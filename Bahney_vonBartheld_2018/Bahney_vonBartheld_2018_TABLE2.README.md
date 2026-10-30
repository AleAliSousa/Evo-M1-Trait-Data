# Bahney_vonBartheld_2018_TABLE2

## Source
Bahney, J., & von Bartheld, C. S. (2018). The cellular composition and glia–neuron ratio in the spinal cord of a human and a nonhuman primate: Comparison with other species and brain regions. *Anatomical Record*, 301(4), 697–710. https://doi.org/10.1002/ar.23728

TABLE 2 (printed p. 703): "Estimates of cell numbers and ratios in the human spinal cord (cell types based on morphology)". Species: Homo sapiens (human), from the caption and Results; the table
prints no species column. PDF: `Bahney-2018-The Cellular Composition and Glia-.pdf`.

## Pipeline
| file | role |
|---|---|
| `Bahney_vonBartheld_2018_TABLE2_snapshot.csv` | frozen source: two stacked blocks (IF, stereology) with their printed headers, rows, `±` cells and the abbreviations footnote |
| `Bahney_vonBartheld_2018_TABLE2.R` | reads the snapshot positionally; writes CSV + public TSV; `table_checks` |
| `Bahney_vonBartheld_2018_TABLE2.csv` | one row per method × segment (8 rows) |
| `reference_tables/Bahney_vonBartheld_2018_TABLE2_definitions.csv` | data dictionary |
| `Bahney_vonBartheld_2018_TABLE2_registry_row.xlsx` | registry row for the owner to paste |
| public TSV | `__Public/comparative-data/10.1002%2Far.23728_TABLE2.tsv` |

## Reader / provenance
Transcribed 2026-10-28 by an AI assistant from the PDF text layer (the font encodes `±` as
"6" and `=` as "5"), then checked cell-by-cell against a 3× render of p. 703; every number was
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
Actual R run 2026-10-28 — 7 pass, 3 mismatch (kept as printed, warned):
- `segment_sum_Isotropic fractionator (IF)`: 535.5 + 670.3 + 457.9 = 1663.7 vs printed Total 1,660 (difference 3.7; tolerance 0.65).
- `pct_sum_Stereology_Cervical (c)`: 80.5 + 13.5 + 6.8 = 100.8 (tolerance 0.15).
- `pct_sum_Stereology_Total`: 74.8 + 13.4 + 12.2 = 100.4 (tolerance 0.15).

Text/table note: Results (p. 703) states "The GNR was 7.25, 5.33, and 6.94 for the cervical,
thoracic and lumbar spinal cord, respectively (Table 2)", but Table 2 prints stereology GNRs
7.1 / 5.7 / 5.6; the text values match the IF **nNNR** column (7.2 / 5.3 / 6.9) to rounding.
The CSV keeps the printed table values; candidate `publication_ambiguity` erratum (not filed — owner decision).

## Registry note (action for owner)
`__ReadMe.xlsx` Sheet1 col A for **TABLE 2, TABLE 3 and TABLE 4** ends in an auto-incremented
DOI (`…/ar.23729`, `…/ar.23730`, `…/ar.23731`); the article DOI is **10.1002/ar.23728**
(PDF p. 697; TABLE 1 row). The formula columns therefore resolve `Item encoded` to
`10.1002%2Far.2372{9,30,31}_TABLE{2,3,4}`. The build scripts detect this and write the TSV
under the house-formula code `10.1002%2Far.23728_TABLE<N>` with a warning. The
`<Item>_registry_row.xlsx` files carry the corrected citation; once col A is fixed and
`_tools/file_list.R` re-run, the lookup and the TSV name agree and the guard is inert.
