# `trait_authority.csv` — which folder owns each trait

**Landed 2026-09-22.** One row per app-facing label, saying which repo folder holds the
authoritative value. 565 rows, covering every label the app serves.

## Why it exists

Authority used to be implicit and discovered by string matching. `app.R`'s `label_for()` takes
`canonical_variable` + `canonical_unit`, tries the bare name, then `"name (unit)"`, and uses
whichever spelling **happens to exist** among the loaded labels — so which merge won was a side
effect of how that merge spelled its output. `variable_canonical.csv` lists only the exceptions, so
it can tell you a trait needs redirecting but not what is authoritative. And `superseded_by`, which
reads like the declaration, **is consulted by no code** — it can name a folder that does not produce
the label, with nothing to notice.

## Columns

| Column | Meaning |
|---|---|
| `label` | the app-facing variable label |
| `authority` | the repo folder whose value is definitive |
| `basis` | how the row got its authority — see below |
| `status` | `active` / `disputed` / `vetoed` |
| `n_producers`, `all_producers`, `other_producers` | what else emits this label, so a contest stays visible |
| `note` | why, and any caveat |

`basis` values are not interchangeable:

| `basis` | Rows | Meaning |
|---|---|---|
| `auto_single_producer` | 535 | one producer; no decision to make |
| `adopted_from_variable_canonical` | 19 | taken from an existing `superseded_by` |
| `adjudicated` | 11 | a human decided — **never regenerated** |

## The one rule adjudicated so far

**RULE-1.** For a structure volume emitted by both the volumes merge and the cell-counts tables,
`__merging_volumes` is authoritative: it resolves across teams and sources and carries the
laterality and select-value machinery, while the cell-counts copy is a by-product of the
isotropic-fractionator tables. Covers Amygdala, Cerebellum, EntorhinalCortex, Hippocampus,
Hypothalamus, OlfactoryCortices, Septum, Striatum, Tectum, Tegmentum and Thalamus, and matches the
`Neocortex_Vol.mm3` decision already recorded in `variable_canonical.csv`.

## Workflow

```bash
Rscript _keys/build_trait_authority.R   # regenerate (--dry-run to preview)
Rscript _checks/check_trait_authority.R # enforce
```

Both are picked up by `run_all_scripts_v2.R` automatically. To decide a contested label, set
`authority` and `basis = adjudicated` with a reason in `note`; the generator will not touch it again.

## What the check enforces

1. **Completeness** — every label the app serves has a row, and no row names a label it no longer
   serves. This is the guard whose absence let `variable_domain.csv` drift 38 labels behind the data
   with no signal but an "Unclassified" bucket.
2. **Validity** — every `authority` is a real producer folder **and** actually produces that label.
   This is what `superseded_by` lacks, and why it can drift.
3. **Decided** — nothing left at `NEEDS_DECISION` or with a blank authority.

All three were verified by deliberately violating them; each fails with the offending label named.

## A caveat worth knowing

Authority here is per **label**, not per **concept**. `Neocortex_Vol.mm3` and `Neocortex_mm^3` were
the same measurement under two labels, and this registry would have given each its own row without
noticing they collide — it makes authority explicit, not *sameness*. Concept-level grouping is what
`poolable_group` in `variable_domain.csv` was for, and it is still filled on only 10 of 622 rows.
The Lewitus neocortex case is the argument for eventually doing that work.

## Derivation note

Both scripts obtain the label→producer map by evaluating everything in `__ShinyApp/app.R` above the
`shinyApp()` call, which yields the app's own `compiled` table without starting a server. That is
deliberate: any second implementation of `load_compiled()` could disagree with the app, and a
registry that describes a different label space from the one being served would be worse than none.
Both scripts stop if `app.R` stops having exactly one top-level `shinyApp(` call, and both stop on a
`Dataset` with no folder mapping rather than inventing an authority for it.
