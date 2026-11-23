# Candidate links: project structures -> Uberon (notes for the reviewer)

Mapped on 2026-11-23. Status of every row: `candidate`. Nothing was written to the database folder.

## What was mapped

- Slice: every distinct `canonical_structure` in `_keys/variable_domain.csv` = **224 terms**. `_keys/variable_definitions.csv:Structure` holds the same 224 values, so there were **0** extra `Structure` values to add.
- Vocabulary: Uberon only, looked up through the EBI OLS4 API. Uberon release as reported by OLS: `2026-11-05 (OLS versionIri http://purl.obolibrary.org/obo/uberon/releases/2026-11-05/uberon.owl; OLS loaded 2026-11-23)` (the OLS `version` field itself is empty; the date is taken from `versionIri`).
- Output: **313 rows** for 224 terms; 66 terms have more than one row (maximum 4); 181 distinct Uberon ids.
- 223 terms have at least one Uberon link; 1 term (`pooled_multiregion`) is deliberately `none`.
- `relation` reads as *the Uberon class relative to the project term*: `broad` = the Uberon class is broader than ours, `narrow` = it is narrower (used for the components of composite blocks such as `DiencephalonStriatum`).

### Rows by relation and confidence

| relation | high | medium | low | all rows |
|---|---|---|---|---|
| exact | 52 | 61 | 0 | 113 |
| close | 12 | 61 | 12 | 85 |
| broad | 31 | 19 | 3 | 53 |
| narrow | 7 | 33 | 8 | 48 |
| related | 0 | 3 | 10 | 13 |
| none | 1 | 0 | 0 | 1 |
| **total** | 103 | 177 | 33 | 313 |

### Best relation per term (224 terms)

exact: 113 · close: 71 · broad: 23 · narrow: 15 · related: 1 · none: 1

So 113 terms have an `exact` candidate, 71 have `close` as their best, and 39 are reachable only through a broader class, components, or a related class.

## How the rows were made

1. The project side was read first: `variable_definitions.csv` definitions, `glossary.csv`, `anatomy_reference.csv`, `anatomy_crosswalk.csv`, `Stephan/anatomy_key.csv` (code arithmetic such as 22 = 23 + 24), `variable_catalog.csv` definitions and source papers, `__merging_cell_morphology/region_crosswalk.csv`, `__merging_volumes/volumes_definitions.csv`, and the pilot `ontology_pilot/concept_links.csv`.
2. 290 OLS searches were run (`ontology=uberon`); raw responses are in `ols_cache/search/`. Each chosen id was then re-fetched by id (`ols_cache/terms/`), and the label in the table is the one OLS returned for that id. Uberon text definitions and synonyms were read before choosing.
3. The choice, relation, confidence and reason are **curated judgements** written in the `DECISIONS` block of the script. They are not computed. The script adds the mechanical parts (counts, example label, qualifier summary, labels, version) and refuses to write an id that no cached search returned, that fails the by-id fetch, or that is obsolete.
4. Automatic rows: 21 rows ("Qualifier row: ...") were added by rule for terms whose labels all sit in one cortical layer (cortical layer III: 15, cortical layer V: 6). They were not individually judged.

Checks run: all 224 terms have a row; `n_labels` equals the label count in `variable_definitions.csv` for every term; every example label exists; all 181 ids were re-fetched live from OLS a second time and label and non-obsolete status matched; a deliberately wrong id was refused by the script. The script was also run once in an empty folder (no cache, every search and term fetched again from OLS): the table it wrote was byte-identical to the delivered one.

## The ten least certain choices

