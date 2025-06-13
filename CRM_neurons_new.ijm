//measures CRM (ch2) intensity in neuron nucleus and immediate cytoplasm.
//takes a folder of segmented neuron tiffs as input, outputs spreadsheet.

inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("downloads");


// Get a list of all TIFF files in the directory
list = getFileList(inputDir);
pathSize=lengthOf(inputDir)

//get case name from folder name
for (i =pathSize; i>0; i--) {
	teststr=substring(inputDir, i-1);
	if (matches(teststr, "(\\\\.*\\\\)")) {
		i1=i;
		break;
	}
}
caseName=substring(inputDir,i1,pathSize-1);

// Process each TIFF file in the directory
for (i = 0; i < list.length; i++) {if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")){
	open(inputDir + list[i]);

	numImages = nImages;
	if (numImages == 0) {
	    exit("No images are open.");
	}
	
	//single out dapi and crm channel
	run("Make Subset...", "channels=1,2");
	title =getTitle();
	
	
	selectImage(title);
	run("Split Channels");
	selectImage("C1-"+title);
	 //dapi
	resetMinAndMax;
	
	run("Enhance Contrast", "saturated=5");
	//waitForUser;
	//setMinAndMax(800, 2500);
	run("Gaussian Blur...", "sigma=2");
	//-------------debug breakpoint if can't get good nuc ROI-------------
	setAutoThreshold("Huang dark no-reset");
	run("Convert to Mask");
	//run("Fill Holes");
	//run("Keep Largest Region");
	setTool("wand");
	run("Tile");
	waitForUser("Please use the Wand tool select the nucleus you want.\n If there is none, click ok to skip this image.");
	//skipps image if nothing is selected
	if (selectionType==-1) {
		print("Skipped "+title+"."); 
		close("*");
	}
	//process the selection
	else{
		roiManager("Add");
		
		//measure CRM intensity at nucleus
		run("Set Measurements...", "area mean display"	);
		selectImage("C2-"+title);
		roiManager("select", 0);
		run("Measure");
		setResult("Label",0,"Nuc "+i+1);
		updateResults();
		//measure CRM intensity at immediate cyt surrounding nucleus (for the lack of better ways to define nucleus
		run("Make Band...", "band=1.5");
		run("Measure");
		setResult("Label",1,"Cyt "+i+1);
		updateResults();
		//add in data line about crm manual classification 
		if(matches(title,".*\\+.*")){
			setResult("Nuc CRM type",2, true);
			setResult("Label",2,"Cell "+i+1+" Class");
		}
		else{
			setResult("Nuc CRM type", 2,false);
			setResult("Label",2,"Cell "+i+1+" Class");
		}
		updateResults();
		//write each case into its own sheet in the same xlsx file.
		run("Read and Write Excel", "dataset_label="+caseName+" file=["+outputDir+"/CRM results.xlsx] no_count_column stack_results sheet=["+caseName+"]");
		//return environment to initial state for the next iteration
		run("Clear Results");
		close("*");
		roiManager("deselect");
		roiManager("delete");
		print("Processed "+i+1+"/"+list.length+" images.");
	}
}}


print("Complete. All results are saved in Downloads/CRM results.xlsx.");