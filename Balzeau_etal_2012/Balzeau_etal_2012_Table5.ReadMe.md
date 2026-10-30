# Balzeau_etal_2012_Table5

## Source

PDF: `Balzeau-2012-Variations and asymm.pdf`

Paper: Balzeau, A., Holloway, R. L., & Grimaud-Herve, D. (2012). *Variations and asymmetries in regional brain surface in the genus Homo.* Journal of Human Evolution, 62(6), 696-706. https://doi.org/10.1016/j.jhevol.2012.03.007

Table: **Table 5. Percentage contribution of frontal, parieto-temporal and occipital lobes to the hemispheres.** (p. 702)

## What the table reports

Per Homo sample (5) x cortical lobe (3): the sample size `n`, the mean **percentage** contribution of the lobe to the hemisphere (the three lobe surfaces sum to 100% within each sample), and `V*` (size-corrected coefficient of variation). These are derived percentages, so they are **not** merged into `__merging_volumes`.

Samples: Homo habilis s.l.; African and Georgian Homo erectus s.l.; Asian Homo erectus; Neandertals s.l.; AMH.

## Files

| Path | Role |
|---|---|
| `Balzeau_etal_2012_Table5_snapshot.csv` | Faithful capture of the printed Table 5. Source of truth. |
| `Balzeau_etal_2012_Table5.R` | Preparation: snapshot -> `Balzeau_etal_2012_Table5.csv` (+ DOI-named TSV). |
| `Balzeau_etal_2012_Table5.csv` | Analysis-ready data, 15 rows (5 samples x 3 lobes). "use this". |
| `reference_tables/Balzeau_etal_2012_Table5_definitions.csv` | Data dictionary. |
| `comparison/balzeau_percentages.csv` | Pre-existing curated copy of Table 5, audited only. |
| `comparison/Balzeau_etal_2012_Table5_compare_to_balzeau_percentages_csv.R` | QA: snapshot vs curated. |
| `comparison/..._comparison_report_from_R.csv`, `..._mismatches_from_R.csv` | QA outputs. |

## Preparation

Same positional read + long reshape as Table 3, with the mean column named `Mean_pct_of_hemisphere`. Output columns: `Sample`, `Structure_Balzeau2012`, `Structure`, `n`, `Mean_pct_of_hemisphere`, `V_star`, `source`.

Note: the percentage sample sizes differ slightly from Table 3 (e.g. AMH `n = 108` here vs `110` there; Neandertals `n = 10` vs `11-12`), exactly as printed.

## Checking

`comparison/Balzeau_etal_2012_Table5_compare_to_balzeau_percentages_csv.R` audits the snapshot against `comparison/balzeau_percentages.csv`: **45 values checked, 0 mismatches.** Also verified against the PDF text (page 702).

## Data role

`secondary` — derived percentages; excluded from the volumes merge.
