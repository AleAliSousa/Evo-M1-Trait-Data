# Scouting & scoping — dataset expansion and taxonomic growth

*Consolidated 2026-08-06 from three files now deleted: `HANDOFF_scouting_20260731.md`,
`SCOUTING_candidate_papers_20260731.md`, `SCOPING_backbone_traits_and_taxonomy.md`. Content is
unchanged apart from collapsing statements that appeared in two files into one, and correcting
items the later files had already superseded.*

**Part 1** — candidate papers scouted to extend the merges: status, curator decisions, per-candidate
detail, and what each unfinished source still needs.
**Part 2** — the design note on wide-coverage "backbone" traits and growing the dataset beyond
mammals.

---
---

# PART 1 — Candidate papers for dataset expansion

A literature scout (2026-07-31) for **new comparative data that would extend the existing merges**,
not a duplicate hunt. Every candidate was checked against the source list in `__ReadMe.xlsx`
(Sheet1) so none duplicates a registered item.

Scope reminder (see Part 2 and `_keys/species_reference.csv`): the dataset is currently
**mammal-only** (~215 species; 76 primates + the classic Stephan Insectivora/Scandentia set +
Rodentia, Carnivora, Chiroptera, Afrosoricida, etc.), centred on **primary motor cortex (M1)
evolution** and its correlates (dexterity, corticospinal tract, hand morphology, brain-structure
volumes, cell counts, cortical areas, gyrification, sleep, diet, metabolism, vocal/behavioural
traits). Non-mammal sources are held as **premature** until the resolver is de-MDD'd (Part 2,
do-first step 4).

Original scouting branch: **`claude/evo-m1-trait-data-q50l6x`**.

## Build status

**All scaffolds are now finished source folders** (2026-08-05): frozen source → `.R` → analysis CSV →
DOI-coded public TSV → `definitions.csv` → README → `__ReadMe.xlsx` row. Nine registry items.

| Item | Rows | Frozen source |
|---|---|---|
| `Capellini_etal_2008_sleep-data{Female,Male,Mixed}` | 40 / 89 / 54 records, 93 species | 3 database CSVs (digital-native) |
| `Reader_etal_2011_Data` | 238 species | Dryad CSV (digital-native) |
| `Liu_etal_2016_TableS1` | 137 specimens, 13 species | SI PDF → snapshot |
| `Jacobs_etal_2018_Table3` | 40 (20 species × 2 neuron classes) | printed table → snapshot |
| `Jacobs_etal_2018_Table5` | 53 (19 species × neuron types) | printed table → snapshot |
| `Heuer_etal_2019_Table1` | 34 species / 65 individuals | printed table → snapshot |
| `Heuer_etal_2019_S1` | 66 scanned specimens | journal supplement TSV (digital-native) |

**166 species-key rows** added to `_keys/Stephan/species_key.csv` under paper-scoped tokens
(`Capellini2008` 108, `Heuer2019` 33, `Jacobs2018` 20, `Reader2011` 4, `Liu2016` 1).

**No merge script has been touched.** `__merging_sleep`, `__merging_behaviour` and
`__merging_cellcounts` wiring is still outstanding; each folder's README says exactly what that
wiring needs. Current build is unaffected.

