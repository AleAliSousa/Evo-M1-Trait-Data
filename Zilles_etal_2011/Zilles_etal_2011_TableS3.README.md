# Zilles_etal_2011_TableS3

## Status — documentation completed, NOT FINISHED

Frozen source, R reader and analysis CSV already exist in this folder; this README was added on 2026-10-13 to complete the 4-file convention. It documents the existing files only — no data, script, snapshot, registry row or public TSV was changed. No registry invariant is claimed passed.

## Source → snapshot

Zilles, K., Amunts, K., & Smaers, J. B. (2011). Three brain collections for comparative neuroanatomy and neuroimaging. Annals of the New York Academy of Sciences, 1225(S1), E94–E104. https://doi.org/10.1111/j.1749-6632.2011.05978.x

Locus: **Supporting Information Table S3. Zilles-Amunts collection Homo sapiens** (listed under "Supporting information" at the end of the article; the article body refers to it under "Short catalogs of the collections", p. E95). Catalogue of the Zilles-Amunts collection: serial sections of complete human embryos, fetal, neonatal/postnatal and adult brains (paper text: 22 prenatal, 49 neonatal/postnatal up to 13 years, 38 adult brains; 42 adult brains additionally scanned by postmortem MRI before histology).

Source format is a digital-native journal supplement workbook, `nyas_5978_sm_table3.xls` (legible; machine-readable cell values, no OCR involved). Legibility is source-format metadata, not a measurement-confidence score. The article PDF `Zilles-2011-Three brain collecti.pdf` is held in this folder for context only; the table itself is not printed in the article.

`Zilles_etal_2011_TableS3_snapshot.xlsx` (sheet `TableS3`) was generated from the supplement by `Zilles_etal_2011_build_snapshot.py`: it copies the sheet title ("Zilles-Amunts Collection of human brains"), the 10 header cells and every non-blank row in order, converting whole-number numeric cells to integers and stripping non-breaking spaces. Note that the house rule for born-digital sources is to keep the untouched download as the frozen copy; here the original `.xls` is kept unchanged alongside the derived `.xlsx` snapshot. Human visual curation of the snapshot against the supplement is pending.

## Snapshot → data readable

Run `Zilles_etal_2011_TableS3.R` in a clean R session. With `rebuild_snapshot <- FALSE` it reads the existing snapshot (and only calls the Python helper if the snapshot is missing), names the 10 columns, squishes whitespace (so multi-line cells become single space-separated strings), drops blank rows; the build intends to carry Age-only heading rows (e.g. `prenatal`) down into `developmental_group`; keeps rows with a catalogue number, adds `source_row`, and writes `Zilles_etal_2011_TableS3.csv` (152 records). It then looks up `Item encoded` by exact `Item name` in `__ReadMe.xlsx` Sheet1 and writes the public TSV to `__Public/comparative-data/`, stopping if no registry code exists.

Units: Body weight g and fresh brain weight **g** as printed (not converted to mg); age as printed (weeks/days/years); section thickness µm; values kept as printed text, `---` = not given.

Observation level: **one row per catalogued specimen** (an individual brain/section series), not species means. Pool to species before any species-level use.

Data role: **primary** (specimen catalogue of the authors' own collection). [TO CHECK: registry `Data role` not verified.] The table is a collection catalogue (specimen metadata with body and fresh brain weights), not a measurement table of brain structures.

## Known limitations

- `developmental_group` is `prenatal` for all 152 records: only the first Age-only heading matches the build's heading rule, so later developmental stages are not separated. [TO CHECK: fix the heading rule in the `.R`; do not use `developmental_group` as is.]
- The printed section heading `Human brains with postmortem MRI (3-D FLASH) before histological processing` sits in the catalogue column and is kept as a specimen record (`source_row` 110) with otherwise empty fields. [TO CHECK: should be treated as a heading.]
- Four multi-line continuation rows without catalogue number (extra hemispheres/brain-stem series) are removed by the `!is.na(catalogue_number)` filter. [TO CHECK]
- Brain weight remains in g; convert ×1000 in the build before any merge.
- `Species_binomial` = `Homo sapiens` is a build-added constant (the table prints no species column; the source legend and text state human).
- Multi-value cells (several stainings / distances per specimen) are collapsed into one space-separated string; the pairing between stainings and distances is positional only.

## QA and online database

No public comparison folder exists, and no independent 0-mismatch audit is claimed. [TO CHECK: whether the committed CSV was produced by an R run of `Zilles_etal_2011_TableS3.R`; no execution log is held in the folder.] Definitions: `reference_tables/Zilles_etal_2011_TableS3_definitions.csv` (existing; created 2026-09-28). Expected analysis rows: **152**.

Pending: owner registry check; clean R audit → dry run → build → validate; human visual curation of the snapshot; collection-scoped species mapping; resolution of the [TO CHECK] items above before any merge.
