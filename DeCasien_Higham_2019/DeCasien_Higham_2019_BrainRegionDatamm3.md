# DeCasien & Higham 2019 - Brain Region Data (mm3)

DeCasien AR, Higham JP (2019). *Primate mosaic brain evolution reflects selection on sensory and cognitive specialization.* Nature Ecology & Evolution 3:1483-1493. doi:10.1038/s41559-019-0969-0

## Table

- **Workbook:** `41559_2019_969_MOESM3_ESM.xlsx`
- **Worksheet:** `Brain Region Data (mm3)`
- **Rows written:** 399
- **Role:** Compiled brain and brain-region volumes in mm3, with source reference numbers, sample sizes and replacement-note codes.
- **Taxonomic coverage:** 72 distinct printed `Taxon` values; printed names are preserved and `species_sci` is added through the project species key.

## What we built

- **Frozen source (digital-native, no derived snapshot):** the journal workbook is retained verbatim and read directly.
- **Reformat:** `DeCasien_Higham_2019_BrainRegionDatamm3.R` reads only this worksheet, removes only wholly empty formatting rows/columns, preserves source fields and writes:
  - `DeCasien_Higham_2019_BrainRegionDatamm3.csv`
  - `__Public/comparative-data/10.1038%2Fs41559-019-0969-0_BrainRegionDatamm3.tsv` when no registry encoding is available.
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

- Expected output rows: **399**.
- The script reports the number of rows written.
- Source columns are preserved after removal of wholly empty formatting columns.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/DeCasien_Higham_2019_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| DeCasien_Higham_2019-E001 | Septum | MOESM3 BrainRegionData(mm3), row r014 (Aotus_trivirgatus), column Septum | 83.3 | 83.3 | publication_error | 83.8 | proposed | DeCasien & Higham cite Stephan, Frahm & Baron 1981 for this cell; Stephan_etal_1981 Table VI prints 83.8 for Aotus trivirgatus (N = 5, same N). Single-digit substitution (8 -> 3). | Repo CSV mirrors the published supplement (83.3) and is NOT changed; the errata records the disagreement with the cited source. |
| DeCasien_Higham_2019-E002 | Septum | MOESM3 BrainRegionData(mm3), row r144 (Gorilla_gorilla_gorilla), column Septum | 1193 | 1193 | publication_error | 1173 | proposed | Cited source Stephan_etal_1981 Table VI prints 1173 for Gorilla gorilla (N = 1, same N). Single-digit substitution (7 -> 9). | Repo CSV mirrors the published supplement (1193) and is NOT changed. |
| DeCasien_Higham_2019-E003 | Amygdala | MOESM3 BrainRegionData(mm3), row r385 (Saimiri_sciureus), column Amygdala | 277 | 277 | publication_error | 227 | proposed | Cited source Stephan_etal_1981 Table XI prints 227 for Saimiri sciureus (N = 1, same N). Single-digit substitution (2 -> 7). | Repo CSV mirrors the published supplement (277) and is NOT changed. |
| DeCasien_Higham_2019-E004 | MOB | MOESM3 BrainRegionData(mm3), row r393 (Tarsius_syrichta), column MOB | 79.2 | 79.2 | publication_error | 18.8 | proposed | Cited source Stephan_etal_1981 Table V prints 18.8 for Tarsius syrichta (N = 2); the supplement's 79.2 is the value printed on the ADJACENT row of Table V (wrong-row copy). | Repo CSV mirrors the published supplement (79.2) and is NOT changed. |
| DeCasien_Higham_2019-E005 | Cerebellum | MOESM3 BrainRegionData(mm3), row r340 (Pongo_pygmaeus), column Cerebellum (Zilles & Rehkämper 1988 entry) | 42900 | 42900 | publication_ambiguity |  | proposed | 42900 is the Zilles & Rehkämper 1988 Table 12-2 'Cerebellum' figure, which that source gives WITHOUT the pons, whereas the DeCasien column key defines Cerebellum as pons-inclusive (Stephan code). N differs too (DeCasien N = 2 vs Zilles N = 1). The number is reproduced exactly; the structure definition is not. | No proposed value: a structure-definition mismatch, not a digit error. Flag for anyone pooling this row with Stephan-key cerebellum volumes. |

5 recorded, 5 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
