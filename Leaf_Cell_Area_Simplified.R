#Leaf cell area analysis scripts. Reads in cell shape jpgs from ImageJ and outputs area and shape statistics.
#written by Amber, 2019

install.packages("Momocs")
install.packages("ggplot2")
library(Momocs)
library(ggplot2)

#set the path to where leaf jpg outlines are stored
dirs <- list.dirs(path = "", full.names = TRUE)

list.files(path = dirs, full = T, pattern = "jpg") %>% import_jpg() %>% Out()-> l
measures <- matrix(data = NA, nrow = length(l), ncol = 4)

#loops through each coordinate object and creates matrix of statistical data
for(i in 1:length(l))
{
  measures[i,] <- c(coo_area(l[i]), coo_eccentricityboundingbox(l[i]), coo_solidity(l[i]), coo_circularity(l[i]) )
}

#reorganizing into a dataframe

measuresDF <- data.frame(measures)
colnames(measuresDF) <- c('Area', 'AspectRatio', 'Solidity', 'Circularity')
measuresDF$Sample_Number <- names(l)
measuresDF <- measuresDF[,c(5,3,2,1,4)]

#~~~~~~~~~~~~

#extracting data from file names to fill dataframe
temp_list <- strsplit(measuresDF$Sample_Number, "_")
#fixing weird filenames
for(i in 1:length(temp_list)){
  if (length(temp_list[[i]]) != 4){
    print(i)}
  if (length(temp_list[[i]]) == 3){
    temp_list2 <- unlist(strsplit(temp_list[[i]][3], 'x'))
    temp_list[[i]][3] <- paste0(temp_list2[1], 'x')
    temp_list[[i]] <- append(temp_list[[i]], temp_list2[2])
  }
}



temp_list_DF <- t(as.data.frame(temp_list))
colnames(temp_list_DF) <- c('Species', 'Leaf_side', 'Magnification', 'Cell_number')
temp_list_DF <- as.data.frame(temp_list_DF)

#splitting leaf side and replicate number

temp_list_DF$Replicate <- substring(temp_list_DF$Leaf_side,3,3)
temp_list_DF$Leaf_side <- substring(temp_list_DF$Leaf_side,1,2)

temp_list_DF$Sample_Number <- measuresDF$Sample_Number


temp_list_DF$Species <- toupper(temp_list_DF$Species)
temp_list_DF$Leaf_side <- toupper(temp_list_DF$Leaf_side)

test <- merge(measuresDF, temp_list_DF)
l$fac <- test

l$fac$Species <- as.factor(l$fac$Species)
l$fac$Leaf_side <- factor(l$fac$Leaf_side, levels = c("AD", "AB"))

#writing shape data to csv
write.csv(l$fac, "epcell_data.csv")

#plotting shape data with ggplot
ggplot(l$fac, aes(x=Species, y=Circularity, fill=Leaf_side)) + 
  geom_boxplot()

plot.new()
panel(arrange(l, desc(Circularity)), fac = "Species", palette = col_summer2)