numImages = nImages;
if (numImages == 0) {
    exit("No images are open.");
}
if (numImages>1){
	waitForUser("More than 1 image is open. Please close the ones you don't need. Otherwise the script misbehaves."';	
}
ROI_count=RoiManager.size;
print(ROI_count);


selectImage(1);
run("Duplicate...", "duplicate");
run("Split Channels");
selectImage(2);
resetMinAndMax;
run("Enhance Contrast", "saturated=25");
//waitForUser;
//setMinAndMax(800, 2500);
run("Gaussian Blur...", "sigma=2");
//-------------debug breakpoint if can't get good nuc ROI-------------
setOption("BlackBackground", true);
run("Convert to Mask");
//run("Fill Holes");
//run("Keep Largest Region");
waitForUser('Please use the Wand tool select the nucleus you want');
roiManager("Add");
run("Area to Line");
roiManager("Add");
selectImage(3);
roiManager("Select", ROI_count+1);
roiManager("Set Line Width", 5);
run("Measure");
run("Select None");
/*
setAutoThreshold("Huang dark no-reset");
//setTool("wand");
waitForUser('Please use the Wand tool select the nucleus you want');
*/
roiManager("Select", ROI_count);
RoiManager.scale(0.7, 0.7, true);
roiManager("Deselect");
roiManager("Select", ROI_count);
run("Measure");
selectWindow("Results");
roiManager("Deselect");
//roiManager("delete");
print('Complete!');

