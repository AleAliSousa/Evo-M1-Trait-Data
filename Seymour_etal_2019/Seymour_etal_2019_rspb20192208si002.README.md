# Seymour et al. (2019) — electronic supplementary material 002

Seymour RS, Bosiocic V, Snelling EP, Chikezie PC, Hu Q, Nelson TJ, Zipfel B, Miller CV
(2019). *Cerebral blood flow rates in recent great apes are greater than in
Australopithecus species that had equal or larger brains.* Proc Biol Sci 286:20192208.
DOI 10.1098/rspb.2019.2208. Item name `Seymour_etal_2019_rspb20192208si002`.

## Source → snapshot → CSV → TSV

- **Source:** `rspb20192208_si_002.xlsx` — "Great Ape internal carotid foramen
  measurements" (one sheet; 119 individual great-ape / human skulls with bilateral
  foramen measurements + a museum-abbreviation key).
- **Snapshot:** `Seymour_etal_2019_rspb20192208si002_snapshot.xlsx` (sheet `SI002`) — a
  frozen, journal-faithful copy: title/author rows, the two-tier `Right`/`Left` group
  header, the column-name and unit rows, all 119 specimen rows in printed order, and the
  museum key footnotes. No cleaning in the snapshot.
- **Reformat:** `Seymour_etal_2019_rspb20192208si002.R` reads the snapshot by position,
  keeps the specimen rows (Genus present), trims the genus (`"Pan " → "Pan"`), builds
  `Species_binomial`, and keeps both foramina (`Right_*`, `Left_*`) with units as printed
  (ECV ml; area mm²; diameters/radii mm). It writes:
  - `Seymour_etal_2019_rspb20192208si002.csv` — one row per specimen (119).
  - `10.1098%2Frspb.2019.2208_rspb20192208si002.tsv` in `__Public/comparative-data/`.

Granularity is **per individual specimen**. Taxa: *Gorilla beringei/gorilla/sp.*,
*Pan troglodytes/paniscus/sp.*, *Pongo pygmaeus/abelii/sp.*, *Homo sapiens*.

## Species names

`Species_binomial` is the join name; all 10 distinct binomials were added to
`_keys/Stephan/species_key.csv` under token **`Seymour2019`**. Because this table
identifies most specimens to species, the species-level names are kept as accepted
(e.g. *Gorilla gorilla*, *Gorilla beringei*), with `sp.` retained for indeterminate
individuals.

> **Flag for the curator:** genus-level lumping is handled differently across the
> Seymour tables — 2015's single genus-mean rows resolve to `Gorilla sp.` / `Pongo sp.`,
> whereas 2019's species-resolved specimens keep `Gorilla gorilla`, `Pongo pygmaeus`,
> etc. Confirm this is the intended treatment before these feed a shared merge.

## Comparison / QA

No independent curated copy of this file exists in the project, so there is **no
comparison script** (its absence is not a defect, per the guide).

## Data role

Great-ape / hominin foramen morphometrics (metabolic/blood-flow lineage), per individual.
Set the `Data role` flag in `__ReadMe.xlsx`.
