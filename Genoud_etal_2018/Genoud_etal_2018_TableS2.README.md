# Genoud et al. 2018 — Table S2 (mammalian BMR database)

Genoud M, Isler K, Martin RD (2018). *Comparative analyses of basal rate of metabolism in mammals:
data selection does matter.* Biological Reviews 93(1):404–438. doi:10.1111/brv.12350.

Registry (`__ReadMe.xlsx`): Item name **`Genoud_etal_2018_TableS2`**, encoded
`10.1111%2Fbrv.12350_TableS2`.

## What the data are
A curated compilation of **basal metabolic rate (BMR)** for mammals: **1739 measurement rows**
covering **827 species**, each row an entry from the primary literature with **body mass (g)**,
**BMR (ml O₂/h)**, the original source, and the authors' full data-quality scoring. Granularity is
**per-measurement** (many species have several entries); the authors mark the best per-species value
via `ALL`/`SELECT`. Body mass ranges 2.2 g – 4037.5 kg.

## ⚠️ Compilation / secondary — whole-body BMR, not merged
Every value is drawn from the primary source named in `Authors` (with `Cited_value` /
`Source_unavailable` / `Secondary_reference` recording provenance). This is a **secondary**
compilation, built here for provenance and **not added to any merge**. Note also that **whole-body
BMR is a separate measure class** from cerebral metabolic rate, so it does **not** belong in
`__merging_cerebral_metabolic_rate` (it can inform `__energetics_comparison`). `Data role` in
`__ReadMe.xlsx` should be set to **secondary** (currently "review").

## Data-quality columns (keep, don't silently drop)
The paper's whole point is that *data selection matters*, so the selection machinery is preserved:
- `b, b1` — availability of a metabolic-rate-vs-temperature graph.
- `c–h` — the six standard BMR criteria (thermal neutrality, rest, postabsorptive, resting phase,
  adult, non-reproductive), scored `1 / 0 / -1`.
- `i–q` — additional concerns (taxon assignment, captivity, condition, body mass, protocol, …).
- `Ecrit`, `E` — overall 4-level evaluations (`E` = `Ecrit` corrected for `i–q`).
- `Accepted` (E∈{1,2}), `ALL` (best estimate/species), `SELECT` (best *accepted* estimate/species),
  `SPOILED`. **549 rows are `SELECT`.** Column meanings: `reference_tables/…_definitions.csv`.

## Source → Data readable (digital-native: no snapshot)
The source is a machine-readable journal workbook, so it **is** the frozen source (kept verbatim; no
derived snapshot — see `__HOWTO_build_a_dataset_file.md` §0a invariant 1).
`brv12350-sup-0003-tables2.xlsx` (sheet "Feuil1"; column legend in `brv12350-sup-0002-tables1.pdf`,
Table S1) → `Genoud_etal_2018_TableS2.R` → **`Genoud_etal_2018_TableS2.csv`** (use this) + the
public TSV `__Public/comparative-data/10.1111%2Fbrv.12350_TableS2.tsv`.

Units: body mass kept in **g** (project unit); BMR kept in **ml O₂/h** (source unit, unconverted —
it is a distinct measure class). `BMR_pct` is the source's *derived* value (% of the allometric
expectation BMR = 2.382·mass^0.729) and is carried as-is, not re-derived.

## Species names
The printed name is preserved as **`Species_Genoud2018`** (legend "Species original"); the accepted
binomial in **`Species`** is the source's own Wilson & Reeder (2005) harmonisation ("Species W&R"),
so the table is self-harmonising (Bush pattern). Because it is **not merged**, no rows were added to
`_keys/Stephan/species_key.csv`; add them (token `Genoud2018`, variant = `Species_Genoud2018`,
accepted = `Species`) if this table is ever brought into a merge.

## Build note
Generated in an environment without R; outputs were produced by the equivalent step and
`Genoud_etal_2018_TableS2.R` reproduces them from the frozen source (readxl → CSV + TSV with the
`Item encoded` lookup). Re-run in R to regenerate.

Pipeline: Source (frozen, digital-native) → Data readable ✅ → definitions ✅ → README ✅ → Data role (set to *secondary*) ⬜ · excluded from merges.
