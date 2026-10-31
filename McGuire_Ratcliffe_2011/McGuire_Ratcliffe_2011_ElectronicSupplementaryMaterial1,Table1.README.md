# McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1

## Source
McGuire, L. P., & Ratcliffe, J. M. (2011). Light enough to travel: Migratory bats have smaller
brains, but not larger hippocampi, than sedentary species. *Biology Letters*, 7(2), 233–236.
https://doi.org/10.1098/rsbl.2010.0744

Electronic Supplementary Material 1, Table 1 (ESM pp. 1–2): "Body mass (g) and brain, neocortex,
hippocampus, cerebellum, and medulla oblongata volume data (mm3) for the 64 species considered in
our study". Sources in this folder: `rsbl20100744supp1.pdf` (the ESM, downloaded 2026-10-31 from
royalsocietypublishing.org — the supplement was behind a reCAPTCHA to automated fetch and was
retrieved by hand) and `McGuire_Ratcliffe_2011.pdf` (the paper, used for the citation of the
measurement source).

## Pipeline
| file | role |
|---|---|
| `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_extract_snapshot.R` | builds the frozen snapshot from the ESM PDF text layer (no value typed in the script) |
| `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_snapshot.csv` | frozen source: 66 rows = the 64 printed species rows in printed order plus the 2 printed group-summary rows; printed column order, printed blank cells, printed Family padding, printed reference numbers |
| `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_extract_references.R` | builds the references lookup from the ESM reference list and the paper's reference 17 |
| `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1.R` | reads the snapshot; harmonises species; writes CSV + public TSV; `table_checks` |
| `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1.csv` | one row per species (64 rows × 14 columns) |
| `reference_tables/McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_definitions.csv` | data dictionary |
| `reference_tables/McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_references.csv` | per-row source lookup (30 rows) |
| `reference_tables/McGuire_Ratcliffe_2011_errata.csv` | errata for this paper |
| `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_registry_row.xlsx` | registry row for the owner to paste |
| public TSV | `__Public/comparative-data/10.1098%2Frsbl.2010.0744_ElectronicSupplementaryMaterial1,Table1.tsv` |

## Reader / provenance
Snapshot built 2026-10-31 by an AI assistant with `pdftools::pdf_data` on ESM pp. 1–2: every cell
is placed in its column by the x position of its words, so the twelve rows that print only body
mass and brain volume keep four blank cells rather than shifting values left. Verified row by row
against a page render of ESM pp. 1–2 on the same date, reading across each row (species, then each
column heading) rather than down columns, with attention to the family block breaks and the rows
that carry blanks. The printed group-summary rows are kept as rows 65–66 of the snapshot.

## Data role
**secondary** throughout, with two distinct provenances that the item keeps apart:

1. **Measurements** — every body mass and volume comes from Baron, Stephan & Frahm (1996)
   *Comparative neurobiology in Chiroptera*, named in the ESM Table 1 caption and reference 17 of
   the paper. Column `measurement_source` carries the key `Baron_etal_1996` on all 64 rows. The
   caption also states the one transformation the authors applied: whole-brain volume is **derived**
   as brain mass / 1.036; the other five columns are volumes as published.
2. **Migration classification** — the Migratory/Sedentary call for each species, with the works
   supporting it printed per row as numbers keyed to the ESM's own reference list (1–30). Column
   `migration_category_ref_keys` keeps those keys verbatim, `"; "` separated.

This item is a roadmap to the primary source, not a substitute for it: deduplicate against
`Baron_etal_1996` before any merge.

## References resolved
All **29** distinct keys printed in the References column resolve to a full citation from the ESM's
own numbered reference list (ESM pp. 2–4); **0** unresolved. Entry **14** (Miller-Butterworth,
Jacobs & Harley 2003) is listed by the ESM but cited by no row of Table 1, so it has no row in the
references file. A 30th row carries the measurement source (`ref_key = Baron_etal_1996`,
`cited_in_column = measurement_source`), its citation read from reference 17 of the paper.

To use: split `migration_category_ref_keys` on `"; "` and join on `ref_key`; `measurement_source`
joins on `ref_key` directly.

Four strings in the ESM reference list are text-layer artefacts of the PDF, not print: the page
render shows `Mammalia`, `Mammals`, `helvum` and a superscript `th`, where the text layer yields
`Ma mmalia`, `Ma mmals`, `helvu m` and `4 th`. The extract script declares and asserts those four
repairs. Everything else is kept exactly as the ESM prints it, including `Sesaonal` (entry 10),
`de V. Pienar, U` and `C. Struick Publishers` (entry 6), `John Hopkins University Press`
(entry 18) and the spaced page range `251 -261` (entry 26); each is flagged in that row's `note`.

## Columns / units
Body mass in g, all five regional measures in mm3, as printed. Twelve of the 64 species print only
body mass and whole-brain volume; those four regional cells are blank in the CSV, as in the source.

## Species
`species_printed` keeps the printed binomial; `accepted_name` is resolved through
`_keys/Stephan/species_key.csv` (collection `Stephan`, `source_publication =
McGuire_Ratcliffe_2011`, 64 rows added 2026-10-31). Identity is from NCBI Taxonomy; where the
taxid already has a hub row in `_keys/species_reference.csv` the hub's `accepted_name` is used, so
this item lines up with the rest of the collection. 59 rows are `verbatim`, 1 `spelling`
(*Cynopterus horsfieldi* → *C. horsfieldii*) and 4 `synonym:NCBI` (*Hipposideros commersoni* →
*Macronycteris commersoni*; *Eptesicus serotinus* → *Cnephaeus serotinus*; *Pipistrellus nanus* →
*Afronycteris nanus*; *Chaerephon pumila* → *Mops pumilus*).

## Table checks
The ESM prints a Migratory and a Sedentary mean ± se under each of the six measurement columns.
The build recomputes all 12 from the 64 species rows and compares at printed precision (tolerance =
one unit of the printed decimal). **All 12 pass**, means and standard errors alike — actual R run
2026-10-31. The group n the build uses matches the printed n for body mass and brain volume
(31 and 33) and drops to 25 and 27 for the four regional columns, which is exactly the number of
species that print a value there.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/McGuire_Ratcliffe_2011_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| McGuire_Ratcliffe_2011-E001 | family_printed | ESM 1 Table 1, p. 1, Family column, block heading above Rhinolophus ferrumequinum | Rhinolophuidae | Rhinolophuidae | publication_error | Rhinolophidae | confirmed | ESM 1 p. 1 prints 'Rhinolophuidae' as the family label for the four Rhinolophus rows. No such family exists; the family of Rhinolophus is Rhinolophidae (Gray, 1825), spelt correctly elsewhere in the literature the ESM cites. The four species in the block (R. ferrumequinum, R. hipposideros, R. landeri, R. mehelyi) are all Rhinolophidae. | The analysis CSV keeps the printed label in family_printed, per the convention that a publication error is flagged, not corrected. Only the family label is affected; no measurement or species name is involved. |

1 recorded, 0 open (proposed), 1 confirmed, 0 withdrawn.
<!-- errata:end -->
