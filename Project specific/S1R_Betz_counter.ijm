// Process tiffs in the input dir
// For each tiff that has: (DAPI, S1R, TDP),create cell body ROI based on S1R
// calculate mean intensity and area

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

//setBatchMode("hide");   
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

	title=getTitle();		//sample title str: [0]16_[1]Ctrl_[2]Med_[3]647S1Rrb-594VChATrb_[4]01_[5]null_[6]3
	imgArea=getValue("Area");
	title_arr=split(title,"_");
	group=title_arr[1];
	case=title_arr[0];
	region=title_arr[2];
//	class=title_arr[5]; //options: null, VChat-S1R
	cellid=substring(title_arr[6],0,indexOf(title_arr[6], ".tif"));
	infoString="Case "+case+" "+region+" cell "+cellid+"";
		
	print("Processing "+infoString+". ("+i+1+"/"+list.length+")");
	roiManager("add");	//add the cell outline (existing overlay, should be selected upon file opening)
	roiManager("select", 0);
	roiManager("Rename", "ROI");	//
	roiArea=getValue("Area");
	run("Duplicate...","duplicate");
	rename("backup");
	selectImage(title);
	roiManager("select", 0);
	run("Clear Outside");
	run("Split Channels");
	for(i=1;i<=3;i++){
		selectImage("C"+i+"-"+title);
		channel=getChannelInfo(getImageID());	//rename each split image based on the target
		if (channel.matches("DAPI")) {
			rename("DAPI");
		}
		if (channel.matches("FITC.*")) {
		rename("S1R");
		}
			if (channel.matches("TRITC.*")) {
		rename("TDP43");
		}
	}
	selectImage("S1R");	//using S1R to produce full cell area
	run("Duplicate...","title=S1R_areaSeg");
	roiManager("select", 0);
	run("Enhance Contrast", "saturated=2");
	setAutoThreshold("Mean dark no-reset");	//using Mean for now
	run("Convert to Mask");
	run("Keep Largest Region");
	run("Fill Holes");
	run("Erode");
	run("Keep Largest Region");
	run("Dilate");
	run("Gaussian Blur...", "sigma=3");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Fill Holes");
	run("Create Selection");
	roiManager("add");
	roiManager("select", 1);
	roiManager("rename", "cell_outline");
	roiManager("select", roiIndexOf("ROI"));
	roiManager("delete");
	roiManager("select", roiIndexOf("cell_outline"));
	cellArea=getValue("Area");

	
	selectImage("backup");
	roiManager("Set Color", "white");
	roiManager("Set Line Width", 1);
	
	selectImage("S1R");
	meanS1R=getValue("Mean");

	setResult("Group", nResults, group);
	setResult("Case", nResults-1, case);
	setResult("Region", nResults-1, region);
	setResult("Cell ID", nResults-1, cellid);
	setResult("Object", nResults-1, "Cell");
//			setResult("Area seg warning",nResults-1, warnflag);
	setResult("Cell Area (um^2)",nResults-1, cellArea);
	setResult("Mean S1R", nResults-1, meanS1R);
	updateResults();

	selectImage("backup");		//use this as the basis of output image
	if (roiIndexOf("ROI")!=-1){
	roiManager("select", roiIndexOf("ROI");
	roiManager("delete");
	}
	run("Select None");
	run("From ROI Manager");	//convert all ROImngr objects to overlay

	run("Flatten");
	saveAs("Tiff", output+File.separator+case+"_"+region+"_"+cellid+"_seg.tif");
	if (roiManager("count")>0){
		roiManager("deselect");
		roiManager("delete");
		}
	close("*");
}
	

function getChannelInfo(ID){
	selectImage(ID);
	info=getImageInfo();
	info_array=split(info, "\n");
	//Array.show(info_array);
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
function roiIndexOf(roiName) { 	//returns index of roi whose name==roiName. returns -1 (no selection) if none found.
	nR = roiManager("Count"); 
 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName)) { 
			return i; 
		} 
	} 
	return -1; 
} 