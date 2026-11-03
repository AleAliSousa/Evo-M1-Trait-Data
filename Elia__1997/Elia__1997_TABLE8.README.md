# Elia__1997_TABLE8

**Item name** `Elia__1997_TABLE8` · **Item number** `TABLE 8` · **Item encoded** `ISBN%3A9780397587636_TABLE8` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx`; code derived as the registry formula builds it with the ISBN override in column C — `ISBN:9780397587636` percent-encoded, `_`, item locus. Paste `Elia__1997_TABLE8_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Elia, M. (1997). Tissue distribution and energetics in weight loss and undernutrition. In J. M. Kinney & H. N. Tucker (Eds.), *Physiology, stress, and malnutrition: Functional correlates, nutritional intervention* (pp. 383-411). Lippincott-Raven. ISBN 0-397-58763-5 (ISBN-13 978-0-397-58763-6).

**Item full original title:** TABLE 8. Energy expenditure of the whole body, FFM brain, and FFM (FFM - brain) other than brain of a normal child and a marasmic child before nutritional therapy and at peak hypermetabolism during recovery, p. 401.

## Source

PDF in this folder: `elia_1997 p384-411.pdf`, COPIED (bytes identical) from the EndNote library (References.Data/PDF/2566130226/). The chapter's printed pages are 383-411 (the PDF starts at the first page of the chapter). The scan of p. 401 is landscape and its OCR text layer is garbled in the table region.

**Scope decision.** The request was to build the chapter only if it prints a comparable organ table with the 225 kcal/kg/day brain value. **TABLE 8 does** (brain weight, brain kcal/kg/day = 225 for the normal child, brain kcal/day, body and FFM-minus-brain energy, for a 12-month-old normal and marasmic child) and is built. The other tables are **not** organ partitions and were skipped: TABLE 1-2 (ways of expressing BMR in malnutrition), TABLE 3-4 (% loss of organ weights), TABLE 5 (body composition of atrophic infants), TABLE 6 (not examined; not located in the text layer), TABLE 7 (brain and forearm O2 consumption during total starvation: primary PET/AV-difference values from refs 65-67; a candidate for a separate item, not built here).

## Pipeline

```
Source (PDF)
  -> Elia__1997_extract_snapshot.R   writes the frozen snapshot
  -> Elia__1997_TABLE8_snapshot.csv   FROZEN: 16 rows x 11 cols
  -> Elia__1997_TABLE8.R   parse + derived columns + table checks
  -> Elia__1997_TABLE8.csv   6 rows x 36 cols  ("use this")
  -> __Public/comparative-data/ISBN%3A9780397587636_TABLE8.tsv
  -> reference_tables/Elia__1997_TABLE8_definitions.csv, Elia__1997_errata.csv, Elia__1997_species_key_proposed.csv
```

### Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-03 from 110- and 300-dpi renders of PDF page 19 (printed p. 401), typed as a verbatim printed-layout block into `Elia__1997_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy or to run outside a UTF-8 locale. The OCR text layer was not usable for the table. The only independent check is the table's own arithmetic (below): all 51 relations were re-run, which would expose a mis-keyed digit. There was no earlier transcription of this table to compare with, and **no second human reading yet**. The build script reads the frozen file, contains no table values, and was run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8`) on 2026-11-03.

### Structure of the snapshot and of the analysis CSV

