def project = getProject()
count=0
list=project.getImageList()
for (entry in list) {

    def hierarchy = entry.readHierarchy()
    def annotations = hierarchy.getAnnotationObjects()
    if (annotations.size()>0) {
        count++
    }
    print entry.getImageName() + '\t' + annotations.size()
}
print "Number of images with annoations: "+count+"/"+list.size()