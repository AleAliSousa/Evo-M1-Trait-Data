# Zilles_etal_2011_TableS1

## Status — documentation completed, NOT FINISHED

Frozen source, R reader and analysis CSV already exist in this folder; this README was added on 2026-10-13 to complete the 4-file convention. It documents the existing files only — no data, script, snapshot, registry row or public TSV was changed. No registry invariant is claimed passed.

## Source → snapshot

Zilles, K., Amunts, K., & Smaers, J. B. (2011). Three brain collections for comparative neuroanatomy and neuroimaging. Annals of the New York Academy of Sciences, 1225(S1), E94–E104. https://doi.org/10.1111/j.1749-6632.2011.05978.x

Locus: **Supporting Information Table S1. Stephan collection** (listed under "Supporting information" at the end of the article; the article body refers to it under "Short catalogs of the collections", p. E95). Catalogue of the Stephan collection: serially sectioned brains of insectivores, scandentia, bats, primates and miscellaneous mammals (paper text: brains collected and processed c. 1950–1980 by Heinz Stephan and others).

Source format is a digital-native journal supplement workbook, `nyas_5978_sm_table1.xls` (legible; machine-readable cell values, no OCR involved). Legibility is source-format metadata, not a measurement-confidence score. The article PDF `Zilles-2011-Three brain collecti.pdf` is held in this folder for context only; the table itself is not printed in the article.

`Zilles_etal_2011_TableS1_snapshot.xlsx` (sheet `TableS1`) was generated from the supplement by `Zilles_etal_2011_build_snapshot.py`: it copies the sheet title ("Stephan Collection"), the 9 header cells and every non-blank row in order, converting whole-number numeric cells to integers and stripping non-breaking spaces. Note that the house rule for born-digital sources is to keep the untouched download as the frozen copy; here the original `.xls` is kept unchanged alongside the derived `.xlsx` snapshot. Human visual curation of the snapshot against the supplement is pending.

## Snapshot → data readable

Run `Zilles_etal_2011_TableS1.R` in a clean R session. With `rebuild_snapshot <- FALSE` it reads the existing snapshot (and only calls the Python helper if the snapshot is missing), names the 9 columns, squishes whitespace (so multi-line cells become single space-separated strings), drops blank rows; taxonomic heading rows (Insectivora, Scandentia, Chiroptera, Primates, Miscellaneous species) are carried down into `collection_group`; keeps rows with a catalogue number, adds `source_row`, and writes `Zilles_etal_2011_TableS1.csv` (1363 records). It then looks up `Item encoded` by exact `Item name` in `__ReadMe.xlsx` Sheet1 and writes the public TSV to `__Public/comparative-data/`, stopping if no registry code exists.

Units: Body weight g and fresh brain weight mg as printed (mg is already the project brain unit); section thickness µm; values kept as printed text, no conversion.

Observation level: **one row per catalogued specimen** (an individual brain/section series), not species means. Pool to species before any species-level use.

Data role: **primary** (specimen catalogue of the authors' own collection). [TO CHECK: registry `Data role` not verified; see the overlap note below.] The table is a collection catalogue (specimen metadata with body and fresh brain weights), not a measurement table of brain structures.

## Known limitations

- Two multi-line continuation rows of the snapshot that carry no catalogue number are removed by the build's `!is.na(catalogue_number)` filter. [TO CHECK: whether these hold extra section series that should be attached to the preceding specimen.]
- Body weight is blank for 104 records and fresh brain weight for 99.
- Stephan-collection body and brain weights may coincide with values already published in earlier Stephan-group papers built elsewhere in this repo. [TO CHECK: cross-publication value match before any merge, to avoid double counting.]
- Multi-value cells (several stainings / distances per specimen) are collapsed into one space-separated string; the pairing between stainings and distances is positional only.

## QA and online database

No public comparison folder exists, and no independent 0-mismatch audit is claimed. [TO CHECK: whether the committed CSV was produced by an R run of `Zilles_etal_2011_TableS1.R`; no execution log is held in the folder.] Definitions: `reference_tables/Zilles_etal_2011_TableS1_definitions.csv` (added 2026-10-13 alongside this README). Expected analysis rows: **1363**.

Pending: owner registry check; clean R audit → dry run → build → validate; human visual curation of the snapshot; collection-scoped species mapping; resolution of the [TO CHECK] items above before any merge.
