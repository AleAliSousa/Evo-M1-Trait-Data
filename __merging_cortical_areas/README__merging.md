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
| `CorticalSurface_Area.mm2` | total (neo)cortical sheet surface area (**whole cortex**, per one hemisphere) | mm² |
| `CorticalExposedSurface_Area.mm2` | **exposed** (outer-envelope) cortical surface, per one hemisphere — never pooled with the total sheet | mm² |
| `CorticalThickness.mm` | mean cortical grey-matter thickness, one hemisphere | mm |
| `FoldingIndex_MHH` | Mota & Herculano-Houzel folding index FI = AG/AE — **not** the Zilles GI, never pooled with GI | — |
| `M1_Surface_Area.mm2` | **regional** — primary motor cortex (M1) surface area | mm² |
| `V1_Surface_Area.mm2` | **regional** — primary visual cortex (V1) surface area | mm² |
| `V2_Surface_Area.mm2` | **regional** — second visual area (V2) surface area | mm² |
| `Prefrontal_Surface_Area.mm2` | **regional** — prefrontal (granular frontal) surface, Brodmann partition | mm² |
| `OtherAssociation_Surface_Area.mm2` | **regional** — Brodmann's residual "other association" category | mm² |
| `FrontalMotor_Surface_Area.mm2` | **regional** — Brodmann's agranular frontal block (**not M1** — includes premotor) | mm² |

Project area unit = **mm²** (convert cm² × 100 if a source uses cm²).

**Whole-cortex vs regional.** `CorticalSurface_Area.mm2` is whole cortex; `M1_Surface_Area.mm2` is a
**regional** sub-trait (motor cortex only) and is **never pooled** with the whole-cortex surface — it
sits in its own column (`trait_class = regional` in `_long`). This is the slot for future regional
surfaces (V1, prefrontal, …).

**Species aliases.** To make the same animal join across sources, spelling variants are unified:
`Otolemur garnetti`→`Otolemur garnettii`, `Aotus nancymae`→`Aotus nancymaae` (Collins printed the
short forms; Young the correct ones), and Young's two *Papio* homotypic-synonym labels →
`Papio cynocephalus anubis`. **Added 2026-08-25 (Mota printed-name repairs):** Mota 2019 prints
`Girafa camelopardalis` and `Tragelaphus stripceros` (typos), both papers misspell *Dasyprocta
prymnolopha* (2015 `promnolopha`, 2019 `primnolopha`), and the olive baboon appears as
`Papio anubis` (2019) / `Papio anubis cynocephalus` (2015) — all unified. Without these the
Mota-lineage supersede misses and one animal splits into two Species rows.

## Sources (this build)

| Reference | n_cortical_areas | n_visual | n_somatomotor | surface mm² | role |
|---|---|---|---|---|---|
| `Changizi__2001_Figure3` | ✓ (`n_areas`) | | | | primary⁵ |
| `Changizi_Shimojo_2005_Table1` | ✓ (`areas_shown`) | | | | primary⁵ |
| `Finlay_etal_2006_Table6.1` | ✓ (`total_areas`) | ✓ | ✓ | ✓ (`cortical_area_mm2`) | primary¹ |
| `Collins_etal_2010_DatasetS1` | | | | ✓ (per-hemisphere, from paper) | primary |
| `Young_etal_2013_Table1` | | | | ✓ **regional (M1 only)** → `M1_Surface_Area.mm2` | primary³ |
| `Turner_etal_2016_Table1` | | | | ✓ whole-cortex ("brain" surface), **case-deduped** | primary⁴ |
| `Collins_etal_2016_Table1` | | | | ✓ whole-cortex + **regional V1/V2** (chimp); M1 superseded⁶ | primary⁶ |
| `Mota_Herculano-Houzel_2015_TableS1` | | | | ✓ total surface (own cols) + `FoldingIndex_MHH` + thickness⁷ | primary⁷ |
| `Mota_etal_2019_SupplementaryTableS1` | | | | ✓ total + exposed surface + thickness⁷ | primary⁷ |
| `Smaers_etal_2017_TableS1part2` | | | | ✓ **regional** V1/prefrontal/other-assoc/frontal-motor (10 primates) | **secondary**⁸ |
| `Brodmann__1913_Table1` | | | | ✓ whole-cortex, one hemisphere, **34 taxa across mammal orders** | primary⁹ |
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
⁶ **Collins 2016 (added 2026-08-25).** One chimpanzee (Texas Biomedical female, specimen crosswalk
  `KAAS-PAN-11_38`), right hemisphere flattened, areas by structure (cm² → ×100). Wired:
  whole cortex (34,100 mm²) → `CorticalSurface_Area.mm2`; V1 (3,504) → `V1_Surface_Area.mm2`;
  V2 (2,869) → `V2_Surface_Area.mm2`; M1 (2,497) → `M1_Surface_Area.mm2` **as
  `superseded_by_Young_etal_2013`** — Young 2013 measured the SAME chimp (probable link; M1 2,700 mm²,
  boundary difference), and Young is the M1-dedicated paper, so Young keeps M1 and the two are never
  averaged. The "somatosensory block", "premotor block" and "Prefrontal Cortex" rows are dissection
  blocks with arbitrary boundaries — provenance only, **not wired**. Its left-hemisphere V1 row is a
  serial-section **volume**, excluded by the area filter. This closes the "deliberate decision" hold
  recorded in `Collins_etal_2016/…README.md`.
