# Phillips_etal_2007_Table1

Table 1 | Unadjusted midsagittal area measures of the CC and its subdivisions, total brain volume, and body weight. Source: `fulltext.xml` (PMC full text, PMC1945086), DOI in `__ReadMe.xlsx`.

## Build

Table 1 gives per-individual unadjusted midsagittal areas (mm²) of the corpus callosum (CC) and its 7 subdivisions (rostrum, genu, rostral body, anterior midbody, posterior midbody, isthmus, splenium), total CC area, brain volume (cc) and body weight (kg) for 18 Hiram College capuchins: the 13 named animals of Phillips_Sherwood_2007_Table1 plus Sabro (M), Shiro (M) and the coded M21-02 (M), M57-04 (F) and M58-04 (F). This is the three-author PLoS ONE paper — distinct from the two-author Neuropsychologia petalias paper of the same year (Phillips_Sherwood_2007_Table1), and not the manuscript duplicated in the repo's `Phillips_Sherwood_2007_b` folder.

From the paper folder, run:

```sh
Rscript Phillips_etal_2007_Table1_snapshot.R
Rscript Phillips_etal_2007_Table1.R
```

The source is born-digital: the snapshot script captures the table programmatically from the frozen PMC JATS XML in this folder (the digital-native pattern; no value typed by hand) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Phillips_etal_2007_Table1.R`. The R script reads only its item snapshot and writes `Phillips_etal_2007_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Species.** The paper prints *Cebus apella*; the analysis CSV resolves to *Sapajus apella* and keeps the printed form in `Species (printed)`.
- **The brain volumes are specimen-level values** for the same animals as the other Phillips items — they must not be treated as a species sample independent of Phillips_Sherwood_2005_Table1 and Phillips_Sherwood_2007_Table1 (the colony's union across the three papers is these same 18 animals).
- **Printed totals are not subdivision sums.** The printed Total CC Area does not equal the sum of the 7 printed subdivision areas (Alou: subdivisions sum to 59.50 mm², printed total 62.50 mm²; Carlos: 89.00 vs 88.50; DiMaggio: 66.25 vs 67.75) — the total was evidently traced as its own outline. Both are carried exactly as printed. Table 2's adjusted Overall CC is consistent with the printed totals (verified in the build round by recomputing the adjusted values from this table's areas and brain volumes; see the Table 2 README for the three ±0.007 cases), so the totals, not the sums, are what the paper's own analysis used.
- The snapshot was captured programmatically and checked against an independent extraction of the same XML; human visual signoff remains pending in the registry. No merge is performed by this build.
