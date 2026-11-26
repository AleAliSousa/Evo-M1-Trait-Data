# Hevner_etal_1995_OrdinalLaminar

**2026-11-26 public completion.** The item now has an exact row in the main `__ReadMe.xlsx` registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_etal_1995/Hevner_etal_1995_OrdinalLaminar.R` wrote `__Public/comparative-data/10.1016%2F0306-4522(94)00514-6_OrdinalLaminar.tsv`. Earlier “not registered” or “public TSV pending” statements below describe the initial build date. Human source review remains as separately recorded.


**Item name** `Hevner_etal_1995_OrdinalLaminar` · **Item number** `Ordinal Laminar` · **Item encoded** `10.1016%2F0306-4522(94)00514-6_OrdinalLaminar` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Hevner_etal_1995_OrdinalLaminar_registry_row.xlsx`.

Hevner, R. F., Liu, S., & Wong-Riley, M. T. T. (1995). A metabolic map of cytochrome oxidase in the rat brain: Histochemical, densitometric and biochemical studies. *Neuroscience*, 65(2), 313–342. <https://doi.org/10.1016/0306-4522(94)00514-6>

**Item full original title:** Ordinal cytochrome-oxidase statements for rat cerebral cortex: laminar statements of Results 'Cerebral cortex' (p. 335), Fig. 29 legend (p. 332), Discussion pp. 339, 341, and the area-level ordinal statements of pp. 332–335. Constructed statement table.

## Source

PDF in this folder: `Hevner-1995-A metabolic map of cytochrome oxid.pdf` (Elsevier scan with OCR layer, 30 pages = journal pp. 313–342). DOI as registered. Quantified content is in the sibling items `_Figure31` (regional OD / biochemistry), `_Figure32` (perikaryal OD) and `_Text`.

## What this item is — and is not

**These are ordinal readings of the authors' own words, not measurements.** The paper gives no optical density for any cortical layer. Each row is one printed qualitative statement about cytochrome-oxidase (CO) reactivity of a layer, laminar compartment or area; `state` is our coding of the printed adjective (the verbatim clause is kept in `printed_wording`); `state_score` (1–7) and `ordinal_rank` (1 = darkest, dense rank within species × area × subfield × condition) are **derived from those adjectives** and imply no interval scale. Relative statements ("less reactive than the clusters") carry the comparison in `comparison_target` and are not ranked. Restatements of an already-rowed layer and groups with a single rankable statement get no rank (`rank_scope`). Schema: the `Preuss_etal_1999` statement-row convention (`row, row_type, taxon_as_printed, taxon_in_methods, species_as_published, Species, taxon_level, cortical_area, layer, marker, feature, trait, state, value_low, value_high, unit, n_individuals, state_basis, printed_wording, source_locator, observation_level, data_role, note`) plus `subfield, compartment, condition, comparison_target, state_score, ordinal_rank, rank_scope, source`.

Coding rules (fixed in the build script, never extended silently): darkest/highest = 7; dark, relatively dark, particularly high = 6; moderate-to-dark = 5; moderate = 4; light-to-moderate (printed "low-to-moderate", "lightly or moderately", "light-to-moderately") = 3; light, relatively low = 2; pale, relatively pale, least reactive, lightest = 1. Printed "high" / "CO-rich" / "specifically heightened" are coded dark; the printed word is always in `printed_wording`.

## What was rowed

25 statement rows: 4 laminar statements with an absolute state, 4 relative laminar statements, 12 area-level statements (layer = 'all layers (area-level)'), and 2 other (layers III–IV by CO and 2-DG, p. 341; pale neuron types, p. 335 — perikaryal, quantified in `Hevner_etal_1995_Figure32`). The task anticipated per-area laminar descriptions (Fr1/Fr2, Par1, Te1, Oc1, Oc2, cingulate, retrosplenial, insular, piriform, hippocampal strata); **the paper does not print them** — Results 'Cerebral cortex' (p. 335) gives one general rule (layers III–IV darkest in most areas, e.g. limb sensorimotor cortex), the entorhinal exception (layer II; layer V ventromedially), the granular/dysgranular and barrel/septa contrasts and the lateral-entorhinal islands; the hippocampal formation is described only as 'overall moderate' with 'considerable heterogeneity'. Every printed laminar statement is rowed; nothing was inferred from the plates (Figs 1–28 carry area labels but no printed intensity words). Primary auditory cortex has two area-level rows that sit in tension (p. 335 'highest overall'; p. 332 'somewhat lower ... focally low to moderate or high' relative to the auditory brainstem nuclei); both kept.

## Pipeline

