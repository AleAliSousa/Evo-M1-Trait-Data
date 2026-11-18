# Gonzalez-Voyer et al. 2016 — Dryad brain data (596 species)

Gonzalez-Voyer A, González-Suárez M, Vilà C, Revilla E (2016). *Larger
brain size indirectly increases vulnerability to extinction in mammals.*
Evolution 70: 1364–1375. doi:10.1111/evo.12943.
Data package: Dryad doi:10.5061/dryad.m2tj3.

Species-level **brain mass (g)** and **adult body mass (g)** for **596
mammal species** — complete for both masses on all 596 rows — plus
gestation, litter size, weaning age, population density and IUCN status,
with the literature sources for each row named in `References`.

## Source → Snapshot → Data readable → Online database

- **Source:** the authors' data package on Dryad
  (doi:10.5061/dryad.m2tj3), downloaded 2026-11-18.
- **Snapshot:** none — the file is digital-native. The untouched
  Dryad download is kept verbatim in this folder under its original
  name (`Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv`), is listed
  in the registry (the item's "Snapshot filename" field in
  `__ReadMe.xlsx`), and the build script reads it directly. Nothing
  was re-saved or converted. The package's own README PDF is kept in
  this folder as provenance; it holds the reference list that the
  data file's `References` keys (e.g. `1|2`) point into.
- **Data readable:** `GonzalezVoyer_etal_2016_BrainData.R` reads
  **only** that file, adds `species_sci` (printed name with
  underscores replaced by spaces; the printed name is preserved as
  `Species_name`), carries every published value over verbatim, and
  writes `GonzalezVoyer_etal_2016_BrainData.csv` (596 rows) and the
  public TSV. The script runs clean under Rscript and reproduces the
  committed CSV/TSV exactly.
- **Definitions:** `reference_tables/GonzalezVoyer_etal_2016_BrainData_definitions.csv`.
- **Online database:** public TSV `10.1111%2Fevo.12943_BrainData.tsv`
  in `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `GonzalezVoyer_etal_2016_BrainData`).

## Data role and caveats

- **Secondary compilation.** Values are species means the authors
  compiled from the per-row literature sources (averaging multiple
  estimates where available). The file does not flag which brain masses
  derive from endocranial volumes.
- **Relation to González-Lagos et al. (2010):** same research group,
  expanded coverage (596 vs 493 species). The 2010 dataset — the direct
  source of Castillo-Morales et al. 2016's Ei — was never deposited in
  a repository; this release is its closest openly citable descendant.
  Ei on the 2010 definition (ln[brain / body^0.64]) can be recomputed
  from this file's two mass columns, but the result is an Evo-M1-side
  derivation, not a value published in either paper.
- Domestic forms are largely absent (e.g. no *Vicugna pacos* row).
