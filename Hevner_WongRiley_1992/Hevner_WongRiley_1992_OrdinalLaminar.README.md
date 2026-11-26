# Hevner_WongRiley_1992_OrdinalLaminar

**2026-11-26 public completion.** The item now has an exact row in the main `__ReadMe.xlsx` registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_WongRiley_1992/Hevner_WongRiley_1992_OrdinalLaminar.R` wrote `__Public/comparative-data/10.1002%2Fcne.903260310_OrdinalLaminar.tsv`. Earlier “not registered” or “public TSV pending” statements below describe the initial build date. Human source review remains as separately recorded.


**Item name** `Hevner_WongRiley_1992_OrdinalLaminar` · **Item number** `Ordinal Laminar` · **Item encoded** `10.1002%2Fcne.903260310_OrdinalLaminar` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Hevner_WongRiley_1992_OrdinalLaminar_registry_row.xlsx`.

Hevner, R. F., & Wong-Riley, M. T. T. (1992). Entorhinal cortex of the human, monkey, and rat: Metabolic map as revealed by cytochrome oxidase. *Journal of Comparative Neurology*, 326(3), 451–469. <https://doi.org/10.1002/cne.903260310>

**Item full original title:** Ordinal laminar cytochrome-oxidase statements for the entorhinal cortex of human, monkey and rat (Abstract p. 451; Results pp. 453–461 by species and EC field; Figs. 2, 6, 9 legends; Discussion pp. 463–467). Constructed statement table; the paper prints no table.

## Source

PDF in this folder: `Hevner-1992-Entorhinal cortex of the human, mo.pdf` (Wiley scan with OCR text layer, 19 pages = journal pp. 451–469). DOI verified against the page-head stamp and CrossRef on 2026-11-18 (J Comp Neurol 326: 451–469, 1992; Hevner & Wong-Riley). All 19 pages inspected: Figs. 1–9 are photomicrographs; no table, no plot, no densitometry — the paper is qualitative.

## What this item is — and is not

**These are ordinal readings of the authors' own words, not measurements.** The paper gives no optical density for any cortical layer. Each row is one printed qualitative statement about cytochrome-oxidase (CO) reactivity of a layer, laminar compartment or area; `state` is our coding of the printed adjective (the verbatim clause is kept in `printed_wording`); `state_score` (1–7) and `ordinal_rank` (1 = darkest, dense rank within species × area × subfield × condition) are **derived from those adjectives** and imply no interval scale. Relative statements ("less reactive than the clusters") carry the comparison in `comparison_target` and are not ranked. Restatements of an already-rowed layer and groups with a single rankable statement get no rank (`rank_scope`). Schema: the `Preuss_etal_1999` statement-row convention (`row, row_type, taxon_as_printed, taxon_in_methods, species_as_published, Species, taxon_level, cortical_area, layer, marker, feature, trait, state, value_low, value_high, unit, n_individuals, state_basis, printed_wording, source_locator, observation_level, data_role, note`) plus `subfield, compartment, condition, comparison_target, state_score, ordinal_rank, rank_scope, source`.

Coding rules (fixed in the build script, never extended silently): darkest/highest = 7; dark, relatively dark, particularly high = 6; moderate-to-dark = 5; moderate = 4; light-to-moderate (printed "low-to-moderate", "lightly or moderately", "light-to-moderately") = 3; light, relatively low = 2; pale, relatively pale, least reactive, lightest = 1. Printed "high" / "CO-rich" / "specifically heightened" are coded dark; the printed word is always in `printed_wording`.

## What was rowed

