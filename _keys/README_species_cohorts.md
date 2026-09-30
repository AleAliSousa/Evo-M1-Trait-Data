# `species_cohorts.csv` — named species sets

Species sets the project reports trait coverage against. The Shiny app's
**Cohort coverage** tab reads this file and nothing else to decide which
species belong to a cohort.

## Format

One row per **species × cohort**, so a species may belong to several cohorts
(human is in all three).

| column | meaning |
|---|---|
| `cohort` | short machine key, used in downloads (`EvoM1`) |
| `cohort_label` | how the cohort is named in the interface |
| `species_sci` | binomial **as the cohort itself names it** (see below) |
| `common_name` | shown beside the binomial in the checklist |
| `lookup_name` | optional override: the label the compiled data hold this species' values under. Blank = join on `species_sci` |
| `lookup_basis` | why that override is justified — required whenever `lookup_name` is set |
| `source` | where the membership list came from — required |
| `note` | free text; used here to record name-fragmentation caveats |

## Cohorts currently defined

| cohort | n | membership |
|---|---|---|
| `HMBA` | 4 | human, *Macaca mulatta*, *Callithrix jacchus*, mouse — the subsampled set |
| `EvoM1` | 25 | the M1 cross-species cohort |
| `V1` | 25 | the V1 cohort — **currently the same 25 species as `EvoM1`** |

All three lists were supplied by the project owner (2026-09-30). `HMBA` is a
strict subset of `EvoM1`. `V1` and `EvoM1` are kept as separate cohorts even
though their membership coincides today, because they answer different
questions and can diverge; if they are meant to stay locked together, drop one.

## Species names: write the cohort's own name

`species_sci` is deliberately the name **the cohort uses**, even where the
compiled data file that animal differently. Two separate mechanisms then
reconcile them, and the difference between them matters:

- **`_keys/species_display_aliases.csv`** renames a species for the *whole
  app*. Right for a pure nomenclature change, where both names
  unambiguously denote the same taxon.
- **`lookup_name` in this file** is *cohort-local*: it says "for this cohort,
  count the values filed under that label", and changes nothing else.

Worked example of the first. The cohort names the arctic ground squirrel
`Urocitellus parryii` (current MDD genus); every value in the compilation —
body mass, brain mass, diet, torpor — is filed under the pre-split name
`Spermophilus parryii`. An alias row unifies them and the cohort resolves.
Without it the species would have reported no data at all.

`lookup_name` is blank for every row as shipped. No substitution is applied
by default, so a cohort reports what its own names hold.

## Name fragmentation: the thing to look at first

Several cohort members have substantial data filed under a *related* label
that the exact name does not pick up. The app's **Name variants** sub-tab
lists these with their value counts. Four cases were consequential; two have
been ruled on and two are open.

A label is offered as a variant when one name is a word-wise **prefix** of the
other, or when it is the genus placeholder `Genus sp.`. Congeners with a
different epithet are deliberately **not** offered.

### Adopted

**`Gorilla gorilla gorilla` → pooled with `Gorilla gorilla` + `Gorilla sp.`
(30 → 249 measurement variables).** The evidence is positive, not inferred:
all 110 `Gorilla sp.` rows in `__merging_volumes/volumes_long.csv` record
`species_printed = Gorilla gorilla` with `species_basis = lump`, and **no row
anywhere in that merge prints `beringei`**. So `Gorilla sp.` is the volumes
merge's conservative genus-level label for western-gorilla material, not a
pooling of two gorilla species — the `beringei` rows in
`volumes_species_overrides.csv` are pre-emptive entries for source tables that
are not in the merge. *G. g. gorilla* is the nominate subspecies of
*G. gorilla* and the only one in research collections. The three labels
overlap on just 3 variables (body mass 110,825 vs 111,717 g; brain mass 466.9
vs 500 g; ECV 490.4 vs 461 mL) — separate compilations of one species, pooled
as ordinary multi-source values. Brain structure & size went from 5 traits
to 114.

**`Saimiri boliviensis boliviensis` → pooled with `Saimiri boliviensis`
(40 → 75).** Nominate subspecies, and the labels agree where they overlap
(body mass 750 g in both; brain mass 22.98 vs 25.5 g). `Saimiri sciureus` is
**not** adopted — see below.

**`Sus scrofa` → re-pointed to `Sus scrofa domesticus` (58 → 107).**
*Re-pointed, not pooled.* Unlike Gorilla, `species_printed` is
`Sus scrofa domesticus` *verbatim*: the sources really do distinguish wild
boar from domestic pig, and the values differ accordingly — body mass 100,000
vs 65,091 g (35%), brain mass 137.65 vs 112 g (19%), cortical surface area
6,594 vs 13,022 mm² (49%); gestation and weaning age are identical. Pooling
would report a mean body mass near 82 kg describing neither animal, which
matters because the app's plot tab is allometric by default. The sequenced pig
is a domestic animal and the domestic label carries the Kazu 2015 and
Herculano-Houzel cell counts, so the cohort slot points there. Owner decision,
2026-09-30.

