# ContactJ4All

## General Information

**Name of Macro:** ContactJ4All.ijm\
**Date:** 28 December 2021\
**Objective:** Analyse contacts between fluorescently labelled images.\
**Input:** two opened fluorescence images (i.e two channels). ContactJ4All can be used with 2D, 3D and time series and 8-bit,12-bit and 16-bit depth images.\
**Output:** A resulting image with the contacts together with the two channels, the contact mask and ROIs of the contacts.

**ImageJ Version:** 1.7

**Requirements:** 
- Advanced Weka Segmentation PMID 28369169, doi:10.1093/bioinformatics/btx180
- Colocalization Plugin (Pierre Bourdoncle, Institut Jacques Monod, Service Imagerie, Paris) https://imagej.nih.gov/ij/plugins/colocalization.html

Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

## Contact information

Gemma Martin (gemmamartin@ub.edu), Maria Calvo (mariacalvo@ub.edu)\
Advanced Optical Microscopy Unit \
Scientific and Technological Centers (CCiTUB). Clinic Medicine Campus \
UNIVERSITY OF BARCELONA \
C/ Casanova 143 \
Barcelona 08036 \
Tel: 34 934037159

## How to use ContactJ4All

ContactJ is macro script for the open-source image analysis software ImageJ. This macro find the contact site of the of the colocalized part of two fluorescence images.

1.	Open two fluorescence images (i.e. green and red channel of a confocal image). If needed, filter them. ContactJ4All can be used with 2D, 3D and time series and 8-bit,12-bit and 16-bit depth images. 
2.	Run the macro with ImageJ
3.	ContactJ GUI appears:\
![imagen](https://user-images.githubusercontent.com/46067312/147688322-a68fb6e9-68f4-4a22-907d-edcd08fd50a1.png)
 
4.	Choose the images, name of organelles, thresholds and ratio of colocalization. 
5.	Click OK.
6.	ContactJ4All shows the contact sites as output images and the ROI contact in ROI manager.



