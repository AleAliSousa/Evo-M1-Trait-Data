1. Open PDF in Adobe and Export > Image > JPEG
2. Open a figure page in ImageJ
3. Start with linear scale
- Use the line selection tool to draw a line along the length of the scale bar
- go to Analyze > Set Scale
- input the known physical distance represented by the line bar in the "known distance" field, along with the appropriate unit of measurement

4. Next Wand (tracing) tool
5. Do largest structure first


2a. Open figure with Fuji
3. Robust Automatic Threshold Selection https://imagej.net/plugins/rats
-> improves wand (still lacks black line) 
-----> could instead ignore ALL black lines and just count the white inside and add the white inside up
-> choose a high pixel to remove noise
4. Analyze > Set Measurements > Display label
-> includes name of ROI
5. ROI Manager > (select a structure) Add [t] 
6. ROI Manager > Rename... (for label)
7. ROI Manager > More >> Save (saves selected ones as zip)
8. ROI Manager > More >> Open (opens zipped)

