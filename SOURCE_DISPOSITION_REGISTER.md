# Source disposition register

**Canonical decision log for sources or source items that have been reviewed but are not simply
“build and merge.”** Use this file to prevent the cycle of adding, removing, rediscovering, and
re-adding the same paper.

This register does **not** duplicate the data catalog:

- `__ReadMe.xlsx` remains the citation, item, and public-filename registry.
- `PROJECT_SCOPE_AND_DATASET_ROADMAP.md` remains the project scope and active build roadmap.
- Source-folder READMEs retain detailed evidence and extraction notes.
- This file records only the **decision**, its reason, the preferred alternative, and what evidence
  would justify reconsideration.

## Maintenance rule

1. Search this file before scaffolding, deleting, exporting, or wiring a source.
2. Never delete an old decision. Update its current disposition and append a dated entry to
   **Decision history**.
3. Distinguish the level of the decision: whole source, one item/table, one measure, or merge only.
4. A source can stay in `__ReadMe.xlsx` and in its source folder even when it is not built or merged.
   Keeping a documented skip is often the best protection against duplicated work.
5. `EXCLUDED` does not mean “erase the evidence.” It means retain enough citation and reasoning to
   keep the decision reproducible.

## Status vocabulary

| status | meaning |
|---|---|
| `PLANNED` | accepted for a future build; not yet a public dataset |
| `HOLD` | potentially useful, but a named blocker or owner decision prevents action |
| `SEPARATE` | useful and possibly built, but methodologically incompatible with an existing merge |
| `DOCUMENTED SKIP` | reviewed; no new extractable primary data or no defensible standalone build |
| `SUPERSEDED` | a preferred/corrected/upstream source supplies the same role |
| `EXCLUDED FROM MERGE` | source/item may be retained or built, but must not feed the named compilation |
| `OUT OF SCOPE` | does not answer the current project question |

## Whole-source decisions

