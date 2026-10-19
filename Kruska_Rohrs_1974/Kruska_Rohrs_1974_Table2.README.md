# Kruska_Rohrs_1974_Table2 — Table 2, feral pigs from the Galapagos Islands (volumes, mm3)

Source: Kruska & Rohrs (1974), doi 10.1007/BF00518633 (folder PDF).
Snapshot: `Kruska_Rohrs_1974_Table2_snapshot.csv` (frozen, transcribed from the publication; not edited by the reader).
Reader: `Kruska_Rohrs_1974_Table2.R` parses the snapshot by row label and writes `Kruska_Rohrs_1974_Table2.csv` and the public TSV named by registry Item encoded (`10.1007%2Fbf00518633_Table2.tsv`).
Registry: Data role primary; Progress stage FINISHED; no skip flag.

## Checks run
- Reader run in a scratch copy with Rscript: exit 0, 84 rows (4 specimens x 21 structure rows).
- Independent re-parse of the snapshot in Python: 0 mismatches in volume_mm3 across all rows.

## Caveats
The table mixes parent and sub-structure rows (Amygdaloid complex with a) and b) sub-rows; Palaeocortex + Amygdaloid complex; limbic structures). The reader keeps every printed row as printed; no hierarchy is summed. The footnote "a Damaged olfactory bulb." has no marker in the row labels, so the affected value is not identified. Brain weight and brain volume are footer rows carried as specimen columns, not structure rows. Percentages are not printed in this table.

## Provenance
Snapshot transcription: earlier session (see the original snapshot and the folder's source PDF).
Reader written 2026-10-17 by an AI assistant from the snapshot. No value is typed in the script.
