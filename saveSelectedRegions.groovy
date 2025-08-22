//Save tiffs of selected annotations in project folder/Exported With image and class name. Original annotation border is saved in overlay.
import qupath.imagej.gui.*
import ij.*

def server = getCurrentServer()
//def name = GeneralTools.getNameWithoutExtension(getProjectEntry().getImageName())
def name = GeneralTools.stripExtension(getProjectEntry().getImageName())
int count = 0
for (pathObject in getSelectedObjects()) {
    count++
    def request = RegionRequest.createInstance(server.getPath(), 1, pathObject.getROI())
    def imp = IJExtension.extractROI(server, pathObject, request, true).getImage()
    createDirectoryInProject("Export")
   // def path= makeFileInProject("Export",  "${name}_${pathObject.getClassification()}_${count}.tif");
    def path = buildFilePath(PROJECT_BASE_DIR,"Export", "${name}_${pathObject.getClassification()}_${count}.tif")

    IJ.save(imp, path)
}