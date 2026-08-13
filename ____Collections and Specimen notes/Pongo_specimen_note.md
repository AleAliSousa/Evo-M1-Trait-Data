# Specimen / concept note: Pongo (orangutan) — the pygmaeus / abelii split

## Purpose

This note tracks the taxonomic-history problem in the orangutan (*Pongo*) data
and explains why it needs **two different mechanisms**, not one. It is the
reference worked example for the two-layer specimen / taxon-concept model in
`_keys/specimen_crosswalk/` (see `SCHEMA.md`).

## The core problem

*Pongo* used to be **one species** and is now **two**. Before Groves (2001),
*Pongo pygmaeus* was used *sensu lato* for all orangutans. Groves elevated the
Sumatran form to full species rank as *Pongo abelii*, leaving *Pongo pygmaeus*
(*sensu stricto*) for the Bornean form.

Two consequences, which behave differently in the database:

1. **A single specimen** recorded long ago as "*Pongo pygmaeus*" may in fact be
   a Sumatran animal — i.e. modern *P. abelii*. That is resolvable at the
   specimen level.
2. **An old species *mean*** labelled "*Pongo pygmaeus*" may be an average over
   a **mix** of Bornean, Sumatran, and possibly captive **hybrid** individuals.
   That is **not** resolvable — you cannot un-average a pooled mean into its
   modern species. It must stay attached to the old broad concept.

This is why Pongo cannot be handled the way the gibbon *Disco* was. Disco is one
individual with conflicting labels (resolve to one identity). An old *Pongo
pygmaeus* mean is one label over many individuals (do not split).

## Evidence in this dataset

### 1. The master catalog hides Sumatran animals inside "Pongo pygmaeus"

`specimens info 151211.xls` (sheet `catalog`) lists 9 orangutans, **all** under
`species = Pongo pygmaeus`. Two of them carry a `subspecies` value that reveals
they are Sumatran:

| catalog id | collection | species | subspecies | sex |
|---|---|---|---|---|
| CAT-150 | Zilles | Pongo pygmaeus | `Pongo pygmaeus abeli` | M |
| CAT-151 | Zilles | Pongo pygmaeus | `sumatra` | F |

A species-mean pipeline that reads only the `species` column never sees the
`subspecies` field, so these Sumatran (modern *P. abelii*) individuals are
silently folded into a "*Pongo pygmaeus*" average.

### 2. MacLeod 2000 records the split label on a specimen directly

