#Momocs testing for Solanaceae leaf epidermis project. Reads in cell outline jpgs from ImageJ and outputs leaf area and shape data.
#written by Amber, 2019

library(Momocs)
library(dplyr)

#~~LOADING IN DATA~~

#location of directory containing cell outline folders
dirs <- list.dirs(path = "C:/Users/aeden/OneDrive/Desktop/Test_Coordinates/", full.names = TRUE)

#creating master dataframe outside of loop, and master coo list
endloopDF <-data.frame(row.names=1:11)
listofcoos <- list()

#loops through each cell outline folder
for(i in 2:length(dirs)){
  
  #extracts coo objects from each outline in folder
  list.files(path = dirs[i], full = T, pattern = "jpg") %>% import_jpg() %>% Out()-> l
  
  measures <- matrix(data = NA, nrow = length(l), ncol = 4)
  
  #loops through each coo object and creates matrix of statistical data
  for(i in 1:length(l))
  {
    measures[i,] <- c(coo_area(l[i]), coo_eccentricityboundingbox(l[i]), coo_solidity(l[i]), coo_circularity(l[i]) )
  }
  
  #reorganizing into a dataframe
  measuresDF <- data.frame(measures)
  colnames(measuresDF) <- c('Area', 'AspectRatio', 'Solidity', 'Circularity')
  measuresDF$Sample_Number <- names(l)
  measuresDF <- measuresDF[,c(5,3,2,1,4)]
  
  #extracting data from file names to fill dataframe
  temp_list <- strsplit(measuresDF$Sample_Number, "_")
  temp_list_DF <- t(as.data.frame(temp_list))
  colnames(temp_list_DF) <- c('Species', 'Leaf_side', 'Magnification', 'Cell_number')
  temp_list_DF <- as.data.frame(temp_list_DF)
  
  #splitting leaf side and replicate number
  temp_list_DF$Replicate <- substring(temp_list_DF$Leaf_side,3,3)
  temp_list_DF$Leaf_side <- substring(temp_list_DF$Leaf_side,1,2)
  
  temp_list_DF$Sample_Number <- measuresDF$Sample_Number
  
  #saving coo object in master coo list
  listofcoos <- append(listofcoos, l)
  
  test <- merge(measuresDF, temp_list_DF)
  
  #combining temp data frame with master dataframe outside of loop
  endloopDF <- rbind(endloopDF,test)
  
}

#converting to capital letters
endloopDF$Species <- toupper(endloopDF$Species)
endloopDF$Leaf_side <- toupper(endloopDF$Leaf_side)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#creating coordinate outline objects from jpgs
list.files(path = dataDir, full = T, pattern = "jpg") %>% import_jpg() %>% Out()-> l


#~~EXTRACTING STATISTICAL DATA~~

measures <- matrix(data = NA, nrow = length(l), ncol = 4)

for(i in 1:length(l))
{
  measures[i,] <- c(coo_area(l[i]), coo_eccentricityboundingbox(l[i]), coo_solidity(l[i]), coo_circularity(l[i]) )
}

measuresDF <- data.frame(measures)
colnames(measuresDF) <- c('Area', 'AspectRatio', 'Solidity', 'Circularity')
measuresDF$Sample_Number <- names(l)
measuresDF <- measuresDF[,c(5,3,2,1,4)]

#extracting data from file names

temp_list <- strsplit(measuresDF$Sample_Number, "_")
temp_list_DF <- t(as.data.frame(temp_list))
colnames(temp_list_DF) <- c('Species', 'Leaf_side', 'Magnification', 'Cell_number')
temp_list_DF <- as.data.frame(temp_list_DF)
temp_list_DF$Sample_Number <- measuresDF$Sample_Number
test <- merge(measuresDF, temp_list_DF)

#~~DISPLAYING DATA~~



panel(listofcoos , cols='chartreuse3', borders='black')

#panel plots coordinate objects side by side
panel(x, dim, cols, borders, fac, palette = col_summer,
      coo_sample = 120, names = NULL, cex.names = 0.6, points = TRUE,
      points.pch = 3, points.cex = 0.2, points.col, ...)
coo_listpanel(coo.list, dim, byrow = TRUE, fromtop = TRUE, cols, borders,
              poly = TRUE, points = FALSE, points.pch = 3, points.cex = 0.2,
              points.col = "#333333", ...)