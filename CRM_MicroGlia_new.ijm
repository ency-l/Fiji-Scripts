#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

setBatchMode("hide");
processFolder(input);
run("Read and Write Excel","file=["+output+"/Results.xlsx] sheet="+getResult("Case",nResults-1)+" dataset_label="+getResult("Case",nResults-1));
Table.deleteRows(0,nResults-1); //clear results.
waitForUser("Done!");

// function to scan folders to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		//if(File.isDirectory(input + File.separator + list[i]))   don't want recursive search
		//	processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	open(input+File.separator+list[i]);
	print("Processing: " + input + File.separator + file+" ("+i+1+"/"+list.length+")");
	
print(">> Initializing. ");
	xSize=getWidth();
	ySize=getHeight();
	FileName=split(list[i],"(_|\\.)");					// Split image name by underscore or dot. Then save the strings as an array.
	FileName=Array.deleteIndex(FileName, 4);		//remove the "tif" element
	//Filname[]: [0] Group, [1] Case No, [2] CRM classification, [3] Annotation ID
	Area=newArray(2);
	GMean=newArray(2);
	YMean=newArray(2);
	YSD=newArray(2);
	//results arrays. [0] Nuc [2] Cyt.
print("\\Update:>> Initializing. (Done)");

	if(i>0 && nResults>0){	//don't run this on first loop (there are no results to compare to) or if the results are empty (from skipping a whole case)
print(">> Checking case names");
		prevCase=getResult("Case",nResults-1);
		if(FileName[1]!=prevCase){ //if the case name of current file is different from the last file processed:	
			run("Read and Write Excel","file=["+output+"/Results.xlsx] sheet="+prevCase+" dataset_label="+prevCase);   //write all existing results into excel under the sheet named after the case.
			Table.deleteRows(0,nResults-1); //clear results.
			print("\\Update:>> Checking case names (Done)");
			print(">>>> New case detected.Finished processing and saving case "+prevCase+".");
		}
		else{
print("\\Update:>> Checking case names (Done)");}}	//This if loop checkes if we are moving onto a new case, and if we are, saves all the measurements from existing case and wipes restuls table. In effect this makes each case saved in a long column (each image is 1 row of data) and in different sheets. This loop however doesn't account for the last case (there's no case after it to trigger the loop), hence a copy of the save statement is added after the whole processing is finished to save the last case. (ln 13)

print(">> Splitting Channels");
	run("Duplicate...", "duplicate");
	title=getTitle();
	run("Split Channels");
	close("C4-*");		//close red 
print("\\Update:>> Splitting Channels (Done)");

print(">> Segmenting IBA-1");
	selectImage("C3-"+title);
	setAutoThreshold("Default dark no-reset"); //using the slighly more lenient Default thresholder.
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Create Selection");
	roiManager("add");
	RoiManager.select(roiManager("count")-1);
	i_IBA=roiManager("index");
print("\\Update:>> Segmenting IBA-1 (Done)");

print(">> Segmenting Nuclei");
	selectImage("C1-"+title); //select DAPI
	//generate TDP ROI and save to ROIM
	setAutoThreshold("Otsu dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Watershed");
	run("Create Selection");
	roiManager("add");
print("\\Update:>> Segmenting Nuclei (Done)");

