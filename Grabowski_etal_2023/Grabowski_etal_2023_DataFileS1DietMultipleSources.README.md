# Grabowski et al. 2023: Data File S1, diet from multiple sources (48 rows, 13 species)

Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect primate brain-size evolution. *Systematic Biology*, *72*(2), 404–418. https://doi.org/10.1093/sysbio/syac075

Data: Dryad, https://doi.org/10.5061/dryad.2547d7wpg (Data File S1).

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **Data File S1 Diet Multiple Sources** → Item name **`Grabowski_etal_2023_DataFileS1DietMultipleSources`**, Item encoded **`10.5061%2Fdryad.2547d7wpg_DataFileS1DietMultipleSources`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`Grabowski_SB_Data_File_S1.xlsx` is the untouched Dryad Data File S1 (https://doi.org/10.5061/dryad.2547d7wpg), kept under its original name in `Grabowski_etal_2023/` (sha256 `3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `Diet Data - Multiple Sources`, title A1 "Percentage Average Diet Data when Multiple Sources with Sample Sizes (individuals per study group) are Available. Spaces in rows separate species groups." Row 2 is the header (19 named columns A-S and an unnamed column T). Rows 3-63 hold 48 data rows in 13 blocks separated by 13 blank rows (6, 10, 15, 20, 26, 30, 35, 40, 45, 49, 53, 58, 59; dropped); row 64 is the footnote `* Max sizes when variation is reported` (for `N*`; dropped).

**Formulas — cached values.** The 143 cells of the average rows are Excel formulas; `readxl` returns their cached values. All were cached at build; F39, E57 and F57 are cached `#VALUE!` (a source prints `n/a`) and are blank in the CSV.


## What the data are
Each block is one species: one row per source (study group, population, season or month, with its N = individuals per group) and a last row with the block's average (`row_role` = `average`; N = sum of the sources; percentages = N-weighted means; *Propithecus verreauxi* uses a plain AVERAGE of equal N). `block` and `row_role` are derived from the layout and checked (the script stops if the average row is not the last of its block). The `notes` cell of an average row lists the unweighted means that sheet 'Diet Data' uses.

**Observation level:** source × species (source rows) or species (average rows) — do not pool the two. **Data role: secondary.**

## Build
`Grabowski_etal_2023_DataFileS1DietMultipleSources.R` (run: `Rscript Grabowski_etal_2023/Grabowski_etal_2023_DataFileS1DietMultipleSources.R`) reads the frozen file and writes:
- `Grabowski_etal_2023_DataFileS1DietMultipleSources.csv`: 48 rows × 21 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.5061%2Fdryad.2547d7wpg_DataFileS1DietMultipleSources.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.5061__dryad.2547d7wpg_DataFileS1DietMultipleSources.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Grabowski_etal_2023_DataFileS1DietMultipleSources_definitions.csv` (21 columns + 7 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Grabowski_etal_2023_DataFileS1DietMultipleSources.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** Text trimmed and white space collapsed, `n/a` → blank. Printed columns N `Roots`, P `Fungus`, Q `Nectar`, R `Buds` and the unnamed T are `n/a` on every data row and are not written (the script stops if one ever holds a value). No unit conversion (percentages; N in individuals).

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Grabowski_etal_2023`, matched on the lower-cased printed name). This item prints 13 distinct names; 13 accepted names result. The key rows are new: `out/_keys_General_new_rows_Grabowski_etal_2023.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: verbatim 11, subspecies_assign 2. 0 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). No printed name is unresolved. 

**References.** `reference_tables/Grabowski_etal_2023_DataFileS1DietMultipleSources_references.csv` lists 23 cited works (`ref_key` exactly as printed, one row per printed form; `cited_in_column` = the CSV column, or `caption` for works named in a header or note row). 13 have their entry verbatim from `Grabowski_SB_Data_File_References.docx` or the article's reference list; the others have none printed (citation left empty, never invented; the note says why). Cells keep their printed text; multi-citation cells are not split in the CSV (bind with `build_source_match()`, dictionary match on `ref_key`).

## Table checks
Script section 4 runs 354 checks: 265 pass, 70 mismatch, 19 not evaluable. Results stay in `table_checks`; values are kept as printed.
- **Average N* = sum of the source N* (13 checks: 13 pass).**
- **Average % = N-weighted mean of the sources (93 checks: 92 pass, 1 not evaluable).** Reproduces every cached formula; not evaluable where a source prints `n/a` (M29: *Pongo abelii* Gum typed 0 with both sources `n/a`).
- **Source rows: Fruit+Seeds = Fruit + Seeds (35 checks: 35 pass); Total Animal = Invertebrates + Vertebrates (21 checks: 21 pass).**
- **Sheet 'Diet Data' vs this sheet (4d).** Diet Data prints an average for these species ("Average of ...", mostly "see Multiple Sources Sheet"). Against the N-weighted average rows: 99 checks: 22 pass, 65 mismatch, 12 not evaluable. Against the unweighted mean of the sources: 93 checks: 82 pass, 5 mismatch, 6 not evaluable — Diet Data uses the unweighted means (as listed in the `notes` of the average rows). The 5 remaining differences: *Propithecus verreauxi* (Diet Data cites Norscia et al. 2006 and Richard 1978 instead; 4 values) and *Eulemur rubriventer* leaves (Diet Data 0.5, unweighted mean 1.0).

## Printed-data observations (reported, not corrected)
- The analysis sheet (Diet Data) does not use this sheet's N-weighted averages (above).
- Only 13 species are here, although 26 Diet Data rows refer to this sheet ("see Multiple Sources Sheet" / "see 2nd Sheet"); 18 of those species have no block here.
- References carry typos (`Agestuma` for Agetsuma; `Whiten et a.l`; `Ménard and Vallet 1996` where the bibliography has 1997).


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Grabowski_etal_2023_DataFileS1DietMultipleSources.R to confirm.