1. `Area13` -> UBERON:0004167 *orbitofrontal cortex* (broad, medium). Uberon's "Brodmann (1909) area 13" (UBERON:0013544) was **rejected** as a homonym: Uberon puts Brodmann areas 13-16 in the insula, while the Semendeferi 1998 area 13 is orbitofrontal. That the source's area 13 is orbitofrontal comes from the paper, not from the keys.
2. `PFC_area12` -> UBERON:0004167 *orbitofrontal cortex* (broad, medium) and `PFC_area12` -> UBERON:0013543 *Brodmann (1909) area 12* (related, low). Same numbering problem: the region crosswalk calls it "orbitofrontal area 12", Uberon's BA12 is Brodmann's frontopolar guenon area. `PFC_area11` (`PFC_area11` -> UBERON:0013528 *Brodmann (1909) area 11* (close, medium)) has the same weakness to a lesser degree.
3. `FI` -> UBERON:0034893 *agranular insular cortex* (broad, low) (and the same for `fronto_insular_cortex`). Uberon has no frontoinsular class; "agranular insular cortex" as the parent rests on general knowledge and part of FI may lie outside the insula.
4. `Schizo_cortex` -> UBERON:0014736 *periallocortex* (close, low). The keys give only the name; that the Stephan schizocortex is the entorhinal/perirhinal/presubicular belt is general knowledge to be confirmed.
5. `Subthalamus` -> UBERON:0001900 *ventral thalamus* (related, low). The Stephan "subthalamus" is pallidum + subthalamic nucleus (codes 22 = 23 + 24), which is not what Uberon's class with the synonym "subthalamus" means; the two component rows are the safer links.
6. `Medulla_oblongata` -> UBERON:0000988 *pons* (narrow, low). That the Stephan "medulla oblongata" volume contains the pons is **inferred** from the five-part code arithmetic (net brain = codes 6-10), not stated anywhere in the keys.
7. `Thalamus` -> UBERON:0001897 *dorsal plus ventral thalamus* (close, medium) versus `Thalamus` -> UBERON:0004703 *dorsal thalamus* (close, low). Uberon's "thalamus" class includes the epithalamus; the Stephan thalamus does not. Which class fits depends on the source.
8. `HP_HS_fibers` -> UBERON:0002603 *paraterminal gyrus* (narrow, low), `HP_HS_fibers` -> UBERON:0002665 *supracallosal gyrus* (narrow, low). Chosen on Uberon synonyms ("precommissural hippocampus", "supracommissural hippocampus"); one of the two classes has no text definition.
9. `HippocampoAmygdaloidTransitionArea` -> UBERON:0035026 *amygdalohippocampal transition area* (close, low). Uberon has two similar classes and the name-matching one has no definition.
10. `Thalamus_medial_nucleus` -> UBERON:0002739 *medial dorsal nucleus of thalamus* (close, low). "Nucleus medial thalami" (Heiss 2004 PET ROI) could be the mediodorsal nucleus or the medial nuclear group.

Other low-confidence terms (27 terms carry at least one low-confidence row): `ACC_subgenual`, `Amygdala superficial`, `Area_striata_laminae_2_6`, `Basal_forebrain`, `CerebralCortexNoHippocampus`, `Cerebrum`, `Complexus_centromedialis`, `FI`, `HP_HS_fibers`, `HippocampoAmygdaloidTransitionArea`, `Medulla_oblongata`, `MesencephalonMedulla`, `Nonolfactory_allocortex`, `PFC_area12`, `PrefrontalCortex`, `Schizo_cortex`, `SubcorticalForebrain`, `Subthalamus`, `Thalamus`, `Thalamus_medial_nucleus`, `White_matter`, `cortex_corticospinal_field`, `eye/visual system`, `fronto_insular_cortex`, `spinal cord / M1 output`, `temporal_TE`, `thal_MGN_parvocellular`.

## What a reviewer should look at first

