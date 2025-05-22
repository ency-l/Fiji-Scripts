Updated: 2025-05-21

> Only this repo and the contents of <ins>Drive 8\Alex\4_IJ Macros</ins> are maintained. Copies of scripts in other places might be dated.

## File list

1. **AxonalTDP_single_full** 

For measuring TDP-43 in white matter tracts in spinal cord. Takes green(c2) TDP and red (c3) NFH. This script looks for a round NHF+ area that is representative of a crossected axon. Current analyze particles parameters are set to 1-200 px; 0.5-1 cir. Measures area and mean.

2. **BFscalebar50_allOpenFiles**

Adds a horizontol 50 μm 20 px black scale bar with 30pt text to the bottom right of each image and flatten it, then closes the orignal images.


3. **BFscalebar50_notext_allOpenFiles**

Same but doesn't have text.

4. **BFscalebar50_single**

Only processes the currently selected image. Use this if the allOpenFiles versions are buggy.

5. **BFscalebar100**

The 100μm version of BFscalebar50. Note that this also only processes the currently selected image.

> *TODO: Make an "all open files" and "specific folder" version of this*

6. **CRMnuc**

Measures the intensity of C2 in the nucleus and the cytoplasm area immediately surrounding it. The later is measured for calculating N/C fraction. Currently this only works with one image open.

> *TODO: Change input method to folder*

7. **FolderSplitandSave**

Takes folder of multichannel images, split them and save them to a different folder. This one currently has a bug where the last file in a folder won't be processed.

> *TODO: fix the bug where one file will not get processed*

8. **generalPurposeAllOpenFiles_template**

A template for creating more scripts that apply a set of actions to all open images.

9. **NPCMeasurementNormalized**

Only works when only 1 image is open. Measures the intensity of c3 at nuclear envelope (defined as a 5px line along the nucleus) and inside the nucleus (for normalization.) Currently needs to manually select desired ROI after segmenting.

> *TODO: Change input method to folder; automate ROI selection*

10. **saveAllOpenImags**

Self explanatory. Save everything that's open to a specified folder with the current window titles.

11. **scalebar100split** 

Scale bar script for multichannel images. Split the channels and add a white 100μm scale bar (20px, bottom right, 30px text) to the composite RGB image. This script is intended for creating images for <ins>presentation</ins>, NOT analysis. What this means is that it changes individual channel files to RGB color mode. Currently needs to manually save the files after they are created.

> *TODO: Automate saving and closing temp files created during processing.*

12. **MicroGliaXPO**

The most polished one so far (lol). For a given input folder, detects all nuclei that have overlap with microglia marker IBA1, segment these regions and measure the XPO (c2, green) intensity in these regions. Export measurements to an excel sheet at a specified output folder. Measurement from diff files will be saved as adjacent columns in the same spreadsheet. Also saves a binary tiff of the region being measured from each input file in the output folder.

## TODO

Organize them by general utility and specific projects.
