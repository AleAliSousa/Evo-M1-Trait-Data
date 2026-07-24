# Burger et al. 2019 — Supplementary Data SD1 (brain & body mass)

Burger JR, George MA Jr, Leadbetter C, Shaikh F (2019). *The allometry of brain size in mammals.*
Journal of Mammalogy 100(2):276-283. doi:10.1093/jmammal/gyz043

Supplementary Data **SD1** — brain-size data for **1,552 mammal species**: mean brain mass and
mean body mass (grams), sample sizes, sex, and one or two primary literature references per
brain-mass value. SD2 (`gyz043_suppl_supplement_material.docx`) holds the full reference list.

## What we built
A house-style build was missing (the folder had only the raw supplement + a hand-placed public
TSV). Now built to convention:

- **Frozen source (digital-native, no snapshot):** the journal download
  `gyz043_suppl_Supplement_Data.csv` (14 columns, 1,552 rows) is machine-readable, so it **is** the
  frozen source — kept verbatim, never edited (see `__HOWTO_build_a_dataset_file.md` §0a invariant 1).
  The earlier `_snapshot.xlsx` was a redundant re-save and has been removed.
- **Reformat:** `Burger_etal_2019_SupplementaryDataSD1.R` reads the source CSV directly, adds the accepted
  binomial as `species_sci` (via `_keys/*/species_key.csv` + `species_reference.csv`; printed
  `Binomial` preserved), and writes:
  - `Burger_etal_2019_SupplementaryDataSD1.csv` (analysis-ready)
  - `__Public/comparative-data/10.1093%2Fjmammal%2Fgyz043_SupplementaryDataSD1.tsv`
    (public, DOI-encoded — **regenerated with `species_sci`**, replacing the earlier hand-placed
    copy that lacked it)
- **Definitions:** `reference_tables/Burger_etal_2019_SupplementaryDataSD1_definitions.csv`.

## Data role
**Secondary (compilation).** Each brain-mass value carries its own primary reference
(`BrainReference1/2`); the underlying primaries are the merge-worthy sources. Body mass and brain
mass are both compiled here.

## Quality caveats (from the source)
- `Brain.resid` / `T_resid` are **not reproducible** — the authors could not reproduce them and
  advise deriving residuals anew from a current phylogeny. Kept for provenance, flagged
  `do not use as-is` in the definitions.
- Volumes were converted at **1 cm³ = 1 g** where a source reported volume (per Burger et al.,
  following Isler & van Schaik 2009).
- Subspecies were pooled to species by sample-size-weighted means (source methods).
- A few body-mass values look anomalous in the source itself (e.g. *Aotus lemurinus* 9,026 g,
  *Tapirus bairdii* 14,260 g) — these are in SD1 as published and are surfaced by the
  `__merging_body_ecology` disagreement report, not introduced here.

## Species names
Printed `Binomial` (Wilson & Reeder 2005) preserved; `species_sci` added via the project key.
**176** of the 1,552 species map to the project's core reference species (brain + body mass);
more resolve to accepted names known to other collections. No synonym bridges were added (the
overlap is already broad); add rows to `species_key.csv` (source_publication = Burger2019) if a
specific project species needs recovering.

## Registry
Already registered in `__ReadMe.xlsx` Sheet1 (row 27): Publication `Burger_etal_2019`, 1st Author
Burger, year 2019, DOI 10.1093/jmammal/gyz043, Item `Supplementary Data SD1`, encoded
`10.1093%2Fjmammal%2Fgyz043_SupplementaryDataSD1` (matches the public TSV). Progress stage set to
FINISHED.

## Downstream use
Body mass feeds `__merging_body_ecology` (secondary role). Brain mass is a candidate for a
brain-mass / volumes cross-check. Both are all-mammal (1,552 species).

## Checks
- Analysis CSV = 1,552 rows (one per species; no duplicate binomials). First-party compilation;
  no independent curated copy to audit against.
