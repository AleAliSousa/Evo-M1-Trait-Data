Source

Unsure - check this - found in the Expensive Brain project

--> Snapshot

Falcone_etal_2019_TABLE1_snapshot.csv

--> Data readable   

Falcone_etal_2019_TABLE1.csv <-- USE THIS

--> Online database

Added TSV copy named with DOI to https://github.com/r03ert0/comparative-data

 <-- ONLINE COPY

## Snapshot layout audit (2026-11-27)

Compared local PDF Table 1. Restored the two header tiers, infraclass section
rows, and blank repeated taxonomy labels in the ten-column source grid. The R
reader fills those labels and expands printed `r` to the established analysis
value. Corrected obvious older extraction placements: Macropodidae and
Didelphidae now occupy Family, and Scandentia no longer inherits Rodentia's
Muroidea suborder. Ran `Rscript Falcone_etal_2019/Falcone_etal_2019_TABLE1.R`;
the derived CSV changes only those four taxonomy cells. Species labels and
ILA observations are otherwise unchanged.
