---
name: reconcile-data-compilations
description: Reconcile two or more secondary data compilations at the underlying primary-source level. Use when merging compilations, comparing values copied from the same studies, preserving per-row primary citations, preventing shared-source double counting, or auditing compilation disagreement. Triggers on "merge compilations", "compare compilations", "primary references", "same source values", "secondary compilation", "dedupe shared studies", "source-aware merge".
---

# Reconcile Data Compilations

Use this workflow when two tables or papers compile measurements from other
studies.  A compilation is provenance, not an independent primary study.  The
authoritative evidence unit is the underlying source work (or a documented
multi-source aggregate when it cannot be decomposed).

Read `_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md`
before changing a public item or merge.  Its snapshot, reference-table, data-role,
and public/private-boundary rules still apply.

## Required data model

Keep these concepts separate throughout the build:

- `compilation_id`: the table or paper that supplied the row.
- `source_reference_id`: a stable identifier for every cited work, including a
  review, book, or chapter when that is all the compilation names.
- `reference_level` and `source_type`: whether the cited work is a primary
  report or a secondary/tertiary synthesis, and what kind of source it is.
- `primary_reference_id`: the underlying experimental work; leave this blank
  when the cited source is secondary and its row-level primary lineage is not
  recoverable.
- `reference_raw`: the citation exactly as the compilation prints it.
- `primary_reference_citation`: the full bibliography entry, preserving each
  compilation's printed form when both contain it.
- `reference_role`: direct reported source, component source, ratio source,
  calibration source, or other explicit lineage role.
- `derivation_role`: direct report, self-primary report, compiler average,
  compiler estimate, derived total, or cross-area summary.
- `source_granularity`: singleton primary source, compound source set, derived
  summary, or unresolved reference.
- `condition_group` plus `condition_evidence`: the harmonized analytical
  condition and whether it comes from a primary row/protocol or only a blanket
  statement by the secondary compiler. Do not upgrade “unanesthetized” to
  “awake” without evidence.
- `study_arm_id` when recoverable, otherwise an explicit `arm_identity_status`
  and ambiguity-group ID. A shared paper and broad condition do not prove that
  control, treatment, disease, task, age, or temperature rows are exchangeable.
- Raw value/unit and standardized value/unit must coexist.
- Preserve a source-row locator and the printed numeric lexemes separately from
  parsed numbers, so trailing zeros and source precision survive serialization.

Use a relational value-to-reference link table as the authoritative many-to-many
representation.  Semicolon-joined IDs/citations in a merged CSV are convenience
fields, not a substitute for the link table.

## Workflow

1. Inventory every source row and classify the compilation itself as primary,
   secondary, or mixed.
2. Build an item-scoped `reference_tables/<Item>_references.csv` from only the
   works cited by data rows.  Its first four columns follow the house contract:
   `ref_key,cited_in_column,citation,note`.  Add stable ID, resolution status,
   evidence file/locator, and occurrence columns when useful.
3. Preserve the frozen snapshot.  Put OCR or column-shift corrections in a
   checked overlay and record the correction on affected output rows.
4. Normalize citation text only to generate candidates.  Retain surname
   particles, hyphens, and year suffixes.  Confirm identity using the local full
   bibliography (title/journal/volume/start page where present).  Never merge an
   author/year collision automatically.
5. Classify the resolved cited work itself. A resolved bibliography entry is
   not automatically primary: reviews, monographs, handbooks, and textbook
   chapters remain cited-source provenance and must not enter a primary-only
   pool unless their row-level experimental sources are recoverable. Emit an
   all-cited-source catalog plus a primary-only catalog when both are present.
6. Split a multi-citation cell only into reference links.  If one printed value
   cites multiple works and cannot be deconvolved, classify it as a compound
   source value; do not pretend that each work independently reported that value.
   For compiler averages or cross-area summaries, recover transitive component
   lineage when it is determinable from adjacent/source tables, while retaining
   the row's derived role and excluding it from the primary-only pool.
7. Standardize species, structure, condition, measure, and units before proposing
   value matches.  Preserve printed labels and source subregions.
8. Audit within-compilation cardinality before averaging. If one primary work has
   several rows for the same taxon/structure/measure/condition/unit key and their
   arms are not recoverable, quarantine the whole group and emit every record/value
   member to an arm-ambiguity report. Renaming the group “baseline” is not a fix.
9. Compare compilations only after matching the primary source plus the complete
   biological cell: taxon, structure/subregion, measure, condition/method when
   relevant, and standardized units.
10. Deduplicate confirmed shared primary observations before aggregation.  Retain
   one governed value in the merge, preserve every compiler report in provenance,
   and never count the two compilations as independent teams.
11. Aggregate within a primary work first only after study-arm identity is resolved,
   then aggregate across distinct primary works.
   Emit `n_primary_references`, sorted primary IDs/full citations,
   `Compilations_reporting`, and `Compilations_used`.
12. Put detailed cross-compilation checks in the restricted repository, per
    `REPO_BOUNDARY.md`; the public merge may retain a concise dedupe/provenance
    report.

## Comparison statuses

Always retain exact equality and a precision-aware result separately:

- `same_exact`: standardized values equal within numerical epsilon.
- `same_within_reported_precision`: difference is no larger than the combined
  half-unit implied by the two printed precisions.
- `different`: an unambiguous matched pair exceeds that tolerance.
- `ambiguous_one_to_many`, `ambiguous_many_to_one`, `ambiguous_many_to_many`:
  matching cardinality is not one-to-one; do not average to force a pair.
- `compound_reference`: one value cites multiple primary sources.
- `taxonomy_conflict`, `region_conflict`, `condition_conflict`, or
  `unresolved_reference`: preserve for review; do not auto-deduplicate.
- `<compilation>_only`: no corresponding report from the other compilation.

For a disagreement, the merge decision and the comparison judgment are distinct.
The records are still the same primary work and must not be double-counted, but
the reported value difference must remain visible.

## Validation gates

Fail the build unless all of the following hold:

- Every included direct datum resolves completely to exactly one primary
  reference; a multi-part citation with even one unresolved part is not an
  eligible singleton.
- Every resolved source reference has an explicit level/type, and no value
  cited only to a secondary synthesis enters the primary-only pool without a
  documented row-level primary lineage.
- Every raw citation alias maps to one catalog row or an explicit issue row.
- No compiler count such as `N=6` is treated as a citation.
- No compound row is partially deduplicated.
- All link-table foreign keys resolve to the reference catalog.
- Every derived row with recoverable component lineage has links, and ordered
  joined IDs agree with link-table `reference_order`.
- No derived/average/estimated row enters the primary-only pool unnoticed.
- No unresolved within-primary multirow source/cell/condition/unit group is
  averaged; every such group is either arm-resolved or quarantined with a
  complete record/value manifest.
- Every merged `n_primary_references` equals the number of listed distinct IDs.
- Raw and standardized values/units remain available for every compared row.
- Source-row locators round-trip to the frozen carrier, and printed value/SD
  lexemes reproduce the authoritative source presentation (for example, a PDF
  when a numeric workbook has discarded display-only trailing zeros), including
  rows expanded to multiple measures or separated by skipped labels.
- Known unit-conversion sentinels and source-row corrections pass.
- Recompute same-source deduplication and final cell means independently from
  the provenance table; do not validate only row counts or nonblank fields.

For the worked example, see
`__merging_cerebral_metabolic_rate/README__merging.md` and
`__merging_cerebral_metabolic_rate/build_primary_reference_catalogs.py`.
