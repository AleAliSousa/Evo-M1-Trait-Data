# Heldstab et al. 2016 — Supplementary Table S1 (manipulation complexity)

Heldstab SA, Kosonen ZK, Koski SE, Burkart JM, van Schaik CP, Isler K (2016). *Manipulation
complexity in primates coevolved with brain size and terrestriality.* Sci Rep 6:24528.
doi:10.1038/srep24528

Full table title: **"Table S1. List of species and data used for this study."** 37 primate species.

## Overlap with the dexterity / manipulation papers
This is a **manual-skill** dataset: the focal trait `MC` (manipulation complexity) is in the same
family as the digital-dexterity scores in Heffner & Masterton 1975/1983 and Iwaniuk et al. 1999,
and it shares many primate species with Caspar et al. 2022 (hand preference) — see the overlap
summary. The table also carries brain-size measures (endocranial volume, neocortex, cerebellum),
so its species may already appear in the repo's volume merge; check before combining.

## Source → Snapshot
The article is open access but the data live only in the supplement PDF (`srep24528-s1.pdf`,
Table S1, pp. 4–6), a wide ~18-column table with wrapped species/site cells. Extracted with a
layout-preserving text pass and transcribed into `Heldstab_etal_2016_TableS1_snapshot.xlsx`
(sheet `TableS1_snapshot`): row 1 = title, row 2 = header, one row per species, values as printed
with `-` for "not given". Every numeric value was cross-checked back against the PDF text.
*Recommend a visual diff against the PDF before publication.*

## Data readable
`Heldstab_etal_2016_TableS1.R` → `Heldstab_etal_2016_TableS1.csv` (**use this**). Turns the printed
`-` into `NA`, parses numerics, and keeps `n_individuals` as text (some rows give per-group counts
like `3/2`). Columns defined in `reference_tables/Heldstab_etal_2016_TableS1_definitions.csv`.

## Species note
`Species` holds the printed binomials, which are already modern (e.g. *Sapajus apella*,
*Symphalangus syndactylus*, *Pongo abelii*); reconcile to `_keys/Stephan/species_key.csv`.

## Provenance
Primary behavioural scoring (manipulation complexity) by the authors; brain/body and cognition
measures compiled from cited sources (see definitions notes).

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ☐ (run the
R script with the full repo mounted to write the DOI-named TSV to `__Public/comparative-data/`)
