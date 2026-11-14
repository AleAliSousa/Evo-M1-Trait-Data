# `_keys` — shared identities, definitions, and comparison rules

`_keys` supports compilation and use of the project data. **The main reference for using compiled data is the shared set of species identities, anatomical concepts, variable definitions, and comparison/provenance rules.** Species source-label mappings form one logical table: filter its `collection` column to see a team's rows. The current author-named folders store parts of that table for compilation convenience; they are not separate authorities or the main way to browse the finished data.

## Start here when using compiled data

| Question | Shared reference |
| --- | --- |
| Which organism does this row represent? | `species_reference.csv` (`accepted_name` is the project identity anchor); `SPECIES_NAMING.md` explains resolution and taxonomic qualifications. |
| What brain structure or other variable was measured? | `anatomy_reference.csv`, `variable_definitions.csv`, `variable_catalog.csv`, and `glossary.csv`. Read the definition and unit, not just the column name. |
| Do differently named regions or measures represent the same thing? | `anatomy_crosswalk.csv`, `structure_boundary_basis.csv`, and the source-specific definitions. A shared name or ontology link alone does not establish equivalent boundaries. |
| May observations be combined, or do papers repeat the same data? | `source_relationships.csv`, `trait_authority.csv`, the applicable method/pooling rules, and specimen records in `specimen_crosswalk/`. |

The compiled `__merging_*/` products carry the values and their source fields. The references here explain their identities and meanings; no single key replaces the source's methods or specimen provenance. Files such as `variable_definitions.csv` are built from paper-local `reference_tables/*_definitions.csv` and other project inputs; correct those inputs or the builder when a generated row is wrong.

## During compilation: source-label keys

A source table preserves the paper's printed name or column. The species resolver reads all `_keys/*/species_key.csv` files, combines their rows in memory, and uses `(source_publication, variant_name)` to map printed names to `accepted_name` in `species_reference.csv`. Because these files share a schema and include `collection`, they could also be stored as one CSV without changing the logical mapping: filtering `collection` would recover the team view. `General` is the collection value for papers without a named collection assignment. See `SPECIES_NAMING.md`.

**Team-specific terminology is a special case.** Where a collection repeatedly uses its own structure codes or column conventions, filtering the mapping to that team saves repeated translation work. For example, Stephan-associated volume papers reuse and change structure codes; Herculano-Houzel-associated tables have recurring structure/measure labels. `Stephan/anatomy_key.csv`, `HerculanoHouzel/anatomy_key.csv`, and `Allman/anatomy_key.csv` currently store these mappings separately. They could form one filterable anatomy table once their differing schemas are aligned. They do not define the project's general neuroanatomy or prove that same-named measurements across papers have identical boundaries.

A paper does not need a new team folder merely because it has a new author. Add source-specific definitions, context, and evidence in that paper's `reference_tables/`; add active species rows to the mapping with the applicable `collection` value, and add an anatomy mapping when the source label needs translation. The current storage layout requires placing those rows in the corresponding collection file. Paper-local `*species_key_proposed.csv` files are proposals until reviewed and promoted to an active key.

## Cross-paper interpretation

`anatomy_crosswalk.csv` links concepts across data domains; `structure_boundary_basis.csv` records source-specific boundaries. `variable_definitions.csv` separates structure, measure, unit, and definition where available. `source_relationships.csv` records reprints, extensions, supersession, and independent remeasurements. These are the layers to use when comparing compiled values across publications. Draft or unreviewed links should not be treated as pooling instructions.

## Wild/domestic pooling keys (added 2026-10-20, read-time only)

- **`species_pooling.csv`** — wild/domestic label pairs (`Sus scrofa` / `Sus scrofa domesticus`,
  `Mustela putorius` / `Mustela putorius furo`), with basis and authority. Consumed by the app's
  `cohort_species(ch, pooling =)` and the Cytosplore builder's fourth argument; no merge reads it.
  `README_species_pooling.md`.
