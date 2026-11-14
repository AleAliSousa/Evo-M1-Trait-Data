# Herberstein_etal_2022_Columndescriptions

Source: Herberstein et al. (2022), AnimalTraits — a curated animal trait database for body mass, metabolic rate and brain size. Scientific Data 9, 265. https://doi.org/10.1038/s41597-022-01364-9

## Source and snapshot

The user supplied `observations.xlsx`, downloaded from AnimalTraits (https://animaltraits.org/); the precise download date and release/commit were not supplied. Do not assume this is a separately versioned 2022 release merely from the article year. `Herberstein_etal_2022_Columndescriptions_snapshot.xlsx` is a byte-identical copy of that workbook, frozen on 2026-11-13. Each registered sheet has its own unchanged workbook copy, per the item convention. Read sheet `Column descriptions`. The supplied workbook has incorrect worksheet dimension metadata (A1); readxl discovers the data correctly. No transcription or resaving was performed. Human visual check: Not applicable: tabulated and digital already.

## Build and outputs

Run `Rscript Herberstein_etal_2022/Herberstein_etal_2022_Columndescriptions.R` from the repository root. This writes `Herberstein_etal_2022_Columndescriptions.csv` and the public TSV named by exact Item name lookup in the live `__ReadMe.xlsx`. The registry already contains this item. The separate `Herberstein_etal_2022_Columndescriptions_registry_row.xlsx` proposes descriptive metadata for the owner to paste by header name and Item name. The live registry was not edited. Definitions are in `reference_tables/Herberstein_etal_2022_Columndescriptions_definitions.csv`.

The analysis table retains all 43 published column descriptions, with `Column`, `Description` and `Defined by` unchanged. This is metadata supporting Observations, not an additional set of trait measurements. Its definitions file describes these three fields. The frozen workbook also contains the data sheet, which this item does not read. Both R scripts were executed successfully on 2026-11-13.
