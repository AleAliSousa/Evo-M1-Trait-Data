Source

1. Auto-Download Supplementary Data 3 at Source: 
https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-020-14356-3/MediaObjects/41467_2020_14356_MOESM6_ESM.xlsx

--> Snapshot

41467_2020_14356_MOESM6_ESM.xlsx <-- USE THIS

--> Online database

2. Opened in Numbers. Export To -> TSV -> Create a file for each table; Unicode (UTF-8) 

3. Copied Supplementary Data_3-Table 1.tsv and renamed as TSV named with DOI

10.1038%2Fs41467-020-14356-3_SupplementaryData3.tsv <-- ONLINE COPY

4. Manually added TSV copy named with DOI to https://github.com/r03ert0/comparative-data




Note:
1. Diel activity is available in Supplementary Data 4
(found association with acoustic communication)

2. Consider deleting because too encompassing. Almost all mammals, including all mammals in the sample for which there is data, have acoustic communication.


Rebuild (2026-09-28, AI assistant session; species-column fix)

- Frozen source: `Chen_Wiens_2020_SupplementaryData3_snapshot.xlsx` = byte-identical copy (cp) of
  `41467_2020_14356_MOESM6_ESM.xlsx` (sha256 9b803880...44694). The original download is kept too.
- Build: `Chen_Wiens_2020_SupplementaryData3.R` reads sheet "Supplementary Data_3" and writes
  `Chen_Wiens_2020_SupplementaryData3.csv` + `__Public/comparative-data/<Item encoded>.tsv`
  (Item encoded looked up by Item name in `__ReadMe.xlsx`). 1799 rows.
- Why: the earlier public TSV (step 2-3 above, Numbers export) carried a "Table 1" title line and
  parsed as a single column. The Numbers export subfolder `41467_2020_14356_MOESM6_ESM/` is left
  in place as provenance of that earlier copy; it is no longer used.
- Columns: `Species_printed` (as printed, Genus_species), `Species_binomial` (underscore -> space,
  `species_basis = spelling`), Family, Order, Class, State (0/1), References, source.
  Definitions: `reference_tables/Chen_Wiens_2020_SupplementaryData3_definitions.csv`.
