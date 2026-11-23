# Candidate vocabulary links: behaviour and sensory slice

Mapped on 2026-11-23. Every row has `mapping_status = candidate`; nothing here is approved and nothing was written to the database folder.

## Files

- [vocabulary_links_behaviour_sensory.csv]({{artifact:c89ea977-69b6-4551-8755-3b9b547e74ac}}): the table, 336 rows, one per project term x ontology term.
- [vocabulary_links_behaviour_sensory_label_map.csv]({{artifact:6079ceb6-f14c-4056-b2e6-6ca2a146ca73}}): all 308 variable labels with the project term each collapses onto.
- [build_vocabulary_links_behaviour_sensory.py]({{artifact:de8b41c5-dff9-4ddc-8ee7-82c17e67155b}}) with [ols_cache.py]({{artifact:18817456-1ad2-47c9-aa89-30acd7543313}}): the script that produces both tables. It holds the mapping decisions, re-fetches every chosen identifier by id and writes the label OLS returns.
- `ols_cache_behaviour_sensory.tar.gz` and `ols_search_log.csv` (saved alongside): the raw OLS responses and a list of every search run. With the archive unpacked next to the script, the script rebuilds the table offline; a clean-room rebuild gave a byte-identical CSV.

## What was mapped

- Slice: 308 labels in `_keys/variable_definitions.csv` with domain `behaviour` (256) or `sensory` (52).
- Project terms: 194 trait terms plus 10 measure classes = 204 terms. Every one has at least one row.
- 127 trait terms and all 10 measure classes have at least one ontology link. 67 trait terms (108 labels) have no adequate term and carry a single `none` row.
- 100 distinct ontology terms are used. Versions as reported by OLS: GO 2026-07-26, NBO 2023-07-04, OBA 2026-10-10, UBERON 2026-11-05, VT 2026-11-06. OLS gives no version string for Uberon, so its release date is taken from the versionIri OLS returns.
- All 100 identifiers were also re-fetched live (not from cache) after the build; ids, labels and home ontology matched and none is obsolete.

### How labels were collapsed into project terms

A project term is the `Measure` value with the `_AuthorYear` source token removed, and with replicate qualifiers removed: month of a digitised monthly reading, named study animal, mirror-test phase (Covered / Marked / Uncovered), experimental group (control / trained / experimental / naive controls), age class of the Bartlett play share, delay condition of the short-term memory score, citric-acid concentration of the sucrose mixture test, and the `_compiled` / `_digitized` provenance tags. The 22 Gautier call-type presence characters collapse onto one term, `Vocal_character`. Stems that differ in wording were NOT merged even where they mean the same thing (for example `Activity_pattern`, `Activity_period`, `Activity_cycle`, `ActivityTiming`; `Sleep` and `TotalSleepTime.h`; `Social_group_size` and `SocialGroupSize.count`); such stems carry identical links, so they can be merged later without redoing the mapping. The rule is the `project_term()` function in the script, and the label map shows the result label by label.

### How relations were used

- `exact` was not used. Every project term in this slice is a measurement (a duration, share, count, score, threshold or category), while NBO and GO offer the behaviour or process and VT and OBA offer mostly general trait classes.
- `close`: the ontology term is a trait of the same kind as ours and differs only in a stated boundary (for example daily total versus one episode).
- `broad`: a VT or OBA trait class of which ours is one specific measure.
- `narrow`: the ontology term covers one category value of ours, or one part of a measure class.
- `related`: ours is a measurement of the behaviour, process or structure named by the ontology term, or a quantity derived from it. This is the same idea as the pilot's `measures_time_in` and `measures_duration_of`.
- `none`: nothing adequate in the vocabularies searched; the `ontology` column lists which were searched and `evidence_url` is an OLS search that came back without a suitable term.

## Counts

Rows by relation and confidence:

| relation | high | medium | low | total |
|---|---|---|---|---|
| exact | 0 | 0 | 0 | 0 |
| close | 8 | 10 | 1 | 19 |
| broad | 35 | 33 | 22 | 90 |
| narrow | 1 | 8 | 1 | 10 |
| related | 46 | 90 | 14 | 150 |
| none | 58 | 9 | 0 | 67 |
| total | 148 | 150 | 38 | 336 |

