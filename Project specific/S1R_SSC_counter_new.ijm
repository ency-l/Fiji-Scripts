// Process tiffs in the input dir
// For each tiff that has: (DAPI, S1R, VAChT),create ROI for each S1R and VAChT punctum
// For each punctum, calculate mean intensity and area
// Punctum whose mean intensity is lower than that of the whole cell in the corresponding channel (i.e. darker than the cell) is discarded.
//TODO: calculate colocalization for all above-threshold S1R and VAChT

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
	skipflag=false;
	warnflag=NaN;
	title=getTitle();		//sample title str: [0]16_[1]Ctrl_[2]Med_[3]647S1Rrb-594VChATrb_[4]01_[5]null_[6]3
	imgArea=getValue("Area");
	title_arr=split(title,"_");
	group=title_arr[1];
	case=title_arr[0];
	region=title_arr[2];
	class=title_arr[5]; //options: null, VChat-S1R
	cellid=substring(title_arr[6],0,indexOf(title_arr[6], ".tif"));
	infoString="Case "+case+" "+region+" cell "+cellid+"";
	if(class=="null"){
		s1rflag=false;
	}
	else if(class=="VChat-S1R"){
		s1rflag=true;	//only doing S1R-related measurements on cells that have puncta
	}
	else{
		skipflag=true;	//only if img doesn't have proper cat (invalid)
	}	
	if(skipflag==false){	//standard processing for ALL valid inputs
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
			if (channel.matches("Cy5")) {
			rename("S1R");
			}
				if (channel=="TRITC") {
			rename("VAChT");
			}
		}
		selectImage("VAChT");	//using S1R to produce full cell area
		run("Duplicate...","title=VAChT_areaSeg");
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

		
		if (s1rflag==true){
			roiManager("Set Color", "cyan");
		}
		else{
			roiManager("Set Color", "white");
		}

		roiManager("Set Line Width", 1);
		meanVAChT=getValue("Mean");
		selectImage("S1R");
		meanS1R=getValue("Mean");
		channelsArr=newArray(meanS1R,meanVAChT);
		for (i = 0; i < 2; i++) {
			setResult("Group", nResults, group);
			setResult("Case", nResults-1, case);
			setResult("Region", nResults-1, region);
			setResult("Cell ID", nResults-1, cellid);
			setResult("Object", nResults-1, "Cell (ch="+(i+1)+")");
//			setResult("Area seg warning",nResults-1, warnflag);
			setResult("Cell Area (um^2)",nResults-1, cellArea);
			setResult("Cell Mean", nResults-1, channelsArr[i]);
			setResult("SSC Class", nResults-1, s1rflag);
			setResult("SSC Mean", nResults-1, NaN);
			setResult("SSC Mean Norm", nResults-1,NaN);
			updateResults();
		}
		if(s1rflag==true){
			processSSC("S1R");
	
			temp = newArray(roiManager("count")-1);
			if (temp.length>0){
			for (i = 0; i < temp.length; i++)
	    	temp[i] = 1 + i;
			roiManager("select", temp);
			roiManager("Set Color", "green");
			}
			VAChTBeginId=roiManager("count");
			processSSC("VAChT");
			temp = newArray(roiManager("count")-VAChTBeginId);
			if (temp.length>0){
				for (i = 0; i < temp.length; i++)
		    	temp[i] = VAChTBeginId + i;
				roiManager("select", temp);
				roiManager("Set Color", "red");
			}
	
		}
		selectImage("backup");		//use this as the basis of output image
		if (roiIndexOf("ROI")!=-1){
		roiManager("select", roiIndexOf("ROI");
		roiManager("delete");
		}
		run("Select None");
		run("From ROI Manager");	//convert all ROImngr objects to overlay
	
		run("Flatten");
		saveAs("Tiff", output+File.separator+case+"_"+region+"_"+cellid+suffix+"_mean.tif");
		if (roiManager("count")>0){
			roiManager("deselect");
			roiManager("delete");
			}
	}
	else{
		print("Image without puncta class detected. Skipping...");
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

function processSSC(name){
	selectImage(name);
	roiManager("select", roiIndexOf("cell_outline")); //select the cell boundary that was just segmented
	run("Clear Outside");
	roimBegin=roiManager("count");
	Mean=getValue("Mean");
	SD=getValue("StdDev");
	k=Mean;
	print(k);
	run("Duplicate...","duplicate ignore title=temp");
	run("8-bit");
	run("Auto Local Threshold", "method=Niblack radius=30 parameter_1=2 parameter_2=0 white");
	run("Analyze Particles...", "size=1-200 circularity=0.30-1.00 show=Masks");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Dilate");
	run("Create Selection");

	if (selectionType != -1){
		roiManager("add");
	}
	if (selectionType==9){
			roiManager("Split");
			roiManager("select", roimBegin); //delete the composite shape
			roiManager("delete");
		}
	close("temp");
	close("Mask of temp");

		for (j = roimBegin; j < roiManager("count"); j++) {	//iterate through each SSC
		    roiManager("select", j);
			roiManager("rename", "SSC_"+j);
			roiManager("update");
			roiManager("Set Line Width", 1);
			selectImage(name);
			ssc_mean=getValue("Mean");
			if(ssc_mean<k){
				roiManager("delete");
				}
			else{
		    roiManager("select", j);
			List.set("Name",j);
			List.set("Area", getValue("Area"));
			List.set("Xmass",getValue("XM"));
			List.set("Ymass",getValue("YM"));
			
			List.set("Circularity",getValue("Circ."));
			setResult("Group", nResults, group);
			setResult("Case", nResults-1, case);
			setResult("Region", nResults-1, region);
			setResult("Cell ID", nResults-1, cellid);
			setResult("Object", nResults-1, "SSC");
			setResult("Type",nResults-1, name);
			setResult("SSC ID", nResults-1, List.get("Name"));
			setResult("SSC Area", nResults-1, List.get("Area"));
			setResult("SSC Mean", nResults-1, ssc_mean);
			setResult("SSC Mean Norm", nResults-1,ssc_mean/meanS1R);
			setResult("SSC CoM",nResults-1,List.get("Xmass")+", "+List.get("Ymass"));
			}
		
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