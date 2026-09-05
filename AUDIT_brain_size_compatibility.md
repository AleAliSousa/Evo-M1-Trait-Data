# Whole-brain size: what pools with what, and why

Companion to `AUDIT_app_variable_organization.md`. That document organised variables by
*meaning* (domain and measure class). This one settles a question one level finer: two
variables can both be "whole-brain size in grams" and still not be the same measurement.
Cranial capacity is not brain weight. A brain volume may or may not include the meninges.
A mass converted from a volume at 1 cm³ = 1 g is not a weighed mass. A whole brain with
the olfactory bulbs cut off is not the same brain.

The key is `_keys/brain_size_basis.csv`, built by `_keys/build_brain_size_basis.py`.

## The rule this audit follows

**An inclusion is recorded as yes or no only where the source's own definitions file says
so. Everything else is `unknown`.** Nothing is inferred from what is conventional in the
field, because the entire point is to separate what the sources state from what a reader
assumes. Of 56 whole-brain-size columns, 26 have a quoted basis and 30 do not
(`basis_evidence` = `unstated`).

## What was wrong before

`__merging_brain_mass` harvested every column matching `brain (mass|weight|wt)`, converted
everything to grams, and pooled it into a single `Brain_Mass (g)` value per species. The
definitions show those columns are not one measurement:

| Source | What its definitions actually say |
|---|---|
| Burger et al. 2019 (`Mean_brain_mass_g`) | "compilation; 1 g = 1 cm³ conversion used when volumes reported (per source methods)" — and no per-row flag saying which rows are which |
| Herculano-Houzel 2015 (`brain.mass..g.or.cm3.`) | brain mass in grams, **or** brain volume in cm³ where the cited source reported a volume |
| Herculano-Houzel 2015, Kazu 2014/2015, Avelino-de-Souza 2025 | "whole brain (both sides), **NOT** including the olfactory bulbs" |
| Kverková et al. 2018 | "Whole brain; appx. **sum of 14 structures incl Olfactory bulbs**" |
| Stephan et al. 1981, Ebinger 1974, de Sousa 2009/2010 | "fresh brain weight" |
| MacLeod 2000 | uses the estimated brain weight where a row prints both a **with-meninges** weight and an estimated weight |
| Seymour 2015/2017/2019, Heldstab 2016, Caspar 2022 | endocranial volume — correctly excluded from the mass merge, but then absent from the app entirely |
| Iwaniuk 2001 `Brain Size`, Burger `Brain.resid`, Heuer 2023 `LogBrainWeight_source` | residuals and a logged copy — **not sizes at all** (`is_size = FALSE`) |

Attributing all 2,660 harvested rows to a basis showed how far the mixing went:

All counts below are on the current harvest — 2,660 rows over 1,671 species, i.e. *after* the
two recovered species described under "Where the split becomes unreadable" below.

- **1,331 of 1,671 species (80%) rested entirely on the mass-or-volume-mixed sources.** Only
  101 species rested solely on weighed mass, 8 solely on the olfactory-bulb-excluding stream
  and 7 solely on the sum-of-structures stream.
- 224 species combined two or more bases in a single pooled number (200 with two, 24 with three).
- Where a species had both a weighed mass and a mixed-basis value (212 species), the median
  ratio was 1.000 — but 39 differed by more than 1.2× and 7 by more than 2×.
- Where a species had both a weighed mass and an olfactory-bulb-excluding mass (25 species),
  the median ratio was **0.926**: the bulb-excluding values run about 7% low, which is the
  inclusion difference showing up as a systematic offset rather than as noise.

## The decision

Split into **parallel variables, with no pooling across bases** (the user's choice among
annotate-and-keep-coverage, re-pool-preferring-measured, and split).

| App variable | Species | Basis |
|---|---|---|
| `Brain_Mass_measured (g)` | 289 | a weighed brain mass (fresh, fixed, mixed or compiled — see `state`) |
| `Brain_Mass_excl_olfactory_bulb (g)` | 40 | weighed mass, olfactory bulbs excluded (isotropic-fractionator group) |
| `Brain_Mass_mass_or_volume (g)` | 1,553 | mass for some species, volume at 1 cm³ = 1 g for others, unresolved per row |
| `Brain_Mass_from_volume_or_ecv (g)` | 29 | not weighed: computed from a brain volume, or from an endocranial volume (Weaver 2001) |
| `Brain_size_sum_of_structures (g)` | 11 | summed sub-structure volumes, olfactory bulbs included |
| `Endocranial_volume (mL)` | 281 | braincase capacity: brain + meninges + CSF + vessels |
| `Endocranial_volume_female (mL)` | 106 | the same, female-only means |

