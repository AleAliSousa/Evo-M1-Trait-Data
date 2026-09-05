# Merging metabolic data

Pipeline for compiling the comparative **brain metabolic-rate** dataset — the metabolic
counterpart of `__merging_volumes/` and `__merging_cellcounts/`, and the merge named as
planned in `__HOWTO_build_a_dataset_file.md` §10. It supersedes the earlier prototype in
`__energetics_comparison/` (Heiss + Kaufman only; Karbowski was excluded there because its
source xlsx was OCR-garbled — that table has since been parsed, so it is now included).

**Scope: brain only.** Regional and whole-brain *cerebral* metabolic rate. It deliberately
does **not** include whole-body / basal metabolic rate — none of the three sources report it
(they are all cerebral). If body BMR is wanted later it needs a separate source and its own
measure class.

## Measures

Two **measure classes** are emitted, tagged in the `measure_class` column. They are never
pooled with, or averaged against, each other.

### Mass-specific rates — `cerebral_metabolic_rate`, `cerebral_perfusion`

| Measure | Meaning | Unit (project standard) | Species |
|---|---|---|---|
| `CMRgl`  | cerebral metabolic rate for glucose | µmol / 100 g / min | 14 |
| `CMRO2`  | cerebral metabolic rate for oxygen  | µmol / 100 g / min | 9 |
| `CBF`    | cerebral blood flow (perfusion)     | mL / 100 g / min | 10 |

Karbowski reports CMRgl/CMRO2 per **gram**; the build multiplies by 100 to reach the
per-100 g project standard.

### Absolute whole-brain totals — `cerebral_absolute_rate`

| Measure | Meaning | Unit | Species |
|---|---|---|---|
| `Total_glucose_utilization` | whole-brain glucose use | µmol / min | 10 |
| `Total_O2_consumption`      | whole-brain oxygen use  | mL / min   | 7 |

Printed by Karbowski Tables S1/S2, whole brain only, one row per primary reference. These
are **derived** quantities — that paper's own mass-specific rate × brain mass — reported by
Karbowski alone, so they are *not independent* of the rates above and must never be averaged
against them. They are carried because absolute whole-brain glucose and oxygen use is the
quantity that compares directly against whole-body BMR (`__merging_body_ecology`,
`BMR_wholeanimal` mL O2/h) and against the fossil-hominin BGU estimates in
`__merging_fossil_brain_glucose` (same unit, µmol/min). They are already whole-brain
quantities and are **not** rescaled.

An earlier version of this merge excluded them on the grounds that they are a different
measure class. They are — hence the separate `measure_class` value, which is what keeps the
pooling apart, rather than dropping the data.

## Sources and their data role

