# Harlow_etal_1932_TABLE2

**Source** — Harlow, H. F., Uehling, H., & Maslow, A. H. (1932). Comparative behavior of primates. I.
Delayed reaction tests on primates from the lemur to the orang-outan. *Journal of Comparative
Psychology*, 13(3), 313-343. https://doi.org/10.1037/h0073864

**Item** — TABLE 2, "Summary of correct responses" (printed page 323).

| file | what it is |
|---|---|
| `Harlow_etal_1932_TABLE2_snapshot.xlsx` | the frozen snapshot: the table as printed |
| `Harlow_etal_1932_TABLE2.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Harlow_etal_1932_TABLE2.csv` | analysis-ready data ("use this") |
| `reference_tables/Harlow_etal_1932_TABLE2_definitions.csv` | data dictionary |
| `Harlow_etal_1932_TABLE2.README.md` | this file |

**Analysis rows** — 124 (animal x printed delay block). **Observation level** — individual animal x delay.

**Public TSV** — written to the repo-level `__Public/comparative-data/` under the registry
`Item encoded`. See "Registry" below.

## Who read the values, and how they were checked

The source is a **1932 scanned journal page**. The PDF carries an OCR text layer, but it
emits table columns out of reading order and corrupts digits, so it was **not** used for any
value. Every cell was read off page renders at 200-600 dpi by an **AI assistant (Claude) on
2026-10-31** and typed verbatim into the frozen snapshot through
``Harlow_etal_1932_extract_snapshots.py`` (the printed-layout block lives in that script;
re-running it refuses to overwrite a differing frozen copy). The same session re-rendered each
table at 400-600 dpi with the column rules visible and read every row left to right against the
transcription.

**A human side-by-side check is still outstanding.** Record it in the `Human visual check of
snapshot` column of `__ReadMe.xlsx` (`DDMMYYYY_initials`) once done. Read *along rows*, and dwell
on the places flagged under "What to look at first" below.


## What the table is

The paper's main result: for each of the 24 animals and each of eight delay periods, the number
of trials (NT), the per cent of all trials correct (PC) and the per cent of the last 50 trials
correct (LFC).

## Snapshot

Three-tier header (`PERIOD OF DELAY` spanning eight delay blocks, each `NT`/`PC`/`LFC`, with a
`per cent` units row), so XLSX with blank padding under each spanning header: 26 columns, 33 rows
= 2 caption rows, 4 header rows, 24 animal rows, 3 footnote rows. Blank cells are blank, the
guenon Skeezix keeps its printed `(Failed to grasp problem)`, and the `*` and the dagger printed
in the `Over 180 seconds` block are kept in the cells where they appear.

## What the script does

Reads the frozen XLSX positionally; for each animal and each delay block emits one row when the
block carries anything. The two footnote marks are read **from the snapshot's own footnote rows**
(so the comparison does not depend on the session's encoding) and resolve the `Over 180 seconds`
block to a real delay: `*` = 300 s (the orang-outan Jiggs), dagger = 600 s (the mandrill Pat);
`delay_s_from_footnote` flags those two rows. Species come from the TABLE 1 roster, joined on the
printed FAMILIAR NAME.

## Table checks

| check | result |
|---|---|
| `lfc_multiple_of_2` - LFC is a per cent of 50 trials, so every attainable value is even | **mismatch**: 1 of 84 printed LFC cells fails |

The failing cell is Macaque No. III at 60 seconds, printed `53`. Re-read at 600 dpi: the digits
are unambiguous. Recorded as `Harlow_etal_1932-E002` (publication_error) and **kept as printed**
in the snapshot, the CSV and the TSV.

## What to look at first (human check)

- Skeezix's `(Failed to grasp problem)` row - the rows below it are the ones most likely to have
  shifted;
- the `Over 180 seconds` block: only Jiggs and Pat have entries there, and the footnote marks sit
  in the LFC column;
- Thunder, Lightning, Sooty, Xanthippe, Scarface Al, Bugs and Racket, whose rows stop part-way
  across the table and whose remaining values are easy to read into the wrong delay block;
- Macaque No. IV, whose 30-second block has NT and PC but no LFC.

## Registry

`__ReadMe.xlsx` column A for this paper carries trailing whitespace, so the formula-built
`Item encoded` currently reads `10.1037%2Fh0073864<NBSP>_TABLE<N>` — with a stray non-breaking
space. The owner has trimmed column A but Excel has not recalculated, so the cached value is
still the old one. The build script therefore strips **every** space (including NBSP) from
`Item encoded` before using it as a filename; the public TSV is written as
`10.1037%2Fh0073864_TABLE<N>.tsv`. **This is correct only once `_tools/file_list.R` has been
re-run** so that the registry's cached `Item encoded` and the `AUTO_Public_TSV_FileList` match the
filename on disk.

`Data role` is blank in the registry for this item. A proposed value, with the reasoning, is in
`<ITEM>_registry_row.xlsx` in this folder — paste it as values into Sheet1, then re-run
`_tools/file_list.R`.

## Errata

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Harlow_etal_1932_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Harlow_etal_1932-E002 | pct_correct_last50 | Table 2, p.323, row 'Macaque / No. III', 60-seconds block, LFC cell | 53 |  | publication_error |  | proposed | LFC is defined in the printed footnote as 'per cent last 50 trials correct'. Every attainable percentage of 50 trials is a multiple of 2, so 53 is not attainable; the other 83 printed LFC cells are all even. Re-read at 600 dpi: the digits are unambiguously 53. The true value cannot be recovered from the paper. | Kept as printed in the snapshot and in the CSV/TSV. Detected by the item's own table check (check_id lfc_multiple_of_2), which reports status = mismatch on every run. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
