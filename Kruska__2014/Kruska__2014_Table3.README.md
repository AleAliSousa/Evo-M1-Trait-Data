# Kruska__2014_Table3 — Table 3, guinea pigs (brain-structure volumes and % of pure brain tissue)

Source: Kruska DCT (2014), Mammalian Biology, doi 10.1016/j.mambio.2013.12.005 (folder PDF).
Snapshot: `Kruska__2014_Table3_snapshot.csv` (frozen, transcribed from the publication; not edited by the reader).
Reader: `Kruska__2014_Table3.R` parses the snapshot by row label and writes `Kruska__2014_Table3.csv` and the public TSV named by registry Item encoded (`10.1016%2Fj.mambio.2013.12.005_Table3.tsv`).
Registry: Data role primary; Progress stage FINISHED; no skip flag.

## Checks run
- Reader run in a scratch copy with Rscript: exit 0, 144 rows (6 specimens x 24 structure rows).
- Independent re-parse of the snapshot in Python: 0 mismatches in volume_mm3 and pct_of_pure_brain_printed across all rows.

## Caveats
Same layout and checks as Table 2. The hierarchy is not summed by the reader; do not sum structure rows.

## Provenance
Snapshot transcription: earlier session (see the original snapshot and the folder's source PDF).
Reader written 2026-10-17 by an AI assistant from the snapshot. No value is typed in the script.