| source | current disposition | why | preferred source / action | reconsider only if | evidence |
|---|---|---|---|---|---|
| Weaver 2005, *Reciprocal evolution of the cerebellum and neocortex in fossil humans* | `DOCUMENTED SKIP` | No new raw table; quantitative content is derived from or reuses Weaver 2001. | Use the built Weaver 2001 Tables A-11/A-15. Keep the 2005 citation, folder, and registry row as provenance. | A genuinely new primary value is identified and can be separated from the 2001 data; any figure digitization must be explicitly marked derived. | [`Weaver_2005_NOTE.md`](Weaver_2005/Weaver_2005_NOTE.md) |
| Smaers & Soligo 2013, *Brain reorganization, not relative brain size…* | `DOCUMENTED SKIP` | Supplements contain PCA scores, figures, and a sample description—not new raw structure volumes; underlying sources are already represented. | Use Stephan 1981, Frahm 1982, Smaers 2011, or the other cited primary sources. | Raw per-species motor-cortex volumes become available from a citable primary deposit. | [`Smaers_Soligo_2013_NOTE.md`](Smaers_Soligo_2013/Smaers_Soligo_2013_NOTE.md) |
| Navarrete et al. 2018, *Primate Brain Anatomy: New Volumetric MRI Measurements…* | `EXCLUDED` | Owner-flagged values, inter-observer concern, and an erratum that rewrites Table 1/specimen attribution. | Do not re-scaffold. Continue using the established histological teams for current volume merges. | Owner explicitly lifts the exclusion; then use the erratum-corrected table, create a separate MRI team, and complete a specimen crosswalk first. | [`PROJECT_SCOPE_AND_DATASET_ROADMAP.md`](PROJECT_SCOPE_AND_DATASET_ROADMAP.md) |
| Lesku et al. 2006, mammalian sleep architecture | `SUPERSEDED` / not built | Closely related older compilation; Capellini 2008 is the curated, corrected re-compilation selected for this role. | Use built Capellini et al. 2008 and resolve shared ancestry rather than averaging sources. | Lesku contains a required variable or primary record absent from Capellini, with dependencies explicitly resolved. | [`PROJECT_SCOPE_AND_DATASET_ROADMAP.md`](PROJECT_SCOPE_AND_DATASET_ROADMAP.md) |
| Navarrete et al. 2016, innovation and technical intelligence | `BUILT`; not yet compiled | Earlier exclusion as “covered by Reader” was too broad. Its technical/non-technical subtype counts complement Reader, but derive from the same report records. The deposit contains integer counts—not pre-corrected rates—and no research-effort denominator. | Keep the registered `Data` item as distinct measures; never add its subtype counts to Reader totals or invent an effort-normalized field. | Reconsider only the exact included variables—not the source wholesale—if a downstream product cannot represent their dependency on Reader. | [`Navarrete_etal_2016_Data.README.md`](Navarrete_etal_2016/Navarrete_etal_2016_Data.README.md), [`PROJECT_SCOPE_AND_DATASET_ROADMAP.md`](PROJECT_SCOPE_AND_DATASET_ROADMAP.md) |
| Olkowicz et al. 2016, avian brain cell counts | `BUILT`; `EXCLUDED FROM MERGE` | Valid 28-species avian comparative dataset, but current compilations are mammal-only. The registered `DatasetS1` naming and explicit `Class = Aves` gate are now implemented. | Retain the public shelf dataset; keep it out of mammal merges until a class-aware route and avian region-term destination exist. | Compile only after the class/taxonomy gate and a destination for avian region terms are implemented. | [`Olkowicz_etal_2016_DatasetS1.README.md`](Olkowicz_etal_2016/Olkowicz_etal_2016_DatasetS1.README.md) |
| Medina-González 2026, terrestrial-mammal joint excursion | `HOLD` | Zenodo record `10.5281/zenodo.15425733` is published but restricted and returns no files to unauthenticated clients. Exact headers and redistribution license cannot yet be checked. | Keep the registered `Data` item and reader scaffold; build only after the owner supplies the files or access is granted. | The seven source files become legitimately accessible and their license permits the planned public TSV. | [`MedinaGonzalez_2026.README.md`](MedinaGonzalez_2026/MedinaGonzalez_2026.README.md) |
| Heuer et al. 2019, 3-D neocortical folding | `SEPARATE`; metadata built, measurements on hold | Its 3-D convex-hull folding metrics are not interchangeable with the Zilles 2-D GI. The actual Zenodo folding table is not yet held locally. | Keep separate from `__merging_gyrification`; acquire the frozen Zenodo data before building the measurement item. | Merge only into a method-explicit folding product that preserves the 3-D measure identities. | [`Heuer_etal_2019.README.md`](Heuer_etal_2019/Heuer_etal_2019.README.md) |

## Item- or merge-level decisions

These do not exclude the whole paper. They prevent a particular table, derived result, duplicate,
or incompatible measure from entering a compilation.

