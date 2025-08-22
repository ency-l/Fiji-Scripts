inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("Choose a folder to save the measurement spreadsheet");


// Get a list of all TIFF files in the directory
list = getFileList(inputDir);

// Process each TIFF file in the directory
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
open(inputDir + list[i]);


numImages = nImages;
if (numImages == 0) {
    exit("No images are open.");
}
/*if (numImages>1){
	waitForUser("More than 1 image is open. Please close the ones you don't need. Otherwise the script misbehaves.";	
}
*/

run("Make Subset...", "channels=1,4");
title = getTitle();
/*
//check if file name has space, parentheses or dashes, show a warning
if (matches(title,".*[\\s\\(\\)\\-].*")==true) {
	waitForUser("The file name: "+title+" contains space, parentheses \"()\" or dashes \"-\". \n This might mess up the data label when saving measurements to excel. \n Click OK to proceed or click cancel to abort.");
}*/
selectImage(title);
//run("Duplicate...", "duplicate");
run("Split Channels");
selectImage("C1-"+title);
 //dapi
resetMinAndMax;

run("Enhance Contrast", "saturated=5");
//waitForUser;
//setMinAndMax(800, 2500);
run("Gaussian Blur...", "sigma=2");
//-------------debug breakpoint if can't get good nuc ROI-------------
setAutoThreshold("Otsu dark no-reset");
run("Convert to Mask");
//run("Fill Holes");
//run("Keep Largest Region");
setTool("wand");
waitForUser("Please use the Wand tool select the nucleus you want.\n If there is none, click ok to skip this image.");


if (selectionType==-1) {print("Skipped "+title+"."); }
else{

roiManager("Add");
run("Area to Line");
roiManager("Add");
selectImage("C2-"+title); //tritc
ROI_count=roiManager("count"); //starting from an empty ROIM, this should be 2.
roiManager("Select", ROI_count-1);
 //select the line ROI (index=1)
roiManager("Set Line Width", 3);
run("Measure");
run("Select None");
/*
setAutoThreshold("Huang dark no-reset");
//setTool("wand");
waitForUser('Please use the Wand tool select the nucleus you want');
*/
roiManager("Select", ROI_count-2); //select the area ROI (index=0)
RoiManager.scale(0.7, 0.7, true);
roiManager("Add");
roiManager("Deselect");
roiManager("Select", ROI_count); //select the small nucleus ROI (index=2) 
run("Measure");
selectWindow("Results");
close("*");
run("Read and Write Excel", "dataset_label="+title+" file=["+outputDir+"/Measurement_Results.xlsx]");
//return environment to initial state for the next iteration
run("Clear Results");
roiManager("deselect");
roiManager("delete");
print("Processed "+i+1+"/"+list.length+" images.");
    }
    }
}
