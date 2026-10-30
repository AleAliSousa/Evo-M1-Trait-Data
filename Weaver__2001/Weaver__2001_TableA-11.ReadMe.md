# Weaver__2001_TableA-11

## Source

PDF: `weaver_2001.pdf` (dissertation p. 240)

Paper: Weaver, A. G. H. (2001). *The cerebellum and cognitive evolution in Pliocene and Pleistocene hominids* [PhD dissertation, The University of New Mexico]. (UMI 3017523)

Table: **Table A-11: PCF and CBLM Volume from MRI Scans.** 34 specimens.

## What the table reports

Per MRI specimen: posterior cranial fossa (**PCF**) volume, cerebellum (**CBLM**) volume, and their ratio, across hominoids — Hylobates (Gi, n=4), Pongo (Or, n=4), Gorilla (GO, n=2), Pan (Pan, n=4), bonobo (Bo, n=3), and Homo sapiens (YH/CS, n=17). **PCF volume is a variable not present in Table A-15**, so this is genuinely additive primary data (individual-level, not means).

## Snapshot fidelity (scanned source)

Transcribed from a high-resolution render of p. 240 (the OCR is unreliable) and validated: the printed `CBLM/PCF` equals `CBLM ÷ PCF` for all 34 rows within rounding.

## Files

| Path | Role |
|---|---|
| `Weaver__2001_TableA-11_snapshot.csv` | Faithful transcription (caption + header + 34 rows). |
| `Weaver__2001_TableA-11.R` | Preparation: snapshot -> CSV (+ TSV). Expands taxon codes; converts cc -> mm³. |
| `Weaver__2001_TableA-11.csv` | Analysis-ready data, 34 rows (one per specimen). |
| `reference_tables/Weaver__2001_TableA-11_definitions.csv` | Data dictionary. |

## Units

PCF and CBLM volumes printed in **cc**; converted to project units **mm³** (× 1000). `CBLM/PCF` is a dimensionless ratio.

## Data role

`primary` — Weaver's own per-specimen MRI volumes (PCF, cerebellum).

## Registry note

Not currently in `__ReadMe.xlsx`. Found while mining the dissertation for additional real data. Proposed registry entry: `Item name` `Weaver__2001_TableA-11`, `Item encoded` `UMI%3A3017523_TableA-11` (see the proposed-registry xlsx). Until added, the `.R` writes the local CSV and skips the TSV with a warning.
