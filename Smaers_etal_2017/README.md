# Smaers et al. 2017 — folder overview

Smaers, J. B., Gómez-Robles, A., Parks, A. N., & Sherwood, C. C. (2017). *Exceptional Evolutionary
Expansion of Prefrontal Cortex in Great Apes and Humans.* Curr Biol 27(5), 714–720.
https://doi.org/10.1016/j.cub.2017.01.020

## Table S1 is split into two builds

Supplemental Table S1 prints **two different measure classes** under one heading. They are now built
as two independent items (each: journal-faithful snapshot → reformat R → CSV + public TSV →
definitions → comparison → README):

- **Part 1 — volumes** (`Smaers_etal_2017_TableS1part1*`): the "Smaers data" block, 4
  cortical regions × {gray, white} = 8 volume columns, 19 species. `Measure = Volume`.
- **Part 2 — surface areas** (`Smaers_etal_2017_TableS1part2*`): the "Brodmann data"
  block, 4 region surface areas (mm²), 10 species. `Measure = surface area`.

See each part's `*.README.md` for details.

## Provenance & key caveats (see `primary_source_checks/`)

The frontal-lobe data are **compiled, not newly measured** — prefrontal & frontal motor from Smaers
2010 [S1] + Smaers 2011 [S2]; primary visual from de Sousa 2010 [S6]; Brodmann surface areas from
Brodmann 1909 [S3]. Two flags:

1. **Volumes labelled mm³ are actually cm³** (they reproduce Smaers 2011 exactly).
2. **Prefrontal + frontal motor is NOT the whole frontal lobe** — they are the anterior-5 and
   posterior-5 of 20 frontal sections (the two ends); their sum ≈ 37 % of total frontal-lobe
   volume. For whole frontal lobe use `../Smaers_etal_2011/` Suppl. Table 1.
   Full analysis: `primary_source_checks/frontal_lobe_source_and_partition.md`.

## Registry note (`../__ReadMe.xlsx`)

Two rows are needed for this folder (Part 1 + Part 2). Suggested **Item number** values —
`Table S1 part1 volumes` and `Table S1 part2 surface area` — which the registry's formulas collapse
(spaces/underscores removed) to Item names `Smaers_etal_2017_TableS1part1volumes` /
`...part2surfacearea` and the matching DOI-encoded TSV stems. The two reformat R scripts look these
up with a separator-insensitive key, so they resolve regardless of the underscore styling.
The ready-to-paste row contents are in `__ReadMe_rows_to_add_Smaers2017.csv`.

## `_superseded_single_table/`

The earlier single-sheet build (the mixed volumes+surface snapshot and its R/CSV/definitions) was
moved here, non-destructively, when Table S1 was split. Not used by any script.