```
Source (PDF)
  -> Hevner_etal_1995_OrdinalLaminar_snapshot.R   writes the frozen CONSTRUCTED snapshot (hand-typed statement block)
  -> Hevner_etal_1995_OrdinalLaminar_snapshot.csv   FROZEN: 26 rows x 20 cols (header + 25 statements)
  -> Hevner_etal_1995_OrdinalLaminar.R   vocabulary check + species key + trait codes + state_score + ordinal_rank
  -> Hevner_etal_1995_OrdinalLaminar.csv   25 rows x 31 cols  ("use this")
  -> __Public/comparative-data/10.1016%2F0306-4522(94)00514-6_OrdinalLaminar.tsv   (written by the build once registered)
  -> reference_tables/Hevner_etal_1995_OrdinalLaminar_definitions.csv
```

## Who read the statements, when, and how it was checked

Hand transcription (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18 from the PDF text layer, with laminar adjectives, layer labels and every number checked on page renders (pages listed in the snapshot script header). The build script was run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8`) from a clean session on 2026-11-18; it stops, as expected, at `Expected one registered item row for Hevner_etal_1995_OrdinalLaminar` because the item is not yet registered (the analysis CSV is written before that point). Vocabulary check: every `state_as_read` is in the fixed vocabulary and every relative state has a comparison target (the build stops otherwise).

## Ordinal ranking (compact; derived from the adjectives)

**Laminar statements (all that the paper prints):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| adult | IV | whisker barrels | dark | 1 | Results, p. 335 |
| adult | II | cell clusters (CO-reactive islands) | dark | 1 | Results, p. 335 |
| adult | II | neuropil surrounding cell islands | moderate | 2 | Discussion, p. 339 |
| adult | IV | barrel septa | relatively pale | 2 | Discussion, p. 339 |

Relative laminar rows (not ranked): limb sensorimotor layer IV granular zones somewhat higher / slightly darker than dysgranular zones (p. 335; Fig. 29 legend); barrel septa lighter than barrels; lateral entorhinal interstices less reactive than the layer II islands. Discussion p. 341: cortical layers III and IV 'particularly high' by both CO and 2-DG (trait `CO_other_intensity`).

**Rat Oc1 (primary visual cortex): no layer-by-layer statement is printed.** The paper ranks Oc1 among the areas with the *highest overall* CO (p. 335) and states the general rule 'layers III–IV darkest in most areas'; the Oc1 row therefore carries `layer = all layers (area-level)` and the general III–IV row carries `cortical_area = cerebral cortex, most areas`. No Oc1-specific laminar ranking exists in this paper.

**Area-level ordinal ranking (pp. 332–335):**

| area (as printed) | state (as read) | rank (1 = highest) | where |
|---|---|---|---|
| hindlimb and forelimb sensorimotor cortex | highest | 1 | Results, p. 335 |
| primary somatosensory cortex | highest | 1 | Results, p. 335 |
| primary visual cortex (monocular and binocular subdivisions) | highest | 1 | Results, p. 335 |
| primary auditory cortex | highest | 1 | Results, p. 335 |
| retrosplenial cortex | relatively dark | 2 | Results, p. 334 |
| piriform cortex (primary olfactory) | moderate | 3 | Results, p. 335 |
| cingulate cortex | moderate | 3 | Results, p. 334 |
| hippocampal formation (HC, PaS, PrS, S, CA1, CA3, DG) | moderate | 3 | Results, p. 334 |
| parietal cortex area 2 | relatively low | 4 | Results, p. 334 |
| occipital cortex area 2 | relatively low | 4 | Results, p. 334 |
| temporal cortex area 3 | relatively low | 4 | Results, p. 334 |

## Species names

Rows use the existing key label `Sprague-Dawley rat` → *Rattus norvegicus* (histochemistry animals: 7 adult male Sprague-Dawley rats, 300–400 g; EXPERIMENTAL PROCEDURES p. 314, rowed in `Hevner_etal_1995_Text`). `n_individuals = 7`.

## Use

Use the area-level ranking (highest: limb sensorimotor, primary somatosensory, primary visual, primary auditory; relatively dark: retrosplenial; moderate: piriform, cingulate, hippocampal formation; relatively low: parietal area 2, occipital area 2, temporal area 3) as an ordinal companion to the regional densitometry of `Hevner_etal_1995_Figure31` (which quantifies only large regions). For laminar depth profiles in rat cortex this paper gives only 'III–IV darkest' (most areas) and the entorhinal exception.

## Data role

**primary** throughout (the authors' own observations on their own material).

## Unresolved / not captured

- No per-area laminar text exists for Fr1/Fr2, Par1, Te1, Oc1, Oc2, cingulate, retrosplenial, insular or piriform cortex, nor for hippocampal strata; a rat laminar CO profile must come from another source.
- 'relatively low ... compared to other cortical areas' and 'relatively dark' are coded 2 and 6 respectively on the same 1–7 scale as laminar adjectives; the area-level rank uses only area-level rows, so the two scales never mix within one ranking group.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside the cited pages, read a sample of rows against the sentences, confirm the adjective coding, and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.