**The `.R` scripts are canonical but have not been run** (no R in the authoring environment). Their
CSV/TSV were written by an offline mirror — re-run each `.R` in RStudio to confirm. These nine
items are batch 1 in `_checks/BUILD_STATUS_20260805.md`, which carries the current
registry-coverage count.

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
4. **Cerebellar folding — OUT OF SCOPE (2026-07-31).** Decided by the repo owner, who is a co-author
   on the paper. Not scaffolded; not to be revisited unless scope changes. (For the record: that
   paper used Ashwell 2020 data only as a comparison, and Ashwell is already in the repo via the
   volumes merge, so nothing to reconcile.)
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
| 3 | Navarrete et al. 2016 — innovation | ❌ **EXCLUDED** (topic covered via Reader instead) | none | — |
| 4 | Capellini et al. 2008 — mammalian sleep (REM %, daily sleep) | IN | `Capellini_etal_2008/` (+ sleep standardized-term template) | `__merging_sleep` (extends beyond primate-only REM) |
| 5 | Heuer et al. 2019 — neocortical folding (34 primates, MRI) | IN, **separate** | `Heuer_etal_2019/` | **none** — housed separately, never pooled with Zilles GI |
| 6 | Cerebellar folding (eLife 2023) | 🚫 **OUT OF SCOPE** | none | — |
| 7 | Medina-González 2026 — limb excursion, 182 mammals | IN | `MedinaGonzalez_2026/` (+ reader `EvoM1_read_gait_excursion_medina.R`) | `__merging_behaviour` (locomotion) |
| 8 | Corticospinal / CM termination extent | IN | `Corticospinal_terminations/` (compile-from-lit) | behaviour (new `CST_termination_grade`) |
| 9 | ~~Betz cells (compile-from-lit)~~ → **Jacobs et al. 2018** — gigantopyramidal + M1 pyramidal morphology | IN, **snapshots built 2026-08-04** | `Jacobs_etal_2018/` (Tables 3 + 5) | `__merging_cellcounts` as **regional M1** sub-trait (never pooled with whole-cortex counts) |
| — | Reader lineage — technical innovation (2002 classic + 2011 Dryad) | IN | `Reader_etal_2011/` (+ reader `EvoM1_read_innovation_reader.R`) | `__merging_behaviour` (new `Innovation` measure) |

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

### 3. Navarrete, Reader, Street, Whalen & Laland 2016 — Innovation & technical intelligence — ❌ EXCLUDED

Topic covered instead via Reader — see `Reader_etal_2011/`.