The cost is recorded in the row's `note`: 52 variables filed under the bare
binomial — sensory performance, corticospinal tract, cerebral metabolic rate —
are not counted. Those studies were most likely done on domestic pigs too; if
that is confirmed per source, the right fix is to correct the labels at source
rather than pool two forms here.

### Open — this changes reported values, so it needs an owner's ruling

**`Mustela putorius furo` vs `Mustela putorius` (96 vs 58, union 143).** Same
shape as the pig but resolved the other way by default, because the cohort
name is *already* the specific one: a laboratory ferret is
*M. putorius furo*, and `Mustela putorius` is the wild polecat. Both are
printed verbatim and the disagreements are larger still — body mass 1,800 vs
907.5 g (50%), brain mass 6.163 vs 10.7 g (42%), cortical surface area 882 vs
2,454 mm² (64%) — while `Neocortex_grey_matter_Vol.mm3` is identical at 2,140
and longevity and sexual maturity agree exactly. That mixture of exact
agreement on some traits and 50%+ disagreement on the allometric core is
itself worth explaining before anything is pooled. Default is *not* pooled.

### The Saimiri case the variant rule does not reach

`Saimiri sciureus` carries **239 values across 15 datasets** — the Stephan
collection, Herculano-Houzel cell counts, Burish 2010, Zilles 1986, Karl 2024
V1 synapses — against 75 for the adopted pair. It is not offered as a variant
because it is a *different species*, not a longer form of the same name.
Where it overlaps `S. b. boliviensis` it agrees closely (body mass 750 vs
750.96 g; ventricle volume 299 in both; longevity and sexual maturity
identical), which is suggestive but not decisive: squirrel monkeys are of
similar size and the compilations share primary sources. Whether the
historical "S. sciureus" material is in fact *S. boliviensis* is the open
re-identification question already on record here. Adopting it would be the
single largest coverage change available to this cohort, and it is not
assumed in either direction.

### The Saimiri case, which the variant rule does not reach

`Saimiri sciureus` carries **239 values across 15 datasets** — far more than
the 43 under `Saimiri boliviensis boliviensis`. It is not listed as a variant
because it is a *different species*, not a longer form of the same name.
Whether the historical "S. sciureus" material in this literature is in fact
*S. boliviensis* is the open re-identification question already on record in
this repo; it is not assumed here in either direction. Deciding it would
change reported values for a well-covered primate, so it needs an explicit
ruling with a stated basis, recorded in `lookup_basis` or in
`_keys/reidentifications.csv`.

## Adding a cohort

Append rows with a new `cohort` key. Nothing else needs changing — the app
picks up any cohort in the file and sizes its controls to it. Give every row a
real `source`; a membership list with no stated origin cannot be audited later.

## Open taxonomy issues this tab exposed

Both are recorded rather than fixed, because fixing either changes reported
values.

1. **One species under two names.** The compilation carries both
   `Spermophilus tridecemlineatus` (27 values, 6 datasets) and
   `Ictidomys tridecemlineatus` (4 values) — the same thirteen-lined ground
   squirrel, split across the pre- and post-MDD genus. They overlap on
   `Body_Mass (g)` and **disagree**: 140 g from one source against 318.8 g
   from eight. Unifying the names would make the app average two values
   neither source states, so no alias was added. Resolving it needs a decision
   about which body mass is right — both are within the species' seasonal
   range, which is why the disagreement is not self-evidently an error.

2. **The `Spermophilus` split is only partly applied.** 39 further
   `Spermophilus sensu lato` species keep the pre-split genus while
   `Ictidomys tridecemlineatus` and (now) `Urocitellus parryii` use current
   names, so the genus is internally inconsistent. The full MDD split
   (`Urocitellus`, `Callospermophilus`, `Xerospermophilus`, `Otospermophilus`,
   `Ictidomys`, `Notocitellus`, `Poliocitellus`, `Spermophilus` s.s.) is a
   taxonomy job needing an authority, not an alias-by-alias fix.

## What "coverage" counts

- **Measurements only.** Variables flagged `is_measurement = FALSE` in
  `variable_definitions.csv` (QC flags, provenance strings) are excluded —
  counting them would report a hole as filled.
- **Availability, not agreement.** A cell counts as covered if any source
  gives a non-empty value. Whether sources agree is a different question, and
  the Compiled database tab is where it is asked.
- **Matrix fill** on the Statistics tab is quoted over traits the cohort has
  *some* data for. Over all ~835 repo variables it would be a near-zero number
  dominated by traits that exist only for species outside the cohort, which
  says nothing about the cohort.