1. **Canonical spellings that name the same concept twice.** They received the same Uberon id and may deserve merging in the keys: `Cingulate cortex`/`Cingulate_cortex`; `Frontal cortex`/`Frontal_cortex` (plus `FrontalCortex`, `FrontalGrey`, `frontal`); `Occipital cortex`/`Occipital_cortex`; `Temporal cortex`/`Temporal_cortex`; `Flocculonodular lobe`/`FlocculonodularLobe`; `CerebellarCortex`/`Cerebellar_cortex`; `CerebellarVermis`/`Vermis`; `VisualCortex`/`Visual_cortex`; `Medulla`/`Medulla_oblongata`; `OlfactoryBulb`/`Bulbus_olfactorius`; `FI`/`fronto_insular_cortex`; `Lateral_cerebellar_nuclei`/`Nucleus_dentatus_cerebelli`; `PrefrontalCortex`/`Prefrontal_cortex`/`PFC`. Several of these pairs are not equivalent in boundary (for example `Medulla_oblongata` holds a Stephan volume that probably includes the pons), which is why relation or confidence can differ within a pair.
2. **Stephan-school compartments.** `Diencephalon` (contains the pallidum), `Telencephalon`, `Medulla_oblongata`, `Subthalamus`, `Palaeocortex`, `Lobus_piriformis`, `Allocortex`, `Olfactory_allocortex`, `Nonolfactory_allocortex`, `Schizo_cortex`, `Hippocampus`. The reasons rest on the code list in `_keys/Stephan/anatomy_key.csv` plus general knowledge of the scheme; **no source paper was opened**. Each should be checked against the paper's own boundary text.
3. **The 61 `exact` rows at medium confidence.** `exact` was given when the project term names the same anatomical entity and no boundary difference is known; for pooled terms (`Cerebellum`, `Amygdala`, `Hypothalamus`, CMR ROIs, tissue-sample sites) the boundary is per source and was not verified. A stricter reviewer may want these as `close`.
4. **Statements marked in the reason as coming from the source paper or general knowledge** ("per the source paper", "general knowledge", "inferred", "probably", "assumed"). These are the places where the keys were silent.
5. **Terms that are not anatomical structures.** `pooled_multiregion` (none), `spinal cord / M1 output` (related only), `eye/visual system`, `Body`, `Total_brain_volume`, `Total_brain_net_volume` (volume definitions rather than structures), and the fossil endocast terms (`OccipitalLobe`, `ParietoTemporalLobe`, `OccipitoParietoTemporalCortex`, three labels of `FrontalLobe`), where the label measures an endocast surface, not tissue.
6. **Pairs where Uberon itself has two near-equivalent classes** and both are listed for the reviewer to pick: insula / insular cortex; tegmentum / midbrain tegmentum; prepyriform area / piriform cortex; "dorsal plus ventral thalamus" / dorsal thalamus; globus pallidus / pallidum; primary visual cortex / Brodmann area 17; primary motor cortex / Brodmann area 4; amygdalohippocampal transition area / amygdalohippocampal area.
7. **Concepts for which OLS returned no Uberon class** (so only a broader class or components are linked): area MT, frontoinsular area FI, dysgranular insular cortex, area 3b, area 7a, area TE, anterior insula, sensorimotor cortex, piriform lobe, centromedial amygdala, parvocellular medial geniculate, both accessory olives together, layers II-VI as a unit, "rest of brain". "Not found" means not found by the searches listed in the script, not proof of absence.
8. **The 21 automatic layer rows.** Correct by construction only if `structure_qualifier` is correct.

## Limits

- Only Uberon was consulted. No Allen, NeuroNames/NMOBR or FMA links.
- Label-level qualifiers (layer, hemisphere, grey/white) are summarised in `reason`; the distinct `structure_qualifier` values were not mapped as terms of their own, and the 80 source-level `Structure` spellings in `variable_domain.csv` that differ from their canonical term were not given separate rows.
- Uberon part-of relations were checked for one case only (accessory olfactory bulb is part of olfactory bulb). "The Uberon class does/does not include X" otherwise rests on the Uberon text definition.
- Uberon definitions are often loose or absent (noted per row where absent); an `exact` to a class without a definition rests on label and synonyms.
- The mapping is one curator pass; nothing here licenses pooling of variables.

## Files

- `vocabulary_links_structures.csv` - the table.
- `build_vocabulary_links_structures.py` - reads the keys (read-only), queries or reuses `ols_cache/`, writes the table. With the cache present it runs offline.
- `ols_cache_structures.tar.gz` - raw OLS responses (290 searches, by-id term fetches, ontology metadata, `id_provenance.csv` listing for each id the search that returned it).
