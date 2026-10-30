# Jacob_etal_2021_TABLE3

## Source
Jacob, J., Kent, M., Benson-Amram, S., Herculano-Houzel, S., Raghanti, M. A., et al. (2021). Cytoarchitectural characteristics associated with cognitive flexibility in raccoons. *Journal of Comparative Neurology*, 529(14), 3375–3388. DOI: 10.1002/cne.25197

**Item:** TABLE 3 "Cytoarchitecture analysis of the hilus of the dentate gyrus region in raccoons" (PDF p. 11). Nonsolver N = 5, Intermediate N = 4, Solver N = 5.

## Frozen source
`Jacob_etal_2021_TABLE3_snapshot.csv` — extracted programmatically from the PDF text layer by `Jacob_etal_2021_extract_snapshot.R` (pdftools; no values typed — the script holds only regex patterns and printed-layout literals, each anchored against the PDF), printed layout kept, including trailing zeros as printed (`120.0`, `27.80`, `29.60`) and the significance asterisk inline (`1.42 ± 0.15*`). Verified cell-by-cell against the PDF (2026-09-06); the extractor reattaches footnote markers the text layer floats away from their number and restores the multiplication sign the text layer drops from "200 × 300 μm". Rerunning the extractor refuses to overwrite a differing frozen copy (writes *_snapshot_NEW.csv instead). Never edit it; all cleaning is in the `.R`.

## Build
Run `Jacob_etal_2021_TABLE3.R`. It reads the frozen snapshot, splits `mean ± SEM` cells, keeps the asterisk as `fusiform_footnote_ref`, writes `Jacob_etal_2021_TABLE3.csv`, and publishes `10.1002%2Fcne.25197_TABLE3.tsv` to `__Public/comparative-data/` via the registry lookup.

## Units
Cell-profile counts per 200 × 300 μm field of vision (averages, not cumulative) and percentages (a = % of neurons; b = % of total cells). No conversion applies.

## Provenance notes
- **Text–table discrepancy, kept verbatim:** Results §3.3 prints nonsolver fusiform mean "x̄c = 0.79"; the table prints **0.71 ± 0.27**. The table value is used; the discrepancy is recorded here and in the definitions, not corrected.
- The `*` on the Solver fusiform value: Figure 7 caption gives *p = .0495 vs intermediates; overall ANOVA F(2,11) = 4.640, p = .035 (Results §3.3).
- Group means of individuals within one species; pool across solver groups before any species-level use.
- Definitions: `reference_tables/Jacob_etal_2021_TABLE3_definitions.csv`.
