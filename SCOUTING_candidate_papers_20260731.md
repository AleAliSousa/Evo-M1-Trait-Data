# Candidate papers to add to Evo-M1-Trait-Data (scouting, 2026-07-31)

A literature scout for **new comparative data that would extend the existing merges**, not a
duplicate hunt. Each candidate is mapped onto the merge it would feed, with what it contributes,
its species count, overlap with what is already ingested, and a suggested `Data role`.

Scope reminder (from `SCOPING_backbone_traits_and_taxonomy.md` and `_keys/species_reference.csv`):
the dataset is currently **mammal-only** (~215 species; 76 primates + the classic Stephan
Insectivora/Scandentia set + Rodentia, Carnivora, Chiroptera, Afrosoricida, etc.), centred on
**primary motor cortex (M1) evolution** and its correlates (dexterity, corticospinal tract, hand
morphology, brain-structure volumes, cell counts, cortical areas, gyrification, sleep, diet,
metabolism, vocal/behavioural traits). Non-mammal sources are listed separately as **premature**
until the resolver is de-MDD'd (scoping step 4).

Every candidate below was checked against the source list in `__ReadMe.xlsx` (Sheet1) so none
duplicate an item already registered. DOIs marked *(verify)* were read from search metadata, not
from the publisher page (Karger/Zenodo block automated fetches) — confirm before registering.

---

## Curator decisions (2026-07-31) — READ FIRST

