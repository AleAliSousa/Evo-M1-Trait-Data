# Zhu_etal_2023_SupplementaryData1 — Social organization and longevity of 974 mammalian species

Zhu, P., Liu, W., Zhang, X., Li, M., Liu, G., Yu, Y., Li, Z., Li, X., Du, J., Wang, X., Grueter,
C. C., Li, M., & Zhou, X. (2023). Correlated evolution of social organization and lifespan in
mammals. *Nat Commun*, 14(1), 372. https://doi.org/10.1038/s41467-023-35869-7

## What this item is
974 mammalian species, each with social-organization category (solitary / pair-living /
group-living), adult body mass, maximum lifespan, diet, activity pattern, lifestyle, and
fossoriality. Per the paper's own Data Legend: "The data were collected from published
literature, reviews, and online databases. References are provided in the Supplementary
Information."

## Source
`41467_2023_35869_MOESM3_ESM.xlsx`, sheet " Supplementary Data 1" (leading space in the sheet
name, as in the source workbook).

## Determining the reference(s) for any datapoint
Every row carries a `Supplementary_References_codes` column — a verbatim, comma-separated list
of reference numbers (e.g. `"1,2,3,4,5"`), exactly as printed in the source sheet's
"Supplementary References" column. These numbers are keys into
`Zhu_etal_2023_SupplementaryReferences.ref_number`, the 88-entry bibliography built alongside
this item from the companion PDF (`41467_2023_35869_MOESM1_ESM.pdf`, p. 32, which states it
holds the references "of Supplementary Data 1 and Supplementary Data 3").

Rather than requiring every user to re-split and re-join that column themselves,
**`Zhu_etal_2023_SupplementaryData1_refs_long.csv` is provided pre-split and pre-joined**: one
row per (species, cited reference), with the citation text already looked up. Every code in
this item's column is numeric and resolves to an entry in
`Zhu_etal_2023_SupplementaryReferences` — unlike `Zhu_etal_2023_SupplementaryData3`, which also
carries a handful of free-text notes (e.g. "Max. lifespan was estimated in this study") in place
of a reference code for values the authors generated themselves; this item has none.

## Data role
**Primary** (secondary-compiled per-datapoint, per the paper's own description) — collected by
the authors from the literature and databases named in the companion reference list; the
dataset itself, as assembled here, is the paper's own contribution.

## Files
- `Zhu_etal_2023_SupplementaryData1_snapshot.csv` — frozen, verbatim sheet export (974 rows).
- `Zhu_etal_2023_SupplementaryData1.csv` / public TSV — same content, published (verbatim
  reference-code column retained, renamed `Supplementary_References_codes` for clarity).
- `Zhu_etal_2023_SupplementaryData1_refs_long.csv` — the reference-resolution bridge table
  described above (4,894 rows: one per species × cited reference/note).
