# Lindenfors 2002 — Appendix 2 / Table A2

Lindenfors, P. (2002). Sexually antagonistic selection on primate size. *Journal of Evolutionary Biology*, 15(4), 595–607. DOI: [10.1046/j.1420-9101.2002.00422.x](https://doi.org/10.1046/j.1420-9101.2002.00422.x). The article identifies its supplementary data as Appendix 2; the publisher's supplement labels the table **Table A2**. The local article PDF is `Lindenfors-2002-Sexually antagonistic selectio.pdf`; the original supplementary Word file is `jeb_422_sm.doc`. An [author-hosted HTML copy of the appendix](https://www.lindenfors.se/publications/Lindenfors%202002%20Sexually%20antagonistic%20selection%20on%20primate%20size%20Appendix.htm) provides another source view.

`Lindenfors__2002_TableA2_snapshot.csv` is the frozen table capture. On 2026-11-24, an AI assistant used `antiword -x db` to read the publisher DOC's table cells, then the separate `Lindenfors__2002_TableA2_snapshot.R` script wrote the snapshot. It retains the source's column and species order, original numeric strings and units, mating-system categories, blank cells, the nine name-only species rows, and the variable-level `Data sources:` note. The original DOC is held unchanged. The snapshot script refuses to overwrite an existing snapshot. The source heading for birth rate has unusual parentheses; its wording is retained in the snapshot. No table values are hardcoded in either script.

Run from repository root:

```sh
Rscript --vanilla Lindenfors__2002/Lindenfors__2002_TableA2.R
```

The reader uses only its frozen snapshot and writes `Lindenfors__2002_TableA2.csv` plus the DOI-coded public TSV, with `Item encoded` resolved by item name from `__ReadMeAddON.xlsx`. There are 203 source species rows: 194 have at least one populated trait or mating-system cell, and nine contain only the species name. These nine are retained and marked `source_has_traits = FALSE`. The output has 178 female body-mass entries. Male and female adult weights and weight at weaning are converted from source kg to project g. All other numeric columns retain the source values and indicated units. The appendix does not print units for foetal or postnatal growth rates, so their output fields explicitly say `_source`; the article describes their calculations, but no unit is imputed in the table. Missing cells remain missing.

The source labels, including historical spellings, are preserved verbatim in `species_as_published` and `Species`; no name or Order was inferred. Mating-system categories such as `MM`, `Mon`, `UM`, and combined variants are not recoded. Variable definitions are in `reference_tables/Lindenfors__2002_TableA2_definitions.csv`.

## Table checks

The R reader checks two relations described by the article using only rows with all needed source cells. All 102 evaluable birth-rate rows agree with litter size divided by interbirth interval within 0.03 offspring/year; the largest absolute difference is 0.02842. All 82 evaluable foetal-growth rows agree with neonate mass times litter size divided by gestation days within 0.006 in the source's growth-rate scale; the largest absolute difference is 0.005. Tolerances allow rounding in printed inputs. The source values are retained even if a future check fails. These are internal arithmetic checks, not independent validation of the underlying measurements.

## Provenance and use

This is a **secondary literature compilation**. The supplement provides a variable-level source list but no per-species citations. The article says adult body weights came from Smith and Jungers (1997), sex-specific neonate weights from Smith and Leigh (1998), and weaning weights estimated from growth curves in Lee (1999). The table may overlap Harvey and Clutton-Brock (1985) and other compiled sources. Trace a primary publication and resolve taxon concepts before pooling any value as an independent observation. Human side-by-side signoff of the full appendix remains pending; the AddON registry records that status. This is a table-derived item, so no figure replot applies.
