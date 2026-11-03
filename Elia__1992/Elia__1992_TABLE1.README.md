# Elia__1992_TABLE1

**Item name** `Elia__1992_TABLE1` · **Item number** `TABLE 1` · **Item encoded** `ISBN%3A9780881678710_TABLE1` — *derived, awaiting registration*
(the item is not yet in `__ReadMe.xlsx`; the code was derived as the registry formula would build it with an ISBN override in column C — `ISBN:9780881678710` percent-encoded, `_`, item locus, the Baron_etal_1996 convention. Paste `Elia__1992_TABLE1_registry_row.xlsx`, run `_tools/file_list.R`, and rename the TSV if the registry resolves a different code.)

Elia, M. (1992). Organ and tissue contribution to metabolic rate. In J. M. Kinney & H. N. Tucker (Eds.), *Energy metabolism: Tissue determinants and cellular corollaries* (pp. 61-79). Raven Press. ISBN 0-88167-871-6 (ISBN-13 978-0-88167-871-0).

**Item full original title:** TABLE 1. Contribution of different organs and tissues to body weight and basal metabolic rate in the reference male, reference female, and a child, p. 63.

## Source

PDF in this folder: `Elia_1992_Organ and Tissue - Energy Metabolism pp61-77.pdf`, COPIED (bytes identical) from the EndNote library (References.Data/PDF/2590466287/). A British Library photocopy of pp. 61-77 (the chapter runs to p. 79/80 in other citations; the copy ends in the discussion on p. 77). TABLE 2 (Korenchevsky % body weight by age) and TABLE 4-5 are not built; TABLE 3 is built as `Elia__1992_TABLE3`.

## Pipeline

```
Source (PDF)
  -> Elia__1992_extract_snapshot.R   writes the frozen snapshots (TABLE1 and TABLE3)
  -> Elia__1992_TABLE1_snapshot.csv   FROZEN: 15 rows x 11 cols
  -> Elia__1992_TABLE1.R   reshape + parse + unit columns + table checks
  -> Elia__1992_TABLE1.csv   24 rows x 24 cols  ("use this")
  -> __Public/comparative-data/ISBN%3A9780881678710_TABLE1.tsv
  -> reference_tables/Elia__1992_TABLE1_definitions.csv, _references.csv, Elia__1992_errata.csv, Elia__1992_species_key_proposed.csv
```

### Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 200-800-dpi renders of PDF pages 3 (TABLE 1, sideways scan) and 6 (TABLE 3), typed as verbatim printed-layout blocks into `Elia__1992_extract_snapshot.R`, which freezes them and refuses to overwrite a differing frozen copy (it also refuses to run outside a UTF-8 locale, because an early run in a C locale had mangled the non-ASCII glyphs `×` and `²`; the frozen files were re-taken in UTF-8 and checked for those glyphs). The PDF is a photocopy scan whose OCR text layer is garbled, so it was not used as a source. The build scripts read the frozen files and contain no table values; they were run with `Rscript` (conda env `evom1-r`, R 4.4.3, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

**Re-verification.** The values were read first from the page images; only afterwards were they compared with the earlier transcription in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (`elia_1992_table3_transcribed.csv`, and the Elia rows of `classic_human_brain_partition.csv`). TABLE 3: all 8 numeric columns x 11 rows agree cell by cell (88 cells, 0 differences; the earlier file left the two cut-off cells blank, as here). TABLE 1: the brain rows agree (1.4 / 1.2 kg, 240 kcal/kg/day, 20 / 21%, 1680 / 1340 kcal/day). New in this build relative to the earlier transcription: the whole of TABLE 1 (all organs, the child column, footnotes a-c), the K x W^x and correlation rows of TABLE 3, and the cut-off/smudge flags.

**Illegible or cut cells (recorded as printed, with a flag).** The right edge of the TABLE 3 scan cuts off the last column: the header reads "All orga" ("All organs minus lung"), the guinea-pig and rat cells show "39." and "17." and then a cut glyph, the K x W^x entry reads "0.448W^" and then a cut glyph, and the correlation reads "0." and then a cut glyph. They are frozen as `39.[cut]`, `17.[cut]`, `0.448W^[cut]`, `0.[cut]`, `All orga ...`, parse to NA, and are **not** completed from arithmetic. TABLE 1 prints the child's weights `0.040`, `1.50` etc. as shown; two yellow scan highlights over the brain cells (2.00 / 2.07 and 20 / 21) are a reader's marks, not print.

