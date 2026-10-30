# Bush & Allman 2003 — Table 1 (neocortex + cerebellum GM/WM, 45 mammals)
Bush EC, Allman JM (2003). *The scaling of white matter to gray matter in cerebellum and neocortex.* Brain Behav Evol 61(1):1-5.
Full title (`__ReadMe.xlsx`): **"Table 1. White matter and gray matter volumes (cm3) for neocortex and cerebellum for 45 mammals"**
## Source->Snapshot
PDF p.2 (text layer). `..._Table1_snapshot.csv` = faithful (group headers kept). 45 species: Cer White, Cer Gray, Neo White, Neo Gray (cm3).
## Data readable
`..._Table1.R` -> `..._Table1.csv`/`.tsv` (use this): species harmonized to `_keys/Stephan/species_key.csv`; `group` retained.
## Comparisons (comparison/)
- `check_Table1_vs_compiled.csv` vs your `bush_compiled.xlsx`: **84/84 cells match**.
- `compare_NeoG_vs_Frahm.csv`: neocortex grey vs Frahm `NeoG_Frahm` (5 shared primates) - cross-dataset.
(NB Table 2 = regression slopes/CIs, not species trait data; not extracted.)
Pipeline: Source->Snapshot OK->Data readable OK->Species harmonized->Online database
