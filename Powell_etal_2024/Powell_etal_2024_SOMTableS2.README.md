# Powell et al. 2024: SOM Table S2, descriptive statistics of limb lengths by genus (108 rows)

Powell, V. C. R., Barr, W. A., Hammond, A. S., & Wood, B. A. (2024). Behavioral and phylogenetic correlates of limb length proportions in extant apes and monkeys: Implications for interpreting hominin fossils. *Journal of Human Evolution*, *190*, 103494. https://doi.org/10.1016/j.jhevol.2024.103494

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **SOM Table S2** → Item name **`Powell_etal_2024_SOMTableS2`**, Item encoded **`10.1016%2Fj.jhevol.2024.103494_SOMTableS2`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`1-s2.0-S0047248424000022-mmc2.xlsx` is the untouched journal SOM workbook (Elsevier mmc2; SOM text = 1-s2.0-S0047248424000022-mmc1.pdf), kept under its original name in `Powell_etal_2024/` (sha256 `29cfee08092ac440661962f1dbd7ae19231b063be0b48592d6fc06ca7b9b647f`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `SOM Table S2`. Row 1 "SOM Table S2", row 2 "Descriptive Statistics for anthropoid genera in this study.", row 3 the header (10 columns A-J; A printed `Genus`), rows 4-138 = 27 blocks (a heading row with the taxon, then fem, tib, hum, rad), row 139 abbreviations and "Descriptive statistics for the unscaled measurements of all genera sampled." (dropped). No formulas; values stored to about 15 significant digits. The heading rows are not written as rows: their taxon is `species_as_published` of the four rows below.


## What the data are and how they were produced
One row per taxon (26 genera and *Homo sapiens*) × bone: n, minimum, maximum, range, mean, variance, coefficient of variation, standard error and SD of the unscaled maximum length. Methods 2.1: "Descriptive statistics are provided at the genus level in SOM Table S2"; the SOM text only lists the table. Recomputing every value from the SOM Table S1 specimens reproduces them all (table checks): variance and SD with n − 1, standard error = SD/√n, coefficient of variation = SD / mean (a fraction, not %).

**Observation level:** taxon × bone (summary statistics; not species values). **Data role: both**; per row, from the pooled S1 specimens: 18 taxa primary, 9 both, 0 secondary.

## Build
`Powell_etal_2024_SOMTableS2.R` (run: `Rscript Powell_etal_2024/Powell_etal_2024_SOMTableS2.R`) reads the frozen file and writes:
- `Powell_etal_2024_SOMTableS2.csv`: 108 rows × 15 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.1016%2Fj.jhevol.2024.103494_SOMTableS2.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.1016__j.jhevol.2024.103494_SOMTableS2.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Powell_etal_2024_SOMTableS2_definitions.csv` (15 columns + 5 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Powell_etal_2024_SOMTableS2.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** Text trimmed; nothing else changes. `n` is written as an integer. Lengths in mm (as S1), variance mm².

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Powell_etal_2024`, matched on the lower-cased printed name). This item prints 27 distinct names; 27 accepted names result. The key rows are new: `out/_keys_General_new_rows_Powell_etal_2024.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: our_judgment 25, verbatim 1, spelling 1. 13 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). No printed name is unresolved. Genus headings map to the General key's genus anchors (`Pan` → `Pan sp.`, basis our_judgment: statistics pool the genus); `Aloutta` (printed) → `Alouatta sp.` (spelling); `Homo sapiens` verbatim.

**References.** No per-row sources are printed: no references file (S1's references file covers the GOmD specimens pooled here).

## Table checks
Script section 5 recomputes every statistic from SOM Table S1: 972 checks: 972 pass, 0 mismatch, 0 not evaluable. n, minimum and maximum exact; the others within 1e-9 (relative). Blocks pool the S1 rows by printed genus (`Homo sapiens` by genus + species); `Aloutta` and `Piliocolobus` (S1 prints `Procolobus badius`) are matched through the accepted genus; `Cebus` pools *C. albifrons* and *C. apella* (Table 1 footnote k).

## Printed-data observations (reported, not corrected)
- The heading column is printed `Genus` but the first block is `Homo sapiens`; `Aloutta` is misspelt.


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Powell_etal_2024_SOMTableS2.R to confirm.
