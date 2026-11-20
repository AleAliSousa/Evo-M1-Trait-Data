# Merging gyrification data

Compiles a comparative dataset of the **whole-cortex gyrification index (GI)** across papers,
following the same `standardized_term` + compile pattern as `__merging_volumes`,
`__merging_cell_counts_isotropic_fractionator`, and `__merging_cortical_areas`.

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
| `Zilles_etal_2013_Table1` | Zilles_2013 | 45 (non-primate) | primary for the species Lewitus lacks; dependent elsewhere |
| `Zilles_etal_1989_Table1` | Zilles_1989 | 43 (primates; 56 individuals) | **primary** for the species it covers (the original GI measurements); Lewitus is the dependent carrier there |
| `Manger_etal_2012_Table1` | Manger_2012 | 28 (30 rows) | own measurements (21 rows) are an independent team; its 9 Pillay & Manger 2007 re-reports are **secondary** (last resort) |

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
- **Zilles 1989 vs Lewitus (added 2026-11-19): the dependency runs the other way.** Lewitus 2014's
  primate GI values are re-reports of Zilles et al. 1989 (Lewitus's reference [1]); on the 41 shared
  species the two agree to a median |difference| of 0.000. Zilles 1989 is therefore **primary** for
  the species it covers and Lewitus is the dependent carrier: the merged GI is the Zilles 1989
  species mean (per-individual hemisphere means averaged), Lewitus's value is retained alongside,
  and the overlap is flagged `citation_dependency = TRUE`. Zilles 1989's GI is printed per
  hemisphere; the merge's observation is the per-individual mean of the available hemispheres.
- **Manger 2012 (added 2026-11-19)** is an independent team for its 21 own-measurement rows; its
  9 re-reports of Pillay & Manger 2007 are **secondary** and are used only when no other team
  covers the species (in the current build they never win: all 9 species are covered by the
  lineage teams, and the values are retained in `GI_Manger2012_PM2007`).
- **Merged-value preference order:** Zilles_1989 > Lewitus_2014 > Zilles_2013 > Manger_2012 (own)
  > Manger_2012 (Pillay & Manger 2007 re-report). Dependent teams are never averaged.

### What that yields

**135 species**: **43** taken from Zilles 1989, **71** from Lewitus 2014, **11** Zilles-2013-only
(species Lewitus lacks), **10** from Manger 2012's own measurements, and **75** citation-dependent
overlaps (41 Zilles-1989 × Lewitus + 34 Lewitus × Zilles-2013) where both values are retained for
inspection. Lewitus and Zilles 2013 agree closely on their overlaps — only three differ by more
than 0.3 GI units: *Capra hircus domestica* (2.28 vs 1.81), *Equus caballus* (2.80 vs 2.40),
*Globicephala macrorhynchus* (5.24 vs 5.55). Zilles 1989 and Lewitus agree even more closely
(median |difference| 0.000 on 41 species); only *Ateles paniscus* (0.133) and *Pongo pygmaeus*
(0.110) differ by more than 0.1, so switching those species' merged value to the Zilles 1989 mean
moves it by at most 0.133.

*(Correction: this paragraph previously claimed 128 species — 113 Lewitus, 15 Zilles-only,
30 overlaps. Those figures were stale: the committed outputs at the time already held
**123 species** — 112 Lewitus, 11 Zilles-only, 34 dependent overlaps.)*

## Species aliases

To make the same animal join across sources, unambiguous same-species spelling variants are unified
(and Lewitus's printed typo `Odocoileus virginiatus` is corrected):

`Felis domestica`→`Felis catus`, `Sus scrofa domestica`→`Sus scrofa domesticus`,
`Equus burchelii`→`Equus burchelli`, `Capra aegagrus hircus`→`Capra hircus domestica`,
`Lama glama`→`Lama glama domesticus`, `Odocoileus virginiatus`→`Odocoileus virginianus`.

Genuinely distinct congeners are **kept separate**: *Bos taurus* vs *B. taurus indicus*,
*Ursus arctos* vs *U. maritimus*, *Tursiops aduncus* vs *T. truncatus*, *Globicephala melas* vs
*G. macrorhynchus*, and genus-level *Phoca sp.* / *Marmosa sp.*

Zilles_etal_1989_Table1 prints abbreviated names (unique to that table in this merge); each is
expanded to the full name the other sources use: `Alouatta senic.`→*Alouatta seniculus*,
`Avahi lan. lan.`→*Avahi laniger*, `Avahi lan. occ.`→*Avahi occidentalis*,
`Cercocebus alb.`→*Lophocebus albigena*, `Colobus badius`→*Piliocolobus badius*,
`Daubentonia mad.`→*Daubentonia madagascariensis*, `Galago demidovii`→*Galago demidoff*,
`Galago senegal.`→*Galago senegalensis*, `Lagothrix lagothr.`→*Lagothrix lagothricha*,
`Lemur alb.fulvus`→*Eulemur fulvus*, `Lemur mongoz`→*Eulemur mongoz*,
`Miopithecus tal.`→*Miopithecus talapoin*, `Nycticebus couc.`→*Nycticebus coucang*,
`Otolemur crassic.`→*Otolemur crassicaudatus*, `Propithecus verr.`→*Propithecus verreauxi*,
`Pygathrix nem.`→*Pygathrix nemaeus*, `Saguinus mid. tam.`→*Saguinus midas* (trinomina roll to
species level, as this merge is species-level). The two genus-level prints stay genus-level:
`Cercopithecus spec.`→*Cercopithecus sp.*, `Papio spp.`→*Papio sp.*
Manger_etal_2012_Table1 prints the bare binomen `Sus scrofa` for its domestic-pig row
(common name "Domestic pig", a Pillay & Manger 2007 re-report); it is unified to
*Sus scrofa domesticus* — no source in this merge prints bare `Sus scrofa` for a wild animal.

## Outputs

- **`gyrification_long.csv`** — one row per (Species, source) GI observation (267 rows). Columns:
  `Species, Standardized_Term, GI, source, team, ref, dependency_group` (plus the species-naming
  columns). Zilles 2013 species keep one row per printed reference value; Zilles 1989 keeps one
  row per individual (hemisphere-mean GI); Manger 2012 keeps one row per table row, with `ref`
  distinguishing its own measurements (`this study`) from its Pillay & Manger 2007 re-reports.
- **`gyrification_wide.csv`** — one row per species (135). Columns: `Species, GI` (the merged value),
  `source_used`, `GI_Lewitus2014`, `GI_Zilles2013_mean`, `GI_Zilles2013_n/min/max`,
  `GI_Zilles1989_mean`, `GI_Zilles1989_n/min/max`, `GI_Manger2012_own_mean`, `GI_Manger2012_own_n`,
  `GI_Manger2012_PM2007`, `manger_value_role`, `n_teams`, `citation_dependency`,
  `GI_abs_diff` (|Lewitus − Zilles 2013| on overlaps), `GI_diff_Z1989_Lewitus`.
- **`gyrification_source_species_ids.csv`** — provenance: which source contributed each species value.
- **`standardized_term_gyrification.csv`** (+ `standardized_term.R`, `standardized_term_by_reference/`)
  — the original→standardized column map, stacked per source.

## Rebuild

Run `gyrification_compiled.R` (reads the sources' public TSVs from `__Public/comparative-data/`;
regenerate a source TSV first if its snapshot/CSV changed). `standardized_term.R` restacks the term
map if a per-reference term file changes.

## Notes / future
- Zilles 2013 Table 1 contains **no primates** (primate GI is in that paper's Figure 2). Primate GI
  in this merge is anchored on Zilles 1989's original measurements (43 species), with Lewitus 2014
  covering the primates Zilles 1989 lacks.
- To add a future GI source, drop a `<Reference>_standardized_terms.csv` in
  `standardized_term_by_reference/`, add the Item name to `item_name` in `gyrification_compiled.R`,
  set its `team`, and decide its dependency relationship to the existing sources.
