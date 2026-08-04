# Betz cells / layer-5 corticospinal neurons in M1 (compile-from-literature)

Scaffold for Tier-3 candidate #9 in `SCOUTING_candidate_papers_20260731.md` (kept per curator,
2026-07-31): the giant layer-5 pyramidal (Betz) neurons that are the cortical origin of the fastest
corticospinal axons — a **regional M1** sub-trait directly tied to motor-cortex specialisation.

## Regional M1 — never pooled with whole-cortex counts

Betz densities/sizes belong with `__merging_cellcounts` as a **regional (M1-only) sub-trait**,
analogous to how `M1_Surface_Area.mm2` sits apart from whole-cortex surface in
`__merging_cortical_areas` (`trait_class = regional`). They must **never** be pooled with whole-cortex
neuron counts. Sits naturally beside Young et al. 2013 (already in the repo: M1 cell count / surface
area / mass, `Young_etal_2013_Table1`).

## Why hand-built

No single comparative table of per-species Betz counts exists; values are scattered across
stereology/morphology papers. Follow the printed/scanned route of `__HOWTO_build_a_dataset_file.md`:
hand-verified `Betz_cells_M1_snapshot.xlsx` (one row per species, value + source) → `.R` → analysis
CSV + compilation TSV → definitions → README.

## Candidate traits

- `Betz_density_M1` — Betz cells per mm² (or per mm³) in M1 layer 5 (state the unit per source).
- `Betz_soma_size` — mean Betz soma cross-sectional area / diameter.
- `Betz_proportion_L5` — Betz as a fraction of layer-5 pyramidal / pyramidal-tract neurons (where
  reported).

Report each with its **stat** and **unit** exactly as the source gives it (stereology vs 2-D counts
are not interchangeable — flag the method per datum, as the cellcount lineage does).

## Sources to compile (gather locally; network policy blocked fetches in-session)

- Review / entry point: *Betz cells of the primary motor cortex.* J Comp Neurol (2024).
  DOI **10.1002/cne.25567** — synthesises comparative Betz data (human vs macaque vs great ape
  proportions and distribution) and cites the primary counts to compile from.
- Primary comparative stereology/morphology of Betz / giant layer-5 corticospinal neurons across
  primates and other mammals (the papers reviewed above; e.g. Sherwood/Jacobs-lineage motor-cortex
  stereology). Confirm and cite per-species values individually.

## Build outline

1. Hand-build `Betz_cells_M1_snapshot.xlsx` (`Species_printed`, `species_sci`, the trait column(s),
   `stat`, `units`, `method`, `Source`; preserve printed names — invariant 3).
2. `Betz_cells_M1.R`: snapshot → resolve via `_keys` → analysis CSV + compilation TSV.
3. `reference_tables/Betz_cells_M1_definitions.csv` (scaffolded).
4. Register in `__ReadMe.xlsx`; **role = secondary** (compilation); `Team = Betz_compilation`;
   `Subcategory = regional (M1)`.
5. Add a `standardized_term_by_reference/…` file and item to `__merging_cellcounts` **as a regional
   sub-trait** (its own standardized terms — do not map onto whole-cortex neuron-count terms).
