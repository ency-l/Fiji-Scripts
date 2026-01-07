// ImageJ Macro: Apply operation to All Open Images

// Get the number of open images
numImages = nImages;
if (numImages == 0) {
    exit("No images are open.");
}

// Loop through each open image and apply run() function
for (i = 1; i <= numImages; i++) {
    title=getTitle();
getDimensions(width, height, channels, slices, frames);
if(channels>1){
	
	selectImage(i);

/*    	Stack.setDisplayMode("color");
    call("ij.ImagePlus.setDefault16bitRange", 16);
	//run("Split Channels");
// Sub out the run(...) line for different commands!
for(c=1;c<=channels;c++){
Stack.setDisplayMode("composite");
	Stack.setChannel(c);
//	selectImage("C"+c+"-"+title);
  	run("RGB Color");
 	saveAs("png","E:/Alex/5_Misc_projs/Gitler_DAMNs/Export_edited/C"+c+"_"+title);
    close();*/
    run("Scale Bar...", "width=50 height=20 font=20 horizontal bold overlay");
    run("Flatten");
    saveAs("png","E:/Alex/5_Misc_projs/Gitler_DAMNs/Export_edited/SB50_"+title);

}



print("OwO How did i do");
