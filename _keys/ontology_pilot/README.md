# Ontology mapping pilot (draft; integrated as merge QA)

This pilot tests external concept links for four anatomy terms and four behavioural variables already in `_keys`. It does not replace paper labels, `anatomy_crosswalk.csv`, or `variable_definitions.csv`. A linked ontology class describes a **region or behaviour**, not the paper's measured quantity or method. In particular, a behaviour process ID does not mean that a source's duration, time budget, or report count is an equivalent ontology trait.

`concept_links.csv` is one row per proposed external link. `project_label` is an exact label from `anatomy_reference.csv` or `variable_definitions.csv`; `source_path` identifies that file. `relation` describes the source concept relative to the ontology class. `candidate` means an ID and label were checked, but source boundaries or variable semantics still need curator review. `unresolved` means no ID has been assigned. Neither status licenses automated pooling.

For comparative anatomy, use Uberon as a cross-species reference, then add Allen Human Brain Atlas or NMOBR IDs only after checking the actual boundary. NMOBR's BioPortal submission is beta and dates to 2019. For behaviour, NBO or GO can identify a process; VT would identify a trait if a suitable *specific* class is verified. Leave an ID empty instead of attaching the generic `VT:0000001` vertebrate-trait root.

Before promotion, verify every class in a pinned ontology release, inspect the paper's boundary or operational definition, record the reviewer and date, and test that no unresolved/overlapping link is treated as an exact match. This CSV is deliberately outside the active resolver paths.

## Paper-variable comparison pilot

`paper_variable_crosswalk.csv` has one row per selected paper variable (17 rows). Its `comparison_group` is a proposed target measurement family, not an assertion that values can be pooled. `comparison_decision` is explicit:

The crosswalk separates `paper`, `source_item`, `raw_variable`, `anatomy` or `behavior`, `measure`, and `unit`. `standardized_variable` preserves the existing catalog/key label for traceability; it is not the field to parse for components. The HH rows take structure and measure from `_keys/HerculanoHouzel/anatomy_key.csv`, which already separates them; behavioural rows take their units and definition paths from `_keys/variable_definitions.csv`. The same raw behaviour code (`Activity_pct`) can mean feeding, resting, or traveling, so `source_item` plus the standardized variable and source definition remain necessary to identify a row.

- `directly_comparable`: matching quantity, boundary/denominator, and unit; specimen independence still needs a separate check.
- `convertible`: a documented deterministic conversion makes the measurements comparable.
- `related_only`: shared topic or candidate measurement family, with a material definition, boundary, or provenance check outstanding.
- `incompatible`: different quantity, boundary, denominator, or scale prevents comparison with that group as recorded.

All current rows are `related_only` or `incompatible` because this pilot uses key/definition tables, not a full inspection of every paper and specimen relationship. `independence_status` is separate because matching measurements can repeat the same observations.

### Links to current rules and merge QA

`poolable_group_ref` copies an existing group from `variable_definitions.csv` when one exists. `boundary_rule_ref` is a `concept|domain|term` key into `anatomy_crosswalk.csv`; those rows are drafts and often say `per_source`, so they do not settle a paper's boundary. `method_rule_ref` is an `item_name` in `cell_count_methods/source_methods.csv`. `source_relationship_refs` contains semicolon-separated `pair_id` values from `source_relationships.csv`. Blank means no applicable record was verified for this pilot row; it does not imply that no rule is needed.

`merge_variable` is the actual compiled label when identified. `_checks/check_ontology_pilot.py` validates every populated link and writes `merge_alignment.csv`, counting matching rows in the current IF, volume contribution, behaviour, and sleep outputs. The four corresponding compilers run this check after writing their outputs. It is a **QA integration**: it makes the pilot auditable during compilation but does not change inclusion, priority, averaging, or pooling. Counts across outputs are sightings, not independent observations; the same source may appear in both IF and volume products. Behavior and sleep counts are variable-level because their merged long outputs do not retain paper-level source rows. A zero count can mean an unused source, a different compiled label, or a missing integration and needs investigation before promotion.

### Add feedback

You do not need to fill every row to use the pilot. Agreement with the column layout needs no entry. Use feedback only for a specific correction, missing boundary, source overlap, or a decision you want changed. Blank feedback does **not** mean the scientific mapping has been reviewed or approved.

Open `feedback.csv` in Excel, Numbers, or a text editor. Find a row by `mapping_id` (for example, `B008`); the paper, raw variable, anatomy/behavior, measure, unit, and current decision are shown beside it. Fill `feedback` in plain language; add a proposed value in `suggested_decision` only if you want to change it. Put a paper page, local note path, or URL in `evidence_path_or_url`, then your name/initials and date. Save as UTF-8 CSV. **Leave the IDs and header unchanged.** Empty rows are intentional: they make it easy to comment on any mapping without editing the draft crosswalk.

Examples of useful feedback: "Figure 4 denominator is social activity; keep incompatible"; "Table S1 explicitly excludes peduncles; compare against A001 boundary"; "These two tables reuse the same individuals." Feedback is a proposal until reviewed and applied to the crosswalk. Keep this separate file when regenerating or extending the pilot so comments survive.

Sources consulted: [Uberon](https://obofoundry.org/ontology/uberon), [AmiGO terms](https://amigo.geneontology.org/amigo/term/UBERON:0002037), [Allen Human Brain Atlas API](https://community.brain-map.org/t/atlas-drawing-and-ontologies/2864), [NMOBR](https://bioportal.bioontology.org/ontologies/NMOBR), [VT](https://bioportal.bioontology.org/ontologies/VT), [NBO](https://obofoundry.org/ontology/nbo.html).
