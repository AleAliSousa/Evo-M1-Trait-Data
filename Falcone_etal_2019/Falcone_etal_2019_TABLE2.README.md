Source

Unsure - check this - found in the Expensive Brain project

--> Snapshot

Falcone_etal_2019_TABLE2_snapshot.csv

--> Data readable   

Falcone_etal_2019_TABLE2.csv <-- USE THIS

--> Online database

Added TSV copy named with DOI to https://github.com/r03ert0/comparative-data

 <-- ONLINE COPY
## Snapshot layout recheck (2026-11-27)

Compared Table 2 with the local born-digital PDF, printed p. 1665. The
snapshot now keeps the ten printed columns (four taxonomic hierarchy columns,
Species, and A–E), the two infraclass section rows, source order, blank cells,
and the A–E definition below the table. The R reader assigns analysis names
and numeric values. Run from the repository root:
`Rscript Falcone_etal_2019/Falcone_etal_2019_TABLE2.R`.
The rebuilt 47-row analysis CSV matches the prior version cell for cell.

The PDF prints **Cercocebus kandti** in its Species column. The former
snapshot instead said **Cercopithecus kandti**. The snapshot now preserves
the printed source label; the R reader explicitly maps that one source label
to the existing analysis label. This is a transcription/provenance correction,
not a taxonomic resolution or independent human source signoff.
