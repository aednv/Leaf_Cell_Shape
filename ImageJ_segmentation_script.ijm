//gets the current cellset segmentation filename (from 'segmentation_images_from_cellset' folder)
//make sure image file is selected before pressing run, otherwise it will name the currentfile wrongly
waitForUser("select image, if finished force quit imagej with cntr-alt-del :P");
currentfilename=getInfo("image.filename");
currentfilename=replace(currentfilename, ".png", "");

segmentation_data_dir="C:/Users/aeden/OneDrive/Desktop/segmentation_macro/segmentation_data/"
segmentation_annotated_dir="C:/Users/aeden/OneDrive/Desktop/segmentation_macro/segmentation_data/segmentation_annotated/"
cell_jpg_output_dir="C:/Users/aeden/OneDrive/Desktop/segmentation_macro/cell_jpg_output/"
original_max_projections_dir="C:/Users/aeden/OneDrive/Desktop/segmentation_macro/original_max_projections/"
segmentation_images_from_cellset_dir="C:/Users/aeden/OneDrive/Desktop/segmentation_macro/segmentation_images_from_cellset/"

//original cellset image needs to be converted to 8 bit and flipped black and white for segmentation
run("8-bit");
run("Invert");

//morphological segmentation of cellset segmentation with MorphoLibJ

run("Morphological Segmentation");

wait(1000);

call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType","border");
call("inra.ijpb.plugins.MorphologicalSegmentation.segment","tolerance=10","calculateDams=true","connectivity=6");
call("inra.ijpb.plugins.MorphologicalSegmentation.toggleOverlay");
call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat","Catchment basins");
wait(2000);
call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
close("Morphological Segmentation");

//naming segmented image based on orginal image name
rename(currentfilename+"_segmentation.tif");

//saving to segmentation_data_dir
save(segmentation_data_dir+currentfilename+"_segmentation.tif");

//opening original image for comparison
open(original_max_projections_dir+currentfilename+".jpg")

//starting the loop counter n is set at 1. Once there is no selection counter will be set to 0.

n = 1


while (n>0){
	setTool("wand");
	waitForUser("Select cell " + n + ". If finished, select nothing (ctrl+shift+A).");
	type=selectionType();

	//if there is no selection, breaks loop
	if (type==-1){
		n=0;
	} 

	//if there is a selection
	else {
	//adds selection to roiManager for labelling
	roiManager("add");
	
	//fills selection with black to avoid double-counting
	//setColor("#08640D");
	//fill();
	//run("Copy");
	//opens new file to deposit cell outline, make sure pixel dimentions match
	//newImage(currentfilename+"_"+n, "8-bit white", 1024, 1024, 1);
	//run("Paste");
	//setColor("#08640D");
	//fill();
	
	//save(cell_jpg_output_dir+currentfilename+"_"+n+".jpg");
	setColor("#08640D");
	fill();
	run("Copy");
	//opens new file to deposit cell outline, make sure pixel dimentions match
	newImage(currentfilename+"_"+n, "8-bit white", 1024, 1024, 1);
	run("Paste");
	setColor("#08640D");
	fill();
	save("C:/Users/aeden/OneDrive/Desktop/segmentation_macro/cell_jpg_output/"
+currentfilename+"_"+n+".jpg");
	close(currentfilename+"_"+n);
	n=n+1;
	
	}
}

roiManager("show all with labels");

//saving roi (region of interest) data
roiManager("save", segmentation_data_dir+currentfilename+".zip");

waitForUser("Press F to make labeled image, and select the new image, then press ok ^.^");
//saving labeled image
save(segmentation_annotated_dir+currentfilename+"-catchment-basins.tif");
close(currentfilename+"-catchment-basins-1.tif");

//closes all images
close("*");
close("Roi Manager");

//opens next cellset segmentation image
open(segmentation_images_from_cellset_dir+currentfilename+".png");
run("Open Next");
close(segmentation_images_from_cellset_dir+currentfilename+".png");

//re-runs macro
runMacro("C:/Users/aeden/OneDrive/Desktop/segmentation_macro/segmentation macro code.ijm");