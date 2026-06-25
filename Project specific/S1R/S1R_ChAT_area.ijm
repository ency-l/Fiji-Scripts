#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

setBatchMode("hide");   
cleanEnviron();
processFolder(input);
print("Finished");
saveAs("Results", output+File.separator+"Results.csv");


function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	
	for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], suffix)){
			processImage(list[i]);
		}
	}
}


function processImage(file){
    open(input + File.separator +file);

//file names:[0]ALS16_[1]Med_[2]ChaT488_[3]NeuN647_[4]S1R568.vsi - 20x[5]_DAPI, FITC, Cy5, TRITC_[6]01_[7]Double+_[8]2.tif
//need: [0]: group/case; [1]: region; [7]: class; [8]: cell ID

//get basic info of the active image
	title=getTitle();		
	imgArea=getValue("Area");
	if(imgArea>=20000){
		print("Non cell image detected, skipping file: "+title+".");
	}
	else{
	title_arr=split(title,"_");
	if (matches(title_arr[0],"ALS.*")){
		case=substring(title_arr[0],indexOf(title_arr[0], "S")+1);
		group="ALS";
	}
	else{
		case=substring(title_arr[0],indexOf(title_arr[0], "l")+1);
		group="Control";
	}
	region=title_arr[1];
	class=title_arr[7]; //options: "Double+", "Only NeuN+", "Double -", null
	cellid=substring(title_arr[8],0,indexOf(title_arr[8], ".tif"));
	infoString="Case "+case+" "+region+" cell "+cellid+"";
	print("Processing "+infoString+". ("+i+1+"/"+list.length+")");

//split channels
//Stack.setChannel(2); 
run("Duplicate...","duplicate");
rename("backup");
selectImage(title);
run("Duplicate...", "duplicate channels=2"); //2=ChAT, 3=TDP, 4=S1R
rename("chat");

//run("Enhance Contrast...", "saturated=0.5");
//run("Apply LUT");
//run("8-bit");
//run("Auto Local Threshold", "method=Bernsen radius=15 parameter_1=0 parameter_2=0 white");
setAutoThreshold("Otsu dark 16-bit no-reset");
run("Convert to Mask");

	run("Fill Holes");
	run("Erode");
//	run("Watershed");
	run("Keep Largest Region");
	run("Dilate");
	run("Gaussian Blur...", "sigma=5");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Fill Holes");
	run("Erode");
		run("Keep Largest Region");
run("Create Selection");
area=getValue("Area");
//print(area);
roiManager("add");
selectImage("backup");
roiManager("select", 0);
	roiManager("Set Color", "white");
	roiManager("Set Line Width", 3);
run("Flatten");
rename("rgb");

saveAs("Tiff",output+File.separator+case+"_"+region+"_"+cellid+"_"+class+"_seg.tif");
setResult("Group",nResults,group);
setResult("Case",nResults-1,case);
setResult("Region",nResults-1,region);
setResult("Class",nResults-1,class);
setResult("Cell ID",nResults-1,cellid);
setResult("Area (um^2)",nResults-1,area);
setResult("Image size",nResults-1,imgArea);
updateResults();
	if (roiManager("count")>0){
		roiManager("deselect");
		roiManager("delete");
		}
	close("*");
}
}


function getChannelInfo(ID){	//returns the name of the currently active channel in currently active image
	selectImage(ID);
	info=getImageInfo();
	info_array=split(info, "\n");
	Array.show(info_array);
	channel_info_ar=Array.filter(info_array,"(Image:.*)");
	channel_info=channel_info_ar[0];
	openBracketIndex=indexOf(channel_info, "(");
	closeBracetIndex=indexOf(channel_info, ")");
	channel_name=substring(channel_info,openBracketIndex+1,closeBracetIndex);
	return channel_name;
	
}
function cleanEnviron(){
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
}