- **`population_status.csv`** — per (source token, label): wild / domestic / mixed / unknown, with the
  evidence from the source row. Drives the `domestic_evidence` mode. Seeded by
  `build_population_status.py`; hand edits survive a re-run. `README_population_status.md`.

## Cross-domain structure references (added 2026-10-07, all rows `drafted`)

Started for the Finder's Coverage tab (`__Finder/README.md`); usable by any merge.

- **`anatomy_crosswalk.csv`** — one row per concept × domain × term (domains: `volumes`, `cellcounts`,
  `cortical_areas`, `CMR`, `GLI`, `cortical_layers`). `relation` says how the term relates to the concept
  (`same`, `contains`, `part_of`, `overlaps`, …); `link_class` is `direct` or `proxy`; `boundary_basis`
  names how the term's boundary was drawn.
  **2026-10-31:** 47 rows added (domain `weights` introduced; new concepts `Olfactory_bulb`,
  `Medulla_oblongata`, `Mesencephalon`, `Pons`, `Tectum`, `Tegmentum`, `Striatum`, `Diencephalon`,
  `Telencephalon`, `Spinal_cord`, `Rest_of_brain`, `Olfactory_cortex`, `Corpus_callosum`, `Mammillary_body`)
  so that TraitExplorer's Region Comparison can pair cell counts, brain-part weights, volumes and CMR
  on the same structure. All `status = drafted`; proxy rows (`CerebralCortex` -> Neocortex,
  `Palaeocortex` -> Olfactory_cortex, `DiencephalonStriatum` -> Diencephalon) need an owner check.
  Pre-change copy: `specimen_crosswalk/audit/anatomy_crosswalk_backup_2026-10-31.csv`.
- **`structure_boundary_basis.csv`** — one row per paper × column, in the pattern of `brain_size_basis.csv`:
  dimension (2D surface / 3D volume / rate / index), boundary basis, source role, and what must never be
  pooled with it. Separates the four Smaers products (2017 Brodmann surfaces; 2017 compiled volumes;
  2011 whole-lobe volumes; 2011/2017 section-block prefrontal and frontal-motor volumes).
- **`coverage_targets.csv`** — named acquisition targets (`planned`) and unsourced gaps (`wanted`).

## Cell-count methods (added 2026-11-04)

- **`cell_count_methods/`** — how each cell number, density and ratio was counted (`methods.csv`); each
  source's method, target merge, treatment and flag (`source_methods.csv`); when methods may be combined
  in the opt-in pooled product (`pooling_rules.csv`); and the log through which experts propose changes
  (`expert_reviews.csv`). Read by both cell-count merges; checked by `_checks/check_cell_count_methods.R`.
  Summary and update procedure in its `README.md`.

## Historical origins

Some shared references began with Stephan volume keys and isotropic-fractionator cell-count mappings. They now serve a wider set of papers and data domains; their current scope should be read from the tables and build scripts rather than inferred from those origins.

## NCBI reconciliation and temporal grade (2026-10-22)

The shared species reference and source-label keys carry reconciled taxids. `taxon_name` and `temporal_grade`
are separate identity attributes, returned by the R and Python species resolvers
along with NCBI name, rank, and mapping basis. Early and archaic H. sapiens
retain their project concept anchors while carrying 9606; the archaic mapping
is explicitly a published source hypothesis. Grade and specimen evidence
control aggregation, not taxid alone. See `SPECIES_NAMING.md` for the contract.

`python3 _keys/sync_ncbi_taxids.py` checks consistency against the checked-in
NCBI snapshot; `--apply` reconciles keys and records changed taxids. The
snapshot includes source URLs and the checked date. `species_grade_key.csv`
contains paper-specific grade annotations, with specimen evidence taking
precedence. `test_taxon_attributes.py` checks grade preservation, redirects,
rank corrections, R/Python agreement, and fossil merge annotations.
