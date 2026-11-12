# Andersen_etal_2022_TableS2

**Item name** `Andersen_etal_2022_TableS2` · **Item number** `Table S2` ·
**Item encoded** (expected once registered) `10.1016%2Fj.nucmedbio.2022.06.007_TableS2`

Andersen, K. B., Hansen, A. K., Knudsen, K., Schacht, A. C., Damholdt, M. F., Brooks, D. J., &
Borghammer, P. (2022). Healthy brain aging assessed with [18F]FDG and [11C]UCB-J PET. *Nuclear Medicine
and Biology* 112–113, 52–58. <https://doi.org/10.1016/j.nucmedbio.2022.06.007>

**Item full original title (printed):** Table (S)2. Region of interest analysis of [11C]UCB-J SUVR-1 and
[18F]FDG SUVR values for young versus old HC

Item number: the supplement prints "Table (S)2", and the article cites it as "Table S2" (Results 3.2,
Discussion). `Table S2` is used so the Item name/TSV stem carries no parentheses.

## Sample sizes (printed in the main text)

**HC old n = 15, HC young n = 11**: main-text Table 1 (p. 53) and the supplement's Fig. S1 labels. The
build reads them from the latter and asserts 15/11. Both groups are healthy controls.

## What the data are

**P-values only**. The table prints no group values. Each P comes from an old-versus-young
comparison (two-sample t test, equal variances), for 14 composite bilateral Hammers VOIs × 4 measures:
[11C]UCB-J **SUVR-1** and [18F]FDG **SUVR**, both centrum-semiovale (CSO) normalised, each without and
with PVC (GTM). It is printed in two parts: **A) uncorrected** and **B) Bonferroni corrected**. Output:
**56 rows** = 14 VOIs × 4 measures, with the A and B P side by side. `0.000` is kept as printed and
stored as 0; read it as P < 0.0005.

This item records **which regions show age effects** for synaptic density vs glucose uptake. No PVC'd
UCB-J difference survives Bonferroni, while every FDG difference does, which matches the main text. The
group values themselves are shown only as box plots (Fig. 1B/D) and are not tabulated anywhere.

VOI labels are kept as printed (`FCx`, `HIP`, `THAL`, …); full names are in
`reference_tables/Andersen_etal_2022_region_labels.csv`. HIP, Amg and SN are not defined in the paper,
and are read as hippocampus, amygdala and substantia nigra (interpretation).

## Frozen source (digital-native)

`Andersen_etal_2022_TableS2_snapshot.docx` is a copy-rename of the journal supplement
`1-s2.0-S0969805122020662-mmc1.docx`, the same file as the Table S1 snapshot. It was never opened or
re-saved. The same OneDrive note applies: sync added an empty `MediaServiceImageTags` property to
`docProps/custom.xml`, and `word/document.xml` is byte-identical to the original. The house snapshot
regex does not cover `.docx` (precedent: `Jacobs_etal_2019`).

The reader (`Andersen_etal_2022_TableS2.R`) parses `word/document.xml` with xml2. It locates the caption,
the two Word tables after it and the A/B footnotes, keeps the two-line column headers, and asserts all of
them. **No value is typed in the script.** The reader was built by an AI assistant (Claude) on
2026-11-11 and run from a clean `Rscript` session. The independent lxml re-parse agrees on every cell
(see the Table S1 README: 324 cells across both items, 0 mismatches).

## Pipeline

```
Source: 1-s2.0-S0969805122020662-mmc1.docx (journal supplement)
  -> Andersen_etal_2022_TableS2_snapshot.docx     FROZEN: copy-rename of the download
  -> Andersen_etal_2022_TableS2.R                 xml2 read + reshape + table checks
  -> Andersen_etal_2022_TableS2.csv               56 rows x 15 cols ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv written only once the registry row exists
  -> reference_tables/Andersen_etal_2022_TableS2_definitions.csv
  -> reference_tables/Andersen_etal_2022_region_labels.csv
```

## Table checks

Part B should equal **min(1, 14 × part A)** (Bonferroni over the 14 VOIs). The reader checks every cell
with interval arithmetic. Part A has 3 decimals (±0.0005, so ±0.007 after ×14), and part B is ± half a
unit of its own last decimal (`1.0` → ±0.05). **56/56 pass** (actual R run, 2026-11-11). The factor 14 is
inferred, not printed; it reproduces every printed B.

## Species

*Homo sapiens* (not printed in the table); proposed key row in
`reference_tables/Andersen_etal_2022_species_key_proposed.csv` (shared with Table S1).

## Registration

The item is **not yet registered**. The build prints `not yet registered - TSV skipped` until the owner
pastes `Andersen_etal_2022_TableS2_registry_row.xlsx` and runs `_tools/file_list.R`.

## Errata

None for this item. The paper's one erratum (`Andersen_etal_2022-E001`) concerns Table S1.
