//LCST axon counts normalized for area
//takes folder input and output results to an excel file
// Prompt user to select the input and output directory
inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("Choose a folder to save results");
setBatchMode("hide");
// Get a list of all TIFF files in the directory
list = getFileList(inputDir);

// Process each TIFF file in the directory
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
        open(inputDir + list[i]);
run("Set Measurements...", "area redirect=None decimal=3");
Roi.setPosition(1);
roiManager("Add");
roiManager("Select", 0);
getStatistics(area);

roiManager("deselect");
roiManager("delete");

//prepare a copy of file for processing
run("Make Subset...", "channels=2,3");
title = getTitle();

run("Split Channels");

//1.1 Select green channel (NFH)

selectWindow("C1-" + title);

//1.2 reset display contrast because IJ likes to mess it up
resetMinAndMax();


//2. threshold
setAutoThreshold("Default dark no-reset");
run("Convert to Mask");
//run("Threshold...");
run("ROI Manager...");

//3. Analyze particles to find the axons. Change pars if needed.

run("Analyze Particles...", "size=0-85 circularity=0.50-1.00 exclude composite add");
AxonNo=RoiManager.size;
setResult("Count", 0, AxonNo);
setResult("Full Area", 0, area);
run("Read and Write Excel", "dataset_label="+title+" no_count_column file=["+outputDir+"/Measurement_Results.xlsx]");
roiManager("deselect");

roiManager("Measure");

selectWindow("Results");

run("Read and Write Excel", "dataset_label="+title+" no_count_column file=["+outputDir+"/Measurement_Results.xlsx]");
//return environment to initial state for the next iteration
run("Clear Results");
roiManager("deselect");
roiManager("delete");
print("Processed "+i+1+"/"+list.length+" images. Counted "+AxonNo+" axons in "+area+" um^2.");
    }
}