# Iwaniuk et al. 1999 — Table 1 (traits used in the comparative analysis)

Iwaniuk AN, Pellis SM, Whishaw IQ (1999). *Is digital dexterity really related to corticospinal
projections?: a re-analysis of the Heffner and Masterton data set using modern comparative
statistics.* Behav Brain Res 101(2):173–187. doi:10.1016/s0166-4328(98)00151-x

Full table title (see `__ReadMe.xlsx`): **"Table 1. The anatomical and behavioural traits used
in the comparative analysis."** 25 species.

## Overlap with Heffner & Masterton
This paper is a re-analysis of the **Heffner & Masterton** dataset, so Table 1 overlaps the
Heffner & Masterton 1975/1983 tables directly: the `Dexterity` column is the same digital-dexterity
score, and `Depth`/`Length` are re-scored corticospinal-tract termination and projection measures
drawn from the same source literature. Iwaniuk et al. add three new variables (`Arboreality`,
`Diet`, `Hand–eye`) and — usefully — print the **corrected modern binomials** for species that are
mis-spelled in the Heffner tables (e.g. *Ateles ater*, *Saguinus oedipus*, *Didelphis virginiana*,
*Rattus norvegicus*, *Felis*, *Potorous tridactylus*, *Myocastor coypus*). This table can serve as
a species crosswalk for the Heffner 1975/1983 `Species` columns.

## Source → Snapshot
PDF (paywalled) exported to Excel via Acrobat, Table 1 copied and hand-formatted into
`Iwaniuk_etal_1999_Table1_snapshot.xlsx` (frozen). The companion reference list is built separately
(see `Iwaniuk_etal_1999_References`).

## Data readable
`Iwaniuk_etal_1999_Table1.R` → `Iwaniuk_etal_1999_Table1.csv` (**use this**). The scientific name
is promoted to `Species`; the common name stays in `Species Generic Name`; the `Depth` and `Length`
cells are split into a value plus a `*_Ref` reference number that keys into
`Iwaniuk_etal_1999_References.csv`. Columns defined in
`reference_tables/Iwaniuk_etal_1999_Table1_definitions.csv`.
*Note: a few `Depth`/`Length` values carry a trailing space from the extraction (cosmetic).*

## Species note
`Species` holds Iwaniuk's scientific binomials as printed (already modernised relative to Heffner);
reconcile to `_keys/Stephan/species_key.csv` downstream. Taxonomy not further modified.

## Provenance
Secondary compilation / re-analysis of Heffner & Masterton plus added ecological scores.
Measure: behavioural (digital dexterity) + corticospinal tract + ecology.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
(`10.1016%2Fs0166-4328(98)00151-x_Table1.tsv` in `__Public/comparative-data/`)
