inputDir=getDir("select the images folder");
setBatchMode("hide");
filelist = getFileList(inputDir) 
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")||endsWith(filelist[i],".tiff")) { 
        open(inputDir + filelist[i]);
        imageName=getTitle();
        Roi.setPosition(1);
		roiManager("Add");
		run("Clear Outside");
        selectImage(imageName);
        save(".tif");
        
        roiManager("reset");
        close("*");
        print("processed "+i+"/"+lengthOf(filelist)+" images.");
        
        
    } 
}

