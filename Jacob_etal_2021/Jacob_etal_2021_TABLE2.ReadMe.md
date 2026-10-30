# Jacob_etal_2021_TABLE2

## Source
Jacob, J., Kent, M., Benson-Amram, S., Herculano-Houzel, S., Raghanti, M. A., et al. (2021). Cytoarchitectural characteristics associated with cognitive flexibility in raccoons. *Journal of Comparative Neurology*, 529(14), 3375–3388. DOI: 10.1002/cne.25197

**Item:** TABLE 2 "Cytoarchitecture analysis of sampled regions from the anterior frontoinsular region in raccoons" (PDF p. 9). Thionin-stained layer-V FI cortex; **no Intermediate row** — that tissue was unavailable (Results §3.2).

## Frozen source
`Jacob_etal_2021_TABLE2_snapshot.csv` — extracted programmatically from the PDF text layer by `Jacob_etal_2021_extract_snapshot.R` (pdftools; no values typed — the script holds only regex patterns and printed-layout literals, each anchored against the PDF), printed layout kept: caption, headers with the header footnote markers (`% VENsa`, `% All neuronsb`), `mean ± SEM` cells, table Note/Abbreviation/footnotes. Verified cell-by-cell against the PDF (2026-09-06); the extractor reattaches footnote markers the text layer floats away from their number and restores the multiplication sign the text layer drops from "200 × 300 μm". Rerunning the extractor refuses to overwrite a differing frozen copy (writes *_snapshot_NEW.csv instead). Never edit it; all cleaning is in the `.R`.

## Build
Run `Jacob_etal_2021_TABLE2.R`. It reads the frozen snapshot, splits `mean ± SEM` cells, writes `Jacob_etal_2021_TABLE2.csv`, and publishes `10.1002%2Fcne.25197_TABLE2.tsv` to `__Public/comparative-data/` via the registry lookup.

## Units
Cell-profile counts per 200 × 300 μm field of vision (**averages, not cumulative counts** — table Note) and percentages: % VENs = of neurons (footnote a); % all neurons = of total cells (footnote b). No conversion applies.

## Notes
- Group means of individuals within one species; pool across solver groups before any species-level use.
- Definitions: `reference_tables/Jacob_etal_2021_TABLE2_definitions.csv`.