- **Merge (had it been used):** `__merging_behaviour` (a new `TechnicalInnovation` /
  `ExtractiveForaging` measure), or as an ecology trait beside Heldstab manipulation complexity.
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
- **Correction found while building the Reader scaffold:** the archived Dryad file has **no
  tactical-deception column** and ships **no pre-corrected values** — raw counts, "reduced" counts
  and a research-effort column instead.

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
- Note this is a separate question from **cerebellar** folding (#6), which is out of scope.

### 6. Cerebellar folding in mammals (eLife 2023) — 🚫 OUT OF SCOPE (owner decision, 2026-07-31; owner is co-author)

- **Merge (had it been used):** cortical-areas / a new cerebellar-surface slot (regional, not pooled
  with neocortical GI). **Role: primary** for cerebellar folding.
- **Contributes:** comparative **cerebellar folding** (folial structure — the paper's result is that
  individual fold size ≈ constant across species and larger cerebella are disproportionately folded)
  from an open collection of **histological data from 56 mammalian species** (manually segmented
  cerebrum + cerebellum). This is a **regional folding/surface** trait, **not** a whole-cerebellum
  volume — so it does **not** duplicate the well-covered cerebellum-*volume* sources (Ashwell 2020,
  Smaers 2018, MacLeod 2003, Rilling & Insel 1998, Matano nuclei, Bush & Allman), and it is a
  different construct from the neocortical-GI merge (Zilles-method neocortex only).
- **Not used anywhere in the repo:** eLife 85907 is not registered in `__ReadMe.xlsx` and is not
  cited by any source or review (checked 2026-07-31). The only eLife items present are Smaers 2018
  (35696, cerebellum *volumes*) and Caspar 2022 (77875, handedness).
- **Natural home + an already-half-present pairing, if scope ever changes:** a **cerebellar
  folding/surface slot** that would also finally surface **Ashwell 2020**'s
  (`10.1016/j.zool.2020.125753`) already-in-repo but currently **dropped** columns —
  `foliation_index`, `cb_ext_surface_esa_mm2`, `cb_pial_surface_psa_mm2` (its standardized-term map
  ingests only the `*_Vol.mm3` volume columns, so the foliation/surface columns never reach a merge).
  Kept separate from cerebellum-volume and from neocortical GI.
- **Data type note:** unlike the dropped MRI work, this is **histology** ("MRI does not provide the
  resolution required… histological data can"), so it does not share the MRI inter-observer issue.
- **Citation:** Heuer K., Traut N., de Sousa A.A., Valk S.L., Clavel J., Toro R. (2023). *Diversity
  and evolution of cerebellar folding in mammals.* eLife 12:e85907. DOI **10.7554/eLife.85907**.
  First author is Heuer; **A. A. de Sousa (repo owner) is a co-author** → left for the owner to judge.

### 7. Medina-González 2026 — joint angular excursion in terrestrial mammals (`MedinaGonzalez_2026/`)

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
- **To confirm before ingesting:** the Zenodo license, and which columns map to
  `Duty_Factor`/`Gait`/`Foot_Posture`. Per-joint angles stay in the frozen source; only the
  species-level summaries are exposed to the trait table.

---

## Tier 3 — M1-core traits worth compiling by hand

The most *on-theme* (M1 output pathway) but existing only as scattered per-species values, so each is
a **hand-built `_snapshot`** per `__HOWTO_build_a_dataset_file.md` (printed/scanned route), not a
journal download.

### 8. Corticomotoneuronal / corticospinal termination extent across primates

- **Merge:** `dexterity_corticospinal` family. Extends the Heffner–Masterton CST axis with the
  *termination-pattern* evidence (ventral-horn / direct CM synapse extent) that Heffner's dexterity
  scale is a proxy for.
- **Sources:** Bortoff & Strick 1993 (*Corticospinal terminations in two New-World primates…*,
  J Neurosci 13(12):5105); Lemon & Griffiths 2005 (*Comparative anatomy and physiology of the
  corticospinal system*); Nudo & Masterton corticospinal series. Values are per-species text/figures
  → snapshot each.

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

## Premature — non-mammal (hold until the resolver is de-MDD'd; Part 2, do-first step 4)

Large isotropic-fractionator neuron-count datasets exist for **squamates + turtles (107 species)**
and **birds (111 species)**, produced with the same method as the Herculano-Houzel mammal set. They
are the obvious first non-mammal additions to `__merging_cellcounts`, **but** `resolve_taxonomy.R` is
MDD-gated and will silently drop non-mammals, and `species_reference.csv` has no `Class` column. Add
these only after Part 2 do-first steps 1 & 4 (add `Class`; add a non-mammal resolver path). Flagged
here so they are not lost.

---

## To finish any source (do on the OneDrive copy, with R)

Per `__HOWTO_build_a_dataset_file.md`, and spelled out in each folder's README:

1. **Download the frozen source** (DOIs/Zenodo/Dryad IDs are in each README).
2. **Confirm exact column headers** — readers/definitions carry `TODO(curator)` / `confirm header`
   markers where real names/values go. Still flagged in-file: **Reader** column names,
   **Medina-González** summary columns, **Capellini** sleep-column headers + REM% derivation.
3. Write the **DOI-coded public TSV** into `__Public/comparative-data/`.
4. **Register** in `__ReadMe.xlsx` (Item name → Item encoded) with the row given in the README.
5. **Wire the merge** (add to the `item_name` vector / add `grab()`+`META`+`TEAM` / add
   standardized-term rows) — only after the source file exists, or the merge errors.
6. Re-run the merge's compile script and check species resolve and no double-counting.

## Suggested order of work

1. **Capellini sleep** (#4) — the sleep merge was explicitly built to grow and currently stops at
   primates for REM.
2. **Liu hand** (#2) — extends the behaviour merge on-theme.
3. **Reader innovation** — the Dryad file is digital-native; needs the column confirmation above.
4. Tier 2/3 as capacity allows.

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

# PART 2 — Backbone traits & taxonomic growth (wide-coverage vs deep-but-narrow)

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
   this is the gate on the squamate/turtle and bird neuron-count datasets in Part 1.
5. (When ready) extract `__backbone_traits` as the single authoritative wide-coverage source;
   repoint the canonical map at it.

Steps 1–3 are metadata + app wiring (low risk, high payoff). Step 5 is the larger refactor and can
wait until you actually add the first non-mammal.
