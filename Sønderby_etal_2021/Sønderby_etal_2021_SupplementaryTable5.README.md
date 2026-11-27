# Sonderby_etal_2021_SupplementaryTable5

Sønderby, I. E., et al. (2021). 1q21.1 distal copy number variants are associated with cerebral and cognitive alterations in humans. Translational Psychiatry, 11, 170. https://doi.org/10.1038/s41398-021-01213-0

Source: <https://static-content.springer.com/esm/art%3A10.1038%2Fs41398-021-01213-0/MediaObjects/41398_2021_1213_MOESM2_ESM.xlsx>. Downloaded 2026-11-22; SHA-256 `3cc97c9bb25c75ff4f2892fbde9565d48c3f25fa88552ccd1bdfdd52c99c707f`.
Frozen source: `Sønderby_etal_2021_SupplementaryTable5_snapshot.xlsx`, bytes unchanged. 110 analysis rows.

Full workbook frozen unchanged; one sheet curated per item, all sensitivity blocks retained. Other workbook sheets retained in source only.

The source is already tabulated and digital: there is no transcription or figure digitization.
The R reader retains numerical values and source identifiers, trims CSV header whitespace,
and supplies explicit model metadata. No physical units are converted. For the 1q21.1 workbook,
source sheet/row/panel and original CI halfwidths identify every extraction; CI bounds are
computed from the rounded effect and rounded halfwidth. All sensitivity blocks remain available.
Repeated global rows in its two panels are retained upstream and excluded from regional comparisons.

ENIGMA fields named `d_icv` are generic. The original article defines the covariates.
Walton cortical baseline models adjust age and age squared (scanner indicators where needed),
with mean cortical thickness or total cortical surface area added in wGlo models; no ICV
covariate for cortical baseline models. Sun case-control CT includes age squared, age, sex,
site; SA includes age, sex, site, ICV. Sun psychosis contrasts include age, sex, site and ICV
only for SA. Source ROI n is absent for Sun: contrast-level 386/315 or 60/60 is separate metadata.
Sonderby normalizes covariate residuals before the group test. Its ICV-adjusted effects are not
total-cortex-adjusted effects. Its printed contrast headings and numerical signs are preserved.

Observation level: regional group contrast. These records are unsuitable for a species-volume
or cell-count merge. ENIGMA Toolbox exports are secondary representations of the named primary
paper, not new independent cohorts. Overlapping contrasts must not be meta-analysed together.

## Rebuild and checks

From the repository root: `LC_ALL=en_US.UTF-8 Rscript Sønderby_etal_2021/Sønderby_etal_2021_SupplementaryTable5.R`.
Clean-session rebuild completed. Source numeric fields are checked against the untouched
CSV/Excel cells in `reference_tables/ingestion_validation.csv`. These effect tables do not
print additive totals suitable for a table-sum check. No figure-derived replot is required.

CSV and public TSV are written. Definitions accompany the item. Registry insertion is pending:
`Sønderby_etal_2021_SupplementaryTable5_registry_row.xlsx` contains paste-ready manual fields and HOW_TO_PASTE instructions.
The build looks up the live registry by Item name and uses an explicitly provisional DOI code
only while that row is absent. Per repository rules the master workbook was not script-edited.

## Frozen-file integrity

Automatic Office custom metadata initially changed the copied XLSX byte hashes without changing worksheet/value parts. The exact publisher bytes were restored and the snapshots made read-only. `reference_tables/publisher_workbook_original.zip` also preserves the original workbook bytes. Final SHA-256 checks match download_provenance.csv.
