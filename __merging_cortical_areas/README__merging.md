# Merging cortical-area data

Compiles a comparative dataset of **number of cortical areas** and **cortical surface area** across
papers, following the same `standardized_term` + compile pattern as `__merging_volumes` and
`__merging_cellcounts`.

## Traits merged (standardized terms)

| Standardized_Term | meaning | unit |
|---|---|---|
| `Species` | accepted binomial (join key) | — |
| `n_cortical_areas` | total number of distinct cortical areas identified | count |
| `n_visual_areas` | number of visual cortical areas/fields | count |
| `n_somatomotor_areas` | number of somatomotor cortical areas | count |
| `CorticalSurface_Area.mm2` | total (neo)cortical sheet surface area (**whole cortex**) | mm² |
| `M1_Surface_Area.mm2` | **regional** — primary motor cortex (M1) surface area | mm² |

Project area unit = **mm²** (convert cm² × 100 if a source uses cm²).

**Whole-cortex vs regional.** `CorticalSurface_Area.mm2` is whole cortex; `M1_Surface_Area.mm2` is a
**regional** sub-trait (motor cortex only) and is **never pooled** with the whole-cortex surface — it
sits in its own column (`trait_class = regional` in `_long`). This is the slot for future regional
surfaces (V1, prefrontal, …).

**Species aliases.** To make the same animal join across sources, spelling variants are unified:
`Otolemur garnetti`→`Otolemur garnettii`, `Aotus nancymae`→`Aotus nancymaae` (Collins printed the
short forms; Young the correct ones), and Young's two *Papio* homotypic-synonym labels →
`Papio cynocephalus anubis`.

## Sources (this build)

| Reference | n_cortical_areas | n_visual | n_somatomotor | surface mm² | role |
|---|---|---|---|---|---|
| `Changizi__2001_Figure3` | ✓ (`n_areas`) | | | | primary⁵ |
| `Changizi_Shimojo_2005_Table1` | ✓ (`areas_shown`) | | | | primary⁵ |
| `Finlay_etal_2006_Table6.1` | ✓ (`total_areas`) | ✓ | ✓ | ✓ (`cortical_area_mm2`) | primary¹ |
| `Collins_etal_2010_DatasetS1` | | | | ✓ (per-hemisphere, from paper) | primary |
| `Young_etal_2013_Table1` | | | | ✓ **regional (M1 only)** → `M1_Surface_Area.mm2` | primary³ |
| `Turner_etal_2016_Table1` | | | | ✓ whole-cortex ("brain" surface), **case-deduped** | primary⁴ |
| `Krubitzer_Kaas_1990_Table1` | | reference² | | | not merged |

¹ Finlay cites Krubitzer & Kaas 1990a as a mapping source, so its counts partly derive from that
  lineage — flagged, not double-merged (different quantity).
³ Young 2013 is the Kaas lab's **M1-specific** companion to Collins 2010 (same flow-fractionator
  program). Only its `M1_area_mm2` enters here, as the **regional** `M1_Surface_Area.mm2` — its
  M1 cell/neuron densities belong to a cell-count merge, not this one. Its *Otolemur garnettii* /
  *Aotus nancymaae* specimens are shared with Collins 2010 (flagged in the source table), but since
  M1 area (regional) and Collins whole-cortex surface are different quantities, there is no
  double-count within this merge.
