# Grabowski et al. 2023: Data File S1, social and mating system (177 species rows)

**Current build status (2026-11-23):** This item is registered in `__ReadMe.xlsx`. `Rscript --vanilla Grabowski_etal_2023/Grabowski_etal_2023_DataFileS1Sociality.R` ran successfully, reproduced the existing analysis CSV and public TSV byte for byte, and passed all eight required file/registry checks. Table checks: 354 pass, 1 printed mismatch. The priority 1 Püschel source trace is in the restricted comparison folder; it does not authorize a merge. Earlier preparation notes below describe the 2026-11-10 state.


Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect primate brain-size evolution. *Systematic Biology*, *72*(2), 404–418. https://doi.org/10.1093/sysbio/syac075

Data: Dryad, https://doi.org/10.5061/dryad.2547d7wpg (Data File S1).

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **Data File S1 Sociality** → Item name **`Grabowski_etal_2023_DataFileS1Sociality`**, Item encoded **`10.5061%2Fdryad.2547d7wpg_DataFileS1Sociality`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`Grabowski_SB_Data_File_S1.xlsx` is the untouched Dryad Data File S1 (https://doi.org/10.5061/dryad.2547d7wpg), kept under its original name in `Grabowski_etal_2023/` (sha256 `3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `Sociality Data`. Row 1 holds group notes (A1 "Social System Data - species in green are from DeCasien et al. (2017), species in light brown are new additions. ...", E1 'Social System Sources', L1, M1, O1, R1 'Mating System Sources', T1 key "UM: Unimale; MM: Multimale; Mon: Monogamous", W1); row 2 the header (27 columns A-AA, three of them 'Notes'); rows 3-179 the 177 species rows; row 180 the colour legend (dropped).

**Formulas — cached values.** Columns M and O (354 cells) are formulas recoding Social.System; all cached at build, none an error.


## What the data are
Per species: the social system given by six sources (`ss_*`: Shultz and Dunbar 2007; Sawaguchi et al. 1990; Shultz et al. 2011; Ford 1994; MacLean et al. 2009; Mittermeier et al. 2013 with page), the DeCasien et al. (2017) four-way social system (`social_system`), its recodes used in the analysis (`social_system_drclass`*: Solitary / Pair / UMMF / MMMF; `social_system_dgt`*: Solitary / Pair / Group), the mating system given by five sources (`ms_*`) and the DeCasien-style five-way mating system (`mating_system`*), with notes. `addition_to_decasien_2017` = Y marks the species the authors added.

**Observation level:** species. **Data role: secondary** (codes compiled from the sources named in the headers; the recodes are the authors' coding).

## Build
`Grabowski_etal_2023_DataFileS1Sociality.R` (run: `Rscript Grabowski_etal_2023/Grabowski_etal_2023_DataFileS1Sociality.R`) reads the frozen file and writes:
- `Grabowski_etal_2023_DataFileS1Sociality.csv`: 177 rows × 30 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.5061%2Fdryad.2547d7wpg_DataFileS1Sociality.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.5061__dryad.2547d7wpg_DataFileS1Sociality.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Grabowski_etal_2023_DataFileS1Sociality_definitions.csv` (30 columns + 7 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Grabowski_etal_2023_DataFileS1Sociality.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** Codes trimmed (the sheet pads them: `' Harem '` → `Harem`), white space collapsed, `n/a` → blank; codes otherwise as printed. Column Z `Social.Grouping` is `n/a` on all rows and is not written (its notes column AA is kept as `notes_social_grouping`). Source columns are named `ss_<source>` / `ms_<source>`; the printed headers are in the definitions.

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Grabowski_etal_2023`, matched on the lower-cased printed name). This item prints 177 distinct names; 176 accepted names result. The key rows are new: `out/_keys_General_new_rows_Grabowski_etal_2023.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: verbatim 169, synonym:NCBI 6, author_judgment 1, subspecies_assign 1. 6 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). No printed name is unresolved. 

**References.** `reference_tables/Grabowski_etal_2023_DataFileS1Sociality_references.csv` lists 30 cited works (`ref_key` exactly as printed, one row per printed form; `cited_in_column` = the CSV column, or `caption` for works named in a header or note row). 16 have their entry verbatim from `Grabowski_SB_Data_File_References.docx` or the article's reference list; the others have none printed (citation left empty, never invented; the note says why). Cells keep their printed text; multi-citation cells are not split in the CSV (bind with `build_source_match()`, dictionary match on `ref_key`).
Here the sources are mostly named in the column headers (`caption`).

## Table checks
Script section 4 runs 355 checks: 354 pass, 1 mismatch, 0 not evaluable. Results stay in `table_checks`; values are kept as printed.
- **Social.System.Drclass* = recode of Social.System (177 checks: 177 pass)** (Solitary, Pair, Polygynandry → MMMF, Polygyny → UMMF; row 3's copy of the formula would print 'UM' for Polygyny, but row 3 is Polygynandry).
- **Social.System.DGT* = Solitary / Pair / Group (177 checks: 177 pass).**
- **Methods: "supplementing their published dataset with 32 additional species" (1 check, mismatch):** 35 rows are marked Y.

## Printed-data observations (reported, not corrected)
- 35 additions marked vs 32 in the Methods.
- The green / light-brown fill of column A repeats column D.


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Grabowski_etal_2023_DataFileS1Sociality.R to confirm.
