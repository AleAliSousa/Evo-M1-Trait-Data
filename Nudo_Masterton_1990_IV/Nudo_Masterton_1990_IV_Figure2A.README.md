# Nudo & Masterton 1990, Part IV — Figure 2A

## Source
Nudo, R. J., & Masterton, R. B. (1990). Descending pathways to the spinal cord, IV: Some factors
related to the amount of cortex devoted to the corticospinal tract. Journal of Comparative
Neurology, 296(4), 584–597. https://doi.org/10.1002/cne.902960406. This item is **Fig. 2A**
(p.587, PDF page 4) — despite the registry's "Source format: figure", it is a printed numeric
table embedded inside the figure, not a chart requiring digitization: "Areas (in sq. mm.) of
cortical regions originating corticospinal fibers, their sum ('CST cortex'), and area of total
neocortex ('total cortex') for each of 22 mammals," listed in descending order of
`pct_CST_over_total_cortex`.

## What this item is
22 mammals, each with the areas of up to four corticospinal-tract-origin cortical regions
(Region A, B, C, C′ — defined elsewhere in the paper, not re-derived here), their sum
("CST cortex"), total neocortex area, and the printed percentage. Every row's arithmetic was
verified during this build: Region A+B+C+C′ reproduces the printed CST-cortex sum, and
100×CST/total reproduces the printed percentage, both within rounding (checked in R via
`stopifnot`).

## Species identity — a documented mismatch, not resolved here
The registry's pre-scouting note assumed "Same 22 mammals as A01" (Nudo & Masterton 1988,
`Nudo_Masterton_1988_TABLE1`). Checking this against the actual printed Fig. 2A list found this
is **not quite true**:
- TABLE1's roster includes an **armadillo** (*Dasypus novemcictus*) that does **not** appear
  anywhere in Fig. 2A's 22-row list.
- Fig. 2A includes a row printed **"LST. SHREW- C.p."** (interpreted here as *Cryptotis parva*,
  American least shrew) that does **not** appear in TABLE1's roster at all.
- TABLE1 lists the cat as *Felis catus* while Fig. 2A prints the abbreviation **"F.d."**
  (interpreted as the historical synonym *Felis domesticus* for the same species, not a different
  species).

`interpreted_taxon` carries the curator's best-guess binomial for each row, by matching the
printed common name + genus-species initials against TABLE1's roster where it is unambiguous.
Two rows are left blank rather than guessed:
- **ALBINO RAT** (printed "R.r.") — TABLE1 only records genus `Rattus` for its rat entry
  (no species given), so "R.r." could be *Rattus rattus* literally or a lab-strain
  *R. norvegicus* ("albino rat" colloquially usually means the latter); not resolved.
- **GROUND SQUIRREL** — the genus-species abbreviation is illegible/cut off in both the PDF's
  text layer and the rendered image. By elimination against TABLE1's roster (which separately
  lists "Eastern gray squirrel" = *Sciurus carolinensis*, already matched to this table's
  "GRAY SQUIRREL- S.c." row), the missing abbreviation is plausibly "C.t." for
  *Citellus tridecemlineatus* (13-lined ground squirrel) — but this is not asserted as certain.

See `reference_tables/..._definitions.csv` (`QA:species_roster_mismatch`) for the same note.

## Data role
`data_role = primary` — printed measured cortical-area data.

## Build status
Staged: `Nudo_Masterton_1990_IV_Figure2A.R` writes only the analysis CSV by default; no public
TSV is written (consistent with the sibling `Nudo_Masterton_1990_III` and `Nudo_Masterton_1988`
items in this repo, which are gated behind `EVOM1_SPINAL_NUDO_RELEASE=OWNER_VERIFIED_R_SOURCE_SCHEMA_AND_SCIENTIFIC_GATES`
per their own READMEs). This item has not been run through that same gate.

## Source
`Nudo-1990-Descending pathways to the spinal co.pdf`, Fig. 2A, p.587 (PDF page 4).