`Brain_Mass (g)` no longer exists. `_keys/variable_canonical.csv` re-points the three
superseded raw variables to the right basis-specific target — `Brain_Mass.mg` and
`Brain_weight_g` to `Brain_Mass_measured`, and `WholeBrain_Mass.g` (isotropic
fractionator) to `Brain_Mass_excl_olfactory_bulb` — and carries an explicit
`keep_separate` row, with its reason, for each pair that must never be pooled.

**Specimen-level masses are pooled into `Brain_Mass_measured`** (Karl 2024, Jacobs 2018):
they are the same physical quantity, and the specimen-versus-species-mean distinction is
already carried by `n_sources`. That is a judgement, not a definition, and it is the one
place this split merges two `poolable_group` values.

## Where the split becomes unreadable, and what replaces it

Splitting makes the cross-basis comparison impossible to see in the long table, so the
builder writes it out: `__merging_brain_mass/brain_size_basis_comparison.csv`, one row per
species with more than one basis (224), with the max/min ratio and a flag at >2×. Five
species are flagged. Reviewing them found two source defects rather than basis effects:

- **Lewitus et al. 2013 `Brain_weight_g` carries two rows that are ×100 the gram value**
  (*Panthera leo* 24,721; *Sus scrofa* 13,765 — both exactly 100× that paper's own 2014
  values). Because pooling prefers `primary` teams and both species have primary sources,
  these do not reach the shipped pooled values. Contained, but the column's name asserts a
  unit its values do not honour.
- **Two rows were being dropped entirely.** `HerculanoHouzel/species_key.csv` gives
  *Cynomys sp.* and *Dasyprocta prymnolopha* an `accepted_name` of the literal string `"NA"`,
  which blanked their species label and silently removed them — the defect `APP_PLAN.md`
  flags as "skip blank keys in the build". Both builders now skip a blank or `"NA"`
  accepted name and fall through to the printed name; the merge went from 2,658 to 2,660
  rows and from 1,669 to 1,671 species.

## Structure-name redundancy

`_keys/variable_catalog.csv` carries `Brain`, `Brain_weight` and `WholeBrain` as three
`canonical_structure` values for one structure, because each is inherited from a different
paper's definitions file. `_keys/variable_domain.csv` — the app-facing key — already
resolves all three to `WholeBrain`; `variable_canonical.csv` now records that collapse as
two `structure_alias` rows so it is reviewable rather than implicit.

Three distinctions that look like redundancy are **kept**, each with a `keep_separate` row:

- `WholeBrain` versus `WholeBrainOlfactoryBulb`. Not aliases. `WholeBrain` follows the
  Herculano-Houzel convention with the olfactory bulbs excluded; `WholeBrainOlfactoryBulb`
  is the including-bulbs structure.
- `Total_brain_volume` versus `Total_brain_net_volume`. Ebinger 1974 prints both: "total
  fresh brain volume" and "pure brain volume after remaining parts and ventricle". The net
  volume excludes the ventricles.
- Brain mass versus endocranial volume, for the reason at the top of this document.

## What the app does with it

`_keys/variable_domain.csv` gained a `poolable_group` column. Every variable tooltip now
ends with a "Measurement basis:" line, and the Plot tab shows a warning when the two axes
carry different non-empty groups, naming both bases.

## Resolving the unstated bases

The first version of this key left **30 of 56 columns** basis-unstated, because the folder
definitions files say only "brain weight" or "brain volume". Those 30 were then read out of
the sources themselves — the PDFs are in the paper folders — and **22 resolved**, leaving
**8**. Every one of the 12 volume columns now has a stated basis.

What the sources turned out to say:

