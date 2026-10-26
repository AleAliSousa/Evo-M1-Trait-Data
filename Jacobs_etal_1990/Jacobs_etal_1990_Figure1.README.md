# Jacobs_etal_1990_Figure1

Absolute and relative hippocampal size by sex in meadow and pine voles

## Source → Snapshot

Jacobs, L. F., Gaulin, S. J. C., Sherry, D. F., & Hoffman, G. E. (1990). Evolution of spatial cognition: Sex-specific patterns of spatial behavior predict hippocampal size. Proceedings of the National Academy of Sciences, 87, 6349–6352. https://doi.org/10.1073/pnas.87.16.6349

Frozen source PDFs accompany this item. Constructed figure snapshot with calibration and coordinates. Extracted by Codex on 2026-10-26; AI comparison against the source completed; human RA verification pending.

## Data readable

The R reader reads the frozen snapshot, performs documented transformations, and writes 4 rows to CSV and DOI-coded TSV.

## Interpretation and provenance

Four species-sex groups, ten adult wild-caught animals each (40 animals total). Panels A/C provide absolute hippocampal means ± SE; B/D reuse those animals for relative measurements. Tissue was perfused with Perfix, frozen at 40 micrometres, with every fourth section measured. Hippocampus means dentate gyrus plus Ammon's horn; volumes were integrated as truncated cones. Laterality is not explicit, so no doubling is applied. Brain volume was mass-derived but is not reconstructed from rounded figure ratios.

Constructed snapshot: manual point and SE-cap selections by Codex on 2026-10-26 from PDF page3 at 200 dpi, crop (165,75,460,470) points, image 820×1098 pixels. Pixel origin top-left; linear axes calibrated separately for panels A–D. R calculates means and half cap-to-cap SE, then rounds absolute values to 0.1 mm3 and relative values to 0.0001. Analyst-assigned reading uncertainty is approximately ±0.1 mm3; this is distinct from sampling SE. The paper's relative-axis label includes ×100 while ticks are 0.04–0.06 and Methods describes a ratio. Those relative values remain uninterpreted metadata. Absolute volumes are catalogued as DigitizedSize.mm3 to keep approximation status visible.

## Table checks

No published arithmetic relation recomputable from these cells; not assessed.

## Online database

Registered by item name in `__ReadMe.xlsx`; public TSV: `10.1073%2Fpnas.87.16.6349_Figure1.tsv`. All columns have item-scoped definitions. Source database/catalog intake only; aggregate merge pipelines are unchanged.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Jacobs_etal_1990_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Jacobs_etal_1990-E001 | relative_axis_mean_estimate | Figure1 panels B/D, y-axis label and Methods | Hippocampal Volume / Brain Volume ×100; ticks 0.04–0.06 |  | publication_ambiguity |  | proposed | Methods describes ratio; literal ×100 label is inconsistent with ratio interpretation of plotted scale. | Keep original plotted scale and flag SE likewise; no percentage conversion or reconstruction of brain volume. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
