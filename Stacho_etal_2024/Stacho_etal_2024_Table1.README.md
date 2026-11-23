# Stacho_etal_2024_Table1

Table 1 | Overview of postmortem human brains. Source: `fulltext.html` (PubMed Central, PMC10976583), DOI in `__ReadMe.xlsx`.

## Build

Table 1 lists the 11 postmortem human brains of the study: specimen ID, section type, sex (printed heading "Gender"), age (years) and fresh brain weight (g, printed with thousands separators). The build strips the separators, renames ID to Specimen, and renames the weight column to the house form.

From the paper folder, run:

```sh
Rscript Stacho_etal_2024_Table1_snapshot.R
Rscript Stacho_etal_2024_Table1.R
```

The snapshot script captures the table from the frozen PubMed Central full text in this folder (`fulltext.html`; snapshot HOWTO method 2: the publisher's own HTML rendering) and refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Stacho_etal_2024_Table1.R`. The snapshot was cross-checked cell-by-cell against the Frontiers JATS XML (`fulltext_frontiers.xml`, same folder): the two renderings agree on every cell. The R script reads only its item snapshot and writes `Stacho_etal_2024_Table1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **pm20 and the footnote.** The pm20 row label carries the table's footnote marker (kept in the snapshot as `pm20*`): "*High-resolution brain model BigBrain (Amunts et al., 2013)". The build strips the marker and records the footnote in the row's Note.
- **11 brains here, n = 10 in Table 3.** Table 3's human means use n = 10, so one of these 11 brains is excluded there — most plausibly pm20, the model brain — but the paper does not say which, and this build does not decide it. The discrepancy is recorded here and in the Table 3 definitions so the two items are not silently reconciled later.
- The snapshot was captured programmatically and checked by the assistant against the Frontiers XML rendering; human visual signoff remains pending in the registry. No merge is performed by this build.