### Structure of the snapshot and of the analysis CSV

* One snapshot row per printed row: caption, two header tiers (spanners with blank padding), 8 data rows (the long row label of "Miscellaneous tissues by difference ..." is one cell with real newlines; the Total row's kcal/day sits inside the % cells as printed), and the three footnote rows. Footnote marks are `^a`, `^b`, `^c`; the ASCII hyphen replaces the printed dash in ranges; the word "timed" in footnote b is kept as printed.
* The analysis CSV is **long**: one row per organ x printed subject column (8 x 3 = 24), reading down each organ row. `*_printed` columns keep the cell text; the parsed numbers are beside them. **Observation level: reference man / reference woman / reference child scenarios**, not specimens or species means.
* Project units: `body_mass.g`, `organ_mass.g` (kg x 1000), `Brain_Mass.mg` (kg x 1e6). Energy: `organ_rate.umol_O2_100g_min` and `CMRO2_derived.umol_100g_min` convert kcal/kg/day with 4.9 kcal per litre O2 and 44.64 umol per mL O2 (kcal/kg/day / 70.56 x 44.64); **the 4.9 is the project/Holliday factor, not printed in this chapter**. Brain 240 kcal/kg/day gives 151.8 umol/100 g/min (3.40 mL O2/100 g/min) — a derived estimate, not a CMRO2 measurement.

## Table checks

The table prints its own arithmetic, re-run in the build script (section 7a): weights add to the Total; % of body weight = 100 x weight / Total weight; % of metabolic rate = 100 x weight x organ rate / Total kcal/day (Miscellaneous is the remainder); both % columns add to 100; and footnote b's per-kg and per-FFM values. Result of an actual R run (2026-11-03): **55 pass, 5 mismatch, 0 not evaluable**, of 60 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `pct_body_weight_Reference female_Miscellaneous tissues by difference (e.g., bone, skin, intestines, glands)` | Reference female, Miscellaneous tissues by difference (e.g., bone, skin, intestines, glands): 100 x weight / printed Total weight vs printed % body weight | 32.5603 | 32.58 | -0.0196552 | 0.00586207 | mismatch |
| `pct_metabolic_Child (0.5 y)_Liver` | Child (0.5 y), Liver: 100 x weight x organ rate / printed Total kcal/day vs printed % metabolic rate | 13.4872 | 14 | -0.512821 | 0.5 | mismatch |
| `pct_metabolic_Child (0.5 y)_Heart` | Child (0.5 y), Heart: 100 x weight x organ rate / printed Total kcal/day vs printed % metabolic rate | 4.51282 | 4 | 0.512821 | 0.5 | mismatch |
| `total_kcal_vs_rows_Child (0.5 y)` | Child (0.5 y): sum over rows of weight x organ rate (kcal/day) vs printed Total kcal/day (informational: the printed total is an independent standard-based value, footnote b, not built from the rows; tolerance 5% is a reading aid, not a printed rule) | 332.437 | 390 | -57.563 | 19.5 | mismatch |
| `footnote_b_per_kg_Reference female` | footnote b: printed Total kcal/day / printed Total weight vs the value printed for Reference female (printed unit 'kcal/day', i.e. kcal/kg/day) | 23.1034 | 23.3 | -0.196552 | 0.05 | mismatch |

Reading the 5 mismatches: (1) a printed arithmetic slip, the female Miscellaneous % body weight 32.58 vs 32.56 (errata E001); (2) a printed arithmetic slip in footnote b, 23.3 vs 23.1 kcal/kg/day for the reference female (E002; the unit is also misprinted as kcal/day, E003); (3) the child Liver (13.49 vs 14) and Heart (4.51 vs 4) metabolic % differ from the printed integer by 0.513 against the 0.5 tolerance: a rounding-direction difference, not recorded as an erratum; (4) the child organ weights x rates add to 332.4 kcal/day, not the printed 390 (-14.7%), whereas the male (1687 vs 1680) and female (1328 vs 1340) agree within 1% (E004); the 5% tolerance on this informational check is a reading aid, not a printed rule. **No printed value was changed.**

## Data role

**secondary** (a compilation). Sources of the numbers: tissue/organ weights of the reference male/female from reference 2 (ICRP 23, Snyder et al. 1975), of the 0.5-year-old child from refs 2, 7, 8, 9 (footnote a); organ metabolic rates (Liver 200, Brain 240, Heart and Kidneys 440, Muscle 13, Adipose tissue 4.5, Miscellaneous 12 kcal/kg/day) are Elia's synthesis of in vivo arteriovenous studies — the table prints no per-organ citation for them (footnote c cites refs 10-13 only for the 25-32% liver share). The print gives only these keys, so `ref_key` carries the footnote-a weight sources (`"2"`, `"2; 7; 8; 9"`); `reference_tables/Elia__1992_TABLE1_references.csv` holds the verbatim bibliography entries (refs 2, 7-9, 10-13) for the lookup (split `ref_key` on `"; "`, join on `ref_key`). These are a roadmap to the primaries; **not merged** into `__merging_cerebral_metabolic_rate` (nothing in that folder was touched).

## Species names

The table prints no species; `species_as_published` carries the column heading (Reference male / Reference female / Child (0.5 y)); all three map to Homo sapiens. **No `_keys/` file was edited**; the rows are proposed in `reference_tables/Elia__1992_species_key_proposed.csv` (collection `General`, 7-column schema), and the build script stops if its key filter returns no rows.

## Printed-vs-recomputed discrepancies (summary)

Female Miscellaneous % body weight (printed 32.58, recomputed 32.56); footnote b reference-female per-kg (23.3 vs 23.1); child column total (390 printed vs 332.4 from rows); everything else within rounding. Full list in `reference_tables/Elia__1992_errata.csv`.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to lay the snapshot beside p. 63 (rotate the scan), read a few rows across, and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Elia__1992_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Elia__1992-E001 | pct_body_weight | TABLE 1 p. 63, row 'Miscellaneous tissues by difference', column '% body weight' Reference female | 32.58 |  | publication_error | 32.56 | proposed | 18.885 kg / 58 kg = 32.560% (table_checks pct_body_weight_Reference female_Miscellaneous...: diff -0.0197 vs tolerance 0.0059). The cell was re-read at 300-400 dpi. The other 20 cells of the block reproduce within rounding, and the column of printed values sums to 100.00 only because 32.58 is used. | CSV keeps the printed 32.58. |
| Elia__1992-E002 | * | TABLE 1 footnote b p. 63: "the values are 24.0, 23.3, and 52.0 kcal/day", Reference female value | 23.3 |  | publication_error | 23.1 | proposed | 1340 kcal/day / 58 kg = 23.10 (table_checks footnote_b_per_kg_Reference female: diff -0.197 vs tolerance 0.05); male 1680/70 = 24.0 and child 390/7.5 = 52.0 reproduce exactly. | Footnote text lives in the snapshot only; no CSV column carries it. |
| Elia__1992-E003 | * | TABLE 1 footnote b p. 63, unit of the three per-body-weight values | kcal/day |  | publication_ambiguity | kcal/kg/day | proposed | The three values (24.0, 23.3, 52.0) are kcal per kg body weight per day (1680/70 = 24.0; 390/7.5 = 52.0); the print says "kcal/day" for them while the FFM values in the same footnote read "kcal/kg fat-free mass/day". | Kept as printed in the snapshot. |
| Elia__1992-E004 | metabolic_pct_total | TABLE 1 p. 63, column 'Metabolic rate (% total)' Child (0.5 y), all rows | 14; 44; 4; 6; 6; 2; 24 |  | publication_ambiguity |  | proposed | Weight x organ rate for the child rows sums to 332.4 kcal/day, against the printed total of 390 kcal/day (table_checks total_kcal_vs_rows_Child (0.5 y): diff -57.6). The printed percentages (14, 44, 4, 6, 6, 2) are share of 390 for the six named organs (Liver 13.5, Heart 4.5, which round the other way at 0.513 > 0.5), Miscellaneous (24) is the remainder. The child column is therefore internally consistent only through the by-difference row. | The same test for the reference male (1687 vs 1680) and female (1328 vs 1340) is within 1%. |

4 recorded, 4 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
