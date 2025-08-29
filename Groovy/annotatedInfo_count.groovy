//export the counts of objects in two classes in each image to a csv

def project = getProject()
count=0
list=project.getImageList()
def data=[["ImageName","PositiveCells","NegativeCells"]];
for (entry in list) {

    def hierarchy = entry.readHierarchy()
    def annotations = hierarchy.getAnnotationObjects()
    def class1=getPathClass("positive")    //change to desired classes
    def class2=getPathClass ("negative")   //change to desired classes
    if (annotations.size()>0) {
        count++
    }
    def num_c1=annotations.findAll{it.getPathClass()==class1}.size()
    def num_c2=annotations.findAll{it.getPathClass()==class2}.size()
    data<<[entry.getImageName(),num_c1,num_c2]
    print entry.getImageName() + '\t' + annotations.size()+'\t'+num_c1+'\t'+num_c2
}
//def csvFile = new File("E:/Alex/5_Misc_small_projs/Isabel Unc13a/Export.csv")
def csvFile = buildFilePath(PROJECT_BASE_DIR, "Export.tif")

csvFile.withWriter('UTF-8') { writer ->data.each { row ->writer.writeLine(row.join(","))}}
print "Number of images with annoations: "+count+"/"+list.size()