⁷ **Mota lineage (added 2026-08-25).** Own-measurement columns only; Mota 2015's `_other` columns are
  values compiled from other papers (secondary) and are **never merged** (reviews-are-roadmaps rule).
  Mota 2019's `N` (cortical neurons) is likewise skipped here, and its `VT/VG/VW` cortical volumes are
  **HELD** pending a `__merging_volumes` overlap audit. Both tables report **one hemisphere**.
  **Supersede:** 2019 re-reports the same hemisphere measurements as 2015 (AT values identical where
  both print, e.g. agouti 1412.7/1413, kudu 22,203, giraffe 40,128), so for `CorticalSurface_Area.mm2`
  and `CorticalThickness.mm` the 2015 row is `superseded_by_Mota_etal_2019` wherever 2019 has the
  species; after the alias repairs, **all 24** 2015 own-surface species are superseded. `FoldingIndex_MHH`
  exists only in 2015 and stays active; `CorticalExposedSurface_Area.mm2` exists only in 2019.
⁸ **Smaers 2017 part2 = Brodmann 1909, ingested as a SECONDARY (added 2026-08-25, owner decision).**
  The surface block in Smaers 2017 Table S1 reproduces Brodmann (1909)'s 4-region cytoarchitectonic
  partition (per-primary audit: `Smaers_etal_2017/Smaers_etal_2017_TableS1_primary_sources.csv`).
  The Brodmann-1909 primary is not built, so per the reviews-are-roadmaps rule this is a deliberate
  Tier-2-style ingestion; **if the 1909 primary is ever built it supersedes these rows.**
  *Additivity audit:* the four regions sum **exactly** to Brodmann 1913's per-hemisphere totals for
  marmoset (1,649), gibbon (16,301) and chimp (39,572) — confirming one-hemisphere basis — and to
  within 4% of the human "Durchschnitt". **Mandrill fails by exactly +10,000** (sum 31,321 vs total
  21,321): a misprint in one of the two sources, most plausibly other-association 23,422 → 13,422.
  That one cell is `excluded_additivity_vs_Brodmann1913` (kept in `_long`, out of `_wide`; not
  repaired). Species arrive underscore-joined; the chimp trinomial is aliased to *Pan troglodytes*.
  Its *Papio cynocephalus* and *P. hamadryas* are two separate Brodmann taxa — NOT aliased to the
  Kaas-lab *Papio cynocephalus anubis*. `FrontalMotor` ≠ M1 (includes premotor): never pool.
