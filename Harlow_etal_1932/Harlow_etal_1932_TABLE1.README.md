# Harlow_etal_1932_TABLE1

**Source** — Harlow, H. F., Uehling, H., & Maslow, A. H. (1932). Comparative behavior of primates. I.
Delayed reaction tests on primates from the lemur to the orang-outan. *Journal of Comparative
Psychology*, 13(3), 313-343. https://doi.org/10.1037/h0073864

**Item** — TABLE 1, "Classification of the animals" (printed page 316).

| file | what it is |
|---|---|
| `Harlow_etal_1932_TABLE1_snapshot.csv` | the frozen snapshot: the table as printed |
| `Harlow_etal_1932_TABLE1.R` | reformat: snapshot -> analysis CSV + public TSV |
| `Harlow_etal_1932_TABLE1.csv` | analysis-ready data ("use this") |
| `reference_tables/Harlow_etal_1932_TABLE1_definitions.csv` | data dictionary |
| `Harlow_etal_1932_TABLE1.README.md` | this file |

**Analysis rows** — 24 (one per animal). **Observation level** — individual animal (several animals share a species).

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

The specimen roster: family, genus, species, the animal's familiar (individual) name, estimated
age and sex for the 23 anthropoids and 1 lemuroid tested. **It is the key that gives Tables 2-6
their species**: those tables print only loose taxon words plus the familiar name, and each of
their build scripts joins back to this snapshot on `familiar_name`.

## Snapshot

Flat single-header layout, so CSV. 31 rows = caption, sub-caption, header, the
`Suborder Anthropoidea` section row, the italic `years` units row, 23 animal rows, the
`Suborder Lemuroidea` section row, 1 animal row, and the footnote. Printed spellings kept
(`sooty mangaby`, `mustached guenon`, `Pongiidae`, `Nycticibidae`), as is the `*` on `Simia`.
Ages are typed `11 1/2` / `1 1/2` for the printed vulgar fractions.

## What the script does

Reads the frozen CSV positionally, carries the suborder heading down, keeps the rows that print a
SEX value, splits the FAMILY cell into family and parenthetical common name, strips the footnote
marker off the genus into its own column, parses `11 1/2` to 11.5, and resolves
`genus + epithet` through `_keys/resolve_species.R` against `_keys/General/species_key.csv`.

## Species

Elliot (1913) nomenclature throughout: `Pithecus` for macaques, `Lasiopyga` for guenons,
`Papio sphinx` for the mandrill, `Simia sylvanus` for the Barbary ape (the printed footnote
discusses this genus explicitly), `Lemur variegatus` for the ruffed lemur. All 14 printed
binomials have rows in `_keys/General/species_key.csv` under
`source_publication = Harlow_etal_1932`; none is left unresolved. The two assignments that rest
on the printed **common** name rather than the epithet are `Cercocebus Aethiops` ("sooty
mangaby" -> *Cercocebus atys*; the epithet *aethiops* today denotes a different animal) and
`Lasiopyga Callitrichus` ("green guenon" -> *Chlorocebus sabaeus*).

## Table checks

None: the table prints no totals, percentages or other self-checking relation.

## What to look at first (human check)

- the two section rows and the italic `years` row - an inserted or dropped row here shifts
  every animal below it;
- the five consecutive `Macacus rhesus` rows and the three consecutive `mandrill` rows, where a
  one-row slip would be invisible in the FAMILY column;
- the ages `11 1/2`, `1 1/2` (three animals) and `20` - the vulgar fractions are easy to misread.

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
