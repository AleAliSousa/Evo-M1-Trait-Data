# Project scope and dataset roadmap

**Single source of truth, updated 2026-09-02.** This document replaces the former
`SCOUTING_AND_SCOPING.md`, `_checks/handoff_remaining_builds.md`, and
`NOTE_project_purpose_and_scope.md`. It combines four questions that had drifted across those files:

1. Why does this dataset exist?
2. Which sources are in or out?
3. What is actually left to build?
4. How should the taxonomy, backbone traits, and app grow?

Inclusion decisions are stable and citable: amend an IN / EXCLUDED / OUT-OF-SCOPE decision only
after an explicit owner decision. Build status is operational and should be updated whenever a
dataset or merge lands. The detailed per-folder procedure remains
`_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md`; this file records the
queue and the decisions, not a second copy of the HOWTO.

Before adding, removing, or re-scaffolding a reviewed paper, consult
`SOURCE_DISPOSITION_REGISTER.md`. It is the canonical cross-project log for documented skips,
superseded sources, merge exclusions, holds, and the evidence required to reverse a decision.

---

# PART 1 — Project purpose and current scope

## Original purpose

Evo-M1-Trait-Data was built to supply **comparative phenotypic traits for a single-nucleus RNA-seq
(snRNA-seq) project on mammalian primary motor cortex (M1)**, including M1 subregions where
available. The transcriptomic project supplies cell types and their proportions across species;
this repository supplies the organism- and structure-level context: brain and body mass, structure
volumes, neuron and glia counts, cortical layouts, gyrification, corticospinal and pyramidal-tract
measures, dexterity and hand morphology, metabolism, sleep, diet, and behaviour.

The species list is therefore not a balanced taxonomic sample. The species list is therefore not a 
taxonomically balanced sample. Rather, it reflects the intersection of species measured in the 
classical comparative neuroanatomy literature, particularly within overlapping datasets derived from 
the same specimen collections and methodological traditions. As a result, the sample is disproportionately 
shaped by a small number of highly influential research programs (including those of Stephan and colleagues,
Herculano-Houzel and colleagues, and Allman and colleagues) and those species that the snRNA-seq project could obtain tissue for.
That is also why specimen identity matters so much: when the comparison is to a small number of
sequenced individuals, knowing whether a literature species mean is one animal—and which
animal—can be as important as the value itself.

## The larger three-region project

M1 is one of three regions in the wider effort, which collects comparable snRNA-seq data from
roughly 25 mammals for:

1. **M1** — primary motor cortex and available subregions
2. **V1** — primary visual cortex
3. **Entorhinal cortex**

A V1 and entorhinal counterpart to the M1 trait set is therefore in scope. V1 coverage is already
better than the repository name suggests: `Stephan_etal_1981` area striata,
`Zilles_Rehkämper_1988` area-striata grey, `Bush_Allman_2004_b` V1 grey,
`Smaers_etal_2017` visual cortex grey/white/surface, `Changizi_Shimojo_2005` V1/A1/S1,
`Frahm_etal_1998` MT, `deSousa_etal_2010` V1–LGN, and `Collins_etal_2010` cortical surface.
Entorhinal coverage is much thinner; the Stephan schizocortex/hippocampus columns are the obvious
starting point for a targeted scout.

Region should become a first-class metadata axis. `_keys/variable_catalog.csv` already carries
`Structure` and `canonical_structure`; it still needs a region-of-interest tag such as M1, V1,
entorhinal, whole-brain, or other.

## Sensory data and a future repository name

The audio-visual dataset in `____Sensory_audiovisual/` is the first large intake that is not merely
an M1 correlate: it contributes visual acuity, audiograms, sound-localization thresholds, and
interaural distance for 157 species. It naturally serves the V1 arm and the broader question of
whether regional cell-type composition tracks function rather than size alone.

**Merge route decided and built (2026-08-31):** `__merging_sensory` compiles percepts only
(acuity, audiogram-derived thresholds, sound localization), with compilation-aware study-set
dedupe and a medium split — ~130 species from HH 1992a, Heffner et al. 2020, Koay et al. 1998,
and Veilleux & Kirk 2014. `SensoryData_compiled_check/` is the audit fixture (Route-B
registration reverted by owner). Heesy 2004 and Jung et al. 2022 are built and registered but not
yet wired into `sensory_compiled.R`; the R run is pending (no R in the build sandbox).

That makes the current repository name historically accurate but increasingly narrow. A
region-neutral name such as `Evo-Cortex-Trait-Data` is worth considering after the region tags and
per-region coverage audit exist; renaming first would only move the ambiguity.

## Immediate scope actions

1. Tag variables by region of interest. *(open — `variable_catalog.csv` still has no
   region-of-interest column as of 2026-09-02)*
2. Scout entorhinal / hippocampal-formation volumetrics deliberately.
3. Reconcile trait coverage against the approximately 25 sequenced species, by region.
4. ~~Decide the sensory-data merge route~~ **DONE 2026-08-31** — `__merging_sensory` built,
   percepts as their own measure class (see above).
5. Revisit the repository name after steps 1–3.

## Registry-to-public-TSV naming contract

