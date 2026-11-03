# Aschoff__1971_Tabelle1

**Item name** `Aschoff__1971_Tabelle1` · **Item number** `Tabelle 1` · **Item encoded** `Aschoff%3A1971%3AEnergiehaushalt_Tabelle1` — *derived, awaiting registration*
( Paste `Aschoff__1971_Tabelle1_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Aschoff, J. (1971). Temperaturregulation [section of: Aschoff, J., Günther, B., & Kramer, K., *Energiehaushalt und Temperaturregulation*]. In O. H. Gauer, K. Kramer, & R. Jung (Eds.), *Physiologie des Menschen, Band 2*. Urban & Schwarzenberg. (No DOI; scanned 12-page excerpt, Tabelle 1 on p. 44, Abb. 1 on p. 45.)

**Item full original title:** Tabelle 1. Sauerstoffaufnahme bzw. Wärmebildung der Organe im ruhenden Körper. (65 kg Gewicht, 270 cm³/min Sauerstoffaufnahme), p. 44.

## Source

PDF in this folder: `aschoff_1971.pdf` (copied from `References.Data/PDF/2480964197/`; 12 scanned pages, no usable text layer for the figure). Values printed in Abb. 1 and in the text are in the sibling item `Aschoff__1971_Text`. Other tables and figures of the excerpt (Tabelle 2 temperature differences, Tabelle 3 conductivities, figures) carry no organ metabolism and were not built.

## Pipeline

```
Source (PDF)
  -> Aschoff__1971_extract_snapshot.R   writes the frozen snapshot(s)
  -> Aschoff__1971_Tabelle1_snapshot.csv   FROZEN: 11 rows x 6 cols
  -> Aschoff__1971_Tabelle1.R   clean + parse German numerals + convert units + table checks
  -> Aschoff__1971_Tabelle1.csv   7 rows x 24 cols  ("use this")
  -> __Public/comparative-data/Aschoff%3A1971%3AEnergiehaushalt_Tabelle1.tsv
  -> reference_tables/Aschoff__1971_Tabelle1_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-03 from 170/300-dpi renders of PDF page 2 (book p. 44), typed as a verbatim printed-layout block into `Aschoff__1971_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The OCR text layer of Tabelle 1 (poor scan, decimal commas and thousands points intact) was read afterwards as an independent second reading and agrees on all 42 value cells. The build script reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row (caption; header tiers with blank padding under the spanners *Sauerstoffaufnahme* and *Wärmebildung*; 7 organ rows in printed order). German decimal commas and thousands points are kept; the row *Splanchnikus-/gebiet* is one two-line cell.
* The analysis CSV has one row per organ; `*_printed` columns keep the printed strings, numeric columns are parsed; mL O2 -> µmol O2 at x 44.64 (22.4 L/mol at STP); heat kept in printed cal; `implied_cal_per_ml_O2` = printed cal / printed mL (4.69-4.93, derived).
* **Observation level: organ values of a textbook reference body** (65 kg, 270 mL O2/min), not measurements and not species means.


## Table checks

Result of an actual R run (2026-11-03, `Rscript`, conda env `r`): **13 pass, 1 mismatch, 2 not evaluable**, of 16 checks. Rule: rounding of each printed factor (half a unit of its last printed decimal) or, for a percentage recomputed from a printed total, one unit of its last decimal (HOWTO 7a). Every mismatch is kept as printed and explained below; nothing was changed to make a check pass.

Not-pass checks (the passing checks are in the table_checks object of the build and listed by `build_dataset_item()`):

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `O2_organ_3` | Gehirn: weight x O2 ml/100 g/min / 100 vs printed O2 ml/organ/min | 43.2 | 43 | 0.2 | 0.1335 | mismatch |
| `sum_O2_vs_caption` | sum of the 7 printed organ O2 ml/min vs caption whole-body 270 ml/min | 242.3 | 270 | -27.7 | 0.35 | not_evaluable |
| `sum_weight_vs_caption` | sum of the 7 printed organ weights (kg) vs caption body weight 65 kg | 37.03 | 65 | -27.97 | 0.0035 | not_evaluable |

## Printed-vs-recomputed discrepancies

1. **Gehirn, O2 per organ**: printed 43,0 mL/min; 1.350 g x 3,20 mL/100 g/min = 43,2 (diff 0,2; tolerance 0,13). The printed cal columns agree with 43,2 (15,40 x 13,5 = 207,9 = printed 208). Recorded as erratum `Aschoff__1971-E001` (proposed). The book's 16% for the brain (Abb. 1) is 43,0/270 = 15,9% (43,2/270 = 16,0%).
2. **Muskel, O2 per organ**: printed 43,0; 27.000 g x 0,16 = 43,2. This is inside the rounding of the printed 0,16 rate (a rate of 0,159 reproduces 43,0), so it passes and is not an erratum.
3. **Caption totals are not reproduced by the rows (not an error)**: the seven rows add to 242,3 mL O2/min (caption: 270) and 37,03 kg (caption: 65 kg); other tissues (bone, fat, blood, ...) are not tabulated. Brain share of the caption total: 43,0/270 = 15,9%.
4. The cal columns imply 4,69-4,93 cal per mL O2 (a single factor of 4,8 would give Muskel 0,77, Gehirn 15,4, Lunge 9,6, Nieren 33,6, Splanchnikus 17,3): rounded per row in the print; not corrected.

## Data role

**secondary** (a textbook compilation: the organ weights and rates are estimates and the table cites no source per row; Abb. 1 is credited to Aschoff & Wever 1958). Not to be merged as a primary measurement; use it as a roadmap to primaries.

## Species names

`species_as_published` keeps the printed label. Rows for this paper folder were appended to `_keys/General/species_key.csv` (collection General; 2026-11-03, pending owner sign-off) and the build stops if the key returns no rows for the folder. The table names no species; `human` is inferred from the chapter (Physiologie des Menschen) and the 65 kg body, and marked as such in the key note.

## Per-row source citations

The table prints no per-row source. The only citation tied to this page is `[1]` (after the 52%/18% statement, see the `_Text` item); the chapter bibliography is not in the scanned excerpt, so no `references.csv` is written for this table.

## Compilation comparison (done AFTER the snapshot was frozen)

The working transcriptions and the cross-source comparison live in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (`CLASSIC_COMPILATIONS_FINDINGS.md`); they were compared with this snapshot only after it was frozen, and no printed value was changed. The merged `__merging_cerebral_metabolic_rate` was not modified. The brain row (3,20 mL/100 g/min, 1.350 g, 43,0 of 270 mL/min = 16%) is the Aschoff entry in `classic_human_brain_partition.csv`; no differences between that transcription and the page image.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Aschoff__1971_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Aschoff__1971-E001 | O2_ml_organ_min | Tabelle 1 p. 44, row Gehirn, column Sauerstoffaufnahme ml/Organ·min | 43,0 |  | publication_error | 43,2 | proposed | Arithmetic: 1.350 g x 3,20 ml/100 g/min = 43,2 ml/min; the printed cal columns agree with 43,2 (15,40 x 1.350/100 = 207,9 = printed 208). Text layer and 300-dpi render both read 43,0. The paper then cites 43,0 mL/min and 16% (43/270 = 15.9%); 43,2 would give 16.0%. | Printed value kept (CSV mirrors the print); the Muskel row (27.000 g x 0,16 = 43,2 vs printed 43,0) is within the rounding of the 0,16 rate and is not recorded. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
