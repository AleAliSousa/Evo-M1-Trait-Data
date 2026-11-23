# Merging Heuer et al. 2019 neocortical folding (MRI)

Compiles the Heuer et al. 2019 primate neocortical-folding dataset from the
paper's specimen-level source item into species-level merge outputs, following
the same compile pattern as `__merging_cerebellar_folding` and
`__merging_gyrification`. Surfaced in the app as the dataset
**"Neocortical folding (MRI)"** (requires the `std_heuer2019()` loader in
app.R — a code change plus redeploy, unlike the generic `std_merge()`
datasets).

## Scope: Heuer 2019 only, kept separate

Heuer 2019's folding measures come from **3-D MRI surface reconstructions**:
an absolute gyrification index defined as the ratio between the cerebral surface
area and the surface area of a sphere of the same volume, plus folding length, fold number,
fold wavelength (Lambda) and fold depth (Delta).

**Deliberately excluded from every other folding merge (kept completely
separate — never combined):**

- The **Zilles-method gyrification index** (`__merging_gyrification`): a 2-D
  coronal-contour ratio — a different construct from Heuer's 3-D AbsGI.
- The **Mota & Herculano-Houzel folding index** (`__merging_cortical_areas`):
  a surface-area/thickness scaling construct, again not interchangeable.

**Owner decision (2026-07-31): Zilles GI, Mota FI and Heuer MRI folding are
three separate methods and are never pooled.** This merge therefore contains
Heuer 2019 alone, as a single primary source.

## Hemisphere basis

Surface area and volume are **whole-cerebrum values, both hemispheres
combined** (the human specimen maximum, 236,309 mm², is ~2× the known
per-hemisphere total). The surface column is **not** pooled into
`__merging_cortical_areas`, whose canonical `CorticalSurface_Area.mm2` is per
hemisphere; a halved join would be a separate curator decision.

## Source

| Reference | source item | specimens | species | role |
|---|---|---|---|---|
| `Heuer_etal_2019` | `Heuer_etal_2019/Heuer_etal_2019_Data.csv` | 65 | 34 | **primary** (authors' own measurements) |

The source item was built from the authors' own archive,
**github.com/neuroanatomy/34primates** (`data/derived/stats/stats.csv` joined
to the specimen→species lookup `src/10kTrees_34PrimateSpecies.tsv`). The
Zenodo record cited in the paper folder (doi:10.5281/zenodo.2538751) holds
only Figure-2 poster PDFs — no data table. No convex-hull surface column
exists in the archived table (AbsGI is published; the hull area itself is
not).

Species names in the source item are the authors' Wilson & Reeder names
verbatim, including subspecies forms and one subgenus form
(`Trachypithecus (Trachypithecus) germaini`), normalised by the project
resolver at compile time.

## Aggregation

Specimen → species by **arithmetic mean** within each printed species, per
measure. The long file also carries `Value_median`, `value_min`, `value_max`
and `n_specimens` per row so the aggregation stays auditable;
`heuer2019_source_species_ids.csv` lists the specimen IDs behind each species
row. Specimen counts per species range from 1 to 10 (*Homo sapiens* 10,
*Pan troglodytes troglodytes* 9, *Macaca fascicularis* 8, *Macaca mulatta* 6).

Values are kept **verbatim** — in particular the one small negative fold
depth (Delta = −0.0824343, the single *Microcebus murinus* specimen), which
the authors' own analysis scripts clip to 0. The merge does not clip, so the
*Microcebus murinus* `Fold_depth` value is negative.

## Species naming

Follows SPECIES_NAMING.md v1, as in the other merges: `Species` stays the
printed name (the join column); `_keys/resolve_species.R` adds
`species_printed`, `accepted_name`, `species_basis` and `reidentified`.
Of the 34 printed names, 32 resolve (including two `subspecies_assign`:
*Gorilla beringei graueri* → *Gorilla beringei*, *Pan troglodytes
troglodytes* → *Pan troglodytes*). Two are **unresolved** and are carried
under their printed names, never dropped:

- `Gorilla gorilla gorilla` — no spoke or hub entry covers the trinomial
  (its sibling *Gorilla beringei graueri* does resolve).
- `Trachypithecus (Trachypithecus) germaini` — subgenus form, unmatched.

Both are candidates for future `_keys` spoke rows; no name was silently
dropped or lumped in this build.

## Traits merged

| Measure | meaning | unit |
|---|---|---|
| `Cerebral_surface_area` | total pial surface, both hemispheres | mm2 |
| `Cerebral_volume` | cerebral volume, both hemispheres | mm3 |
| `Absolute_gyrification_index` | cerebral surface area / surface area of a sphere of the same volume (Heuer's definition; not the Zilles GI) | ratio |
| `Folding_length` | total length of the curves dividing sulci from gyri (mean-curvature map) | mm |
| `Folding_number` | estimated number of sulci (regions of negative mean curvature) | count |
| `Fold_wavelength` | mean fold wavelength (Lambda) | mm |
| `Fold_depth` | mean fold depth (Delta) | mm |

## Outputs

| file | contents |
|---|---|
| `heuer2019_long.csv` | Species × Measure rows (238 = 34 species × 7 measures): `Species, Measure, Units, Value` (species mean), median/min/max, `n_specimens`, `source`, naming columns |
| `heuer2019_wide.csv` | one row per species, one column per Measure |
| `heuer2019_source_species_ids.csv` | per-species audit: resolution + specimen IDs aggregated |
| `heuer2019_definitions.csv` | variable definitions for the 7 measures (house schema) |

Rebuild: `Rscript __merging_heuer2019/heuer2019_compiled.R` from anywhere —
the script locates the repo root from its own path and reads
`Heuer_etal_2019/Heuer_etal_2019_Data.csv` plus `_keys/resolve_species.R`.