Rows by vocabulary: VT 97, NBO 84, GO 54, UBERON 23, OBA 11; `none` rows 67.

Terms by their best relation (closest link each term has): exact 0, close 13, broad 83, narrow 4, related 37, none 67.

Terms with no adequate ontology term, by measure class:

| measure class | terms | labels |
|---|---|---|
| activity & movement | 2 | 3 |
| cognition | 8 | 8 |
| manipulation & skill | 5 | 7 |
| self-recognition (mirror) | 25 | 53 |
| sensory structure | 2 | 2 |
| sociality | 25 | 35 |

## The ten least certain choices

1. `Top_speed` -> OBA:2060017 *locomotory behavior rate* (close, low). 'Rate' of a locomotory behaviour may mean how often it occurs, not speed; ours is a top-speed class.
2. `Sleeping_trees_used` -> VT:0010708 *sheltering behavior trait* (related, low). A count of sleeping sites is at best loosely a sheltering trait; `none` would be equally defensible.
3. `TorporBoutMax.h` -> GO:0042750 *hibernation* (related, low). GO has hibernation but no torpor; daily torpor is not covered. The same weakness applies to `TorporTbMin.C` and to the hibernation link of the sleep & torpor class.
4. `Binocular_field` -> VT:0001299 *eye orientation trait* (related, low). A visual-field quantity linked to an eye-placement trait because no visual-field term exists in the five vocabularies.
5. `L_cone_lambda_max` -> VT:0004022 *cone electrophysiology trait* (broad, low). Spectral peak of a pigment linked to a trait named for electrophysiology; applies to all seven cone terms and, with VT:0004021, the two rod terms. The entity is a cell type and its pigment, which none of the five vocabularies models.
6. `Melanopsin_lambda_max` -> UBERON:0000966 *retina* (related, low). The project definition gives only the unit; the tissue is assumed from general knowledge of melanopsin.
7. `Tannic_acid_inhibition_threshold` -> VT:0001986 *taste sensitivity trait* (broad, low). Tannin astringency is partly tactile, and the project definition does not say what is inhibited.
8. `Manipulation_complexity` -> NBO:0000349 *manual dexterity* (related, low). Complexity of the manipulation repertoire is not dexterity; linked only as related.
9. `Social_network_density` -> VT:0010445 *social interaction trait* (broad, low). Group-level network statistics (six terms) linked to a trait written for individuals.
10. `Mirror_Glance_count` -> NBO:0000314 *visual behavior* (related, low). Glance and Stare counts linked to the very general 'visual behavior'; the ethogram categories are not described in the project.

All 38 low-confidence rows, including those above: `Angular_utilization_index_FL` -> VT:0010731; `Angular_utilization_index_HL` -> VT:0010731; `Binocular_field` -> VT:0001299; `CFF_electrophysiological` -> GO:0050908; `Foot_Posture` -> VT:0004263; `L_cone_lambda_max` -> VT:0004022; `Loud_play_vocalisation` -> NBO:0000037; `Loud_play_vocalisation` -> NBO:0000075; `M_cone_lambda_max` -> VT:0004022; `manipulation & skill` -> NBO:0000339; `Manipulation_complexity` -> NBO:0000349; `Melanopsin_lambda_max` -> UBERON:0000966; `Mirror_Glance_count` -> NBO:0000314; `Mirror_Stare_count` -> NBO:0000314; `Retinal_linear_magnification` -> VT:0002092; `Retinal_pigment_L_cone_peak` -> VT:0004022; `Retinal_pigment_M_cone_peak` -> VT:0004022; `Retinal_pigment_M_L_shared_peak` -> VT:0004022; `Retinal_pigment_Rod_peak` -> VT:0004021; `Retinal_pigment_S_cone_peak` -> VT:0004022; `Rod_lambda_max` -> VT:0004021; `S_cone_lambda_max` -> VT:0004022; `sleep & torpor` -> GO:0042750; `Sleeping_trees_used` -> VT:0010708; `Social_network_centralisation` -> VT:0010445; `Social_network_connections` -> VT:0010445; `Social_network_density` -> VT:0010445; `Social_network_diameter` -> VT:0010445; `Social_network_dyadic_efficiency` -> VT:0010445; `Social_network_global_efficiency` -> VT:0010445; `Tannic_acid_inhibition_threshold` -> GO:0050909; `Tannic_acid_inhibition_threshold` -> VT:0001986; `Top_speed` -> OBA:2060017; `TorporBoutMax.h` -> GO:0042750; `TorporTbMin.C` -> GO:0042750; `Vocal_cluster_ARI` -> VT:0001529; `Vocal_contagion` -> NBO:0000037; `Vocal_contagion` -> VT:0001529.

