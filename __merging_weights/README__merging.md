# Merging brain-part weights

Pipeline for compiling **brain-part (sub-regional) wet weight/mass** across species — a sibling of
`__merging_brain_mass/` (whole-brain mass only). This merge does **not** duplicate or re-derive
whole-brain mass: any "Brain"/whole-brain column in a harvested source is dropped here and left to
`__merging_brain_mass/`. What this merge adds is the breakdown of that mass into brain divisions —
cerebral cortex, cerebellum, olfactory bulb, medulla, and other subcortical/hindbrain parts.

## Update: Latimer correction and addition

Two corrections/additions made after the initial merge, prompted by the project owner:

1. **Latimer 1942 was rebuilt as one unified item.** The first pass wrongly treated brain-part
   weights and spinal-cord weight/length as two separate dataset items under two registry rows.
   Table I (p. 43) is printed as a **single table** covering brain divisions, spinal cord, and
   body weight/length together for the same dogs. It is now one item,
   `Latimer__1942_TABLEI.csv`, matching the single registry row the owner had entered
   (`Item name = Latimer__1942_TABLEI`). This merge now also pulls the item's `Cord weight` row
   (mapped to the canonical `SpinalCord` token) alongside the brain-division rows it already used.
2. **Latimer 1956 Table 2 added as a second, independent Latimer source.** This is a different
   paper (Latimer, H. B. (1956). *The Weights of the Parts of the Brain in Several Species of
   Animals*. Trans. Kansas Acad. Sci.) reporting brain stem / prosencephalon / cerebellum weights
   for 10 taxa (frog, chicken, turtle, rat, rabbit, guinea pig, cat, dog, baboon, human) — it
   substantially broadens species coverage beyond the single-species (dog) 1942 table. 7 of the 10
   rows are Latimer's own dissections (`role = primary`); rat, baboon, and human are the paper's
   own cited secondary values (Donaldson 1924; Riese & Riese 1952; Donaldson 1909 respectively)
   and are kept in `weights_long.csv` with `role = secondary` so they are visible but
   distinguishable from directly-measured rows.

## Source set — included and why

| Source | Species covered | Part-mass columns used | Role | Included? |
|---|---|---|---|---|
| Latimer 1942 Table I (`Latimer__1942_TABLEI.csv`) | dog (*Canis lupus familiaris*), male and female cohorts | Olfactory bulbs, Hemispheres and dien., Prosencephalon, Mesencephalon, Cerebellum, Medulla, Rhombencephalon, Cord weight (mg, printed) | primary (measured) | Yes |
| Latimer 1956 Table 2 (`Latimer__1956_Table2.csv`) | frog, chicken, turtle, rat, rabbit, guinea pig, cat, dog, baboon, human — 10 taxa | Brain stem, Prosencephalon, Cerebellum (mg, printed) | primary for 7 taxa (Latimer's own dissections); secondary for rat/baboon/human (paper's own cited external sources — Donaldson 1924, Riese & Riese 1952, Donaldson 1909) | Yes (`role` column carries primary/secondary per row) |
| Herculano-Houzel et al. 2015 Table 1 | ~40 mammals | Cerebral cortex Mass, g | primary (measured) | Yes |
| Herculano-Houzel et al. 2015 Table 2 | ~41 mammals | Cerebellum Mass, g | primary (measured) | Yes |
| Herculano-Houzel et al. 2015 Table 3 | ~40 mammals | RoB ("Rest of Brain") Mass, g | primary (measured) | Yes |
| Herculano-Houzel et al. 2015 Table 4 | ~29 mammals | Olfactory bulb Mass, g | primary (measured) | Yes |
| Herculano-Houzel et al. 2015 Table 5 | ~40 mammals | Brain mass, g | — | **No** — whole-brain mass, `__merging_brain_mass`'s domain |
| Herculano-Houzel et al. 2020 Table 1/2 | bats | `MBRAIN` (whole-brain, g); `NCX`/`NCB`/`NRoB` (neuron **counts**, not mass) | — | **No** — no part-*mass* column at all, only whole-brain mass (excluded per above) and neuron counts, which belong to `__merging_cellcounts`, not this weight merge |
| Kverkova et al. 2018 Table S1 | ~11 African mole-rats and relatives | Brain_Mass.g x `<part>_p.C.Brain` (14 parts, see below) | **derived** (not measured) | Yes, flagged |

Kverkova's table publishes **part volume as a percent of total brain volume** (`..._p.C.Brain`,
a fraction e.g. `0.037`), not part mass directly. Per the task instructions, part mass is derived
as `Brain_Mass.g x <part>_p.C.Brain` and every such row carries `role = "derived"` and a
`derivation` string spelling out the exact arithmetic and the assumption being made (that the
volume fraction of the brain occupied by a part is a usable proxy for its mass fraction — i.e.
approximately uniform tissue density across parts and against the whole brain). These rows are
never treated as equivalent evidence to a directly measured mass; the wide-table summary
(`primary_preferred`) always prefers a real HerculanoHouzel measurement over a Kverkova-derived
value when both exist for the same species/structure (see Pooling below).