print(">> Finding IBA-1-associated nuclei");
	RoiManager.select(roiManager("count")-1); //select  most recent item in ROIM (the raw compound DAPI mask)
	if (Roi.getType=="composite"){	//split if there are multiple nuclei
		roiManager("split");
		roiManager("delete");			//remove raw compound DAPI mask
		i_NucAllList=newArray();					
		a_NucAllList=newArray();					
		for(i=i_IBA+1; i<RoiManager.size; i++){						//go through everything except the IBA mask (should be all splitted nuc)
			roiManager("select", i);
			i_NucAllList=Array.concat(i_NucAllList,roiManager("index"));	//saving the index of splitted nuc into an array for retreival. 
			a_NucAllList=Array.concat(a_NucAllList,getValue("Area"));	//saving the area of splitted nuc into an array for testing overlap later.
		}
	
		t_NucAllList=newArray(i_NucAllList.length);				//new list that is the same size as the # of nucs to store test results.
			// the indeces in all NucAllLists (i_, a_, t_) should match each other and refer to the same ROI. That is to say, for ROI x, its info is stored in i_[n]= ROIM index of x; a[n]= area of x; t_[n]= overlap test of x.		
		for(i=0;i<i_NucAllList.length;i++){
			roiManager("Select",newArray(i_IBA,i_NucAllList[i]));	//select the IBA mask and one of the nucleus
			roiManager("AND");					//AND operation to find overlap
			run("Create Selection");
			if (selectionType()!=-1) {
				roiManager("Add");										//add to ROIM
				RoiManager.select(roiManager("count")-1); 				//select the newly added overlap ROI
				OverlapSize=getValue("Area");							//measure size
				if (OverlapSize< 0.5*a_NucAllList[i]){					//if overlap is smaller than half of the nucleus's whole size
					roiManager("delete");								//delete the temp overlap ROI
					t_NucAllList[i]=false;								//save test result					
				}
				else{
					roiManager("delete");								
					t_NucAllList[i]=true;				
					print(">>>> Nucelus found.");
				}
			}

		}
	}
	else{
		i_NucAllList=newArray(roiManager("index"),0);
		i_NucAllList=Array.deleteIndex(i_NucAllList, 1);
		t_NucAllList=newArray(i_NucAllList.length);
		testArea=getValue("Area");
		roiManager("Select",newArray(i_IBA,roiManager("count")-1));	//select the IBA mask and one of the nucleus
		roiManager("AND");										//AND operation to find overlap
			if (selectionType()==-1){
				t_NucAllList[0]=(false);
			}
			else{
				roiManager("Add");										//add to ROIM
				RoiManager.select(roiManager("count")-1); 				//select the newly added overlap ROI
				OverlapSize=getValue("Area");							//measure size
				if (OverlapSize< 0.5*testArea){					//if overlap is smaller than half of the nucleus's whole size
					roiManager("delete");								//delete the temp overlap ROI
					t_NucAllList[0]=(false);
				}
				else{
					roiManager("delete");								//delete the temp overlap ROI
					print(">>>> Nucleus found.");
					RoiManager.select(i_NucAllList[0]);
					t_NucAllList[0]=true;	
				}
			}
		}
	newImage("selectedNuc", "8-bit black", xSize,ySize,1);		//prepare a new blank image of the same size
	for(i=0;i<i_NucAllList.length;i++){
		if (t_NucAllList[i]==true){			//if this nuc passed the test

		roiManager("Select",i_NucAllList[i]); //select it by its index #
		roiManager("fill");					//draw it on the new mask image
		}
	}
	selectImage("selectedNuc");
	if (getValue("Mean")==0) {print(">> WARNING:No microglial nucleus detected. Skipping "+title+".");} //nuc checkpoint
	else{
	run("Keep Largest Region");			
	run("Create Selection");
	roiManager("Add");										//add to ROIM
	save(output+File.separator+"nucMask_"+title);			//save at output
	RoiManager.select(roiManager("count")-1); 		//get index of the selected nucleus
	roiManager("rename", "Nuc");
	for(i=i_IBA+1; i<RoiManager.getIndex("Nuc"); i++){						
		RoiManager.delete(i);
		}
	close("selectedNuc");
	//selectImage("selectedNuc-largest");
print(">>>> Nuclei mask saved at output path. (Done)");

print(">> Segmenting Cytoplasm");
	roiManager("Select",newArray(i_IBA,RoiManager.getIndex("Nuc")));	//select the IBA mask and the nuc
	newImage("IBA", "8-bit black", xSize,ySize,1);		//prepare a new blank image of the same size
	RoiManager.select(i_IBA);
	roiManager("fill");
	run("Image Calculator...", "image1=IBA operation=Subtract image2=selectedNuc-largest create");
	run("Create Selection");
	
	if (selectionType()==-1){print(">> WARNING:No cytoplasm detected. Skipping "+title+".");} //cyt checkpoint
	else{
		roiManager("Add");
		RoiManager.select(roiManager("count")-1);
		i_Cyt=roiManager("index");
		close("*IBA");
print("\\Update:>> Segmenting Cytoplasm (Done)");
		

print(">> Measuring.");
	selectImage("C2-"+title);
	RoiManager.select(RoiManager.getIndex("Nuc"));
	GMean[0]=getValue("Mean");
	Area[0]=getValue("Area");
	RoiManager.select(i_Cyt);
	GMean[1]=getValue("Mean");
	Area[1]=getValue("Area");
	Ratio=GMean[1]/GMean[0];


	selectImage("C3-"+title);
	RoiManager.select(RoiManager.getIndex("Nuc"));
	YMean[0]=getValue("Mean");
	YSD[0]=getValue("StdDev");
	RoiManager.select(i_Cyt);
	YMean[1]=getValue("Mean");
	YSD[1]=getValue("StdDev");
print("\\Update:>> Measuring. (Done)");

print(">> Writing Results.");
	setResult("Case",nResults, FileName[1]);
	setResult("Group",nResults-1,FileName[0]);
	setResult("CRM_N", nResults-1, GMean[0]);
	setResult("CRM_C", nResults-1, GMean[1]);
	setResult("CRM_ratio", nResults-1, Ratio);
	setResult("IBA_N", nResults-1, YMean[0]);
	setResult("IBA_C", nResults-1, YMean[1]);
	setResult("Area_N", nResults-1, Area[0]/9.4673);
	setResult("Area_C", nResults-1, Area[1]/9.4673);  //convert px to um
	updateResults();
print("\\Update:>> Writing Results. (Done)");
	}
	}

close("*");
roiManager("deselect");
roiManager("delete");
print("");
}
