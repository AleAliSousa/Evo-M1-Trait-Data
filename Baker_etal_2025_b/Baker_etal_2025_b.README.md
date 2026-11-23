> **Folder name:** this is the second Baker, Barton & Venditti paper from 2025
> added to this repo, so it sits in `Baker_etal_2025_b` (the `Smaers_etal_2011_b`
> precedent). `Baker_etal_2025` (no suffix) is the same authors' *Communications
> Biology* paper, "Human dexterity and brains evolved hand in hand"
> (doi:10.1038/s42003-025-08686-5) — a different paper and dataset.

Source

1. Go to Source: Article Online Link to supplementary data
https://www.nature.com/articles/s41467-025-66843-0#Sec16

2. Download the file linked there:
Supplementary Data 1 — species-level brain and body mass data (4,679 species).
Publisher filename: 41467_2025_66843_MOESM3_ESM.xlsx

3. The download is digital-native (XLSX with sheets "Data S1" and
"Reference List"), so no snapshot is made: it is kept verbatim in
this folder under its original name, is listed in the registry under
that name (the item's "Snapshot filename" field), and the build
script reads it directly. Nothing was re-saved or converted.

--> USE THIS FILE: 41467_2025_66843_MOESM3_ESM.xlsx

Build: `Baker_etal_2025_b_SupplementaryData1.R` reads only that
file, extracts the mammal rows (1,684 species) to
`Baker_etal_2025_b_SupplementaryData1.csv` and to the DOI-coded public
TSV. See `Baker_etal_2025_b_SupplementaryData1.README.md` for the data
role (secondary compilation), caveats and checks. Registry row in
`__ReadMe.xlsx` added 2026-11-17 (item Baker_etal_2025_b_SupplementaryData1).

Quality Notes:

1. Each row's `Source` column names the publication the value was compiled
   from; full citations are on the frozen source's "Reference List" sheet.

2. Whole-brain masses only: the authors excluded masses reported excluding
   the olfactory bulb, excluded juveniles, and converted endocranial
   volumes to mass at 1 g = 1 cm3 where only volumes were available. The
   per-row basis is not flagged — see the item README before any merge use.

3. Folder added 2026-11-16 by Muse (Buddy), Michael Proulx's AI assistant,
   at Michael Proulx's request; rebuilt to the snapshot-first form in
   `_skills/build-dataset-item` on 2026-11-18.