MacLeod (2000) Appendix I ("Duesseldorf records of primates used in volumetric
study, Hirnforschung sample") lists four *Pongo* specimens. One carries **both**
species names in its printed cell:

| MacLeod id | printed specimen cell | sex | brain g | fixed vol cc |
|---|---|---|---|---|
| 0475 | `PONGO (ZILLES)+A79` | F | NA | 107.6 |
| **YN85-38** | **`PONGO PYGMAEUS / ABELII / ZILLES (SEMEND.)`** | M | 369 | 216.3 |
| OY 1148 | `PONGO PYGMAEUS / ZILLES(SEMEND.) / HARRY (2/97)` | M | 440 | 186.11 |
| OHDZ / 6728 | `PONGO PYGMAEUS / ZILLES(SEMEND.) / BRIGGS (5/97)` | M | 345 | 154.89 |

**YN85-38** is the explicit pygmaeus→abelii case: the specimen was recorded as
*Pongo pygmaeus* and then annotated *abelii*, i.e. reassigned to the Sumatran
species under newer taxonomy. It is resolved to *Pongo abelii* in the crosswalk.

### 3. The Duesseldorf collection overlap (why Stephan and Zilles values mix)

The *Pongo* specimens are Zilles/Semendeferi material sourced largely from
Yerkes, housed at the Düsseldorf C. & O. Vogt Institut für Hirnforschung — the
same institute as the Stephan collection. Because the two collections overlap
physically and were used together in later studies (MacLeod, de Sousa,
Bauernfeind, Barger), an orangutan value can enter a **Stephan-dataset**
comparison table having actually originated in the **Zilles/Rehkämper** stream.
The house names tie the two records systems together:

```text
catalog 'Harry'  (CAT-148, Zilles, Yerkes)  = MacLeod HARRY (2/97) / OY 1148
catalog 'Briggs' (CAT-147, Zilles, Yerkes)  = MacLeod BRIGGS (5/97) / OHDZ / 6728
```

### 4. Smaers swapped orangutan between 2010 and 2011 — and the merge takes the Sumatran one

Added 2026-08-12, while wiring total frontal grey matter into
`volumes_compiled_select.R`.

Smaers' two frontal-lobe tables print *different* orangutans under the same
label "*Pongo pygmaeus*", and the change is invisible unless you read the
catalogue numbers:

| source | printed catalogue | = catalog / MacLeod id | brain vol (Smaers) | MacLeod brain g | implied density |
|---|---|---|---|---|---|
| Smaers et al. 2010 Table 1 | `297` | CAT-148 `simple code` 297 = **HARRY** / OY 1148 | 424.7 cm³ | 440 | 1.036 g/cm³ |
| Smaers et al. 2011 Suppl. Table 1 | `yn85 38` | **YN85-38** (candidate CAT-150) | 356.2 cm³ | 369 | 1.036 g/cm³ |

Both identifications land on the same implied brain density (1.036 g/cm³), which
is what confirms them: the catalogue numbers alone are ambiguous, the
mass-to-volume ratio is not.

The consequence for the data: **Pongo is the one species whose frontal grey
matter changes materially between the two Smaers tables — −33% (64.44 → 42.96
cm³) — and none of that is re-measurement.** Every other species' total brain
volume agrees between 2010 and 2011 to within 0.01%, so the same brains were
re-used throughout; only the orangutan was replaced. Reading the −33% as
measurement drift would be wrong.

Because `volumes_compiled_select.R` selects Smaers 2011 (not 2010), the
orangutan value in the merge is **YN85-38 = *Pongo abelii*** — the Sumatran
animal — carried under the lumped label `Pongo sp.`. Smaers et al. 2017 carries
the same individual forward (its Pongo `prefrontal_gray` 8.596 cm³ = the 2011
`sec5_grey_total` 8.60 for `yn85 38`), so the `FrontalMotor_grey/white` values
already in `volumes_wide_select.csv` under `Pongo sp.` are this same Sumatran
brain.

Note this is a **specimen** case, not a concept case: n = 1, so nothing is
pooled and nothing needs un-averaging. `Pongo sp.` here is a genus-level *label*
over a single Sumatran individual, not a genus mean — the do-not-split rule
below does not apply to it, and `resolved_taxon = Pongo abelii` does.

## Recommended database treatment

### Specimen level (`specimen_crosswalk.csv`)

Track each physical animal as one `canonical_specimen`, keep every printed label
as an alias row, and set `resolved_taxon` only where the evidence supports it:

- `PONGO-YN85-38` → `resolved_taxon = Pongo abelii`, `taxon_conflict = TRUE`.
- `CAT-150`, `CAT-151` → `resolved_taxon = Pongo abelii` (subspecies field).
- HARRY, BRIGGS, 0475, and the remaining catalog rows → `resolved_taxon = NA`
  (no evidence to place them Bornean vs Sumatran); they stay linked to the
  broad concept until an accession record resolves them.

### Concept level (`taxon_concept_registry.csv`)

Any **pooled mean** printed as "*Pongo pygmaeus*" from a pre-2001 source maps to
the concept `Pongo pygmaeus (s.l.)` with `decomposable = FALSE`. Its
`believed_composition` states the sample may contain Bornean + Sumatran (+
hybrid) animals. It is **never auto-rewritten** to *P. pygmaeus s.s.* or
*P. abelii*.

## The hard rule (for the merge / comparison)

```text
specimen measurement  -> may be reassigned to a modern species via resolved_taxon
                         (surfaces taxon_conflict; never silent)
pooled s.l. mean      -> pinned to Pongo pygmaeus (s.l.); never split into a
                         modern species (would fabricate composition)
```

This is distinct from the DeCasien cross-genus **duplicate** case (Disco): a
duplicate is *one* specimen entered twice under two genera (dedup); an s.l.
pooled mean is *many* specimens under one label (do not split).

## What remains unresolved

- Which of the unmarked catalog orangutans (CAT-149, 152, 153, 174, 180) and
  MacLeod 0475 / HARRY / BRIGGS are Bornean vs Sumatran. Needs Yerkes / Zilles
  accession or pedigree records.
- Whether catalog CAT-150 (M, `abeli`, Yerkes) **is** MacLeod YN85-38 (M,
  `ABELII`, Yerkes). Sex, species annotation, and source agree; the identifier
  systems differ. Marked as a candidate match, unconfirmed.
- Whether any published "*Pongo pygmaeus*" mean in the corpus was computed over
  a Bornean+Sumatran mix (see `pongo_provenance_audit.csv`).

## Sources cited

- MacLeod CE (2000), *The Cerebellum and Its Part in the Evolution of the
  Hominoid Brain*, PhD dissertation, Simon Fraser University — Appendix I,
  `MacLeod__2000_APPENDIXI.csv`.
- Groves CP (2001), *Primate Taxonomy*, Smithsonian Institution Press — split of
  *Pongo abelii* from *Pongo pygmaeus*.
- Master catalog `specimens info 151211.xls`, sheet `catalog`, rows CAT-147..180
  (parsed to `collection_specimens_parsed.csv`).
