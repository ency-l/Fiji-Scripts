
//run("Duplicate...", "duplicate channels=2");
run("16-bit");
run("Enhance Contrast...", "saturated=5");
//run("Apply LUT");
//run("Maximum...", "radius=15");
run("Gaussian Blur...", "sigma=2");
setBatchMode("show");
run("Threshold...");
waitForUser("Set threshold manually and click apply. Then click OK.");
//setAutoThreshold("Minimum dark no-reset");
//setOption("BlackBackground", true);
//run("Convert to Mask");
run("Erode");
run("Erode");
run("Erode");
run("Erode");
run("Erode");
run("Threshold...");

run("Create Selection");
run("Send ROI to QuPath");
run("Close All");