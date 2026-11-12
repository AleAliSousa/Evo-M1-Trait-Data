# Grabowski et al. 2023: Data File S1, group size and activity period (363 species rows)

Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect primate brain-size evolution. *Systematic Biology*, *72*(2), 404–418. https://doi.org/10.1093/sysbio/syac075

Data: Dryad, https://doi.org/10.5061/dryad.2547d7wpg (Data File S1).

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **Data File S1 Group Size Activity** → Item name **`Grabowski_etal_2023_DataFileS1GroupSizeActivity`**, Item encoded **`10.5061%2Fdryad.2547d7wpg_DataFileS1GroupSizeActivity`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`Grabowski_SB_Data_File_S1.xlsx` is the untouched Dryad Data File S1 (https://doi.org/10.5061/dryad.2547d7wpg), kept under its original name in `Grabowski_etal_2023/` (sha256 `3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `Group Size and Activity Data`, A1 "Group Size and Activity Period Data. Columns in green and also denoted with asterisk contain data used in main analysis."; B1, C1, H1, K1, L1 name the source of each column group. Row 2 is the header (13 columns A-M); rows 3-365 are the 363 species rows; no blank or footnote rows.

**Formulas — cached values.** Column L (356 cells) is `IF(K=1,"Diurnal",IF(K=0,"Nocturnal"))`; all cached at build, none an error. L305 caches the logical FALSE (K305 is `n/a` and the formula has no else branch); it is written as printed, `FALSE`.


## What the data are
Per species: the average group size used in the analysis (`combo_average_group_size`*: Powell et al. 2017 Group.size.combined, else DeCasien et al. 2017 Average.Group Size), the DeCasien et al. 2017 columns (average, min, max, count of entries), the Powell et al. 2017 columns (foraging group size, range, combined size, source) and the activity period (Diurnality 1/0 and Activity.Period.DN* Diurnal / Nocturnal, from Powell et al. 2017 supplemented with Santini et al. 2015 and Shultz et al. 2011).

**Observation level:** species. **Data role: secondary.**

## Build
`Grabowski_etal_2023_DataFileS1GroupSizeActivity.R` (run: `Rscript Grabowski_etal_2023/Grabowski_etal_2023_DataFileS1GroupSizeActivity.R`) reads the frozen file and writes:
- `Grabowski_etal_2023_DataFileS1GroupSizeActivity.csv`: 363 rows × 19 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.5061%2Fdryad.2547d7wpg_DataFileS1GroupSizeActivity.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.5061__dryad.2547d7wpg_DataFileS1GroupSizeActivity.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Grabowski_etal_2023_DataFileS1GroupSizeActivity_definitions.csv` (19 columns + 6 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Grabowski_etal_2023_DataFileS1GroupSizeActivity.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** Text trimmed, white space collapsed, `n/a` → blank. Numeric columns that also print words are split: the number stays in the column, the words go to `*_note` (`foraging_group_size_mean_note`: 'single study', '30+'; `group_size_combined_note`: 'two studies'). Text columns keep printed numbers as text (`group_size_range` '100' on row 41; `source_group_size` '13.9' on row 49). No unit conversion (individuals).

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Grabowski_etal_2023`, matched on the lower-cased printed name). This item prints 363 distinct names; 327 accepted names result. The key rows are new: `out/_keys_General_new_rows_Grabowski_etal_2023.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: verbatim 306, synonym:NCBI 17, our_judgment 16, subspecies_assign 9, unresolved 8, author_judgment 4, lump 2, spelling 1. 102 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). 8 printed names are unresolved (blank `Species`, 8 rows): `Alouatta_arctoidea`, `Aotus_miconax`, `Cebus_nigritusXlibidinosus`, `Cheirogaleus_adipicaudatus`, `Euoticus_pallidus`, `Leontopithecus_caissara`, `Piliocolobus_tholloni_and_foai`, `Presbytis_natunae`. Printed names keep their underscore.

**References.** `reference_tables/Grabowski_etal_2023_DataFileS1GroupSizeActivity_references.csv` lists 185 cited works (`ref_key` exactly as printed, one row per printed form; `cited_in_column` = the CSV column, or `caption` for works named in a header or note row). 20 have their entry verbatim from `Grabowski_SB_Data_File_References.docx` or the article's reference list; the others have none printed (citation left empty, never invented; the note says why). Cells keep their printed text; multi-citation cells are not split in the CSV (bind with `build_source_match()`, dictionary match on `ref_key`).
ATWP = All the World's Primates (online); HMW = Handbook of the Mammals of the World vol. 3; '07 review' = chapters of Primates in Perspective (2007).

## Table checks
Script section 4 runs 788 checks: 787 pass, 0 mismatch, 1 not evaluable. Results stay in `table_checks`; values are kept as printed.
- **Activity.Period.DN* = Diurnal / Nocturnal from Diurnality (356 checks: 355 pass, 1 not evaluable).** Row 305 (*Eulemur_macaco_macaco*) is not evaluable (Diurnality `n/a`, cached FALSE).
- **Combo Average Group Size* = Group.size.combined when numeric, else Average.Group Size (275 checks: 275 pass)** — note B1 reproduced on every row.
- **Min ≤ Average ≤ Max group size (157 checks: 157 pass).**

## Printed-data observations (reported, not corrected)
- Rows 41 (*Callimico_goeldii*: Foraging.Group.Size.Mean 0, Group.Size.Range 100, Group.size.combined 'two studies', Source 'n/a') and 49 (*Cebus_apella*: Foraging.Group.Size.Mean 'single study', Source.group.size 13.9) look shifted by one column in G-J; kept as printed.
- Source cells carry mojibake (`M‚àö¬©ndez`, `Sch‚àö¬∫lke`) and typos (`MacKinnon 19080`); kept.


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Grabowski_etal_2023_DataFileS1GroupSizeActivity.R to confirm.
