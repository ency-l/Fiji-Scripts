
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