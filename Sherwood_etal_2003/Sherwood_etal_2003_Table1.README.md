# Sherwood et al. 2003 — Table 1 (Betz & Meynert cell soma volumes + literature covariates)

Sherwood CC, Lee PWH, Rivara C-B, Holloway RL, Gilissen EPE, Simmons RMT, Hakeem A, Allman JM,
Erwin JM, Hof PR (2003). *Evolution of specialized pyramidal cells in primate visual and motor
cortex.* Brain Behav Evol 61:28–44. doi:10.1159/000068879.

Registry: **`Sherwood_etal_2003_Table1`**, encoded `10.1159%2F000068879_Table1`; stage blank →
set after R rerun.

## What the data are
**25 taxa** (23 primates + *Tupaia glis*, *Pteropus poliocephalus*). Two data layers in one table:

- **PRIMARY (this study):** soma volumes (µm³; planar rotator, ~225 neurons/region/individual) —
  mean/SD/CV for M1 infragranular pyramids, **Betz cells**, V1 infragranular pyramids, **Meynert
  cells**. n = 1–5 individuals per taxon. Directly relevant to the Betz_cells_M1 scaffold
  (Jacobs lineage).
- **SECONDARY (literature):** neocortex volume (mm³), brain + body weight (g), EQ (Martin 1981),
  diet/habitat, group size, dexterity index. Per-value sources resolved from **column-header
  defaults** (neocortex=Stephan 1981, brain=Harvey 1987, body=Fleagle 1999, diet/habitat=
  Clutton-Brock & Harvey 1980, group=Rowe 1996, dexterity=Heffner & Masterton 1983) with
  **per-cell superscript overrides** (Baron 1996, Zilles & Rehkämper 1988, Groves 2001, Dunbar
  1992, personal observation) — carried in the `*_ref` columns. Never ingest these secondary
  columns as independent values; their primaries (Stephan 1981, Baron 1996, Zilles & Rehkämper
  1988, Heffner & Masterton 1983) are already repo folders or registry rows.

## Source → Snapshot → Data readable
Text extraction flattened the superscript markers into the numbers ("2,710²" → "2,7102"), so
**every right-block cell was disambiguated against the rendered page image** (journal p. 31);
left block from `pdftotext -layout` (journal p. 30). Frozen in
`Sherwood_etal_2003_Table1_snapshot.xlsx` (sheets `Table1`, `notes`). `.R` → `.csv` (**use
this**) + public TSV. Built offline 2026-08-31 (Python mirror) — re-run the .R in RStudio.

Pipeline: Source ✅ → Snapshot ✅ → Data readable ✅ → Registry stage ⬜ → R rerun ⬜ → Merge ⬜
