# Powell et al. 2024: SOM Table S1, limb lengths and indices of 1825 anthropoid specimens

Powell, V. C. R., Barr, W. A., Hammond, A. S., & Wood, B. A. (2024). Behavioral and phylogenetic correlates of limb length proportions in extant apes and monkeys: Implications for interpreting hominin fossils. *Journal of Human Evolution*, *190*, 103494. https://doi.org/10.1016/j.jhevol.2024.103494

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **SOM Table S1** → Item name **`Powell_etal_2024_SOMTableS1`**, Item encoded **`10.1016%2Fj.jhevol.2024.103494_SOMTableS1`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`1-s2.0-S0047248424000022-mmc2.xlsx` is the untouched journal SOM workbook (Elsevier mmc2; SOM text = 1-s2.0-S0047248424000022-mmc1.pdf), kept under its original name in `Powell_etal_2024/` (sha256 `29cfee08092ac440661962f1dbd7ae19231b063be0b48592d6fc06ca7b9b647f`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `SOM Table S1`. Row 1 "SOM Table S1 / Complete anthropoid sample included in the current study. A", row 2 the caption (footnote a), row 3 the header (21 columns A-U; `Localityb` carries footnote b, `ID ` a trailing space), rows 4-1828 the 1,825 specimens, row 1829 the abbreviations and footnotes a and b in one cell (dropped). No formulas. The local copy used by the mirror (`src/Powell_2024_mmc2.xlsx`) is byte-identical to the journal file.


## What the data are and how they were produced
One row per adult specimen: genus, species, collection, locality, ID, sex, superfamily, the maximum lengths of femur, tibia, humerus and radius (mm), the Mosimann-adjusted ratios (bone / geometric mean of the four), fore- and hindlimb length and the indices IMI, HFI, BRI, CRI (article Table 3). The SOM text (`1-s2.0-S0047248424000022-mmc1.pdf`) only lists the table ("Complete anthropoid sample included in the current study (provided as a separate Excel file)"); Methods 2.1-2.2 describe the sample: non-human data measured by the first author with calipers, osteometric boards or 3D scans, plus data provided by J.M. Plavcan, C.B. Ruff and M. Tocheri; most human data from the Goldman Osteometric Dataset (Auerbach and Ruff 2004, 2006), the rest measured by the first author in the Terry Collection (NMNH).

**Observation level:** individual specimen. **Data role: both** (abstract: "a mix of newly-collected and published data"). Per row: `GOmD` → secondary (1166 rows, all *Homo sapiens*); `MCZ` → both (156 rows; Table 1 footnote f: "Specimens of the Museum of Comparative Zoology, Harvard, and data from Auerbach and Ruff (2004, 2006)"); all other collections → primary (503).

## Build
`Powell_etal_2024_SOMTableS1.R` (run: `Rscript Powell_etal_2024/Powell_etal_2024_SOMTableS1.R`) reads the frozen file and writes:
- `Powell_etal_2024_SOMTableS1.csv`: 1825 rows × 26 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.1016%2Fj.jhevol.2024.103494_SOMTableS1.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.1016__j.jhevol.2024.103494_SOMTableS1.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Powell_etal_2024_SOMTableS1_definitions.csv` (26 columns + 5 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Powell_etal_2024_SOMTableS1.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** Text trimmed (header `ID `), white space collapsed. `species_as_published` joins the printed Genus and Species with a space (`Gorilla g.gorilla`); the printed Species is kept as `species_epithet`. IDs are written as printed: IDs Excel stored as numbers are written with up to 15 significant digits (they may have lost trailing zeros, e.g. 25.53), and three human IDs look like Excel-converted times (`8:00:04AM`, `8:00:06AM`, `OS.7/2727:54`). Lengths are mm (not printed; Methods 2.2); no conversion.

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Powell_etal_2024`, matched on the lower-cased printed name). This item prints 41 distinct names; 39 accepted names result. The key rows are new: `out/_keys_General_new_rows_Powell_etal_2024.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: verbatim 31, subspecies_assign 5, spelling 4, synonym:NCBI 1. 0 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). No printed name is unresolved. Abbreviated trinomials (`Gorilla g.gorilla`, `Pan t.verus`, ...) roll up to their species (`subspecies_assign`); printed misspellings (`cristata`, `hamadrays`, `chrysomela`, `fuscicolis`) map by `spelling`; `Procolobus badius` → *Piliocolobus badius*. `Cebus apella` stays *Cebus apella* as in the hub (the authors keep Cebus for Sapajus, Table 1 footnote k).

**References.** `reference_tables/Powell_etal_2024_SOMTableS1_references.csv`: the collection code `GOmD` (Goldman Osteometric Dataset) is the only published source printed per row; its entries (Auerbach & Ruff 2004, 2006) are verbatim from the article. The other codes are museum collections, not works.

## Table checks
Script section 4 runs 18411 checks: 18404 pass, 7 mismatch, 0 not evaluable. Results stay in `table_checks`; values are kept as printed.
- **Derived columns from the four lengths, every row:** fl = hum + rad (1825 checks: 1825 pass); hl = fem + tib (1825 checks: 1825 pass); IMI (1825 checks: 1825 pass), HFI (1825 checks: 1825 pass), BRI (1825 checks: 1825 pass), CRI (1825 checks: 1825 pass), tolerance half a unit of the 10th significant digit; gFEM, gTIB, gHUM, gRAD = bone / (fem·tib·hum·rad)^¼ (7300 checks, all pass), tolerance 0.5e-9 (9 printed decimals). All reproduce.
- **Footnote a totals:** n = 1825, Homo 1270, non-Homo Hominoidea 312, Cercopithecoidea 153, Ceboidea 90 (5 checks, all pass).
- **Article Table 1 (males, females, unknown, n per species; 156 checks: 149 pass, 7 mismatch).** Mismatches: Gorilla gorilla n 64 vs 66; Gorilla beringei n 9 vs 7; Trachypithecus cristatus males 0 vs 5; Trachypithecus cristatus females 0 vs 5; Trachypithecus cristatus unknown 10 vs 0; Saguinus oedipus females 2 vs 3; Saguinus oedipus unknown 1 vs 0.

## Printed-data observations (reported, not corrected)
- Table 1 prints *Gorilla gorilla* n = 66 (37 + 27 = 64) and *G. beringei* n = 7 (3 + 4 + 2 = 9); S1 has 64 and 9 (73 gorillas either way). *Trachypithecus cristatus* is 5 m + 5 f in Table 1 but `uk` × 10 in S1; *Saguinus oedipus* has one `u` specimen that Table 1 counts as female.
- Sex code `u` (7 Ceboidea rows) is not in the abbreviation list (only `uk`); both are counted as unknown.
- S1 prints `Procolobus badius`, `lagothricha`, `cristata`, `hamadrays`, `chrysomela`; Table 1 prints *Piliocolobus badius*, `lagotricha`, `cristatus`, `hamadryas`, `chrysomelas` (S2: `Piliocolobus`). Both print `fuscicolis` (= fuscicollis).


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Powell_etal_2024_SOMTableS1.R to confirm.
