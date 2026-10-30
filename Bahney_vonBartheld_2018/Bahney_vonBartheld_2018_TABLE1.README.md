# Bahney_vonBartheld_2018_TABLE1

## Source
Bahney, J., & von Bartheld, C. S. (2018). The cellular composition and glia–neuron ratio in the spinal cord of a human and a nonhuman primate: Comparison with other species and brain regions. *Anatomical Record*, 301(4), 697–710. https://doi.org/10.1002/ar.23728

TABLE 1 (printed p. 701): "Estimates of cell numbers and ratios in the cynomolgus monkey spinal cord". Species: Macaca fascicularis (cynomolgus monkey), from the caption and Results; the table
prints no species column. PDF: `Bahney-2018-The Cellular Composition and Glia-.pdf`.

## Pipeline
| file | role |
|---|---|
| `Bahney_vonBartheld_2018_TABLE1_snapshot.csv` | frozen source: two stacked blocks (IF, stereology) with their printed headers, rows, `±` cells and the abbreviations footnote |
| `Bahney_vonBartheld_2018_TABLE1.R` | reads the snapshot positionally; writes CSV + public TSV; `table_checks` |
| `Bahney_vonBartheld_2018_TABLE1.csv` | one row per method × segment (8 rows) |
| `reference_tables/Bahney_vonBartheld_2018_TABLE1_definitions.csv` | data dictionary |
| `Bahney_vonBartheld_2018_TABLE1_registry_row.xlsx` | registry row for the owner to paste |
| public TSV | `__Public/comparative-data/10.1002%2Far.23728_TABLE1.tsv` |

## Reader / provenance
Transcribed 2026-10-28 by an AI assistant from the PDF text layer (the font encodes `±` as
"6" and `=` as "5"), then checked cell-by-cell against a 3× render of p. 701; every number was
also confirmed present in the text layer. Printed spacing anomalies are kept in the snapshot
(`5.3 ± 0. 85`, `4.2 ± 1. 95`, `74.3 ±42.6`); the build strips them.

## Data role
**primary** (the paper's own isotropic-fractionator and stereology counts, n = 3).

## Columns / units
Cell numbers stay in the printed unit (million cells); percentages and ratios as printed.
IF block → `nonneuronal_pct`, `ratio_type = nNNR`; stereology block → `glia_pct`,
`endothelial_pct`, `ratio_type = GNR`. Observation level: method × segment means.

## Species
`species_as_published` = binomial from caption/Results; harmonised via
`_keys/General/species_key.csv` (source_publication `Bahney_vonBartheld_2018`).

## Table checks
Rule: Cervical + Thoracic + Lumbar vs printed Total (tolerance = half a unit of the last printed
decimal per summed cell + half a unit of the Total); percent columns sum to 100 (0.05 per cell).
All 10 checks pass (segment sums for both methods; percent sums for all 8 rows) — actual R run 2026-10-28.
