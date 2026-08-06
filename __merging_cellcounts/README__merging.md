# Merging cell-counts data

Pipeline for compiling the comparative brain cell-count dataset.

## Steps

1. **Standardized term list** — `standardized_term.R`
   - Input: one term file per table in `standardized_term_by_reference/`
     (`<Reference>_standardized_terms.csv`, columns `Original_Term, Reference, Standardized_Term`).
   - Output: `standardized_term_cellcounts.csv` (all per-reference files stacked).

2. **Compile cell counts** — `cellcounts_compiled.R`
   - Merges, filters, and calculates variables across datasets.
   - Inputs: `__Public/comparative-data/*.tsv`, `__ReadMe.xlsx`, `standardized_term_cellcounts.csv`.
   - Outputs: `cellcounts_long.csv`, `cellcounts_wide.csv`.
   - Checks: `cellcounts_unfiltered.csv`; `cellcounts_conflictcheck.R`.
   - Species names: `cellcounts_source_species_ids.csv`.
   - Flagged datasets: `*_metadata_flags.csv`.

3. **Imputations** — `cellcounts_imputations_diagnostic.R` → `imp30x10.RData`.

## Adding a paper

1. Create `standardized_term_by_reference/<Reference>_standardized_terms.csv` (its terms → standardized terms).
2. Register it in `__ReadMe.xlsx` (Item name → Item encoded) and add it to the `item_name` vector in `cellcounts_compiled.R`.
3. Put its DOI-coded table in `__Public/comparative-data/<Item encoded>.tsv`.
4. Re-run `standardized_term.R`, then `cellcounts_compiled.R`.

Most recent addition: `AvelinodeSouza_etal_2025_TABLE1` (*Balaenoptera acutorostrata*, the minke whale).

## Corrections

- **2026-06 — HH-2020 Table 2 derived masses (unit fix), step 3.4.**
  Regional masses not reported in Herculano-Houzel et al. 2020 Table 2
  (`CerebralCortex_Mass.g`, `Cerebellum_Mass.g`, `RoB_Mass.g`) are back-calculated
  from neuron count ÷ neuronal density. Because `_N.p.mg` is neurons per **mg**,
  `_N.n / _N.p.mg` is a mass in **mg** and must be divided by 1000 to get grams.
  The code previously **multiplied** by 1000, inflating those masses by **10⁶** for
  the ~13 African bats in that table (whole-brain masses, reported directly, were
  unaffected). Corrected to `(_N.n / _N.p.mg) / 1000`. Re-run the pipeline to
  propagate the fix.

- **2026-06 — Burish et al. 2010 (two fixes).**
  (a) *Brain = whole brain*: Burish's "Brain" (`MBR`, `NBR`) is the whole brain, so it is now
  mapped to `WholeBrain_Mass.g` / `WholeBrain_N.n` in its standardized-terms file (rather than a
  separate `Brain_*` measure that duplicated WholeBrain). The `Brain_*` measure no longer exists.
  (b) *Units*: Burish tabulated cell COUNTS in **millions** (e.g. *Macaca mulatta* brain "6380" =
  6.38×10⁹ neurons; spinal-cord neuron/other counts likewise). Step 3.4b in `cellcounts_compiled.R`
  now multiplies `WholeBrain_N.n`, `SpinalCord_N.n(_SD)`, `SpinalCord_O.n(_SD)` by 1e6. Masses (g),
  densities (per mg) and percentages were already absolute and are unchanged. A density sanity scan
  (neurons / (mass×1000) should be ~50–3,000,000 /mg) flagged only Burish; JardimMesseder et al. 2017
  and the other datasets were within range. Re-run `standardized_term.R` then `cellcounts_compiled.R`.

- **Dos Santos et al. 2020 — published Table 1 excluded; authors' unpublished data used instead.**
  The published Table 1 (main PDF) contains transcription/typographical errors in several cell-count
  values, some physically impossible (neurons or microglia exceeding total cells; e.g. *Tragelaphus
  strepsiceros* whole-brain cells = 21,751,929, ~1000× too small — the unpublished value is
  21,751,929,128). The authors supplied an updated **unpublished** spreadsheet
  (`2020-PublishedDataMammalsMicroglia - cópia.xlsx`; received 22 Mar 2024 via O. S. Todorov from the
  authors' team). Independent checks (`DosSantos_etal_2020/DosSantos_etal_2020_Table1_check.R`; summary
  `DosSantos_etal_2020_comparison_summary.md`) show the unpublished data is internally consistent and
  agrees with older publications (Herculano-Houzel et al. 2015). Therefore `item_name` uses
  `DosSantos_etal_2020_unpublished` (commented out `DosSantos_etal_2020_Table1`). The unpublished file
  contributes the microglia/cell ratio (`*_I.p.C`); cell **numbers** for these species come from older
  primary sources. The published Table 1 is kept only as a reference snapshot.

## Within-team resolution: most recent wins (worked example, Kazu 2015)

`cellcounts_compiled.R` §8.2 builds a `worth_dataframe` per team, sorting sources by **date
descending, then number of species descending**, and assigns `priority` = row number. §8.3 then
marks every row `WORSE` whose priority is above the minimum for that **species × variable**, and
drops it. So a newer table from the same team supersedes an older one automatically, per
species × variable — there is no manual column filtering and no per-source exclusion list to
maintain.

`Kazu_etal_2015_TABLE1` (added 2026-08-06) is the worked example, and it is instructive because
the date *ties*:

- Kazu is Herculano-Houzel–team work, so it is resolved in §8.2.H alongside `HerculanoHouzel_etal_2015`
  Tables 1–5. Both are dated **2015**.
- The tie-break on species count hands the shared variables to HH (≈40 species against 5).
- Simulated against the published TSVs before wiring: of the five Kazu species,
  **80 species × variable pairs are held by both → HH wins**; **87 pairs are sub-structure values
  only Kazu has** (hippocampus 20, pons + medulla 20, diencephalon + basal ganglia 16,
  mesencephalon 16, cortical grey matter 15); **21 more are whole-structure values HH happens to
  lack for those species**. Kazu contributes 108 values and duplicates none.
- Of the 80 overlapping pairs, **none differ by more than 2%** — HH 2015's full-precision values
  already are the corrigendum's, so which source wins does not change the data. That is the check
  worth repeating whenever a same-team, same-year source is added: if the overlap *disagreed*, the
  priority rule would be silently choosing between two different measurements rather than two
  printings of one.

The older printing, `Kazu_etal_2014_Table1`, is not in `item_name` and should never be: the
corrigendum changed 71 of the 184 cells present in both, and the 2014 values fail
`N_BR = N_CXT + N_CB + N_RoB` by up to −22%. Even if it were listed, its 2014 date would put it
below both — but leaving it out keeps the intent explicit.
