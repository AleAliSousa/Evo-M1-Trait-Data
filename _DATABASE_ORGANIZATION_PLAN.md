# Database organization plan

**Consolidated 2026-11-23.** One note for how `Evo-M1-Trait-Data` is organised and where it is
going. The apps are planned separately in the app plan.

**Direction (owner, 2026-11-23).** Three goals govern everything below:

1. **Reduce the repository.** Fewer folders, fewer parallel mechanisms, fewer notes.
2. **One route.** One way in which sources are compared, reconciled and delivered to the apps.
3. **Two repositories.** Source PDFs and publisher files in one repository; builds and outputs in another.

**Precedence.** Where notes disagree, the newest note is the plan of record. Older notes
contribute what is still relevant (section 5) and are otherwise superseded. Dates are those
stated inside each note. "Checked" means tested on 22–23 November 2026 against the local
checkout, which matched the last-fetched `origin/main`; anything not marked checked is reported
as the source note states it. Lines marked **Recommendation** are this consolidation's own.

---

## 1. Target state

```
SOURCES REPOSITORY (new)                 BUILD-AND-OUTPUTS REPOSITORY (this repo, reduced)
<Paper>/                                 <Paper>/
  publisher PDF, full-text capture,        snapshot(s) and snapshot-maker
  supplements, downloaded data files       item script, analysis CSV
                                           definitions, errata, README
                                         __Public/comparative-data/   public TSVs
                                         _keys/        identities, catalogue, relationships
                                         __compiled/   ONE mapping table, ONE R build,
                                                       ONE set of outputs (long, wide,
                                                       unfiltered, species resolution)
                                         __ShinyApp/   app code; reads __compiled/ and the
                                                       public TSVs, nothing else

PRIVATE REPOSITORY (role unchanged): checks, unpublished data, specimen records
```

The snapshot is the boundary object. Everything before it is evidence as published and lives
in the sources repository. Everything from the snapshot onward is our work and lives here.
`__compiled/` is a working name from `one-route-per-trait-plan.md`.

Gone in the target state: the 27 `__merging_*` folders, the trait-table feed,
`_keys/variable_canonical.csv`, the two pilot folders, and the backup and one-off material
listed in W9.

## 2. Where things stand (checked)

| | What | Size |
|---|---|---|
| Tracked working tree | 13,019 files | 3.41 GB |
| Publisher PDFs in paper folders | 688 files | 1.44 GB, about 41% of tracked bytes |
| Other source-type files in paper folders | `.docx` `.doc` `.zip` `.htm(l)` `.xml` and images: 172 files | about 130 MB |
| `.xlsx` / `.xls` in paper folders | 545 files; a mix of publisher supplements and our own workbooks, not separated here | 167 MB |
| Paper folders | about 620 | — |
| Snapshots | 1,184 snapshot files; 223 snapshot-maker scripts | — |
| Public tables | 1,142 TSVs in `__Public/comparative-data/` | 243 MB |
| Registry | `__ReadMe.xlsx` `Sheet1`, about 1,160 rows | — |
| Merge layer | 27 `__merging_*` folders; 44 R and 16 Python scripts at their top level | — |
| Duplicate patch | `_keys/variable_canonical.csv` | 64 rows |
| Label authority | `_keys/trait_authority.csv` | 1,387 labels; 1,347 with a single producer |
| Pilots | `__measurements/` 3.2 GB on disk (16 MB tracked); `__metadata/` 95 MB (37 MB tracked) | — |
| Backup folder | `_bk2/`, 1,240 tracked files | 231 MB |
| Git history | `.git` on this machine | 8.9 GB |

## 3. Principles

From `one-route-per-trait-plan.md` §2 (2026-11-22), which names them as standing rules:

