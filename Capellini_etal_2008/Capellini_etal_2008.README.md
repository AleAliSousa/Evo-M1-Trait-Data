# Capellini et al. 2008 — mammalian sleep (ecology & evolution reappraisal)

Source folder for a **sleep** source feeding `__merging_sleep` (candidate #4 in
`SCOUTING_candidate_papers_20260731.md`; kept per curator, 2026-07-31). Extends the sleep merge
**beyond its current primate-only REM coverage** to a broad mammalian sample.

## Source (freeze before cleaning)

Capellini, I., Barton, R. A., McNamara, P., Preston, B. T., & Nunn, C. L. (2008). *Phylogenetic
analysis of the ecology and evolution of mammalian sleep: a reappraisal.* Evolution 62(7):1764–1776.
DOI **10.1111/j.1558-5646.2008.00392.x**. Open copy: PMC2674385.

- **Why this over Lesku 2006:** Capellini et al. is a **curated, corrected re-compilation** of the
  same underlying mammalian-sleep data (Zepelin, Savage & West, Campbell & Tobler, Lesku 2006) — the
  cleaner single primary. Lesku, Roth, Amlaner & Lima (2006, Am Nat 168:441, DOI 10.1086/506973) is
  the antecedent; if both are ingested they are the **same lineage → resolve, never average**.
- **What it contributes:** total sleep time (TST) and its **REM** and **NREM/SWS** components for a
  broad mammal set (~tens of species, several new to this merge). Maps onto the two existing
  standardized terms.
- **Frozen source:** the paper's supplementary sleep table. Could not be pulled in the scaffolding
  session (network policy; no R). Download locally; keep verbatim; write the DOI-coded public TSV
  `__Public/comparative-data/10.1111%2Fj.1558-5646.2008.00392.x_<Table>.tsv` (invariant 2).

## Derivation (units) — do this in an `.R` build script, not by hand

The sleep merge's two standardized terms are:

| Standardized_Term | from Capellini | derivation |
|---|---|---|
| `Sleep_h_day`   | total sleep time (h/day) | direct copy |
| `REM_sleep_pct` | REM (h) and TST (h)      | `REM_sleep_pct = 100 * REM_h / TST_h` |

Write `Capellini_etal_2008_Table.R` that reads the frozen source, computes `Sleep_h_day` and
`REM_sleep_pct` (show the formula in a comment, per invariant 4), preserves the printed species name,
and writes the analysis CSV + the public TSV. The standardized-term map then just relabels those two
computed columns (below).

## Register + wire into `__merging_sleep`

1. `reference_tables/Capellini_etal_2008_definitions.csv` (scaffolded).
2. `__merging_sleep/standardized_term_by_reference/Capellini_etal_2008_<Table>_standardized_terms.csv`
   (scaffolded template) — maps the source columns to `Species` / `Sleep_h_day` / `REM_sleep_pct`.
3. Register in `__ReadMe.xlsx` Sheet1: `Item name = Capellini_etal_2008_<Table>`,
   `Item encoded = 10.1111%2Fj.1558-5646.2008.00392.x_<Table>`, `Data role = primary`,
   `Main Trait(s) = sleep (REM %, daily sleep)`, `Taxon group = Mammals`, `Team = Capellini_2008`.
4. In `__merging_sleep/sleep_compiled.R`: add the item to the `item_name` vector and to `team_of`
   (`Capellini_etal_2008_<Table> = "Capellini_2008"`), and add a read+relabel block mirroring the
   Herculano-Houzel binomial block (Capellini lists binomials → only spelling normalisation needed;
   no common-name resolution table required). Re-run `standardized_term.R` then `sleep_compiled.R`.

### Citation-dependency (now bites)

`Sleep_h_day` currently comes from Herculano-Houzel 2015, whose daily-sleep column also descends from
these older compilations. So Capellini vs HH for `Sleep_h_day` is **citation-dependent → resolve, do
not average** (pick one primary; the README of the merge documents the team-aware rule). `REM_sleep_pct`
currently comes only from Eagleman (primates); Capellini adds non-primate REM — new species do not
conflict, shared species resolve by the same rule.
