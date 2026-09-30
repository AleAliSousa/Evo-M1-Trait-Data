# Taxon pooling — where the decision belongs

Two pooling requests keep recurring: pool **domesticated with wild** forms
(*Sus scrofa domesticus* with *Sus scrofa*, *Mustela putorius furo* with
*M. putorius*), and pool **subspecies / sensu lato with sensu stricto**
(*Gorilla gorilla gorilla* with *G. gorilla*, pre-split *Pongo pygmaeus* with
its modern components). This records where that decision is made today, why
the two requests are not the same kind of problem, and what a flexible
version would look like.

Nothing here is implemented beyond the concept-boundary guard in
`_checks/check_cohort_coverage.R`. It is a map, not a change.

## The short answer

**Do not pool in `__merging_*`.** The merges aggregate with `mean()` grouped
on the resolved species name, so pooling there averages the components and
they cannot be recovered — the concept registry already says this out loud
for *Pongo*: "A pooled mean over this concept cannot be un-averaged:
composition of the underlying sample is usually unrecoverable."

The merges already emit everything a *later* pooling step needs. Each
`__merging_*/..._long.csv` carries `species_printed`, `accepted_name`,
`species_basis`, `Sources` and `n_sources` alongside the value. So pooling
can be a **read-time policy** over a faithful merge, rather than a
merge-time commitment. Resolve identity once, upstream; decide pooling
downstream, per question.

## The two axes are different in kind

| | sensu / subspecies | domesticated vs wild |
|---|---|---|
| What differs | what the **name** meant, historically | which **population** was measured |
| Same species? | often not — `Pongo pygmaeus` s.l. spans two species | yes, always |
| Recoverable? | usually not, once averaged | yes, if labels are kept |
| Already modelled | `taxon_concept_registry.csv` | **nowhere** |
| Right home | resolve time (it is a naming fact) | read time (it is a biological covariate) |

The first is concept drift: a printed name whose referent changed when a
taxon was split. That is a property of the *literature*, so it has to be
settled where printed names are interpreted — the resolver.

The second is not a taxonomy problem at all. *Sus scrofa domesticus* is
*Sus scrofa*; the difference is domestication, which has a real and
well-documented effect on exactly the traits this repo holds — the observed
gaps are body mass 100,000 vs 65,091 g and brain mass 137.65 vs 112 g for
the pig, 1,800 vs 907.5 g and 6.163 vs 10.7 g for the ferret. Whether to
pool them depends on the question being asked, which is the definition of a
read-time choice. Pooling them upstream would bake one answer into every
downstream use.

## Where the decision is made today

Three sites, in pipeline order:

1. **`_keys/<Collection>/species_key.csv`** — variant spelling →
   `accepted_name`, keyed by `(source_publication, variant_name)`. This is
   *identity*, and per `SPECIES_NAMING.md` principle 1 it is explicitly "not
   a taxonomy claim". Every merge resolves through the same
   `_keys/resolve_species.R`, so a change here reaches all 18 merges.

2. **`_keys/volumes_species_overrides.csv`** — per
   `(source_table, printed_name)` → forced `accepted_name`. **This is where
   merge-time pooling actually happens today**: ~40 rows map each volume
   source's `Gorilla gorilla` onto `Gorilla sp.`, annotated "genus-level
   lumping, as in the other 17 volume sources". It is also the weak point:
   *it exists only for the volumes merge*. There is no equivalent file for
   the other 17, so there is currently no uniform place to state a pooling
   policy.

3. **Read time** — `_keys/species_display_aliases.csv` (renames a species
   app-wide) and `species_cohorts.csv`'s `lookup_name` (cohort-local, pools
   several labels onto one cohort slot). Non-destructive; both leave the
   merges untouched.

`species_basis` in the merge output already records *why* a name was
resolved as it was, and the vocabulary is most of what a pooling policy
needs: `lump` (181 rows), `subspecies_assign` (119), `synonym:*`,
`spelling`, `reident`, `our_judgment`, `verbatim`, `unresolved`, `hub`.
**There is no term for the domestication axis** — that is the vocabulary gap.

## What is already built, and what only looks built

