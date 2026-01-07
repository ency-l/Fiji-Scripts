/*
 * Macro template to process multiple open images
 */

//#@ File(label = "Output directory", style = "directory") output
#@ String(label = "Title contains") pattern

processOpenImages();

/*
 * Processes all open images. If an image matches the provided title
 * pattern, processImage() is executed.
 */
function processOpenImages() {
	n = nImages;
	setBatchMode(true);
	for (i=1; i<=n; i++) {
		selectImage(i);
		imageTitle = getTitle();
		imageId = getImageID();
		if (matches(imageTitle, "(.*)"+pattern+"(.*)"))
			processImage(imageTitle, imageId);
	}
	setBatchMode(false);
}

/*
 * Processes the currently active image. Use imageId parameter
 * to re-select the input image during processing.
 */
function processImage(imageTitle, imageId) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + imageTitle);

	//run("Duplicate...", "duplicate");
	run("Arrange Channels...", "new=12");

	newtitle=substring(imageTitle,indexOf(imageTitle,"z"));
	Stack.setChannel(1);
	setMinAndMax(300,8000);
	Stack.setChannel(2);
	setMinAndMax(100,10000);
	run("Green");
	//run("Channels Tool...");
	//Property.set("CompositeProjection", "null");
	saveAs("PNG", "E:/Alex/7_Oligo/export/"+newtitle);
	Stack.setDisplayMode("color");
	Stack.setChannel(1);
	saveAs("PNG", "E:/Alex/7_Oligo/export/"+newtitle+"-c1");
	Stack.setChannel(2);
	saveAs("PNG", "E:/Alex/7_Oligo/export/"+newtitle+"-c4");
	//run("Channels Tool...");

}