* One snapshot row per printed **line**: three header tiers (Metabolic rate / Weight, Body, Brain, FFM - brain / column labels with the column-number formulas `[(7) • (3)]`, `[(5) - (8)]`, `[(9) ÷ (4)]`), the scenario rows with their wrapped labels ("Marasmus / (before treatment) / (12 months)"), the unlettered note and footnote a. The weight columns print no unit (kg inferred: body 10, 5, 6; brain 0.9, 0.8). The three superscript marks on the body weights read as `+`, `++`, `+++` (the footnote legend gives `+, 20% fat; ++, 10% fat; +++, 12.5% fat`).
* The analysis CSV has **one row per printed brain-rate line (6)**: the marasmic scenarios print 3 and 2 stacked alternative brain-rate assumptions under each other; the cells printed once per scenario (weights, body kcal/day, body kcal/kg/day) are repeated on each line. Printed cells are kept as text (`*_printed`) beside the parsed value and the printed % change versus the normal child. **Observation level: model scenarios of a 12-month-old child, not specimens or species means.**
* Derived (flagged `_derived` in the column name): `Brain_Mass.mg`, `body_mass.g`, `CMRO2_derived.umol_100g_min` (kcal/kg/day / 70.56 x 44.64 with the project factor 4.9 kcal/L O2, **not printed**; 225 kcal/kg/day = 142.3 umol/100 g/min), and `brain_share_body_kcal_pct_derived` (normal child 36.8% of body kcal/day).

## Table checks

The table states its arithmetic in its column headings and footnote (brain kcal/day = rate x brain kg; FFM-brain kcal/day = body - brain; FFM-brain kcal/kg/day = kcal/day / kg; % changes vs the normal child; FFM = body x (1 - fat%)). All were re-run. Result of an actual R run (2026-11-03): **50 pass, 1 mismatch, 0 not evaluable**, of 51 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `pct_change_brain_rate_kcal_kg_day_marasmus_peak_hypermetabolism_v2` | marasmus_peak_hypermetabolism_v2: 100 x (brain_rate_kcal_kg_day / normal child value - 1) vs printed % change | 20 | 30 | -10 | 0.5 | mismatch |

The one mismatch is a **printed arithmetic slip**: the second peak-hypermetabolism line prints `270 (+30%)` for the brain rate, but 270 / 225 = +20% (the adjacent `216 (+7%)` already corresponds to +20% on the rate). Kept as printed; erratum `Elia__1997-E001`. All other 50 checks reproduce within half a unit of the printed digit.

## Data role

**secondary and model-derived.** The brain rate (225 kcal/kg/day normal; 180-270 marasmic) is the author's **assumption** (footnote a), the weights and body energy are his scenario values; nothing is measured in this table. TABLE 8 prints **no per-row citation** (no references table is built; the neighbouring text on pp. 400-402 cites refs 65-67 for the measured starvation values, in TABLE 7 — not built). **Not merged**; nothing in `__merging_cerebral_metabolic_rate` was touched. Do not read `CMRO2_derived.umol_100g_min` as a CMRO2 measurement.

## Species names

The table prints no species (title: "a normal child", "a marasmic child"). `species_as_published` keeps those; both map to Homo sapiens in the proposed key rows (`reference_tables/Elia__1997_species_key_proposed.csv`, collection `General`; **no `_keys/` file was edited**). The build stops if the key filter returns no rows.

## Printed-vs-recomputed discrepancies (summary)

One: `270 (+30%)` vs +20% (E001). Everything else reproduces within rounding.

## Human visual check of snapshot

Pending human RA: lay the snapshot beside p. 401 (landscape scan), read a few rows across, and record `DDMMYYYY_initials` in the registry column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Elia__1997_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Elia__1997-E001 | brain_rate_pct_change | TABLE 8 p. 401, row 'Marasmus (during treatment at peak hypermetabolism)', 2nd stacked line, column Brain kcal/kg/day | 270 (+30%) |  | publication_error | +20% | proposed | 270 / 225 = 1.20, i.e. +20% against the normal child (table_checks pct_change_brain_rate_kcal_kg_day_marasmus_peak_hypermetabolism_v2: observed 20 vs printed 30, tolerance 0.5). The same line prints 216 (+7%) kcal/day, which equals 270 x 0.8 and fits +20% on the rate (216/202.5 = +6.7%). The other five stacked brain-rate % changes reproduce. | CSV keeps the printed +30. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
