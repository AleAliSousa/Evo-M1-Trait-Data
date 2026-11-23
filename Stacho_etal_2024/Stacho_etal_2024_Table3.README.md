# Stacho_etal_2024_Table3

Table 3 | Mean values of brain and RN volume in the five different groups (Homo, Hominidae, Cercopithecidae, Platyrrhini, and Prosimiae). Source: `fulltext.html` (PubMed Central, PMC10976583), DOI in `__ReadMe.xlsx`.

## Build

Despite its caption, Table 3's rows are species (20), not the five groups: for each, the mean fresh brain volume (BV, cm³) and the mean volumes of the parvocellular (RNp) and magnocellular (RNm) parts of the red nucleus in each hemisphere (mm³), over the specimens of Tables 1 and 2, with the n behind each mean. The table's footnote reads: "The total brain volume (BV), as well as the RNp and RNm volumes of the left and right hemisphere are shown. All volumes were corrected for shrinkage."

From the paper folder, run:

```sh
Rscript Stacho_etal_2024_Table3_snapshot.R
Rscript Stacho_etal_2024_Table3.R
```

The snapshot script captures the table from the frozen PubMed Central full text in this folder (`fulltext.html`; snapshot HOWTO method 2) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Stacho_etal_2024_Table3.R`. The snapshot was cross-checked cell-by-cell against the Frontiers JATS XML (`fulltext_frontiers.xml`, same folder): the two renderings agree on every cell, including the flagged alignment below. The R script reads only its item snapshot and writes `Stacho_etal_2024_Table3.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **PRINTING ERROR — the Gorilla and Hylobates measurement values are transposed in print; corrected in the build under a guard.** As printed, *Gorilla gorilla* carries BV 98.8 cm³ / RNp 33.7/34.3 / RNm 2.6/2.0 and *Hylobates lar* BV 396.8 cm³ / RNp 131.1/129.3 / RNm 6.8/7.4 — a 98.8 cm³ gorilla brain and a 396.8 cm³ gibbon brain are both impossible. The within-paper checks (`internal_checks/`) could not prove the swap from the paper alone (every text statement and figure descends from the same Table 3 pipeline, and each row's RNp/BV ratio, 0.34/0.33, sits inside the hominid band either way), but they proved the species names and sample sizes are correct as printed — Table 3's n matches Table 2's specimen counts for all 20 species — so the transposition exchanged **only the five measurement columns**. The cross-paper check then demonstrated it: Table 2's specimens are YN82-140 (the gorilla; BV 362.9 cm³ in MacLeod et al. 2003 Table 2, de Sousa et al. 2010 Table 1 and Bauernfeind et al. 2013 Table 1) and YN81-146 + Disco (the gibbons; BV 88.8 and 115.8 cm³, mean 102.3). As printed both rows are off by a factor of ~3.7–3.9 from the documented volumes of their own specimens; exchanged, both land within ordinary cross-method distance (gorilla 396.8 vs 362.9, +9.3%; gibbon 98.8 vs 102.3, −3.4%). The demonstration is committed in the restricted repo as `__stacho2024_cross_paper_check`. With Michael's approval (2026-11-23), the build script applies the exchange in a guarded block that first asserts the snapshot carries exactly the printed (transposed) values and fails loudly otherwise; the snapshot stays verbatim, and Taxon, Species and Number never move. Both rows' Note column records the printed values and the evidence. No erratum is known.
- **Misprinted species names.** "Saimiri scuireus" and "Daubentonia madagescariensis" are misprints; the build uses the correct binomials in `Species` and keeps the printed forms in `Species (printed)`. "Cercopithecus Spec." is the paper's own indeterminate label and is kept in both columns.
- **Checks.** The build asserts: the non-human per-species n sum to the 25 specimens of Table 2; the human n is 10 (Table 1 lists 11 human brains — see the Table 1 README; the paper does not say which brain is excluded); all volumes are positive; the hominid RNp/BV ratios fall in 0.2–0.45; and the guarded correction's assertions on the printed Gorilla/Hylobates values and sample sizes (see above) hold before the exchange is applied.
- The snapshot was captured programmatically and checked by the assistant against the Frontiers XML rendering; human visual signoff remains pending in the registry. No merge is performed by this build.
