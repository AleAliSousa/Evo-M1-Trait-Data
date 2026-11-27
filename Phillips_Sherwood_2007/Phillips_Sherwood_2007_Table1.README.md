# Phillips_Sherwood_2007_Table1

Table 1 | Subject information and asymmetry quotients for all regional petalias (positive values indicate a right-side bias). Source: `Phillips-2007-Cerebral petalias an.pdf` (NIH-PA author manuscript), PDF page 9, DOI in `__ReadMe.xlsx`.

## Build

Table 1 gives per-individual data for 13 named Hiram College capuchins (7 male, 6 female): sex, age, tube-task mean handedness index (MHI) and z-score, dextral group (R/L/A), and cerebral petalia asymmetry quotients (AQs) for the anterior frontal, posterior frontal, parietal and occipital regions, measured from MRI. Petalias are the protrusion of one cerebral hemisphere relative to the other; these AQs are cerebral-width quotients, not volumes. Group means (± SE) by region appear only in the text and Figure 1 and are not part of this item.

From the paper folder, run:

```sh
Rscript Phillips_Sherwood_2007_Table1_snapshot.R
Rscript Phillips_Sherwood_2007_Table1.R
```

The snapshot script captures the table programmatically from the frozen author-manuscript PDF in this folder (snapshot HOWTO method 3: poppler `pdftotext -bbox` word geometry) and refuses to overwrite a differing frozen snapshot. The table is printed rotated 90 degrees on the page: in word geometry the printed columns run as horizontal bands and the 13 printed rows as vertical slots 8 pt apart; the script assigns every word to its band and slot and asserts the printed subject order. It was run once for this build. On subsequent runs, run only `Rscript Phillips_Sherwood_2007_Table1.R`. The R script reads only its item snapshot and writes `Phillips_Sherwood_2007_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Source is the author manuscript, not the publisher version.** Values are as in the NIH-PA manuscript held in this folder. A byte-identical PDF formerly in `Phillips_Sherwood_2007_b` was removed on 2026-11-26; it was not a separate paper. The other Phillips 2007 paper is the three-author PLoS ONE corpus callosum paper, built as Phillips_etal_2007.
- **Sign convention** (printed table title): positive petalia AQ values indicate a right-side bias. MHI is the tube-task handedness index, (R − L)/(R + L); the dextral group follows the paper's z-score rule (|z| > 1.95 = unambiguous).
- **Species.** The paper prints *Cebus apella*; the analysis CSV resolves to *Sapajus apella* and keeps the printed form in `Species (printed)`.
- **Seven of these animals are the coded subjects of the 2005 paper.** By exact matches on both tube-task MHI and z: Vincent = CA003, Alou = H03, Miro = CA9207, Shoeless = H04, Carlos = CG29, Sosa = H02, DiMaggio = H06. Probable-grade inference from exact value matches, not a printed identification; the names are kept as printed here and the 2005 code is recorded in the Note column. The other 6 animals (DC, Georgia, Gizmo, Jake, LC, Noel — all female) appear first in this paper.
- **Coincidence as printed:** Miro's anterior frontal and posterior frontal petalia AQs are both −11.76. Recorded as printed.
- The snapshot was captured programmatically and checked against an independent extraction of the same page; human visual signoff remains pending in the registry. No merge is performed by this build.
