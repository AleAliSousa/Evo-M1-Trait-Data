# Sherwood_etal_2010_SupplementaryTableS1

Table S1 | SY-ir puncta density data used to calculate the asymmetry quotient (AQ). Source: `NIHMS741073-supplement-Supp_Materials.doc` (supplementary document attached to the PMC author manuscript, PMC4676573), DOI in `__ReadMe.xlsx`.

## Build

Supplementary Table S1 gives the per-hemisphere synaptophysin (SY)-immunoreactive puncta densities — number of puncta per 10⁸/mm³ — for the left and right primary motor cortex hand representation of the same 33 chimpanzees as Sherwood_etal_2010_Table1, together with the asymmetry quotient (AQ) calculated from them. It is the only per-hemisphere raw data in either Sherwood chimpanzee paper: every anatomical value in the 2007 paper and in Table 1 of this paper is an AQ, and these densities are what the 2010 density AQs derive from.

From the paper folder, run:

```sh
Rscript Sherwood_etal_2010_SupplementaryTableS1_snapshot.R
Rscript Sherwood_etal_2010_SupplementaryTableS1.R
```

The snapshot script converts the frozen supplementary .doc to HTML with LibreOffice (headless, into a temp directory) and extracts the table programmatically; it refuses to overwrite a differing frozen snapshot. It was run once for this build. On subsequent runs, run only `Rscript Sherwood_etal_2010_SupplementaryTableS1.R`. As a documented exception to the one-snapshot rule, the build also reads the sibling `Sherwood_etal_2010_Table1_snapshot.csv` for the cross-check below. The R script writes `Sherwood_etal_2010_SupplementaryTableS1.csv` and the DOI-coded public TSV. The item definitions are in `reference_tables/`.

## Interpretation and checks

- **AQ verification (passed, one flagged case).** The build recomputes every AQ as (R − L)/((R + L) × 0.5) from the printed densities. The recomputed values agree with this table's printed AQ column within 0.016 for 32 of 33 animals (the printed densities are rounded to 2 decimals, which bounds the recomputation error), and this table's AQ column agrees **exactly** with Table 1's density AQ for all 33 animals. The exception is C0594: printed AQ 0.02 in both tables, but recomputation from the printed densities (left 2.24, right 2.32) gives 0.035 — more than density rounding explains, so the paper's AQ was evidently computed from unrounded or intermediate values. Carried as printed and flagged on the row; it does not meet the project's guarded-correction bar (the two AQ printings agree with each other, and there is no basis for preferring a recomputed value over the printed one).
- The supplement was obtained from the PMC author manuscript's own attachments — no publisher (Wiley) version was needed. Its footnote ("F = female, M = male, Age at death in years") is not a data row and is not captured.
- The snapshot was captured programmatically and checked against an independent text extraction of the same document; human visual signoff remains pending in the registry. No merge is performed by this build.
