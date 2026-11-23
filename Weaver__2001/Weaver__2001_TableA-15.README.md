# Weaver__2001_TableA-15

## Source

PDF: `weaver_2001.pdf` (dissertation p. 244; "Notes" on p. 245)

Paper: Weaver, A. G. H. (2001). *The cerebellum and cognitive evolution in Pliocene and Pleistocene hominids* [PhD dissertation, The University of New Mexico]. Albuquerque, NM. (UMI 3017523)

Table: **Table A-15: Data for Raw and Derived Variables.** 29 specimens/taxa.

> **Folder-naming note.** The repo registry (`__ReadMe.xlsx`) lists the publication as **`Weaver__2001`** (double underscore, the single-author convention, cf. `MacLeod__2000`, `Kaufman__2004`). The clone also contains an older stub folder `Weaver_2001` (single underscore) holding only the PDF. This dataset was built under the registry-correct **`Weaver__2001`** (the PDF was copied in). The single-underscore `Weaver_2001` stub can be removed once this is merged.

## What the table reports

One row per specimen (fossils) or taxon mean (extant, marked `(n = X)`), with three **raw** variables — CBLM (cerebellum volume, cc), BoMass (body mass, kg), BrMass (brain mass, g) — and three **derived** variables — NetBrain (= BrMass − CBLM, g), CQ (cerebellar quotient, actual/predicted), EQ (encephalization quotient, Martin 1990). Definitions follow the dissertation's Tables 11-1 / 11-2.

## Snapshot fidelity (scanned source)

The page is a scan and OCR of the table is unreliable, so the snapshot was transcribed from a **high-resolution render** of p. 244 and independently checked: `NetBrain = BrMass − CBLM` holds for every one of the 29 rows within rounding, which validates the numeric transcription. The printed CQ header is truncated in the scan to `CQ (actual/` (the column is the cerebellar quotient = actual/predicted); this is preserved verbatim in the snapshot and clarified in the definitions.

## Files

| Path | Role |
|---|---|
| `Weaver__2001_TableA-15_snapshot.csv` | Faithful transcription of Table A-15 (caption + printed header + 29 rows). Source of truth. |
| `Weaver__2001_TableA-15.R` | Preparation: snapshot -> CSV (+ DOI/UMI-named TSV). Parses `n`, expands the group code, converts to project units. |
| `Weaver__2001_TableA-15.csv` | Analysis-ready data, 29 rows. "use this". |
| `reference_tables/Weaver__2001_TableA-15_definitions.csv` | Data dictionary. |

No `comparison/` folder: no independent curated copy of this dissertation table exists to audit against (allowed by the pipeline). The internal `NetBrain = BrMass − CBLM` identity serves as the transcription check.

## Units & conversions

CBLM cc → mm³ (×1000); BoMass kg → g (×1000); BrMass and NetBrain g → mg (×1000). Printed originals are kept alongside (`CBLM_cc`, `BoMass_kg`, `BrMass_g`, `NetBrain_g`). CQ and EQ are dimensionless relative indices.

## Data role

`both` — the fossil cerebellar/endocranial measurements are Weaver's own (primary); the extant monkey/ape/human values are taken from other sources (secondary — see `Weaver__2001_NotesforTableA-15`); NetBrain/CQ/EQ are derived. Add to a merge deliberately (per-variable, primary columns only).
