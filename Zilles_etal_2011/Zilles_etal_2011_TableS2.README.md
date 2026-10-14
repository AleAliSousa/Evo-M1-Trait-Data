# Zilles_etal_2011_TableS2

## Status — documentation completed, NOT FINISHED

Frozen source, R reader and analysis CSV already exist in this folder; this README was added on 2026-10-13 to complete the 4-file convention. It documents the existing files only — no data, script, snapshot, registry row or public TSV was changed. No registry invariant is claimed passed.

## Source → snapshot

Zilles, K., Amunts, K., & Smaers, J. B. (2011). Three brain collections for comparative neuroanatomy and neuroimaging. Annals of the New York Academy of Sciences, 1225(S1), E94–E104. https://doi.org/10.1111/j.1749-6632.2011.05978.x

Locus: **Supporting Information Table S2. Zilles collection vertebrates** (listed under "Supporting information" at the end of the article; the article body refers to it under "Short catalogs of the collections", p. E95). Catalogue of the Zilles collection: serial sections of reptile, marsupial, insectivore, rodent, lagomorph and nonhuman-primate brains (paper text: prepared c. 1977 onward by Karl Zilles).

Source format is a digital-native journal supplement workbook, `nyas_5978_sm_table2.xls` (legible; machine-readable cell values, no OCR involved). Legibility is source-format metadata, not a measurement-confidence score. The article PDF `Zilles-2011-Three brain collecti.pdf` is held in this folder for context only; the table itself is not printed in the article.

`Zilles_etal_2011_TableS2_snapshot.xlsx` (sheet `TableS2`) was generated from the supplement by `Zilles_etal_2011_build_snapshot.py`: it copies the sheet title ("Zilles Collection"), the 11 header cells and every non-blank row in order, converting whole-number numeric cells to integers and stripping non-breaking spaces. Note that the house rule for born-digital sources is to keep the untouched download as the frozen copy; here the original `.xls` is kept unchanged alongside the derived `.xlsx` snapshot. Human visual curation of the snapshot against the supplement is pending.

## Snapshot → data readable

Run `Zilles_etal_2011_TableS2.R` in a clean R session. With `rebuild_snapshot <- FALSE` it reads the existing snapshot (and only calls the Python helper if the snapshot is missing), names the 11 columns, squishes whitespace (so multi-line cells become single space-separated strings), drops blank rows; group heading rows are carried down into `collection_group` verbatim, including the printed misspellings `Varightous`, `Masupalia` and `Simier`; keeps rows with a catalogue number, adds `source_row`, and writes `Zilles_etal_2011_TableS2.csv` (119 records). It then looks up `Item encoded` by exact `Item name` in `__ReadMe.xlsx` Sheet1 and writes the public TSV to `__Public/comparative-data/`, stopping if no registry code exists.

Units: Body weight g and fresh brain weight **g** as printed (not converted to the project unit mg); section thickness µm; values kept as printed text, `---` = not given.

Observation level: **one row per catalogued specimen** (an individual brain/section series), not species means. Pool to species before any species-level use.

Data role: **primary** (specimen catalogue of the authors' own collection). [TO CHECK: registry `Data role` not verified.] The table is a collection catalogue (specimen metadata with body and fresh brain weights), not a measurement table of brain structures.

## Known limitations

- One multi-line continuation row of the snapshot without catalogue number is removed by the build's `!is.na(catalogue_number)` filter. [TO CHECK]
- Species names are printed as common names, abbreviations or truncations (e.g. `Tortoise`, `Tachyglossus acule.`, `Castor Myeer`, `Notomys spec?`); mapping to binomials is pending in the collection-scoped species key.
- The `code` column's meaning is not stated in the source. [TO CHECK]
- Brain weight remains in g; convert ×1000 in the build before any merge. [TO CHECK]
- Multi-value cells (several stainings / distances per specimen) are collapsed into one space-separated string; the pairing between stainings and distances is positional only.

## QA and online database

No public comparison folder exists, and no independent 0-mismatch audit is claimed. [TO CHECK: whether the committed CSV was produced by an R run of `Zilles_etal_2011_TableS2.R`; no execution log is held in the folder.] Definitions: `reference_tables/Zilles_etal_2011_TableS2_definitions.csv` (added 2026-10-13 alongside this README). Expected analysis rows: **119**.

Pending: owner registry check; clean R audit → dry run → build → validate; human visual curation of the snapshot; collection-scoped species mapping; resolution of the [TO CHECK] items above before any merge.
