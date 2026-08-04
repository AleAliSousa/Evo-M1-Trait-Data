# Merging gyrification data

Compiles a comparative dataset of the **whole-cortex gyrification index (GI)** across papers,
following the same `standardized_term` + compile pattern as `__merging_volumes`,
`__merging_cellcounts`, and `__merging_cortical_areas`.

## Scope: GI only

`GI` = the **Zilles-method gyrification index**: the ratio of the total (inner + buried) cortical
contour to the superficially exposed (outer) contour, measured on coronal sections. GI = 1 means no
folding; higher = more folded. This merge pools **only** measures computed on that definition.

**Deliberately excluded (kept completely separate — never merged):**

- The Mota & Herculano-Houzel **folding index (FI)** (`Mota_etal_2015`, `Mota_etal_2019`). FI is a
  different construct (surface-area/thickness scaling), not interchangeable with GI. Their
  exposed-surface-area columns belong with cortical-surface data (`__merging_cortical_areas`), not here.
- **Heuer et al. 2019 MRI folding** (`Heuer_etal_2019/`). A **3-D** surface-vs-convex-hull gyrification
  index plus folding length / wavelength / depth — a different method from the **2-D** Zilles
  coronal-contour GI (the paper presents it as an alternative to Zilles). **Owner decision
  (2026-07-31): the two kinds of gyrification data are kept completely separate and never combined.**
  Heuer's data is useful but is housed in its own folder and does not feed this merge; its surface-area
  columns would belong with `__merging_cortical_areas` if ever merged.

These tables are built to house convention in their own folders but do not feed this merge.

## Traits merged (standardized terms)

| Standardized_Term | meaning | unit |
|---|---|---|
| `Species` | accepted binomial (join key) | — |
| `GI` | whole-cortex gyrification index (Zilles method) | ratio (dimensionless) |

## Sources (this build)

| Reference | team | GI species | role |
|---|---|---|---|
| `Lewitus_etal_2014_TableS1` | Lewitus_2014 | 102 | **primary** (main compilation) |
| `Lewitus_etal_2014_TableS8` | Lewitus_2014 | 25 (11 new vs S1) | primary (fills species absent from S1) |
| `Zilles_etal_2013_Table1` | Zilles_2013 | 45 (non-primate) | primary for the 15 species Lewitus lacks; dependent elsewhere |

## Team-aware, citation-dependency-aware combine

Same rules as the blood-flow / volume merges:

- **Within a team (same paper), newest/authoritative wins.** Lewitus S1 and S8 are the same paper;
  S1 is authoritative and S8 only adds the 11 species missing from S1. Their GI values are
  **identical for all 14 shared species** (checked), so no conflict arises.
- **Across teams, average — UNLESS the sources are citation-dependent.** Zilles-2013 Table 1 is
  compiled partly *from* Lewitus 2014 (its source reference [7]) and uses the same Zilles GI method,
  so Lewitus-2014 and Zilles-2013 are **citation-dependent**. They are therefore **never averaged**.
  Rule applied: **prefer Lewitus** (the primary compilation); use **Zilles only for species Lewitus
  does not cover**. Every overlap keeps *both* raw values and is flagged.

### What that yields

128 species: **113** taken from Lewitus 2014, **15** Zilles-only (species Lewitus lacks), and
**30** citation-dependent overlaps where Lewitus is used but the Zilles value is retained alongside
for inspection. Lewitus and Zilles agree closely on the overlaps — only three differ by more than
0.3 GI units: *Capra hircus domestica* (2.28 vs 1.81), *Equus caballus* (2.80 vs 2.40),
*Globicephala macrorhynchus* (5.24 vs 5.55).

## Species aliases

To make the same animal join across sources, unambiguous same-species spelling variants are unified
(and Lewitus's printed typo `Odocoileus virginiatus` is corrected):

`Felis domestica`→`Felis catus`, `Sus scrofa domestica`→`Sus scrofa domesticus`,
`Equus burchelii`→`Equus burchelli`, `Capra aegagrus hircus`→`Capra hircus domestica`,
`Lama glama`→`Lama glama domesticus`, `Odocoileus virginiatus`→`Odocoileus virginianus`.

Genuinely distinct congeners are **kept separate**: *Bos taurus* vs *B. taurus indicus*,
*Ursus arctos* vs *U. maritimus*, *Tursiops aduncus* vs *T. truncatus*, *Globicephala melas* vs
*G. macrorhynchus*, and genus-level *Phoca sp.* / *Marmosa sp.*

## Outputs

- **`gyrification_long.csv`** — one row per (Species, source) GI observation (181 rows). Columns:
  `Species, Standardized_Term, GI, source, team, ref, dependency_group`. Zilles species keep one row
  per printed reference value.
- **`gyrification_wide.csv`** — one row per species (128). Columns: `Species, GI` (the merged value),
  `source_used`, `GI_Lewitus2014`, `GI_Zilles2013_mean`, `GI_Zilles2013_n/min/max`, `n_teams`,
  `citation_dependency`, `GI_abs_diff` (|Lewitus − Zilles| on overlaps).
- **`gyrification_source_species_ids.csv`** — provenance: which source contributed each species value.
- **`standardized_term_gyrification.csv`** (+ `standardized_term.R`, `standardized_term_by_reference/`)
  — the original→standardized column map, stacked per source.

## Rebuild

Run `gyrification_compiled.R` (reads the sources' public TSVs from `__Public/comparative-data/`;
regenerate a source TSV first if its snapshot/CSV changed). `standardized_term.R` restacks the term
map if a per-reference term file changes.

## Notes / future
- Zilles 2013 Table 1 contains **no primates** (primate GI is in that paper's Figure 2). Primate GI
  in this merge therefore comes entirely from Lewitus 2014.
- To add a future GI source, drop a `<Reference>_standardized_terms.csv` in
  `standardized_term_by_reference/`, add the Item name to `item_name` in `gyrification_compiled.R`,
  set its `team`, and decide its dependency relationship to the existing sources.
