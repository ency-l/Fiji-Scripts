Updated: 2025-8-29

>This repository is a remote version of `Drive 8\Alex\4_IJ Macros`. Copies of scripts in other places are not maintained and are likley dated.

# File list
## Groovy Scripts for QuPath

*Still haven't made peace with Groovy's grammar yet. These are just some basic stuff.*
- **saveRegions**

Export all annotations to .tiffs for downstream analysis.

- **annotatedInfo**

Prints in terminal the number of annotation in each image in the project. I made this as a quick way to check which image has been annotated.

- **annotatedInfo_count**

Does everything annotatedInfo does, but also count annotations that belongs to two classes of one's choice. (can be more, but only 2 was needed when this was initially made) Export the number of annotations belonging to each class in each image to a csv file. 

## General Purpose Tools

- **Folder_Split_ScaleBar_customizable**

General use tool that processes a whole folder of the same type of images. Allow user to choose between brightfield (only adds scalebar) and fluorescent multichannel (splits channel and adds scalebar to a composite image) and customize scalebar features.

- **Single_Split_ScaleBar_customizable**

The same thing as the one above but only executes on one file. Good for testing what you want before processing the batch.

- **saveAllOpenImgs**

Self explanatory. Save everything that's open to a specified folder with the current window titles, then close all open images. (Good for selecting ROIs in QuPath, then sending them all to IJ and running this to save them.)

- **folderSplitChannel**

Splits all multichannel tiffs in a folder and save them to another folder. Intended for preparing single channel images for downstream analysis.


- **saveSelectedRegions.groovy**

Groovy script to export ROI annotations in Qupath. It will save all *selected* annotations as tiffs in `PROJECT_BASE_DIR/Export`. Original annoation borders are preserved as overlay.

- **generalPurposeAllOpenFiles_template**

A template for creating more scripts that apply a set of actions to all open images.

## Axonal TDP-43 Project
- **AxonalTDP_single_full** 

For measuring TDP-43 in white matter tracts in spinal cord. Takes green(c2) TDP and red (c3) NFH. This script looks for a round NHF+ area that is representative of a crossected axon. Current analyze particles parameters are set to 1-200 px; 0.5-1 cir. Measures area and mean.

## Ataxin-2 Project
- **Ataxin2Intensity**

For measuring intensity of Ataxin-2 and related proteins of interest in neurons. PABP1 and TDP-43 agg co-loc analysis will be added in the future.

## S1R Project
- **S1R_cellArea_SSCCountArea** 

Analyzes the S1R channel. For measuring 1) cell area and 2)individual SSC count/area/mean in each cell. Outputs an annotated merged image of the detected cell border/SSC borders for manual review and a csv of all measurements. Works most of the time but there are about 10% of cases where the segmentation fails, esp SSCs.

## SOD Microglia Exportin/Nuc Pore Complex Project (Gulshan) 


- **NPCMeasurementNormalized**

Takes folder input. Measures the intensity of c3 at nuclear envelope (defined as a 1px line along the nucleus) and inside the nucleus (for normalization.) Currently needs to manually select desired ROI after segmenting. Output data to a spreadsheet at a path of choice.  


- **CRM_neurons_new**

Takes folder input and output measurements to an .xslx in downloads folder (designed for multiple folders that belongs to the same dataset, fixed output to avoid having to specify output every time a diff folder is processed.) Needs manual selection of target cell nucleus after auto thresholding, then measures CRM (XPO-1) intensity at the nucleus and cytoplasm (defined by the 1.5px "doughnut" around the nucleus, for the lack of better ways to reliably define cytoplasm.) Data is saved to account for the special file naming scheme in generation of the source tiff images. It also adds the cell CRM type classification (which was stored in the tiff file name) into measurement results for ease of organization. Each case (input folder) is saved as a separate sheet in the same xslx file.

- **CRM_MicroGlia_new**

The microglia version of the script above. Fully automated. Nucleus is segmented and those with bad IBA1 overlap (<50%) is removed, then only the largest object is kept (remove random nuc fragments that might got included on the edge). Measures CRM intensity at nucelus and cytoplasm (created by subtracting nucleus region from full IBA1 ROI.) Improved log function compared to the neuron version.

# Archived
*These scripts are either 1) not working as intended or 2) have better alternatives in the list above. They are included here purely for documentation purposes.*

- **MicroGliaXPO** `(obsolete)`

Replaced by CRM_MicroGlia_new

 For a given input folder, detects all nuclei that have overlap with microglia marker IBA1, segment these regions and measure the XPO (c2, green) intensity in these regions. Export measurements to an excel sheet at a specified output folder. Measurement from diff files will be saved as adjacent columns in the same spreadsheet. Also saves a binary tiff of the region being measured from each input file in the output folder.

- **CRMnuc** `(obsolete)`

Replaced by CRM_neurons_new

Measures the intensity of C2 in the nucleus and the cytoplasm area immediately surrounding it. The later is measured for calculating N/C fraction. Currently this only works with one image open.

- **BFscalebar50_allOpenFiles** `(obsolete)`

Adds a horizontol 50 μm 20 px black scale bar with 30pt text to the bottom right of each image and flatten it, then closes the orignal images.

- **BFscalebar50_notext_allOpenFiles** `(obsolete)`

Same but doesn't have text.

- **BFscalebar50_single** `(obsolete)`

Only processes the currently selected image. Use this if the allOpenFiles versions are buggy.

- **BFscalebar100** `(obsolete)`

The 100μm version of BFscalebar50. Note that this also only processes the currently selected image.

 - **scalebar100split**  `(obsolete)`

Scale bar script for multichannel images. Split the channels and add a white 100μm scale bar (20px, bottom right, 30px text) to the composite RGB image. This script is intended for creating images for <ins>presentation</ins>, NOT analysis. What this means is that it changes individual channel files to RGB color mode. Currently needs to manually save the files after they are created.

- **removeholes** and **removeholes_manual** `(broken)`

Was an attempt at a quick way to segment the area containing tissue vs background using QuPath' IJ script runner. Couldn't find a way to process the image so that the foreground can be consistently and correctly detected when the beginning signal levels vary. Tried circumventing this issue by prompting manual thresholding from user ("manual") but it keeps breaking in QP's IJ instance for some reason.