175 statement rows: 78 human, 57 monkey, 40 rat. By source: Abstract p. 451 (group statements expanded to the three species), Results — human fields Eo, ER, EI, Ec, ECL, ELr/ELc and tangential sections (pp. 453–457), monkey fields Eo, ER, EI, Ec, ECL, ELr/ELc (pp. 459–461), rat fields EM (dorsal vs ventral) and EL and the atypical EC (p. 461), Fig. 2 / 6 / 9 legends, and the Discussion "Comparative laminar and field analysis" (pp. 463–466) and "Modular patterns" / "Species differences" (p. 467). Layers as the paper names them: I, II, III, IV (= lamina dissecans, Ramón y Cajal), V / Vab / Va / Vb / Vc, VI; compartments: neuron clusters, interstices, islands, bridges, layer-I regions above clusters, upper/lower/outer/inner portions. Trait mix: 108 absolute laminar intensities, 37 relative, 28 presence/absence (islands, bridges, modularity, distinct layer IV), 2 value rows (island diameter 200–800 µm; ~200–250 islands — also in `Hevner_WongRiley_1992_Text`).

## Pipeline

```
Source (PDF)
  -> Hevner_WongRiley_1992_OrdinalLaminar_snapshot.R   writes the frozen CONSTRUCTED snapshot (hand-typed statement block)
  -> Hevner_WongRiley_1992_OrdinalLaminar_snapshot.csv   FROZEN: 176 rows x 20 cols (header + 175 statements)
  -> Hevner_WongRiley_1992_OrdinalLaminar.R   vocabulary check + species key + trait codes + state_score + ordinal_rank
  -> Hevner_WongRiley_1992_OrdinalLaminar.csv   175 rows x 31 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fcne.903260310_OrdinalLaminar.tsv   (written by the build once registered)
  -> reference_tables/Hevner_WongRiley_1992_OrdinalLaminar_definitions.csv
```

## Who read the statements, when, and how it was checked