## Sex-pooling decision (Latimer 1942)

Latimer 1942 reports the dog brain-part weights **separately for males (n=162) and females
(n=159)** — large, independently-sampled cohorts, not paired replicates of the same animals.
**Decision: keep the sexes as two distinct observation rows in `weights_long.csv`** (`sex = "male"`
/ `"female"`), rather than pooling into one dog value. Rationale:
- Latimer's own analysis treats sex as a grouping variable (with reported CV per sex), and the
  male/female difference is itself non-trivial (e.g. Brain 76,918 mg male vs 73,000 mg female,
  the whole-brain row, which is excluded here but shows the scale of the sex effect propagates to
  parts too — Cerebellum 7,369 vs 6,954 mg).
- Collapsing to a single pooled mean would need the raw n-weighted formula, and burying it as the
  only dog value would silently discard information that downstream body-mass/sex-dimorphism
  analyses might want.
- `weights_wide.csv` (species x canonical-structure) does take a simple mean across the two sex
  rows for the single "dog" wide summary cell, since the wide table is one row per species by
  design; the two underlying sex-specific rows remain fully visible in `weights_long.csv` for
  anyone who needs them unpooled.

## Units

Project unit for brain-part weight is **mg** (`_skills/build-dataset-item/references/__HOWTO_build_a_dataset_file.md`
section 6). Conversions applied and kept visible in `weights_long.csv` (`unit_original`,
`conversion_factor_to_mg`):
- Latimer 1942: already published in mg — factor 1, no conversion.
- Herculano-Houzel et al. 2015 (Tables 1-4): published in g — multiplied by 1000.
- Kverkova et al. 2018 (derived): `Brain_Mass.g` published in g — derived part mass multiplied by
  1000 after the fraction is applied.

## Species harmonisation

