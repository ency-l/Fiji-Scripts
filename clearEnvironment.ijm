//Clears results, logs, ROI manager and close all open files.

if (isOpen("Results")){
	selectWindow("Results");
	Table.deleteRows(0, nResults-1);
}
if (roiManager("count")>0){
	roiManager("deselect");
	roiManager("delete");
}
close("*");
print("\\Clear");
