# Grabowski et al. 2023: Data File S1, brain and body size (239 species rows)

Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect primate brain-size evolution. *Systematic Biology*, *72*(2), 404–418. https://doi.org/10.1093/sysbio/syac075

Data: Dryad, https://doi.org/10.5061/dryad.2547d7wpg (Data File S1).

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **Data File S1 Brain Body** → Item name **`Grabowski_etal_2023_DataFileS1BrainBody`**, Item encoded **`10.5061%2Fdryad.2547d7wpg_DataFileS1BrainBody`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`Grabowski_SB_Data_File_S1.xlsx` is the untouched Dryad Data File S1 (https://doi.org/10.5061/dryad.2547d7wpg), kept under its original name in `Grabowski_etal_2023/` (sha256 `3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `Prmate Brain Body Means ME Data` (name as printed), title row 1 "Primate Species Average Endocranial Volume (cc^3) and Body Mass (g), with sample sizes and measurement error". Rows 1-3 (title, description with the AB2/AC2 notes, header) are not data; rows 4-242 are the 239 species rows; there are no blank or footnote rows and no formulas in this sheet.


## What the data are
One row is one species as printed: endocranial volume (ECV, cc) and body mass (g) means of males, females and the species, with their sample sizes, the taxonomy (order to species group), how the ECV species mean was computed (`m/f` = mean of the sex means; `ind` = mean of all individuals), the printed sources, and the predicted log measurement-error variances of the two species means (computed as in Grabowski et al. 2016). Columns printed with `*` (green) were used in the main analysis: ECV.species.mean, N.species, Body.mass.species.mean, N.body.mass.species and the two error columns.

**Observation level:** species (means). **Data role: secondary** — ECV and body mass come from Isler et al. (2008) and the works printed in `source_of_ecv` / `source_of_body_mass`; the error variances are model inputs, not trait values.

## Build
`Grabowski_etal_2023_DataFileS1BrainBody.R` (run: `Rscript Grabowski_etal_2023/Grabowski_etal_2023_DataFileS1BrainBody.R`) reads the frozen file and writes:
- `Grabowski_etal_2023_DataFileS1BrainBody.csv`: 239 rows × 35 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.5061%2Fdryad.2547d7wpg_DataFileS1BrainBody.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.5061__dryad.2547d7wpg_DataFileS1BrainBody.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Grabowski_etal_2023_DataFileS1BrainBody_definitions.csv` (35 columns + 6 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Grabowski_etal_2023_DataFileS1BrainBody.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** Text is trimmed and runs of white space collapsed; `n/a` → blank; nothing else changes (names, codes, citations verbatim, including `Schülke`). Column L `Subspecies` is `n/a` on every row and is not written (the script stops if it ever holds a value). Units: printed ECV columns kept in cc and project-unit columns added (`*_mm3` = cc × 1000); body mass is already in g. Counts are written as integers (the script stops on a non-integer count).

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Grabowski_etal_2023`, matched on the lower-cased printed name). This item prints 239 distinct names; 231 accepted names result. The key rows are new: `out/_keys_General_new_rows_Grabowski_etal_2023.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: verbatim 211, synonym:NCBI 10, our_judgment 8, unresolved 4, subspecies_assign 3, author_judgment 3. 38 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). 4 printed names are unresolved (blank `Species`, 4 rows): `Cheirogaleus_adipicaudatus`, `Euoticus_pallidus`, `Piliocolobus_tholloni_and_foai`, `Presbytis_natunae`. Printed names keep their underscore (`Alouatta_belzebul`).

**References.** `reference_tables/Grabowski_etal_2023_DataFileS1BrainBody_references.csv` lists 33 cited works (`ref_key` exactly as printed, one row per printed form; `cited_in_column` = the CSV column, or `caption` for works named in a header or note row). 6 have their entry verbatim from `Grabowski_SB_Data_File_References.docx` or the article's reference list; the others have none printed (citation left empty, never invented; the note says why). Cells keep their printed text; multi-citation cells are not split in the CSV (bind with `build_source_match()`, dictionary match on `ref_key`).

## Table checks
Script section 4 runs 810 checks: 771 pass, 10 mismatch, 29 not evaluable. Results stay in `table_checks` (never written to the CSV/TSV); values are kept as printed.
- **ECV species mean = (male + female mean) / 2 for `m/f` (147 checks: 145 pass, 2 mismatch).** Tolerance 0.01 (two printed decimals). Mismatches: *Macaca nigra* (row 148) prints 94.9 vs 87.25 and *Macaca sylvanus* (row 153) 93.2 vs 92.715 — both rows say the species mean is from Harvey and Clutton-Brock 1985.
- **ECV species mean = N-weighted mean of the sex means for `ind` (49 checks: 18 pass, 2 mismatch, 29 not evaluable).** Evaluable only when every individual is sexed (N.species = N.male + N.female); the 29 other `ind` rows include unsexed individuals (or, for *Galago_demidoff*, an N.species below the sum). Mismatches: *Lepilemur ruficaudatus* (row 135) 8.25 vs 7.75 (n = 1 + 1) and *Otolemur garnettii* (row 166) 11.5 vs 10.85.
- **N.species vs N.male + N.female (194 checks: 193 pass, 1 mismatch):** equal for `m/f`, at least the sum for `ind`. *Galago_demidoff* (row 103) prints N.species 25 with 25 males and 38 females.
- **Body mass species mean = (male + female) / 2 (211 checks: 209 pass, 2 mismatch)**, tolerance 0.5 g. *Cercopithecus neglectus* (row 70) 5450 vs 5740; *Macaca fuscata* (row 144) 9515 vs 9500.
- **N.body.mass.species = male + female N (206 checks: 206 pass).**
- **Methods totals (3 checks, not reproducible):** the Methods give "183 primate species based on 3506 individual observations for brain size and 6608 ... for body mass", each species mean with at least one male and one female. The sheet does not flag that set: species with ≥ 1 male and ≥ 1 female ECV number 196, with 4031 brain and 7385 body-mass observations.

## Printed-data observations (reported, not corrected)
- Three body-mass cells cite a personal communication (Pastorini 2007, printed in three spellings).
- `source_of_body_mass` is `n/a` on 10 rows; `calculation_of_ecv_species_mean` on 15.
- Genus-level and composite printed names (`Piliocolobus_tholloni_and_foai`) are kept as printed; see Species.


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Grabowski_etal_2023_DataFileS1BrainBody.R to confirm.