| source item | level | disposition | reason / replacement | evidence |
|---|---|---|---|---|
| Dos Santos et al. 2020 published Table 1 | item + cell-count merge | `EXCLUDED FROM MERGE` | Published transcription errors include physically impossible counts. Use the internally consistent unpublished author spreadsheet; retain Table 1 as a reference snapshot. | [`DosSantos_etal_2020_comparison_summary.md`](DosSantos_etal_2020/DosSantos_etal_2020_comparison_summary.md) |
| Gabi et al. 2016 Table S2 | item | `DOCUMENTED SKIP` | Regression slopes/statistics, not species trait values. Table S1 remains valid. | [`Gabi_etal_2016_TableS1.README.md`](Gabi_etal_2016/Gabi_etal_2016_TableS1.README.md) |
| Kazu et al. 2015 regression statistics | item | `DOCUMENTED SKIP` | Inferential statistics rather than species trait values; not registered or built. The corrected Table 1 is the data item. | [`Kazu_etal_2015_TABLE1.README.md`](Kazu_etal_2015/Kazu_etal_2015_TABLE1.README.md) |
| Nudo et al. 1995 Table 3 | item + all merges | `EXCLUDED FROM MERGE` | Arithmetically derived from Table 2 and retained only for provenance. | [`Nudo_etal_1995_TABLE3.README.md`](Nudo_etal_1995/Nudo_etal_1995_TABLE3.README.md) |
| Balzeau et al. 2012 Tables 3 and 5 | volume merge | `EXCLUDED FROM MERGE` | Size-corrected dimensions and derived percentages, not absolute volume measures. Other paper items remain usable. | [`Balzeau_etal_2012_Table3.ReadMe.md`](Balzeau_etal_2012/Balzeau_etal_2012_Table3.ReadMe.md), [`Balzeau_etal_2012_Table5.ReadMe.md`](Balzeau_etal_2012/Balzeau_etal_2012_Table5.ReadMe.md) |
| Smaers et al. 2017 prefrontal measure | measure + volume merge | `SUPERSEDED` / duplicate | Duplicates Smaers 2011 Supplementary Table 2; use the earlier/raw source. This does not exclude the paper's other measures. | [`crosspub_Smaers2017_FINDINGS.md`](__merging_volumes/crosspub_Smaers2017_FINDINGS.md) |
| Baron et al. 1996 Tables 10 and 32 | items + volume merge | `HOLD` | The completed audit finds no overlap with the current canonical core, but seven historical taxon concepts require curator decisions and all same-species source rows must be averaged within each Baron item before Tier-1 recency resolution. Keep both built/public items out of the merge until those gates are implemented. | [`Baron_etal_1996_overlap_taxonomy_audit.md`](Baron_etal_1996/Baron_etal_1996_overlap_taxonomy_audit.md) |

Specimen-level duplicate decisions do **not** belong in this table. Record them in
`_keys/specimen_crosswalk/` and the specimen notes, where one animal can be followed across papers.

## Unresolved disposition conflicts

| source/item | conflict | required decision |
|---|---|---|
| Fu et al. 2013 Table 1 | Weaver's skip note refers to “Fu 2013” as an existing documented-skip precedent, but `__ReadMe_export_gaps.md` and the 2026-08-05 build-status snapshot list it as a missing build. | Inspect the source-specific evidence and choose `PLANNED` or `DOCUMENTED SKIP`; do not build or delete it solely from either stale cross-project list. |

## Decision history

| date | decision |
|---|---|
| 2026-08-15 | Register created from existing source notes and the consolidated roadmap. |
| 2026-08-15 | Weaver 2005 retained in the project and `__ReadMe.xlsx` as `DOCUMENTED SKIP`; no item suffix assigned. |
| 2026-08-15 | Navarrete 2016 changed from blanket `EXCLUDED` to `PLANNED`: build only complementary classifications/effort-normalized measures, not duplicate Reader report counts. |
| 2026-08-15 | Olkowicz 2016 confirmed as build/register allowed but not eligible for mammal compilations. |
| 2026-08-15 | Navarrete 2016 built from the 167-species Dryad CSV. Source inspection showed integer subtype counts and no effort denominator, so the output does not claim corrected rates. |
| 2026-08-15 | Olkowicz 2016 Dataset S1 built for all 28 avian species with `Class = Aves`; remains excluded from mammal merges. |
| 2026-08-15 | Medina-González 2026 recorded as `HOLD` until its restricted Zenodo files are legitimately available. |
| 2026-08-15 | Canonical volume outputs made explicitly core-only; DeCasien-only papers remain confined to the `_DeCasien` comparison subset. Matano 1992, Kverkova 2018 Table S1, and Smaers 2011 Supplementary Table 2 were added to the core. |
| 2026-08-15 | Baron 1996 Tables 10/32 overlap/taxonomy audit completed: zero current core overlap; merge remains `HOLD` for seven taxon concepts and within-source aggregation. |
