# Elia__1992_TABLE3

**Item name** `Elia__1992_TABLE3` · **Item number** `TABLE 3` · **Item encoded** `ISBN%3A9780881678710_TABLE3` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx`; code derived as the registry formula builds it with the ISBN override in column C. Paste `Elia__1992_TABLE3_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Elia, M. (1992). Organ and tissue contribution to metabolic rate. In J. M. Kinney & H. N. Tucker (Eds.), *Energy metabolism: Tissue determinants and cellular corollaries* (pp. 61-79). Raven Press. ISBN 0-88167-871-6 (ISBN-13 978-0-88167-871-0).

**Item full original title:** TABLE 3. Relation of organ weight to body weight (organ weight = K x body weight^x) in approximately mature mammals, p. 66. Footnote a: "Calculated using data from Brody (17)" (Brody 1945, *Bioenergetics and Growth*).

## Source

PDF in this folder: `Elia_1992_Organ and Tissue - Energy Metabolism pp61-77.pdf`, COPIED (bytes identical) from the EndNote library (References.Data/PDF/2590466287/). The same PDF serves `Elia__1992_TABLE1`.

## Pipeline

```
Source (PDF)
  -> Elia__1992_extract_snapshot.R   writes the frozen snapshots (TABLE1 and TABLE3)
  -> Elia__1992_TABLE3_snapshot.csv   FROZEN: 19 rows x 9 cols
  -> Elia__1992_TABLE3.R   parse + unit column + table checks (sums, power-law refits)
  -> Elia__1992_TABLE3.csv   11 rows x 17 cols  ("use this")
  -> reference_tables/Elia__1992_TABLE3_allometry_as_printed.csv   (printed K x W^x and r rows)
  -> __Public/comparative-data/ISBN%3A9780881678710_TABLE3.tsv
  -> reference_tables/Elia__1992_TABLE3_definitions.csv, _references.csv, Elia__1992_errata.csv, Elia__1992_species_key_proposed.csv
```

### Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 200-800-dpi renders of PDF pages 3 (TABLE 1, sideways scan) and 6 (TABLE 3), typed as verbatim printed-layout blocks into `Elia__1992_extract_snapshot.R`, which freezes them and refuses to overwrite a differing frozen copy (it also refuses to run outside a UTF-8 locale, because an early run in a C locale had mangled the non-ASCII glyphs `×` and `²`; the frozen files were re-taken in UTF-8 and checked for those glyphs). The PDF is a photocopy scan whose OCR text layer is garbled, so it was not used as a source. The build scripts read the frozen files and contain no table values; they were run with `Rscript` (conda env `evom1-r`, R 4.4.3, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

**Re-verification.** The values were read first from the page images; only afterwards were they compared with the earlier transcription in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (`elia_1992_table3_transcribed.csv`, and the Elia rows of `classic_human_brain_partition.csv`). TABLE 3: all 8 numeric columns x 11 rows agree cell by cell (88 cells, 0 differences; the earlier file left the two cut-off cells blank, as here). TABLE 1: the brain rows agree (1.4 / 1.2 kg, 240 kcal/kg/day, 20 / 21%, 1680 / 1340 kcal/day). New in this build relative to the earlier transcription: the whole of TABLE 1 (all organs, the child column, footnotes a-c), the K x W^x and correlation rows of TABLE 3, and the cut-off/smudge flags.

**Illegible or cut cells (recorded as printed, with a flag).** The right edge of the TABLE 3 scan cuts off the last column: the header reads "All orga" ("All organs minus lung"), the guinea-pig and rat cells show "39." and "17." and then a cut glyph, the K x W^x entry reads "0.448W^" and then a cut glyph, and the correlation reads "0." and then a cut glyph. They are frozen as `39.[cut]`, `17.[cut]`, `0.448W^[cut]`, `0.[cut]`, `All orga ...`, parse to NA, and are **not** completed from arithmetic. TABLE 1 prints the child's weights `0.040`, `1.50` etc. as shown; two yellow scan highlights over the brain cells (2.00 / 2.07 and 20 / 21) are a reader's marks, not print.

### Structure of the snapshot and of the analysis CSV

* One snapshot row per printed row: caption, header, 11 animal rows in printed order (Elephant, Steer, Horse, Dairy cow, Hog, Human, Sheep, Dog, Monkey, Guinea pig, Rat), the printed gap row, the `KW^x,b` and `Correlation coefficient` rows, two footnote rows.
* The analysis CSV is **wide, one row per printed animal** (11). Weights are kept in g as printed; `Brain_Mass.mg` = brain g x 1000 (project unit). The elephant lung `(6,650)` is printed in parentheses with no explanation: parsed as 6650 and flagged in `lung_in_parentheses` (E012). `all_minus_lung_as_printed` carries the two cut-off cells verbatim. **Observation level: one representative approximately mature animal per row (Brody 1945), no n, no dispersion.**
* The printed power laws and correlations are written to `reference_tables/Elia__1992_TABLE3_allometry_as_printed.csv` (values as printed, last column NA because cut off).