- `taxon_concept_registry.csv` (9 rows) has the right schema for the sensu
  axis — `sensu`, `rank`, `valid_period`, `decomposable`,
  `believed_composition`, `split_authority`, `superseded_by`. But **no merge
  reads it**; only two per-paper scripts do (`Barger_etal_2012`,
  `Semendeferi_Damasio_2000`). The concept layer exists beside the pipeline,
  not in it.
- `SPECIES_NAMING.md` §3c documents `resolve_species()` with
  `taxonomy = "NCBI" | "ITIS" | "GBIF" | "MDD" | "paper:<folder>" | "anchor"`
  and a `return=` selector. The implemented signature is
  `resolve_species(printed, source_publication, keys_dir)` — **the
  multi-view argument was never built.** The doctrine of "one anchor, many
  taxonomy views" is therefore aspirational in code, even though
  `species_taxonomy.csv` is already shaped one-row-per-(name × authority) to
  support it.

That matters for this design: the hook the pooling policy would hang on is
the one piece of the naming architecture that does not yet exist.

## A flexible version

**Add `_keys/species_pooling.csv`** — one row per member of a pooling group,
so groups are declarative and auditable:

```
pool_id              member                    axis           relation      basis  authority
Sus_scrofa           Sus scrofa                domestication  wild_form     ...    MDD
Sus_scrofa           Sus scrofa domesticus     domestication  domestic_form ...    MDD
Gorilla_gorilla      Gorilla gorilla           subspecies     species_rank  ...    MDD
Gorilla_gorilla      Gorilla gorilla gorilla   subspecies     nominate      ...    MDD
```

`axis` ∈ `{domestication, subspecies, sensu, indet}`. Every row needs a
`basis` and an `authority`, on the same footing as `reidentifications.csv` —
a pooling group with no stated reason is not auditable.

**Give the resolver the argument its own docs promise**, extended by one:

```r
resolve_species(printed, source_publication = NULL,
                taxonomy = "anchor",          # documented, not yet built
                pool = character(0))          # new: axes to collapse
```

`pool = character(0)` is the default and reproduces today's behaviour
exactly, which is what makes this safe to add: existing merges keep running
unchanged, and a consumer that wants pooled output asks for it
(`pool = "domestication"`). Because the argument is per call, the volumes
merge can stay lumped while a cohort view stays split.

**Consumers then opt in per axis**, and the app's cohort tab is the obvious
first client: `species_cohorts.lookup_name` is currently a hand-maintained
list of labels, which is exactly what a `pool_id` reference would replace.

## Guard rail, and why it exists

Pooling is only safe while the labels being pooled actually hold what you
think. The live example: the concept registry reads
`Gorilla sp. (indet.)` as **non-decomposable**, composed of
*Gorilla gorilla* + *Gorilla beringei*. The cohort nevertheless adopts it,
on the evidence that all 110 rows carrying that label in
`volumes_long.csv` record `species_printed = Gorilla gorilla` and that no
row anywhere in that merge prints `beringei`. That decision rests on the
label's *present content*, not on its meaning — and stops being safe the
moment a beringei-printed row enters the merge.

`_checks/check_cohort_coverage.R` therefore reports this exposure on every
run rather than leaving it to be rediscovered:

```
concept-boundary exposure (report, not an error):
  - EvoM1 / Gorilla gorilla gorilla adopts 'Gorilla sp. (indet.)',
    a non-decomposable concept whose believed composition also includes: Gorilla beringei
```

Any pooling mechanism built later should keep this property: a group whose
members straddle a `decomposable = FALSE` concept boundary is reported, not
silently honoured.

## Order to do it in, if it is done

1. Add the `domestication` term to the `species_basis` vocabulary and record
   the domestic/wild pairs — cheap, and immediately useful for reporting even
   with no pooling.
2. Wire `taxon_concept_registry.csv` into the merges so the sensu axis is
   visible in the output at all.
3. Build `resolve_species(..., taxonomy=)` as documented.
4. Add `species_pooling.csv` and the `pool=` argument, default off.
5. Move `species_cohorts.lookup_name` onto `pool_id` references.

Steps 1–2 are reporting and carry no risk to existing numbers. Step 3 is the
prerequisite that is currently missing. Only 4–5 change what any consumer
sees, and only for consumers that ask.
