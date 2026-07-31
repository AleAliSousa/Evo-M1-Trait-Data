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

## Tier 1 — strongest fits (M1-adjacent or directly extend a live merge)

### 1. Heuer et al. 2018 — Primate Brain Anatomy: New Volumetric MRI Measurements
- **Merge:** `__merging_volumes` (brain-structure volumes). **Role: secondary** (MRI-derived, modern
  compilation to sit alongside the Stephan/Düsseldorf histological volumes).
- **Contributes:** volumetric measurements of **16 brain areas** across **39 primate species**,
  **20 of them not previously in the volumetric literature** — telencephalon, cerebellum, neocortex,
  and regional structures — from the Netherlands Institute of Neuroscience Primate Brain Bank
  (9.4 T). This is the single largest source of *new primate species* for the volumes merge and the
  natural modern counterpart to Stephan.
- **Citation:** Heuer K., Gulban O.F., Bazin P.-L., et al. (2018). *Primate Brain Anatomy: New
  Volumetric MRI Measurements for Neuroanatomical Studies.* Brain Behav Evol 91(2):109–128.
  PMID **29894995**; DOI 10.1159/000489791 *(verify)*. Erratum: Brain Behav Evol 92(3-4):182.
- **Overlap/notes:** cross-check species against Stephan/Isler/deSousa before merging; MRI vs
  histology means it should stay a **team of its own** and never be pooled cell-for-cell with the
  histological volumes. Supplementary volume tables are the ingestable artifact.

### 2. Bardo et al. 2016 — Manipulative potential from hand proportions
- **Merge:** `__merging_behaviour` (hand morphology / manipulation), beside `dexterity_baker`.
- **Contributes:** a **manipulability / workspace** measure for **13 anthropoid species** (137 hand
  samples: humans, apes, OWM, NWM) derived from hand proportions. Directly comparable to Baker's
  `peak_workspace` (both descend from the Feix et al. 2015 manipulability index) and to Heffner
  dexterity — fills the manipulation axis for species Baker doesn't cover.
- **Citation:** Bardo A., Cornette R., Borel A., Pouydebat E. (2016). *Assessing the manipulative
  potentials of monkeys, apes and humans from hand proportions: implications for hand evolution.*
  Proc R Soc B 283(1843):20161923. DOI **10.1098/rspb.2016.1923**.
- **Overlap/notes:** citation-dependency rule applies (shares the Feix manipulability construct with
  Baker) → **never average**; record as a secondary key, resolved value stays Baker's where both
  exist. See `__merging_behaviour/README__merging.md` VocalRepertoire/Dexterity precedent.

### 3. Navarrete, Reader, Street, Whalen & Laland 2016 — Innovation & technical intelligence
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

### 5. Heuer et al. 2019 — Evolution of neocortical folding (34 primate MRI)
- **Merge:** `__merging_gyrification` (folding). **Role: secondary.**
- **Contributes:** folding metrics across **34 primate species** from MRI. NB the merge currently
  pools **only the Zilles-method GI** and deliberately excludes Mota/HH folding-index constructs —
  so ingest only if the Heuer folding metric can be reconciled to the Zilles GI definition;
  otherwise house it beside Mota FI as a separate construct (do not pool).
- **Citation:** Heuer K., Gulban O.F., Bazin P.-L., et al. (2019). *Evolution of neocortical folding:
  a phylogenetic comparative analysis of MRI from 34 primate species.* Cortex 118:275–291.
  DOI **10.1016/j.cortex.2019.04.011**.

### 6. Cerebellar folding in mammals (eLife 2023)
- **Merge:** cortical-areas / a new cerebellar-surface slot (regional, not pooled with neocortical
  GI). **Role: primary** for cerebellar folding.
- **Contributes:** comparative **cerebellar folding / surface** across a broad mammal sample —
  complements Smaers cerebellum volumes and the neocortical folding merges.
- **Citation:** *Diversity and evolution of cerebellar folding in mammals.* eLife 12:e85907 (2023).
  DOI **10.7554/eLife.85907** *(verify authors/n before registering)*.

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

### 9. Betz-cell / layer-5 corticospinal neuron counts in M1
- **Merge:** `__merging_cellcounts` as a **regional M1 sub-trait** (never pooled with whole-cortex
  neuron counts), or beside Young 2013 M1 counts.
- **Sources:** Jacobs et al. and the Betz-cell comparative literature (e.g. *Betz cells of the primary
  motor cortex*, J Comp Neurol 2024, DOI 10.1002/cne.25567) report macaque/human/great-ape Betz
  densities and proportions. Compile the per-species giant-pyramidal counts as a regional column.

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
3. **Navarrete innovation** (#3) and **Bardo hand** (#2) — clean archived datasets, extend the
   behaviour merge on-theme.
4. Tier 2/3 as capacity allows.

For any of these, follow `__HOWTO_build_a_dataset_file.md`: freeze source → `.R` reformat →
analysis CSV + DOI-coded public TSV → definitions.csv → README → register in `__ReadMe.xlsx`
(`Item name`/`Item encoded`) → add to the merge's `item_name` vector and re-run.
