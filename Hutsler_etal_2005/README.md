# Hutsler et al. 2005 — comparative cortical layering

## Source

Hutsler, J. J., Lee, D.-G., & Porter, K. K. (2005). Comparative analysis of cortical layering and
supragranular layer enlargement in rodent, carnivore and primate species. *Brain Research*,
1052, 71–81. DOI **10.1016/j.brainres.2005.06.015** · PMID **16018988**.

The EndNote PDF was copied into this folder and checksum-locked in
`Hutsler_etal_2005_extract_snapshot.py` (SHA-256
`93c8718ba14f86e30eef3fabd135c263f86e1de195239f9a1909cb640da8d665`).

## What is built

| Item | Granularity | What it contains |
|---|---|---|
| `Hutsler_etal_2005_Table1.csv` | 14 species | Printed species names, accepted names, 32 specimen counts and tissue sources; flags the 13-species regional subset |
| `Hutsler_etal_2005_Figure3.csv` | 14 species | **Digitized, approximate primary somatosensory** total, supragranular II/III and infragranular V/VI thicknesses and proportions |
| `Hutsler_etal_2005_Figure6.csv` | 3 orders × 3 regions | **Digitized, approximate order means** for supragranular II/III in motor, premotor and sensory cortex |
| `Hutsler_etal_2005_ReportedValues.csv` | 44 published summaries | Exact narrative values, including M1 total thickness, layer I/IV proportions and combined pyramidal proportions |
| `outputs/.../Hutsler_etal_2005_build.xlsx` | review workbook | The four clean tables, definitions and QA notes in one human-readable workbook |

Each item has a frozen CSV snapshot, an `.R` build script, an analysis CSV, an item README and a
definition table. `Hutsler_etal_2005_extract_snapshot.py` verifies the PDF and can regenerate the
exact Table 1 snapshot or extract the embedded figure JPEGs used for digitization.

## The M1 boundary

This paper does **not** publish species-specific M1 thickness values. The species-level Figure 3 bars
are from **primary somatosensory cortex**, the only region available for all 14 species. The regional
analysis contains every species except mouse, but Figure 6 collapses them into three order means.
Therefore:

- M1-compatible values are limited to 13-species pooled means and order × region summaries.
- Do not copy an order-level M1 bar onto each member species.
- Keep Figure 3 S1 rows separate from Figure 6 M1 rows in any merge.

The natural home is a new `__merging_cortical_layers` lineage with explicit `region`, `layer`,
`aggregation_level`, `value_basis` and `uncertainty` fields. It should sit beside, not inside, the
Jacobs M1 neuron-morphology data. Jacobs measures soma/dendrite morphology; Hutsler measures cortical
and laminar thickness. They are joinable by species/region for analysis but are not the same trait.

## Source inconsistencies retained

The build does not choose silently among mutually inconsistent statements:

1. Results p.74 reports S1 supragranular proportions of **0.44, 0.35, 0.26** for primates,
   carnivores and rodents. The abstract and Discussion p.77 instead report **0.46 ± 0.03,
   0.36 ± 0.03, 0.19 ± 0.04**.
2. Figure 3 digitization gives supragranular order means of about **1126, 677, 523 µm** and
   **0.491, 0.388, 0.278**, which do not reproduce the narrative **867.9, 567.1, 438.2 µm** and
   **0.44, 0.35, 0.26**. Figure 3 remains a separately flagged provisional source.
3. Figure 6 sensory bars digitize to **885, 565, 470 µm** and **0.441, 0.335, 0.255**, much closer
   to the narrative values (rodent absolute differs by about 32 µm).
4. The Figure 6 caption calls panels A and B supragranular and infragranular “proportional” panels,
   but panel A's axis is absolute µm and panel B's bars match supragranular proportions. The build
   follows the axes and bar reconciliation, and records the caption error on every row.

Because these conflicts require curatorial sign-off, no rows were added to `__ReadMe.xlsx` and no
public DOI-named TSVs were created. The local build is complete and reproducible.

## Methods and comparability

- Adult tissue, multiple archival sources and processing histories.
- Animal material: 4% paraformaldehyde, 40 µm frozen sections, Nissl staining. Human material:
  paraffin, 8 µm sections, hematoxylin/eosin.
- Ten orthogonal linear measures per region per species; crowns, deep sulci and folds avoided.
- Layers II and III were combined when individual boundaries were unreliable. Layer IV could be
  omitted when not reliably visualized, especially in agranular M1.
- Raw histological thickness is acknowledged by the authors to overestimate true 3-D thickness.

These fields should be preserved before combining Hutsler with any Sherwood or other comparative
laminar-thickness source.