Hand transcription (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18 from the PDF text layer, with laminar adjectives, layer labels and every number checked on page renders (pages listed in the snapshot script header). The build script was run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8`) from a clean session on 2026-11-18; it stops, as expected, at `Expected one registered item row for Hevner_WongRiley_1992_OrdinalLaminar` because the item is not yet registered (the analysis CSV is written before that point). Vocabulary check: every `state_as_read` is in the fixed vocabulary and every relative state has a comparison target (the build stops otherwise).

## Ordinal ranking (compact; derived from the adjectives)

**Human, field EI (largest field; Results pp. 453–455):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| adult | I | places overlying layer II neuron clusters | dark | 1 | Results, p. 455 |
| adult | II | neuron clusters | dark | 1 | Results, p. 455 |
| adult | III | neuron clusters | dark | 1 | Results, p. 455 |
| adult | Vab | whole layer | moderate | 2 | Results, p. 455 |
| adult | VI | whole layer | moderate | 2 | Results, p. 455 |
| adult | I | whole layer (generally) | light | 3 | Results, p. 455 |
| adult | IV | whole layer | light | 3 | Results, p. 455 |
| adult | Vc | whole layer | light | 3 | Results, p. 455 |

**Monkey (Macaca sp.), field EI (Results p. 459; Fig. 6 legend p. 463):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| adult | II | whole layer | dark | 1 | Fig. 6 legend, p. 463 |
| adult | III | whole layer | dark | 1 | Fig. 6 legend, p. 463 |
| adult | Va | whole layer | moderate | 2 | Results, p. 459 |
| adult | Vb | whole layer | moderate | 2 | Results, p. 459 |
| adult | VI | whole layer | moderate | 2 | Results, p. 459 |
| adult | I | whole layer | light | 3 | Results, p. 459 |
| adult | IV | whole layer | light | 3 | Results, p. 459 |
| adult | Vc | whole layer | light | 3 | Results, p. 459 |
| adult | V and VI | radial myelinated fiber bundles | pale | 4 | Results, p. 459 |

**Rat, field EM (Results p. 461; dorsal and ventral EM ranked separately):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| adult, all dorsoventral levels | II | whole layer (thick, continuous) | dark | 1 | Results, p. 461 |
| adult, all dorsoventral levels | III | border with layer II | dark | 1 | Results, p. 461 |
| adult, all dorsoventral levels | III | whole layer | moderate | 2 | Results, p. 461 |
| adult, all dorsoventral levels | I | whole layer | light-to-moderate | 3 | Results, p. 461 |
| adult, dorsal EM | V | whole layer | moderate | 1 | Results, p. 461 |
| adult, dorsal EM | IV (lamina dissecans) | whole layer | light | 2 | Results, p. 461 |
| adult, dorsal EM | VI | whole layer | light | 2 | Results, p. 461 |
| adult, ventral EM | V | whole layer (cell bodies and neuropil) | dark | 1 | Results, p. 461 |
| adult, ventral EM | IV (lamina dissecans) | whole layer | moderate | 2 | Results, p. 461 |
| adult, ventral EM | VI | whole layer | moderate | 2 | Results, p. 461 |

**All three species, 'EC (general)' = the Discussion's comparative laminar analysis (pp. 463–466); ranks identical for human and monkey, rat lacks the II-and-III row:**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| adult | II | cellular portions, in particular neuron clusters | darkest | 1 | Discussion, p. 463 |
| adult | II | much of layer | dark | 2 | Discussion, p. 463 |
| adult | II and III | cellular portions | dark | 2 | Discussion, p. 466 |
| adult | VI | whole layer (generally) | moderate | 3 | Discussion, p. 466 |
| adult | Va-b | whole layer | moderate | 3 | Discussion, p. 466 |
| adult | I | whole layer (mostly) | light-to-moderate | 4 | Discussion, p. 463 |
| adult | IV (lamina dissecans) | whole layer | light-to-moderate | 4 | Discussion, p. 466 |
| adult | V | most of layer | light-to-moderate | 4 | Discussion, p. 466 |

Other fields (Eo, ER, Ec, ECL, ELr/ELc; rat EL) are ranked in the CSV the same way (`rank_scope = "layers within area"`).

## Species names

The text prints 'human', 'monkey' / 'macaque monkey' and 'rat'; Methods (p. 452) give the macaques as two *Macaca fascicularis*, two *M. radiata*, two *M. mulatta* (pooled in all Results, so the monkey rows resolve to the genus anchor `Macaca sp.`, taxid 9539) and the rats as Sprague-Dawley. Nine variant rows with `source_publication = Hevner_WongRiley_1992` were appended to `_keys/General/species_key.csv` on 2026-11-18; the build stops if the key filter returns no rows. `n_individuals`: human 4 individuals (6 hemispheres), monkey 6, rat 7.

## Use

For the laminar-metabolism question the relevant rows are the absolute laminar states per field (filter `trait == "CO_laminar_intensity"`, `rank_scope == "layers within area"`), e.g. human EI: clusters of II and III dark (rank 1) > Vab, VI moderate (2) > I, IV, Vc light (3). The cross-species message of the paper (Discussion p. 466): layer II clusters darkest in all three species; in primates layer III cellular portions as dark as II, in rat layer III lighter than II; lamina dissecans and Vc light (myelin); rat ventral EM layer V dark (subicular input). Do not average `state_score` across rows; treat it as ordinal.

## Data role

**primary** throughout (the authors' own observations on their own material).

## Unresolved / not captured

- No numeric CO value exists in the paper; any pairing with densitometric items must be ordinal (rank correlation at best).
- Field boundaries in tangential sections were 'probable' (p. 455); the anteromedial/posterolateral island-group rows keep the authors' 'probably'.
- The Results sentence for human ECL layer I says only 'except above neuron clusters'; the state 'dark' for that compartment is taken from the Fig. 2 legend (row cross-noted).
- 'especially in the human' (Abstract) for dark neuropil adjacent to clusters is rowed for human only; the monkey (no dark layer-I regions above clusters) and rat (no columnar extensions into layer I) statements are rowed as 'absent'.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside the cited pages, read a sample of rows against the sentences, confirm the adjective coding, and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.
