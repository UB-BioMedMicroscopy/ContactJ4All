
/*
Advanced Optical Microscopy Unit
Scientific and Technological Centers. Clinic Medicine Campus
UNIVERSITY OF BARCELONA
C/ Casanova 143
Barcelona 08036 
Tel: 34 934037159

------------------------------------------------
Gemma Martin (gemmamartin@ub.edu) , Maria Calvo (mariacalvo@ub.edu)
------------------------------------------------

Name of Macro: ContactJ4all.ijm


Date: 21 des 2021

Objective: Analyse contacts between fluorescently labelled images

Input: two confocal images

Output: A resulting image with the contacts together with the two channels, the contact mask and ROIs of the contacts

Version: 1.7

Requirements: 
- Colocalization Plugin (Pierre Bourdoncle, Institut Jacques Monod, Service Imagerie, Paris) https://imagej.nih.gov/ij/plugins/colocalization.html. 
- Advanced Weka Segmentation PMID 28369169, doi:10.1093/bioinformatics/btx180

*/


//Close previous images and results
if (nImages>2) {

	if(isOpen("Results")){
	    IJ.deleteRows(0, nResults);
	}
	run("ROI Manager...");
	roiManager("reset"); //to delete previous ROIs
	IJ.deleteRows(0, nResults);
	
	
	//set measurement options
	run("Set Measurements...", "area mean min shape integrated display redirect=None decimal=5");
	
	run("Options...", "iterations=1 count=1 do=Nothing");
	
	
	////////////////////////////////////// UI CONTACTJ ////////////////////////////////////////////////////////////
	
	  ratio=50;
	
	  threshold1 = newArray("Default dark", "Huang dark", "Intermodes dark", "IsoData dark", "Li dark", "MaxEntropy dark", "Mean dark", "MinError dark", "Minimum dark", "Moments dark", "Otsu dark", "Percentile dark", "RenyiEntropy dark", "Shanbhag dark", "Triangle dark", "Yen dark");
	  threshold2 = newArray("Default dark", "Huang dark", "Intermodes dark", "IsoData dark", "Li dark", "MaxEntropy dark", "Mean dark", "MinError dark", "Minimum dark", "Moments dark", "Otsu dark", "Percentile dark", "RenyiEntropy dark", "Shanbhag dark", "Triangle dark", "Yen dark");
	
	  Dialog.create("ContactJ4All");
	
	  Dialog.addMessage("\n Organelle 1\n ");
	  Dialog.addImageChoice("Image Organell 1");
	  Dialog.addChoice("Threshold organelle 1:", threshold2);
	
	  Dialog.addMessage("\n Organelle 2\n ");
	  Dialog.addImageChoice("Image Organell ");
	  Dialog.addChoice("Threshold organelle 2:", threshold2);
	 
	  Dialog.addMessage("\n");
	  Dialog.addNumber("Ratio colocalization (0-100):", ratio);
	
	  Dialog.addMessage("\n");
	
	  Dialog.addHelp("https://github.com/UB-BioMedMicroscopy/ContactJ/tree/1.0")
	  
	  Dialog.show();
	
	  titleorg1=Dialog.getImageChoice();
	  threshold1 = Dialog.getChoice();
	
	  titleorg2=Dialog.getImageChoice();
	  threshold2 = Dialog.getChoice();
	  
	  ratio = Dialog.getNumber();
	
	  
	  selectWindow(titleorg1);
	  org1=getImageID();
	  selectWindow(titleorg2);
	  org2=getImageID();
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	
				
	//********************************************************************************************************************
	// ******************************** Colocalization Mitochondria Lipid Droplets ***************************************
	//********************************************************************************************************************
	
	//get values of autothreshold for green channel (Yen dark)
	selectImage(org1);
	depth=bitDepth();
	getDimensions(width, height, channels, slices, frames);
	
	run("Set Measurements...", "mean display redirect=None decimal=5");
	meanmax=0;
	slicemax=1;
	for (i = 1; i <= slices; i++) {
		setSlice(i);
		print(i);
		run("Measure");
		mean=getResult("Mean", i-1);
		if(mean>meanmax){
			slicemax=i;
			meanmax=mean;
		}
	}
	
	
	
	
	setSlice(slicemax);
	setAutoThreshold(threshold1);
	getThreshold(thresholdorg1,thresholdorg12);
	resetThreshold();
	
	//get values of autothreshold for red channel (Otsu dark)		
	selectImage(org2);
	
	IJ.deleteRows(0, nResults);
	
	meanmax=0;
	slicemax=1;
	for (i = 1; i <= slices; i++) {
		setSlice(i);
		print(i);
		run("Measure");
		mean=getResult("Mean", i-1);
		if(mean>meanmax){
			slicemax=i;
			meanmax=mean;
		}
	}
	
	setSlice(slicemax);
	
	setAutoThreshold(threshold2);
	getThreshold(thresholdorg2,thresholdorg22);
	resetThreshold();
				
	//colocalization using previous autothresholds
			
	coloc_contactj(org2, org1, thresholdorg2,thresholdorg22,thresholdorg1,thresholdorg12,ratio);
				
	//using the colocalized image of colocalization highlighter and combining it with skeletonize, the colocalized perimeter is obtained. 
				
	selectWindow("Colocalized_Points");
	
	//************************************** Skeletonize **********************************************************
	
	//Skeletonization of the obtained mask
	run("Skeletonize", "stack");run("Skeletonize", "stack");
	
	//*************************************************************************************************************
	
	rename("ContactJ_Mask");
	
	
	
	//Create ROIs of contacts for each slice
	for (i = 1; i <= nSlices; i++) {
	    setSlice(i);
		run("Create Selection");
		if(selectionType()>-1){
	
			roiManager("Add");
		}
	}
	
	
	roiManager("Show All");
	roiManager("Show None");
	run("Grays");
	
	run(depth+"-bit");
	
	selectWindow(titleorg1);
	rename("c1");
	selectWindow(titleorg2);
	rename("c2");
	
	//Merge channels with contacts
	run("Merge Channels...", "c1=c1 c2=c2 c4=ContactJ_Mask create keep");
	rename("ContactJ_Result");
	
	Stack.setDimensions(3, slices, frames);
	
	//selectWindow("Composite");
	//close();
	
	selectWindow("c1");
	rename(titleorg1);
	selectWindow("c2");
	rename(titleorg2);
	
	
	
	
	roiManager("reset"); //to delete previous ROIs
	
}else{
	waitForUser("ContactJ4All", "Please, open the images before running the macro");
}

