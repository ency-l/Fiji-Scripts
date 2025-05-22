// 50um black scale bar, automated version that processes all open imgs.

// Get the number of open images
numImages = nImages;
if (numImages == 0) {
    exit("No images are open.");
}

// Loop through each open image and apply run() function
for (i = 1; i <= numImages; i++) {
    selectImage(i);
    title = getTitle();
    run("Scale Bar...", "width=50 height=0 thickness=20 font=0 color=Black bold overlay");
    run("Flatten");
    selectWindow(title);
    close();
}


