# Maslow_Harlow_1932_TABLE2

**Source** — Maslow, A. H., & Harlow, H. F. (1932). Comparative behavior of primates. II. Delayed
reaction tests on primates at Bronx Park zoo. *Journal of Comparative Psychology*, 14(1), 97-107.
https://doi.org/10.1037/h0072093

**Item** — TABLE 2, "Summary of correct responses" (printed page 106).

| file | what it is |
|---|---|
| `Maslow_Harlow_1932_TABLE2_snapshot.xlsx` | the frozen snapshot: the table as printed |
| `Maslow_Harlow_1932_TABLE2.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Maslow_Harlow_1932_TABLE2.csv` | analysis-ready data ("use this") |
| `reference_tables/Maslow_Harlow_1932_TABLE2_definitions.csv` | data dictionary |
| `Maslow_Harlow_1932_TABLE2.README.md` | this file |

**Analysis rows** — 77 (animal x printed delay, plus one row for each of the three animals that yielded no data). **Observation level** — individual animal x delay.

**Public TSV** — written to the repo-level `__Public/comparative-data/` under the registry
`Item encoded`. See "Registry" below.

## Who read the values, and how they were checked

The source is a **1932 scanned journal page**. The PDF carries an OCR text layer, but it
emits table columns out of reading order and corrupts digits, so it was **not** used for any
value. Every cell was read off page renders at 200-600 dpi by an **AI assistant (Claude) on
2026-10-31** and typed verbatim into the frozen snapshot through
``Maslow_Harlow_1932_extract_snapshots.py`` (the printed-layout block lives in that script;
re-running it refuses to overwrite a differing frozen copy). The same session re-rendered each
table at 400-600 dpi with the column rules visible and read every row left to right against the
transcription.

**A human side-by-side check is still outstanding.** Record it in the `Human visual check of
snapshot` column of `__ReadMe.xlsx` (`DDMMYYYY_initials`) once done. Read *along rows*, and dwell
on the places flagged under "What to look at first" below.


## What the table is

For each of the 18 animals and each of eight delays (0, 5, 10, 15, 30, 60, 120, 180 seconds), the
number of trials (N) and the percentage correct (%C). Three animals have a sentence printed
across the data columns instead of values.

## Snapshot

Three-tier header (`PERIOD OF DELAY (SECONDS)` spanning eight delays, each N/%C), so XLSX with
blank padding: 17 columns, 24 rows = 2 caption rows, 3 header rows, 18 animal rows, 1 footnote
row. The three sentences (`Too ferocious to attend to experimental situation`, `Too sick to
respond. Died soon after`, `Too shy to respond`) are kept in the first data cell of their rows.

## Species

This table prints **no binomials** - only common names. They are resolved directly through
`_keys/General/species_key.csv` (`source_publication = Maslow_Harlow_1932`), not by joining to
TABLE 1, because TABLE 2's row order differs from TABLE 1's numbering and two of its names
contradict TABLE 1 (errata E001 "Hamadryas baboon" vs TABLE 1's guinea baboon; E002 "Baby
mandrill" vs TABLE 1's baby drill).

## Table checks

None: the table prints no totals or other self-checking relation.

## What to look at first (human check)

- the three sentence rows (10 Common macaque, 12 Spider monkey, 18 Brown mongoose lemur), which
  break the column grid;
- the 10-second block, which is empty for every animal except the three capuchins - its blank
  cells are where a sideways slip would start;
- `Young gorilla` at 120 s, printed `1  100` (a single trial), and `Baby mandrill` at 120 s and
  `Drill` at 180 s, both printed `0` per cent - genuine zeroes, not blanks;
- the last two lemur rows, which stop after the 5-second block.

## Registry

`__ReadMe.xlsx` column A for this paper carries trailing whitespace, so the formula-built
`Item encoded` currently reads `10.1037%2Fh0072093<NBSP>_TABLE<N>` — with a stray non-breaking
space. The owner has trimmed column A but Excel has not recalculated, so the cached value is
still the old one. The build script therefore strips **every** space (including NBSP) from
`Item encoded` before using it as a filename; the public TSV is written as
`10.1037%2Fh0072093_TABLE<N>.tsv`. **This is correct only once `_tools/file_list.R` has been
re-run** so that the registry's cached `Item encoded` and the `AUTO_Public_TSV_FileList` match the
filename on disk.

`Data role` is blank in the registry for this item. A proposed value, with the reasoning, is in
`<ITEM>_registry_row.xlsx` in this folder — paste it as values into Sheet1, then re-run
`_tools/file_list.R`.

## Errata

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Maslow_Harlow_1932_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Maslow_Harlow_1932-E001 | animal_as_published | Table 2, p.106, row 4, versus Table 1, p.99, animal 4 | Table 2: 'Hamadryas baboon'; Table 1: '4. Lasiopygidae (guinea baboon)  Papio  Papio' |  | publication_ambiguity |  | proposed | Both tables describe the same 18 animals, but the fourth baboon is the guinea baboon Papio papio in Table 1 and the hamadryas baboon in Table 2. Papio papio and Papio hamadryas are different species. Nothing in the paper adjudicates between them. | Each item resolves its species from the name its own table prints; the two tables are not joined on row position. See the _keys/General/species_key.csv rows for this paper. |
| Maslow_Harlow_1932-E002 | animal_as_published | Table 2, p.106, row 8, versus Table 1, p.99, animal 7 | Table 2: 'Baby mandrill'; Table 1: '7. Lasiopygidae (drill)  Papio  Leucophaeus  Baby (2 years)' |  | publication_ambiguity |  | proposed | Table 1's only infant is a DRILL (Mandrillus leucophaeus); Table 2's only infant is called a mandrill (Mandrillus sphinx). Table 1 also lists a separate adult mandrill (animal 8) which Table 2 lists as 'Mandrill'. Nothing in the paper adjudicates between them. | Each item resolves its species from the name its own table prints; the species_key row for 'Baby mandrill' is marked basis = hypothesis, LOW CONFIDENCE. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
