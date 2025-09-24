/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.
setBatchMode("hide");
processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		//if(File.isDirectory(input + File.separator + list[i]))
			//processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input,output, list[i]); 	//add output to parameter if needed
	}
}

function processFile(input, output,file) {	//add output to parameter if needed
	open(input+File.separator+file);
///////////////////////////////////////////////////////////////////////////	
title=getTitle();
title_short=substring(title, 0,indexOf(title,"."));
run("Size...", "width=100 height=100 depth=3 constrain average interpolation=Bilinear");
  run("Scale Bar...", "width=5 height=10 thickness=2 bold hide overlay");
run("Flatten");
name=title_short+"_SB5.tif";
	saveAs("Tiff", output+File.separator+name);
	print("Processing: " + input + File.separator + name);
	//print("Saving to: " + output);
///////////////////////////////////////////////////////////////////////////	
	close("*");

}
