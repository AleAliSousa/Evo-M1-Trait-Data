# Heffner & Masterton 1983 — Table I (Animals and descriptive data)

Heffner RS, Masterton RB (1983). *The role of the corticospinal tract in the evolution of
human digital dexterity.* Brain Behav Evol 23(3–4):165–183. doi:10.1159/000121494

Full table title (see `__ReadMe.xlsx`): **"Table I. Animals and descriptive data on which all
correlations are based."** 21 species rows. This is the smaller successor sample to
Heffner & Masterton 1975 Table I (`compare to 1975`).

## Source → Snapshot
PDF is paywalled and Table I is laid out across pages with stacked value/[reference] cells.
Transcribed by hand (kept to the original layout) and cross-checked against an AI table
extraction of the PDF. The frozen transcription lives in
`Heffner_Masterton_1983_TableI_snapshot.xlsx` (sheet `TableI_snapshot`): row 1 = title,
row 2 = column names, then one row per animal, values and bracketed references exactly as
printed. `Heffner_Masterton_1983_Tables.xlsx` holds the same Table I plus Tables II–IV
(dexterity scale, correlations, partial correlations) for reference.
*Recommend a visual diff against the PDF before publication.*

## Data readable
`Heffner_Masterton_1983_TableI.R` → `Heffner_Masterton_1983_TableI.csv` (**use this**).
Each measurement cell is split into a numeric value and its bracketed `*_ref`; numbers parsed;
common names moved to `common_name`, binomial to `Species`. Columns defined in
`reference_tables/Heffner_Masterton_1983_TableI_definitions.csv`.

## Species note
`Species` holds the binomial with two obvious transcription typos corrected —
*Erinaceous* → *Erinaceus* and *Macaca ira* → *Macaca irus* — while the exact printed string is
kept in `Species_as_printed`. The corrections are applied from
`reference_tables/Heffner_Masterton_1983_TableI_species_crosswalk.csv` (the same crosswalk system
used for the 1975 table; neither of these two is in Iwaniuk 1999, so both are marked as spelling
fixes). One further row is **imputed** from Iwaniuk 1999 (flagged `Iwaniuk_etal_1999_imputed` in the
new `species_basis` column): the genus-only *Didelphis* → *Didelphis virginiana*. Taxonomy is
**not** modernised (e.g. *Cercopithecus pygerythrus*, *Hylobates syndactylus*, *Galago
crassicaudatus*, *Pongo pygmaeus* left as printed; reconcile to `_keys/Stephan/species_key.csv`
downstream). The remaining genus-only rows (*Paraechinus*, *Tarsius*, *Erinaceus*) are kept as
printed. Note *Macaca irus* = *M. fascicularis*.

## Provenance
Secondary compilation: most anatomical values are drawn from the bracketed literature sources,
behavioural ranks (phyletic level, digital dexterity) are Heffner & Masterton's own scales.
Measure: behavioural (digital dexterity) + corticospinal tract morphometry.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ☐ (run the
R script with the full repo mounted to write the DOI-named TSV to `__Public/comparative-data/`)
