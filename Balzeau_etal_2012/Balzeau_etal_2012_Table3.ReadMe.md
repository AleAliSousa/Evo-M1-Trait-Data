# Balzeau_etal_2012_Table3

## Source

PDF: `Balzeau-2012-Variations and asymm.pdf`

Paper: Balzeau, A., Holloway, R. L., & Grimaud-Herve, D. (2012). *Variations and asymmetries in regional brain surface in the genus Homo.* Journal of Human Evolution, 62(6), 696-706. https://doi.org/10.1016/j.jhevol.2012.03.007

Table: **Table 3. Size-corrected dimensions for the surface of the frontal, parieto-temporal and occipital lobes in the different analysed samples.** (p. 701)

## What the table reports

Per Homo sample (5) x cortical lobe (3): the sample size `n`, the mean **size-corrected** surface dimension, and `V*` (the sample size-corrected coefficient of variation). The values are **relative/allometric** (size-corrected), not absolute surfaces or volumes, so they are **not** merged into `__merging_volumes`.

Samples: Homo habilis s.l.; African and Georgian Homo erectus s.l.; Asian Homo erectus; Neandertals s.l.; AMH (anatomically modern Homo sapiens).

## Files

| Path | Role |
|---|---|
| `Balzeau_etal_2012_Table3_snapshot.csv` | Faithful capture of the printed Table 3 (caption + two-tier header + 3 lobe rows). Source of truth. |
| `Balzeau_etal_2012_Table3.R` | Preparation: snapshot -> `Balzeau_etal_2012_Table3.csv` (+ DOI-named TSV). Positional read of the two-tier header; reshaped to one tidy row per (sample x lobe). |
| `Balzeau_etal_2012_Table3.csv` | Analysis-ready data, 15 rows (5 samples x 3 lobes). "use this". |
| `reference_tables/Balzeau_etal_2012_Table3_definitions.csv` | Data dictionary. |
| `comparison/balzeau.csv` | Pre-existing curated copy of Table 3, audited only. |
| `comparison/Balzeau_etal_2012_Table3_compare_to_balzeau_csv.R` | QA: snapshot vs curated. |
| `comparison/..._comparison_report_from_R.csv`, `..._mismatches_from_R.csv` | QA outputs. |

## Preparation

`Balzeau_etal_2012_Table3.R` reads only the snapshot. Because the printed table has a two-tier header (sample group spanning `n / Mean / V*`), the snapshot is read positionally: the caption and the two header rows are skipped, and the three lobe rows are reshaped to long format with columns `Sample`, `Structure_Balzeau2012` (printed lobe name), `Structure` (canonical), `n`, `Mean_surface_sizecorrected`, `V_star`, `source`. On save it writes the CSV next to the script and a DOI-encoded TSV into `__Public/comparative-data/`.

## Checking

`comparison/Balzeau_etal_2012_Table3_compare_to_balzeau_csv.R` audits the snapshot against `comparison/balzeau.csv`: **45 values checked (5 samples x 3 lobes x {n, Mean, V*}), 0 mismatches.** The snapshot was also verified cell-by-cell against the PDF text (page 701).

## Data role

`secondary` — size-corrected (relative) surface dimensions, not absolute measures; recorded for provenance but excluded from the volumes merge.
