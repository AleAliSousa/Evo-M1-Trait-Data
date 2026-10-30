# DeCasien & Higham 2019 - DQI data

DeCasien AR, Higham JP (2019). *Primate mosaic brain evolution reflects selection on sensory and cognitive specialization.* Nature Ecology & Evolution 3:1483-1493. doi:10.1038/s41559-019-0969-0

## Table

- **Workbook:** `41559_2019_969_MOESM3_ESM.xlsx`
- **Worksheet:** `DQI data`
- **Rows written:** 72
- **Role:** Diet quality index values, dietary component percentages, source reference numbers and notes.
- **Taxonomic coverage:** 72 distinct printed `Taxon` values; printed names are preserved and `species_sci` is added through the project species key.

## What we built

- **Frozen source (digital-native, no derived snapshot):** the journal workbook is retained verbatim and read directly.
- **Reformat:** `DeCasien_Higham_2019_DQIdata.R` reads only this worksheet, removes only wholly empty formatting rows/columns, preserves source fields and writes:
  - `DeCasien_Higham_2019_DQIdata.csv`
  - `__Public/comparative-data/10.1038%2Fs41559-019-0969-0_DQIdata.tsv` when no registry encoding is available.
- **Registry lookup:** if `__ReadMe.xlsx` contains an `Item encoded` value matching the script name, that value overrides the fallback public filename.

## Data role

**Secondary compilation/supporting table.** DeCasien and Higham compiled the study data from published literature sources. The publication reports 33 brain regions and socioecological predictors including activity period, diet, DQI, social system and group size. Primary-source references printed in the worksheet are retained for provenance.

## Source-specific caveats

- Brain-region values combine literature sources and may include multiple rows per taxon. The publication states that final analytical values were sample-size-weighted across studies. This build does not reproduce that downstream aggregation; it preserves the worksheet rows.
- The brain-region workbook uses replacement-note codes and grey-cell exclusions. The codes are documented in `Brain Region Data Notes`; cell formatting remains in the frozen workbook and is not represented in CSV/TSV.
- `Group Size Data (from 38)` contains explicit `ok`/`dup` flags. The build preserves both and does not silently remove duplicate-flagged rows.
- Missing values are written as blank fields.

## Downstream use

Use the built table as a provenance-preserving input to the relevant brain-volume or socioecological merge. Apply any study-specific filtering, aggregation or duplicate exclusion explicitly in downstream code, not in this source build.

## Checks

- Expected output rows: **72**.
- The script reports the number of rows written.
- Source columns are preserved after removal of wholly empty formatting columns.