| Source | Role | What it contributes |
|---|---|---|
| `Heiss_etal_2004`  | **primary**   | *Homo sapiens* regional CMRgl (PET), one study. |
| `Kaufman__2004` (A1–A14) | **secondary** (compilation) | 14 brain regions × up to 3 measures, **one row per primary study** with its own citation, sample size, and anesthesia state. Table A15 (Kaufman's own species means) is **not** used — we re-derive means from the study rows. |
| `Karbowski__2007` (S1–S23) | **secondary** (compilation) | 21 regions of CMRgl (+ whole-brain CMRO2), **one row per primary reference**. Karbowski's own `average <species>` rows are **dropped**. |

## Why "compilation-aware" resolution (not simple team-averaging)

`__HOWTO §9` says **only primary data is merged**, and Karbowski's own ReadMe warns that a
metabolic merge "should draw on the primary sources, not on this compilation." Kaufman and
Karbowski are both compilations of *other labs'* primary measurements, and they cite
**overlapping** primary studies. Averaging their published species-means as if they were two
independent teams would double-count every study they share.

So instead of team-averaging, the pipeline:

1. Pulls Kaufman (A1–A14) and Karbowski (S1–S23) down to the **primary-study level**, each row
   carrying its original literature reference.
2. Normalises each reference to a **first-author + year key** (`(De Voider et al., 1997)` and
   `De Volder et al 1997` → `de1997`; OCR variants collapse correctly).
3. **Dedupes studies reported by both** compilations within a Species × Region × Measure cell,
   keeping the Kaufman datum (study-level, conscious-confirmed) and dropping the Karbowski copy.
   Every collision is logged in `cerebral_metabolic_rate_dedupe_report.csv` (**37** shared studies removed —
   exactly the double-counting a naïve merge would introduce).
4. Averages the value **within each distinct study first**, then **across distinct studies** —
   so each independent primary measurement counts once regardless of how many compilations
   reprinted it.

**Anesthesia filter.** Explicitly anesthetized rows (392, Kaufman) are excluded from the merged
means (anesthesia strongly depresses CMR; matches Kaufman's own conscious-only A15 convention).
Conscious and unknown-state rows are kept. All rows, including anesthetized, stay in
`cerebral_metabolic_rate_unfiltered.csv` with a `conscious` flag.

## Steps

1. **Standardized term list** — `standardized_term.R`
   - Input: one term file per source in `standardized_term_by_reference/`
     (`Original_Term, Reference, Standardized_Term`).
   - Output: `standardized_term_cerebral_metabolic_rate.csv` (all stacked).
2. **Compile** — `cerebral_metabolic_rate_compiled.R` (house-style) **or** `build_cerebral_metabolic_rate_merge.py`
   (the tested builder that generated the shipped CSVs; R was unavailable in the build
   environment, same arrangement as the Karbowski build — both implement the same pipeline).
   - Outputs: `cerebral_metabolic_rate_long.csv`, `cerebral_metabolic_rate_wide.csv`.
   - Provenance/QA: `cerebral_metabolic_rate_unfiltered.csv`, `cerebral_metabolic_rate_dedupe_report.csv`,
     `cerebral_metabolic_rate_source_species_ids.csv`.

## Outputs

- **`cerebral_metabolic_rate_long.csv`** — one row per Species × Region × Measure:
  `Species, Region, Measure, measure_class, Units, Value, n_studies, Compilations, Volume_term`.
  `measure_class` is what keeps the mass-specific rates and the absolute whole-brain totals
  apart; do not aggregate across it.
  `Volume_term` links to the matching `*_Vol.mm3` term in `__merging_volumes` where one clean
  counterpart exists (else NA), for downstream metabolism-vs-size analysis.
- **`cerebral_metabolic_rate_wide.csv`** — one row per species, one column per `Region__Measure`.
- **`cerebral_metabolic_rate_unfiltered.csv`** — every primary-study datum with full provenance
  (compilation, table, printed species, raw + canonical region, conscious flag, reference).
- **`cerebral_metabolic_rate_dedupe_report.csv`** — the shared primary studies removed to avoid double-counting.
- **`cerebral_metabolic_rate_source_species_ids.csv`** — printed label → accepted species crosswalk.

Coverage: **263 merged cells · 16 species · 39 regions** — 214 mass-specific rate cells,
32 perfusion, 17 absolute whole-brain totals (11 species). CMRgl broadest; CMRO2/CBF mainly
Kaufman; regional richness mainly Karbowski + Kaufman; *Homo* the only species in all three.

### Rounding, and three cells that moved by 0.001

The 246 rate cells reproduce the previously shipped values except for **three**, each 0.001
higher: *Homo sapiens* thalamus CBF (54.238), *Macaca mulatta* thalamus CMRgl (44.313) and
*Mus musculus* neocortex CMRgl (94.863). All three are 8-study means that land exactly on a
`.0005` decimal boundary, and the old values were not stable: they came from naive float
accumulation, whose last bit — and therefore the third decimal — depended on the order the
source files happened to be read in.

Two changes make the output deterministic:

- **The mean** is accumulated with `math.fsum`, which returns the exactly-rounded sum
  whatever the order the study values arrive in. R's `sum()` agrees with it bit for bit on
  these data (verified by running both builders).
- **The rounding** is an explicit shared rule, `round3()`, written out identically in both
  builders: format to 9 decimal places with C `printf`, then round half away from zero at the
  4th decimal using exact integer arithmetic.

`round3()` exists because *neither language's native rounding would do*. Python's `round()`
rounds the stored double, so 73.2074999… → 73.207; R's `round()` rounds the shortest decimal
you would print, so 73.2075 → 73.208. Both are defensible, they disagree on a few percent of
multi-study means, and the twins would have silently diverged. The shared rule was checked
against 200,000 simulated multi-study means with **zero** R-versus-Python disagreements, and
running both builders on the real data now gives **263 identical cells with no differing
column**.

The residual double-rounding window in `round3()` is 5 × 10⁻¹⁰ wide — six orders of magnitude
below the two or three decimals the sources actually print.

## Species harmonisation

Kaufman labels are genus-level; Karbowski/Heiss are binomial. Genus labels are mapped to the
standard laboratory binomial the primary studies actually used (the same names Karbowski
assigns, e.g. dog → *Canis lupus familiaris*), flagged in `cerebral_metabolic_rate_source_species_ids.csv`.
Kaufman's explicit `M mulatta` / `M fascic` become *Macaca mulatta* / *M. fascicularis*; the
**generic `Macaca`** is kept separate as *Macaca sp.* rather than forced to a species. Karbowski
names already resolve through `_keys/Stephan/species_key.csv` (token `Karbowski2007`); a
`Kaufman2004` token can be added there if this crosswalk is promoted to the central key.

## Caveats

- **`Basal_ganglia` (Kaufman) is an aggregate** and is not 1:1 with the split nuclei
  (`Caudate_nucleus`, `Pallidum`, `Substantia_nigra`) that Karbowski/Heiss report; they are kept
  as distinct canonical regions, not pooled.
- **Cortical lobe ≈ cortex.** Heiss anatomical lobes (Frontal/Parietal/Temporal/Occipital) and
  Karbowski/Kaufman grey-matter "* cortex" are aligned under one canonical `*_cortex` label so
  the human series can be pooled; treat those as lobe≈cortex approximations.
- **Reference matching is first-author + year.** Robust to OCR/formatting variants but could in
  principle merge two different same-surname-same-year studies; only one short-surname key
  (`de1997` = De Volder 1997) actually triggered a dedupe here and was verified genuine.
- Karbowski rows lack anesthesia metadata (`conscious = unknown`, kept in the merge).

## Cross-check (independent human cortical CMRgl)

Merged *Homo sapiens* whole-brain CMRgl = **29.1** µmol/100 g/min (24 distinct studies) — matches
Kaufman's own human whole-brain mean (~29.3) and the ~30 literature value. Neocortex CMRgl = 35.5
(50 studies, all three sources), sitting between Heiss (33.5) and Kaufman (~37). Mass-specific rate
falls with body size as expected (mouse/rat ≈ 73 vs human ≈ 29).

## Relationship to `__flow_comparison/` (assessed — kept separate)

`__flow_comparison/` (Seymour 2015 + Boyer & Harrington 2019) is **arterial blood flow through
cranial canals** (ICA / ICA+VA), in **mL/s**, derived from bony-canal radii and Poiseuille flow.
That is a **different measure class** from anything here: it is whole-organ volumetric inflow, not
mass-specific cerebral rate. Two reasons it is **not** folded into this merge:

1. **Different data type.** Per `__HOWTO §10`, merges are one-per-data-type; mL/s arterial flow
   must not be pooled with µmol·100 g⁻¹·min⁻¹ CMR or with `CBF` perfusion (mL·100 g⁻¹·min⁻¹).
   Note `CBF` here (Kaufman) *is* metabolically-coupled perfusion and belongs in this merge; the
   Seymour/Boyer flow is not the same variable.
2. **It is downstream of this merge, not upstream.** `__flow_comparison`'s own ReadMe states its
   purpose is to be **calibrated against** measured brain glucose uptake — i.e. against
   `cerebral_metabolic_rate_long.csv` — to *estimate* CMRglc in fossil hominins. Folding it in would be circular.

Recommendation: keep `__flow_comparison/` as its own flow table; consumers who want a flow→glucose
calibration should join it to `cerebral_metabolic_rate_long.csv` on accepted species name.

## Adding a source

1. Add `standardized_term_by_reference/<Item name>_standardized_terms.csv`.
2. If it is a **compilation**, extract it to primary-study level (reference per row) so it can be
   deduped; if it is **primary**, add it directly. Register `Data role` in `__ReadMe.xlsx`.
3. Extend the region/species crosswalks in the build script, then re-run
   `standardized_term.R` and `cerebral_metabolic_rate_compiled.R` (or `build_cerebral_metabolic_rate_merge.py`).
