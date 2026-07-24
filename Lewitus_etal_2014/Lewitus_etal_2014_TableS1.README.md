# Lewitus et al. 2014 — Table S1 (physiological & life-history variables)

Lewitus E, Kelava I, Kalinka AT, Tomancak P, Huttner WB (2014). *An adaptive threshold in
mammalian neocortical evolution.* PLoS Biology 12(11):e1002000. doi:10.1371/journal.pbio.1002000

Table S1 = **"Physiological and life-history variables"** for 104 mammal species: brain/body/
neonate weights, neocortex volume, gyrification index (GI), ventricle volume, glia:neuron ratio,
neuronal & glial densities, basal metabolic rate, and ~30 life-history / ecology variables
(lifespan, gestation, litter size, diet, sociality, home range, …).

## Source → CSV → public TSV (digital-native: no snapshot)
This is a **digital-native** source, so the snapshot step is **skipped** — the journal's own
machine-readable supplement is already the durable, faithful copy, and freezing a second copy would
add nothing. The build reads the source **directly** and all cleaning is reproducible from it.

- **Source:** journal supplement `pbio.1002000.s013.xlsx` (Table S1; sheet `Sheet1`, row 1 = title,
  row 2 = header), kept in this folder. (Table S2 definitions = `pbio.1002000.s014.xlsx`; Table S9
  neuron numbers = `pbio.1002000.s020.xlsx`.)
- **Reformat:** `Lewitus_etal_2014_TableS1.R` reads the source directly, **corrects the journal's
  three header typos** (`Neuronal_denisty` → `Neuronal_density`, `Glial_cell_denisty` →
  `Glial_cell_density`, `Basal_metaboic_rate` → `Basal_metabolic_rate`), harmonises species (printed
  underscored name kept as `Species`, accepted binomial added as `species_sci` via the project key),
  and writes:
  - `Lewitus_etal_2014_TableS1.csv` (analysis-ready, corrected names; 104 species)
  - `__Public/comparative-data/10.1371%2Fjournal.pbio.1002000_TableS1.tsv` (via the
    `__ReadMe.xlsx` Item name → Item encoded lookup)

> The earlier build made a `Lewitus_etal_2014_TableS1_snapshot.xlsx` (a verbatim copy of the source,
> typos and all); under the current digital-native convention that snapshot is **retired / no longer
> read** by the build (kept only as legacy provenance). Delete it if you prefer a clean folder.

## Comparison (founder public TSV is the QA anchor)
`comparison/Lewitus_etal_2014_TableS1_compare_to_public_tsv.R` audits the build output against the
DOI-coded TSV that already existed in `__Public` before this project began (the "already there"
founder file). The founder TSV is treated **only as a comparison anchor — never as a snapshot**.
Matched by `Species`; every shared column except `species_sci`/`Species` is compared (numeric where
possible, else string; `NA` treated as missing). **Result: 104/104 species matched, 0 mismatched
cells across 39 compared columns** — the source-direct build reproduces the public TSV. This step
also regression-guards every future re-run (cf. Smaers 2011 Suppl. Table 2, where the same kind of
audit caught a rounded/decimal-dropped founder file and the public TSV was regenerated).

## Species names
Printed (underscored) names preserved in `Species`; accepted binomials in `species_sci`. 74 of 104
species resolve to a canonical binomial already in `_keys/species_reference.csv`.

## Provenance note (glia variables)
The glia:neuron ratio and neuronal/glial density columns appear in this supplement (Table S1) but are
not discussed in the Lewitus 2014 main text; they trace to Lewitus et al. 2012
(doi:10.1111/j.1558-5646.2012.01601.x), where "glia" = astrocytes + oligodendrocytes. Kept as
**secondary** for those columns.

## Data role
`Body_weight`, `Brain_weight_g`, `Neonate_brain_weight_g` are **secondary** (compiled in the volume/
cell-count merges). The GI, neocortex, density, and life-history/ecology variables are **primary**
here. Registry: already in `__ReadMe.xlsx` as `Lewitus_etal_2014_TableS1`.
