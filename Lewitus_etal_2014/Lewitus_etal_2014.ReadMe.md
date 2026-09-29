Lewitus et al 2014
tsvs already in comparative data folder https://github.com/r03ert0/comparative-data/ 

* [Table S8 from Lewitus et al 2014](https://github.com/r03ert0/comparative-data/blob/master/10.1371%252Fjournal.pbio.1002000_TableS8.tsv) Neurone number and gyrification index for 25 species

not directly referred to: 10.1371%2Fjournal.pbio.1002000_TableS1.tsv

## Items in this folder

Each item's snapshot (if any), R script, CSV and README share the `__ReadMe.xlsx` Item name; the
script writes the CSV here and the DOI-named TSV to `__Public/comparative-data/`.

| Item name | Source | Build | Notes |
|---|---|---|---|
| `Lewitus_etal_2014_TableS1` | `pbio.1002000.s013.xlsx` (digital-native, read directly) | `Lewitus_etal_2014_TableS1.R` | `Lewitus_etal_2014_TableS1.README.md` |
| `Lewitus_etal_2014_TableS8` | `pbio.1002000.s020.xlsx` (digital-native, read directly) | `Lewitus_etal_2014_TableS8.R` | `Lewitus_etal_2014_TableS8.README.md` |
| `Lewitus_etal_2014_ExternalDatabaseS1references` | `pbio.1002000.s021.doc` → `Lewitus_etal_2014_ExternalDatabaseS1references_snapshot.xlsx` | `Lewitus_etal_2014_ExternalDatabaseS1references.R` | `Lewitus_etal_2014_ExternalDatabaseS1references.README.md` |
| `Lewitus_etal_2014_ExternalDatabaseS1variablesources` | `pbio.1002000.s021.doc` → `Lewitus_etal_2014_ExternalDatabaseS1variablesources_snapshot.xlsx` | `Lewitus_etal_2014_ExternalDatabaseS1variablesources.R` (run after the references script) | `Lewitus_etal_2014_ExternalDatabaseS1variablesources.README.md` |

Table S2 definitions (`pbio.1002000.s014.xlsx`) are summarised in
`reference_tables/Lewitus_etal_2014_TableS1_definitions.csv`.

## Restricted checks

The comparisons, the source audit and the per-species External Database S1 provenance are in the
restricted repo, `Evo-M1-Trait-Data-restricted/restricted_checks/Lewitus_etal_2014/comparison/`:
`Lewitus_SOURCE_AUDIT.md` (+ `.html`), `Lewitus_etal_2014_ExternalDatabaseS1_provenance.csv`,
`Lewitus_etal_2014_Neocortex_source_attribution.csv`, `README_neocortex_source_check.md` and the
`*_compare_to_*.R` scripts.
