# Walton_etal_2022_ENIGMA_WeightRestoredControls_CortThick

Walton, E., et al. (2022). Brain Structure in Acutely Underweight and Partially Weight-Restored Individuals With Anorexia Nervosa: A Coordinated Analysis by the ENIGMA Eating Disorders Working Group. Biological Psychiatry. https://doi.org/10.1016/j.biopsych.2022.04.022

Source: <https://raw.githubusercontent.com/MICA-MNI/ENIGMA/b08974b55243060cbc1fad12c87048037446e8f7/enigmatoolbox/datasets/summary_statistics/anorexia_pwrAN-controls_CortThick.csv>. Downloaded 2026-11-22; SHA-256 `cefafc2f52f2998459485f9592aa5a27fd9569cf6c87891f1598019fc92b5cba`.
Frozen source: `Walton_etal_2022_ENIGMA_WeightRestoredControls_CortThick_snapshot.csv`, source cells unchanged (repository LF line endings; original download used CRLF). 68 analysis rows.

Published adjusted group contrast; no new test or spatial null. Generic d_icv header does not define covariates; metric comes from file name and loader. Source n_patients equals n_controls and differs from matched wGlo file; retained as printed, not used for weighting.

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

From the repository root: `LC_ALL=en_US.UTF-8 Rscript Walton_etal_2022/Walton_etal_2022_ENIGMA_WeightRestoredControls_CortThick.R`.
Clean-session rebuild completed. Source numeric fields are checked against the untouched
CSV/Excel cells in `reference_tables/ingestion_validation.csv`. These effect tables do not
print additive totals suitable for a table-sum check. No figure-derived replot is required.

CSV and public TSV are written. Definitions accompany the item. Registry insertion is pending:
`Walton_etal_2022_ENIGMA_WeightRestoredControls_CortThick_registry_row.xlsx` contains paste-ready manual fields and HOW_TO_PASTE instructions.
The build looks up the live registry by Item name and uses an explicitly provisional DOI code
only while that row is absent. Per repository rules the master workbook was not script-edited.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Walton_etal_2022_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Walton_etal_2022-E002 | n_cases | ENIGMA anorexia_pwrAN-controls_CortThick.csv; all rows | n_patients equals n_controls | retained as source | publication_ambiguity |  | proposed | All 68 n_patients values equal n_controls; matched wGlo export reports different patient counts (e.g. L_bankssts 249 vs 551). | No counts corrected. These contrasts are ingested but excluded from the primary cross-condition comparison. Source n must not be used for weighting pending clarification. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
