# Vocabulary links: units and kinds of measurement (CANDIDATE, for owner review)

Mapped on 2026-11-23. Every row has `mapping_status = candidate`; nothing in the project folder was changed.

## What was mapped
- **Units**: all 84 distinct `Unit` strings of `_keys/variable_definitions.csv` -> Units of Measurement Ontology (UO 2026-10-12).
- **Measure classes**: all 34 distinct `measure_class` values -> PATO (2026-10-01) and, where a ready-made trait exists, OBA (2026-10-10).
  The task brief expected about 36 classes; the file has 34.
- **Measure codes**: all 82 glossary terms of kind `measure_code` / `measure code` -> PATO and OBA. Codes that are not a kind of quantity
  (`n`, `S.n`, `SD`, `Source`) are kept with relation `none`.

| term_kind | terms_in_slice | terms_with_a_link | terms_none_only | rows |
|---|---|---|---|---|
| measure_class | 34 | 26 | 8 | 59 |
| measure_code | 82 | 78 | 4 | 105 |
| unit | 84 | 75 | 9 | 132 |

Units in detail: 56 have a single UO term (exact / close / broad), 19 are compound or transformed units linked only through
component or related UO terms, 9 are not units (ordinal, categorical, binary, text) and have relation `none`.

Rows by relation: {'broad': 95, 'related': 92, 'close': 39, 'exact': 36, 'none': 24, 'narrow': 10}

Rows by confidence: {'high': 188, 'medium': 81, 'low': 27}

Rows by ontology: {'UO': 132, 'PATO': 117, 'OBA': 47}

Relation x term kind:

| term_kind | broad | close | exact | narrow | none | related |
|---|---|---|---|---|---|---|
| measure_class | 18 | 12 | 0 | 10 | 11 | 8 |
| measure_code | 56 | 24 | 2 | 0 | 4 | 19 |
| unit | 21 | 3 | 34 | 0 | 9 | 65 |

## Conventions used
- `broad` = the ontology term is broader than the project term; `narrow` = the ontology term covers only part of the project term.
- **Compound units** with no single UO term (for example `umol/100g/min`) get one `related` row per component UO term; the reason starts with
  `COMPOUND UNIT` and gives the full expression and the role of the component. 60 rows are component rows;
  their confidence describes the identity of the component, not a match to the whole unit.
- **PATO supplies only the quality** (volume, mass, has number of ...), never the bearer. A code that fixes what is measured (`N.n` = neurons) is
  therefore `broad` to PATO; a code that is a bare quantity plus unit (`Vol.mm3`) is `close`; only unit-free `Mass` and `ratio` are `exact`.
- `measure_class` has no written definition in the project (it is assigned by rule in `_keys/build_variable_catalog.R` and reused from the merges),
  so each class was read from its member labels, units and definitions. Topic classes (diet, ecology, sociality ...) are not kinds of quantity.
- `n_labels` for a measure code = labels whose `glossary_terms` list the code or whose `Measure` / label equals or ends with `_<code>`; it is an
  approximate usage count (0 means the code occurs only in the glossary / anatomy keys).
- UO and PATO were read in full from OLS (every term); OBA (83,548 terms) was searched with 347 queries, so an OBA
  term with unexpected wording can have been missed. "No OBA term found" means not found by those searches.

