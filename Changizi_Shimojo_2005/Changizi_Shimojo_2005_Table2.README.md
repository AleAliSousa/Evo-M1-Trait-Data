# Changizi & Shimojo 2005 — Table 2 (relative size of V1, V2, A1, S1, M1)

Changizi, M.A., & Shimojo, S. (2005). *Parcellation and area-area connectivity as a function of
neocortex size.* Brain Behav Evol 66(2):88–98. doi:10.1159/000085942

Printed caption: **"Table 2. Data for relative size (as a percentage of neocortex) of selected areas
in a number of animals"** — 16 animals × {V1, V2, A1, S1, M1}, under the spanning header
"Relative size of area, %". Footnote: "Sources are those in table 1. Data are plotted in figure 2."

## Source → Snapshot
This is the hardest table in the paper to extract and the reason the whole build uses word
coordinates. Table 2 sits in the **right-hand column of a two-column page**, interleaved line by
line with the body prose of the left column, so `extract_text()` returns table rows sandwiched
between sentences — and, critically, it drops the blank cells, so `Shrew  5.445  4.230  12.651`
looks like three *consecutive* columns when it is really V1 / A1 / S1 with V2 and M1 empty.
Reading a row like that one column to the left would silently turn an S1 value into an M1 value.

`Changizi_Shimojo_2005_extract_snapshot.py` therefore places every word by its x-centre into a fixed
column window taken from the printed header (V1 385–418, V2 418–453, A1 453–490, S1 490–528,
M1 528–575 pt). Numbers in this table are right-aligned and the headers left-aligned at the same
column edge, so the windows are unambiguous. The result was checked cell by cell against a 220-dpi
render of the page.

`Changizi_Shimojo_2005_Table2_snapshot.xlsx` (sheet `Table2`), 20 worksheet rows: row 1 caption,
row 2 the "Relative size of area, %" spanner (kept as a single cell, as printed), row 3 the
V1/V2/A1/S1/M1 header, rows 4–19 the 16 animals in printed order, row 20 the footnote.

## Data readable
`Changizi_Shimojo_2005_Table2.R` → `Changizi_Shimojo_2005_Table2.csv` (**use this**), 16 rows,
one per animal, kept **wide** so the blanks stay visible per area. Columns are defined in
`reference_tables/Changizi_Shimojo_2005_Table2_definitions.csv`.

**Units are kept as printed**: every value is a percentage of neocortex (surface, since the
measurements come from flattened maps).

## Blanks — the whole difficulty of this table
Blank means **not measured**, never zero: "In some animals data do not exist for some areas" (p. 90).
Every blank is carried through as `NA`. Counts of printed values, verified against the page:

| area | values printed |
|---|---|
| V1 | 15 of 16 |
| V2 | 9 of 16 |
| A1 | 15 of 16 |
| S1 | 14 of 16 |
| M1 | 9 of 16 |

`n_areas_reported` records the per-row count. Two rows deserve naming:

- **Mouse** prints *no value at all* — the row is blank across all five areas (`n_areas_reported = 0`).
  It is kept, because the printed table keeps it. (Consistent with table 1: mouse is one of the four
  animals with no flattened map.)
- **Opossum** prints V1, V2, A1 and **nothing for S1 or M1** — the 8.859 on that row is A1, not S1.
  This is exactly the row a line-based read would shift.

## Checks
- 16 data rows, matching the printed table.
- Per-area value counts (above) match a visual count off the rendered page.
- No row's five percentages sum to more than 100.
- Row-for-row species agreement with table 1: table 1 has 19 animals, table 2 has 16 — the three
  missing are **Rat, Ferret and Cat**, i.e. three of the four animals that table 1 marks as
  "counted, no SD". (Mouse, the fourth, is present but blank.) The only name that differs is
  "Star-nosed mole" here vs "Star-mole" in table 1.
- All 16 rows resolve to a scientific name.

## Species note
Only the common name is printed here. `animal_printed` keeps it verbatim; `species_sci` is resolved
**only through the species key** (`Changizi2005` rows of `_keys/Stephan/species_key.csv`, currently
standing in as `PROPOSED_species_key_rows.csv` in this folder). No mapping is hard-coded in the `.R`.

## Provenance / data role
**`Data role` = primary.** These percentages are Changizi & Shimojo's own measurements: they scanned
the Kaas–Krubitzer flattened parcellation maps and measured each area's surface with NIH Image
(p. 90). The maps are other people's; these numbers are not.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Definitions ✅ → Species rows proposed ✅ →
Online database ☐ (the `.R` writes `10.1159%2F000085942_Table2.tsv` when run with the repo mounted).
