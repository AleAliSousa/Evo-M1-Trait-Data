# Harlow_etal_1932_TABLE5

**Source** — Harlow, H. F., Uehling, H., & Maslow, A. H. (1932). Comparative behavior of primates. I.
Delayed reaction tests on primates from the lemur to the orang-outan. *Journal of Comparative
Psychology*, 13(3), 313-343. https://doi.org/10.1037/h0073864

**Item** — TABLE 5, "Tests of retention of delayed reaction method in primates" (printed page 334).

| file | what it is |
|---|---|
| `Harlow_etal_1932_TABLE5_snapshot.csv` | the frozen snapshot: the table as printed |
| `Harlow_etal_1932_TABLE5.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Harlow_etal_1932_TABLE5.csv` | analysis-ready data ("use this") |
| `reference_tables/Harlow_etal_1932_TABLE5_definitions.csv` | data dictionary |
| `Harlow_etal_1932_TABLE5.README.md` | this file |

**Analysis rows** — 74 (animal x printed test occasion). **Observation level** — individual animal x test occasion.

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

Total correct responses on four occasions: the original test series, a retest 10-14 days later,
a test after 4-6 weeks of no practice, and a test after 9-12 weeks of no practice. p.335
describes the series as ten trials at each delay from zero to 120 seconds, so the maximum
possible score is 70; the highest printed is 60.

## Snapshot

Single header row, so CSV. 24 rows = caption, sub-caption, header, 21 animal rows. Blank cells
are left blank: six animals have no 4-6 week score and six have no 9-12 week score.

## What the script does

Positional read; long reshape to animal x occasion, emitting only the cells that carry a printed
value (74 of a possible 84). The familiar name comes from the parenthesis in each printed label
and is matched against the TABLE 1 roster.

## Table checks

| check | result |
|---|---|
| `retest_reliability_r` - the Pearson correlation of the first two columns over all 21 rows, against the `.971` stated on p.335 | **pass** (observed .9704, difference -0.0006, tolerance 0.001) |

The paper used "Hull's product-moment formula", which is the ordinary Pearson r; the residual is
rounding of the printed integer scores.

## A text/table disagreement (errata E003)

p.335 says the test series was given to all the primates "with the exception of the orang-outan,
the sooty mangabey and the mustachio monkey" - yet the sooty mangabey Sooty has scores here
(34, 28), while Macaque No. V, not named as excluded, has no row. Recorded as
`Harlow_etal_1932-E003` (publication_ambiguity); nothing is changed.

## What to look at first (human check)

- the block Mangabey (Sooty) -> Mandrill (Socrates), where the two right-hand columns are mostly
  blank and a dropped blank would shift everything below;
- Guenon (Lightning), the only animal in that block with a 9-12 week score (28);
- Cebus (Scarface Al) `9` and Lemur (Racket) `11`, the two single-digit values.

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
| Harlow_etal_1932-E003 | * | Table 5, p.334, versus the Reliability paragraph on p.335 | Table 5 lists 21 animals including 'Mangabey (Sooty)'; p.335 states the test series was given to all the primates 'with the exception of the orang-outan, the sooty mangabey and the mustachio monkey' |  | publication_ambiguity |  | proposed | The sooty mangabey Sooty has scores in Table 5 (34, 28) although the text names it among the three animals excluded from the series the table summarises; conversely Macaque No. V, which is not named as excluded, has no row in Table 5. | Reported, not repaired: no value is changed. Affects only the reader's expectation of which animals Table 5 covers. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