## Ten least certain choices
| term_kind | project_term | ontology_id | ontology_label | relation | confidence | reason |
|---|---|---|---|---|---|---|
| unit | mm3 | UO:0000101 | microliter | exact | medium | UO has no 'cubic millimeter' term. Microliter is the same unit by definition (1 L = 1 dm3, so 1 mm3 = 1 uL; the glossary states this too); only the name differs. Marked exact on magnitude; reviewer to confirm that an identically sized, differently named unit is acceptable. |
| unit | µg/g | UO:0000169 | parts per million | close | medium | ug per g is a mass fraction of 1e-6; UO parts per million is a dimensionless notation that holds when both amounts use the same measure (here mass, w/w). Ours keeps the mass units explicit and specifies wet tissue. UO 'milligram per kilogram' is numerically equal but is defined as a dose per body weight, so it was not used. |
| unit | ratio | UO:0010006 | ratio | exact | medium | Glossary: 'dimensionless ratio of two measured quantities'. UO 'ratio' gives one quantity as a multiple of another. UO also has the parent class 'ratio unit' (next row); reviewer to choose one. |
| unit | index | UO:0000186 | dimensionless unit | broad | low | Heterogeneous source-defined indices (locomotor diversity, network centralisation, adjusted Rand index, pollical/workspace indices). Only the generic dimensionless unit applies; some members are counts or ratios in substance. |
| measure_code | N.p.mg | PATO:0000070 | amount | related | low | Ours is a numerical density (neurons per mg tissue). PATO has no count-per-unit quality: its density terms are defined on mass. Only the counted quantity (amount) is linked; the normalisation is lost. |
| measure_class | cellular_composition | PATO:0000025 | composition | close | medium | PATO composition: 'quantities or relative ratios of subparts'. Ours = cell numbers, cell densities, cell-type percentages and ratios within a brain structure, plus 23 categorical labels and a few per-area / per-length densities (mitochondria, synapses, interlaminar astrocytes). |
| measure_class | sensory performance | PATO:0000152 | threshold | close | medium | PATO threshold: value at which a change is observed / limit. Most members are perceptual thresholds or limits (taste thresholds in mM, hearing frequency limits, visual acuity, flicker fusion, minimum audible angle); a few are derived ranges/ratios. |
| measure_class | activity & movement | PATO:0000186 | behavioral quality | broad | low | Topic class in the project's behaviour domain (activity pattern, time budgets, gait, locomotor mode). PATO offers only this generic parent; the measured quantities (counts, shares of time, categories) are not captured. |
| measure_code | soma_depth | PATO:0000040 | distance | close | medium | PATO distance: extent of space between two entities (soma and pial surface). PATO 'depth' was not used: it is the bearer's own inward dimension, not its position below a surface. |
| measure_code | basal_dendritic_field_area | PATO:0070064 | dendritic field size | close | medium | PATO dendritic field size is a 3-D extent (region spanned by the dendritic arbor). Ours is the 2-D polygon area of the BASAL arbor in the tangential plane. |

The same doubt applies to the sibling rows: `um3` -> femtoliter and `cells/mm3` -> cells per microliter (as `mm3`); `mg/g` -> parts per thousand
(as `µg/g`); all nine density codes (as `N.p.mg`); the three other behaviour topic classes mapped to PATO behavioral quality.

## What a reviewer should look at first
1. `mm3` -> UO:0000101 microliter (187 labels, the most used unit). UO has no cubic millimeter; decide whether the equal-sized
   microliter is acceptable as `exact`, or whether the link should be downgraded and a UO term requested.
2. The 24 `none` rows: confirm that ordinal / categorical / text unit strings and metadata classes should stay unmapped
   rather than go to another vocabulary (for example a statistics ontology for `SD`).
3. Cell and spine **density** codes (`N.p.mg`, `O.p.mg`, `I.p.mg`, `C.p.g`, `N.p.g`, `O.p.g`, `spine_density`, `max_spine_density`,
   `ila_linear_density`): PATO has no count-per-mass/volume/length quality. These are linked only to `amount` (related, low).
4. Measure classes with `close` links where the class is wider than the term: `brain_size` (endocranial volume is a proxy),
   `cerebral_perfusion` (foramen / lumen dimensions), `cellular_composition`, `sensory performance`.
5. The unit string `umol/min or ratio` mixes two quantities and `um x 1e5` / `as printed` / `mm3 as printed` carry unresolved units; these are
   data-dictionary issues to fix upstream rather than mapping questions. See `units_variants.csv` for all spelling variants.
6. `months` and `years`: UO fixes them at 30 and 365.25 days; check against the conversions used in the life-history merge.

## Files
- `vocabulary_links_units_measures.csv` (296 rows), `units_variants.csv` (37 rows in 15 groups),
  `build_vocabulary_links_units_measures.py` + `ols_client.py`, `ols_cache.tar.gz` (raw OLS responses and `cache_index.csv`).
