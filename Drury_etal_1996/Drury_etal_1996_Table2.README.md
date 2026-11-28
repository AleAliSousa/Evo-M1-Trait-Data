# Drury et al. 1996 — Table 2: surface area of cortical subdivisions in the macaque

Drury, H. A., Van Essen, D. C., Anderson, C. H., Lee, C. W., Coogan, T. A., & Lewis, J. W. (1996). Computerized mappings of the cerebral cortex: A multiresolution flattening method and a surface-based coordinate system. *Journal of Cognitive Neuroscience, 8*(1), 1–28. https://doi.org/10.1162/jocn.1996.8.1.1

Registry item: **`Drury_etal_1996_Table2`**; public TSV `10.1162%2Fjocn.1996.8.1.1_Table2.tsv`.

## What the table is
Table 2 (journal p. 15) gives, for one macaque hemisphere (case 79-0, right hemisphere), the surface area of 79 cortical subdivisions on the three-dimensional reconstruction (mm²) and each as a percent of total cortical surface. Areal borders were painted on a physical model of this hemisphere following Felleman & Van Essen (1991) and transferred to the computerized reconstruction; case 79-0 was reconstructed from layer-4 contours of Nissl-stained sections. Printed subtotals (visual, somatosensory, motor, auditory, prefrontal, neocortex), total non-neocortex and total cerebral cortex are kept as their own rows (`row_type`).

The footnote says the areas are 3-D surface areas; areas measured on the 2-D flat map were within a few percent except V3, V3A, PIP and FEF (more than 20% off).

## Frozen source and reader
- The PDF (`Drury-1996-Computerized mappings of the cerebr.pdf`) is a scan; its text layer garbles this table.
- **Reader:** an AI assistant (Copilot) read Table 2 by eye from a 300-dpi render of PDF page 15 on 2026-11-10 and typed it as a verbatim printed-layout block in `Drury_etal_1996_Table2_snapshot.R`, which writes the frozen `Drury_etal_1996_Table2_snapshot.csv` (and refuses to overwrite a differing copy unless `EVOM1_UNFREEZE="Drury_etal_1996_Table2"`).
- **Second reading:** a fresh OCR (tesseract) of the same render agrees on all 87 printed areas and on 85 of 87 percents; the two others (7b 1.9, S11 1.5) were read by OCR without the decimal point and are confirmed on the image.
- Rows are in reading order (left column block, then right). Labels are kept as printed: "MST1" and "S11" are the typeface's MSTl and SII (`area_label` gives the standard form), and the footnote's "Fellemann" is kept.
- `Drury_etal_1996_Table2.R` reads the snapshot, carries the group headings down (`system`, `visual_subgroup`, `cortex_class`), keeps printed values, runs the table checks and writes `Drury_etal_1996_Table2.csv` (87 rows: 79 areas + 8 subtotal/total rows) and the public TSV.
- **R NOT RUN:** the 10 Nov 2026 CSV and TSV were written by a Python mirror. Run `Rscript Drury_etal_1996_Table2_snapshot.R` then `Rscript Drury_etal_1996_Table2.R` to confirm.
- Human visual check of the snapshot against page 15: pending (registry column AJ).

## Table checks
Every subtotal and total is recomputed from its cells (tolerance half a mm² per summed cell) and every percent as 100 × area / 7,205 (tolerance 0.05 + area rounding). **95 of 95 pass** (Python mirror).
- Visual 3,726 (sum 3,726); somatosensory 872 (sum 873); motor 652; auditory 224 (sum 225); prefrontal 538; neocortex 6,878 (sum of printed subtotals and the remaining areas 6,879); non-neocortex 327; total 7,205 = 6,878 + 327. The one-unit differences are rounding.

## What it shows about Van Essen & Drury (1997)
`VanEssen_Drury_1997_Text` reuses this hemisphere (case 79-0) for its macaque comparison:
- Its "macaque neocortex 72 cm²" equals this table's **total cerebral cortex** (7,205 mm²), not its neocortex (6,878 mm²). The 1996 text says the same: "The surface area of the three-dimensional reconstruction is 72 cm² for Case 79-0", with the hippocampal formation included. The 1997 macaque percentages (buried 59%, frontal 26%, occipital 32%) may therefore also be shares of the whole cortex; the 1997 paper does not say.
- Its "~13% and ~9%" for macaque V1 and V2 (p. 7099) match this table's 13.1% and 9.6%.
- Felleman & Van Essen's (1991) 99.4 cm² comes from a different hemisphere (case 80-G, measured planimetrically on a flat map; this paper gives that map as 106 cm²), which explains the conflict flagged on the Van Essen macaque rows.

The value-by-value comparison is kept in the restricted repo (`restricted_checks/_cross_table/Drury_etal_1996_vs_VanEssen_Drury_1997/`), per the repo boundary rule.

## Species
The paper identifies the animal only as a macaque (commercially acquired brain, species unknown; Carolina Biological, Burlington, NC) → *Macaca* sp. (NCBI 9539, genus). Species-key row: `_keys/General/species_key.csv`, source `Drury_etal_1996`.

## Data role
Primary (measured on the authors' own reconstruction). One hemisphere of one animal: do not treat as a species mean.

## Snapshot layout audit (2026-11-27)

Compared local PDF Table 2. Rebuilt the snapshot as the two printed
three-column blocks, side by side, with the caption and footnote retained.
The R reader separates the blocks and supplies line metadata. Ran
`Rscript Drury_etal_1996/Drury_etal_1996_Table2.R`: all 95 table checks
passed and the 87-row CSV retained SHA-256
`3d8fa04e3ae00ff704ea9ea0bcdd04de43a483961e6f6bd0d7ffc05132f58bb0`.
