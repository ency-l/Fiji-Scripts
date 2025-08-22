/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.
setBatchMode("hide");
processFolder(input);
run("Read and Write Excel","file=["+output+"/Results.xlsx] sheet="+getResult("Case",nResults-1)+" dataset_label="+getResult("Case",nResults-1));
Array.show(EdgeException);
Dialog.createNonBlocking("Done");
Dialog.addMessage("Finished processing all images.", 20, "#0000ff");
Dialog.show();
// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
//		if(File.isDirectory(input + File.separator + list[i]))  these are for recursive processing, no need for this
//			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}
function processFile(input, output, file) {

	open(input+File.separator+list[i]);
	print("Processing: " + input + File.separator + file+" ("+i+1+"/"+list.length+")");
	print("......Preparing file info");
	FileName=split(list[i],"(\\s|_|\\.)");					// Split image name by space, underscore or dot. Then save the strings as an array.
	FileInfo=newArray(FileName[0],FileName[4],FileName[5]);   //get image info from file name. [0] Case, [1] Inclusion type, [2] ID.
	print("......Checking case names");
	if(i>0){	//don't run this on first loop (there are no results to compare to)
		prevCase=getResult("Case",nResults-1);
		if(FileInfo[0]!=prevCase){ //if the case name of current file is different from the last file processed:	
			run("Read and Write Excel","file=["+output+"/Results.xlsx] sheet="+prevCase+" dataset_label="+prevCase);   //write all existing results into excel under the sheet named after the case.
			Table.deleteRows(0,nResults-1); //clear results.
			print("\\Update: New case detected.Finished processing and saving case "+prevCase+".");
		}
	}	//This if loop checkes if we are moving onto a new case, and if we are, saves all the measurements from existing case and wipes restuls table. In effect this makes each case saved in a long column (each image is 1 row of data) and in different sheets. This loop however doesn't account for the last case (there's no case after it to trigger the loop), hence a copy of the save statement is added after the whole processing is finished to save the last case. (ln 13)
	
	//initialize measurement results vars
	MeanVal=newArray(3);
	SDVal=newArray(3);  //not used
	AreaVal=newArray(3);//not used
	EdgeException=newArray();
	
	print("......Splitting Stack");
	run("Duplicate...", "duplicate");
	title=getTitle();
	run("Split Channels");

	//generate TDP ROI and save to ROIM
	print("......Segmenting TDP-43 ");
	selectImage("C3-"+title);
	setAutoThreshold("Huang dark 16-bit no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Keep Largest Region");
	run("Create Selection");

	if (selectionType==-1) {print("Skipped "+title+"."); }
	else{
	roiManager("add");	
	RoiManager.select(roiManager("count")-1);
	i_tdp=roiManager("index");
	
//--------Edge measurement with LoG------------
	print("......Convolving");
	selectImage("C2-"+title);
	run("Duplicate...","title=G_edge");
	//kernel used for convolve
	kernel="[0 0 0 -1 -1 -1 0 0 0\n0 -1 -1 -3 -3 -3 -1 -1 0\n0 -1 -3 -3 -1 -3 -3 -1 0\n1 -3 -3 6 13 6 -3 -3 -1\n1 -3 -1 13 24 13 -1 -3 -1\n1 -3 -3 6 13 6 -3 -3 -1\n0 -1 -3 -3 -1 -3 -3 -1 0\n0 -1 -1 -3 -3 -3 -1 -1 0\n0 0 0 -1 -1 -1 0 0 0\n]";
	run("Convolve...", "text1="+kernel+" normalize");
	//make small version of tdp (for inner edge boundary)
	RoiManager.select(i_tdp);
	run("Scale... ", "x=0.8 y=0.8 centered");
	roiManager("add");
	RoiManager.select(roiManager("count")-1);
	i_Stdp=roiManager("index");
	//make large version of tdp (for outer edge boundary)
	RoiManager.select(i_tdp);
	run("Scale... ", "x=1.2 y=1.2 centered");
	roiManager("add");
	RoiManager.select(roiManager("count")-1);
	i_Ltdp=roiManager("index");
	//make band ROI and measure edge 
	roiManager("select", newArray(i_Stdp,i_Ltdp));
	roiManager("XOR");
	}
	if (selectionType==-1) {
		print("......Unable to create edge in  "+title+". Skipped."); 
		Array.concat(EdgeException,title);
	}

	else{
	roiManager("add");
	print("......Saving edge measurements");
	RoiManager.select(roiManager("count")-1);
	i_tdpEdge=roiManager("index");
	MeanVal[0]=getValue("Mean");
	SDVal[0]=getValue("StdDev");
	AreaVal[0]=getValue("Area");
	
//--------Relative NFH Intensity measurement-------------
	print("......Saving TDP-43(+) region measurements");
	selectImage("C2-"+title);
	RoiManager.select(i_tdp);
	MeanVal[1]=getValue("Mean"); //NFH values from TDP(+) ROI
	SDVal[1]=getValue("StdDev");
	AreaVal[1]=getValue("Area");
	print("......Saving environment region measurements");	
	run("Make Band...","band=1.5");
	roiManager("add");
	RoiManager.select(roiManager("count")-1);
	i_tdpBand=roiManager("index");	//this is diff from tdpEdge because this is exclusively area OUTSIDE the original TDP dot. i.e. environment (TDP-) intensity
	MeanVal[2]=getValue("Mean"); //NFH values from the surrounding environment
	SDVal[2]=getValue("StdDev");
	AreaVal[2]=getValue("Area");
	ratio=MeanVal[1]/MeanVal[2];
//--------arrange data for saving-----------
	print("......Writing results");	
	setResult("Case",nResults, FileInfo[0]);
	setResult("Inclusion_Type",nResults-1, FileInfo[1]);
	setResult("ID",nResults-1, FileInfo[2]);
	setResult("TDP_Size",nResults-1, AreaVal[1]);
	setResult("Edge_Str",nResults-1, MeanVal[0]);
	setResult("Norm_NFH_Str",nResults-1, ratio);
	updateResults();
	close("*");

	}
}