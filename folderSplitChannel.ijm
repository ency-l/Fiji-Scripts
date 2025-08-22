// Take a folder with multichannel tiff files as input, split them by channel and save in another folder. 
// This is intended for downstream analysis, not generating presentation images.

inputDir = getDirectory("Choose a folder containing TIFF files");
saveDir = getDirectory("Choose a folder to save split TIFF files");
list = getFileList(inputDir);
setBatchMode("hide");

if (list.length == 0) {
    exit("Input folder is empty.");
}

// Loop through each open image and apply run() function
for (i = 0; i < list.length; i++) {if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {

	open(inputDir + list[i]);
    getDimensions(width, height, channels, slices, frames);
    run("Remove Overlay");
	if(slices>1){
	    run("Make Subset...", "channels=1-"channels+" slices=3");	//Choose the desired z if there a z stack.
	}
    title=getTitle();
    run("Split Channels");
	for (c = 1; c <=channels; c++) {
		selectImage("C"+c+"-"+title);
		splitTitle=getTitle();
		resetMinAndMax;
		saveAs("tiff",saveDir+splitTitle);
	}
	close("*");
	print("Processed"+i+1+"/"+list.length+" files.");

}}
close("*");
print("Processing completed. All files saved in: " + outputDir);
