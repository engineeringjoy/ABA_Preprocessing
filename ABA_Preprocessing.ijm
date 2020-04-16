/*
 *ABA_PreProcessing.ijm
 *JFRANCO
 *20200416
 *
 *The goal of this code is to preprocess buckling videos for further automated buckling analysis. 
 *The code requires user supervision to ensure quality control.
 *The original code was written for images acquired on the WormSense microscope Hermione, 
 *taken at 20x. Unknown frame rate and calibration. 
 */

/* BEFORE RUNNING THIS CODE FOR TESTING PURPOSES BE SURE OF A FEW THINGS:
 *  1. Locate the video named "CB1108xTU2769_1%Agarose100%cam_5_3_MMStack_Pos0.ome.tif"
 *  2. Make a directory called "AutomatedBucklingAnalysis" 
 *  3. Within that directory, make a subfolder called "RawVideos" and store the file named above in that folder.
 *  4. Again, within that main directory, make another subfolder called "ProcessedVideos."
*/

 //USER SPECIFIED PARAMETERS
 version = "v4"																								// <-- CHANGE MEEEE!!! If this is your first time running code use "v1"
 path = "/Users/joiedufranco/Google Drive/Research/Merlin/Data/AnalysisTools/";		  						// <-- CHANGE MEEEE!!! Update with your path to the ABA directory
 dir = "AutomatedBucklingAnalysis/";
 rawdir = "RawVideos/";
 savedir = "ProcessedVideos/";
 file = "CB1108xTU2769_1%Agarose100%cam_5_3_MMStack_Pos0.ome.tif"
 nfCropped = "ExV1_1_Cropped_" +version+ ".tif";
 nfSubstack = "ExV1_2_Substack_" +version+ ".tif";
 nfSubBack = "ExV1_3_SubtractBackground_" +version+ ".tif"
 nfABC = "ExV1_4_AjdBC_" +version+ ".tif";
 nfSmooth = "ExV1_5_Smooth_" +version+ "tif";
 nfThresh = "ExV1_6_Threshold_" +version+ ".tif";

//OPEN FILE
open(path+dir+rawdir+file)

//User first needs to crop the stack to just the region to analyze. This help reduce background noise
//that makes thresholding challenging. The box should be (1) made, (2) user flip through stack to ensure
//the box is in the right place, (3) adjusted as necessary
makeRectangle(0, 232, 317, 280);
makeRectangle(0, 193, 317, 280);
makeRectangle(0, 219, 350, 225);
makeRectangle(0, 203, 324, 208);
makeRectangle(0, 203, 352, 265);
run("Auto Crop");

//CROP STACK TO REGION OF INTEREST
//Save the cropped stack {we save a new stack after every processing step}
saveAs("Tiff", path+dir+savedir+nfCropped);

//MAKE A SUBSTACK OF FRAMES TO ANALYZE
//User will need to select substack to analyze, ensuring that all frames in the sequence are in focus.
//This also makes the stack easier to work with since it will be a smaller file size
run("Make Substack...", "  slices=41-182");
saveAs("Tiff", path+dir+savedir+nfSubstack );
selectWindow(nfCropped);						   														    //Close cropped file now that it's done being used
close();

//SUBTRACT BACKGROUND
run("Subtract Background...", "rolling=50 stack");
saveAs("Tiff", path+dir+savedir+nfSubBack);


//ADJUST BRIGHTNESS CONTRAST
//When this is done with the "auto" function it's the same as the "Enhance Constrast" feature
run("Enhance Contrast", "saturated=0.35");
run("Apply LUT", "stack");
saveAs("Tiff", path+dir+savedir+nfABC);

//APPLY SMOOTHING FILTER TO REDUCE NOISE
run("Smooth", "stack");
saveAs("Tiff", path+dir+savedir+nfSmooth);

//APPLY THRESHOLD
//This thresholding applies the "Otsu" method, which is different from what is in the video.
//Ask Joy to see Evernote on this topic if you're interested in how the method choice was made.
run("Threshold...");
setAutoThreshold("Otsu dark");
setOption("BlackBackground", false);
run("Convert to Mask", "method=Otsu background=Dark calculate");
saveAs("Tiff", nfThresh);
