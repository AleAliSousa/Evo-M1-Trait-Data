# Carlo_Stevens_2013_TableS1

## Source
Carlo, C. N., & Stevens, C. F. (2013). Structural uniformity of neocortex, revisited.
*PNAS*, 110(4), 1488–1493. https://doi.org/10.1073/pnas.1221398110 — Supporting Information
`pnas.201221398si.pdf`, Table S1 "Species characteristics".

## Pipeline
| file | role |
|---|---|
| `Carlo_Stevens_2013_TableS1_snapshot.csv` | frozen source: printed header, 7 specimen rows, abbreviation footnote |
| `Carlo_Stevens_2013_TableS1.R` | snapshot → CSV + public TSV |
| `Carlo_Stevens_2013_TableS1.csv` | one row per specimen (7) |
| `reference_tables/Carlo_Stevens_2013_TableS1_definitions.csv` | data dictionary |
| `Carlo_Stevens_2013_TableS1_registry_row.xlsx` | registry row |
| public TSV | `__Public/comparative-data/10.1073%2Fpnas.1221398110_TableS1.tsv` |

## Reader / provenance
Transcribed 2026-10-28 by an AI assistant from the SI text layer (born-digital PDF, no
machine-readable table supplied) and verified against a 2.5× render; every cell asserted present
in the text layer. The SI is a PDF, not a born-digital data file, so a transcription snapshot is
the frozen copy.

## Data role
primary (specimen metadata of this study).

## Notes
`in_figure2` drops frontal (F): Figure 2 shows motor, somatosensory, parietal and temporal areas,
and the 24 resulting specimen × area combinations equal the 24 points digitized in
`Carlo_Stevens_2013_Figure2`. `age_years` is NA for "Adult"/"Unknown" (printed text kept in
`age_printed`). Species: Mus sp. / Rattus sp. are genus-only as printed; harmonised via
`_keys/General/species_key.csv` (source_publication `Carlo_Stevens_2013`).

## Table checks
Not assessed (no printed totals).
