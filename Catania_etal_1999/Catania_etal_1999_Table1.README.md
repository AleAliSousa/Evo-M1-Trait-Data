# Catania et al. 1999 — Table 1

Source: Catania, K. C., Lyon, D. C., Mock, O. B., & Kaas, J. H. (1999). Cortical organization in shrews: Evidence from five species. *Journal of Comparative Neurology, 410*(1), 55–72. https://doi.org/10.1002/(SICI)1096-9861(19990719)410:1<55::AID-CNE6>3.0.CO;2-2

`Catania_etal_1999_Table1_snapshot.csv` is a faithful transcription of the printed Table 1. Cells retain the source convention `area mm² (percent of total neocortex)`, including printed dashes. The snapshot also preserves the table's misspelling `Cryptopus parva`; the cleaned file stores that in `species_as_published` while normalizing `Species` to *Cryptotis parva*. `Catania_etal_1999_Table1.R` reshapes the table to one measured structure × case row and writes the analysis CSV and public TSV.

The item contains seven hemispheres from *Sorex cinereus*, *Blarina brevicauda*, and *Cryptotis parva*. Area borders came from chemoarchitecture, supplemented by electrophysiology where available; all measurements were made after fixation in 2% paraformaldehyde, with no shrinkage correction stated. Most component sums agree within printed rounding, but case 2A does not: A1 + V1 + S1/S2 is 4.70 mm² while total sensory cortex is printed as 5.0 mm². The builder preserves both values and flags every row from that case.
