#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
setBatchMode("hide");

function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		else
			processFile(input,output, list[i]);
		}
}
function writeResults(caseName){
	if (nResults>0){	//don't run this on first loop (there are no results to compare to)
	print(">> Checking case names.");
	prevCase=getResultString("Case",nResults-1);
	if(caseName!=prevCase){ //if the case name of current file is different from the last file processed:	
		run("Read and Write Excel","file=["+output+"/Results.xlsx] sheet="+prevCase+" dataset_label="+prevCase);   //write all existing results into excel under the sheet named after the case.
		Table.deleteRows(0,nResults-1); //clear results.
		print("\\Update:>> Checking case names...Found new case number. Saving previous case("+prevCase+").");
	}
}
}
function processFile(input,output,file){
	run("Set Measurements...", "display redirect=None decimal=3");
	fileName=split(input, "/|\\");
	caseName=substring(fileName[5],0,indexOf(fileName[5], "_"));
	cellName=substring(file,0,indexOf(file,"_"));
	
	writeResults(caseName);
	area_n=0;
	circularity=0;
	print("Begin processing Case "+caseName+", cell "+cellName+". ("+i+1+"/"+list.length+")");
	open(input+File.separator+file);
	roiManager("Add");//[0]
	roiManager("select", 0);
	roiManager("rename", "outline");
	area_o=getValue("Area");	//outline area
	roiManager("select", 0);
	run("Clear Outside");
    getDimensions(width, height, channels, slices, frames);
    if (slices>1){
    	print(">> Z-stack detected. Extracting z=2.");
   		run("Make Subset...", "channels=1-4 slices=3");	
   	}
	rename("cell");
	title=getTitle();
	run("Split Channels");
	
	print(">> Trying to segment nucleus");
	//dapi
	selectImage("C1-"+title);
	roiManager("select", 0);
	run("Gaussian Blur...", "sigma=2");
	roiManager("select", 0);
	setAutoThreshold("Otsu dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	selectImage("C1-"+title);
	nucFileName=caseName+"_"+cellName+"_nuc";
	
	getStatistics(area, mean);

	if(mean!=0){
		print("\\Update:>> Trying to segment nucleus...evaluating.");
		run("Keep Largest Region");
		run("Create Selection");
		roiManager("Add");//[1]
		roiManager("Select", 1);
		area_n=getValue("Area");
		circularity=getValue("Circ.");
		
		if (circularity>0.4 && (area_n/area_o)<0.5){	//only accept nuc with circ>0.4. Otherwise throw away the nuc ROI and treat as a cell without nuc.
			print("\\Update:>> Trying to segment nucleus...success!");
			roiManager("rename", "nuc");
			roiManager("Select", newArray(0,1));
			roiManager("XOR");	
			roiManager("Add");//[2]
			roiManager("Select", 2);
			roiManager("rename", "cyt");
			save(output+File.separator+nucFileName);
		}
		else{
			roiManager("delete");
			print("\\Update:>> Trying to segment nucleus...failed.");
		}

	}
	else{print("\\Update:>> Trying to segment nucleus...failed.");}

	//ataxin2
	print(">> Measuring channel of interest.");
	selectImage("C3-"+title);
	NucStat=false;
	NucBG=0;
	if(roiManager("count")>1){	//if a nuc/cyt ROI was annotated
		roiManager("Select",1);
		NucBG=getValue("Mean");
		roiManager("Select", 2);	//use cyt ROI
		NucStat=true;
	}
	else{	
		roiManager("Select", 0);	//use the cell outline ROI
	}
	mean=getValue("Mean");
	area_c=getValue("Area");
	
	print(">> Generating results.");
	setResult("Case",nResults,caseName);
	setResult("Cell",nResults-1,cellName);
	setResult("Nuc Flag",nResults-1,NucStat);
	setResult("Nuc Circ",nResults-1,circularity);
	setResult("Nuc Area",nResults-1,area_n);
	setResult("Cell Area",nResults-1,area_o);
	setResult("Cyt Area",nResults-1,area_c);
	setResult("Mean_ATXN2",nResults-1,mean);
	setResult("Mean_Nuc_ATXN2",nResults-1,NucBG);
	updateResults();
	print(">> All done! Resetting environment.");
	roiManager("deselect");
	roiManager("delete");
	close("*");
}
print("\\Clear");
processFolder(input)
writeResults("Wa");