/// *********************** Colocalization function **************************************

function coloc_contactj(green, red, lr,ur,lg,ug,A){
	Stack.getDimensions(width, height, channels, slices, frames);
	if(frames>1){
		selectImage(red);
		run("Stack to Hyperstack...","channels=1 slices="+frames+" frames=1 display=Grayscale");
		run("Hyperstack to Stack");
		selectImage(green);
		run("Stack to Hyperstack...","channels=1 slices="+frames+" frames=1 display=Grayscale");
		run("Hyperstack to Stack");
		Stack.getDimensions(width, height, channels, slices, frames);
	}
	pixg=newArray(slices*width*height);
	pixr=newArray(slices*width*height);
	selectImage(green);
	f=1;
	for (i=0;i<slices;i++) {
		setSlice(i+1);
		for (x=0;x<width;x++) {
			for (y=0;y<height;y++) {
				pixg[f-1]=getPixel(x,y);
				showProgress(f/(width*height*slices)/3);
				f=f+1;
			}
		}
			
	}
	selectImage(red);
	f=1;			
	for (i=0;i<slices;i++) {
		setSlice(i+1);
		for (x=0;x<width;x++) {
			for (y=0;y<height;y++) {
				pixr[f-1]=getPixel(x,y);
				showProgress((f/(width*height*slices)/3)+1/3);
				f=f+1;
			}
		}
	}
	newImage("Colocalized_Points","32-bit black",width,height,slices);	
	f=1;
	for (i=0;i<slices;i++) {
		setSlice(i+1);
		for (x=0;x<width;x++) {
			for (y=0;y<height;y++) {
				if (pixg[f-1]>lg && pixr[f-1]>lr && pixg[f-1]/pixr[f-1]*100>A && pixr[f-1]/pixg[f-1]*100>A) {
					setPixel(x,y,1);
				}
				else {
					setPixel(x,y,0);
					}
				showProgress((f/(width*height*slices)/3)+2/3);
				f=f+1;
			}
		}	
	}

	
	run("8-bit");
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark calculate");
	
}
