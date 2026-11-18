# Gonzalez-Voyer et al. 2016 — Dryad brain data (596 species)

Gonzalez-Voyer A, González-Suárez M, Vilà C, Revilla E (2016). *Larger
brain size indirectly increases vulnerability to extinction in mammals.*
Evolution 70: 1364–1375. doi:10.1111/evo.12943.
Data package: Dryad doi:10.5061/dryad.m2tj3.

Species-level **brain mass (g)** and **adult body mass (g)** for **596
mammal species** — complete for both masses on all 596 rows — plus
gestation, litter size, weaning age, population density and IUCN status,
with the literature sources for each row named in `References`.

## What we built

- **Frozen sources:** the Dryad CSV and its README PDF, verbatim, in
  this folder.
- **Reformat:** `GonzalezVoyer_etal_2016_BrainData.R` adds `species_sci`
  (printed name, underscores replaced by spaces; printed name preserved
  as `Species_name`) and writes:
  - `GonzalezVoyer_etal_2016_BrainData.csv` (596 rows)
  - `public_tsv/10.1111%2Fevo.12943_BrainData.tsv` (public, DOI-encoded
    — name is the expected Item encoded; see Registry)
- **Definitions:** `reference_tables/GonzalezVoyer_etal_2016_BrainData_definitions.csv`.
- **Reader:** the CSV/TSV were produced by Muse (Buddy), Michael
  Proulx's AI assistant, with a Python equivalent of the .R build and
  cross-checked against the frozen source (596 rows, no duplicates,
  brain+body mass present for all rows). **R execution of the .R script
  is pending** — the script reproduces the same outputs.

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

## Registry

The public TSV name above is the expected Item encoded
(10.1111%2Fevo.12943_BrainData). Adding the registry row in
`__ReadMe.xlsx` is an owner step, as is any ingestion into a merge.
