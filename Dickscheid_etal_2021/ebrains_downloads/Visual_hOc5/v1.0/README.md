# Cortical layers and cell segmentation for cortical patches of the BigBrain

This repository contains cortical image patches for different cytoarchitectonic regions, extracted from the original tissue sections of the Bigbrain model (Amunts et al., Science, 2013) at 1 micron resolution, together with manual annotations of cortical layers and automatic cell segmentations. It has been created by T. Dickscheid, S. Bludau, C. Paquola, C. Schiffer and E. Upschulte in the Institute of Neuroscience and Medicine (INM-1), Forschungszentrum Julich, Germany, headed by Prof. Katrin Amunts. 

The histological sections wer prepared as described in the BigBrain publication. Briefly, the brain was fixed in formalin, MR-imaged, embedded in paraffin, and serially cut with a microtome into 20µm thick sections. Every single section has been stained and digitized. Silver staining for cell bodies was performed using a modified Merker method (Merker, 1983), which is robust and gives a high contrast between cell bodies and neuropil. The final sections have been imaged using a light microscope (Huron Technologies, Inc.) at 1 micron in-plane resolution. 

The cell segmentations have been performed using the recently proposed Contour Proposal Networks (CPN; E. Upschulte et al.; https://arxiv.org/abs/2104.03393; https://github.com/FZJ-INM1-BDA/celldetection).

The volumetric shrinkage factor of the tissue has been determined as 1,931. The factor is already taken into account in the pdf reports included in this repository for estimates of cell numbers per volume, cell body areas, and cortical layer thickness. The factor is not applied to the measured attributes in segments.txt and layerinfo.txt - they refer to the physical image coordinates in micron.


The repository contains subfolders for different tissue sections, which contain one subfolder per sampled image patch with the actual data. The file structure is as follows:

``` 
.
├─ [brain region name]
│  ├─ stats.pdf  ..................... Summary report of sample locations and layerwise cell segmentations for all patches of this brain region
│  └─ [tissue section ID] ............ Folder with image patches of one particular tissue section
│      └─ [image patch ID] ........... Folder with data for one image patch
│         ├─ 0.json .................. Polygon annotation of pial surface 
│         ├─ I_II.json ............... Polygon annotation of boundary between layers I and II
│         ├─ II_III.json ............. Polygon annotation of boundary between layers II and III 
│         ├─ III_IV.json ............. Polygon annotation of boundary between layers III and IV
│         ├─ IV_V.json ............... Polygon annotation of boundary between layers IV and V
│         ├─ V_VI.json ............... Polygon annotation of boundary between layers V and VI
│         ├─ VI_WM.json .............. Polygon annotation of gray/white matter boundary (inner surface)
│         ├─ image.nii.gz ............ Full resolution image patch as a Nifti file with affine matrix into the physical space of the BigBrain template
│         ├─ image.png ............... Full resolution image patch as png file
│         ├─ info.txt ................ Basic metadata of the image patch as space-separated text file 
│         ├─ layerinfo.txt ........... Measured area in square micrometer per layer annotation for the image patch
│         ├─ layermask.png ........... Layer segmentation mask corresponding to image.png.
│         ├─ report.pdf .............. Visual pdf report of the patch and its segmentation, showing patch location, segmentations, and segmented cell statistics
│         ├─ segments_cpn_xx.tif ..... Segmentation mask of cell instances, where each cell has a unique value. Since the CPN algorithm is able to model overlap, multiple segmentations images xx can be available to capture overlapping instances.
│         ├─ segments.txt ............ Segmented cell attributes, one row per cell with columns: x, y, area (in square micron), layer index (1..6), cell instance label in the segmentation_cpn_xx.png)

```