⁴ Turner 2016 reports whole-cortex ("brain") surface area for 5 Kaas-lab cases. It **shares specimens**
  with the other tables, so surface is ingested from a curated per-case file (`turner_2016_surface.csv`)
  with **case-level dedupe**: case **09‑27** = the Collins 2010 baboon → `exclude_duplicate_Collins2010`
  (Collins already contributes that specimen's surface); case **11‑31** = a normal baboon also in
  Young 2013b (which is excluded from merges) → **included here** as the merged surface source for it.
  New species it adds: *Macaca radiata* (case 12‑58, two hemispheres averaged), *Macaca nemestrina*
  (11‑47), *Macaca mulatta* (10‑50, a different specimen from Finlay's macaque → both kept, flagged).
  cm² → mm² ×100. (Turner's folder is now **fully built** — snapshot, `.R`, CSV, public TSV
  `10.1159%2F000446762_Table1.tsv`, definitions, README. This merge still reads the curated
  `turner_2016_surface.csv`; the build's comparison script audits the snapshot against that very file
  and reports **6/6 cases matched, 0 value mismatches** with `dedupe_status` agreeing, so re-pointing
  the merge at the TSV — which carries `case_number`, `hemisphere` and `dedupe_status` itself — would
  change no merged value. Left as a deliberate follow-up rather than an unaudited swap.)
² Krubitzer & Kaas 1990 Table 1 reports **relative %** of a fixed 8-field visual scheme
  (17,18,DL,DM,DI,FST,MT,MST), not absolute areas and with no surface area. Its "8" is a
  method-fixed field count, **not comparable** to Finlay's visual-area counts (19–23) — averaging the
  two would be meaningless. So it is **documented here but not merged numerically**; only its Species
  rows are kept in the term map.

### Collins 2010 surface area — from the paper, not the piece-sum
Collins Dataset S1 is per **tissue piece**. Summing pieces reproduces the paper's per-hemisphere total
for galago #2 (1849) and the baboon (18577), but **undercounts galago #1** (piece-sum 1138 vs the
paper's stated 2261 mm² — Dataset S1 omits ~10 of 46 pieces). So per-hemisphere totals are taken from
the **paper text** and kept in `collins_2010_surface_from_paper.csv` (one hemisphere per specimen).
Macaque (08-59) had no surface measured. The two galagos are one species (*Otolemur garnetti*).

## Sources considered but NOT merged (why)
- `cercor/bhy315 Table4` — within-species **baboon** epilepsy groups (AN/EB/LB/SC), no Species column → not comparative.
- `ar.a.20114` (V1_surface_cm2), `cub.2017.01.020` (Smaers 2017 regional surfaces), `fnana.2013.00035` (% cortical area) — **regional or relative**, not whole-cortex totals.
- `zool.2020.125753` — **cerebellar** surface, not cortex.
- `1741-7007-5-18` (Karbowski 2007) — its `n_areas` column is incidental/all-NA (metabolic dataset).

These are recorded here so a future curator can add regional-surface sub-traits deliberately.

## Outputs
- `cortical_areas_long.csv` — one row per (Species × Standardized_Term × source): every contributed value.
- `cortical_areas_wide.csv` — species × trait summary: mean across independent sources, `n_sources`,
  `sources`, and a `conflict_flag` where sources disagree strongly (CV > 0.15).
- `standardized_term_cortical_areas.csv` — all per-reference term maps stacked.
- `cortical_areas_source_species_ids.csv` — printed → accepted species names per source.

## Resolution rule
One row per (Species × trait × source) in `_long`. In `_wide`, values from **independent sources** are
averaged; large disagreements are **flagged, not silently pooled**. Note: Changizi and Finlay count
"areas" very differently (e.g. cat 23 vs 30; macaque 28 vs 54), so `n_cortical_areas` conflicts are
expected and surfaced by `conflict_flag` — a curator decides, they are not auto-reconciled.

⁵ **Changizi lineage supersede.** Changizi & Shimojo 2005 (`areas_shown`) is the same author's revised
count and **supersedes** Changizi 2001 (`n_areas`) for shared species (11): the 2001 row stays in
`_long` with `status = superseded_by_Changizi_Shimojo_2005` but is **excluded from `_wide`**. Only
Changizi 2001's species that C&S 2005 lacks (**Homo sapiens**) stay active from 2001. C&S 2005 also
adds new species (*Mus musculus, Rattus norvegicus, Tupaia belangeri, Ornithorhynchus anatinus,
Macroderma gigas, Mustela putorius furo, Soricidae sp.*). Finlay (a different author) is **not**
superseded — its counts remain independent contributors, so Changizi-vs-Finlay conflicts persist.
C&S 2005's `n_areas_extrapolated` (modeled), Table 2 `n_areas_reported` (≤5 primary areas), the per-area
% of neocortex, brain mass/EQ, and the connectivity Tables 3–5 (different measure class) are **not**
merged here. `_long` carries a `status` column (active / superseded_*).

### Species-name audit (C&S 2005 confirms Changizi 2001)
Because C&S 2005 prints explicit binomials for the same author's animals, it was used to audit the
common-name→binomial guesses in `Changizi__2001/common_name_to_species.csv` (see its `CS2005_check`
column). 10 confirmed; **1 corrected**: Changizi 2001 "hedgehog" was *Erinaceus europaeus* (a
Finlay-based guess) → **`Atelerix albiventris`** (C&S 2005 Table 1, Krubitzer et al. 1995, brain 3.273 g).
Finlay 2006's hedgehog remains *Erinaceus europaeus* — a genuinely different species, so the two are
now kept apart in the merge.

## Definitions
`cortical_areas_definitions.csv` documents every standardized term with its **measurement basis**
(one row per term × source for the surface trait). Read it before combining these values.

## Are the surface data compatible? (audit)
**Yes — in kind.** All three surface sources report the **same quantity**: the *total cortical sheet
area* — the fully **unfolded** cortical mantle (buried/sulcal cortex included), **per hemisphere**,
in **mm²**. Each is measured by physically **flattening** the cortex:
- `Finlay_etal_2006` — "total cortical sheet area" from Kaas & Krubitzer flattening studies.
- `Collins_etal_2010` — neocortex separated from white matter and manually flattened (per-hemisphere
  totals from the paper text).
- `Turner_etal_2016` — neocortex manually flattened, piece surfaces measured in ImageJ (reported in
  cm² → ×100 to mm²).

This is the *total* sheet, **not** the exposed/pial surface. It is therefore **not** interchangeable
with an exposed-surface measure such as Mota & Herculano-Houzel's `AG`; to add Mota here you must use
`AG × FI` (total), per hemisphere. See `cortical_areas_definitions.csv`.

**Value-level caveats (basis is fine; the numbers still need a curator's eye):**
- **Macaca mulatta** — Finlay 10,598 vs Turner 15,230 mm² (~44% apart, **different specimens**);
  surfaced by `conflict_flag`. Same basis, genuine between-study/between-individual disagreement.
- **Papio cynocephalus anubis** — Collins 18,577 (case 09-27) and Turner 23,400 (case 11-31) are
  **two different individuals**; the wide mean pools them (Turner's 09-27 duplicate is correctly
  excluded, so no double-count).
- **Otolemur garnettii** — two Collins hemispheres (2,261 + 1,849) averaged to one per-species value.
- Species means therefore mix individuals across studies; `_long` keeps every raw value for auditing.

## Adding a paper
1. Build the paper (printed name + trait columns in its public TSV).
2. Add `standardized_term_by_reference/<Item name>_standardized_terms.csv`.
3. Add the Item name to the `item_name` vector in `cortical_areas_compiled.R`.
4. Re-run `standardized_term.R`, then `cortical_areas_compiled.R`.
