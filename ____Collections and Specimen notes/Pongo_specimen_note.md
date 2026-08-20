# Public specimen/concept note: *Pongo*

## Purpose and evidence boundary

This public note explains the *Pongo pygmaeus*/*Pongo abelii* taxonomic problem
using only published sources. The full evidence note includes unpublished
catalog matches and is held in
`Evo-M1-Traits-Data-restricted/specimen_registry/cases/pongo/`.

The public and restricted claims must not be conflated. In particular, a
specimen label printed in a paper is public, but a match from that label to a
private catalog record remains restricted-derived.

## The core problem

Before the modern species split, *Pongo pygmaeus* was used broadly for
orangutans that may now belong to *P. pygmaeus* (Bornean) or *P. abelii*
(Sumatran). This creates two distinct cases:

1. A named individual can be reassigned when public specimen evidence supports
   the modern identity.
2. A pooled pre-split mean cannot be un-averaged into modern species and must
   remain attached to `Pongo pygmaeus (s.l.)`.

## Public evidence chain

### 1. MacLeod 2000 records four individual orangutans

MacLeod Appendix I prints four *Pongo* specimen records. One, **YN85-38**,
contains both `PONGO PYGMAEUS` and `ABELII` in the printed record. That public
specimen-level evidence supports:

```text
YN85-38 -> resolved_taxon = Pongo abelii
```

The other printed individuals remain unresolved between Bornean and Sumatran
unless independent public evidence establishes the modern species.

### 2. Smaers 2011 prints the same YN85-38 identifier

Smaers et al. 2011 Supplementary Table 1 prints the orangutan catalog label
`yn85 38`. The shared identifier links this row to the MacLeod specimen without
using the private catalog. Because it is one individual rather than a pooled
mean, the value is reassignable to *Pongo abelii* under the specimen consumer
rule.

This specimen supplies the total-frontal-grey value currently entering
`volumes_compiled_select.R` under the broader output label `Pongo sp.`. The
broad output label must not be mistaken for a genus mean.

### 3. Smaers 2017 carries the public measurement forward

Smaers et al. 2017 carries forward the same individual-level frontal series.
The `prefrontal_gray` value agrees with the corresponding Smaers 2011 section
value at printed precision. The public crosswalk therefore links the 2017 row
to YN85-38 through the published 2011 record.

### 4. A genus-level or pooled value follows the opposite rule

Zilles/Rehkämper 1988 prints a value as `Pongo sp.`. DeCasien later files that
stream under modern `Pongo pygmaeus`. A genus-level or pre-split pooled value
cannot be promoted automatically to the modern Bornean species. It remains
attached to `Pongo pygmaeus (s.l.)` unless specimen-level composition becomes
publicly and completely recoverable.

## Database treatment

At the specimen level:

- YN85-38 is `historical_biological_specimen`.
- Its published MacLeod and Smaers labels are public crosswalk rows.
- `resolved_taxon = Pongo abelii` is supported by the printed MacLeod record.
- Catalog-only candidate matches are absent from the public row.

At the concept level:

- `Pongo pygmaeus (s.l.)` is `decomposable = FALSE` for a pooled mean whose
  individual composition is not recoverable.
- It has no single `modern_equivalent`.
- `Pongo abelii` data explicitly assigned under modern taxonomy remain
  separate from the broad pre-split concept.

## Hard rule

```text
published individual with resolving evidence
    -> may use resolved_taxon, with conflict visible

pooled or genus-level pre-split value
    -> stays pinned to Pongo pygmaeus (s.l.); never auto-promote
```

## Restricted complement

The restricted note preserves catalog-derived aliases, private metadata, and
mixed-source candidate matches. Those details can inform an authorized build
but are not evidence that may be copied into the public crosswalk. The source
boundary is recorded in
`_keys/specimen_crosswalk/specimen_source_registry.csv`.

## Public sources

- MacLeod (2000), dissertation, Appendix I.
- Smaers et al. (2011), Supplementary Tables 1 and 2.
- Smaers et al. (2017), Table S1.
- Zilles & Rehkämper (1988), Table 12-2.
- DeCasien & Higham (2019), MOESM3 compilation.
- Groves (2001), *Primate Taxonomy*.
