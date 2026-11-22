# Sun_etal_2020_ENIGMA_CaseControls_CortSurf

Sun, D., et al. (2020). Large-scale mapping of cortical alterations in 22q11.2 deletion syndrome: Convergence with idiopathic psychosis and effects of deletion size. Molecular Psychiatry, 25, 1822–1834. https://doi.org/10.1038/s41380-018-0078-5

Source: <https://raw.githubusercontent.com/MICA-MNI/ENIGMA/b08974b55243060cbc1fad12c87048037446e8f7/enigmatoolbox/datasets/summary_statistics/22q_case-controls_CortSurf.csv>. Downloaded 2026-11-22; SHA-256 `4bb33c3571787b0e425f8b516320397d51ffadbe14145d0a6104882d2f1eef1a`.
Frozen source: `Sun_etal_2020_ENIGMA_CaseControls_CortSurf_snapshot.csv`, bytes unchanged. 68 analysis rows.

Published adjusted group contrast; no new test or spatial null. Generic d_icv header does not define covariates; metric comes from file name and loader.

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

From the repository root: `LC_ALL=en_US.UTF-8 Rscript Sun_etal_2020/Sun_etal_2020_ENIGMA_CaseControls_CortSurf.R`.
Clean-session rebuild completed. Source numeric fields are checked against the untouched
CSV/Excel cells in `reference_tables/ingestion_validation.csv`. These effect tables do not
print additive totals suitable for a table-sum check. No figure-derived replot is required.

CSV and public TSV are written. Definitions accompany the item. Registry insertion is pending:
`Sun_etal_2020_ENIGMA_CaseControls_CortSurf_registry_row.xlsx` contains paste-ready manual fields and HOW_TO_PASTE instructions.
The build looks up the live registry by Item name and uses an explicitly provisional DOI code
only while that row is absent. Per repository rules the master workbook was not script-edited.
