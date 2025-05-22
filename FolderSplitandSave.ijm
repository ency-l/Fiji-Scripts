// ImageJ Macro: Process and Split Multi-Channel TIFF Files
// Will operate an entire input folder and output to a given folder
// Prompt user to select the input directory
inputDir = getDirectory("Choose a folder containing TIFF files");
outputDir = getDirectory("Choose a folder to save processed TIFF files");

// Get a list of all TIFF files in the directory
list = getFileList(inputDir);

// Process each TIFF file in the directory
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff")) {
        open(inputDir + list[i]);
        title = getTitle();
        
        // Split Channels
        run("Split Channels");
        // Get and save each channel
        for (c = 1; c <= nImages; c++) {
            selectImage(c);
            resetMinAndMax;  // Reset Min and Max for each channel as IJ tends to mess it up upon opening an img
           // run("RGB Color");
            filename = getTitle();
			saveAs("Tiff", outputDir + filename);
            close();
        }
        
        // Close the original image
     //   selectWindow(title);
       // close();
    }
}

print("Processing completed. All files saved in: " + outputDir + "PLEASE CHECK FOR ANY OPEN IMAGES AND MANUALLY SAVE THEM BEFORE CLOSING!!!!");