`__ReadMe.xlsx` is not merely a bibliography. Its `Sheet1` table is the naming registry that links a
source citation and table number to the stable names used by source folders, reader scripts, and
public TSVs. This extends the convention established by
[`r03ert0/comparative-data`](https://github.com/r03ert0/comparative-data): a public table is a TSV
whose filename begins with an encoded DOI. The upstream instructions point contributors to Eric
Meyer's [URL Decoder/Encoder](https://meyerweb.com/eric/tools/dencoder/). The workbook adds an
`_ItemNumber` suffix so several tables from one DOI remain distinct.

The naming chain in `Sheet1` is:

| columns | role |
|---|---|
| A–D | curator-entered citation, same-author/year sequence, DOI or alternate identifier, and item number |
| E–I | parsed citation components and the human-readable publication stem |
| J | encoded DOI or alternate identifier |
| K | `Item name`, used by many R readers to find a registry row |
| L | `Item encoded`, the public filename stem (`<encoded identifier>_<item number>`) |
| M | exact check that `L.tsv` occurs in `AUTO_Public_TSV_FileList` |

`AUTO_Public_TSV_FileList` is generated by `_tools/file_list.R`; it must never be edited by hand.
It is a one-way inventory of `__Public/comparative-data/*.tsv`, not a second naming authority. The
registry remains authoritative; the generated sheet and column M are checks against files on disk.

### Formula and filename audit (2026-08-15; status notes updated 2026-09-02)

*(The registry has since grown to 380 data rows — counts below are the 2026-08-15 state.)*

The core design is sound. All 304 populated data rows have formulas in every derived column E–M, there are no
duplicate values in `Item encoded` (L), and independently recomputed E–L values agree with the
intended chain. The following exceptions need curator attention:

1. **One ambiguous internal `Item name` — RESOLVED by 2026-09-02:** the two Young et al. 2013
   papers now carry distinct sequence values in B (blank vs `b`), producing
   `Young_etal_2013_Table1` (10.3389/fncir.2013.00030) and `Young_etal_2013_b_Table1`
   (10.1073/pnas.1318894110). Each name spans two registry rows — that is the legitimate
   multi-row "#n" convention, not the old ambiguity.
2. **Encoding is a representation, not another DOI:** J encodes `/`, `:`, `<`, and `>` for stable
   filenames. A generic URL encoder may encode additional characters, but the DOI Handbook permits
   several reserved characters—including semicolons—to remain literal in a DOI URL. The only
   current Dencoder differences are semicolons in three legacy Wiley DOI stems: rows 187, 210, and
   211. Their registry and disk names agree, so do **not** rename them; any serialization change must
   be coordinated with the fork/upstream consumers. Future DOI entry should still be checked for
   punctuation such as `?`, `#`, quotes, and percent signs that can alter URL parsing.
3. **The blank-item audit is resolved:** rows 24, 65, 190, 193, 194, 200, and 207 now carry the
   source items selected below, and Baron Table 32 was appended as row 298. Row 288 (Weaver 2005)
   remains intentionally blank and is marked `DOCUMENTED SKIP`: it has no new extractable table and
   reuses/derives from Weaver 2001 data already built in the repository. Keeping the citation and
   folder prevents duplicate future work; the blank D prevents it from masquerading as an export.
4. **Source capitalization is intentional:** D preserves the label and capitalization printed by
   the source (`TABLE 1`, `Table 1`, `TableI`, and so on). The formulas remove spaces and underscores
   but do not change case. This is a provenance rule, not an inconsistency. Public TSV names and
   registry values must match exactly; do not normalize or mass-rename them without an explicit,
   coordinated downstream migration.
5. **The Baron identifier is resolved:** row 24 and the new Table 32 row use the volume-specific
   `ISBN:9783764353704` (rather than the whole-set ISBN or OCLC; see the
   [volume/set metadata](https://agris.fao.org/search/en/providers/122535/records/65dde9f863b8185d9ca55c2a)).
   Existing registry convention remains DOI by default, ISBN for books, and OCLC as the fallback
   when no ISBN exists.
6. **The stale M-cache problem is resolved:** `_tools/file_list.R` now validates every populated
   E–M formula against the canonical row-relative family, fills only missing formulas, refreshes the
   deterministic E–M cached values, and requests a full Excel recalculation. New rows therefore do
   not depend on someone opening Excel before non-Excel readers see the correct filenames. The
   visible M header identifies both the generated sheet and its owning R script; the list itself is
   still derived only from the public directory.
7. **Two public files are not represented by an L value — RESOLVED by 2026-09-02:**
   `10.1371%2Fjournal.pbio.3000494_DNAonlyMCC.tsv` now has its registry row (Excel row 356,
   `Upham_etal_2019_DNAonlyMCC`; column M reads `notfound` only until the next `file_list.R`
   run), and the orphaned `NA.tsv` has been deleted from `__Public/comparative-data/`.

Rows 296–301 use the canonical row-2 E–M formula family as of 2026-08-15. Repeated row edits have
nevertheless split E–L into multiple shared-formula blocks per column. That fragmentation is
non-result maintenance, not a data error. The lower-risk way to keep
new rows correct is to make `_tools/file_list.R` validate and fill the canonical formula family
for every populated registry row. An Excel Table with calculated columns would auto-fill formulas
more naturally and could be protected while A–D and N–AM stay editable, but it is a structural
change that must first be tested against the R readers.

**Operational rule:** register or correct A–D, let E–L derive the names, generate the public TSV,
then run `_tools/file_list.R` and inspect M. Existing public filenames are API-like identifiers for
downstream datasets, so formula cleanup must not silently rename them.

“Wiley filenames” means the three TSV filenames derived from long, legacy Wiley SICI-form DOI
strings—not a separate naming system or a choice among several DOIs. Each article has the one long
DOI shown by Wiley. `%2F`, `%3A`, `%3C`, and `%3E` are percent-encoded representations of characters
inside that same DOI. The semicolon is part of each DOI ending (`;2-F`, `;2-L`, or `;2-I`), and the
registry and disk currently agree:

- `10.1002%2F1096-8644(200102)114%3A2%3C163%3A%3AAID-AJPA1016%3E3.0.CO;2-F_TABLE2.tsv`
- `10.1002%2F(SICI)1096-8644(199806)106%3A2%3C129%3A%3AAID-AJPA3%3E3.0.CO;2-L_TABLE2.tsv`
- `10.1002%2F1096-8644(200103)114%3A3%3C224%3A%3AAID-AJPA1022%3E3.0.CO;2-I_TABLE2.tsv`

### Registered targets from the blank-item audit (2026-08-15)

These choices favour primary measurements that add a new axis or useful taxonomic coverage and
avoid exporting the same values twice. Seven registered items were built on 2026-08-15; Medina is
the sole source-level blocker and Weaver is an intentional skip. A multi-table book receives one
registry row per exported table rather than one catch-all row.

| Excel row | source | best first public data | D suffix | status / rationale / constraint |
|---:|---|---|---|---|
| 24 and 298 | Baron, Stephan & Frahm 1996 | five fundamental brain-part volumes, then telencephalic components | `Table 10` and `Table 32` | **BUILT** — 272 species rows in each item; registered with volume-specific `ISBN:9783764353704`; two source-level Table 32 component-sum inconsistencies are retained and reported |
| 65 | Ebinger 1974 | individual wild- and domestic-sheep brain/region volumes | `Tables 3-4` | **BUILT** — 10 individuals; Tables 5–10 are percentages or summaries derived from these primary tables |
| 190 | Medina-González 2026 | AUI, limb posture, top speed, and locomotor habit; retain joint-level angles in the frozen source | `Data` | **HOLD** — adds quantitative posture and locomotor-performance traits across 182 mammals, but the source deposit is restricted |
| 193 | Navarrete et al. 2016 | technical/non-technical innovation subtype counts and life-history composite | `Data` | **BUILT** — 167 species; complements Reader 2011, but depends on its report records. Despite “rate” in the source headers, the deposit contains integer counts and no effort denominator, so no corrected rate was invented |
| 194 | Nguyen et al. 2020 (folder/registry: `Nguyen_etal_2019`, DOI 10.1002/cne.24823) | species × region × neuron-type dendritic and spine summary statistics | `Table 2` | **BUILT** — 49 felid region × neuron-type rows; extends Jacobs-style morphology across frontal cortex, M1, and V1 |
| 200 | Olkowicz et al. 2016 | complete region-level neuron/non-neuron counts and densities | `Dataset S1` | **BUILT / EXCLUDED FROM MAMMAL MERGE** — 28 avian species and all 75 source measurements; older `TableS1` scaffold aligned to the registered name; `Class = Aves` is explicit |
| 207 | Schleifenbaum 1973 | individual age/sex/body/brain data plus absolute region volumes | `Tables 1-2` | **BUILT** — 33 canids; Tables 1–2 are primary and Table 3 is relative composition derived from them |
| 288 | Weaver 2005 | no new public TSV; provenance/analysis check against Weaver 2001 Table A-15 | none — `DOCUMENTED SKIP` | retained in the registry/project to prevent duplicate work; the paper has no new raw table and only derived/reused quantitative content |

Source pointers for the recommendations: [Navarrete Dryad deposit](https://datadryad.org/dataset/doi%3A10.5061/dryad.dk10k),
[Nguyen article](https://onlinelibrary.wiley.com/doi/abs/10.1002/cne.24823), and
[Weaver open article](https://pmc.ncbi.nlm.nih.gov/articles/PMC553338/). The remaining target tables
were checked against the frozen source PDFs and READMEs in their repository folders.

---

# PART 2 — Candidate papers and active dataset builds

A literature scout (2026-07-31) for **new comparative data that would extend the existing merges**,
not a duplicate hunt. Every candidate was checked against the source list in `__ReadMe.xlsx`
(Sheet1) so none duplicates a registered item.

Scope reminder (see Part 3 and `_keys/species_reference.csv`): the dataset began with **primary
motor cortex (M1) evolution** and its correlates (dexterity, corticospinal tract, hand morphology,
brain-structure volumes, cell counts, cortical areas, gyrification, sleep, diet, metabolism,
vocal/behavioural traits) across ~215 mammal species (76 primates + the classic Stephan
Insectivora/Scandentia set + Rodentia, Carnivora, Chiroptera, Afrosoricida, etc.).

## Non-mammal policy (owner decision, 2026-08-12)

**Register them; don't compile them.** Non-mammal sources **keep their `__ReadMe.xlsx` rows** and may
be built to snapshot → CSV → public TSV like any other source. They are **excluded from the
compilations** (`__merging_*`) for now. Registry ≠ merge.

Two things this changes:

- It **decouples building from the resolver.** The older framing held non-mammals as "premature until
  the resolver is de-MDD'd" (Part 3, do-first step 4). That gate applies to **compiling**, not to
  building — so e.g. `Olkowicz_etal_2016` (birds) can be built and registered now; it just doesn't
  enter a merge. The de-MDD work stays a prerequisite for *ingestion*, not for shelf-stocking.
- It makes the current state **non-compliant**, and knowingly so — see below.

### ⚠️ Known violation: 43 birds are already in the compilations

Audited 2026-08-12. **Ruf & Geiser 2015** (*Daily torpor and hibernation in birds and mammals*) is
built and wired, and its **43 AVES** rows flowed straight through:

| output | birds | carrying | in the Shiny app? |
|---|---|---|---|
| `__merging_body_ecology/body_ecology_long.csv` | 43 | `Body_Mass` (Team `Ruf`, role secondary) | **yes** |
| `__ShinyApp/data/evom1_traits_long.csv` | 42 | `Torpor_type`, `Torpor_Tb_min_C`, `Torpor_bout_max_h` | **yes** |
| `__merging_sleep/sleep_long.csv` | 42 | sleep/torpor terms | no (`sleep_long` is not one of the seven tables `app.R` loads directly; sleep/torpor reaches the app via `evom1_traits_long`) |

8 avian orders — hummingbirds, swifts, nightjars, mousebirds, owls, a kingfisher, passerines,
pigeons. **They were never dropped by the resolver because these merges don't go through it**, and
**0 of the 43 appear in `_keys/species_reference.csv`** — so they are simultaneously *in the app* and
*invisible to the taxonomy backbone*. A "mammals only" filter built on `species_reference.csv` would
silently fail to exclude them.

Bringing this in line is a **merge-side filter**, not a data deletion: the `Ruf_Geiser_2015/` source
folder keeps all 213 rows (43 birds + 170 mammals) exactly as published; the compile scripts gate on
class. Not yet implemented — flagged here so the decision and the deviation are on the same page.

### Other non-mammal data held (registry-legal, correctly not compiled)

| source | non-mammal content | built? | in a merge? |
|---|---|---|---|
| `Chen_Wiens_2020` Suppl. Data 3 | 1,589 spp — 574 Aves, 508 Amphibia, 490 Lepidosauria, 16 Testudines, 1 Crocodylia | raw supplement TSV only | no |
| `Caves_etal_2018` Table S1 | 26 of 40 spp — birds, fish (incl. shark, ray), crocodile, turtle, frog, **and invertebrates**: octopus, scallop, shrimp, honeybee, *Drosophila*, ants, butterflies, dragonfly, cockroach, jumping spider | yes | no |
| `Fritsches_etal_2005` | 3 fish (swordfish, yellowfin + bigeye tuna) | yes | no |
| `Olkowicz_etal_2016` | 28 bird species | yes — `DatasetS1`, 81 output columns | no; shelf dataset, explicitly gated as `Class = Aves` |
| `Wilman_etal_2014` | only `MamFuncDat` registered; upstream `BirdFuncDat` not in the repo | n/a | n/a |

Note the Caves invertebrates: the repo's *holdings* already span five vertebrate classes plus
arthropods and molluscs. That is fine under this policy — it is the compilations that are mammal-only.

Original scouting branch: **`claude/evo-m1-trait-data-q50l6x`**.

## Build status and remaining queue (2026-08-15)

The original scout batch has complete source folders for the items below. Reader has now also been
turned into its trait workbook and wired into the behaviour merge; the earlier claim that no merge
script had been touched is obsolete.

| Item | Rows | Frozen source |
|---|---|---|
| `Capellini_etal_2008_sleep-data{Female,Male,Mixed}` | 40 / 89 / 54 records, 93 species | 3 database CSVs (digital-native) |
| `Reader_etal_2011_Data` | 238 species | Dryad CSV (digital-native) |
| `Liu_etal_2016_TableS1` | 137 specimens, 13 species | SI PDF → snapshot |
| `Jacobs_etal_2018_Table3` | 40 (20 species × 2 neuron classes) | printed table → snapshot |
| `Jacobs_etal_2018_Table5` | 53 (19 species × neuron types) | printed table → snapshot |
| `Heuer_etal_2019_Table1` | 34 species / 65 individuals | printed table → snapshot |
| `Heuer_etal_2019_S1` | 66 scanned specimens | journal supplement TSV (digital-native) |
| `Heuer_etal_2023_Data` | 56 species / 383 direct-measure observations | author GitHub release + eLife supplement |
| `Bortoff_Strick_1993_Table1` | 2 directly compared species | Bortoff & Strick 1993 tract-tracing evidence (curated table) |

**166 species-key rows** added to `_keys/Stephan/species_key.csv` under paper-scoped tokens
(`Capellini2008` 108, `Heuer2019` 33, `Jacobs2018` 20, `Reader2011` 4, `Liu2016` 1).

### Completed in the 2026-08-15 build pass

- **Blank-item audit:** built Baron Tables 10/32, Ebinger Tables 3–4, Navarrete Data, Nguyen Table
  2, Olkowicz Dataset S1, and Schleifenbaum Tables 1–2. Each build has a source-scoped R script,
  local CSV, variable definitions, README, and DOI/ISBN-coded public TSV. Olkowicz is shelf-stocked
  only; Medina remains restricted; Weaver remains a documented skip.
- **Registry/file-list audit:** registered the already-built Jacobs 2016, Johnson 2016, and Peruffo
  2019 cortical-layer TSVs on rows 299–301. The script-owned 260-file public inventory then had 258
  registry matches. *(2026-09-02: the public directory holds 300 TSVs and the registry 380 rows;
  `NA.tsv` is deleted, `DNAonlyMCC` is registered, and the current exceptions list lives in
  `_checks/registry_audit_20260902.md`.)*

- **Reader 2011:** confirmed the actual Dryad schema, rebuilt `innovation_reader.xlsx` (238
  species), and added raw report counts, reduced-count sensitivity measures, and research-effort
  denominators to `__merging_behaviour`. Report counts have explicit names and are not pooled with
  Heldstab's categorical tool-use variables.
- **Heuer 2023:** froze the version-of-record paper, supplement, author final table, component
  measurement tables, assembly script, and license; built the analysis CSV/public TSV and a
  dedicated 383-row `__merging_cerebellar_folding` table; exposed it in the Shiny app. It remains
  separate from Ashwell's PSA/ESA foliation index and from neocortical GI.
- **Corticospinal terminations:** built a conservative first release from the two species directly
  compared by Bortoff & Strick (1993). The grade is wired into behaviour. The binary
  `CM_monosynaptic` field is intentionally blank because light-microscopic terminal fields cannot
  prove a monosynaptic connection; the paper's softer inference is stored separately.

### Brain-structure-volume staging intake (2026-08-15)

The files in `____Brain_structure_volumes/` were reconciled against existing source folders and
`__ReadMe.xlsx`. Four papers were true loose-source gaps. They are now registered at workbook rows
335–338 so none can disappear merely because its eventual output belongs to a datatype other than
regional volume.

| Loose paper | Extractable target | Status | Build / merge decision |
|---|---|---|---|
| Reep, Finlay & Darlington 2007 | Table 1: 29 specimens × 11 regional volumes | **BUILT** — `Reep_etal_2007/` | Frozen snapshot, CSV, definitions, reader, and public TSV. Add to the volume merge as independent team `Reep`; preserve its one-side ×2 provenance. Reep's diencephalon excludes globus pallidus and its striatum includes it, so those two use definition-specific terms. Amygdala also overlaps paleocortex. |
| Campos & Welker 1976 | Table 1: capybara and guinea-pig brain subdivisions, cortical morphometry, cell density and cell number | **BUILT 2026-08-24** | Frozen 20-measure snapshot; separate volume, cortical-morphometry, and cell-count products plus a long public table. Both specimens and all printed factors retained; three source arithmetic discrepancies are flagged and tested. |
| Halley & Krubitzer 2019 | Figure 1: 39-species dorsal-thalamus versus neocortex synthesis | **DOCUMENTED SKIP 2026-08-24** | Source audit reconstructs all 39 points from data already held: 37 Stephan 1981 rows plus the two Campos 1976 rodents. No plot digitization/public TSV. The audit also records caption source and marmoset-label contradictions. |
| Armstrong 1979 | Tables 1-9: thalamic relay-nucleus volume, neuronal density/count, and perikaryal volume | **BUILT 2026-08-24** | Frozen 106-row transcription; separate volume, density/count, and perikaryal products plus a long public table. Specimen crosswalk links `Hylo.-h` and `Hylo.-s` as two hemispheres of one gibbon and identifies the three-brain human count estimate. |

The other staged files already have source folders and registry coverage, so no duplicate rows were
created: DeCasien & Higham 2019 (including `41559_2019_969_MOESM3_ESM.xlsx`), Frahm et al. 1997,
Sherwood et al. 2004, and Stephan et al. 1970, 1981, and 1988. Their copies in the staging folder
remain intake artifacts, not new measurement teams.

### Willemet 2012/2013 implications for this project

Willemet 2012 reanalysed 376 mammals with 12 regional volumes: 28 historical “insectivores”, 45
primates, 3 scandentians, 271 bats from the Stephan/Baron/Frahm group, and the 29 Reep mammals. It
does not publish a new independent measurement series. Its most important source lead is the large
bat block: this repository already holds the cited *Comparative Neurobiology in Chiroptera* book and
has built `Baron_etal_1996_Table10` (five fundamental brain parts) and
`Baron_etal_1996_Table32` (eight telencephalic components), each with 272 source rows. Those two
tables are the closest recoverable primary form of Willemet's bat data and are already registered and
public, but they are not yet wired into `__merging_volumes`. The 2026-08-15 audit found **zero**
Baron species or species × canonical-structure overlaps in the current core merge, so this is a new
Chiroptera block rather than a duplicate of currently wired Stephan rows. Wiring remains on
**HOLD** for seven historical taxon concepts and for explicit within-source averaging where
subspecies/source rows collapse to one species. Do not ingest Willemet's secondary slopes, PCA
loadings, or plot points as a new measurement team.

The papers also motivate cross-datatype joins rather than only more volumetry: taxon-specific
allometry and cerebrotype homogeneity; neuron/glia scaling; neurodevelopmental timing; cortical-area,
layering and gyrification differences; and ecological, life-history, cognitive and behavioural
correlates. The repository already has partial compatible coverage in the volume, cell-count,
body/ecology, sleep, behaviour, sensory and cortical-morphology products. New collection should
therefore target coverage gaps and within-species samples, not duplicate the secondary Willemet
figures.

### Remaining source build

1. **Medina-González 2026 is externally blocked.** Zenodo record `15425733` is published and
   describes seven supplementary files for 182 species, but its current API record is `restricted`
   and returns no downloadable files. The scaffold and reader stay in place. Do not fabricate its
   columns or request access on the owner's behalf; build it when the files are supplied or access
   is granted.
2. **Campos & Welker 1976 - complete 2026-08-24:** Table 1 is built as separate volume,
   cortical-morphometry, and cell-count products; the mixed units are not wired into one merge.
3. **Halley & Krubitzer 2019 - audited 2026-08-24:** all 39 Figure 1 points duplicate upstream
   primary tables already held, so the figure is a documented skip and is not digitized.
4. **Armstrong 1979 - complete 2026-08-24:** Tables 1-9 are built into specimen-aware,
   datatype-specific outputs with a specimen crosswalk and secondary comparison rows labeled.

### Remaining administration and wiring

- Registry rows for `Heuer_etal_2023_Data` and the CST compilation were added to `__ReadMe.xlsx` on
  2026-08-15, and the Shiny source manifest was rebuilt with both public tables.
- `Baron_etal_1996_Table10` and `Baron_etal_1996_Table32` are built and public. Their reproducible
  overlap/taxonomy audit is complete: 259 source concepts, zero current core overlap, and seven
  concepts on manual review. Standardized-term maps and merge wiring wait for those taxon decisions
  plus the required within-source species averaging. Together the tables supply the 272-row bat
  dataset most directly implicated by Willemet 2012.
- ~~Capellini sleep~~ is done — `__merging_sleep` is built and wired (its torpor/sleep terms reach
  the app through `evom1_traits_long`). The older scout batch still needs a targeted merge audit
  for **Liu hand measures and Jacobs regional M1 morphology** (grep 2026-09-02: neither appears in
  any `__merging_*/*.R`). Folder existence is not proof that merge wiring is complete.

## Curator decisions — READ FIRST

1. **⚠️ "Heuer et al. 2018" never existed — it was Navarrete 2018 misattributed.** There is no Heuer
   2018 volumetric-MRI paper. The paper titled *Primate Brain Anatomy: New Volumetric MRI
   Measurements for Neuroanatomical Studies* is **Navarrete, A. F., Blezer, E. L. A., Pagnotta, M.,
   de Viet, E. S. M., Todorov, O. S., Lindenfors, P., Laland, K. N., & Reader, S. M. (2018).** Brain
   Behav Evol **91(2):1–9**, DOI **10.1159/000488136**, PMID **29894995** (EndNote `[4443]`, PDF
   held). The fabricated citation grafted the *Heuer 2019* author list onto Navarrete's title and
   invented DOI `10.1159/000489791`. A 2026-07-31 note "reinstating Heuer 2018" was itself wrong and
   **inverted the owner's decision**, resurrecting an owner-excluded source under a clean name.
   **Scaffold deleted 2026-08-04** (`Heuer_etal_2018/` and
   `__merging_volumes/standardized_term_by_reference/Heuer_etal_2018_SupplementaryData_standardized_terms.csv`,
   whose nine "high-confidence" structure columns were guessed, never read from any SI). Verified
   clean: no row in `__ReadMe.xlsx`, no `__Public` TSV, no item in `volumes_compiled.R`. **Heuer et
   al. 2019 (neocortical folding) is a real, separate paper and is unaffected.**
2. **EXCLUDE Navarrete 2018 — identity pinned.** The owner's flag (values depart from expectations,
   inter-observer differences, first author unreachable) applies to the **2018 volumetric-MRI**
   paper, **not** the 2016 innovation dataset (candidate #3). Simon Reader co-authors both, which is
   why the two got tangled. Corroborating the flag: the **erratum** — Brain Behav Evol
   2018;**92(3-4):182–184**, DOI **10.1159/000496658**, PMID 30783037 — rewrites Table 1,
   re-attributes the 10 "scan donations" to the Great Ape Neuroscience Project (Sherwood & Hof) and
   K. A. Phillips, and corrects specimen descriptions. Some scans are ***in vivo*** (*Cebus
   apella*), and the GANP great apes plausibly overlap collections already in the merge. Both
   Navarrete papers stay out. **Open for the owner** (not blocking): whether the 2018 exclusion
   should be revisited using the **erratum-corrected** Table 1 — it is the largest pool of new
   primate species available to `__merging_volumes` (39 species, ~20 new). No action without an
   explicit decision.
3. **Technical innovation: IN, sourced from Simon Reader — not Navarrete.** Compile from Reader &
   Laland 2002 (PNAS) and its machine-readable extension Reader, Hager & Laland 2011 (Phil Trans;
   Dryad doi:10.5061/dryad.t0q94). See `Reader_etal_2011/Reader_etal_2011.README.md` and
   `____EvoM1_TraitTable/EvoM1_read_innovation_reader.R`.
4. **Cerebellar folding — ~~OUT OF SCOPE~~ → IN, low priority (owner decision, 2026-08-12).**
   *Original ruling 2026-07-31: out of scope, deferred to the repo owner because she is a co-author.
   That deferral is now resolved — the owner has decided to include it.* **Heuer et al. 2023**
   (eLife 12:e85907) is IN and was **built 2026-08-15** from the open author release. It now has a
   dedicated merge and appears in the Shiny app.
   - **Built and registered:** `Heuer_etal_2023/` contains the frozen evidence, canonical R
     builder, 56-species analysis/public tables, definitions, and README. Its `__ReadMe.xlsx` row
     exists (Excel row 138, `Heuer_etal_2023_Data`, public TSV matched in column M).
   - **⚠️ Do NOT combine with Ashwell 2020 — different method (owner, 2026-08-12).** `Ashwell__2020`
     does carry **`foliation_index`, `cb_ext_surface_esa_mm2`, `cb_pial_surface_psa_mm2` for 150
     species**, all populated and currently **dropped** (that folder's term map ingests only the
     `*_Vol.mm3` columns). It is tempting to read that as a ready-made backbone for Heuer 2023. **It
     is not.** Ashwell's foliation index is *pial surface ÷ external surface* (PSA/ESA), where the
     external surface is a **multi-sided convex polygon** enclosing the cerebellum — a different
     measurement procedure from Heuer 2023's. The two quantify the same *concept* and are **not
     interchangeable values**: keep them as separate `Measure`s, never pooled, never averaged.
     This is the third instance of the same rule in this file — cf. Zilles 2-D GI vs Heuer 2019 3-D
     folding (curator decision 5). Surfacing Ashwell's three dropped columns is still worth doing on
     its own merit, as its **own** Ashwell-method measure; it is not a head start on Heuer 2023.
     (The 2023 paper cites Ashwell only as a comparison, consistent with this.)
   - **⚠️ The Heuer-vs-Heuer comparison is blocked on the neocortical side, not the cerebellar one.**
     `Heuer_etal_2019/` holds only the *sample documentation* (Table 1 = 34 spp/65 individuals;
     S1 = 66 scans). Its actual folding metrics — absolute GI, folding length, wavelength, depth —
     live on **Zenodo doi:10.5281/zenodo.2538751**, unreachable at scaffolding time and still not in
     the repo. Until that is pulled there is nothing on the neocortical side to compare against.
   - **Keep three things apart** (unchanged from the original entry): cerebellar folding ≠
     cerebellum **volume** (Ashwell volumes, Smaers 2018, MacLeod 2003, Rilling & Insel, Matano
     nuclei, Bush & Allman); and ≠ **neocortical GI** (`__merging_gyrification` pools only the
     Zilles 2-D coronal-contour `GI`, 127 spp, one term). A cerebellar folding/surface slot is its
     own thing. Housing is still open — own merge vs housed-separately like Heuer 2019 — decide when
     it is built.
   - Data type: **histology**, so it does not inherit the MRI inter-observer concern that keeps
     Navarrete 2018 out.
5. **Gyrification: keep the two kinds completely separate, never merged.** Zilles-method 2-D GI stays
   in `__merging_gyrification`; Katja Heuer's 3-D MRI folding is useful but housed on its own and
   never combined with Zilles. Method difference verified (3-D convex-hull + folding
   length/wavelength/depth vs 2-D coronal contour). Documented in the GI merge README's exclusion
   note.

## Status of every candidate

| # | Candidate | Decision | Scaffold | Feeds |
|---|---|---|---|---|
| 1 | ~~Heuer et al. 2018 — MRI brain volumes~~ → **Navarrete et al. 2018** (39 primates, ~20 new) | ❌ **EXCLUDED** (misattribution retracted 2026-08-04; owner-flagged paper) | **deleted** | none |
| 2 | ~~Bardo~~ → **Liu et al. 2016** — hand manipulability (13 anthropoids) | IN (byline corrected 2026-08-04) | `Liu_etal_2016/` (+ reader `EvoM1_read_hand_liu.R`) | `__merging_behaviour` (hand morphology) |
| 3 | Navarrete et al. 2016 — innovation | ✅ **BUILT 2026-08-15** | `Navarrete_etal_2016/` | public shelf: technical/non-technical subtype counts + life-history composite; do not add its Reader-derived counts to Reader totals |
| 4 | Capellini et al. 2008 — mammalian sleep (REM %, daily sleep) | ✅ **BUILT + WIRED** (`__merging_sleep` built; terms reach the app via `evom1_traits_long`) | `Capellini_etal_2008/` (+ sleep standardized-term template) | `__merging_sleep` (extends beyond primate-only REM) |
| 5 | Heuer et al. 2019 — neocortical folding (34 primates, MRI) | IN, **separate** | `Heuer_etal_2019/` | **none** — housed separately, never pooled with Zilles GI |
| 6 | Cerebellar folding — **Heuer et al. 2023** (eLife 12:e85907) | ✅ **BUILT 2026-08-15** | `Heuer_etal_2023/` | dedicated `__merging_cerebellar_folding` + Shiny app; **never pooled with Ashwell 2020 foliation or neocortical GI** |
| 7 | Medina-González 2026 — limb excursion, 182 mammals | IN, **blocked: restricted source record** | `MedinaGonzalez__2026/` (+ reader scaffold) | `__merging_behaviour` after files become available |
| 8 | Corticospinal / CM termination extent | ✅ **BUILT 2026-08-15**, renamed to the house pattern + re-keyed to the article DOI same day | `Bortoff_Strick_1993/` (Table 1, curated) | behaviour (`CST_termination_grade` + cautious CM inference), team `Bortoff_Strick`, **primary** |
| 9 | ~~Betz cells (compile-from-lit)~~ → **Jacobs et al. 2018** — gigantopyramidal + M1 pyramidal morphology | IN, **snapshots built 2026-08-04** | `Jacobs_etal_2018/` (Tables 3 + 5) | `__merging_cellcounts` as **regional M1** sub-trait (never pooled with whole-cortex counts) |
| — | Reader lineage — technical innovation (2002 classic + 2011 Dryad) | ✅ **BUILT + WIRED 2026-08-15** | `Reader_etal_2011/` (+ `innovation_reader.xlsx`) | `__merging_behaviour` (report counts + effort variables) |

Each scaffold folder has a **README** (source citation + DOI, download/freeze steps, `__ReadMe.xlsx`
registration row, and the exact merge-wiring edits) and a `reference_tables/*_definitions.csv`.

---

## Tier 1 — strongest fits (M1-adjacent or directly extend a live merge)

### 1. ~~Heuer et al. 2018 — Primate Brain Anatomy~~ → **Navarrete et al. 2018** — ❌ EXCLUDED (owner-flagged; scaffold deleted 2026-08-04)

- **This candidate was a misattribution.** See curator decisions 1–2. This entry stands as a record
  of what was assessed and rejected — **do not re-scaffold it.**
- **Citation:** Navarrete, A. F., Blezer, E. L. A., Pagnotta, M., de Viet, E. S. M., Todorov, O. S.,
  Lindenfors, P., Laland, K. N., & Reader, S. M. (2018). *Primate Brain Anatomy: New Volumetric MRI
  Measurements for Neuroanatomical Studies.* **Brain Behav Evol 91(2):1–9**, DOI
  **10.1159/000488136**, PMID **29894995**. EndNote `[4443]` (PDF held).
  **Erratum:** Brain Behav Evol 2018;**92(3-4):182–184**, DOI **10.1159/000496658**, PMID 30783037.
- **What it would have contributed (for the record):** 16 brain areas across **39 primate species**,
  ~20 new to the volumetric literature, from 46 Netherlands Institute of Neuroscience Primate Brain
  Bank brains at 9.4 T plus 7 scans from other sources; partial measurements on 8 further brains.
  This is the largest single pool of *new primate species* available to the volumes merge, which is
  why the exclusion is worth revisiting deliberately rather than by accident.
- **Why excluded:** owner flag — values depart from expectations, inter-observer differences, first
  author unreachable. The erratum independently rewrites Table 1 and the specimen attributions.
- **If the exclusion is ever lifted:** it is **MRI**, so it must enter as its own team, never pooled
  with the histological Stephan/Baron/Frahm collection; work from the **erratum-corrected** Table 1,
  not the original; and run a specimen crosswalk first — the "other sources" scans are GANP great
  apes (Sherwood & Hof) and *in vivo* *Cebus apella* (K. A. Phillips), which may already be
  represented in the merge through other collections.

### 2. ~~Bardo et al. 2016~~ → **Liu et al. 2016** — Manipulative potential from hand proportions (`Liu_etal_2016/`)

- **⚠️ AUTHOR MISATTRIBUTION CORRECTED 2026-08-04.** "Bardo et al. 2016" does not exist. The paper
  carrying this title is by **Liu, Xiong & Hu** — a biomechanics/robotics group at Huazhong
  University of Science and Technology. Ameline Bardo is a real hand-evolution researcher (several
  EndNote records) but is **not** an author on it. Same failure mode as the "Heuer 2018" case: real
  title, real journal, real DOI, invented byline. Folder renamed `Bardo_etal_2016/` →
  `Liu_etal_2016/`; reader renamed `EvoM1_read_hand_bardo.R` → `EvoM1_read_hand_liu.R`.
- **Citation:** Liu, M.-J., Xiong, C.-H., & Hu, D. (2016). *Assessing the manipulative potentials of
  monkeys, apes and humans from hand proportions: implications for hand evolution.* **Proc Biol Sci
  283(1843):20161923.** DOI **10.1098/rspb.2016.1923** · PMID **27903877** · EndNote `[9631]`.
- **Merge:** `__merging_behaviour` (hand morphology / manipulation), beside `dexterity_baker`.
- **Contributes:** modelled manipulative potential for **13 anthropoid species** — SI Table S1 gives
  per-**specimen** rows (museum accession numbers) with thumb and forefinger segment proportions plus
  two derived measures: **`WS`** (workspace) and **`GMI`** (global manipulation index, the headline
  measure). Column headers confirmed from the SI PDF, held in the folder
  (`rspb20161923_si_001.pdf`).
- **Specimen count = 137**, per the paper's own Methods (13 species). An earlier sweep of the
  extracted Table S1 found ~133 rows and flagged it as a possible undercount — that was the
  undercount; 137 is correct. (The "137 hand samples" figure had originally come from the fabricated
  block, so it was treated as unverified until the Methods confirmed it independently.)
- **Overlap/notes:** the citation-dependency with Baker is **harder than first recorded**. Liu's raw
  morphometrics are *taken from* Feix, Kivell, Pouydebat & Dollar (2015) — the same source Baker 2025
  `peak_workspace` descends from. So the two share their **raw input**, not merely a construct
  family: **never average**, resolve to one source. `Data role = secondary` (derived re-analysis);
  Feix 2015 is the upstream primary and is **not yet in the repo**. See
  `__merging_behaviour/README__merging.md` VocalRepertoire/Dexterity precedent.
- **Also in the SI:** Figure S6 infers manipulative potential for **fossil** hands (*H.
  neanderthalensis*, Ohalo II H2, *H. naledi*) — keep decomposable, never pooled into an extant mean.

### 3. Navarrete, Reader, Street, Whalen & Laland 2016 — Innovation & technical intelligence — ✅ BUILT 2026-08-15

**Decision revised and implemented 2026-08-15.** Reader remains the upstream source for the report
records, but it does not make Navarrete's technical/non-technical reclassification redundant. The
167-species Dryad CSV is frozen in `Navarrete_etal_2016/`; the source-scoped build emits the
registered `Data` CSV/public TSV and definitions. The source contains integer counts despite
headers that say “rate (nr)” and provides no research-effort denominator, so the build labels them
as counts and does not invent corrected rates. Record the dependency and never add these subtype
counts to Reader totals.

- **Merge:** `__merging_behaviour` as distinct `TechnicalInnovation` / `NonTechnicalInnovation`
  measures, or as an ecology trait beside Heldstab manipulation complexity.
- **Contributes:** species scores for **technical innovation, non-technical innovation, and technical
  innovation including extractive foraging** across **167 primate species** — a strong behavioural
  correlate of manual/M1 specialisation, with a clean archived dataset.
- **Citation:** Navarrete A.F., Reader S.M., Street S.E., Whalen A., Laland K.N. (2016). *The
  coevolution of innovation and technical intelligence in primates.* Phil Trans R Soc B
  371(1690):20150186. DOI **10.1098/rstb.2015.0186**. Data: Dryad **10.5061/dryad.dk10k**.
- **Overlap/notes:** conceptually related to Heldstab 2016 extractive-foraging / manipulation
  complexity (already secondary) — keep as its own `Measure`, do not pool. Reader, Hager & Laland
  2011 (Phil Trans R Soc B 366:1017, DOI 10.1098/rstb.2010.0342) is the predecessor innovation
  dataset if a second source is wanted for the dependency check.
- **Source correction:** Navarrete's own archived file has **no tactical-deception column**, no
  reduced-count fields, and no research-effort denominator. Those fields belong to Reader's
  separate archive. Navarrete supplies the reclassified integer report counts plus a partly missing
  life-history composite.

### 4. Mammalian sleep architecture — **Capellini et al. 2008** built; Lesku et al. 2006 is the related alternative

- **Merge:** `__merging_sleep` — extends it **beyond the current primate-only REM coverage**. Maps
  directly onto the two existing standardized terms `REM_sleep_pct` and `Sleep_h_day`; the merge
  README explicitly says it was "built as a standing home… more sources are expected."
- **Built:** **Capellini et al. 2008**, *Phylogenetic analysis of the ecology and evolution of
  mammalian sleep*, Evolution; PMC2674385 — a curated, corrected re-compilation of the same
  underlying data, and the cleaner primary if only one is added. Folder `Capellini_etal_2008/`;
  3 database CSVs (Female / Male / Mixed), 40 / 89 / 54 records, 93 species.
- **The alternative, not built:** Lesku J.A., Roth T.C., Amlaner C.J., Lima S.L. (2006). *A
  phylogenetic analysis of sleep architecture in mammals: the integration of anatomy, physiology, and
  ecology.* Am Nat 168(4):441–453. DOI **10.1086/506973** — REM and NREM/SWS for a broad mammalian
  sample (path-analysis dataset, ~50+ species).
- **Overlap/notes:** both Lesku and Herculano-Houzel's daily-sleep column descend from the older
  mammalian-sleep compilations (Zepelin, Savage & West, Campbell & Tobler) → **the
  citation-dependency rule bites here: resolve, don't average.**

---

## Tier 2 — good fits, secondary

### 5. Heuer et al. 2019 — Evolution of neocortical folding (34 primate MRI) — ✅ scaffolded (`Heuer_etal_2019/`)

- **Merge:** **none — housed separately in `Heuer_etal_2019/`** (like Mota FI). **Role: secondary.**
- **Citation:** Heuer K., Gulban O. F., Bazin P.-L., Osoianu A., Valabregue R., Santin M., Herbin M.,
  & Toro R. (2019). *Evolution of neocortical folding: a phylogenetic comparative analysis of MRI
  from 34 primate species.* **Cortex 118:275–291.** DOI **10.1016/j.cortex.2019.04.011** ·
  PMID **31235272**. Confirmed real 2026-08-04; **not in EndNote**.
- **Contributes:** 3-D MRI folding metrics across **34 primate species / 65 individuals** — absolute
  (convex-hull) gyrification index, total folding length, average fold wavelength (~12 mm), average
  fold depth, cerebral + convex-hull surface.
- **⚠️ The folding measures are NOT in the journal supplement.** `mmc1.zip` holds only the scan-QC
  table. The gyrification index / folding length / wavelength / depth / surface areas exist only on
  **Zenodo doi:10.5281/zenodo.2538751**, still unreachable at the time of writing. What is built is
  the **sample documentation** (Table 1 = 34 species / 65 individuals; S1 = 66 scanned specimens).
  See `Heuer_etal_2019/Heuer_etal_2019.README.md`.
- **Decision (method-confirmed 2026-07-31): do NOT pool into the Zilles-GI merge.** Heuer uses a
  **3-D** surface-vs-convex-hull method + folding length/wavelength/depth; the GI merge pools only
  the **2-D** Zilles coronal-contour GI. Different construct/method (the paper presents its metrics
  as an alternative to Zilles) — even Heuer's "GI" is the 3-D convex-hull variant, not
  interchangeable. Surface-area columns would belong with `__merging_cortical_areas` if ever merged,
  not the GI merge.
- This remains separate from **cerebellar** folding (#6), which is now built in its own merge.

### 6. Cerebellar folding in mammals (eLife 2023) — ✅ BUILT 2026-08-15

- **Status:** built from the open author GitHub release and eLife supplement: 56 species and 383
  non-missing direct-measure observations. The dedicated merge and Shiny dataset are live and the
  registry row exists (2026-09-02: Excel row 138, public TSV matched).
- **Merge:** a new cerebellar folding/surface slot (regional; **not** pooled with neocortical GI, and
  **not** with cerebellum volume). **Role: primary** for cerebellar folding.
- **Contributes:** comparative **cerebellar folding** (folial structure — the paper's result is that
  individual fold size ≈ constant across species and larger cerebella are disproportionately folded)
  from an open collection of **histological data from 56 mammalian species** (manually segmented
  cerebrum + cerebellum). This is a **regional folding/surface** trait, **not** a whole-cerebellum
  volume — so it does **not** duplicate the well-covered cerebellum-*volume* sources (Ashwell 2020,
  Smaers 2018, MacLeod 2003, Rilling & Insel 1998, Matano nuclei, Bush & Allman), and it is a
  different construct from the neocortical-GI merge (Zilles-method neocortex only).
- **Natural home:** the dedicated `__merging_cerebellar_folding` slot. Ashwell 2020's
  (`10.1016/j.zool.2020.125753`) already-in-repo but currently **dropped** columns —
  `foliation_index`, `cb_ext_surface_esa_mm2`, `cb_pial_surface_psa_mm2` (its standardized-term map
  ingests only the `*_Vol.mm3` volume columns, so the foliation/surface columns never reach a merge).
  Those Ashwell values remain a separate future measure, not another Heuer team to pool.
- **Data type note:** unlike the dropped MRI work, this is **histology** ("MRI does not provide the
  resolution required… histological data can"), so it does not share the MRI inter-observer issue.
- **Citation:** Heuer K., Traut N., de Sousa A.A., Valk S.L., Clavel J., Toro R. (2023). *Diversity
  and evolution of cerebellar folding in mammals.* eLife 12:e85907. DOI **10.7554/eLife.85907**.
  First author is Heuer; **A. A. de Sousa (repo owner) is a co-author** → left for the owner to judge.

### 7. Medina-González 2026 — joint angular excursion in terrestrial mammals (`MedinaGonzalez__2026/`)

- **Merge:** `__merging_behaviour` (locomotion/gait), beside Granatosky and Wimberly.
- **Citation:** Medina-González, P. (2026). *Joint Angular Excursions and Angular Range Utilization
  During Stance-Phase Locomotion in Terrestrial Mammals: A Comparative Morphofunctional Data Set.*
  J Exp Zool A. DOI **10.1002/jez.70069**. Data: **Zenodo doi:10.5281/zenodo.15425733**
  ("Supplementary Data … Joint Angular Excursion and Efficiency in Terrestrial Mammals", published
  2025-05-15; FONDECYT 11231111).
  *(The initial scouting entry filed this under "Grabowski" — that byline was never verified and is
  wrong; the Zenodo record and the linked paper are Medina-González. Corrected when the folder was
  built.)*
- **Contributes:** stance-phase joint angular excursions and an **angular utilization index (AUI %)**
  for **182 terrestrial mammal species across 15 orders**, each classified by limb posture, body
  mass, top speed and locomotor habit — the widest-coverage locomotion source scouted, broadening
  gait/locomotion far beyond the current primate-leaning set.
- **Current blocker (verified 2026-08-15):** Zenodo publishes the record metadata but marks access
  `restricted` and returns no files. Confirm the license and real column schema only after the seven
  files are supplied; per-joint angles stay frozen and only defensible species-level summaries feed
  the trait table.

---

## Tier 3 — M1-core traits worth compiling by hand

The most *on-theme* (M1 output pathway) but existing only as scattered per-species values, so each is
a **hand-built `_snapshot`** per
`_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md` (printed/scanned route), not a
journal download.

### 8. Corticomotoneuronal / corticospinal termination extent across primates — ✅ BUILT 2026-08-15

- **Merge:** `__merging_behaviour`. Extends the Heffner–Masterton CST axis with the
  *termination-pattern* evidence (ventral-horn / direct CM synapse extent) that Heffner's dexterity
  scale is a proxy for.
- **First release:** Bortoff & Strick 1993's direct comparison of *Cebus apella* / *Sapajus apella*
  and *Saimiri sciureus*. Exact pages and figures are carried in the snapshot. Broad review-only
  clade statements were not assigned to species, and Nudo & Masterton's origin data were not
  miscast as termination data.

### 9. ~~Betz-cell compile-from-literature~~ → **Jacobs et al. 2018** (`Jacobs_etal_2018/`) — ✅ SNAPSHOTS BUILT

- **⚠️ SCAFFOLD DISSOLVED 2026-08-04.** `Betz_cells_M1/` was a *compile-from-literature* placeholder
  premised on "no single comparative table of per-species Betz counts exists". **That premise was
  wrong** — Jacobs et al. 2018 is exactly that table, and it was in EndNote with a PDF all along. The
  scaffold had also invented a source identity (`Betz_cells_M1_compilation`, `Team = Betz_compilation`)
  for a paper with a real author, year and DOI. Folder replaced by `Jacobs_etal_2018/`.
  *(Note: "Betz cell" as **anatomy** is real and retained — Jacobs uses "gigantopyramidal" across
  mammals and reserves "Betz" for primates. What did not exist was a **source** called "Betz".)*
- **Citation:** Jacobs, B., Garcia, M. E., Shea-Shumsky, N. B., … Sherwood, C. C., & Manger, P. R.
  (2018). *Comparative morphology of gigantopyramidal neurons in primary motor cortex across
  mammals.* **J Comp Neurol 526(3):496–536.** DOI **10.1002/cne.24349** · PMID **29088505** ·
  EndNote `[4950]`.
- **Merge:** `__merging_cellcounts` as a **regional M1 sub-trait** (never pooled with whole-cortex
  neuron counts), beside `Young_etal_2013_Table1` — checked, no species or measure collision with
  Young.
- **Built:** two snapshots, both verified against the paper's own statistics.
  **Table 3** = unbiased stereology, 20 species (11 carnivore + 9 primate), layer V pyramidal **and**
  gigantopyramidal soma length/area/volume + body and brain mass. **Table 5** = Golgi morphology,
  19 species / 7 orders × 3 neuron types (superficial layer III, deep layer V, gigantopyramidal),
  617 traced neurons: soma size and depth, dendritic volume, length, segment length, segment count,
  spine number, spine density.
- **Nolan et al. 2024** (*Betz cells of the primary motor cortex*, J Comp Neurol 532(1):e25567,
  DOI 10.1002/cne.25567, PMID 38289193) is the **review entry point only** — no per-species table,
  and it misquotes Jacobs' feliform mean soma size as 2874 μm² where the paper says **2,847**. Never
  a row's `Source`.
- **Remaining primaries** (audit in `Jacobs_etal_2018/README.md`): Sherwood et al. 2003 ✅ EndNote
  `[5508]` (23 primates + 2 non-primates); Rivara et al. 2003 ❌ absent (the whole human row);
  Lassek & Wheatley 1945 ✅ `[6767]` (chimpanzee area-4 enumeration).

---

## Premature — non-mammal compilation (Part 3, do-first step 4)

*Superseded in part by the non-mammal policy above (2026-08-12): these may now be **built and
registered** whenever convenient — it is **compilation** that is gated, not shelf-stocking.*

Large isotropic-fractionator neuron-count datasets exist for **squamates + turtles (107 species)**
and **birds (111 species)**, produced with the same method as the Herculano-Houzel mammal set. They
are the obvious first non-mammal additions to `__merging_cellcounts` **if and when the compilations
open to non-mammals**, **but** `resolve_taxonomy.R` is MDD-gated and will silently drop non-mammals,
and `species_reference.csv` has no `Class` column. Ingest only after Part 3 do-first steps 1 & 4
(add `Class`; add a non-mammal resolver path). Flagged here so they are not lost.

---

## To finish any source (do on the OneDrive copy, with R)

Per `_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md`, and spelled out in
each folder's README:

1. **Download the frozen source** (DOIs/Zenodo/Dryad IDs are in each README).
2. **Confirm exact column headers** — never build against a guessed schema. Reader, Navarrete, and
   Olkowicz were confirmed on 2026-08-15; Medina-González remains unknown because the record is
   restricted. Audit any remaining Capellini derivation markers before merge wiring.
3. Write the **DOI-coded public TSV** into `__Public/comparative-data/`.
4. **Register** in `__ReadMe.xlsx` (Item name → Item encoded) with the row given in the README.
5. **Wire the merge** (add to the `item_name` vector / add `grab()`+`META`+`TEAM` / add
   standardized-term rows) — only after the source file exists, or the merge errors.
6. Re-run the merge's compile script and check species resolve and no double-counting.

## Current order of work (refreshed 2026-09-02; audit in `_checks/registry_audit_20260902.md`)

1. **Registry hygiene — refreshed 2026-09-02 (`_checks/registry_audit_20260902.md` is now the
   canonical list).** Done since 08-31: the corrupted `Young_etal_2013_xml:…` key repaired; the
   four blank-Item-number keys (`Shultz_Dunbar_2010_` etc.) filled — zero trailing-`_` keys
   remain; Heesy 2004 registry row added; Heffner_Heffner_1992 renamed → `_1992_a` (the
   snapshot's one "missing" key is this rename, not a lost row). Fixed 2026-09-02 (owner-approved):
   the VanEssen row 357 artifact author removed → row now derives `VanEssen_Drury_1997_Table1`
   (matches the built products); Jung 2022 products + public TSV renamed to `Reportedresults`
   (registry casing kept — D preserves the printed label); Todorov products renamed to
   `Todorov_etal_2019_rspb20191712si001.*` (registry key kept; the frozen supplement's inner
   `dimorphdata.csv` member untouched; `specimen_source_registry.csv` pointer updated).
   Remaining one-sitting Excel queue: register Hutsler ×4 + `Stephan_etal_1987_Table2` +
   Deaner 2007 (+ stubs Reader_Laland 2002 / Weaver 2005 / Changizi_He 2005 when adopted);
   **de Sousa 2022 double extension** (`acuityblind.csv` as Item number → `…acuityblind.csv.tsv`
   on disk); the Olkowicz figshare/PNAS key decision (`_checks/script_repairs_20260829.md`);
   remove or purpose `data_intermediate/`.
2. **Sensory intake — the active program.** `__merging_sensory` built 2026-08-31 (percepts only,
   compilation-aware study-set dedupe; ~130 species from HH1992a, Heffner 2020, Koay 1998,
   Veilleux & Kirk 2014; `SensoryData_compiled_check/` is the audit fixture, Route-B registration
   reverted by owner). Newly built source folders **Heesy 2004** (snapshot 2nd review pending)
   and **Jung et al. 2022** (3 items) are registered but **not yet wired** into
   `sensory_compiled.R`; Kirk & Kay 2004 rows are registered — wire or record the skip. Snapshot
   handling follows the 09-02 format doctrine (evidence not product; born-digital = copy-rename
   untouched; Barbeito tsv-twin cleanup still pending).
3. **Cell-counts + surface-areas intake — surfaces DONE 2026-08-25.** All five TODO sources were
   already built; the gap was wiring. `__merging_cortical_areas` now carries Collins 2016 (chimp
   cortex/V1/V2; M1 superseded by Young — same specimen), Mota 2015 own columns and Mota 2019
   AT/AE/T, with new terms (exposed surface, thickness, MHH folding index, V1/V2 regional), a
   Mota-lineage supersede (2019 > 2015), Mota printed-name alias repairs, and an AG=total-surface
   correction to the 2015 definitions (the old "exposed" reading would have double-folded via
   AG×FI). Outputs regenerated offline (329 long rows, 66 species) — **re-run
   `standardized_term.R` + `cortical_areas_compiled.R` in RStudio to confirm.** Remaining from this
   intake: the regional CELL-COUNT reshape (Kaas V1/M1 densities, HH 2013 mouse areas) — design
   decision recorded in `__merging_cellcounts/WIRING_into_cellcounts.md` (owner choice: wide
   per-area columns vs a separate regional product); Mota 2019 VG/VW volumes HELD for a
   `__merging_volumes` overlap audit.
   **Surface-area candidates from the Project Kaskan review sheet (2026-08-25).** The restricted
   Kaskan compilation (`…-restricted/unpublished_data/____Unpublished__ProjectKaskan/Project
   Kaskan remeasuring/M1 surface.xlsx`) quotes published values whose primaries have no public
   source folder yet — build from the primaries (verify citations in EndNote first):
   ~~**Demirci et al. 2023**~~ — **BUILT 2026-08-31** (`Demirci_etal_2023_Fig.1`: SA+V for all 12
   species from the full-res Fig. 1; both-hemisphere values, halve SA at wiring; R rerun pending);
   ~~**Van Essen & Drury 1997**~~ — **BUILT 2026-08-31** (`VanEssen_Drury_1997_Table1`: neocortex +
   5 lobes + sulcal/gyral L/R + text V1 L/R; per-hemisphere as published; R rerun + row rename
   pending; still chase its cited Filiminoff 1932 / Stensaas 1974 human V1 primaries);
   ~~**Chaplin et al. 2013**~~ — **BUILT 2026-08-31** (`Chaplin_etal_2013_ResultsText`: the
   candidate is the J Neurosci differential-expansion paper, doi 10.1523/JNEUROSCI.2909-13.2013 —
   owner repointed the row + swapped the PDF same day; marmoset 963 / capuchin 6,796 / macaque
   11,876 mm², n=1 each, mid-thickness not pial, macaque = reused F99 atlas specimen; set the
   row's Item number to `ResultsText`, then R rerun. The *other* Chaplin 2013 — marmoset V1
   retinotopy, doi 10.1002/cne.23215, V1 totals 193/214 mm² — is out of the queue unless its V1
   values are wanted as a separate row).
   ~~Smaers 2017 Brodmann-1909
   revisit~~ — **DONE 2026-08-25**: `Smaers_etal_2017_TableS1part2` wired as a SECONDARY
   (Brodmann-1909-via-Smaers; supersedable by a future 1909 primary build) with three new regional
   terms, and `Brodmann__1913_Table1` wired as a primary whole-cortex source (34 taxa, one human
   row: Europäer Durchschnitt). Additivity audit: regions sum exactly to the 1913 totals
   (marmoset/gibbon/chimp); the mandrill other-association cell is excluded (+10,000 misprint in
   one of the two sources). Merge now 400 long rows / 82 wide species. **Finlay 2006 is
   whole-paper FLAGGED (owner, 2026-08-25):** the source-attribution audit
   (`Finlay_etal_2006/Finlay_etal_2006_Table6.1_source_attribution.csv`) found its traced
   surfaces systematically low for small mammals/marsupials and several rows without a citable
   primary; all its rows are held out of the wide table
   (`flagged_pending_ProjectKaskan_check`) and the registry row carries the flag — verify against
   the Project Kaskan remeasuring dataset once built, then unflag per column. The sheet's own
   remeasured values are unpublished and stay restricted (image-analysis pass planned there;
   see `M1_surface_STATUS_and_PLAN_20260825.md` in the Kaskan folder). Registry rows
   `Changizi__2001_Figure3` + `Finlay_etal_2006_Table6.1` ("Species -- wait for Project Kaskan")
   wait on the Kaskan area-name/species tables.
4. **R-side runs on next RStudio session:** `_tools/file_list.R` (AUTO TSV column is badly
   stale — 43 orphaned public TSVs and 16 FINISHED-but-notfound rows, all the 08-31→09-02
   builds), `_checks/registry_snapshot.R` (snapshot is 7 rows stale), the
   `standardized_term.R` + `cortical_areas_compiled.R` confirmation rerun, the
   `sensory_compiled.R` run, and the pending Completed100 sample-trees run.
5. Audit and, where still absent, wire **Liu hand and Jacobs M1 morphology**, plus the built
   surface sources **Demirci 2023 / Van Essen & Drury 1997 / Chaplin 2013** into
   `__merging_cortical_areas` (grep 2026-09-02: none of the five appears in any
   `__merging_*/*.R` yet; Capellini sleep is done — `__merging_sleep` built and wired).
6. **Freeze-source pass** on the three invariant-1 folders with derived data but no frozen
   source: `Fu_etal_2013`, `Rilling_Insel_1998`, `deJager_etal_2022` (Halley & Krubitzer is the
   documented skip and stays as-is).
7. **Baron 1996 bat block** wiring into volumes — blocked on the seven historical taxon-concept
   decisions plus within-source averaging.
8. Build Medina-González immediately after its restricted files become available.
9. Decide on a class-aware destination before compiling Olkowicz or any other avian shelf
   dataset (`____Spinal_cord_etc/` is the next staging folder to watch as a merge-group
   candidate).
10. Implement the region tags and per-region coverage audit from Part 1.

*(The original scouting list put "Heuer 2018 volumes" first as the biggest new-species yield. That
candidate is the excluded Navarrete paper — see curator decisions 1–2. Nothing to do there without
an explicit owner decision.)*

## Lesson recorded (2026-08-04) — verify a citation before naming a folder

**Three of the scouting session's scaffolds were named from citations assembled from memory, and all
three were wrong in the author field while carrying a real title, real journal and (usually) a real
PMID.**

| Scaffolded as | Actually | Consequence |
|---|---|---|
| `Heuer_etal_2018/` | **Navarrete et al. 2018**, Brain Behav Evol 91(2):1–9, EndNote `[4443]` | *Inverted a curator decision* — reinstated an owner-excluded source under a clean name. **Deleted.** |
| `Bardo_etal_2016/` | **Liu, Xiong & Hu 2016**, Proc Biol Sci 283(1843):20161923, EndNote `[9631]` | Wrong byline; also understated the Feix 2015 citation-dependency. **Renamed `Liu_etal_2016/`.** |
| `Betz_cells_M1/` | **Jacobs et al. 2018**, J Comp Neurol 526(3):496–536, EndNote `[4950]` | Invented a "no such table exists" premise and a fake source identity for a real paper already held with a PDF. **Replaced by `Jacobs_etal_2018/`; snapshots now built.** |

All three papers were **already in the EndNote library**, two of them with PDFs. A single
`_tools/endnote.py find` on the title would have caught each one. (A fourth, candidate #7, was filed
under the wrong first author — "Grabowski" — and corrected to Medina-González only when the folder
was built.)

**Rule:** check every scouted citation against EndNote or the publisher record **before** naming a
folder after it — the folder name propagates into definitions CSVs, standardized-term templates,
`__ReadMe.xlsx` rows, reader scripts and merge wiring, so an unverified name spreads. Search three
ways (author, journal+year, title) before concluding a paper is present or absent. And where a note
claims a previous decision was mistaken, re-derive the fact from a source — a confident retraction
can itself be the error.

## Environment limits during the scouting session (why it was scaffolds, not data)

- Org network policy denied publishers / Dryad / Zenodo at the egress proxy (`connect_rejected 403`).
- No R runtime — merges could not be run or verified.
- `__ReadMe.xlsx` (binary master) was **not** edited from that environment on purpose; each README
  gives the row to add so the owner keeps control of the master file.
- DOIs marked *(verify)* in the original scouting notes were read from search metadata, not from the
  publisher page (Karger/Zenodo block automated fetches) — confirm before registering.

## Commit trail (scouting session)

```
9f1e150 Gyrification README: document Heuer 2019 as kept completely separate from Zilles GI
f9b570d Heuer 2019: lock 'house separately' — method differs from Zilles GI (verified)
495365a Scaffold reinstated Heuer candidates (volumes + neocortical folding)
c9bf7e6 Scouting report: reinstate Heuer (mis-attribution), flag Navarrete
d971285 Scouting report: mark cerebellar folding (#6) out of scope
7378e7f Scouting report: correct cerebellar-folding (#6) entry
89aaeba Scaffold remaining kept candidates: Bardo, Capellini, Medina-Gonzalez, CST, Betz
4bb347e Start Reader technical-innovation compilation
e6d6c88 Add scouting report: candidate papers for dataset expansion
```

---
---

# PART 3 — Backbone traits & taxonomic growth (wide-coverage vs deep-but-narrow)

Design note for the concern: *some variables (body mass, body BMR, brain size, base ecological vars)
exist for LOADS of species — potentially beyond mammals — while the core M1/brain traits are
deep-but-narrow. How do we handle this, especially in the Shiny app, so the dataset can grow into
non-mammals later?*

## What the repo already does right

- **Storage is long, not wide.** `compiled` in `__ShinyApp/app.R` is a union of three long tables
  (`volumes_long.csv`, `cellcounts_long.csv`, `evom1_traits_long.csv`) in
  `Species × Variable × Value × Source` shape. Ragged coverage costs nothing here — a species with
  only body mass just has fewer rows. This is the right foundation; keep it.
- **Concept-pooling already exists.** `_keys/variable_canonical.csv` pools duplicated backbone
  variables into one house concept + unit with conversion factors — e.g. `Body_Mass.g`,
  `Body_weight`, `Body weight kg` → **Body_Mass (g)**; three `Brain_Mass` variants → **Brain_Mass
  (g)**. It even has a `concept` column already.
- **The plot handles ragged coverage.** `p_data()` does a `complete.cases` intersection, so X-vs-Y
  only plots species with both variables. No NA explosion at plot time.
- **A taxonomy backbone exists in `_keys`.** `species_reference.csv` carries `Order_resolved`,
  `Family_resolved`, `ncbi_taxid`, per-source membership flags, and a `taxonomy_source`;
  `resolve_taxonomy.R` resolves via NCBI + MDD.

## The four real gaps

1. **The taxonomy backbone is mammal-only and isn't wired into the app.** `species_reference.csv` has
   **no `Class` column** (everything is implicitly Mammalia; only Order/Family), and
   `resolve_taxonomy.R` resolves against **MDD = Mammal Diversity Database**, which will silently
   drop any non-mammal. The app never reads `species_reference.csv` at all — `sp_choices` is just the
   flat unique species list.
2. **Backbone traits are physically duplicated across merges.** Body/brain mass is stored
   independently in every merge:
   - `Body_Mass.g`: volumes_long **99**, cellcounts_long **80**, traits **102**
   - `Brain_Mass`: volumes **97**, cellcounts **70**, traits **154**

   Pooling papers over this at display time, but re-deriving the same value in each merge, is where
   drift enters — already flagged (the `Brain_Mass.mg` audit rows / mg-vs-g mislabel note in
   `variable_canonical.csv`).
3. **No taxonomic filter axis in the app.** Species and variables are the only filters, so you can't
   say "mammals only" or "primates only" independent of trait choice.
4. **Only body & brain mass are pooled.** BMR (`metabolic_rate`, present in the trait table and in
   `__merging_cerebral_metabolic_rate`) and diet/ecology aren't in `variable_canonical.csv` yet, so
   they don't pool and won't carry a scope tag.

## Concrete changes

### 1. Give traits a taxonomic *scope*, and give species a *Class* — two independent axes

The core fix is to stop letting taxonomic scope and trait scope move together.

**a. Extend `_keys/variable_canonical.csv` into the single trait catalogue.** Add two columns beside
the existing `concept`:

| new column | values | purpose |
|---|---|---|
| `trait_scope` | `pan-vertebrate` / `mammal-wide` / `primate-core` | declares how far a trait legitimately extends |
| `role` | `backbone` / `specialist` | backbone = wide-coverage reference traits |

Mark `Body_Mass`, `Brain_Mass`, `BMR`, diet, activity-period as `role=backbone,
trait_scope=pan-vertebrate`; nuclei volumes, cortical areas, gyrification, CST, ILAs as
`role=specialist, trait_scope=primate-core` (or `mammal-wide`). This is a metadata-only change — no
data moves.

**b. Add `Class` (and optionally a higher `Clade`) to `species_reference.csv`.** `Order_resolved` is
already there; a `Class` column is what lets the app filter Mammalia vs non-mammals. Backfill
existing rows to `Mammalia`.

**c. Fix the resolver before any non-mammal is added.** `resolve_taxonomy.R` is MDD-gated; add a
non-mammal path (NCBI is already wired; GBIF backbone is the usual choice) selected by `Class`, so
adding a bird doesn't fail taxonomy resolution silently.

### 2. Wire the backbone into the app (mirrors how `variable_canonical` is already loaded)

- In `build_data.R`, copy `_keys/species_reference.csv` into `data/` (exactly like the existing
  `variable_canonical.csv` fallback copy at lines 37–39).
- In `app.R load_compiled()`, left-join `compiled` to it on `Species` to attach
  `Class / Order_resolved / Family_resolved`, and join the trait catalogue to attach
  `role / trait_scope` per variable.
- Add a **taxonomic filter** (Class → Order → Family) as a *separate* sidebar control from the
  variable filter.
- Make the variable dropdown **availability-driven**: once species/taxa are chosen, restrict variable
  choices to those with data for the selection, and show a coverage badge (n species per variable) so
  users see `Body_Mass` = thousands vs a nucleus = tens. The plot already intersects; extend the same
  "who actually has this" logic to the UI.

Result: pan-vertebrate body-mass-vs-brain-size shows thousands of species; primate nuclei show the
deep-but-narrow set — same app, no schema change.

### 3. Decide backbone storage: pool-at-display (now) vs one backbone merge (for growth)

- **Option A — keep per-merge duplication, rely on pooling.** Zero new infrastructure, works today.
  Cost: every new merge re-derives body/brain mass; drift risk is real and already showing (the mg/g
  audit rows).
- **Option B — extract one `__backbone_traits` merge (recommended for growth).** A single
  authoritative, team-aware, pan-taxonomic long table for `Body_Mass`, `Brain_Mass`, adult `BMR`,
  diet, activity. Other merges *reference* it instead of re-storing. Point the backbone concepts in
  `variable_canonical.csv` at it (`match_dataset = "Backbone"`). This is the natural entry point for
  non-mammals and kills the whole class of re-derivation bugs. Also finish pooling BMR + diet into
  the canonical map while doing this.

### 4. What "add non-mammals later" then looks like

Purely additive: append rows to the backbone long table + rows to `species_reference.csv` (with
`Class`). Nothing in the specialist merges changes — they stay absent for those species, and the
app's availability logic simply doesn't offer them when non-mammals are in scope. No sparse wide
matrix is ever materialised.

## Do-first checklist

1. Add `Class` to `species_reference.csv`; backfill `Mammalia`.
2. Add `role` + `trait_scope` to `variable_canonical.csv`; tag backbone vs specialist; add the
   missing BMR + diet concepts.
3. Join both into the app; add the taxonomic filter + availability-driven variable list.
4. De-MDD the resolver (add a `Class`-gated non-mammal path) **before** ingesting any non-mammal —
   this is the gate on the squamate/turtle and bird neuron-count datasets in Part 2.
5. (When ready) extract `__backbone_traits` as the single authoritative wide-coverage source;
   repoint the canonical map at it.

Steps 1–3 are metadata + app wiring (low risk, high payoff). Step 5 is the larger refactor and can
wait until you actually add the first non-mammal.
