# Riddell_Corl_1977_TableII

**Source** — Riddell, W. I., & Corl, K. G. (1977). Comparative investigation of the relationship between
cerebral indices and learning abilities. *Brain, Behavior and Evolution*, 14(6), 385-398.
https://doi.org/10.1159/000125804

**Item** — Table II, "Anatomical and performance data for several species on five tasks" (printed page 391-392).

| file | what it is |
|---|---|
| `Riddell_Corl_1977_TableII_snapshot.xlsx` | the frozen snapshot: the table as printed |
| `Riddell_Corl_1977_TableII.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Riddell_Corl_1977_TableII.csv` | analysis-ready data ("use this") |
| `reference_tables/Riddell_Corl_1977_TableII_definitions.csv` | data dictionary |
| `Riddell_Corl_1977_TableII.README.md` | this file |

**Analysis rows** — 30 (task block x species). **Observation level** — task x species.

**Public TSV** — written to the repo-level `__Public/comparative-data/` under the registry
`Item encoded`. See "Registry" below.

## Who read the values, and how they were checked

The source is a **1977 scanned journal page** (Karger, Brain Behav. Evol.). The PDF carries an OCR text layer, but it
emits table columns out of reading order and corrupts digits, so it was **not** used for any
value. Every cell was read off page renders at 200-600 dpi by an **AI assistant (Claude) on
2026-10-31** and typed verbatim into the frozen snapshot through
``Riddell_Corl_1977_extract_snapshot.py`` (the printed-layout block lives in that script;
re-running it refuses to overwrite a differing frozen copy). The same session re-rendered each
table at 400-600 dpi with the column rules visible and read every row left to right against the
transcription.

**A human side-by-side check is still outstanding.** Record it in the `Human visual check of
snapshot` column of `__ReadMe.xlsx` (`DDMMYYYY_initials`) once done. Read *along rows*, and dwell
on the places flagged under "What to look at first" below.


## What the table is

A **compilation**. For five behavioural tasks it assembles, per species, the body weight (P, g)
and brain weight (E, g), two derived cerebral indices - Jerison's "extra neurons" Nc (x 10^7) and
Herschel's index H - the learning-set slope where applicable, and four rank columns, each value
carrying a printed reference number. Only two values in the whole table are new: the body and
brain weights of *Meriones unguiculates* and *Rattus rattus* in the learning-set block, whose
"E and P reference" reads **present study**. Everything else is secondary.

The five blocks are successive discrimination reversal (6 species), conditioned response reversal
(4), delayed alternation (3), learning sets (11) and extradimensional shift (6). The table runs
across two printed pages; p.392 repeats the caption as "Table II (continued)" and the full
header.

## Secondary sources - the point of this item

`reference_tables/Riddell_Corl_1977_TableII_references.csv` resolves **every** key the table
cites to the full bibliography entry (pp.396-398), verbatim: 21 numbered references plus the
pseudo-key `present study`. To bind them: split `behavior_reference` or `E_and_P_reference` on
`"; "` and match on `ref_key`. The one printed multi-citation, `24, 35` (Saimiri sciurea,
learning sets), is stored as `24; 35`.

Oddities in the bibliography are recorded in the `note` column rather than corrected: ref 1 prints
"Monogolian" and the initial `ROLLIN, R.` where refs 30/31 print `ROLLIN, A.`; ref 8 omits the
colon after the author list; ref 27 prints `(1974.)`; ref 41 ends with a comma.

**This is a roadmap for primary ingestion, not primary data.** Do not merge these P and E values
as if they were measured here - with the two "present study" exceptions.

## Snapshot

Two-line header and brace-grouped blocks, so XLSX. 36 rows = caption, `[page 391]`, header, 23
data rows, `[page 392]`, `Table II (continued)`, header, 6 data rows; 14 columns, including a
`[printed brace]` column at the position the brace occupies on the page (between Species and
Dependent variable). The `Dependent variable` cell is printed once per block and is left blank on
the block's other rows, as on the page. Misprinted epithets are kept exactly: `Cebus capuchin`,
`Saimiri sciurea`, `Erinaceus europacus`, `Silvilagus gabbi`, `Meriones unguiculates`,
`Sciurus vulgaric`, `Paco paca`, `Galago-senegalensis`.

## Units

`P, g` is already the project unit for body weight. `E, g` is kept as printed and also converted
to the project unit for brain weight: `Brain_Mass.mg = Brain_Mass.g x 1000`.

