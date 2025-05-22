// ImageJ Macro: Makes a copy with 100um white scalebar and splits all channels. Both the scalebar-ed image and indiv. channels are ready to be saved for presentation (this is not designed to generate images for further analysis!)
//Will operate on all open stack images. Does not work well with RGB images.
//The original file is preserved as all operations are done on duplicates.
showMessageWithCancel("Please make sure all channels have been adjusted for export display. This script outputs RGB format files and overwrites original intensities. Click OK to proceed or cancel to stop the script.");
// Get the number of open images
numImages = nImages;
if (numImages == 0) {
    exit("No images are open.");
}

// Loop through each open image and apply processing
for (i = numImages; i >= 1; i--) {
    selectImage(i);
    originalTitle = getTitle();
    
    // First duplicate - Add scale bar and flatten
    run("Duplicate...", "duplicate");
    selectImage(getTitle());
    run("Scale Bar...", "width=100 height=20 thickness=20 font=30 bold overlay");
    run("Flatten");
    
    // Second duplicate - Split channels and set color profile to RGB
    selectImage(i); // Go back to original
    run("Duplicate...","duplicate");
    selectImage(getTitle());
    run("Split Channels");
    for (c = 2; c <= nImages; c++) {
            selectImage(c);
            run("RGB Color");
    }
    
}
run("Tile"); //display all files in tile format for easy review
print("Complete! When there are multiple stacks being processed, this script sometimes makes extra copies of composite RGB images without a scale bar. Simply close the files you don't need.");
