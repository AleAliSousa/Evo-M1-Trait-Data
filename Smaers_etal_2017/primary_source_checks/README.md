# Primary-source checks for the "Smaers dataset" (Smaers et al. 2017, Table S1)

Smaers et al. 2017 (Current Biology) names "the Smaers dataset" in the main text, but the values are
given **only in the supplement** (Table S1) and several primary sources are cited **only there** —
including **S6 = de Sousa et al. 2010 (Cereb Cortex)** for striate/extrastriate (primary visual).
This folder traces every value to its **primary** source and verifies it.

## Convention
- `../Smaers_etal_2017_TableS1{_snapshot}.csv` = faithful to the **secondary** source (Smaers 2017).
- `../Smaers_etal_2017_TableS1_primary_sources.csv` = column -> primary source map (with Smaers S-refs
  and where the raw data lives in this repo).
- `Smaers_etal_2017_attributed_long.csv` = the **corrected/alternative** table: one row per
  species x region x matter, tagged with the primary source; `primary_value` + `abs_diff` to be filled
  from the primary source, then flagged match/mismatch.

## Primary-source attribution (from the Smaers 2017 supplement)
- Prefrontal & frontal-motor (gray+white) <- Smaers 2010 PLoS One [S1] + Smaers 2011 BBE [S2]
  (raw individual data: `../../Smaers_etal_2011/`).
- Primary visual (gray+white) <- **de Sousa et al. 2010 [S6]** (your striate/extrastriate paper).
- Other cortical association <- de Sousa 2010 extrastriate / derived — **VERIFY** in Table S1 footnote.
- Brodmann surface-area block <- Brodmann 1909 [S3] (separate sub-table).

## Checks to run (secondary vs primary)
1. **Primary visual vs de Sousa 2010** — compare Smaers-2017 primary-visual to your de Sousa V1
   (`ASG_Sousa`, `Primary.visual.White.Smaers`). Mind units (Smaers labels mm3 but values scale cm3).
2. **Prefrontal/motor vs Smaers 2011** — aggregate Smaers_etal_2011 raw (Supp Tables) to species and
   compare. NB: 2011 reports total frontal + section-interval bootstrapping, so the prefrontal/motor
   split must be reconstructed before a cell-by-cell check.
3. Record diffs; where the secondary mis-transcribes the primary, prefer the primary (per
   `__ReadMe.xlsx` Conflicts sheet ordering).
