# deSousa__2008_Suppl.Table5.2

## Source
de Sousa, A. A. (2008). *Hominoid brain organization: Histometric and morphometric
comparisons of visual brain structures* [Ph.D., The George Washington University].
UMI:3311323. Registry Item **Suppl. Table 5.2** — exactly as printed — giving
Item name `deSousa__2008_Suppl.Table5.2` and Item encoded
`UMI%3A3311323_Suppl.Table5.2`. Printed p. 198 (PDF page 217, landscape). The full
printed label, **"Suppl. Table 5.2. Comparison of adjusted values to published data
of Semendeferi et al. (1998, 2002)"**, is kept verbatim in the snapshot caption and
in `Item full original title`.

**6 specimens × correction factor, brain volume, area 13 and area 10, in two blocks:
Semendeferi et al. as published, and the dissertation's re-adjusted values.**

## Why this item exists
Every numeric `area 13` / `area 10` value in the restricted staging workbook
`_deSousaDissertation_staging/multisystem.xlsx` is printed here — all nine of its
populated pairs match this table's Semendeferi columns exactly. Registering this
table makes the public dissertation the citable source for them.

## Pipeline
PDF text layer → snapshot → R → usable csv/tsv.

| file | role |
|---|---|
| `deSousa__2008_Suppl.Table5.2_extract_snapshot.R` | reads the PDF text layer, writes the frozen snapshot |
| `deSousa__2008_Suppl.Table5.2_snapshot.xlsx` (sheet `Suppl.Table5.2`) | frozen source, printed layout and units |
| `deSousa__2008_Suppl.Table5.2.R` | reads the snapshot, cleans, converts units, writes CSV + public TSV |
| `deSousa__2008_Suppl.Table5.2.csv` | one row per specimen (6) |
| `reference_tables/deSousa__2008_Suppl.Table5.2_definitions.csv` | data dictionary |

## Who read the values, when, and how it was checked
Read from the dissertation PDF's own text layer at run time
(`pdftools::pdf_data()`, page 217), placed by printed x-position; only the caption,
the two header tiers and the two footnotes are printed literals. Extracted and
checked by an AI assistant (Claude Science session), 2026-09-25. The printed grid is
complete, so the build script asserts **no NA anywhere**, plus row count, printed row
order (hs20 → hly), the first Semendeferi area 10 (14217.7 mm³) and the first
converted current brain volume (1302.1 cm³ → 1302100 mm³).

Independent check: all nine populated `area 13` / `area 10` pairs in the restricted
`multisystem.xlsx` reproduce values in this table's Semendeferi block exactly
(hs20 366.2 / 14217.7; pt1, ptb, ptc 269.9 / 2239.2; ppz, ppy 110.5 / 2804.9;
ggy 273.2 / 1942.5; ouh 316.6 / 1611.1; hly 51.5 / 203.5). Note the workbook files
that orangutan pair under `ouh` while this table prints it for **`ouy`**; the printed
table is authoritative.

## Data role — SECONDARY, not merged; two blocks that must never be pooled
| block | what it is |
|---|---|
| `semendeferi_*` | Semendeferi et al. (1998, 2002) **as published** — belongs to `Semendeferi_etal_1998` / `_2001` / `_2002`, not to de Sousa |
| `current_*` | the dissertation's re-adjustment of the *same* specimens to its fresh-weight correction-factor convention — a re-scaling, not an independent measurement |

Neither block is new measurement, so the item is built for provenance and is not
added to any merge. Averaging the two blocks would average a value with its own
rescaled self.

## Printed footnotes (carried per row in `footnote`)
- `*` (human, `hs20`): the brain volume differs because Semendeferi calculated it
  from the **fixed** weight (1200 g), whereas the dissertation used the **fresh**
  weight (1349 g).
- `**` (orang, `ouy`): the fresh weight for this specimen is 440 g.

The asterisks are not attached to individual cells in the PDF text layer, so they are
recorded per row rather than invented into cell strings.

## Species names
The table prints **common names only** (human, chimp, bonobo, gorilla, orang,
gibbon). Those printed variants are registered in `_keys/Stephan/species_key.csv`
under the token `deSousa2008`; the printed string is kept in
`species_as_published`. `code` joins to `deSousa__2008_Table5.1`.

## Units
Brain volume printed in cm³ → **mm³** (×1000). Area 13 and area 10 are printed in
mm³ and are left unconverted. Correction factors are dimensionless.

## Observation level
**One row per specimen.**