| Column(s) | Resolved to | The source's own words |
|---|---|---|
| `Stephan_etal_1970` | `mass_fresh` | "The latter can be found by dividing the weight of the fresh brain by the specific brain weight." |
| `Frahm_etal_1998` | `mass_fresh` | table legend: "Brain weight; data taken from STEPHAN" — a reprint of the Stephan collection's fresh weights |
| `Armstrong__1979` | `mass_fresh_or_fixed_mixed` | "The brain weights were 1,890 gm (after fixation in 10% formalin) and 1,200 gm (fresh) respectively." |
| `Schleifenbaum__1973` | `mass_fresh_or_fixed_mixed` | the collection material was formol-fixed while his own poodle material was freshly prepared — and he notes the wolf brains suffered from years in fixative |
| `Olkowicz_etal_2016`, `Turner_etal_2016`, `Collins_etal_2016` | `mass_fixed` | brains perfused and postfixed before dissection and weighing |
| `Weaver__2001` | `mass_from_volume_or_ecv` | "from measured brain volume (extant) or endocranial volume via Ruff et al. 1997 (fossils)" |
| `Changizi_Shimojo_2005`, `Manger__2006`, `Baron_etal_1996`, `Finlay_etal_2006`, `Garwicz_etal_2009`, `Sherwood_etal_2003` | `mass_compilation_unspecified` | each states that its masses were compiled from other publications, without reporting fixation state |
| `Semendeferi_Damasio_2000` | `volume_mri` | MRI volumetry on living subjects |
| `Semendeferi_etal_1998/2001`, `deSousa_etal_2010`, `Smaers_etal_2011` | `volume_histological` | stereology on fixed, sectioned tissue |
| `Ashwell__2020` | `volume_shrinkage_corrected` | Cavalieri estimator on sections, with shrinkage calculated |
| `MacLeod_etal_2003`, `Smaers_etal_2018` | `volume_mri_or_histological_mixed` | one dataset combining in vivo MRI with histological sections |

One trap is worth naming, because it decides several of these rows. A paper's fixation protocol
describes the tissue it sectioned, and that is not evidence about a brain-mass column its authors
took from the literature. `Sherwood_etal_2003` immersion-fixed or perfused all of its histology
specimens, but its mass column is "species mean brain weight from literature" — so it is
`mass_compilation_unspecified`, not `mass_fixed`. The three papers assigned `mass_fixed` above are
the ones whose tabulated mass is of the brain they themselves perfused.

Two consequences for pooling:

- **Weaver 2001 left `Brain_Mass_measured`.** Its "brain mass" is back-calculated from a volume,
  or for fossils from an endocranial volume — the very conversion this document exists to keep
  apart. Its 29 species are now `Brain_Mass_from_volume_or_ecv (g)`, a fifth parallel variable.
  This dropped `Brain_Mass_measured` from 315 species to 289.
- **Fresh, fixed, mixed and compiled masses stay in `mass_measured`.** They are all a brain on a
  balance; the `state` column in the key records the difference, and the app surfaces it. Only
  the derivation (Weaver) changes what may be pooled.

`_keys/verify_source_statements.py` re-extracts each PDF and fails if a statement attributed to
a paper does not occur verbatim in it. It exists because an inference written in quotation marks
is indistinguishable from a quotation once it is in the CSV — the check caught three of my own,
including one that was a paraphrase and one that had been trimmed past an OCR artefact.

## Still open

- **8 mass columns have no stated basis**: `Bauernfeind_etal_2013`, `Brodmann__1913`,
  `Lewitus_etal_2013`, `Lewitus_etal_2014`, `Nudo_etal_1995`, `Stimpson_etal_2015`,
  `Young_etal_2013`, `deSousa_etal_2013`. Each was read and each is genuinely silent about the
  tabulated mass. Several describe a fixation protocol for their *histology*, which says nothing
  about the mass column: `deSousa_etal_2013` is the clearest case, drawing its brains from the
  Zilles (immersion-fixed), Stephan (Bouin's-perfused) and Great Ape Aging Project collections
  without saying which weight each tabulated value is. `Young_etal_2013` sourced its brains from
  four places (galago and New World monkey perfused, macaque and baboon purchased) without
  stating what the tabulated mass is. They stay in `mass_measured` with every inclusion field
  `unknown`.
- Turner et al. 2016 gives *Macaca nemestrina* 36.4 g against 110 g elsewhere; the row is
  `role = info` and does not reach a pooled value, but the column has not been traced.
