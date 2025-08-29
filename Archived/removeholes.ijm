// Intended for running in QuPath IJ script runner to quickly generate ROI for non-void (actual tissue) area. 
// Can't find a good way to modify diff signal levels to the same level so that they can be processed with the same thresholding algo.
// Don't use this.

//run("Duplicate...", "duplicate channels=2");
run("16-bit");
run("Enhance Contrast...", "saturated=20");
run("Apply LUT");
run("Maximum...", "radius=15");
run("Gaussian Blur...", "sigma=2");

setAutoThreshold("Minimum dark no-reset");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Erode");
run("Erode");
run("Erode");
run("Erode");
run("Erode");


run("Create Selection");