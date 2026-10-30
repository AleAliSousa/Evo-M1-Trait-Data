# Bush & Allman 2004b — Table 2 (cortical region volumes, 55 species)

Bush EC, Allman JM (2004). *The scaling of frontal cortex in primates and carnivores.*
PNAS 101(11):3962-3966.

Full title (`__ReadMe.xlsx`): **"Table 2. Volumes for cortical regions for 55 species of mammals (cm3)"**
(called Table 2 in text though linked under Supporting Information).

## Source -> Snapshot
HTML download from the PNAS site (`05760table2.html`). `Bush_Allman_2004b_Table2_snapshot.csv` =
faithful parse: 55 species x FrG, RoG, FrRat, WhBr, NeoG, NeoW, Act, Diet, Gr, Grsz (cm3).

## Data readable
`Bush_Allman_2004b_Table2.R` -> `Bush_Allman_2004b_Table2.csv` / `.tsv` (use this): columns renamed
(frontal_grey, rest_of_cortex_grey, frontal_ratio, whole_brain, neocortex_grey, neocortex_white +
activity/diet/group), **species harmonized** to `_keys/Stephan/species_key.csv`. Includes primates +
carnivores; filter on the primate subset for Study 3.

## Comparisons (comparison/)
- `check_Table2_vs_digitized.csv` - vs your `bush_neocortex.xls`: **251/275 cells match** (24 cells to
  review - likely rounding in the digitized copy).
- `compare_NeoG_Bush_vs_Frahm.csv` - cross-dataset, neocortex grey vs Frahm (`NeoG_Frahm`, your Stephan
  data): Bush runs **~3-12% smaller** for shared primates (Homo -5.0%, Pan -5.5%, Hylobates -3.3%;
  Aotus an outlier at -33%). So Bush and Frahm neocortex are NOT interchangeable - use one consistently.

## Relevance to Study 3 (Heiss structures)
Adds neocortex grey/white + a frontal-cortex measure across many species; complements Frahm neocortex
and Smaers frontal. Whole-brain present, so part-whole (rest-of-brain) can be computed.

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species harmonized -> Online database
