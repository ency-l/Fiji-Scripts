// ImageJ Macro: Apply operation to All Open Images

// Get the number of open images
numImages = nImages;
if (numImages == 0) {
    exit("No images are open.");
}

// Loop through each open image and apply run() function
for (i = 1; i <= numImages; i++) {
    selectImage(i);
// Sub out the run(...) line for different commands!
    run("Subtract Background...", "rolling=50");
    run("Measure");
    close("*");
}
close("*");
print("OwO How did i do");
