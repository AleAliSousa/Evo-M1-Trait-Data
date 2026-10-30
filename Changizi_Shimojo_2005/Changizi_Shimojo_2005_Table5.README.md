# Changizi & Shimojo 2005 — Table 5 (average area connections per area, per animal)

Changizi, M.A., & Shimojo, S. (2005). *Parcellation and area-area connectivity as a function of
neocortex size.* Brain Behav Evol 66(2):88–98. doi:10.1159/000085942

Printed caption: **"Table 5. Average number of area connections per area (10 to the power of the
average base-10 logarithm of the number of area connections per areas), standard deviation of the
logarithm of the number of area connections per area, and brain mass for a variety of animals
(ordered by brain mass)"** — 11 animals × {Latin name, average, SD log, brain mass g}. Footnote:
"See methods for references and cortical areas. Data are plotted in figure 3b."

*(The caption's "per areas)" is the paper's own typo; kept verbatim in the snapshot.)*

## Source → Snapshot
Printed source (p. 92, right-hand column; the four-line caption sits in the left column beside it).
Built by `Changizi_Shimojo_2005_extract_snapshot.py` from word coordinates and checked by eye
against a 230-dpi render.

`Changizi_Shimojo_2005_Table5_snapshot.xlsx` (sheet `Table5`), 17 worksheet rows: row 1 caption,
rows 2–5 the four printed header lines, rows 6–16 the 11 animals in printed order (ordered by brain
mass), row 17 the footnote.

## Data readable
`Changizi_Shimojo_2005_Table5.R` → `Changizi_Shimojo_2005_Table5.csv` (**use this**), 11 rows.
Columns are defined in `reference_tables/Changizi_Shimojo_2005_Table5_definitions.csv`.

**Units are kept as printed** (task decision): the average is a count of connections per area (a
back-transformed log10 mean), the SD is on the log10 scale, and `brain_mass_g` is in **grams** —
multiply × 1000 for the project's `Mass.mg` standard at merge time.

## Blanks and one real zero
**No cell in this table is blank**; any `NA` in the CSV would be a parse failure and the `.R` warns
on it. **Rat prints SD = 0.00 and that is a genuine zero, not a missing value**: rat contributes
exactly one entry to table 4 (S1 = 7), so the log10 values have no spread. It is stored as `0`.

## Checks
- 11 data rows, matching the printed table.
- Rows are in ascending brain mass, as the caption states (1.78 → 84.64 g).
- **Recomputation from table 4.** The caption's own recipe — `10^mean(log10 x)` and `sd(log10 x)`
  over the per-area counts in table 4 — reproduces the printed average **and** SD **exactly at 2 dp
  for all 9 animals whose counts table 4 prints** (see the table 4 README for the full comparison).
  Cat (13.34 / 0.24) and macaque (16.99 / 0.32) cannot be recomputed: their per-area counts are the
  three "not shown here" rows of table 4. The SD is the **sample** SD (n−1) — the population SD
  gives 0.09 for tree shrew where the paper prints 0.10.
- **Brain mass agrees with table 1** for all 9 shared animals after rounding 3 dp → 2 dp
  (1.778→1.78, 3.114→3.11, 5.174→5.17, 6.522→6.52, 7.223→7.22, 7.779→7.78, 16.335→16.34,
  27.093→27.09, 84.643→84.64). Bushbaby (4.57 g) and Squirrel monkey (22.48 g) appear only here.
- All 11 rows resolve to a scientific name.

## Species note
Both a common and a Latin name are printed. `animal_printed` and `latin_name_printed` keep them
verbatim (including *Rattus rattus*, *Felis domesticus* and the genus-only *Aotus* / *Macaca*);
`species_sci` is resolved **only through the species key** (`Changizi2005` rows of
`_keys/Stephan/species_key.csv`, currently standing in as `PROPOSED_species_key_rows.csv`), on the
common name first and the Latin name second. No mapping is hard-coded in the `.R`.

## Provenance / data role
**`Data role` = secondary.** The averages are Changizi & Shimojo's own summary of counts compiled
from other groups' connection studies (table 4); brain masses are compiled from the literature
(same values as table 1 for the shared animals).

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Definitions ✅ → Species rows proposed ✅ →
Online database ☐ (the `.R` writes `10.1159%2F000085942_Table5.tsv` when run with the repo mounted).