1. **One route per trait.** Every app label is produced by exactly one build path. A second copy of a trait anywhere in the app feed is a bug.
2. **Reconcile, don't duplicate.** Primaries before compilations. A compilation that largely re-reports a primary already held is a cross-check and gap-filler only, never pooled wholesale. Pooling is by explicit precedence, never by averaging across sources. Fossil values are different variables from extant ones, except endocranial volume.
3. **Provenance at the data-point level.** Every value keeps its source item; reconciliation chooses among sources and never blends them into anonymity.
4. **One editable table drives the build**: one row per (trait, source) with precedence, unit conversion and label. File-level registration only where it earns its keep.
5. **R only** for build scripts that live in the repo.
6. **Nothing is deleted until its replacement is verified live.** Build in a replica → cell-level diff → PR → verify → delete last, as in the body/ecology split (PRs #95–#100; loader re-point PR #99). Data moves are live on push because the app reads GitHub at runtime; loader changes need a redeploy.
7. **It needs to be simple.** (Michael's verdict on the pilot, as recorded in the same note.)

Older rules that remain in force unchanged: printed values are kept and snapshots are frozen;
a different method or structure boundary makes a different variable (Zilles 2-D GI vs Heuer 3-D
folding; Heuer 2023 vs Ashwell 2020; brain mass by basis); species names are resolved once by
one resolver and taxa are not pooled in the build; every check lives in the private repo and
nothing private writes into the public one; public TSV filenames are identifiers; source
decisions go in `_SOURCE_DISPOSITION_REGISTER.md`; a correction is an erratum row, never an
edit; a tool acts and a check only reports.

Older rules this plan changes:

| Older rule | Source | Now |
|---|---|---|
| One folder per publication holds source, snapshot, script and outputs | `_REPO_BOUNDARY.md` §3 | The folder name is kept in both repositories; the source files move (W3). |
| Each app label has one authoritative producer *folder* | `README_trait_authority.md` (2026-09-22) | Each trait has one build path and an explicit source precedence in the mapping (W1). `trait_authority.csv` is the starting inventory and is retired with the merges. |
| Independent remeasurements are pooled as distinct primary studies | `SOURCE_RELATIONSHIPS.md` (2026-09-30) | "Never by averaging across sources." This changes values wherever a merge currently averages across sources; Phase 0 must list those cells (decision D2). |
| Extend `variable_canonical.csv` into the single trait catalogue | roadmap Part 3 (2026-09-02) | The file is retired; its role columns go elsewhere (W6). |
| Extract a `__backbone_traits` merge for body mass, brain mass, BMR, diet | roadmap Part 3 | Not built. Backbone traits are rows in the mapping (W1). |
| A Python builder may stay until its R twin is proved equal | 2026-08-07 decision | The single pipeline is R. The 16 Python files in merge folders go with the merges; the 11 in `_keys/` are decision D8. |

## 4. Workstreams

### W1. One route per trait

Source: `one-route-per-trait-plan.md` (2026-11-22). Status: no phase started; `__compiled/`
does not exist (checked).

**Why.** A trait reaches the app by three routes: a `__merging_*` folder with its own compiled
script; the trait table (`evom1_traits_long.csv`, melted from the workbooks with no
reconciliation); and the per-publication TSVs in the source-tables view. The same datum can
exist three times. `variable_canonical.csv` hides only the duplicates someone has noticed and
can only relabel or drop trait-table rows.

**Design.** Layer 1: per-publication tables, unchanged in content. Layer 2: one R pipeline
driven by the mapping table: sources → per-trait reconciliation by precedence → one long table
plus wide, unfiltered and species-resolution outputs, in one folder. Layer 3: the catalogue
(`_keys/variable_domain.csv` and the definitions builder), unchanged in role. The supplementary
merge is the working model: a sources CSV with a precedence column, dual mapping for pooled
labels, provenance spanning all contributors. The trait table stops being an app feed; the
traits only it carries (dexterity, corticospinal tract, locomotion, gait, handedness, V1 synapse
measures) become mapping rows whose source is the trait table, ranked below any primary.

**Phase 0 — route audit. No repo changes.**

1. Every app label and its route or routes, with species counts per route and value agreement where routes overlap. Start from `trait_authority.csv`, which already lists the producers of each label; add duplicates that hide under different labels, using `poolable_family` in `variable_domain.csv` (filled on 561 of 1,510 rows).
2. For every multi-source trait, a proposed precedence as a decision table: POOL BY PRECEDENCE / KEEP SEPARATE / ALREADY HANDLED, with evidence. `_keys/source_relationships.csv` holds the declared relationship and quoted passage for 224 paper-pair rows; 218 are still `drafted` and none is `confirmed`, so curator confirmation of the rows a decision relies on is part of this step.
3. Inventory of everything that reads the merge folders or the trait table. Named in the plan: `app.R` loaders, `_keys/build_species_taxonomy.py`, the definitions builder, `__shinyapp_update.R`, TraitExplorer. Found in addition (checked): `__Cytosplore_export/build_cytosplore_traits.R`, `_keys/build_trait_authority.R`, `_keys/build_cell_morphology_domain.py`, `_keys/build_brain_size_basis.py`, `__ShinyApp/build_data.R`, `_checks/check_ontology_pilot.py`.
4. **Recommendation:** three further inventories, because Phase 2 cannot be designed without them:
   - cells that are currently a cross-source average (see the table in section 3);
   - per-merge logic that is not precedence: within-source species averaging, laterality doubling, unit and basis conversion, method splits, the study-set dedupe of the sensory merge;
   - hand-authored inputs that sit inside merge and pilot folders and would be deleted with them: `__merging_volumes/volumes_select_value_flags.csv`, `laterality_known.csv`, `volumes_primary_DeCasien_curation.csv`, `volumes_primary_DeCasien_sources.csv`; `__merging_body_ecology/body_ecology_value_flags.csv`; the value flags, vocabulary and crosswalk CSVs of `__merging_cell_counts_histology/` and `__merging_cell_morphology/`; `__merging_trees/tree_tip_crosswalk.csv`; `_keys/volumes_species_overrides.csv`; `__metadata/curation/`.

**Phase 1 — stop the trait-table feed duplicating merges.** Mapping rows for every
trait-table-only trait. `variable_canonical.csv` shrinks to zero rows as each duplicate is
reconciled at the source. The app drops its `traits` feed once the mapping covers its labels;
interim option: keep the feed with an empty canonical file and a start-up check that fails
loudly on any label arriving from two datasets.

**Phase 2 — build the single pipeline in parallel.** New folder with the mapping table, one R
build script and the outputs, built in a replica against live inputs. Acceptance test:
reproduce the app's current compiled database cell for cell, with every difference itemised and
traced to a Phase 0 decision. Guards for known source misprints become mapping-level
annotations with the guard values recorded.

**Phase 3 — switch the app.** Re-point the loader to the single output; redeploy; spot-check
picker contents, per-dataset species counts against the Phase 2 acceptance table, and the
sentinel values (elephant cortex O.n 150,150,000,000; rabbit cerebellum O/N 0.314;
*Leontocebus fuscicollis* Cathemeral; Gestation coverage). Verify TraitExplorer against the new
output before Phase 4.

**Phase 4 — retire.** Delete `__merging_*` in batches after each is verified live under the
new route, with the registry and the updater's staging list changed in the same PRs. Retire
`variable_canonical.csv`, the trait-table feed machinery in `build_data.R`, and the pilot
folders. Heuer 2019 is the test case: a single-source "merge" becomes one mapping row or a
decision not to surface it; separateness is a property of the mapping, not of the directory tree.

**What the older notes add to the mapping design.**

- The relationship vocabulary of `SOURCE_RELATIONSHIPS.md` says what each mapping row must be able to express: `supersedes`, `reprints`, `derives_from` and `extends_sample` are precedence; `same_specimens_different_method` and `redefines_structure` are separate labels; a pair can have different winners for different structures, so precedence is per (trait, source), which the mapping grain already provides and which fixes rule D5 of `COMPILATION_LESSONS.md` (structure-level supersession missed by paper-level ordering).
- The remaining "Not yet" rules of `COMPILATION_LESSONS.md` are design requirements for the pipeline: A3 mark values the source never printed; E3 a specimen id where the value is one individual's; E4 explicit zeros with a `structure_absent` flag; F2 and F3 use the coverage inverse as the pick-list for skipped columns and isolated gaps; G4 name the PanTHERIA release in the source.
- Never combine two datasets that re-use the same secondary source as if independent; keep role and team on every value (`provenance_and_comparison_independence.md`).
- A record of which data points were passed over (`____TODO/Database comparative data.txt`): the unfiltered output with the losing sources kept is that record.

**Risks, from the plan.** Live-app breakage (guard: parallel build, acceptance diff, delete
last). Silent value changes (guard: cell-level test; every delta traces to a decision). Registry
churn (`__ReadMe.xlsx` is shared: sync to live main and diff before and after every change).
Scope creep into curation: which source wins is the curator's choice; the plan only makes
choices explicit and singular; open curation items such as the *Blarina* whole-brain guard stay
open and are carried as flagged annotations.

### W2. Registry and registration

Sources: `one-route-per-trait-plan.md` §2; `__metadata/ITEM_REGISTRY_PILOT.md` and
`FOLDER_REGISTRY_LAYOUT_DRAFT.md` (2026-11-17/18); roadmap Part 1; `__ReadMe_Excel_recovery.md`.

Plan of record: two authored tables and no more.

| Table | Grain | Role |
|---|---|---|
| Item registry, `__ReadMe.xlsx` `Sheet1` | one row per public item | citation → item name → public filename; stays the naming authority |
| Trait–source mapping (new, W1) | one row per (trait, source item) | drives the build |

The pilot's file-level registry (`pipeline_files.csv`, `file_dependencies.csv`) and the
folder-owned item registry are not continued: the newest note judges them "two competing
registration systems" and asks for file-level registration only where it earns its keep.
`_checks/find_csv_tsv_creators.R` already reports which script creates each data file.

Carried forward:

- Registry procedure (roadmap Part 1): enter A–D, let E–L derive the names, generate the TSV, run `_tools/file_list.R`, inspect the file-match column. Rows past 200 are changed by paste file (a working constraint recorded in the provenance plan). Three legacy Wiley DOI stems keep their semicolons.
- Prevention rules after the 2026-10-26 Excel content-recovery incident: cells in column order; formulas and caches preserved; no blind re-save through a spreadsheet library; `_checks/registry_snapshot.R` keeps a text copy so a lost row shows in git.
- Findings from the pilot: the cached file-match status reads `notfound` for Kaufman A1 and A10 although both TSVs exist; 97 registry rows have no exact-named item script; a definitions file can apply to one item, a group or a whole paper, and scope cannot be inferred from the filename (Kaufman 2004 Tables A1–A14 vs A15).
- Open from the 2026-10-31 audit, not re-checked: orphan TSVs that are name mismatches; staged rows to paste; three trailing-underscore keys; 8 FINISHED rows with no TSV.
- Optional, from the roadmap: convert `Sheet1` to an Excel Table with calculated columns, after testing against the R readers.

### W3. Two repositories: sources, and builds with outputs

Sources: `repo-restructure-plan.md` (2026-11-18); `one-route-per-trait-plan.md` Part B
(2026-11-22); owner direction 2026-11-23, which settles the destination as a separate
repository.

**What moves.** Stage 1 of the chain of provenance: material exactly as published. Publisher
PDF, full-text capture (`fulltext.xml`, `fulltext.html`), supplementary bundles and publisher
figures, and downloaded data files. Checked: 688 PDFs (1.44 GB) plus about 130 MB of other
publisher-type files; the 545 spreadsheets in paper folders need sorting into publisher
supplements and our own workbooks.

**What stays.** Snapshots, snapshot-makers, item scripts, analysis CSVs, definitions, errata,
READMEs, the public TSVs, keys, the compiled outputs and the apps. The apps are unaffected:
they read TSVs and compiled outputs, never a source file.

**The four stages** (from the restructure plan) remain the vocabulary: sources (frozen, never
edited), snapshots (the published table frozen as data, before cleaning), scripts (the only
things that run), outputs (regenerable).

**Design points that need settling before any file moves.**

1. *Build scripts that read a source file directly.* A build in this repo must not need the other repository. Checked: besides the 223 snapshot-makers, at least 27 other paper-folder scripts extract from a PDF, 15 parse HTML or XML and 9 unzip a bundle; scripts that read a publisher spreadsheet directly were not counted. The restructure plan notes that born-digital items have no snapshot and their script reads the source file. **Recommendation:** every item gets a snapshot, which for a born-digital source is a byte copy of the data file (already done for Jaeggi and Qiu in the social-variables set, and proposed for Wei 2019). Item scripts then read snapshots only, and the sources repository is needed solely to make or re-verify a snapshot.
2. *Where snapshot-makers live.* They read a source and write a snapshot, so they straddle the boundary (an open question in the restructure plan). **Recommendation:** here, beside the snapshot they document, reaching the source through a resolver.
3. *A resolver.* The pattern exists: `_helpers/restricted_data.R` finds the private repo from an environment variable or the default layout and stops with a message if it is absent. The same is needed for the sources repository, used by snapshot-makers and by every tool that opens a PDF: `_keys/verify_source_statements.py`, `_tools/lock_sources.sh`, `_tools/snapshot_freeze.R`, `_tools/find_paper_pdfs.py`, the frozen-source invariant in `_tools/dataset_builder`, the replot inspection and the human visual check of a snapshot.
4. *Public or private* (decision D3). The plan notes that some source files may not be redistributable. `_REPO_BOUNDARY.md` already gives the test: "Could this file be pushed to a public GitHub repository today, without asking anyone's permission?" The private repository already has a `source_library/` (15 MB, the Nick–Fran intake with a manifest), so one option is to extend it instead of creating a third repository.
5. *Git history* (decision D4). Moving files out of the tree does not shrink a clone or remove the files from the public history. `.git` is 8.9 GB on this machine. If size or redistribution is the aim, the reduced repository needs either a history rewrite or a fresh start with the old repository archived. The apps fetch by path from `main`, so they are unaffected provided the paths they read survive.
6. *Ripple effects named in the plans*: registry snapshot filenames (changed through the registry tools only); `_tools/dataset_builder` validation and audit; the `_skills/build-dataset-item` HOWTOs (update after the move, not before); README links.

**Migration** (from the restructure plan, adapted). Freeze the names. Update
`_tools/dataset_builder` and the resolver on a branch. Pilot on Beatty & Laughlin 2006, which
has every file kind: move its PDF, XML and supplements, re-run its snapshot and item scripts,
and confirm the analysis CSV and public TSV are byte-identical. Then folder by folder,
validating each item, committing in small batches. Final sweep: no script references an old
path and every item validates. A scratch trial on Beatty on 2026-11-18 (sources, snapshot and
scripts in sub-folders of the same paper folder) needed three path edits and reproduced the
36-row CSV and TSV byte for byte; the snapshot-maker refused a deliberately altered snapshot.

**Sequencing.** After the Phase 0 reader inventory. The acceptance test here is byte-identical
item outputs, which leaves W1's baseline untouched, so W3 can overlap W1 Phase 2.

### W4. Value-level provenance and lineage

Sources: `one-route-per-trait-plan.md` principle 3; `_DATAPOINT_PROVENANCE_PLAN.md`
(2026-11-08; plan only, nothing built).

Two grains, handled separately:

- **Which source item a compiled value came from.** Delivered by W1: the mapping names the source, the output carries it, and the unfiltered output keeps the sources that lost.
- **What kind of value a cell is inside its source**: measured, copied, derived, predicted. Mink et al. 1981 Table 1 is called `secondary` as a whole, but its brain-O2 column mixes 5 copied measurements, 28 Eq. 1 predictions, 6 Eq. 3 predictions and 3 other derivations. This is the provenance plan's subject and W1 does not cover it.

Plan for the second grain, after W1 Phase 2:

- A per-item `reference_tables/<Item>_value_provenance.csv`, written by the item's R script, only for items that are mixed. The definitions `role` stays the column default; the finest level present wins; a validator flags a coarser level that contradicts it.
- `origin` ∈ `measured_here`, `reported_from_source`, `transformed`, `derived`, `predicted_model`, `extrapolated_proxy`, `averaged`, `digitised`, `estimated_unspecified`, `unknown`. `check_status` ∈ `match`, `within_rounding`, `mismatch`, `pairing_mismatch`, `derived_reproduced`, `derived_mismatch`, `not_held`, `not_checked`. Errata stay where they are, linked by `erratum_id`.
- Value identifier `<Item name>:<row key>:<variable>`.
- Cross-paper lineage as an edge table with `relation` ∈ `copied`, `rounded`, `unit_converted`, `derived_input`, `averaged_input`, `predicted_from`, `extrapolated_from`, `mispaired`, `cited_not_found`; a value can have several parents and children; values not held are stub nodes.
- Pilot on the Mink cluster (Mink 1981, MacLarnon 1996, Karbowski 2007, Latimer & Sawin 1955, Krompecher & Lipák 1966, Crile & Quiring 1940, the brain-O2 primaries, and Coto 2026 Fig. 7 downstream), seeded from the private cross-table check. Judge the cost before going wider.

The SQLite point inventory in `__measurements/` and the catalogues in `__metadata/` are not the
route to this (W9). Two of their distinctions are kept: source role (primary / secondary / mixed)
and review status (an unresolved decision) are different axes; source role and measurement
method are different axes.

### W5. Species identity and taxonomy

Sources: roadmap Parts 2–3; `SPECIES_NAMING.md`; `_keys/TAXON_POOLING_DESIGN.md` (2026-10-20);
`__merging_volumes/SPECIES_STANDARDIZATION_PLAN.md`. None is contradicted by the newer notes;
W1 changes where two of them are implemented.

| # | Item | State |
|---|---|---|
| 1 | `Class` column in `species_reference.csv`, backfilled | checked: absent from every top-level `_keys/*.csv` |
| 2 | Non-mammal policy "register, don't compile" (2026-08-12) | checked: not in force. Species in eight bird orders: 43 in `__merging_sleep/sleep_long.csv`, 43 in `evom1_traits_long.csv`, 634 in `__merging_body/body_long.csv`. Under W1 the gate is one filter in the pipeline; it needs item 1 and decision D5. |
| 3 | Non-mammal path in the taxonomy resolver before any non-mammal is compiled | a lookup ladder (NCBI → MDD → GBIF → ITIS → PBDB) exists for navigation taxonomy; `resolve_taxonomy.R` not tested |
| 4 | `resolve_species(taxonomy =, pool =)` and the name × authority crosswalk | checked: not built; signature is `resolve_species(printed, source_publication, keys_dir)` |
| 5 | Pooling stays a read-time choice, default off. Domestication axis built 2026-10-20; sensu/subspecies axis deliberately unimplemented; `taxon_concept_registry.csv` read by no merge | under W1 the concept registry is wired into the one pipeline instead of 27 merges |
| 6 | Merge-time lumping lives only in `_keys/volumes_species_overrides.csv` (about 40 rows) | becomes explicit rows in the pipeline's species resolution; listed in W1 Phase 0 |
| 7 | About 18 build scripts still emit `species` / `Species name`; ten common-name tables need a binomial plus `common_name` | open per the note; not re-checked |
| 8 | 406 Hayssen names matching no compilation species | open per `__merging_life_history/README__merging.md` |

### W6. Variable catalogue: scope, region, vocabulary

Sources: roadmap Parts 1 and 3; `__ShinyApp/AUDIT_app_variable_organization.md`;
`_keys/ontology_pilot/README.md`.

- `trait_scope` (pan-vertebrate / mammal-wide / primate-core) and `role` (backbone / specialist) were to be added to `variable_canonical.csv`, and a region-of-interest tag (M1, V1, entorhinal, whole-brain, other) to `variable_catalog.csv`. Checked: none of the three columns exists. Since `variable_canonical.csv` is retired, **Recommendation:** all three go in `_keys/variable_domain.csv`, which has one row per label (1,510), already holds domain, measure class and poolable family and group, and survives W1.
- Then: coverage against the roughly 25 sequenced species by region; a deliberate entorhinal / hippocampal-formation scout; and only after that the repository name (`Evo-Cortex-Trait-Data` was suggested).
- The ontology pilot (8 terms, 17 paper variables, all `related_only` or `incompatible`) stays QA until a curator reviews it. Its check is called by four merge compilers and must be re-attached to the single pipeline or dropped.

### W7. Public/private boundary

Source: `_REPO_BOUNDARY.md` §6 and the private migration README. Checked states:

| Question | State |
|---|---|
| `Baron_etal_1996_overlap_taxonomy_audit.R` writes a build input and audit reports from one public script | open; still in the public folder |
| `SFI dataset/` at the private root needs a home | open |
| Seven `__*_comparison` folders sit at the private root; the placement table puts cross-publication checks under `restricted_checks/_cross_table/` | table and tree disagree |
| `__merging_<domain>/checks/` named as a home for checks | moot; amend the rule text |
| `output/` in the private repo; `checks/` beside `_checks/` in the public repo | both resolved (absent) |
| Rewrite history for the 195 formerly public comparison files | open; decide with D4 |
| Lineage edges and check status public when some primaries are restricted | open (provenance plan) |

`_REPO_BOUNDARY.md` will need a third column for the sources repository once W3 is decided.

### W8. Tooling and process

| # | Item | State |
|---|---|---|
| 1 | `build_dataset_item()` as a gate: it could run another item's script and pass on old outputs (fixed 2026-11-18, `test_build_dataset_item.R`); real Catania and Falcone items still fail inside the wrapper | must work before W3's folder-by-folder migration |
| 2 | `_tools/audit_folders.py` `norm()` drops non-ASCII | not re-checked since 2026-10-31 |
| 3 | A normal cerebral-metabolic-rate rebuild expects `Kaufman__2004/old/` | checked: absent |
| 4 | `_README.md` names `APP_PLAN.md`, `REPO_BOUNDARY.md`, `PROJECT_SCOPE_AND_DATASET_ROADMAP.md` and `Update_ShinyApp.command`; none exists under that name | open |
| 5 | Figure replot backfill (107 candidate CSVs in 58 folders; 4 done) | active; `____TODO/figure_replots_handoff.md` |
| 6 | `_skills/build-dataset-item` HOWTO §9a tells builders to run `python __measurements/build_measurements.py` | remove when the pilot is retired (W9) |
| 7 | Run `build_data.R` and the definitions builder in a UTF-8 locale | standing trap |

### W9. Reduce the repository

Removal candidates, largest first. Nothing here is to be removed before its precondition is met.

| Candidate | Size (checked) | Precondition |
|---|---|---|
| Publisher PDFs and other source files | 1.44 GB + about 130 MB + part of 167 MB | W3 |
| `__measurements/` | 3.2 GB on disk, 16 MB tracked | owner confirms the pilot is superseded (D6); HOWTO §9a removed |
| `_bk2/` | 231 MB, 1,240 tracked files | confirm what it backs up; its contents were not examined |
| `__metadata/` | 95 MB on disk, 37 MB tracked | D6; `curation/brain_mass_row_basis.csv` rehomed first: it is read by `__merging_brain_mass/build_brain_mass_merge.py`, `_keys/build_brain_size_basis.py` and `Baker_etal_2025_b/Baker_etal_2025_b_SupplementaryData1.R` |
| Per-folder pilot files: `pipeline_files.csv` and `file_dependencies.csv` in 10 paper folders; `item_registry.pilot.csv` in 3 | small | D6 |
| The 27 `__merging_*` folders | 172 MB tracked in the seven largest | W1 Phase 4; authored inputs rehomed |
| `__Cytosplore_export/` outputs | 51 MB tracked | whether they are regenerable was not examined |
| `_keys/variable_canonical.csv`; trait-table feed code in `build_data.R`; `_keys/trait_authority.csv` and its builder and check | small | W1 Phases 1 and 4 |
| `____EvoM1_TraitTable/` workbooks | under 1 MB | D7: archive as a source, or keep as a living input |
| Two of the three sweep runners (`_run_all_scripts.sh`, `_v2.R`, `_v3.py`) | small | decide which is current; notes refer to v2 |
| Dated one-off tools in `_tools/` (`__rename_cell_counts_20261104.R` and its log, `add_sequence_letters_20261110.py`, `__edit_all_directories.R`) | small | move to `_archive/` |
| Root-level working files: `mmc2.xlsx`, `Püschel_etal_2026_sources_to_get (updated 2026-11-23).xlsx`, `_Evo-M1 primary-data candidates (merged 2026-11-23).xlsx`, `out/`, the empty `animaltraits_raw_Mammalia/` | small | each needs a home or removal; `_REPO_BOUNDARY.md` §5 says the root holds only what the README lists |
| Roadmap lines 734–1100 and 1162–1388 (dated build passes and the superseded 2026-10-28 order) | about 590 of 1,558 lines | move to `_archive/` |
| Records of finished work: `__ShinyApp/AUDIT_app_variable_organization.md`, `_UNCLASSIFIED_VARIABLES_SUMMARY.md` | small | move to `_archive/` |
| Planning notes replaced by this file | small | section 8 |

Removing a file from the tree does not reduce clone size; see W3 point 5.

## 5. What the older notes contribute, and what is superseded

| Older note | Still relevant, and where it is used | Superseded |
|---|---|---|
| Roadmap Part 3, "Backbone traits & taxonomic growth" (2026-09-02) | `Class` column; non-mammal resolver path; taxonomic filter and availability-driven variable list in the app; the observation that body and brain mass are re-derived in several merges (W1, W5, app plan) | extend `variable_canonical.csv`; `__backbone_traits` merge; pool-at-display |
| Roadmap Part 1 (2026-08-15 / 09-02) | naming contract and registry procedure (W2); region tags, coverage by region, entorhinal scout, deferred rename (W6) | nothing |
| Roadmap Part 2, non-mammal policy (2026-08-12) | the policy and the audit of birds in the feeds (W5) | the proposed per-merge class gate; it becomes one pipeline filter |
| `README_trait_authority.md` (2026-09-22) | producer list per label as the Phase 0 starting point; the check pattern (completeness, validity, decided) for the mapping; the warning that per-label authority does not detect the same concept under two labels | per-folder authority |
| `SOURCE_RELATIONSHIPS.md` (2026-09-30) | relationship vocabulary and quoted evidence as the basis of precedence; "never infer a relationship from year alone" (W1) | pooling of independent remeasurements, subject to D2 |
| `COMPILER_DECISIONS_CONTRACT.md`, `COMPILATION_LESSONS.md` (2026-09-29/30) | "Not yet" rules as pipeline requirements (W1); the error taxonomy for the acceptance diff | nothing |
| `provenance_and_comparison_independence.md` | shared-specimen and shared-secondary cautions (W1) | nothing |
| `SPECIES_NAMING.md` (v1 2026-09-28) | one resolver, printed names kept in items, resolution at compile time (W5) | "every merge sources the resolver" becomes "the pipeline does" |
| `TAXON_POOLING_DESIGN.md` (2026-10-20) | read-time pooling; the guard that reports a pool straddling a non-decomposable concept; open steps (W5) | its premise that merges aggregate with `mean()` per merge |
| `SPECIES_STANDARDIZATION_PLAN.md` (executed 2026-06-28) | remaining build scripts and common-name tables (W5 item 7); the common-name → binomial rule (collection match, then `Genus sp.`, then research-model species; always record the basis) | the merge-level parts, done |
| `____TODO/Database rules.txt` | snapshot rule: match the published table, do not spend more than about 15 minutes reproducing one that already matches, note how it was obtained | nothing |
| `____TODO/Database comparative data.txt` | QC note beside each reference; record of omitted data points; reliability column for the Kaskan data (W1, W2) | "add a column after each merge" |
| `2026-08-07` R-vs-Python decision | R is the build language | the twin-by-twin retirement procedure |
| `__metadata/` and `__measurements/` notes (2026-11-14/18) | the distinctions kept in W4; the list of authored inputs in merge folders (W1); registry findings (W2); builder defects (W8); the note that SQLite written inside OneDrive fails and must be built in local temporary storage | the pilot's two registration systems and its second interpretation of every cell |

## 6. Order of work

1. **Decide** D1–D4. They shape W1 and W3.
2. **W1 Phase 0**: route audit, reader inventory, and the three added inventories. Changes nothing.
3. **Metadata that changes no value**: `Class` (W5), catalogue columns (W6), `_README.md` links (W8).
4. **W3 preparation**: resolver; byte-copy snapshots for born-digital items; Beatty pilot.
5. **W1 Phases 1–2**: mapping, single pipeline in a replica, cell-level acceptance.
6. **W3 migration**, folder by folder; may overlap step 5.
7. **W1 Phases 3–4**: switch the apps, retire the merges, rehome authored inputs.
8. **W9**: pilots, `_bk2/`, one-offs, notes.
9. **W4**: Mink-cluster provenance pilot.

## 7. Decisions

Settled by the owner on 2026-11-23: one route (target of W1); sources and outputs in separate
repositories (W3); reduce the repository (W9).

| # | Decision | Raised in | Recommendation |
|---|---|---|---|
| D1 | Scope of the first single-pipeline build: every trait at once, or domain by domain behind the one mapping | one-route decision 1 | domain by domain into the one output, in the order Phase 0 shows to be least entangled |
| D2 | Cross-source averaging: is "never average across sources" absolute, including independent remeasurements that merges pool today | section 3 | decide from the Phase 0 list of affected cells |
| D3 | Sources repository: public or private; a new repository or the existing private one | one-route decision 3; W3 | private, extending the existing private repository's `source_library/`, unless the owners are confident every file is redistributable |
| D4 | Git history: rewrite, or start the reduced repository fresh and archive the old one | W3 point 5 | decide together with D3 |
| D5 | Non-mammal policy: enforce the 2026-08-12 rule in the pipeline, or revise it | W5 item 2 | — |
| D6 | Confirm the pilot folders are superseded, and where `curation/` goes | one-route decision 4 | confirm; one `_curation/` area for all authored inputs |
| D7 | Trait-table workbooks: archive as a source or keep editable | one-route decision 2 | archive (the plan's own recommendation) |
| D8 | Python in `_keys/` (11 files) under the R-only rule | section 3 | builders that feed the pipeline become R; checks may stay |
| D9 | Value provenance: vocabulary, row key, `cited_not_found` as edge or flag, items for downstream-only papers, public or private lineage | provenance plan §6 | adopt the plan's defaults as provisional for the Mink pilot |
| D10 | Dataset names in the app picker over the single output | one-route decision 5 | see the app plan |
| D11 | Boundary housekeeping: Baron script, `SFI dataset/`, comparison-folder placement | W7 | — |
| D12 | Repository name | roadmap Part 1 | after W6 |
| D13 | Item-level owner decisions carried from the 2026-10-31 audit: Rivara TSV released without review; 8 FINISHED rows with no TSV; Jones 2009 shared definitions file; Kaskan Figure 3 README; Navarrete 2018 erratum-corrected table | roadmap | not re-checked |

## 8. Notes this file replaces

Removed on 2026-11-23, after their still-relevant content was carried into this file. All were
committed and pushed, so each can be read with `git show <commit>:<path>`.

| Removed | Dated | Last commit | Content now in |
|---|---|---|---|
| `__merging_volumes/SPECIES_STANDARDIZATION_PLAN.md` | executed 2026-06-28 | feede85 | W5 item 7; section 5 (common-name rule) |
| `____TODO/Database rules.txt` | 2026-08-24 | 9531cc6 | section 3 (older rules in force); section 5 |
| `____TODO/Database comparative data.txt` | 2026-08-24 | 9531cc6 | W1 (record of passed-over data points); W2; section 5 |

**Still to remove: Part 3 of `_PROJECT_SCOPE_AND_DATASET_ROADMAP.md`** (lines 1439–1558, the
backbone-traits design of 2026-09-02). Its content is in W1, W5, W6 and the app plan. A version
of the roadmap with Part 3 cut to a 17-line pointer, which keeps the five "do-first" steps that
other files refer to, has been prepared but not applied.

Two item READMEs cite §3 of the removed species standardization plan (the rule for
common-name-only tables): `Finlay_etal_2006/Finlay_etal_2006_Table6.1.README.md` line 24 and
`Changizi__2001/Changizi__2001_Figure3.README.md` line 20. The rule: add a real binomial
`Species` column and keep the common names under `common_name`; never overload `Species` with
common names.

Kept as detailed backing for this file, which is the summary and the plan of record where they
differ:

| Note | Backs |
|---|---|
| `one-route-per-trait-plan.md` (2026-11-22) | W1, W3 |
| `repo-restructure-plan.md` (2026-11-18) | W3 |
| `_DATAPOINT_PROVENANCE_PLAN.md` (2026-11-08) | W4, including the Mink and Coto worked examples, which are recorded in full only there |
| `__metadata/FOLDER_REGISTRY_LAYOUT_DRAFT.md`, `__metadata/ITEM_REGISTRY_PILOT.md` (2026-11-17/18) | W2, W3 (Beatty trial), W8; they go with the pilot folders in W9 |
| `_keys/TAXON_POOLING_DESIGN.md` (2026-10-20) | W5; three `_keys` READMEs link to it and it documents the built pooling switch |

Rule books and READMEs of things in use are not plans and stay: `_REPO_BOUNDARY.md`,
`_SOURCE_DISPOSITION_REGISTER.md`, `_keys/SPECIES_NAMING.md`, `_keys/SOURCE_RELATIONSHIPS.md`,
`_keys/README_trait_authority.md` (until W1 Phase 4), the `_tools/dataset_builder/` conventions,
`AGENTS.md`.

## 9. Not consolidated here

- **Dataset build queue.** `_PROJECT_SCOPE_AND_DATASET_ROADMAP.md` Part 2 and its "Current order of work"; the two candidate workbooks at the root; `_other_sources_to_get/`; `____TODO/cell counts & surfaces to add.txt`; `____TODO/__ReadMe_SpinalCord.txt`; `____TODO/Nick_Fran_sources_2026-10-24/`; `HH_coverage_gaps_scaffold.md`; `__metadata/DATA_SOURCES_WEI_AHBA.md`.
- **Analysis plans.** `____TODO/Cell proportions.txt`.
- **Per-merge open items** in each `__merging_*/README__merging.md`. Under W1 they become rows or annotations in the mapping.
- **Reading limits.** Of the roadmap, lines 483–704, 734–1100 and 1176–1388 were not read. `_SOURCE_DISPOSITION_REGISTER.md`, `SPECIES_NAMING.md`, `COMPILATION_LESSONS.md`, `ERRATA_CONVENTION.md` and the files under `__metadata/pilot/` and `__measurements/pilot_*/` were read in part. `_bk2/` and `__Cytosplore_export/` were sized, not examined.
