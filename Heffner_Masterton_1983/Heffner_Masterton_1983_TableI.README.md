# Heffner & Masterton 1983 — Table I (Animals and descriptive data)

Heffner RS, Masterton RB (1983). *The role of the corticospinal tract in the evolution of
human digital dexterity.* Brain Behav Evol 23(3–4):165–183. doi:10.1159/000121494

Full table title (see `__ReadMe.xlsx`): **"Table I. Animals and descriptive data on which all
correlations are based."** 21 species rows. This is the smaller successor sample to
Heffner & Masterton 1975 Table I (`compare to 1975`).

## Source → Snapshot
Layout audit and correction (2026-11-27): rebuilt the 1983 Table I workbook as the printed 11-column table. Each animal's scientific name now occupies the line beneath the common name in the Animal column; grouped heading tiers and the continued-page heading are present. The R reader pairs those rows. Run `Rscript Heffner_Masterton_1983/Heffner_Masterton_1983_TableI.R` from the repository root; the 21-row analysis CSV remained byte-identical (SHA-256 `62f677f6b2fc7d24d838ae879ef1e81af89049c1dad5e91c8f3f793ea86d17f6`). This layout audit is separate from human source signoff.

PDF is paywalled and Table I is laid out across pages with stacked value/[reference] cells.
Transcribed by hand (kept to the original layout) and cross-checked against an AI table
extraction of the PDF. The frozen transcription lives in
`Heffner_Masterton_1983_TableI_snapshot.xlsx` (sheet `TableI_snapshot`): title and grouped
column headings precede paired common-name and scientific-name rows; the continued page has
its repeated headings. Values and bracketed references remain in the printed columns.
`Heffner_Masterton_1983_Tables.xlsx` holds the same Table I plus Tables II–IV
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
