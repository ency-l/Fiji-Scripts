import qupath.lib.projects.ProjectIO
import qupath.lib.projects.Projects

//Renames all image entries with regex.

def pattern = ~/\.vsi.*(\_\d)/    // Put match string between the two "/"s
def replacement = '$1'           // Put replacement between the two quotation marks.

def project = getProject()

for (entry in project.getImageList()) {
    def name = entry.getImageName()
    
    // Replace only matching substring(s)
    def newName = name.replaceAll(pattern, replacement)
    
    if (name != newName) {
        entry.setImageName(newName)
        print "Renamed: $name -> $newName"
    }
}