## Table checks

Re-run in the build script (section 7a): for each animal, liver + kidneys + brain + heart + lung against the printed "All 5 organs" and the four non-lung organs against "All organs minus lung" (tolerance: half a unit of every summed cell's last decimal); and the six printed power laws re-fitted by OLS on the printed rows (exponent and r within rounding; the constant K within 5% relative, a reading aid). Result of an actual R run (2026-11-03): **30 pass, 9 mismatch, 2 not evaluable**, of 41 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `all5_sum_Horse` | Horse: liver + kidneys + brain + heart + lung vs printed 'All 5 organs' | 18620 | 13220 | 5400 | 2.5 | mismatch |
| `minus_lung_sum_Horse` | Horse: liver + kidneys + brain + heart vs printed 'All organs minus lung' | 13220 | 18620 | -5400 | 2 | mismatch |
| `all5_sum_Dairy cow` | Dairy cow: liver + kidneys + brain + heart + lung vs printed 'All 5 organs' | 13500 | 13440 | 60 | 2.5 | mismatch |
| `minus_lung_sum_Dairy cow` | Dairy cow: liver + kidneys + brain + heart vs printed 'All organs minus lung' | 9900 | 9840 | 60 | 2 | mismatch |
| `all5_sum_Hog` | Hog: liver + kidneys + brain + heart + lung vs printed 'All 5 organs' | 3630 | 3530 | 100 | 2.5 | mismatch |
| `minus_lung_sum_Hog` | Hog: liver + kidneys + brain + heart vs printed 'All organs minus lung' | 2330 | 2230 | 100 | 2 | mismatch |
| `minus_lung_sum_Guinea pig` | Guinea pig: liver + kidneys + brain + heart vs printed 'All organs minus lung' | 39.6 | NA | NA | 0.65 | not_evaluable |
| `minus_lung_sum_Rat` | Rat: liver + kidneys + brain + heart vs printed 'All organs minus lung' | 17.04 | NA | NA | 0.605 | not_evaluable |
| `columns_swapped_rows` | rows in which the printed 'All 5 organs' equals the 4-organ sum and the printed 'All organs minus lung' equals the 5-organ sum (the two printed columns swapped); observed = count | 1 | 0 | 1 | 0 | mismatch |
| `refit_K_brain` | brain: OLS constant K from the same fit vs printed K (relative difference, observed - printed relative to printed) | -0.913932 | 0 | -0.913932 | 0.05 | mismatch |
| `refit_K_heart` | heart: OLS constant K from the same fit vs printed K (relative difference, observed - printed relative to printed) | -0.559702 | 0 | -0.559702 | 0.05 | mismatch |

Reading the mismatches: **Horse: the two sum columns are swapped as printed** (13,220 is the 4-organ sum, 18,620 the 5-organ sum; E005, E013); **Dairy cow** (13,440 vs 13,500; 9,840 vs 9,900) and **Hog** (3,530 vs 3,630; 2,230 vs 2,330) are off by 60 g and 100 g in both columns (E006-E009); the guinea pig and rat "minus lung" cells are cut off at the scan edge, so only the recomputed 39.6 and 17.04 are shown as observed; the K constants printed for **Brain (0.76)** and **Heart (0.03)** do not reproduce from the table's own rows (refits 0.0654 and 0.0132), although their exponents (0.71, 0.88) and r do (E010, E011). **No printed value was changed**; `columns_swapped_rows` is a pointer to the Horse row, not an independent mismatch.

## Data role

**secondary** (values "calculated using data from Brody (17)"). The only citation is footnote a; `ref_key` = `17` on every row and `reference_tables/Elia__1992_TABLE3_references.csv` holds the verbatim bibliography entry. Brody (1945) is the primary to ingest, not this table. **Not merged**; nothing in `__merging_cerebral_metabolic_rate` was touched. Human row: 60,000 g body, 1,300 g brain (2.17% of body mass).

## Species names

The table prints common names only. `species_as_published` keeps them; `species` is from the proposed key rows in `reference_tables/Elia__1992_species_key_proposed.csv` (collection `General`; **no `_keys/` file was edited**): Steer and Dairy cow -> Bos taurus; Hog -> Sus scrofa domesticus; Horse, Human, Sheep, Dog, Guinea pig -> Equus caballus, Homo sapiens, Ovis aries, Canis lupus familiaris, Cavia porcellus; **Elephant, Monkey and Rat stay unspecified** ("Elephant (species unspecified)", "Monkey (species unspecified)", "Rattus sp.") because the table does not say which species. The build script stops if the key filter returns no rows.

## Printed-vs-recomputed discrepancies (summary)

Horse swapped columns; Dairy cow and Hog sums low by 60/100 g; two K constants (Brain, Heart) not reproducible from the printed rows; two cut-off cells. Full list: `reference_tables/Elia__1992_errata.csv`.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside p. 66, read a few rows across, and record `DDMMYYYY_initials` in the registry column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Elia__1992_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Elia__1992-E005 | all5_printed.g | TABLE 3 p. 66, row Horse, column 'All 5 organs' | 13,220 | 13220 | publication_error | 18,620 | proposed | Liver 6,700 + kidneys 1,600 + brain 670 + heart 4,250 = 13,220 (4 organs); + lung 5,400 = 18,620 (5 organs). The two printed values sit in each other's columns (columns swapped as printed). | Task note: horse columns swapped as printed. CSV keeps the printed positions. |
| Elia__1992-E006 | all5_printed.g | TABLE 3 p. 66, row Dairy cow, column 'All 5 organs' | 13,440 | 13440 | publication_error | 13,500 | proposed | 6,460 + 1,160 + 400 + 1,880 + 3,600 = 13,500 (table_checks all5_sum_Dairy cow: diff 60). |  |
| Elia__1992-E007 | all_minus_lung_printed.g | TABLE 3 p. 66, row Dairy cow, column 'All organs minus lung' | 9,840 | 9840 | publication_error | 9,900 | proposed | 6,460 + 1,160 + 400 + 1,880 = 9,900 (diff 60). | Both Dairy cow cells are 60 g low; the same 60 g. |
| Elia__1992-E008 | all5_printed.g | TABLE 3 p. 66, row Hog, column 'All 5 organs' | 3,530 | 3530 | publication_error | 3,630 | proposed | 1,600 + 260 + 120 + 350 + 1,300 = 3,630 (table_checks all5_sum_Hog: diff 100). |  |
| Elia__1992-E009 | all_minus_lung_printed.g | TABLE 3 p. 66, row Hog, column 'All organs minus lung' | 2,230 | 2230 | publication_error | 2,330 | proposed | 1,600 + 260 + 120 + 350 = 2,330 (diff 100). | Both Hog cells are 100 g low. |
| Elia__1992-E010 | * | TABLE 3 p. 66, row 'KW^x,b', column Brain: constant K of the printed power law | 0.76W^0.71 |  | publication_ambiguity |  | proposed | OLS fit of log brain g on log body g over the 11 printed rows gives exponent 0.708 (printed 0.71 reproduces) but K = 0.0654, not 0.76 (table_checks refit_K_brain: relative diff -0.91; r = 0.936, printed 0.94 reproduces). 0.76 is 11.6 x the refit K; the printed constant is probably a misprint or comes from Brody's wider data. Re-read at 700-800 dpi: "0.76W" is what is printed. | The K x W^x row is in reference_tables/Elia__1992_TABLE3_allometry_as_printed.csv, printed values kept. |
| Elia__1992-E011 | * | TABLE 3 p. 66, row 'KW^x,b', column Heart: constant K of the printed power law | 0.03W^0.88 |  | publication_ambiguity |  | proposed | Refit of the 11 printed rows: exponent 0.878 (printed 0.88 reproduces), K = 0.0132 (printed 0.03; table_checks refit_K_heart relative diff -0.56). A K of 0.013 would reproduce; "0.03" is the printed text. |  |
| Elia__1992-E012 | lung_mass.g | TABLE 3 p. 66, row Elephant, column Lung | (6,650) | 6650 | publication_ambiguity |  | proposed | The value is printed in parentheses, unlike every other cell; no footnote explains it. 6,650 g = 0.1% of the printed live weight and it enters the elephant's All-5 sum (22,050) without contradiction, so it is parsed as 6650 and flagged. |  |
| Elia__1992-E013 | all_minus_lung_printed.g | TABLE 3 p. 66, row Horse, column 'All organs minus lung' | 18,620 | 18620 | publication_error | 13,220 | proposed | Liver 6,700 + kidneys 1,600 + brain 670 + heart 4,250 = 13,220 (4 organs); + lung 5,400 = 18,620 (5 organs). The two printed values sit in each other's columns (columns swapped as printed). | Partner cell of E005: the two Horse sum cells sit in each other's columns (swapped as printed). CSV keeps the printed positions. |

9 recorded, 9 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
