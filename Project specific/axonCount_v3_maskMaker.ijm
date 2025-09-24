//axon counts in LCST ver 2
//Now only detects axons in the LCST roi area
//Improved detection
//prompt input and output dirs
inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("Choose a folder to save generated masks");
setBatchMode("hide");
// Get a list of all TIFF files in the directory
list = getFileList(inputDir);

// Process each TIFF file in the directory
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
        open(inputDir + list[i]);
        
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
beginTime="Began at "+hour+":"+minute+":"+second+":"+msec;
print("Start processing "+i+1+"/"+list.length+" images."+beginTime );

run("Set Measurements...", "area redirect=None decimal=3");
title = getTitle();

//prepare a copy of file for processing
run("Duplicate...", "title="+title+"_NFH duplicate channels=2");
selectWindow(title);
run("Duplicate...", "title="+title+"_DAPI duplicate channels=1");
//title = getTitle();

//1.0.5 Make a nucleus mask to remove regions overlapping with the nuc
selectWindow(title+"_DAPI");
run("Clear Outside");
run("Maximum...", "radius=5");
setAutoThreshold("Default dark no-reset");
run("Convert to Mask");//title = getTitle();


//1.1 Select green channel (NFH)

selectWindow(title+"_NFH");
Roi.setPosition(1);
roiManager("Add");
//roiManager("Select", 0);
//getStatistics(area);
//print(area);
run("Clear Outside");
roiManager("deselect");
roiManager("delete");

//1.2 reset display contrast because IJ likes to mess it up
resetMinAndMax();
//run("Enhance Contrast...", "saturated=1");


//2. threshold
run("Top Hat...", "radius=10");
//setAutoThreshold("Default dark no-reset");
setAutoThreshold("RenyiEntropy dark no-reset");
run("Convert to Mask");
//run("Threshold...");
//run("ROI Manager...");
imageCalculator("Subtract create", title+"_NFH",title+"_DAPI");
run("Close-");
run("Fill Holes");
run("Erode");
run("Dilate");
//selectWindow("Result of "+title+"_NFH");*/
filename=substring(title,0,indexOf(title, "."));
saveAs("tiff", outputDir+filename+"_Mask");
close("*");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
endTime="Completed at "+hour+":"+minute+":"+second+":"+msec;
print("Processed "+i+1+"/"+list.length+" images. "+endTime);
    }
}