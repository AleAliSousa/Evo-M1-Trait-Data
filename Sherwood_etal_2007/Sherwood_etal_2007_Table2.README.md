# Sherwood_etal_2007_Table2

Table 2 | Population-level asymmetries (mean AQ, SD, t, P). Source: `fulltext.html` (PMC author manuscript, PMC2680156), DOI in `__ReadMe.xlsx`.

## Build

Table 2 gives the group statistics for Sherwood et al. (2007): mean asymmetry quotient (AQ), SD, one-sample t and P for the handedness index and the 11 neuroanatomical AQs of Table 1, n = 18 chimpanzees. It is derivable from Table 1 and adds no new observations; it is registered and built following the workbook's precedent for group-statistics tables (cf. Semendeferi_etal_2011 Tables 2–3), and because its recomputation check validates Table 1's capture.

From the paper folder, run:

```sh
Rscript Sherwood_etal_2007_Table2_snapshot.R
Rscript Sherwood_etal_2007_Table2.R
```

The snapshot script captures the table programmatically from the frozen PMC author-manuscript HTML in this folder and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Sherwood_etal_2007_Table2.R`. As a documented exception to the one-snapshot rule, the build also reads the sibling `Sherwood_etal_2007_Table1_snapshot.csv`: this table is the group summary of Table 1, and the build recomputes every mean and SD from Table 1's values before writing. The printed table's first column (variable names) carries no heading in the PMC rendering; the snapshot names it "Variable". The R script writes `Sherwood_etal_2007_Table2.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **Recomputation check (passed).** Every printed mean and SD was recomputed from Table 1's captured values: maximum absolute deviation 0.006, within the rounding of the printed 2-decimal values. The t and P columns are carried as printed (they are not exactly reproducible from rounded inputs and were not recomputed).
- The population-level findings as printed: leftward bias for neuron density in layer II/III (mean AQ −0.20, P = 0.01) and for hand knob (−0.19, P = 0.05); the HI mean is +0.30 (P = 0.04). The individual-level result of the paper — that PV-ir interneuron density asymmetry best predicts hand preference — is a regression result in the text, not a table, and is not part of this item.
- The snapshot was captured programmatically and checked against an independent extraction of the same HTML; human visual signoff remains pending in the registry. No merge is performed by this build.
