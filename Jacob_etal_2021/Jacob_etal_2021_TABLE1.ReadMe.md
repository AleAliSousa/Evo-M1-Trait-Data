# Jacob_etal_2021_TABLE1

## Source
Jacob, J., Kent, M., Benson-Amram, S., Herculano-Houzel, S., Raghanti, M. A., et al. (2021). Cytoarchitectural characteristics associated with cognitive flexibility in raccoons. *Journal of Comparative Neurology*, 529(14), 3375–3388. DOI: 10.1002/cne.25197

**Item:** TABLE 1 "Hemisphere and brain area weights" (PDF p. 5). Raccoon (*Procyon lotor*); group means (± SEM) for three problem-solving groups (Nonsolver N = 6, Intermediate N = 5, Solver N = 7).

## Frozen source
`Jacob_etal_2021_TABLE1_snapshot.csv` — extracted programmatically from the PDF text layer by `Jacob_etal_2021_extract_snapshot.R` (pdftools; no values typed — the script holds only regex patterns and printed-layout literals, each anchored against the PDF), printed layout kept: caption row, printed column headers, `mean ± SEM` cells with the footnote marker `a` inline (`18.52 ± 0.82a`), the table Note, and the footnote text. Verified cell-by-cell against the PDF (2026-09-06); the extractor reattaches footnote markers the text layer floats away from their number and restores the multiplication sign the text layer drops from "200 × 300 μm". Rerunning the extractor refuses to overwrite a differing frozen copy (writes *_snapshot_NEW.csv instead). Never edit it; all cleaning is in the `.R`.

## Build
Run `Jacob_etal_2021_TABLE1.R` (Rscript or RStudio Source). It reads the frozen snapshot, splits `mean ± SEM` cells, splits footnote markers into `*_footnote_ref` columns, derives per-measure effective n (footnote a = "N − 1, value missing for one animal"), writes `Jacob_etal_2021_TABLE1.csv`, and publishes `10.1002%2Fcne.25197_TABLE1.tsv` to `__Public/comparative-data/` via the registry lookup (by `Item name`, never row number).

## Units
Hemisphere and somatosensory cortex printed in **g → converted to mg** (× 1000, project brain-mass unit); hippocampus printed in **mg**, kept. Snapshot keeps the printed units.

## Notes
- Group means of individuals within one species (intraspecific). Pool across solver groups before any species-level use; rows are not species.
- Structures were dissected from **one hemisphere** (Methods §2.3–2.4): weights are unilateral.
- Definitions: `reference_tables/Jacob_etal_2021_TABLE1_definitions.csv`. Species key: `_keys/HerculanoHouzel/species_key.csv` (Procyon lotor row).
