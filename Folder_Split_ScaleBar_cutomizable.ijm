// ImageJ Macro: Process and Split TIFF Files, has a brightfield and fluor (multi channel) mode.
// Will operate an entire input folder and output to a given folder
// Prompt user to select the input and output directory
inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("Choose a folder to save processed TIFF files");

// Get a list of all TIFF files in the directory
list = getFileList(inputDir);


//get channel and scalebar configs from user
colors=newArray("Black","White");
types=newArray("brightfield","fluorescent");
Dialog.create("Image type");
Dialog.addChoice("Image type", types);
Dialog.show();
Input_type=Dialog.getChoice();
//for IHC
if(Input_type=="brightfield")
{
Dialog.create("Brightfield Scalebar Settings");	
Dialog.addNumber("Scale bar size (um): ", 20);
Dialog.addNumber("Scale bar thickness (px): ", 10);
Dialog.addChoice("Scale bar color: ",colors,"Black");
Dialog.addCheckbox("Show scale bar size text?", true);
Dialog.addNumber("Text size: ", 20);
Dialog.show();
}	
	
//for IF	
else{
Dialog.create("Fluorescence Channel and Scalebar Settings");
Dialog.addMessage("Only support up to 4 channels. \n Leave empty if the channel doesn't exist.");
Dialog.addString("Channel 1 Name", "DAPI");
Dialog.addString("Channel 2 Name", "FITC");
Dialog.addString("Channel 3 Name", "TRITC");
Dialog.addString("Channel 4 Name", "Cy3");
Dialog.addNumber("Scale bar size (um): ", 20);
Dialog.addNumber("Scale bar thickness (px): ", 10);
Dialog.addChoice("Scale bar color: ",colors,"White");
Dialog.addCheckbox("Show scale bar size text?", true);
Dialog.addNumber("Text size: ", 20);
Dialog.show();
}

//store the inputs
SBsize=Dialog.getNumber();
SBthick=Dialog.getNumber();
SBTsize=Dialog.getNumber();
SBcolor=Dialog.getChoice();
SBtext=Dialog.getCheckbox();
if (Input_type=="fluorescent") {
	Ch1=Dialog.getString();
	Ch2=Dialog.getString();
	Ch3=Dialog.getString();
	Ch4=Dialog.getString();
	ChannelList=newArray(Ch1,Ch2,Ch3,Ch4);
}
//establish channel numbers
ChannelNo=0;
for (i = 0; i < 4; i++) {
	if (ChannelList[i]!="") {
	ChannelNo++;
	}
}
run("Close All");
//IHC processing
if(Input_type=="brightfield"){
	for (i = 0; i < list.length; i++) {
	    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
	        open(inputDir + list[i]);
	        title = getTitle();
	        if (SBtext==true) {run("Scale Bar...", "width=&SBsize height=0 thickness=&SBthick font=&SBTsize color=&SBcolor bold overlay");}
	  		else{run("Scale Bar...", "width=&SBsize height=0 thickness=&SBthick font=0 color=&SBcolor bold overlay");}
			run("Flatten");
	        filename = title+"_SB_"+SBsize;
			saveAs("Tiff", outputDir + filename);
			run("Close All");
	    }
	print("Processed "+i+1+"/"+list.length+" images.");
	}
}
//IF processing
else{
	for (i = 0; i < list.length; i++) {
	    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
	        open(inputDir + list[i]);
	        title = getTitle();
			run("Duplicate...", "title=sb duplicate");
			selectImage(title);
			// Split Channels
	        run("Split Channels");
	        
	        // Get and save each channel
	        for (c = 1; c <= nImages-1; c++) { 
	           selectImage(c+1);
	           //run("Enhance Contrast", "saturated=0.35"); 
	           resetMinAndMax;
	           run("RGB Color");
	           rename(ChannelList[c-1]+"_"+title);
	           Chfilename=getTitle();
			   saveAs("Tiff", outputDir + Chfilename);
	        }
	 
	        //make scalebar on composite image and save
	        selectImage("sb");
	         if (SBtext==true) {run("Scale Bar...", "width=&SBsize height=0 thickness=&SBthick font=&SBTsize color=&SBcolor bold overlay");}
	  		else{run("Scale Bar...", "width=&SBsize height=0 thickness=&SBthick font=0 color=&SBcolor bold overlay");}
			run("Flatten");
	        filename = title+"_SB_"+SBsize;
			saveAs("Tiff", outputDir + filename);
			run("Close All");
		}
	print("Processed "+i+1+"/"+list.length+" images.");
    }
}
print("Processing completed. All files saved in: " +outputDir);
