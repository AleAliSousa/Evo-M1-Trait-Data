# Nunn_Samson_2018_SupplementaryTable1

Nunn, C. L., & Samson, D. R. (2018). Sleep in a comparative context: Investigating how human sleep differs from sleep in other primates. American Journal of Physical Anthropology, 166(3), 601–612. https://doi.org/10.1002/ajpa.23427

## Source and extraction

Original `ajpa23427-sup-0001-suppinfot1.xlsx` copied byte-for-byte to `Nunn_Samson_2018_SupplementaryTable1_snapshot.xlsx`. SHA-256 `0ec629b106a88b6b7bc4705190317b570fd7980a4960ff0b891825a61f43dc84`. Reader: Codex, 2026-10-21, using readxl for XLSX and xml2 for DOCX, with independent Python value checks. No transcription or human visual sign-off is claimed for these author-tabulated digital files.

Sheet primate_data_V3.csv: header row 3; species rows 4–33. ECV cm3 is converted to mm3 and body mass kg to g. TST, REM and NREM are hours/day. Activity_period retains D/N/C. Sleep_method, Brain_value_basis and Day_range_basis are constructed metadata from Methods pp.603–604, not extra observations. All nonhuman sleep data are captive. Orangutan sleep stages use videography, and six newly added lemur TST values use actigraphy. Methods report reused ECV for Varecia and Eulemur sister species and a Propithecus genus mean. Diet breadth includes genus medians, and day range includes congeneric proxies. These values must not be counted as new direct measurements. Folivory is a binary diet indicator, not percent leaves; diet breadth categories differ from PanTHERIA.

## Outputs and wiring

`Nunn_Samson_2018_SupplementaryTable1.R` produces `Nunn_Samson_2018_SupplementaryTable1.csv` (30 rows) and `__Public/comparative-data/10.1002%2Fajpa.23427_SupplementaryTable1.tsv`. All metadata columns are described in `reference_tables/Nunn_Samson_2018_SupplementaryTable1_definitions.csv`. Printed species names are resolved downstream by `_keys/resolve_species.R`; unresolved and historical labels are retained without inventing identities.

Mapped to source-specific variables in `__merging_supplementary/supplementary_sources.csv`, explicitly marked secondary. These views preserve coverage while avoiding averaging compilation repeats into existing primary measurements. They are not independent source counts. No color-vision or vocal-repertoire measurement occurs in this supplement.

## Registry and rebuild

Live registry insertion is pending. `Nunn_Samson_2018_SupplementaryTable1_registry_row.xlsx` follows the live 34-column registry layout and contains owner paste instructions. The explicit staging identities used for this build are in `ManyPrimates__2022/ManyPrimates_supplements_build_registry.xlsx`. Before owner insertion, run from the repo root:

```sh
DATASET_REGISTRY=ManyPrimates__2022/ManyPrimates_supplements_build_registry.xlsx Rscript Nunn_Samson_2018/Nunn_Samson_2018_SupplementaryTable1.R
```

After registration, run the same R script without the environment variable. The live registry determines the public TSV name. The supplementary merge reads the explicit local CSV path and therefore does not depend on insertion timing.

## Table checks

Executed in R on 2026-10-21: {'pass': 13, 'mismatch': 7, 'not_evaluable': 10}. REM + NREM compared with TST, tolerance 0.015 h for printed rounding. Independently compiled means need not sum exactly. Published values are retained.
- Chlorocebus_aethiops: sum minus TST = -0.076 h.
- Erythrocebus_patas: sum minus TST = -0.050 h.
- Eulemur_mongoz: sum minus TST = -0.020 h.
- Homo_sapiens: sum minus TST = -0.030 h.
- Macaca_arctoides: sum minus TST = 0.030 h.
- Papio_hamadryas: sum minus TST = 0.050 h.
- Saimiri_sciureus: sum minus TST = -0.150 h.

Cross-source coverage and verification reports are private under `restricted_checks/_cross_table/ManyPrimates_20261021` in the restricted repository.
