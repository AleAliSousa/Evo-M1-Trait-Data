# Heffner & Masterton 1975 — Table I (pyramidal tract and digital dexterity)

Heffner R, Masterton B (1975). *Variation in form of the pyramidal tract and its relationship to
digital dexterity.* Brain Behav Evol 12(3):161–200. doi:10.1159/000124401

Full table title (see `__ReadMe.xlsx`): **"Table I"** — animals, pyramidal-tract morphometry and
digital dexterity. 69 animal rows spanning mammals. Superseded by the smaller
Heffner & Masterton 1983 Table I sample (`compare to 1983`).

## Source → Snapshot
PDF is paywalled and Table I runs over several pages. Transcribed by hand (kept to the original
layout) and cross-checked against an AI table extraction of the PDF. Frozen transcription:
`Heffner_Masterton_1975_TableI_snapshot.xlsx`. (`pyramidal_tract_data.xlsx` is a working copy.)
*Recommend a visual diff against the PDF before publication.*

## Data readable
`Heffner_Masterton_1975_TableI.R` → `Heffner_Masterton_1975_TableI.csv` (**use this**). The script
reads the snapshot, makes the headings readable, collapses the stacked value/reference rows into
one row per animal, and parses numbers. Common name is in `Animal`; the binomial is in `Species`.
Columns defined in `reference_tables/Heffner_Masterton_1975_TableI_definitions.csv`.

## Species note
`Species` now holds the binomial with obvious transcription typos **corrected**; the exact printed
string is kept in `Species_as_printed`. The 11 corrections are listed with their basis in
`reference_tables/Heffner_Masterton_1975_TableI_species_crosswalk.csv`: two are taken from Iwaniuk
et al. 1999's re-analysis of this same dataset (*Ateleus ater* → *Ateles ater*; *Saquinas oedipus*
→ *Saguinus oedipus*) and nine are obvious spelling fixes (*Elephus* → *Elephas*, *Sciurrrus* →
*Sciurus*, *Spermophillus* → *Spermophilus*, *Tasarida* → *Tadarida*, *Phocaena* → *Phocoena*,
*Castor canadiensis* → *canadensis*, *Erinaceous* → *Erinaceus*, *Macaca ira* → *Macaca irus*,
*Tachyglossus aculeata* → *aculeatus*). Taxonomy is **not** modernised, so valid old names and
genus reassignments are left alone (e.g. *Cricetus auratus*, *Microsorex hoyi*, *Felis catus*), as
are the remaining genus-only entries (*Myotis*, *Rhinolophus*, *Tarsius*, *Tapirus*, *Camelus*,
*Equus*, *Erinaceus*, *Paraechinus*) and the uncertain *Horpyiocepalus leucogostra*.

Two rows are **imputed** from Iwaniuk 1999 (flagged `Iwaniuk_etal_1999_imputed` in `species_basis`
and in the crosswalk): the genus-only *Didelphis* → *Didelphis virginiana*, and the "Rat
(unspecified)" row → *Rattus norvegicus*. Four rows the paper leaves genuinely unspecified (bear,
cow, deer, mouse) keep `Species = NA` (`species_basis = unspecified_in_source`). The new
`species_basis` column flags the provenance of every `Species` value. Reconcile to
`_keys/Stephan/species_key.csv` downstream.

## Provenance
Secondary compilation: anatomical values are drawn largely from the cited literature (see the
`*_ref` columns); the digital-dexterity rank is Heffner & Masterton's own scale.
Measure: behavioural (digital dexterity) + corticospinal tract morphometry.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
(`10.1159%2F000124401_TableI.tsv` in `__Public/comparative-data/`)
