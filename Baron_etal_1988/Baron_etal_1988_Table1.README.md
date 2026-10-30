# Baron_etal_1988_Table1

## Source

PDF: `baron_etal_1988_scan.pdf`. Paper: Baron, G., Frahm, H. D., and Stephan, H. (1988), *Comparison of brain structure volumes in Insectivora and Primates* (vestibular nuclear complex), Journal fuer Hirnforschung.

Table 1 — volumes (mm3, both sides) of the vestibular nuclear complex and its four nuclei.

## Layout (organised like Baron_etal_1983/1987)

Final outputs (csv, tsv) come only from the snapshot. Checking is self-contained in `comparison/`. Taxonomy/anatomy homogenisation across papers lives in the shared `../_keys/`.

| Path | Role |
|---|---|
| `Baron_etal_1988_Table1_snapshot.xlsx` | Faithful capture (sheet `Table1_snapshot`): caption, structure-code header, 76 species, abbreviation key. |
| `Baron_etal_1988_Table1.R` | Preparation -> `Baron_etal_1988_Table1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Baron_etal_1988_definitions.csv` | Data dictionary: the 5 codes -> structures + unit. |
| `comparison/Baron_1988.csv` | Formatted table, audited only. |
| `comparison/Baron_etal_1988_Table1_compare_to_Baron_1988_csv.R` | Checking (QA): snapshot vs `Baron_1988.csv`. |

## Structures

`VC` complexus vestibularis (whole complex); `VI` n. vestibularis descendens; `VL` n. vestibularis lateralis; `VM` n. vestibularis medialis; `VS` n. vestibularis superior. All volumes in mm3, both sides.

## Preparation -> `Baron_etal_1988_Table1.csv`

One row per species (76). Columns: `Species_Baron1988` + the five volume columns `VC, VI, VL, VM, VS` (numeric). Also writes a DOI-named TSV to `../__Public/comparative-data/`.

## Checking -> `comparison/`

Matches the snapshot to `Baron_1988.csv` by species and compares the five volumes (mapping the CSV's full structure names to codes). Verified: 0 value mismatches.
