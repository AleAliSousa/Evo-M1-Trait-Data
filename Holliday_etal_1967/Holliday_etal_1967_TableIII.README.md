# Holliday_etal_1967_TableIII

**Item name** `Holliday_etal_1967_TableIII` · **Item number** `Table III` · **Item encoded** `10.1203%2F00006450-196705000-00005_TableIII` — *derived, awaiting registration*
( Paste `Holliday_etal_1967_TableIII_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Holliday, M. A., Potter, D., Jarrah, A., & Bearg, S. (1967). The relation of metabolic rate to body weight and organ size. *Pediatric Research*, 1(3), 185-195. <https://doi.org/10.1203/00006450-196705000-00005>

**Item full original title:** Table III. Relation of organ weight to body weight in 9 species (Data from BRODY [8]), p. 191.

## Source

PDF in this folder: `Holliday_etal_1967.pdf`. Sibling item `Holliday_etal_1967_TableII` (organ metabolic rates). This table prints organ weights only, no metabolic rate.

## Pipeline

```
Source (PDF)
  -> Holliday_etal_1967_extract_snapshot.R   writes the frozen snapshot(s)
  -> Holliday_etal_1967_TableIII_snapshot.csv   FROZEN: 14 rows x 10 cols
  -> Holliday_etal_1967_TableIII.R   clean + convert units + table checks
  -> Holliday_etal_1967_TableIII.csv   9 rows x 27 cols  ("use this")
  -> __Public/comparative-data/10.1203%2F00006450-196705000-00005_TableIII.tsv
  -> reference_tables/Holliday_etal_1967_TableIII_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-03 from 200-dpi renders of PDF page 7 (journal p. 191), typed as a verbatim printed-layout block into `Holliday_etal_1967_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The PDF is a scanned reprint with **no text layer** (0 characters on all 11 pages), so there is no machine second reading; instead every cell was re-read against the page image and against the earlier working transcription (`holliday_1967_table3_transcribed.csv`, `classic_human_brain_partition.csv`): no cell differs. The build script reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`) on 2026-11-03.

### Snapshot and analysis CSV

* The snapshot keeps the printed layout: species as columns, organs as rows, the spanner rows *Organ weight (g)* and *Body weight (kg)*, the Total row, and the two-line ratio label. Thousands commas (`20,340`, `13,700`) kept.
* The analysis CSV has **one row per species** (9), organ weights in columns; body weight kg -> g and brain g -> mg (project units); `sum_5_organs_g_recomputed` and `organ_pct_body_recomputed` are derived columns, not printed values.
* **Observation level**: typical-animal reference values (Brody 1945), not individuals.


## Table checks

Result of an actual R run (2026-11-03, `Rscript`, conda env `r`): **14 pass, 4 mismatch, 0 not evaluable**, of 18 checks. Rule: rounding of each printed factor (half a unit of its last printed decimal) or, for a percentage recomputed from a printed total, one unit of its last decimal (HOWTO 7a). Every mismatch is kept as printed and explained below; nothing was changed to make a check pass.

Not-pass checks (the passing checks are in the table_checks object of the build and listed by `build_dataset_item()`):

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `total_Hog` | Hog: sum of Brain..Lung vs printed Total (g) | 3870 | 3890 | -20 | 3 | mismatch |
| `ratio_Dog` | Dog: 100 x printed Total / body weight vs printed ratio | 9.4 | 9.44 | -0.04 | 0.01 | mismatch |
| `ratio_Guinea_pig` | Guinea pig: 100 x printed Total / body weight vs printed ratio | 6.275 | 6.25 | 0.025 | 0.01 | mismatch |
| `ratio_Rat` | Rat: 100 x printed Total / body weight vs printed ratio | 8.176 | 8.16 | 0.016 | 0.01 | mismatch |

## Printed-vs-recomputed discrepancies

1. **Hog total**: printed 3890; the five printed organs add to 3870 (E004). The printed ratio (3.12) follows 3890 (3.11), not 3870 (3.10); it is unknown whether the total or an organ weight is misprinted. The other eight totals add up exactly.
2. **Ratio row**: Dog 9.44 vs 9.40 (E005), Guinea pig 6.25 vs 6.28 (E006), Rat 8.16 vs 8.18 (E007) fail the one-unit rule; Hog 3.12 vs 3.11, Sheep 4.56 vs 4.57 and Steer 1.95 vs 1.96 differ by < 0.01 and pass (some look truncated rather than rounded).
3. Not an error of this table but worth a flag: Elia 1992 Table 3 prints a **75 g** dog brain (total 770) where this table prints 175 g (total 940); the 175 is consistent with the printed total, so the discrepancy sits in Elia's transcription of Brody.

## Data role

**secondary** (every value is Brody 1945; the caption cites it for the whole table).

## Species names

`species_as_published` keeps the printed label. Rows for this paper folder were appended to `_keys/General/species_key.csv` (collection General; 2026-11-03, pending owner sign-off) and the build stops if the key returns no rows for the folder. `Monkey` and `Rat` are common labels that the table does not resolve (key: `Monkey (species unspecified)`, `Rattus sp.`); `Hog` -> *Sus scrofa domesticus*, `Steer` -> *Bos taurus*, `Guinea pig` -> *Cavia porcellus*.

## Per-row source citations

`reference_tables/Holliday_etal_1967_TableIII_references.csv`: the only citation is `[8]` Brody (1945), valid for the whole table (`ref_key` = `[8]` on every row). The table prints no per-row or per-species reference; Brody was not checked here.

## Compilation comparison (done AFTER the snapshot was frozen)

The working transcriptions and the cross-source comparison live in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (`CLASSIC_COMPILATIONS_FINDINGS.md`); they were compared with this snapshot only after it was frozen, and no printed value was changed. The merged `__merging_cerebral_metabolic_rate` was not modified. `brody_organ_weights_elia1992_vs_holliday1967.csv` there compares this table with Elia 1992 Table 3.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Holliday_etal_1967_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Holliday_etal_1967-E004 | total_organ_g | Table III p. 191, row Total, column Hog | 3890 |  | publication_error |  | proposed | The five printed Hog organ weights (120 + 350 + 500 + 1600 + 1300) add to 3870, not 3890. The printed ratio 3.12 follows the printed total (3890/125,000 = 3.11); 3870 would give 3.10. It is not known whether the total or one organ weight is misprinted. | Kept as printed; the other eight totals add up. The 1967 working transcription (holliday_1967_table3_transcribed.csv) already carried total_printed 3890, total_sum 3870. |
| Holliday_etal_1967-E005 | organ_pct_body | Table III p. 191, last row, column Dog | 9.44 |  | publication_error | 9.40 | proposed | 940 g / 10 kg x 100 = 9.40. | Recomputed from the printed Total and body weight; difference 0.04. |
| Holliday_etal_1967-E006 | organ_pct_body | Table III p. 191, last row, column Guinea pig | 6.25 |  | publication_error | 6.28 | proposed | 50.2 g / 0.8 kg x 100 = 6.275 (6.28). | Difference 0.025; 6.25 would need a total of 50.0. |
| Holliday_etal_1967-E007 | organ_pct_body | Table III p. 191, last row, column Rat | 8.16 |  | publication_error | 8.18 | proposed | 20.44 g / 0.25 kg x 100 = 8.176 (8.18). | Difference 0.016 (the printed 8.16 may be truncated, not rounded; Hog, Sheep and Steer differ by < 0.01 and pass). |

4 recorded, 4 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
