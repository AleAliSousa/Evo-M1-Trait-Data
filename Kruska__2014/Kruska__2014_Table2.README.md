# Kruska__2014_Table2 — Table 2, wild cavies (brain-structure volumes and % of pure brain tissue)

Source: Kruska DCT (2014), Mammalian Biology, doi 10.1016/j.mambio.2013.12.005 (folder PDF).
Snapshot: `Kruska__2014_Table2_snapshot.csv` (frozen, transcribed from the publication; not edited by the reader).
Reader: `Kruska__2014_Table2.R` parses the snapshot by row label and writes `Kruska__2014_Table2.csv` and the public TSV named by registry Item encoded (`10.1016%2Fj.mambio.2013.12.005_Table2.tsv`).
Registry: Data role primary; Progress stage FINISHED; no skip flag.

## Checks run
- Reader run in a scratch copy with Rscript: exit 0, 144 rows (6 specimens x 24 structure rows).
- Independent re-parse of the snapshot in Python: 0 mismatches in volume_mm3 and pct_of_pure_brain_printed across all rows.

## Caveats
Hierarchy reconciles exactly in the header arithmetic (total - rest - ventricle = pure brain, checked to 0.01 mm3 in the reader). The structure rows are hierarchical (e.g. Telencephalon = Neocortex + Corpus striatum + Allocortex); do not sum them.

## Provenance
Snapshot transcription: earlier session (see the original snapshot and the folder's source PDF).
Reader written 2026-10-17 by an AI assistant from the snapshot. No value is typed in the script.
