//Full analysis pipeline for axonal TDP ROI annotation and measurement. Last updated AM 2025-3-27

//1.Splitting the channels

run("Split Channels");

//1.1 Select red channel (NFH)

list = getList("image.titles");
for (i=0; i<list.length; i++){
print(list[i]);
if (startsWith(list[i], "C3-"))
selectWindow(list[i]);}

//1.2 reset display contrast because IJ likes to mess it up
resetMinAndMax();


//2. threshold
setAutoThreshold("Default dark no-reset");
//run("Threshold...");
run("ROI Manager...");

//3. Analyze particles to find the axons. Change pars if needed.

run("Analyze Particles...", "size=1.00-200.00 circularity=0.50-1.00 show=[Overlay Masks] exclude clear include overlay add");

//3.1 send annoatated ROIs to QuPath
run("Send RoiManager ROIs to QuPath", "choose_object_type=Annotation select_objects");

//3.9 Select green channel (TDP-43) for following analysis
for (i=0; i<list.length; i++){
print(list[i]);
if (startsWith(list[i], "C2-"))
selectWindow(list[i]);}

//4. Measure TDP-43 in all ROIs 
resetMinAndMax();
roiManager("Show None");
roiManager("Show All");
roiManager("Measure");
