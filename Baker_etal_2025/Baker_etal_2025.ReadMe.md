Source

1. Go to Source: Article Online Link to supplementary data
https://www.nature.com/articles/s41467-025-66843-0#Sec16

2. Download the file linked there:
Supplementary Data 1 — species-level brain and body mass data (4,679 species).
Publisher filename: 41467_2025_66843_MOESM3_ESM.xlsx

3. The download is digital-native (XLSX with sheets "Data S1" and
"Reference List"), so it is kept verbatim in this folder as the frozen
source — no snapshot is made (see
`_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md`
§0a invariant 1).

--> USE THIS FILE: 41467_2025_66843_MOESM3_ESM.xlsx

Build: `Baker_etal_2025_SupplementaryData1.R` extracts the mammal rows
(1,684 species) to `Baker_etal_2025_SupplementaryData1.csv` and to the
DOI-coded public TSV. See `Baker_etal_2025_SupplementaryData1.README.md`
for the data role (secondary compilation), caveats, checks, and the
registry step that is still pending.

Quality Notes:

1. Each row's `Source` column names the publication the value was compiled
   from; full citations are on the frozen source's "Reference List" sheet.

2. Whole-brain masses only: the authors excluded masses reported excluding
   the olfactory bulb, excluded juveniles, and converted endocranial
   volumes to mass at 1 g = 1 cm3 where only volumes were available. The
   per-row basis is not flagged — see the item README before any merge use.

3. Folder added 2026-11-16 by Muse (Buddy), Michael Proulx's AI assistant,
   at Michael Proulx's request; registry row in `__ReadMe.xlsx` and any
   merge ingestion remain owner steps.
