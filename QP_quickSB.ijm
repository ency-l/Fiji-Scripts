//
//-------------Change this!----------
size=50;        //unit is micron
color="White" //Make sure you capitalize
text=false;    //change this to "true" if you want text
saveFolder="";    //put in the path to folder you want to save it in. If there are backslashes("\"), please change them into double-backslash ("\\").

// If saveFolder is left blank, will save in the default user directory.     
//----------------------------------
//
//
//
//
//
if (saveFolder==""){saveFolder=getDirectory("home");}
replace(saveFolder,"\\","/");

title=getTitle();

if (text==false){
	hide_par="hide";
}
else{
	hide_par="";
}
run("Scale Bar...", "width="+size+" color="+color+" horizontal bold "+hide_par+" overlay");
run("Flatten");
saveAs("Tiff", saveFolder+File.separator+title+"_SB"+size);
