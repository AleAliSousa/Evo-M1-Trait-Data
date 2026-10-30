# Zhu_etal_2023_SupplementaryData3 — Six traits of 94 mammalian species (RNA-seq subset)

Zhu, P., Liu, W., Zhang, X., Li, M., Liu, G., Yu, Y., Li, Z., Li, X., Du, J., Wang, X., Grueter,
C. C., Li, M., & Zhou, X. (2023). Correlated evolution of social organization and lifespan in
mammals. *Nat Commun*, 14(1), 372. https://doi.org/10.1038/s41467-023-35869-7

## What this item is
The 94-species subset of `Zhu_etal_2023_SupplementaryData1` used in the paper's RNA-seq
sequencing and comparative-transcriptomics analyses, with six traits: social-organization
category, activity pattern, diet, locomotor lifestyle, adult body mass, and maximum lifespan.
Per the paper's own Data Legend: "The traits were collected from published literature, reviews,
and online databases. References are provided in the Supplementary Information."

## Source
`41467_2023_35869_MOESM3_ESM.xlsx`, sheet "Supplementary Data 3". Note the sheet's own column
name `GroupLiving.GL` (literal period, not a slash as in Data 1's `GroupLiving/GL`) — kept
verbatim rather than silently normalized to match Data 1.

## Determining the reference(s) for any datapoint
Same scheme as `Zhu_etal_2023_SupplementaryData1`: a verbatim, comma-separated
`Supplementary_References_codes` column keys into `Zhu_etal_2023_SupplementaryReferences
.ref_number` (the 88-entry bibliography shared by both data tables, built from
`41467_2023_35869_MOESM1_ESM.pdf`). `Zhu_etal_2023_SupplementaryData3_refs_long.csv` provides
the same codes pre-split and pre-joined to their citation text, one row per (species, cited
reference/note) — including the free-text notes (e.g. "Adult body mass was measured in this
study", "Social organization was observed in this study") the authors used in place of a
reference number for values they generated themselves.

## Data role
**Primary** (secondary-compiled per-datapoint) — see `Zhu_etal_2023_SupplementaryData1`'s README
for the same note on provenance.

## Files
- `Zhu_etal_2023_SupplementaryData3_snapshot.csv` — frozen, verbatim sheet export (94 rows).
- `Zhu_etal_2023_SupplementaryData3.csv` / public TSV — same content, published.
- `Zhu_etal_2023_SupplementaryData3_refs_long.csv` — reference-resolution bridge table (538
  rows: one per species × cited reference/note).
