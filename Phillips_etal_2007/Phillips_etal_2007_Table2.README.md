# Phillips_etal_2007_Table2

Table 2 | Midsagittal area measures of the CC and its subdivisions (statistically adjusted), age, handedness index and dextral group. Source: `fulltext.xml` (PMC full text, PMC1945086), DOI in `__ReadMe.xlsx`.

## Build

Table 2 gives the size-adjusted corpus callosum measures for the same 18 capuchins as Table 1 of the same paper: overall CC and each subdivision adjusted as √area / ∛(brain volume) (unitless derived ratios), plus age, tube-task mean handedness index (MHI) and dextral group. The paper's by-sex and by-handedness group summaries are Figures 2 and 3 (bar charts of group means ± SD) — figure-only, and not part of this item.

From the paper folder, run:

```sh
Rscript Phillips_etal_2007_Table2_snapshot.R
Rscript Phillips_etal_2007_Table2.R
```

The source is born-digital: the snapshot script captures the table programmatically from the frozen PMC JATS XML in this folder (the digital-native pattern; no value typed by hand) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Phillips_etal_2007_Table2.R`. The R script reads only its item snapshot and writes `Phillips_etal_2007_Table2.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Adjusted values are derived ratios, carried as printed.** They are not areas and must not be back-converted. The build round verified every adjusted value by recomputing √area / ∛(brain volume) from Table 1's printed areas, totals and brain volumes: 141 of 144 agree within the printed rounding (0.005); the three exceptions are Overall CC values (Carlos, Jake, Noel) off by 0.005–0.007, consistent with the authors having computed from unrounded areas and volumes. Carried as printed.
- **Blanks are data.** MHI and Dextral Group are blank, as printed, for Sabro, Shiro, M21-02, M57-04 and M58-04 — the 5 animals that were not in the 2007 behavioural sample. The build carries them as missing with a Note, never as zero.
- **Cross-paper agreement.** Ages and MHIs for the 13 shared animals agree exactly with Phillips_Sherwood_2007_Table1 (asserted in the build). Species is printed *Cebus apella* and resolved to *Sapajus apella*, printed form kept in `Species (printed)`.
- Several values print without a leading zero (".525"); the snapshot keeps the printed form and the build normalises to numeric. The snapshot was captured programmatically and checked against an independent extraction of the same XML; human visual signoff remains pending in the registry. No merge is performed by this build.
