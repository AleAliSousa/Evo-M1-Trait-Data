# Winkler & Bryant 2021 — Figure 1 / Table 1 (play vocalisations)

Winkler SL, Bryant GA (2021). *Play vocalisations and human laughter: a comparative review.*
Bioacoustics 31(6):1–28. doi:10.1080/09524622.2021.1905065

Comparative review of the species reported to produce **play vocalisations**. Table 1 lists the
species (67 rows as printed; the paper states N = 65 — the domesticated ferret is not shown
separately in Figure 1 and the human/ferret bookkeeping differs). Figure 1 is a cladogram of the
same species that codes two extra variables by colour and marker.

## This is play data
Tagged `behavioural (play vocalisations)` in `__ReadMe.xlsx`. It is the project's second play
source alongside Iwaniuk et al. 2001 (play scores). Different measure: this is about the *acoustic
form* of play calls, not play frequency/complexity.

## Source → Snapshot
The article is paywalled; data live in Table 1 (species list + acoustic descriptors, pp. 6–10) and
Figure 1 (cladogram, p. 12). Table 1 was transcribed from the PDF pages (read as images) and
combined with the two Figure 1 variables into
`Winkler_Bryant_2021_Figure1_snapshot.xlsx` (sheet `Figure1_snapshot`): row 1 = title, row 2 =
header, one row per species, values as printed. The Table 1 columns (`taxa_group` … `reference`)
are verbatim; `figure1_feature_category` and `loud_play_vocalisation` are transcribed from the
Figure 1 colour key and diamond markers. *Recommend a visual diff against the PDF before publication.*

## Data readable
`Winkler_Bryant_2021_Figure1.R` → `Winkler_Bryant_2021_Figure1.csv` (**use this**). Normalises the
`play_specific` capitalisation and turns printed `N/A` into `NA`. Columns defined in
`reference_tables/Winkler_Bryant_2021_Figure1_definitions.csv`.

## Figure 1 coding
`figure1_feature_category` (colour key): `panting_heavy_breathing` (18), `high_pitched_tonal` (14),
`hissing` (4), `purring_grumbling` (3), `ultrasonic` (2), `mixed` (1, vervet – hatched), `none`
(24, uncoloured tips), `not_in_figure` (1, ferret). `loud_play_vocalisation = Y` for the 7 species
marked with a black diamond (Kea parrot, African elephant, Harbor seal, California sea lion,
Domestic dog, Common squirrel monkey, Human).

## Species note
`Species` holds the binomials as printed (already modern, e.g. *Chlorocebus aethiops*, *Sapajus*
not used here; two subspecies trinomials kept: *Gorilla gorilla gorilla*, *Gorilla beringei
beringei*, *Cervus canadensis nelsoni*, *Mustela putorius furo*). Reconcile to
`_keys/Stephan/species_key.csv`. Overlaps in species with Iwaniuk 2001 (play) and the primate
dexterity/manipulation papers.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ☐ (run the R
script with the full repo mounted to write the DOI-named TSV to `__Public/comparative-data/`)