## What a reviewer should look at first

1. The 67 terms with no link (108 labels), which are concentrated in sociality and mirror self-recognition. NBO, VT, OBA and GO have no term for group size, group composition, sex ratio, social organisation, mirror self-recognition, handedness, tool use, behavioural innovation, resting or daily torpor. The decision needed is whether to bring in vocabularies outside the five named for this slice or to keep project-local concepts. An OLS search across all ontologies showed candidates elsewhere, not mapped here and not in the CSV: PATO has *nocturnal* (PATO:0095006), *crepuscular* (PATO:0095005) and *handedness* (PATO:0002201); EFO has *sex ratio* (EFO:0004820, defined as males per 100 females, which is not either of our two ratios); MeSH has Tool Use Behavior, Torpor and Social Group. The all-ontology searches tried ('mirror self-recognition', 'self-recognition', 'mirror test') returned no term for mirror self-recognition.
2. The 19 `close` rows, which are the nearest to usable equivalences: daily sleep, REM and NREM duration against the OBA and NBO duration terms (daily total versus one episode); behavioural visual acuity; limb posture; dexterity and hand-eye coordination; functional interaural distance (a travel time) against the OBA distance between ears; and the cognition, communication and play classes.
3. The collapse rule and the label map: check that removing conditions, months, animals and call-type numbers is acceptable, and decide whether the synonym stems listed above should be merged.
4. Terms with at least one label whose definition is recorded as `unresolved` in `variable_definitions.csv`, so that the mapping rests partly on the label wording or on the source catalog: `Activity_cycle`, `Behavioural_repertoire_size`, `Binocular_field`, `Foraging_innovation_count`, `Innovator`, `Loud_play_vocalisation`, `Nontechnical_innovation_count`, `Orbit_convergence`, `Retinal_linear_magnification`, `ShortTermMemory_prop_correct`, `Social_group_size`, `Technical_innovation_count`, `Visual_acuity_anatomical`, `Visual_acuity_behavioural`. The mirror ethogram categories, `Mirror_GR` / `Mirror_GU`, the opsin and lambda-max terms and `Tannic_acid_inhibition_threshold` also have definitions too thin to compare boundaries.
5. Variables that look misfiled, which affects the measure-class links: `Neocortex_ratio` (a brain measure under sociality), `Intermembral_index` (a skeletal ratio under activity & movement), and `Extractive_foraging` / `Tool_use` (unit `category`, but defined as report counts).
6. Two recurring judgement calls: grooming time is linked to both *grooming behavior* and *social grooming* because the project does not say whether self-grooming is excluded; slow-wave sleep is linked to the NREM terms although SWS can be narrower than NREM.
7. The `related` rows are mostly 'measurement of the process'. If the owner prefers the pilot's finer relation names, these can be recoded from the `reason` text and the unit without a new lookup.

## Limits

- Vocabularies: NBO, VT, OBA, GO and Uberon only, as specified for this slice. OBA's copies of VT terms (ids of the form OBA:VT...) were not used, to avoid duplicating the VT rows.
- Uberon was used for sensory structures, plus three anatomical-locus links outside them (forelimb, hindlimb, neocortex).
- Search depth: each OLS query was read to the top 10-15 hits; a suitable term ranked lower, or indexed under wording that was not tried, could have been missed. The search log lists every query.
- Project meaning was taken from `variable_definitions.csv`, `glossary.csv`, `sensory_method_basis.csv`, `variable_catalog.csv`, the behaviour and sensory merge READMEs and the source reference tables. The primary papers were not read.
- The script's `--refresh` option (replay every cached OLS URL) was not run end to end; the offline rebuild and the live re-fetch of the chosen identifiers were.
