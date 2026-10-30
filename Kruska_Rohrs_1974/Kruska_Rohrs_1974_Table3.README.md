# Kruska_Rohrs_1974_Table3 — Table 3, domestic pigs (volumes, mm3)

Source: Kruska & Rohrs (1974), doi 10.1007/BF00518633 (folder PDF).
Snapshot: `Kruska_Rohrs_1974_Table3_snapshot.csv` (frozen, transcribed from the publication; not edited by the reader).
Reader: `Kruska_Rohrs_1974_Table3.R` parses the snapshot by row label and writes `Kruska_Rohrs_1974_Table3.csv` and the public TSV named by registry Item encoded (`10.1007%2Fbf00518633_Table3.tsv`).
Registry: Data role primary; Progress stage FINISHED; no skip flag.

## Checks run
- Reader run in a scratch copy with Rscript: exit 0, 126 rows (6 specimens x 21 structure rows).
- Independent re-parse of the snapshot in Python: 0 mismatches in volume_mm3 across all rows.

## Caveats
Same layout as Table 2; the mixed parent and sub-structure rows apply here too, so do not sum rows. Percentages are not printed in this table.

## Provenance
Snapshot transcription: earlier session (see the original snapshot and the folder's source PDF).
Reader written 2026-10-17 by an AI assistant from the snapshot. No value is typed in the script.
