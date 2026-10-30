# Changizi & Shimojo 2005 — Table 3 (areas and edges in neocortical subnetworks)

Changizi, M.A., & Shimojo, S. (2005). *Parcellation and area-area connectivity as a function of
neocortex size.* Brain Behav Evol 66(2):88–98. doi:10.1159/000085942

Printed caption: **"Table 3. Number of cortical areas and total number of area-area connections in a
variety of neocortical sensory (or sensory-motor) subnetworks"** — 10 subnetworks ×
{Subnetwork, Areas, Edges, Reference}. Footnote: "+ indicates that there are other cortical areas
included in the subnetwork. Data are plotted in figure 3a."

## Source → Snapshot
Printed source (p. 90, right-hand column of a two-column page; the caption sits in the *left*
column beside it). Built by `Changizi_Shimojo_2005_extract_snapshot.py` from word coordinates —
see the table 2 README for why `extract_text()` is not usable here — and checked by eye against a
220-dpi render.

`Changizi_Shimojo_2005_Table3_snapshot.xlsx` (sheet `Table3`), 13 worksheet rows: row 1 caption,
row 2 header, rows 3–12 the 10 subnetworks in printed order (ordered by number of areas), row 13
the footnote.

## Data readable
`Changizi_Shimojo_2005_Table3.R` → `Changizi_Shimojo_2005_Table3.csv` (**use this**), 10 rows.
Columns are defined in `reference_tables/Changizi_Shimojo_2005_Table3_definitions.csv`.

Areas and edges are counts; no unit conversion applies.

The printed `Subnetwork` cell packs three things into one string (`"Cat, somato-motor +"`), so the
reformat splits it and keeps the original:

| column | from |
|---|---|
| `subnetwork_printed` | the cell verbatim |
| `animal_printed` | before the comma |
| `modality_printed` | after the comma, trailing `+` stripped |
| `includes_other_areas` | `TRUE` where the footnote symbol `+` is printed |

## Blanks
**None.** Every cell of table 3 is filled; any `NA` in the CSV would be a parse failure.

## Checks
- 10 data rows, matching the printed table.
- Areas range 8–30, edges 22–348; 4 of 10 rows carry the `+` marker (macaque auditory +, cat
  auditory +, cat visual +, cat somato-motor +).
- Graph sanity: no row's edge count exceeds `A × (A−1)`, the ceiling for a directed network on
  `A` areas. (The paper does not say whether the matrices are directed; the looser bound is used
  so the check cannot fire spuriously.)
- All 10 rows resolve to a scientific name.

## Granularity warning
**The row unit is a subnetwork, not a species.** Only four animals appear (tree shrew, rat, cat,
macaque) and macaque contributes 5 rows and cat 3, from partly overlapping published matrices —
two of the macaque auditory rows (13/56 from Hackett et al. 1998 and 16/95 from Young 1993) are
different tallies of the same system. Do not collapse these to a species mean without deciding how
to treat the duplicates.

## Species note
Only a common name is printed, inside the subnetwork label. `animal_printed` keeps it;
`species_sci` is resolved **only through the species key** (`Changizi2005` rows of
`_keys/Stephan/species_key.csv`, currently standing in as `PROPOSED_species_key_rows.csv`).
"Macaque" and "Cat" are the ambiguous ones here — see the folder's proposal file and the report.

## Provenance / data role
**`Data role` = secondary.** These are tallies of areas and edges read off connectivity matrices
published by others (Lyon et al. 1998; Coogan & Burkhalter 1993; Hackett et al. 1998; Young 1993;
Kaas & Hackett 2000; Scannell & Young 1993). The counting is Changizi & Shimojo's; the connectivity
data are not.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Definitions ✅ → Species rows proposed ✅ →
Online database ☐ (the `.R` writes `10.1159%2F000085942_Table3.tsv` when run with the repo mounted).