⁹ **Brodmann 1913 Table 1 (added 2026-08-25).** Total cortical surface (Rindenfläche) of ONE
  hemisphere for 38 taxa spanning every mammal order — the merge's first non-Kaas, non-Mota
  broad-taxon surface source. Of the five human rows only **"Europäer: Durchschnitt" (112,471 mm²)**
  enters; Maximal-/Minimalwert (envelope of the same series) and the "Naturmenschen"/"Idioten"
  subset rows (the latter pathological) are excluded in the bespoke block and documented in
  `Brodmann__1913/`. Historical planimetry: method-level disagreement with modern sources is
  expected and surfaced by `conflict_flag` (cat 4,474 vs Finlay 3,015/Mota 3,342; mouse 205 vs Mota
  148; lion 21,792 vs Mota 14,876; Tasmanian devil 1,807 vs Mota 1,140). One flag is NOT method
  spread: **Trichosurus vulpecula** — Brodmann 1,547 vs Finlay 208.35 (×7.4).
  *Update (2026-08-25, source-attribution audit):* the Trichosurus value is one instance of a
  **systematic low bias in Finlay's traced surfaces for small mammals/marsupials** (galago 383 vs
  Collins' directly flattened 1,849–2,261; hedgehog 107 vs 575; opossum 270 vs 804; mouse 51 vs
  148–205) — consistent with tracing mapped-region-only mounts or not-to-scale review schematics.
  No cited primary even exists for Trichosurus, Sminthopsis, Erinaceus, or the mouse/rat surfaces.
  Per-species attribution: `Finlay_etal_2006/Finlay_etal_2006_Table6.1_source_attribution.csv`.
  **OWNER DECISION (2026-08-25): the WHOLE Finlay 2006 source is flagged.** Every
  `Finlay_etal_2006_Table6.1` row is held out of `_wide` with
  `status = flagged_pending_ProjectKaskan_check` (kept in `_long`), and the registry row carries a
  matching whole-paper flag in "Flags active (skips)". Verification plan: once the Project Kaskan
  remeasuring dataset (restricted repo) is built, check Finlay's surfaces and area counts against
  it, then unflag per column. Side effect until then: `n_visual_areas` / `n_somatomotor_areas`
  had Finlay as their only source and drop out of `_wide`; `n_cortical_areas` keeps Changizi 2001 /
  C&S 2005; whole-cortex surface loses Finlay's 20 species-values (wide: 93 → 82 species).
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

This is the *total* sheet, **not** the exposed/pial surface.

**Correction (2026-08-25): Mota & Herculano-Houzel's `AG` IS the total surface.** An earlier version
of this note (and of `Mota_etal_2015/Mota_etal_2015_definitions.csv`) called AG "exposed" and
prescribed `AG × FI` to totalize it — that would have **double-folded** the values. The paper defines
the folding index as "the ratio of total surface area AG to exposed surface area AE" (FI = AG/AE;
AE = AG for lissencephalic species, FI = 1). The numbers agree: Mota 2019 cat AT = 3,342 mm² vs
Finlay's *total* 3,015 mm² (not ~2× it), and mouse AT 147.8 ≈ AE 145. So AG (2015 own) and AT (2019)
map **directly** to `CorticalSurface_Area.mm2`, per one hemisphere; AE gets its own term
`CorticalExposedSurface_Area.mm2`. The definitions file was corrected the same day. Since Mota's
surfaces are reconstructions of dissected hemispheres rather than physical flattening, between-method
disagreement with the Kaas flattening values is expected and surfaced by `conflict_flag`
(e.g. *Aotus trivirgatus* Finlay 5,486 vs Mota 2,214 — flagged, curator's eye needed; the Collins 2010
owl-monkey hemisphere, 2,036, sides with Mota).

### Mota 2019 printed-thickness errors (repaired in the merge, 2026-08-25)
Mota defines mean thickness as **T = VG/AG**; 31 of 38 printed T values satisfy VG/AT exactly. Six
rows (*Cavia porcellus, Dasyprocta prymnolopha, Hydrochoerus hydrochoeris, Callimico goeldii,
Macaca radiata, M. fascicularis*) instead print the **AT/AE folding ratio** in the T column
(equality to 3 decimals), and *Sarcophilus harrisii* prints **1198** (decimal slip). Where the same
hemisphere appears in Mota 2015 (AG = AT identical), the 2015 printed T equals VG/AT — independent
confirmation for four of the six. Nested error: *Cavia*'s printed VG (412.4) fails VG + VW = VT
(only failure in an additivity sweep of all 38 rows); recovered as VT − VW = 812.4, giving
T = 1.515 = the 2015 printed value for the same hemisphere. The compile script substitutes the
definitional VG/AT (with the Cavia VG repair) wherever printed T deviates >5% from it; the frozen
TSV keeps the printed numbers. Same repair policy as the Sherwood 2004 en-dash artefacts.

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
