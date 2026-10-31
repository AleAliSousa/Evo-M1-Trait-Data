# Maslow_Harlow_1932_TABLE1

**Source** — Maslow, A. H., & Harlow, H. F. (1932). Comparative behavior of primates. II. Delayed
reaction tests on primates at Bronx Park zoo. *Journal of Comparative Psychology*, 14(1), 97-107.
https://doi.org/10.1037/h0072093

**Item** — TABLE 1, "Classification of the animals" (printed page 99).

| file | what it is |
|---|---|
| `Maslow_Harlow_1932_TABLE1_snapshot.csv` | the frozen snapshot: the table as printed |
| `Maslow_Harlow_1932_TABLE1.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Maslow_Harlow_1932_TABLE1.csv` | analysis-ready data ("use this") |
| `reference_tables/Maslow_Harlow_1932_TABLE1_definitions.csv` | data dictionary |
| `Maslow_Harlow_1932_TABLE1.README.md` | this file |

**Analysis rows** — 18 (one per animal). **Observation level** — individual animal.

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

The specimen roster for the Bronx Park zoo series: a printed animal number (1-18), family, genus,
species, estimated age and sex for 15 anthropoids and 3 lemuroids.

## Snapshot

Single header row, so CSV. 23 rows = caption, sub-caption, header, the `Suborder Anthropoidea`
section row, 15 animal rows, the `Suborder Lemuroidea` section row, 3 animal rows. Several FAMILY
cells wrap over two printed lines; a wrapped cell is still one printed row, so each numbered
animal is one snapshot row. Printed spellings kept (`Chimpanse`, `Porcarius`, `Cinnemalogus`,
`Ateleus`, `Lagotricha`, `Variegatus ruber`).

## Do not join this table to TABLE 2 on row position

TABLE 2 of the same paper lists the same 18 animals in a **different order** and under different
common names, and two of them contradict this table outright (errata E001, E002): TABLE 2's
fourth baboon is the "Hamadryas baboon" where this table has the guinea baboon *Papio papio*, and
TABLE 2's infant is a "Baby mandrill" where this table's only infant (animal 7) is a **drill**.
Each item therefore resolves species from the names its own table prints.

## Species

All 18 printed binomials have rows in `_keys/General/species_key.csv` under
`source_publication = Maslow_Harlow_1932`. Four are **low confidence** and are marked as such in
`species_basis`:

| printed | accepted | why |
|---|---|---|
| `Pithecus Andamanensis` ("pig tailed monkey") | *Macaca nemestrina* (`hypothesis`) | the common name says pig-tailed macaque, the epithet *andamanensis* is today *M. fascicularis umbrosa* |
| `Ateleus Ater` ("spider monkey") | *Ateles* sp. (`our_judgment`) | *ater* cannot be tied to one modern *Ateles* species |
| `Cebus Unicolor` ("hooded Capuchin") | *Cebus* sp. (`our_judgment`) | *unicolor* and "hooded capuchin" point to different modern taxa |
| `Lemur Rufus` ("brown mongoose lemur") | *Eulemur rufus* (`hypothesis`) | the common name points to *Eulemur mongoz*, the epithet to *E. rufus* (errata E003) |

## Table checks

None: the table prints no totals or other self-checking relation.

## What to look at first (human check)

- the two section rows, and animals 3-5, 9-10 and 13-15, whose FAMILY cells wrap over two lines -
  the easiest place to gain or lose a row;
- animals 6 and 7, both drills, and 14 and 15, both `Cebus Capucinus`, distinguished only by the
  AGE cell (`Adult` / `Baby (2 years)`, `Old adult` / `Young adult`);
- the ESTIMATED AGE column, where `Young adult` and `Baby (2 years)` wrap over two lines.

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
| Maslow_Harlow_1932-E003 | species_epithet_as_published | Table 1, p.99, animals 17 and 18 | 17. Nycticibidae (brown mongoose lemur)  Lemur  Rufus;  18. Nycticibidae (gray mongoose lemur)  Lemur  Mongoz |  | publication_ambiguity |  | proposed | For animal 17 the printed common name ('mongoose lemur') and the printed epithet ('Rufus') point to different species: the mongoose lemur is Eulemur mongoz, which is what animal 18 prints, while Lemur rufus is the red-fronted lemur Eulemur rufus. The paper gives no further description. | Kept as printed. accepted_name follows the printed binomial, with species_basis = hypothesis. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
