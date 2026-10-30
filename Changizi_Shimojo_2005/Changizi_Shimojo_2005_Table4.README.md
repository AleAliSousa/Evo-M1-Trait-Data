# Changizi & Shimojo 2005 — Table 4 (area connections per area, per area)

Changizi, M.A., & Shimojo, S. (2005). *Parcellation and area-area connectivity as a function of
neocortex size.* Brain Behav Evol 66(2):88–98. doi:10.1159/000085942

Printed caption: **"Table 4. Number of area connections per area for a variety of areas from a
variety of animals, with citations shown"** — 38 printed rows over 11 animals ×
{Animal, Kind of areas, Area, Area connections per area, Reference}. Footnote: "The average number
of area connections per area for each animal are shown in table 5, and plotted in figure 3b."

## Source → Snapshot
Printed source, running the full height of the right-hand column of p. 91. Built by
`Changizi_Shimojo_2005_extract_snapshot.py` from word coordinates and checked by eye against two
230-dpi renders of the column. Three layout traps had to be handled explicitly, all in the extract
script (never by hand-editing the snapshot):

1. **`"not shown here"` spans two columns.** On the three aggregate rows the phrase starts in the
   Area column and runs into the Area-connections column. The connections column only ever prints an
   integer, so any non-integer found there is appended to the Area cell and the connections cell is
   left empty.
2. **A reference can wrap onto a second printed line.** Two Squirrel rows print
   "Krubitzer et al., 1986;" then "Krubitzer and Kaas, 1990b" on the next line. A line carrying
   nothing but a reference is joined onto the row above.
3. **"Squirrel monkey" wraps across two printed rows** — "Squirrel" sits on the V1 line and "monkey"
   on the DM line. Only the table's ruling lines say the stray "monkey" belongs to the cell above
   rather than to the DM row it visually sits on, so the extract reads the horizontal rules from the
   PDF (`page.edges`) and rejoins the animal name inside each ruled group.

`Changizi_Shimojo_2005_Table4_snapshot.xlsx` (sheet `Table4`), 43 worksheet rows: row 1 caption,
rows 2–4 the three printed header lines, rows 5–42 the 38 data rows in printed order with the
repeated Animal / Kind-of-areas cells left blank exactly as printed, row 43 the footnote.

## Data readable
`Changizi_Shimojo_2005_Table4.R` → `Changizi_Shimojo_2005_Table4.csv` (**use this**), 38 rows.
Columns are defined in `reference_tables/Changizi_Shimojo_2005_Table4_definitions.csv`.

Values are counts of area-area connections; no unit conversion applies.
**Granularity is one cortical area per row, not one species per row** — the per-animal summary is
table 5.

## Blanks — two different kinds, handled differently
- **Repeat blanks (filled down).** The printed table blanks `Animal` and `Kind of areas` whenever
  they repeat the cell above. In the analysis CSV both are filled down (LOCF). This is a formatting
  blank, not missing data; the snapshot keeps it blank, the CSV fills it.
- **A genuinely absent measurement (kept `NA`).** Three rows print `"not shown here"` in the Area
  column and nothing in the connections column — cat (40 sensory areas, Scannell et al. 1995),
  macaque (8 visual areas, Lewis & van Essen 2000) and macaque (56 sensory-motor areas, Young 1993).
  The paper publishes only their average, in table 5. `area_connections_per_area` is `NA` for these
  three and `area_not_shown` is `TRUE`; the group size (40 / 8 / 56) is parsed out into
  `n_areas_in_group`. Never read these as zero.

## Checks
- 38 data rows over 11 animals; the animal set is identical to table 5's.
- `area_not_shown` and a missing count agree on all 38 rows (0 disagreements).
- **The strongest check in this build:** the `.R` recomputes the paper's log-transformed average
  (`10^mean(log10 x)`) and `sd(log10 x)` per animal and prints them for comparison with table 5.
  All **9** animals whose per-area counts are printed reproduce table 5 **exactly at 2 dp**, using
  the **sample** SD (n−1):

  | animal | n | recomputed avg / sd | table 5 |
  |---|---|---|---|
  | Rat | 1 | 7.00 / 0.00 | 7.00 / 0.00 |
  | Tree shrew | 6 | 4.73 / 0.10 | 4.73 / 0.10 |
  | Bushbaby | 4 | 9.05 / 0.10 | 9.05 / 0.10 |
  | Opossum | 2 | 4.47 / 0.07 | 4.47 / 0.07 |
  | Squirrel | 5 | 5.91 / 0.20 | 5.91 / 0.20 |
  | Flying fox | 5 | 6.79 / 0.12 | 6.79 / 0.12 |
  | Marmoset | 5 | 8.65 / 0.14 | 8.65 / 0.14 |
  | Owl monkey | 4 | 9.92 / 0.13 | 9.92 / 0.13 |
  | Squirrel monkey | 3 | 10.49 / 0.17 | 10.49 / 0.17 |

  Cat and macaque cannot be recomputed — theirs are the "not shown here" rows. This check confirms
  that every count landed in the right row *and* in the right animal group (in particular that the
  wrapped "Squirrel monkey" grouping is correct: mis-assigning any one of its three values breaks
  the match).
- All 38 rows resolve to a scientific name.

## Cell we could not read as printed — flagged, not fixed
The tree-shrew block prints **`TD` twice** (3rd row of the block, value 4; 5th row, value 5), which
cannot both be the same area. Lyon, Jain & Kaas (1998) name the tree shrew's temporal visual areas
TD, TI, TP and TA, so the second `TD` is almost certainly a typo for **TI**. The character shapes on
the page are unambiguously "TD" in both places, so it is **kept verbatim** and flagged here and in
the definitions. The numbers are unaffected: the log-average check above uses all six values and
matches table 5 exactly regardless of the label.

## Species note
Only common names are printed. `animal_printed` keeps them; `species_sci` is resolved **only through
the species key** (`Changizi2005` rows of `_keys/Stephan/species_key.csv`, currently standing in as
`PROPOSED_species_key_rows.csv`). Note the table contains both **Squirrel** (*Sciurus carolinensis*)
and **Squirrel monkey** (*Saimiri sciureus*) — distinct rows in the key. The Opossum here is
ambiguous: table 4 cites Kahn et al. 2000, whose animal is *Monodelphis domestica*, while the paper
labels the opossum *Didelphis marsupialis* in tables 1 and 5 (see the report).

## Provenance / data role
**`Data role` = secondary.** Every count is compiled from the cited connection studies
(Kahn, Beck, Lyon, Krubitzer, Collins, Fabri & Burton, Kaas, Scannell, Lewis & van Essen, Young).

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Definitions ✅ → Species rows proposed ✅ →
Online database ☐ (the `.R` writes `10.1159%2F000085942_Table4.tsv` when run with the repo mounted).
