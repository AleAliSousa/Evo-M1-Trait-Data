# Jacob_etal_2021_FIGURE4

## Source
Jacob, J., Kent, M., Benson-Amram, S., Herculano-Houzel, S., Raghanti, M. A., et al. (2021). Cytoarchitectural characteristics associated with cognitive flexibility in raccoons. *Journal of Comparative Neurology*, 529(14), 3375–3388. DOI: 10.1002/cne.25197

**Item:** FIGURE 4 "Isotropic fractionation-based cellular profiles in the raccoon hippocampus" (PDF p. 8). Panel A = total hippocampal nuclei; panel B = total nonneuronal hippocampal nuclei; whole hippocampus of **one hemisphere**, per group.

## Frozen source (constructed snapshot)
`Jacob_etal_2021_FIGURE4_snapshot.csv` — a **constructed snapshot** (per `__HOWTO_make_a_snapshot.md`, "When there is no table"), **extracted programmatically from the PDF text layer by `Jacob_etal_2021_extract_snapshot.R`** (no values typed): the figure prints no numbers, so every value is regex-captured **from the Results §3.1 text** (group means, ANOVA statistics; PDF p. 7) **and the Figure 4 caption** (post hoc p values, panel-a Ns; PDF p. 8). **Nothing is digitized from pixels.** The text layer renders the printed x̄c as `xc` and holds a stray space inside two panel-B means ("43,959, 439", "31,523, 979") — kept verbatim in the snapshot; the build strips non-digits. Each row carries a provenance column naming where its values are printed. Never edit it; the extractor refuses to overwrite a differing frozen copy (writes `*_snapshot_NEW.csv` instead), and all cleaning is in the build `.R`.

## Build
Run `Jacob_etal_2021_FIGURE4.R`. It reads the constructed snapshot, parses the printed strings (mean counts, ANOVA F/df/p/ηp², post hoc p), harmonises group labels to the tables' Nonsolver/Intermediate/Solver, writes `Jacob_etal_2021_FIGURE4.csv`, and publishes `10.1002%2Fcne.25197_FIGURE4.tsv` to `__Public/comparative-data/` via the registry lookup.

## Group Ns (partly derived — see `n_group_basis`)
Panel A: N = 7 solvers / N = 6 nonsolvers printed in the caption; intermediate N = 5 follows from F(2,15) ⇒ total 18. Panel B: "One intermediate solver could not be analyzed for NeuN staining" (text) ⇒ N = 4; F(2,14) ⇒ total 17 = 6 + 4 + 7, consistent.

## Provenance notes
- Caption prints post hoc p = .0706 / .1006; the running text rounds the same tests to .071 / .101. **Caption values used**, both recorded in the snapshot.
- No numeric SEM/SD is printed for these means (error bars only) — none is estimated.
- Unilateral (one hemisphere); do not double without a laterality decision.
- Group means within one species; pool across solver groups before any species-level use.
- Definitions: `reference_tables/Jacob_etal_2021_FIGURE4_definitions.csv`.