## Table checks

The printed `Nc rank`, `E rank` and `H rank` columns are rankings of the printed `Nc`, `E` and `H`
values within each braced block, so the table checks itself:

| check | rule | result |
|---|---|---|
| `Nc_rank` | descending rank of Nc within the block, average ranks for ties | **pass** (0/30 disagree) |
| `E_rank` | descending rank of E within the block | **pass** (0/30) |
| `H_rank` | ascending rank of H within the block (a lower H means a relatively larger brain) | **pass** (0/30) |

The two printed `1.5` values in the conditioned-response block reproduce exactly as an average
rank for the tied H of 6.0. `Behavior rank` is **not** checkable: the behavioural measure it ranks
is not printed.

## Printed inconsistencies (errata E001-E003)

- *Tupaia glis*: P is `145.5` in the delayed-alternation block and `145.4` in the
  extradimensional-shift block, both citing reference 27.
- *Rattus rattus*: H is `15.55` in the learning-set block and `15.6` in the extradimensional-shift
  block, from identical printed P and E - most likely a precision difference.
- In the extradimensional-shift block the printed Behavior ranks are 6 for *Tupaia glis* (row 5)
  and 5 for *Rattus rattus* (row 6), out of row order; every other block is printed in
  Behavior-rank order.

All kept as printed.

## What to look at first (human check)

- the four brace boundaries, where the `Dependent variable` cell changes - a gained or lost row
  there misattributes a whole block;
- rows 9-11 of the learning-set block, which the typesetter spread over extra lines to fit
  `present study` in the last column;
- the five species that appear in more than one block (*Homo sapiens*, *Pan troglodytes*,
  *Cebus albifrons*, *Saimiri sciurea*, *Tupaia glis*, *Rattus rattus*) - read the two printings
  against each other;
- the `Slope` column, printed only for the learning-set block and an en dash everywhere else.

## Registry

`__ReadMe.xlsx` column A for this paper carries trailing whitespace, so the formula-built
`Item encoded` currently reads `10.1159%2F000125804 _TableII` — with a stray space. The owner has trimmed column A but Excel has not recalculated, so the cached value is
still the old one. The build script therefore strips **every** space (including NBSP) from
`Item encoded` before using it as a filename; the public TSV is written as
`10.1159%2F000125804_TableII.tsv`. **This is correct only once `_tools/file_list.R` has been
re-run** so that the registry's cached `Item encoded` and the `AUTO_Public_TSV_FileList` match the
filename on disk.

`Data role` is blank in the registry for this item. A proposed value, with the reasoning, is in
`<ITEM>_registry_row.xlsx` in this folder — paste it as values into Sheet1, then re-run
`_tools/file_list.R`.

## Errata

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Riddell_Corl_1977_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Riddell_Corl_1977-E001 | Body_Mass.g | Table II, delayed-alternation block row 2 (p.391) versus extradimensional-shift block row 5 (p.392), Tupaia glis | 145.5 (p.391); 145.4 (p.392) |  | publication_ambiguity |  | proposed | The same species, citing the same E and P reference (27), is printed with two different body weights in the same table. One of the two is a typesetting slip; the paper does not say which. | Both values kept as printed, one per row. |
| Riddell_Corl_1977-E002 | Herschel_index_H | Table II, learning-set block row 10 (p.391) versus extradimensional-shift block row 6 (p.392), Rattus rattus | 15.55 (p.391); 15.6 (p.392) |  | publication_ambiguity |  | proposed | The same species with identical printed P (326.6) and E (1.9) is given two values of the Herschel index. 15.6 is 15.55 rounded to three significant figures, so this is most likely a precision difference rather than a disagreement, but the paper does not say so. | Both values kept as printed, one per row. |
| Riddell_Corl_1977-E003 | behavior_rank | Table II, extradimensional-shift block (p.392), rows 5 and 6 | Tupaia glis: Behavior rank 6; Rattus rattus: Behavior rank 5 |  | publication_ambiguity |  | proposed | The rows of every other block are printed in Behavior-rank order, and here the printed row numbers 5 and 6 carry Behavior ranks 6 and 5. The behavioural measure being ranked is not printed, so it cannot be decided whether the rank column or the row order is the slip. | Kept as printed. The Nc, E and H rank columns of the same block are re-derived and all agree with the printed values (see the item's table_checks). |

3 recorded, 3 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
