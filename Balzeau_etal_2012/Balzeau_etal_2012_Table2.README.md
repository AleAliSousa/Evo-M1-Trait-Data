# Balzeau_etal_2012_Table2

## Source

PDF: `Balzeau-2012-Variations and asymm.pdf` (p. 700)

Paper: Balzeau, A., Holloway, R. L., & Grimaud-Herve, D. (2012). *Variations and asymmetries in regional brain surface in the genus Homo.* Journal of Human Evolution, 62(6), 696-706. https://doi.org/10.1016/j.jhevol.2012.03.007

Table: **Table 2. Regression results for the relationship between endocranial volume and the surface of the frontal, parieto-temporal and occipital lobes.**

## What the table reports

Per cortical lobe (3) x regression sample (Complete sample / Fossil hominins / AMH): `n`, `Slope`, `Intercept`, `Rsquared`, and a significance code (all `***`, p < 0.001). These are published **regression statistics** (allometric scaling of lobe surface on endocranial volume), not per-specimen measurements.

## Files

| Path | Role |
|---|---|
| `Balzeau_etal_2012_Table2_snapshot.csv` | Faithful capture (caption + header + 9 rows + footnote); the spanned lobe label is left blank on continuation rows as printed. |
| `Balzeau_etal_2012_Table2.R` | Preparation: snapshot -> CSV (+ TSV). Forward-fills the lobe label; parses numbers. |
| `Balzeau_etal_2012_Table2.csv` | Analysis-ready data, 9 rows (3 lobes x 3 samples). |
| `reference_tables/Balzeau_etal_2012_Table2_definitions.csv` | Data dictionary. |

The extraction is from the born-digital journal PDF text (verified); the printed minus sign renders as `(cid:3)` in raw extraction and was resolved to `-`.

## Data role

`secondary` — regression/scaling statistics, not merged into any trait table.

## Registry note

This table is **not currently in `__ReadMe.xlsx`**. It was found while mining the paper for additional real data. To finish the pipeline, add a registry row (proposed `Item name` `Balzeau_etal_2012_Table2`, `Item encoded` `10.1016%2Fj.jhevol.2012.03.007_Table2`) — see the proposed-registry xlsx in the delivery folder. Until then the `.R` writes the local CSV and skips the TSV with a warning.
