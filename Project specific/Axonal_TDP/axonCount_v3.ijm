//axon counts in LCST ver 2
//Now only detects axons in the LCST roi area
//Improved detection
//prompt input and output dirs
inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("Choose a folder to save results");
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
//title = getTitle();


//1.1 Select green channel (NFH)

selectWindow(title+"_NFH");
Roi.setPosition(1);
roiManager("Add");
roiManager("Select", 0);
getStatistics(area);
//print(area);
run("Clear Outside");
roiManager("deselect");
roiManager("delete");

//1.2 reset display contrast because IJ likes to mess it up
resetMinAndMax();
run("Enhance Contrast...", "saturated=1");


//2. threshold
setAutoThreshold("Default dark no-reset");
run("Convert to Mask");
//run("Threshold...");
run("ROI Manager...");

//3. Analyze particles to find the axons. Change pars if needed.

run("Analyze Particles...", "size=1-85 circularity=0.50-1.00 exclude composite add");
AxonNo=RoiManager.size;
setResult("Count", 0, AxonNo);
setResult("Full Area", 0, area);
run("Read and Write Excel", "dataset_label="+title+" no_count_column file=["+outputDir+"/Measurement_Results.xlsx]");
roiManager("deselect");
roiManager("Measure");
run("Read and Write Excel", "dataset_label="+title+" no_count_column file=["+outputDir+"/Measurement_Results.xlsx]");
//return environment to initial state for the next iteration
run("Clear Results");
roiManager("deselect");
roiManager("delete");
close("*");
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
endTime="Completed at "+hour+":"+minute+":"+second+":"+msec;
print("Processed "+i+1+"/"+list.length+" images. Counted "+AxonNo+" axons in "+area+" um^2."+endTime);
    }
}