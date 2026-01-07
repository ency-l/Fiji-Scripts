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
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		processImage(list[i]);
	}
}



function processImage(file){
	check=Array.concat(check,newArray(1,2,3));
    open(input + File.separator +file);
	run("Set Measurements...", "redirect=None decimal=3");
	skipflag=false;
	warnflag=NaN;
	title=getTitle();
	imgArea=getValue("Area");
	title_arr=split(title,"_");
	group=title_arr[1];
	case=title_arr[2];
	region=title_arr[3];
	class=title_arr[8];
	cellid=substring(title_arr[9],0,indexOf(title_arr[9], "."));
	infoString="Case "+case+" "+region+" cell "+cellid;
	if(class=="Puncta-"){
		s1rflag=false;
	}
	else if(class=="Puncta+"){
		s1rflag=true;
	}
	else{
		skipflag=true;
	}
	if(skipflag==false){
		print("Processing "+infoString+". ("+i+1+"/"+list.length+")");
		run("Duplicate...","duplicate");
		rename("copy");
		selectImage(title);
		run("Split Channels");
		for(i=1;i<=3;i++){
			selectImage("C"+i+"-"+title);
			channel=getChannelInfo(getImageID());
			if (channel=="DAPI") {
				rename("DAPI");
			}
			if (channel=="FITC") {
			rename("S1R");
			}
				if (channel=="TRITC") {
			rename("TDP");
			}
		}
		selectImage("S1R");
		run("Duplicate...","title=S1R_areaSeg");
		setAutoThreshold("Triangle dark no-reset");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Keep Largest Region");
		run("Fill Holes");
		run("Erode");
		run("Keep Largest Region");
		run("Dilate");
		run("Create Selection");
		roiManager("add");
		roiManager("select", 0);
		roiManager("rename", "cell_outline");
		cellArea=getValue("Area");
		suffix="";
		if(cellArea/imgArea>0.8){
			print("Warning: The segmented cell area is more than 80% of the whole image area. This could be a failed segmentation. Please double check this cell. ");
			warnflag="large";
			suffix=suffix+"_checkArea";
		}		
		else if(cellArea/imgArea<0.1){
			print("Warning: The segmented cell area is less than 10% of the whole image area. This could be a failed segmentation. Please double check this cell. ");
			warnflag="small";
			suffix=suffix+"_checkArea";
		}
		selectImage("S1R");
		roiManager("select", 0);
		if (s1rflag==true){
			roiManager("Set Color", "#48d1cc");
		}
		else{
			roiManager("Set Color", "white");
		}

		roiManager("Set Line Width", 1);
		meanS1R=getValue("Mean");
		setResult("Group", nResults, group);
		setResult("Case", nResults-1, case);
		setResult("Region", nResults-1, region);
		setResult("Cell ID", nResults-1, cellid);
		setResult("Object", nResults-1, "Cell");
		setResult("Area seg warning",nResults-1, warnflag);
		setResult("Cell Area (um^2)",nResults-1, cellArea);
		setResult("Cell Mean", nResults-1, meanS1R);
		setResult("SSC Class", nResults-1, s1rflag);

		updateResults();
	if(s1rflag==true){
		processSSC();
	}
		selectImage("copy");
		roiManager("Show All without labels");
		run("Flatten");
		saveAs("Tiff", output+File.separator+case+"_"+region+"_"+cellid+suffix+".tif");
		if (roiManager("count")>0){
			roiManager("deselect");
			roiManager("delete");
		}
		close("*");
	}
	else{
		print("Image without puncta class detected. Skipping...");
	}
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

function processSSC(){
	run("Select None");
	selectImage("S1R");
	run("Duplicate...","title=edges");
	run("Find Edges");
	run("Smooth");
	run("Subtract Background...", "rolling=10");
	imageCalculator("Add create", "S1R","edges");
	//run("Subtract Background...", "rolling=10");
	setAutoThreshold("RenyiEntropy dark no-reset");	
	run("Convert to Mask");
	roiManager("select", 0);
	run("Clear Outside");
	run("Fill Holes");
	run("Analyze Particles...", "size=2-Infinity add");
	selectImage("S1R");
	roiManager("select", 0);
	for (j = 1; j < roiManager("count"); j++) {
	    roiManager("select", j);
		roiManager("rename", "SSC"+j);
		roiManager("Set Color", "yellow");
		roiManager("Set Line Width", 1);
		ssc_mean=getValue("Mean");
		List.set("Name",j);
		List.set("Area", getValue("Area"));
		List.set("Mean", getValue("Mean"));
		List.set("Circularity",getValue("Circ."));
		
		setResult("Group", nResults, group);
		setResult("Case", nResults-1, case);
		setResult("Region", nResults-1, region);
		setResult("Cell ID", nResults-1, cellid);
		setResult("Object", nResults-1, "SSC");
		setResult("SSC ID", nResults-1, List.get("Name"));
		setResult("SSC Area", nResults-1, List.get("Area"));
		setResult("SSC Mean", nResults-1, List.get("Mean"));
		setResult("SSC Mean Norm", nResults-1,ssc_mean/meanS1R);
		setResult("SSC Circ",nResults-1,List.get("Circularity"));
		/*setResult("Seg fail warning", nResults-1, NaN);
		setResult("Cell Area (um^2)", nResults-1, NaN);
		setResult("Cell Mean", nResults-1, NaN);
		setResult("SSC Class", nResults-1, NaN);*/

	}
	if(roiManager("count")>1){
		roiManager("select", newArray(1,roiManager("count")-1));
		roiManager("Combine");
		roiManager("Add");
		roiManager("select", roiManager("count")-1);
		ssc_totalArea=getValue("Area");
	

	if(ssc_totalArea/cellArea>0.5){
		print("Warning: The segmented SSC area is more than half of the whole cell area. This could be a failed segmentation. Please double check this cell. ");
		setResult("SSC seg warning",nResults-1,"large");
		suffix=suffix+"_checkSSC";
	}}
	else if(roiManager("count")==1){
		print("Warning: The cell was classified as SSC+ but no SSC was successfully segmented.");
		setResult("SSC seg warning",nResults-1,"fail");
		suffix=suffix+"_checkSSC";
	}
	updateResults();
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
