// ImageJ Macro: Save all open images as TIFF files with numbering
// Prompt user to select a folder for saving
saveDir = getDirectory("Choose a folder to save TIFF files");

// Get the list of all open image windows
numImages = nImages;
if (numImages == 0) {
    exit("No images are open.");
}

// Loop through each open image and save it as a numbered TIFF
for (i = 1; i <= numImages; i++) {
    selectImage(i);
    title = getTitle();
    saveAs("Tiff", saveDir + i + "_" + title + ".tif");
}

print("All open images saved as TIFF in: " + saveDir);
