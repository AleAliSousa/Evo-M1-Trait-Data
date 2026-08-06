# Changizi & Shimojo 2005 — Table 1 (average relative size of cortical areas)

Changizi, M.A., & Shimojo, S. (2005). *Parcellation and area-area connectivity as a function of
neocortex size.* Brain Behav Evol 66(2):88–98. doi:10.1159/000085942

Printed caption: **"Table 1. Data for the average relative size of cortical areas for a number of
animals, measured from flattened cortical maps"** — 19 animals × {Latin name, areas shown, average
relative size (% of neocortex), SD of log relative size, brain mass (g), EQ, reference}.

## Source → Snapshot
Printed source (paywalled PDF, p. 89), so a frozen snapshot is required.
`Changizi_Shimojo_2005_extract_snapshot.py` builds it from the PDF **by word coordinates**
(`page.extract_words()`, x0/x1) rather than `extract_text()`: this is a two-column journal page and
the line-based text layer mixes table rows with body prose and silently collapses blank cells. Each
column is a fixed x-window read off the printed header, and a word lands in the window containing
its horizontal centre, so a blank cell stays blank in the right place. The snapshot was then checked
by eye against a 200-dpi render of the page.

`Changizi_Shimojo_2005_Table1_snapshot.xlsx` (sheet `Table1`), 23 worksheet rows:
row 1 caption, rows 2–3 the two printed header lines, rows 4–22 the 19 animals in printed order
(ordered by brain size), row 23 the printed footnote. Nothing is cleaned there. The only
typographic repair is re-joining the broken `fi`/`fl` ligatures in the caption and footnote
("fl attened" → "flattened"); no data cell contains a ligature.

## Data readable
`Changizi_Shimojo_2005_Table1.R` → `Changizi_Shimojo_2005_Table1.csv` (**use this**), 19 rows.
Columns are defined in `reference_tables/Changizi_Shimojo_2005_Table1_definitions.csv`.

**Units are kept as printed** (task decision, overriding the repo's default brain-mass unit):
relative sizes are percentages of neocortex, `brain_mass_g` is in **grams**, EQ is a dimensionless
index. Multiply `brain_mass_g` × 1000 for the project's `Mass.mg` standard at merge time.

## Blanks
Four animals — **Mouse, Rat, Ferret, Cat** — print **no SD**. This is not zero and not a
transcription slip: the methods (p. 90) say that for these four "only unflattened cortical maps were
available, so measurements of relative size were not possible … the number of areas was simply
counted … and the relative size computed as the inverse of twice the counted number of cortical
areas. Standard deviations are accordingly not provided for these animals." `sd_log_rel_size` is
therefore `NA`, and `rel_size_basis` records which of the two routes produced the value.

## Checks
- 19 data rows, matching the printed table.
- The four counted animals satisfy `avg_rel_size_pct = 100/(2 × areas_shown)` to within 0.001:
  Mouse 9→5.556, Rat 10→5.000, Ferret 11→4.545, Cat 22→2.273. The `.R` warns if this ever fails.
- `n_areas_extrapolated = round(100 / avg_rel_size_pct, 3)` — the paper's own extrapolation (p. 90).
  For the four counted animals it returns twice the counted areas, as it must:
  Mouse 17.999 (=18), Rat 20.0 (=20), Ferret 22.002 (=22), Cat 43.995 (=44).
- Brain masses agree with table 5 for all 9 shared animals after rounding 3 dp → 2 dp.
- All 19 rows resolve to a scientific name.

## Species note
The printed **common** name is kept in `animal_printed` and the printed **Latin** name verbatim in
`latin_name_printed` (including the misspelling *Ornithorhyncus anatinus*, the junior synonym
*Felis domesticus*, the genus-only *Aotus* / *Macaca*, and the three-genus *Sorex, Blarina,
Cryptotis*). `species_sci` is resolved **only through the species key** — the `Changizi2005` rows of
`_keys/Stephan/species_key.csv`, matched on the common name first and the Latin name second. Those
rows are not yet merged, so the identical three-column
**`PROPOSED_species_key_rows.csv`** in this folder stands in until they are; the `.R` switches over
automatically once the shared key carries the token. No mapping is hard-coded in the script.

Table 1 prints "Star-mole" where table 2 prints "Star-nosed mole"; both are in the proposal, both →
*Condylura cristata*.

## Provenance / data role
Mixed, so **`Data role` = both**. The *average relative size and its SD are primary*: Changizi &
Shimojo scanned the published flattened parcellation maps of the Kaas–Krubitzer group and measured
each area's surface with NIH Image (p. 90) — these numbers are not in the cited papers. `areas_shown`,
`brain_mass_g` and `EQ` are *secondary*, compiled from the cited literature.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Definitions ✅ → Species rows proposed ✅ →
Online database ☐ (the `.R` writes `10.1159%2F000085942_Table1.tsv` to `__Public/comparative-data/`
when run with the repo mounted; TSVs were deliberately not written by this build).