- Latimer 1942's `Species` column already carries the resolved accepted name (`Canis lupus
  familiaris`); the Latimer1942 token ("dog" -> `Canis lupus familiaris`) is already present in
  `_keys/Stephan/species_key.csv`, added ahead of this task.
- Herculano-Houzel et al. 2015 and Kverkova et al. 2018 species tokens are resolved through
  `_keys/HerculanoHouzel/species_key.csv`. Every species token in the four HH2015 tables and in
  Kverkova TableS1 is already present as a `variant_name` in that key (checked programmatically,
  zero misses) — no new key rows were required for this merge.

## Canonical structure mapping

Checked against `_keys/anatomy_reference.csv`. Mapped:

| Printed name | Source | Canonical structure |
|---|---|---|
| Olfactory bulbs / Olfactory bulb bulbs / Olfactory bulb Mass | Latimer, HH2015 T4, Kverkova | `OlfactoryBulb` |
| Mesencephalon | Latimer | `Mesencephalon` |
| Cerebellum | Latimer, HH2015 T2, Kverkova | `Cerebellum` |
| Medulla / Medulla oblongata | Latimer, Kverkova | `Medulla` |
| Cord weight | Latimer 1942 | `SpinalCord` |
| Cerebral cortex Mass | HH2015 T1 | `CerebralCortex` |
| RoB (Rest of Brain) Mass | HH2015 T3 | `RoB` (already an existing canonical token in the anatomy reference, used by the cell-counts domain) |
| Olfactory cortices | Kverkova | `OlfactoryCortices` |
| Neocortex | Kverkova | `Neocortex` |
| Entorhinal cortex | Kverkova | `EntorhinalCortex` |
| Hippocampus | Kverkova | `Hippocampus` |
| Amygdala | Kverkova | `Amygdala` |
| Striatum | Kverkova | `Striatum` |
| Septum | Kverkova | `Septum` |
| Thalamus | Kverkova | `Thalamus` |
| Hypothalamus | Kverkova | `Hypothalamus` |
| Tectum | Kverkova | `Tectum` |
| Tegmentum | Kverkova | `Tegmentum` |

**Open gaps — no canonical structure exists yet** (kept under the printed name in
`weights_long.csv`, `canonical_structure` left blank, `mapping_gap` column states the reason):
- Latimer's `"Hemispheres and dien."` (cerebral hemispheres + diencephalon, pooled as printed —
  does not correspond to any single existing canonical token)
- Latimer's `"Prosencephalon"` (forebrain = hemispheres + diencephalon + basal structures; also
  not a canonical anatomy_reference token)
- Latimer's `"Rhombencephalon"` (hindbrain = cerebellum + medulla + pons, printed as one summed
  value; likewise no existing canonical token)
- Latimer 1956's `"BrainStem"` and `"Prosencephalon"` (10-taxa source; same `Prosencephalon` gap
  as the 1942 item, plus a new gap for brain stem, which has no canonical token either)

These are retained in `weights_long.csv` for completeness but excluded from `weights_wide.csv` and
the QA report, since a wide table needs a canonical column key. **TODO for whoever extends
`_keys/anatomy_reference.csv`:** add `Prosencephalon`, `Rhombencephalon`, `BrainStem`, and a
`HemispheresAndDiencephalon` (or similarly named) canonical token if this merge is to be extended
with other classical brain-part literature that uses the same higher-order groupings. Latimer
1956's Frog and Turtle rows carry an additional gap note (`| no binomial given in source for this
taxon`) since the paper does not print a species-level identification for those two.

## De-duplication against `__merging_brain_mass`

`__merging_brain_mass/` already compiles **whole-brain mass** from 27 source tables. This merge
never re-harvests or re-derives that number:
- Latimer's `Brain` row (whole-brain, both sexes) is dropped before building `weights_long.csv`.
- HerculanoHouzel et al. 2015 Table 5 (`Brain mass, g`) is excluded entirely (see source table
  above) — it is a whole-brain-only table with no part breakdown.
- HerculanoHouzel et al. 2020 Tables 1/2 are excluded entirely — Table 1's `MBRAIN` is whole-brain
  mass (again `__merging_brain_mass`'s domain) and Table 2 has no mass column at all (neuron
  counts only).
- Kverkova's `Brain_Mass.g` column is used only as the **multiplier** for deriving part mass from
  the percent-of-brain fractions; the whole-brain value itself is not written to any output here.

## Cross-source disagreement / QA

Only two (Species, canonical_structure) pairs are covered by more than one source at all —
*Heterocephalus glaber* Cerebellum (HerculanoHouzel 2015 Table 2 measured vs Kverkova 2018
derived) and *Heterocephalus glaber* OlfactoryBulb (HerculanoHouzel 2015 Table 4 measured vs
Kverkova 2018 derived). Both agree to within ~7% (ratio < 1.1), well under the 2x disagreement
threshold — see `weights_qa_dedupe.csv` for the full comparison (both flagged `agree (<2x)`, no
`DISAGREEMENT>2x` rows exist in this initial harvest). All other (species, structure) pairs are
covered by exactly one source, so the wide-table means are single-source values, not averages.

## Outputs

- **`weights_long.csv`** — 349 rows (56 unique species), one row per (species, structure, source). Columns: `Species,
  species_as_published, canonical_structure, structure_as_published, mass_mg, mass_g, mass_se_mg,
  n, sex, unit_original, conversion_factor_to_mg, role (primary/derived), derivation, source,
  citation, mapping_gap`.
- **`weights_wide.csv`** — 51 species x canonical-structure summary. One row per species, one
  column per canonical structure (`<Structure>_Mass.mg`), taking the mean across primary sources
  where more than one exists (falling back to derived values only when no primary source covers
  that species/structure).
- **`weights_qa_dedupe.csv`** — 2 rows, every (species, structure) pair with more than one
  contributing source, with min/max mass, the max:min ratio, and a `DISAGREEMENT>2x` /
  `agree (<2x)` flag.

## Rebuild

```sh
python __merging_weights/weights_compiled.py
```

Reads the four primary/secondary source CSVs and the HerculanoHouzel species key directly from
their existing paper folders (no re-extraction from PDFs/snapshots needed — all four source items
are already built) and regenerates all three outputs above. Re-run after any change to
`Latimer__1942_TABLEI.csv`, `HerculanoHouzel_etal_2015_Table{1,2,3,4}.csv`,
`Kverkova_etal_2018_TableS1.csv`, or `_keys/HerculanoHouzel/species_key.csv`.

## Known limitations / not yet covered

- Latimer's three summed-region printed values (`Prosencephalon`, `Rhombencephalon`, `Hemispheres
  and dien.`) have no canonical anatomy token yet (see gap list above).
- Kverkova-derived part masses rest on a volume-fraction-as-mass-fraction approximation; they are
  not independently measured and should not be pooled with measured values as if equally reliable
  (the wide table's `primary_preferred` flag exists precisely so a downstream consumer can filter
  these out if they need measured-only masses).
- HerculanoHouzel et al. 2020 (bats) has no part-mass breakdown to contribute at all; if a future
  bat-specific part-mass source is built, it should be added directly rather than trying to force
  fit through the 2020 neuron-count tables.
- Only 51 species in total have any canonical-structure part-mass coverage from this initial
  three-source harvest (14 unique species from Latimer's single-species/two-sex cohort, HH2015's
  ~40 species union, and Kverkova's 11 species, with 1 species — *Heterocephalus glaber* —
  appearing in both HH2015 and Kverkova). Coverage is far smaller than the 1,616-species
  `__merging_brain_mass` whole-brain compilation; extending this merge with `HerculanoHouzel_etal_2016`
  and other part-volume tables noted in the task (not yet harvested here) would substantially
  widen coverage.
