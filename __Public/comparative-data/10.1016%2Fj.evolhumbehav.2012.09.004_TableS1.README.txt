# Grueter_etal_2013_TableS1

Grueter, C. C., Bissonnette, A., Isler, K., & van Schaik, C. P. (2013). Grooming and group cohesion in primates: implications for the evolution of language. Evolution and Human Behavior, 34(1), 61-68. https://doi.org/10.1016/j.evolhumbehav.2012.09.004

## Source and extraction

Original `1-s2.0-S1090513812000931-mmc1.docx` copied byte-for-byte to `Grueter_etal_2013_TableS1_snapshot.docx`. SHA-256 `ed70511d7b6e59aa76499abba0d1f625d8cb6a06f5599a9f3c4280532e5b0857`. Reader: Codex, 2026-10-21, using readxl for XLSX and xml2 for DOCX, with independent Python value checks. No transcription or human visual sign-off is claimed for these author-tabulated digital files.

Table S1 has 131 group/population records. Rows are not species means. The R script reads the first table directly from the frozen DOCX XML. Species, sites, source attributions and comments are retained; numeric parsing occurs only in derived columns, with exact printed numeric cells retained. Parenthesized community/band sizes are separate from party/unit sizes. UNK, NA, ? and blanks are missing, not zero. Notes qualify Presbytis potenziani grooming as <0.1 and Colobus angolensis group size as >300; these bound-only cells stay in the source CSV but are excluded from display means. Mixed allogrooming/self-grooming and social-behaviour proxies remain explicitly noted. Same-group repeated observations and population averages are retained, so the display is an unweighted record mean, not an independent or sample-weighted species estimate. Seven Karisoke Gorilla beringei rows are labelled primary in Data_role; conservative merged display role is secondary for the table as a whole.

## Outputs and wiring

`Grueter_etal_2013_TableS1.R` produces `Grueter_etal_2013_TableS1.csv` (131 rows) and `__Public/comparative-data/10.1016%2Fj.evolhumbehav.2012.09.004_TableS1.tsv`. All metadata columns are described in `reference_tables/Grueter_etal_2013_TableS1_definitions.csv`. Printed species names are resolved downstream by `_keys/resolve_species.R`; unresolved and historical labels are retained without inventing identities.

Mapped to source-specific variables in `__merging_supplementary/supplementary_sources.csv`, explicitly marked secondary. These views preserve coverage while avoiding averaging compilation repeats into existing primary measurements. They are not independent source counts. No color-vision or vocal-repertoire measurement occurs in this supplement.

## Registry and rebuild

Live registry insertion is pending. `Grueter_etal_2013_TableS1_registry_row.xlsx` follows the live 34-column registry layout and contains owner paste instructions. The explicit staging identities used for this build are in `ManyPrimates__2022/ManyPrimates_supplements_build_registry.xlsx`. Before owner insertion, run from the repo root:

```sh
DATASET_REGISTRY=ManyPrimates__2022/ManyPrimates_supplements_build_registry.xlsx Rscript Grueter_etal_2013/Grueter_etal_2013_TableS1.R
```

After registration, run the same R script without the environment variable. The live registry determines the public TSV name. The supplementary merge reads the explicit local CSV path and therefore does not depend on insertion timing.

## Table checks

No printed additive total is available. Structural extraction and parsing checked against the DOCX XML and an independent python-docx reader.

Cross-source coverage and verification reports are private under `restricted_checks/_cross_table/ManyPrimates_20261021` in the restricted repository.
