# Smaers_etal_2017_TableS1part1

## Source

PDF: `Smaers-2017-Exceptional Evolutio.pdf`; supplement `mmc1.pdf` (and the publisher Excel
`Smaers_mmc1.xlsx`, sheet "Table 1"). Paper: Smaers, J. B., Gómez-Robles, A., Parks, A. N., &
Sherwood, C. C. (2017). *Exceptional Evolutionary Expansion of Prefrontal Cortex in Great Apes and
Humans.* Curr Biol 27(5), 714–720. https://doi.org/10.1016/j.cub.2017.01.020

This is **part 1 of 2** of supplemental **Table S1**. Table S1 prints two different measure
classes — the "Smaers data" volume block and the "Brodmann data" surface-area block — which the
original single-table build wrongly merged. Part 1 is the **volume** block only: 4 cortical regions
(primary visual, prefrontal, other cortical association areas, frontal motor) × {gray, white} = 8
columns, 19 primate species. (Part 2 = the surface areas; see
`Smaers_etal_2017_TableS1part2.README.md`.)

## Files

| Path | Role |
|---|---|
| `Smaers_etal_2017_TableS1part1_snapshot.xlsx` | **Snapshot** (sheet `volumes`): Table S1's Smaers volume block reproduced journal-style (caption row; "Gray matter volume" / "White matter volume" tier-1 span; the 4 region sub-headers ×2; 19 species). Values taken from `Smaers_mmc1.xlsx`. |
| `Smaers_etal_2017_TableS1part1.R` | Reformat → `Smaers_etal_2017_TableS1part1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Smaers_etal_2017_TableS1part1_definitions.csv` | Data dictionary (10-col schema; `Measure = Volume`). |
| `comparison/Smaers.csv` | Pre-existing formatted volume table, audited only. |
| `comparison/Smaers_etal_2017_TableS1part1_compare_to_Smaers_csv.R` | QA: snapshot vs `Smaers.csv`. |
| `__Public/comparative-data/10.1016%2Fj.cub.2017.01.020_TableS1part1volumes.tsv` | Shared public copy. |

## Provenance (these volumes are compiled, not newly measured)

Per the Table S1 / supplement Data section: prefrontal & frontal-motor volumes come from **Smaers
2010 [S1]** + **Smaers 2011 [S2]**; primary visual from **de Sousa et al. 2010 [S6]**; "other
cortical association areas" is defined as **neocortex − frontal lobe − primary visual**; other brain
data from **Stephan et al. 1981 [S7]**. All from the same C&O Vogt-Institute specimens.

### Primary vs secondary — per column (confirmed by value-match)

This table is a **MIX of primary and secondary data**. `__merging_volumes/crosspub_value_match.R`
matched every column to its source by value (see `crosspub_Smaers2017_FINDINGS.md`):

| Column | Source | Role | Value-match |
|---|---|---|---|
| `primary_visual_gray/_white` | de Sousa 2010 [S6] (← Frahm 1984 V1) | **secondary** | **= Frahm 1984 area striata, exact (14 spp)** |
| `prefrontal_gray/_white` | Smaers 2010 [S1] + Smaers 2011 [S2] | primary (Smaers' own) | **= Smaers 2011 Suppl. Table 2** (anterior section-5) |
| `frontal_motor_gray/_white` | Smaers 2010/2011 | primary (own) | **no public table** (posterior section never published — unverifiable) |
| `other_association_gray/_white` | derived (neocortex − frontal − V1) | **secondary / derived** | no single source |

**Merge consequence:** in `__merging_volumes`, **do NOT add this table's `primary_visual`** — it is
Frahm 1984's area striata (already Tier 1) and would double-count; `prefrontal` likewise duplicates
the Smaers 2011 raw. This table is registered as `Data role = both (compilation)` in `__ReadMe.xlsx`
with a `Flags pre-addressed` note.

**Two flags carried in the definitions and reproduced from the source as-is:**

1. **Units.** The supplement labels volumes `mm³`, but the values in fact scale as `cm³` (they
   reproduce Smaers 2011, which is cm³). The snapshot keeps the printed `mm³` label; downstream
   code should treat the numbers as cm³.
2. **Prefrontal + frontal motor ≠ frontal lobe.** Prefrontal is the cumulative volume of the
   **anterior 5** of 20 frontal sections; frontal motor is the **posterior 5** sections (the two
   ends of the lobe). Their sum is only ~37 % of total frontal-lobe volume — see
   `primary_source_checks/frontal_lobe_source_and_partition.md`. Note also the frontal-motor column
   is not independently verifiable: Smaers 2011 published only the anterior (prefrontal) section.

### Standardized-key implications

All eight Table S1 volume columns represent **both hemispheres** and therefore
map to unsuffixed standardized terms after cm3 -> mm3 conversion. They must not
be keyed to `_left` or `_right` terms. The region names also retain the source's
operational definitions:

- `prefrontal_*` -> `PrefrontalCortex_*` as the anterior-five-section proxy;
- `frontal_motor_*` -> `FrontalMotor_*` as the posterior-five-section proxy;
- `other_association_*` -> `AssociationCortex_*` as the published residual; and
- `primary_visual_*` -> area-striata grey/white terms.

The residual uses the **whole frontal lobe**, not `prefrontal + frontal_motor`.
The exact definition and laterality are recorded per column in
`reference_tables/Smaers_etal_2017_TableS1part1_definitions.csv`. These keys are
valid for tracing the `Stephan_primates` compilation even though the modern
volume merge may skip the 2017 secondary/derived rows to avoid double-counting.

## Reformat → CSV

The R reads past the 3 header rows, names the 9 columns by position, drops empty rows, replaces
spaces in the species name with underscores (trinomials kept, e.g. `Gorilla_gorilla_gorilla`), adds
`source = "Smaers_etal_2017"`, and writes `Smaers_etal_2017_TableS1part1.csv` plus a
DOI-named TSV. (R is not in the build sandbox; the committed CSV/TSV were produced by a Python
mirror of this exact logic and will be regenerated when you run the R.)

Output columns: `species, primary_visual_gray, prefrontal_gray, other_association_gray,
frontal_motor_gray, primary_visual_white, prefrontal_white, other_association_white,
frontal_motor_white, source`. Current accepted names are applied later via `../_keys/Stephan/`.

## Checking → `comparison/`

Snapshot matched to `Smaers.csv` by species (normalised to genus + species so the snapshot's
trinomials match the csv's binomials), on the 7 shared columns (`Smaers.csv` lacks primary-visual
gray, which is therefore snapshot-only). **Verified: 19 matched, 0 value mismatches, no
snapshot-only / csv-only species.**
