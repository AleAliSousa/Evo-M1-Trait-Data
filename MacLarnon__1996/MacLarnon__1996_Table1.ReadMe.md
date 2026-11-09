---> Source

Open in Adobe Acrobat Pro. Export a PDF > Microsoft Excel > Microsoft Excel Workbook 

Copy and paste Table 1 from Microsoft Excel Workbook 

--> Snapshot

MacLarnon_1996_Table1_snapshot.xlsx

--> Data readable

Separated order and species columns. Thereby, creating a new "Order" column and added order names in it

Separated subspecies size and species column. Thereby, creating a new "Subspecies size" column and added the values

Separated Spinal cord length (mm) (Dissection//ΣDCL) into  Spinal cord length (mm): Dissections and  Spinal cord length (mm): ΣDCL columns 

Added separate data source column for Body weight (g), Body weight (mg), Spinal cord weight (mg), Spinal cord length (mm): Dissection, Spinal cord length (mm): ΣDCL. And hence removed the reference columns and *

Removed all the characters from values and remove all the — and na to change to auto NA

And convereted columns Body weight (g), Body weight (mg), Spinal cord weight (mg), Spinal cord length (mm): Dissection, Spinal cord length (mm): ΣDCL from chr to numerical.

MacLarnon_1996_Table1.csv <-- USE THIS

--> Online database

Added TSV copy named with DOI to https://github.com/r03ert0/comparative-data

10.1006%2Fjhev.1996.0005_Table1.tsv <-- ONLINE COPY

--> Corrections and source checks (6 Nov 2026; AI assistant, R NOT RUN)

Column label (erratum MacLarnon__1996-E001). The snapshot heads the third value column "Body weight (mg)", but MacLarnon (1996) Table 1 (p. 73) prints "Brain weight (mg)". MacLarnon__1996_Table1.R now renames the column straight after reading the snapshot (the snapshot itself is unchanged), so the CSV and the public TSV carry "Brain weight (mg)" and "Brain weight (mg): Data Source". No values changed.

Rabbit, small subspecies (race X). Checked against the cited source, Latimer & Sawin (1955) (PDF in Latimer_Sawin_1955/), on the page images. The values are the means of the normal (non-dwarf) rabbits, with gross body weight:
- males (n = 35): body 1972.3 g (Table 1, panel B), spinal cord 3.945 g (Table 7), brain 9.265 g (Table 4)
- females (n = 30): body 2480.0 g (Table 1, panel C), spinal cord 4.537 g (Table 7), brain 9.755 g (Table 5)
All six values match. Latimer & Sawin also print cord length by dissection (280.6 mm males, 298.5 mm females; Table 7), which Table 1 leaves blank. Their all-rabbit means (males 1870.0 g, 3.925 g, 9.156 g; females 2192.9 g, 4.292 g, 9.349 g) are not the ones used here. Mink et al. (1981) Table 1 cites the same paper but pairs the female body and brain weights with the male cord weight; that is recorded on the Mink item as erratum Mink_etal_1981-E005.

The CSV and the public TSV were rewritten by a Python mirror of the updated script (header change only; the mirror reproduces the previous R output byte for byte before the change). Run MacLarnon__1996_Table1.R to confirm: the outputs should be identical. The script now also stops if the two rabbit rows ever change.

Errata for this item are in reference_tables/MacLarnon__1996_errata.csv. render_errata.R looks for a README named MacLarnon__1996_Table1.README.md, so it will not update this ReadMe.md; the block below was written by hand in the same format. Renaming this file to MacLarnon__1996_Table1.README.md would let render_errata keep it up to date.


<!-- errata:begin -->
## Errata

Generated from `reference_tables/MacLarnon__1996_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| MacLarnon__1996-E001 | Brain weight (mg) | Table 1, p. 73, header of the third value column (between 'Spinal cord weight (mg)' and 'Spinal cord length (mm)') | Brain weight (mg) | Body weight (mg) | repo_transcription_error | Brain weight (mg) | proposed | The printed header (PDF text layer and page image, p. 73) reads 'Body weight (g) \| Spinal cord weight (mg) \| Brain weight (mg) \| Spinal cord length (mm) (Dissection/ΣDCL) \| Refs'. The snapshot (Acrobat export) heads this column 'Body weight (mg)', and the CSV and public TSV inherited the label ('Body weight (mg)' and 'Body weight (mg): Data Source'). The values are brain weights: Oryctolagus cuniculus (small subspecies) 9265 mg (M) and 9755 mg (F) equal the brain weights in Latimer & Sawin (1955) Tables 4 and 5 (9.265 g and 9.755 g), read on the page images. | Fix made in MacLarnon__1996_Table1.R on 2026-11-06 (column renamed after reading the snapshot; snapshot unchanged; no values changed). CSV and public TSV rewritten by a Python mirror (R NOT RUN). Set status to confirmed after the human check. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
