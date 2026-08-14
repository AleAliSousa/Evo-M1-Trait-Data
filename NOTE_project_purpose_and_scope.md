# Why this dataset exists — original purpose and current scope

**Written 2026-08-14**, recording context that was carried in people's heads rather than in the
repo. This is a *scope* note; the *inclusion decision record* is `SCOUTING_AND_SCOPING.md` and the
*build plan* is `_checks/handoff_remaining_builds.md`.

---

## Original purpose

Evo-M1-Trait-Data was built to supply **comparative phenotypic trait data to set against a
single-nucleus RNA-seq (snRNA-seq) project on mammalian primary motor cortex (M1)** — and in some
cases M1 subregions. The transcriptomic side gives cell types and their proportions across species;
this repo gives the organism- and structure-level traits those cell-type data have to be interpreted
against: brain and body mass, structure volumes, neuron and glia counts, cortical area layouts,
gyrification, corticospinal tract and pyramidal-tract measures, dexterity and hand morphology,
metabolism, sleep, diet and behaviour, across ~215 mammal species.

That explains the shape of the repo. The species list is not a taxonomic sample — it is the
intersection of *what the classical comparative-neuroanatomy literature measured* (Stephan/Düsseldorf
collection, Herculano-Houzel's isotropic-fractionator series, the Allman set) with *what the
snRNA-seq project could obtain tissue for*. It also explains the emphasis on **specimen identity**
(`____Collections and Specimen notes`, `_keys/specimen_crosswalk`): when the comparison is to a
handful of sequenced individuals, knowing that a literature "species mean" is one animal — and
which animal — matters more than it would in a broad phylogenetic comparative study.

## The larger project M1 is one part of

M1 is **one region of three**. The wider effort collects comparable snRNA-seq data from
**~25 mammals** for:

1. **M1** — primary motor cortex (and subregions where available) — the part this repo was built for
2. **V1** — primary visual cortex
3. **Entorhinal cortex**

So the trait side has to widen the same way. The repo's name and its M1-centred framing in
`SCOUTING_AND_SCOPING.md` ("the dataset is centred on primary motor cortex evolution and its
correlates") are **historically accurate but now narrower than the project**. Two things follow:

- **A V1 and an entorhinal counterpart to the M1 trait set are in scope, not scope creep.** Some of
  it is already here and was collected as an M1 correlate rather than as V1 data in its own right:
  `Stephan_etal_1981` area striata, `Zilles__Rehkamper_1988` area striata grey, `Bush_Allman_2004_b`
  V1 grey, `Smaers_etal_2017` primary visual gray/white/surface, `Changizi_Shimojo_2005` V1/A1/S1 as
  % neocortex, `Frahm_etal_1998` MT, `deSousa_etal_2010` V1–LGN, `Collins_etal_2010` cortical
  surface. **V1 volumetric coverage is therefore already decent and largely un-flagged as such.**
  Entorhinal cortex is much thinner — worth a targeted scout of the hippocampal-formation
  volumetric literature (Stephan's schizocortex/hippocampus columns are the obvious entry point).
- **Region should become a first-class axis.** `_keys/variable_catalog.csv` already carries
  `Structure` / `canonical_structure`; what is missing is a *region-of-interest tag* that lets
  someone ask "give me the trait table for V1" the way they can currently ask for M1 only by knowing
  which papers to pick. This pairs naturally with the `Class`/trait-scope axis proposed in
  `SCOUTING_AND_SCOPING.md` Part 2 §1 — same mechanism, second dimension.

## Where the sensory data fits

The audio-visual sensory dataset copied in on 2026-08-14
(`____Sensory_audiovisual/`, see `NOTE_sensory_audiovisual_intake.md`) is the first material that is
**not** an M1 correlate: visual acuity, audiograms, sound-localization thresholds, interaural
distance — behavioural and psychophysical performance for 157 species. Its relevance is to the V1
arm, and secondarily to the general question of whether regional cell-type composition tracks
functional capability rather than just size. It also brings substantial non-primate breadth
(cetaceans, pinnipeds, bats, rodents) that the M1-centred species list lacks.

It is a good argument for the region axis above: as V1 and entorhinal data accumulate, a repo whose
name and README say "M1" will mislead. **Renaming is worth considering** — something region-neutral
(`Evo-Cortex-Trait-Data`, or a name naming the snRNA-seq project it serves) — but only after the
region tagging exists, since a rename without it just moves the ambiguity into the folder name.

## Practical implications, shortest first

1. Tag existing items by **region of interest** (M1 / V1 / entorhinal / whole-brain / other) in
   `_keys/variable_catalog.csv`. Cheap, immediately useful, and it reveals the entorhinal gap.
2. Scout entorhinal / hippocampal-formation volumetrics deliberately, as
   `SCOUTING_AND_SCOPING.md` Part 1 did for M1.
3. Reconcile the trait species list against the **~25 species** actually being sequenced across all
   three regions — the coverage question that matters is per-region-per-species, and it is not
   currently answerable from anything in the repo.
4. Decide the sensory-data route (see the intake note) and whether psychophysical/performance
   measures become a new `measure_class`.
5. Revisit the repo name and README framing once 1–3 are done.
