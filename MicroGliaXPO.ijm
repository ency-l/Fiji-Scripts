
// Prompt user to select the input and output directory
inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("Choose a folder to save processed TIFF files");

// Get a list of all TIFF files in the directory
list = getFileList(inputDir);

// Process each TIFF file in the directory
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
        open(inputDir + list[i]);

//prepare a copy of file for processing
run("Duplicate...", "duplicate");
title = getTitle();

//check if file name has space, parentheses or dashes, show a warning
if (matches(title,".*[\\s\\(\\)\\-].*")==true) {
	waitForUser("The file name: "+title+" contains space, parentheses \"()\" or dashes \"-\". \n This might mess up the data label when saving measurements to excel. \n Click OK to proceed or click cancel to abort.");
}

//continue to initialize file if name is ok
xSize=getWidth();
ySize=getHeight();
run("Split Channels");

// Assuming order: C1 = DAPI (blue), C3 = Microglia (cyan), C2 = FITC (green)
selectWindow("C3-" + title); // Microglia
rename("Microglia");
selectWindow("C1-" + title); // DAPI
rename("DAPI");
selectWindow("C2-" + title); // FITC
rename("XPO");

// Create microglia mask ---------
selectWindow("Microglia");
run("Enhance Contrast...", "saturated=5");
run("Gaussian Blur...", "sigma=2");
setAutoThreshold("Default dark no-reset");
run("Convert to Mask");
rename("Microglia_Mask");

// Segment all nuclei from DAPI ---------
selectWindow("DAPI");
run("Enhance Contrast...", "saturated=5");
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("Otsu dark no-reset");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=10-Infinity show=Nothing add");


// Save the total number of nuclei ROIs
totalROIs = roiManager("count");

//make a new file for adding nuclei that meet the criteria
newImage("SelectedNuclei", "8-bit black", xSize, ySize, 1);

//check each nucleus ROI's overlap with microglia mask
for (j = 0; j <totalROIs; j++) {
   selectWindow("DAPI");
   roiManager("Select", j);
   run("Create Mask");
   rename("TempROI");
   run("Image Calculator...", "image1=TempROI operation=AND image2=Microglia_Mask create");
   rename("OverlapTest");
   run("Set Measurements...", "area redirect=None decimal=3"); 
   run("Analyze Particles...", "size=1-Infinity show=Nothing display clear");
   if(nResults>0)
   	{imageCalculator("OR", "SelectedNuclei","TempROI");}
	close("TempROI");
	close("OverlapTest");
}
//Replace ROI manager's contents with the selected nuclei
roiManager("Deselect");
roiManager("Delete");
selectWindow("SelectedNuclei");
run("Create Selection");
roiManager("split");
//measure green
selectWindow("XPO");
run("Set Measurements...", "area mean display redirect=None decimal=3");
selectedROIs=roiManager("count");
for (j = 0; j <selectedROIs; j++) {
	roiManager("Select",j);
	roiManager("Measure");
}
//save mask and measurements
selectWindow("SelectedNuclei");
filename = title+"_Microglia_Nuc";
saveAs("Tiff", outputDir + filename);
close("*");
run("Read and Write Excel", "dataset_label="+title+" file=["+outputDir+"/Measurement_Results.xlsx]");
//return environment to initial state for the next iteration
run("Clear Results");
roiManager("deselect");
roiManager("delete");
}
}