- **⚠️ RESOLVED 2026-08-04 — "Heuer et al. 2018" never existed; it was Navarrete 2018 misattributed.**
  The 2026-07-31 "CORRECTION" below was itself wrong, and inverted the owner's decision. There is no
  Heuer 2018 volumetric-MRI paper. The paper titled *Primate Brain Anatomy: New Volumetric MRI
  Measurements for Neuroanatomical Studies* is:
  **Navarrete, A. F., Blezer, E. L. A., Pagnotta, M., de Viet, E. S. M., Todorov, O. S., Lindenfors, P.,
  Laland, K. N., & Reader, S. M. (2018).** Brain Behav Evol **91(2):1–9**, DOI **10.1159/000488136**,
  PMID **29894995**. (EndNote `[4443]`, PDF held.) The fabricated citation had grafted the *Heuer 2019*
  author list onto Navarrete's title and invented DOI `10.1159/000489791`.
  **Consequence:** the "reinstatement" resurrected the owner-excluded source under a clean name and
  scaffolded it for `__merging_volumes`. **Scaffold deleted 2026-08-04** (`Heuer_etal_2018/` and
  `__merging_volumes/standardized_term_by_reference/Heuer_etal_2018_SupplementaryData_standardized_terms.csv`,
  whose nine "high-confidence" structure columns were guessed, never read from the SI). Verified
  clean: no row in `__ReadMe.xlsx`, no `__Public` TSV, no item in `volumes_compiled.R` — nothing
  reached the merge. **Heuer et al. 2019 (#5, neocortical folding) is a real, separate paper and is
  unaffected.**
- **EXCLUDE Navarrete — identity now pinned (#1-as-catalogued and #3 are different papers).** The
  owner's flag (values depart from expectations, inter-observer differences, first author unreachable)
  applies to the **2018 volumetric-MRI** paper above. Do not ingest. The open question "which
  Navarrete?" is **answered**: it is Navarrete et al. **2018** (Brain Behav Evol), *not* the 2016
  innovation dataset catalogued as #3. Simon Reader co-authors both, which is why the two got tangled.
  Corroborating the flag: the **erratum** — Brain Behav Evol 2018;**92(3-4):182–184**, DOI
  **10.1159/000496658**, PMID 30783037 — rewrites Table 1, re-attributes the 10 "scan donations" to
  the Great Ape Neuroscience Project (Sherwood & Hof) and K. A. Phillips, and corrects specimen
  descriptions. Some scans are ***in vivo*** (*Cebus apella*), and the GANP great apes plausibly
  overlap collections already in the merge — so this source would need specimen-crosswalk work even
  if the exclusion were lifted. **Ingestion question left open for the owner; nothing to be done
  without an explicit decision.**
- **Technical innovation: IN, sourced from Reader (not from the flagged Navarrete source).** Compile
  from Simon Reader's classic dataset (Reader & Laland 2002, PNAS) and its machine-readable extension
  (Reader, Hager & Laland 2011, Phil Trans; Dryad doi:10.5061/dryad.t0q94). Scaffolding is in place —
  see `Reader_etal_2011/Reader_etal_2011.README.md` and `____EvoM1_TraitTable/EvoM1_read_innovation_reader.R`.
  **Blocked in-session:** the org network policy denied Dryad at the egress proxy and there is no R
  runtime here, so the actual per-species values must be downloaded and the reader run **locally**.
- **Heuer MRI — only #5 (folding) exists. #1 was the misattributed Navarrete paper (see above).**
  `Heuer_etal_2019/` only (neocortical folding — **housed separately, decided; NOT pooled into the
  Zilles-GI merge**). Confirmed real 2026-08-04: Heuer K., Gulban O. F., Bazin P.-L., Osoianu A.,
  Valabregue R., Santin M., Herbin M., & Toro R. (2019). *Evolution of neocortical folding: A
  phylogenetic comparative analysis of MRI from 34 primate species.* **Cortex 118:275–291**,
  PMID **31235272** — 34 species / 65 individuals, as described below. Not in EndNote.
  The separate decision is method-confirmed (2026-07-31): Heuer 2019 uses a **3-D** surface-vs-convex-hull
  gyrification index + folding length/wavelength/depth, whereas the GI merge pools only the **2-D**
  Zilles coronal-contour GI — different construct/method, presented in the paper as an alternative to
  Zilles. Both Heuer folders need the frozen source pulled locally + R to wire on; merge scripts left
  untouched. Note #5 (neocortical folding) is a separate question from cerebellar folding, which
  remains out of scope (below).
- **Cerebellar folding (#6): OUT OF SCOPE (2026-07-31).** Decided by the repo owner, who is a
  co-author on the paper: cerebellar folding is outside the dataset's scope right now. Not scaffolded,
  not to be revisited unless scope changes. (For the record: that paper used some Ashwell 2020 data
  only as a comparison; Ashwell is already in the repo via the volumes merge, so nothing to reconcile.)
- **Keep IN — all scaffolded (2026-07-31):** Liu hand proportions (#2 → `Liu_etal_2016/`, renamed from
  `Bardo_etal_2016/` 2026-08-04 — misattributed byline),
  Capellini/Lesku sleep (#4 → `Capellini_etal_2008/`), limb-excursion locomotion (#7 →
  `MedinaGonzalez_2026/`), corticospinal terminations (#8 → `Corticospinal_terminations/`), gigantopyramidal
  / Betz neurons (#9 → `Jacobs_etal_2018/`, replacing the dissolved `Betz_cells_M1/` compile-from-literature
  scaffold 2026-08-04 — **snapshots now built**). Each folder has a README (source, download/freeze, register, and exact
  merge-wiring steps) + a `reference_tables/*_definitions.csv`; the two behaviour sources and the
  locomotion source also have reader scripts in `____EvoM1_TraitTable/`, and the sleep source has a
  `standardized_term_by_reference/` template. **Every scaffold still needs its source data pulled
  locally** (same network-policy limitation) **and R to run/verify the merges** — the merge scripts
  were left untouched so the current build is unaffected until each is wired on.

---

## Tier 1 — strongest fits (M1-adjacent or directly extend a live merge)

### 1. ~~Heuer et al. 2018 — Primate Brain Anatomy~~ → **Navarrete et al. 2018** — ❌ EXCLUDED (owner-flagged; scaffold deleted 2026-08-04)
- **This candidate was a misattribution.** No Heuer 2018 volumetric paper exists; see the resolution
  note in *Curator decisions* above. The real paper is owner-excluded, so this entry stands as a
  record of what was assessed and rejected — **do not re-scaffold it.**
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
  not the original; and run a specimen crosswalk first — the "other sources" scans are GANP great apes
  (Sherwood & Hof) and *in vivo* *Cebus apella* (K. A. Phillips), which may already be represented in
  the merge through other collections.

### 2. ~~Bardo et al. 2016~~ → **Liu et al. 2016** — Manipulative potential from hand proportions (`Liu_etal_2016/`)
- **⚠️ AUTHOR MISATTRIBUTION CORRECTED 2026-08-04.** "Bardo et al. 2016" does not exist. The paper
  carrying this title is by **Liu, Xiong & Hu** — a biomechanics/robotics group at Huazhong University
  of Science and Technology. Ameline Bardo is a real hand-evolution researcher (several EndNote
  records) but is **not** an author on it. Same failure mode as the "Heuer 2018" case: real title, real
  journal, real DOI, invented byline. Folder renamed `Bardo_etal_2016/` → `Liu_etal_2016/`; reader
  renamed `EvoM1_read_hand_bardo.R` → `EvoM1_read_hand_liu.R`.
- **Citation:** Liu, M.-J., Xiong, C.-H., & Hu, D. (2016). *Assessing the manipulative potentials of
  monkeys, apes and humans from hand proportions: implications for hand evolution.* **Proc Biol Sci
  283(1843):20161923.** DOI **10.1098/rspb.2016.1923** · PMID **27903877** · EndNote `[9631]`.
- **Merge:** `__merging_behaviour` (hand morphology / manipulation), beside `dexterity_baker`.
- **Contributes:** modelled manipulative potential for **13 anthropoid species** — SI Table S1 gives
  per-**specimen** rows (museum accession numbers) with thumb and forefinger segment proportions plus
  two derived measures: **`WS`** (workspace) and **`GMI`** (global manipulation index, the headline
  measure). Column headers confirmed from the SI PDF, now held in the folder
  (`rspb20161923_si_001.pdf`). **The "137 hand samples" figure was part of the fabricated block and is
  unverified** — a sweep of the extracted Table S1 finds ~133 specimen rows; count by hand.
- **Overlap/notes:** the citation-dependency with Baker is **harder than first recorded**. Liu's raw
  morphometrics are *taken from* Feix, Kivell, Pouydebat & Dollar (2015) — the same source Baker 2025
  `peak_workspace` descends from. So the two share their **raw input**, not merely a construct family:
  **never average**, resolve to one source. `Data role = secondary` (derived re-analysis); Feix 2015 is
  the upstream primary and is **not yet in the repo**. See
  `__merging_behaviour/README__merging.md` VocalRepertoire/Dexterity precedent.
- **Also in the SI:** Figure S6 infers manipulative potential for **fossil** hands (*H.
  neanderthalensis*, Ohalo II H2, *H. naledi*) — keep decomposable, never pooled into an extant mean.

### 3. Navarrete, Reader, Street, Whalen & Laland 2016 — Innovation & technical intelligence  — ❌ EXCLUDED (owner-flagged; topic covered instead via Reader, see `Reader_etal_2011/`)
- **Merge:** `__merging_behaviour` (a new `TechnicalInnovation` / `ExtractiveForaging` measure), or
  as an ecology trait beside Heldstab manipulation complexity.
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

### 4. Lesku, Roth, Amlaner & Lima 2006 — Sleep architecture in mammals
- **Merge:** `__merging_sleep` — extends it **beyond the current primate-only REM coverage**.
- **Contributes:** **REM and NREM/SWS** sleep for a broad mammalian sample (path-analysis dataset,
  ~50+ species). Maps directly onto the two existing standardized terms `REM_sleep_pct` and
  `Sleep_h_day`; the merge README explicitly says it was "built as a standing home… more sources are
  expected."
- **Citation:** Lesku J.A., Roth T.C., Amlaner C.J., Lima S.L. (2006). *A phylogenetic analysis of
  sleep architecture in mammals: the integration of anatomy, physiology, and ecology.* Am Nat
  168(4):441–453. DOI **10.1086/506973**.
- **Overlap/notes:** both this and Herculano-Houzel's daily-sleep column descend from the older
  mammalian-sleep compilations (Zepelin, Savage & West, Campbell & Tobler) → **citation-dependency
  rule bites here**: resolve, don't average. **Capellini et al. 2008** (*Phylogenetic analysis of the
  ecology and evolution of mammalian sleep*, Evolution; PMC2674385) is a curated, corrected
  re-compilation of the same underlying data and is the cleaner primary if only one is added.

---

## Tier 2 — good fits, secondary

### 5. Heuer et al. 2019 — Evolution of neocortical folding (34 primate MRI)  — ✅ REINSTATED & scaffolded (`Heuer_etal_2019/`)
- **Merge:** **none — housed separately in `Heuer_etal_2019/`** (like Mota FI). **Role: secondary.**
- **Contributes:** 3-D MRI folding metrics across **34 primate species / 65 individuals** — absolute
  (convex-hull) gyrification index, total folding length, average fold wavelength (~12 mm), average
  fold depth, cerebral + convex-hull surface.
- **Decision (method-confirmed 2026-07-31): do NOT pool into the Zilles-GI merge.** Heuer uses a
  **3-D** surface-vs-convex-hull method + folding length/wavelength/depth; the GI merge pools only the
  **2-D** Zilles coronal-contour GI. Different construct/method (the paper presents its metrics as an
  alternative to Zilles) — even Heuer's "GI" is the 3-D convex-hull variant, not interchangeable.
  Surface-area columns would belong with `__merging_cortical_areas` if ever merged, not the GI merge.
  Frozen source: Zenodo doi:10.5281/zenodo.2538751.
- **Citation:** Heuer K., Gulban O.F., Bazin P.-L., et al. (2019). *Evolution of neocortical folding:
  a phylogenetic comparative analysis of MRI from 34 primate species.* Cortex 118:275–291.
  DOI **10.1016/j.cortex.2019.04.011**.

### 6. Cerebellar folding in mammals (eLife 2023)  — 🚫 OUT OF SCOPE (owner decision, 2026-07-31; owner is co-author)
- **Merge:** cortical-areas / a new cerebellar-surface slot (regional, not pooled with neocortical
  GI). **Role: primary** for cerebellar folding.
- **Contributes:** comparative **cerebellar folding** (folial structure — the paper's result is that
  individual fold size ≈ constant across species and larger cerebella are disproportionately folded)
  from an open collection of **histological data from 56 mammalian species** (manually segmented
  cerebrum + cerebellum). This is a **regional folding/surface** trait, **not** a whole-cerebellum
  volume — so it does **not** duplicate the well-covered cerebellum-*volume* sources (Ashwell 2020,
  Smaers 2018, MacLeod 2003, Rilling & Insel 1998, Matano nuclei, Bush & Allman), and it is a
  different construct from the neocortical-GI merge (Zilles-method neocortex only).
- **Not used anywhere in the repo yet:** eLife 85907 is not registered in `__ReadMe.xlsx` and is not
  cited by any source or review (checked 2026-07-31). The only eLife items present are Smaers 2018
  (35696, cerebellum *volumes*) and Caspar 2022 (77875, handedness).
- **Natural home + an already-half-present pairing:** a **cerebellar folding/surface slot** that would
  also finally surface **Ashwell 2020**'s (`10.1016/j.zool.2020.125753`) already-in-repo but currently
  **dropped** columns — `foliation_index`, `cb_ext_surface_esa_mm2`, `cb_pial_surface_psa_mm2` (its
  standardized-term map ingests only the `*_Vol.mm3` volume columns, so the foliation/surface columns
  never reach a merge). Kept separate from cerebellum-volume and from neocortical GI.
- **Data type note:** unlike the dropped Heuer MRI work, this is **histology** ("MRI does not provide
  the resolution required… histological data can"), so it does not share the MRI inter-observer issue.
  First author is Heuer; **A. A. de Sousa (repo owner) is a co-author** → left for the owner to judge.
- **Citation:** Heuer K., Traut N., de Sousa A.A., Valk S.L., Clavel J., Toro R. (2023). *Diversity
  and evolution of cerebellar folding in mammals.* eLife 12:e85907. DOI **10.7554/eLife.85907**.

### 7. Grabowski / limb angular-excursion dataset — terrestrial mammal locomotion
- **Merge:** `__merging_behaviour` (locomotion/gait), beside Granatosky and Wimberly.
- **Contributes:** **joint angular excursion & locomotor efficiency for 182 species across 15
  mammalian orders** — the widest-coverage locomotion source seen; would broaden gait/locomotion far
  beyond the current primate-leaning set.
- **Source:** Zenodo record **10.5281/zenodo.15425733** *(verify)* — "Supplementary Data … Joint
  Angular Excursion and Efficiency in Terrestrial Mammals." Confirm the linked paper + license and
  which columns map to `Duty_Factor`/`Gait`/`Foot_Posture` before ingesting.

---

## Tier 3 — M1-core traits worth compiling by hand (no single ready dataset)

These are the most *on-theme* (M1 output pathway) but exist only as scattered per-species values, so
each would be a **hand-built `_snapshot`** per `__HOWTO_build_a_dataset_file.md` (printed/scanned
route), not a journal download.

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
  (2018). *Comparative morphology of gigantopyramidal neurons in primary motor cortex across mammals.*
  **J Comp Neurol 526(3):496–536.** DOI **10.1002/cne.24349** · PMID **29088505** · EndNote `[4950]`.
- **Merge:** `__merging_cellcounts` as a **regional M1 sub-trait** (never pooled with whole-cortex
  neuron counts), beside `Young_etal_2013_Table1` — checked, no species or measure collision with Young.
- **Built:** two snapshots, both verified against the paper's own statistics.
  **Table 3** = unbiased stereology, 20 species (11 carnivore + 9 primate), layer V pyramidal **and**
  gigantopyramidal soma length/area/volume + body and brain mass. **Table 5** = Golgi morphology,
  19 species / 7 orders × 3 neuron types (superficial layer III, deep layer V, gigantopyramidal),
  617 traced neurons: soma size and depth, dendritic volume, length, segment length, segment count,
  spine number, spine density.
- **Nolan et al. 2024** (*Betz cells of the primary motor cortex*, J Comp Neurol 532(1):e25567,
  DOI 10.1002/cne.25567, PMID 38289193) is the **review entry point only** — no per-species table, and
  it misquotes Jacobs' feliform mean soma size as 2874 μm² where the paper says **2,847**. Never a
  row's `Source`.
- **Remaining primaries** (audit in `Jacobs_etal_2018/README.md`): Sherwood et al. 2003 ✅ EndNote
  `[5508]` (23 primates + 2 non-primates); Rivara et al. 2003 ❌ absent (the whole human row);
  Lassek & Wheatley 1945 ✅ `[6767]` (chimpanzee area-4 enumeration).

---

## Premature — non-mammal (hold until the resolver is de-MDD'd, scoping step 4)

Large isotropic-fractionator neuron-count datasets exist for **squamates + turtles (107 species)**
and **birds (111 species)**, produced with the same method as the Herculano-Houzel mammal set. They
are the obvious first non-mammal additions to `__merging_cellcounts`, **but** `resolve_taxonomy.R` is
MDD-gated and will silently drop non-mammals, and `species_reference.csv` has no `Class` column. Add
these only after scoping steps 1 & 4 (add `Class`; add a non-mammal resolver path). Flagged here so
they are not lost.

---

## Suggested order of work
1. **Heuer 2018 volumes** (#1) — biggest new-primate-species yield, straightforward supplementary
   table, slots into the most mature merge.
2. **Lesku/Capellini sleep** (#4) — the sleep merge was explicitly built to grow and currently stops
   at primates for REM.
3. **Liu hand** (#2, was mislabelled "Bardo") — extends the behaviour merge on-theme. *(Navarrete
   innovation (#3) is out: the topic is sourced from Reader's own data.)*
4. Tier 2/3 as capacity allows.

For any of these, follow `__HOWTO_build_a_dataset_file.md`: freeze source → `.R` reformat →
analysis CSV + DOI-coded public TSV → definitions.csv → README → register in `__ReadMe.xlsx`
(`Item name`/`Item encoded`) → add to the merge's `item_name` vector and re-run.
