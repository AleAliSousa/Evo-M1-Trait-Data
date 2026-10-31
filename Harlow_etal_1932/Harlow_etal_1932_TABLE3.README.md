# Harlow_etal_1932_TABLE3

**Source** — Harlow, H. F., Uehling, H., & Maslow, A. H. (1932). Comparative behavior of primates. I.
Delayed reaction tests on primates from the lemur to the orang-outan. *Journal of Comparative
Psychology*, 13(3), 313-343. https://doi.org/10.1037/h0073864

**Item** — TABLE 3, "Responses of 10 primates to neutral orientation, favorable orientation, and unfavorable orientation of correct container following 30-second delay periods" (printed page 331).

| file | what it is |
|---|---|
| `Harlow_etal_1932_TABLE3_snapshot.xlsx` | the frozen snapshot: the table as printed |
| `Harlow_etal_1932_TABLE3.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Harlow_etal_1932_TABLE3.csv` | analysis-ready data ("use this") |
| `reference_tables/Harlow_etal_1932_TABLE3_definitions.csv` | data dictionary |
| `Harlow_etal_1932_TABLE3.README.md` | this file |

**Analysis rows** — 30 (10 animals x 3 conditions). **Observation level** — individual animal x orientation condition.

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

Percentage of correct responses in 50 trials at a 30-second delay, with the apparatus presented
so that the two cups were equidistant (neutral), the correct cup nearer the animal (favorable),
or the incorrect cup nearer (unfavorable) - Fig. 3, p.330.

## Two things to know about the printed table

1. **The registry title says "50-second delay periods"; the paper prints "30-second".** The
   caption digit is degraded in the scan, but p.330 states the cups were presented in three
   positions "following thirty-second delays", and the sub-heading "Percentages of responses
   correct in 50 trials" is where the 50 belongs. A corrected title is proposed in
   `Harlow_etal_1932_TABLE3_registry_row.xlsx`.
2. **The caption lists the conditions in a different order from the columns.** Caption: neutral,
   favorable, unfavorable. Columns: NEUTRAL, UNFAVORABLE, FAVORABLE. The column headers are
   authoritative and the data agree with them (the favorable column is 94-100 throughout, the
   unfavorable column falls to 4).

## Snapshot and the brace (errata E001)

The printed table has **eleven label lines for ten value rows**: line 1 reads `I. Mandrill` and
carries its own values, while lines 2 and 3 (`II. Pat`, `II. Baboon Min`) are joined by a printed
brace to one set of values - and `II.` is printed twice. The snapshot keeps all eleven lines in
printed order and records the brace in a `[printed brace]` column placed where the brace sits on
the page, between the label column and the first value column; the shared values sit on the first
braced line.

Tables 4 and 6 list the same animals in the same order as `I. Mandrill (Pat)` and
`II. Baboon (Min)`, so the brace has evidently slipped one line. That reading is recorded as
`Harlow_etal_1932-E001` (publication_ambiguity, status `proposed`). The analysis CSV keeps the
printed labels verbatim in `animal_as_published`; the interpretation appears **only** in
`familiar_name`, on the two rows flagged by `errata_id`. No printed value is altered.

## Table checks

None: the table prints no totals or other self-checking relation.

## What to look at first (human check)

- the brace and the first three label lines (above);
- the UNFAVORABLE column, which is the one that falls monotonically - a one-row slip there is the
  easiest error to make and the hardest to see.

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
| Harlow_etal_1932-E001 | * | Table 3, p.331, printed label lines 1-3 | I. Mandrill / II. Pat / II. Baboon Min (lines 2 and 3 joined by a printed brace to one set of values: 98, 100, 100; line 1 carries 100, 100, 100) |  | publication_ambiguity | I. Mandrill Pat = 100, 100, 100; II. Baboon Min = 98, 100, 100 | proposed | Eleven printed label lines carry ten value rows and the numeral 'II.' is printed twice. Tables 4 (p.334) and 6 (p.337) list the same animals in the same order as 'I. Mandrill (Pat)' and 'II. Baboon (Min)', so the brace has slipped one line and 'Pat' belongs to row I. No value is in doubt, only the label-to-value alignment of the first two rows. | The snapshot keeps all eleven printed lines and the brace. The analysis CSV keeps the printed labels verbatim in animal_as_published and carries the interpretation only in familiar_name, flagged by errata_id. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
