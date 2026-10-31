# Harlow_etal_1932_TABLE4

**Source** — Harlow, H. F., Uehling, H., & Maslow, A. H. (1932). Comparative behavior of primates. I.
Delayed reaction tests on primates from the lemur to the orang-outan. *Journal of Comparative
Psychology*, 13(3), 313-343. https://doi.org/10.1037/h0073864

**Item** — TABLE 4, "Effect of previous responses" (printed page 334).

| file | what it is |
|---|---|
| `Harlow_etal_1932_TABLE4_snapshot.xlsx` | the frozen snapshot: the table as printed |
| `Harlow_etal_1932_TABLE4.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Harlow_etal_1932_TABLE4.csv` | analysis-ready data ("use this") |
| `reference_tables/Harlow_etal_1932_TABLE4_definitions.csv` | data dictionary |
| `Harlow_etal_1932_TABLE4.README.md` | this file |

**Analysis rows** — 36 (6 animals x 3 delays x 2 series). **Observation level** — individual animal x delay x series.

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

Per cent of 10 trials correct at 15, 30 and 60 seconds under two series: NS, the normal/control
series with a random order of right and left choices; ES, the experimental series in which food
was presented on one side four times in succession before being shifted to the other for the
fifth (critical) trial, only the critical trials being scored. `NR` means no response.

## Snapshot

Two-tier header (three delay groups, each NS/ES), so XLSX with blank padding: 7 columns, 12 rows
= 3 caption/sub-caption rows, 2 header rows, 6 animal rows, 1 footnote row.

## What the script does

Positional read; long reshape to animal x delay x series. `pct_correct` is NA on the four printed
`NR` cells, which keep their printed token in `response_code` and `value_as_published`.

## Table checks

None: the table prints no totals or other self-checking relation.

## What to look at first (human check)

- the Macaque (No. IV) ES cell at 30 seconds, printed `0` - a genuine zero, not a blank;
- the four `NR` cells at 60 seconds, which make the last two rows short.

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
<!-- errata:end -->
