# Merging sensory data

Pipeline for compiling the comparative **sensory performance** dataset — the psychophysical
counterpart of `__merging_volumes/` (structure) and `__merging_cellcounts/` (cells), built on
the **compilation-aware** pattern of `__merging_cerebral_metabolic_rate/`.

## Measurement method is part of the measure name

The merge originally filed all seven measures under one measure class, `psychophysics`. By the
sources' own definitions that was wrong for most of them: visual acuity is "Calculated based on
peak density of ganglion cells except as otherwise noted", the field of best vision comes "from
retinal ganglion cell isodensity contours", and the binocular field is the "Width of the angle
of overlap of the left and right retinal fields" — three retinal or optical quantities, not
behavioural thresholds. Only the audiogram limits and the sound-localization threshold are
psychophysics, each with a stated criterion (60 dB SPL; 75% correct / 50% detection).

A behavioural threshold and a number computed from cell density are not the same measurement,
so **values are pooled only within a method**, exactly as `__merging_brain_mass/` pools only
within a measurement basis. The basis of every source column is recorded — with the source's
own words — in `_keys/sensory_method_basis.csv`, built by `_keys/build_sensory_method_basis.py`.
This pipeline reads that key and **aborts** on a harvested row whose basis is not on record.

Two measures needed splitting; the other five carry one basis each:

| Measure | Species | Method basis |
|---|---|---|
| `Visual_acuity_anatomical.cdeg` | 95 | computed from peak retinal sampling density — ganglion cells by default, cone density where retinal summation is absent (Veilleux & Kirk's printed footnote 2) |
| `Visual_acuity_mixed_method.cdeg` | 1 | Heffner & Heffner footnote 26: "Average of ganglion cell density and evoked potential measure" — the components are not recoverable |
| `Visual_acuity_method_unstated.cdeg` | 3 | footnotes 24, 25, 27, 28, 30 name the study the value came from without saying how it measured |
| `CFF_behavioural.Hz` | 10 | behavioural flicker-fusion threshold |
| `CFF_electrophysiological.Hz` | 15 | flicker electroretinogram — an evoked response, not a behavioural report |

`Visual_acuity.cdeg` no longer exists. The three acuity variables are never averaged together.

### Resolving an unstated method

A primary study's method does not change depending on which compilation cites it. Where Heffner
& Heffner cite a study without stating its method and Veilleux & Kirk report the **same primary
study** with a stated basis, the stated basis resolves the unstated one — otherwise one
measurement sits under two different measures and escapes the dedupe. Two rows are resolved this
way (*Felis catus* via `jacobson1976`, *Meriones unguiculatus* via `baker1983`), and both are
listed in `sensory_method_resolution_report.csv` rather than being changed silently. Without
that pass the dedupe found 0 shared studies instead of 2.

Method basis is **not** `value_origin`. That column records how the number was read off the page
(published / digitised from a figure / recomputed), which is a different question.

## Why there is no psychophysics merge

Because the method varies *inside* a variable, a folder cannot hold the distinction: van
Haarlem's CFF is 221 electrophysiological rows and 59 behavioural ones, and Heffner & Heffner's
acuity column is anatomical by default with footnoted exceptions. Splitting by folder would put
half of one variable in each. Method is a per-row property, so it lives in a key and in the
measure name.

**Scope: percepts only.** What an animal can detect or resolve. It deliberately excludes the
morphological covariates that travel with these data (functional interaural distance, eye
axial diameter) and the ecological ones (trophic level, activity pattern, diet, running speed,
body mass) — the latter belong in `__merging_body_ecology/`. They stay in the source tables
for provenance, marked `NOT_MERGED_*` in the standardized-term files so the reason is visible.

## Measures

| Measure | Meaning | Unit |
|---|---|---|
| `Audible_freq_high_60dB.kHz` | highest frequency audible at 60 dB SPL | kHz |
| `Audible_freq_low_60dB.kHz` | lowest frequency audible at 60 dB SPL | kHz |
| `Sound_localization_threshold.deg` | minimum audible angle around the midline | degrees |
| `Visual_acuity.cdeg` | maximum visual acuity | cycles/degree |
| `Field_of_best_vision.deg` | horizontal width of the field of best vision | degrees |
| `Binocular_field.deg` | width of binocular overlap | degrees |
| `Hearing_range.octaves` | **derived, recomputed** from the two merged limits | octaves |

`Hearing_range.octaves` is never merged as a reported value — per the house rule that ratios
and indices are recomputed downstream, it is calculated from the merged in-air limits and
carries `Data_role = derived`, `n_studies = 0`.

**Medium matters.** Underwater audiograms are not comparable with in-air ones (Koay et al.
1998 says so explicitly, and its caption separates them). `Medium` is part of the grouping
key, so *Phoca vitulina* carries an in-air row **and** an underwater row. `sensory_wide.csv`
is **in-air only**; underwater values live in `sensory_long.csv`.

## Sources and their data role

| Source | Role | What it contributes |
|---|---|---|
| `Heffner_Heffner_1992_a_TABLE1` | **both** | *Primary:* field of best vision (13 spp), binocular field (18), and the unfootnoted acuities (its own ganglion-cell estimates). *Compiled:* all 24 localization thresholds and the footnoted acuities, each carrying a printed footnote source. |
| `Veilleux_Kirk_2014_SupplementalTable1` | **both** | *Primary:* `this study` acuities. *Compiled:* bracket-sourced acuities resolving through its 122-entry data-source list. |
| `Koay_etal_1998_Figure6` | **both** | *Primary:* the *Rousettus aegyptiacus* audiogram ("present report"). *Compiled:* 66 further high-frequency limits, each with a caption audiogram source. All figure-digitised. |
| `Heffner_etal_2020_Figure3` | **primary** | *Cottontail rabbit only*, from the paper's **text** (300 Hz, 56 kHz, MAA 27.6°). |
| `Haarlem_etal_2026_CFFdataset` | **secondary** | Critical flicker fusion. 38 mammal rows / 21 species out of its 280 rows / 237 species; each row names its primary study in `primary_reference`, and its `method` column splits the measure into behavioural and electrophysiological. |

### What is deliberately excluded

- **`Heffner_etal_2020` Figure 3 comparative points.** That figure prints **no per-point
  reference**, so its ~79 values have no traceable primary and fail the repo's "no value
  without a traceable source" rule. Only its text values enter. (Contrast Koay Fig. 6, whose
  caption sources every point — which is exactly why Koay's points *can* be used.)
- **Non-mammals.** A class gate is part of the design, and with van Haarlem it now bites hard:
  that source spans 16 classes and mammals are only 38 of its 280 rows (insects 58, fish 50,
  crustaceans 48 all outnumber them). The non-mammal rows stay in the source table. Widening
  this merge beyond Mammalia is a scope decision for the whole repo, not for one source.
- **van Haarlem's own ecology covariates** (habitat, foraging light level, mode of life) and its
  body mass, which reaches `__merging_body_ecology/` instead — 279 rows of `Body_Mass (g)`.
- **`Macaca sp.`** — HH1992a's macaque row is not resolvable to a species (its cited
  primaries mix macaques), so it is dropped rather than assigned.

## Why compilation-aware resolution

Three of the four sources are papers whose comparative values are compiled from *other labs'*
audiograms and acuity measurements — and they cite **overlapping** primaries. Averaging their
published values as if each paper were an independent measurement would double-count every
shared study. So the pipeline:

1. Pulls every value down to the **primary-study level**, each row carrying its own literature
   reference as printed.
2. Normalises each reference to a **first-author + year (+ a/b/c)** key. The author *initial*
   is carried separately after a `|`, because sources print it inconsistently
   ("Belleville and Wilkinson ('86)" vs "Belleville S, Wilkinson F (1986)"); it is used only to
   keep same-surname, same-year authors apart (H. E. Heffner vs R. S. Heffner, 1980).
3. Treats two values as the **same measurement when their study sets intersect** — not when a
   key string matches exactly, since one paper may cite a single study where another cites two.
   Every collision is logged in `sensory_dedupe_report.csv`.
4. Applies the `__HOWTO` §10 rubric: **within one lab the most recent measurement supersedes**
   (logged in `sensory_superseded_report.csv`); **across independent labs, average**.
5. Averages across the remaining distinct primary studies.

Rows from the *same* source item are never collapsed: within one paper, two rows for a species
are two distinct measurements (wild vs domestic Norway rat, wild vs domestic house mouse).
Those *are* averaged into the species value, with the printed population kept in
`sensory_unfiltered.csv`.

**HH1992a study keys are curated, not parsed.** Its footnotes mix prose with citations
("Average of ganglion cell density and evoked potential measure, Silveira, et al., ('82)"), so
the study keys live in a `primary_study_keys` column of that item's footnotes reference table
where they are auditable, rather than being regex-guessed at merge time.

## Current state (first run, 4 sources)

**135 species, 244 merged rows** from 268 study-level rows: 99 visual acuity (95 anatomical,
3 method-unstated, 1 mixed-method), 25 CFF (15 electrophysiological, 10 behavioural), 65 high-frequency
limit, 23 localization threshold, 18 binocular field, 12 field of best vision, 1 low-frequency
limit, 1 derived hearing range. 50 rows are wholly primary, 162 wholly secondary, 4 mixed.
2 shared studies deduped, 1 superseded within the Heffner lab.

The two dedupe hits are the pattern working as intended: HH1992a and Veilleux & Kirk both
report cat acuity from **Jacobson et al. 1976** (9.0 vs 8.85 — agree) and gerbil acuity from
**Baker & Emerson 1983** (2.0 vs 1.8 — flagged, `agrees = FALSE`, two papers reading one
primary differently). The supersede hit is *Sylvilagus floridanus*: Koay 1998 carries the 1995
Heffner & Koay value (56.49 kHz digitised), the 2020 paper re-measured it (56 kHz), and the
2020 value wins — which also makes the merged value match the 2020 paper's printed text.

**End-to-end check:** the derived hearing range for the cottontail comes out at **7.544
octaves** against the paper's printed "7.5 octaves" — independent confirmation of the merged
limits (and of the 56 kHz reading over the abstract's erroneous 32 kHz).

## QA against the compiled sensory check fixture

`comparison_vs_SensoryData_compiled.csv` audits every merged value against
`____Sensory_audiovisual/SensoryData_compiled_check/` (the Bath compilation, reshaped):
**175 agree, 33 differ**. The differences are all explained:

- **22** are rows the fixture itself flags `quarantined_va_offset` — the compilation's known
  24-row visual-acuity displacement. The merge carries the **correct** value from the primary,
  so these differences are the merge fixing the compilation, not disagreeing with it.
- **2** are the fixture's own `curator_flag` rows.
- **9** are `ok` rows with documented causes: species-level averaging of wild/domestic
  populations (*Mus musculus*, *Rattus norvegicus*), the compilation preferring a published
  primary where the merge has Koay's digitised figure value (*Bos taurus*, *Pan troglodytes*),
  a different cited source for the same percept (*Felis catus*, *Mustela putorius*
  localization), and *Phoca vitulina*, where the compilation's 120 kHz is the **underwater**
  value and the merge's in-air row is 23.2 kHz — the medium split doing its job.

## Files

| file | what it is |
|---|---|
| `build_sensory_merge.py` | the script that generated the shipped CSVs (no R in the build environment) |
| `sensory_compiled.R` | canonical house-style R equivalent. Verified cell-for-cell identical to the `.py` across all four tables. Holding that required reading every source with `colClasses = "character"` (Python's csv reader yields strings, while `read.csv` typed the acuity footnote numerically, so a blank became `NA` — and `nzchar(NA)` is `TRUE`, which sent every unfootnoted row down the footnoted branch), `sort(..., method = "radix")` for byte order, computing `value_range` before `summarise` overwrites `Value`, and a `split_refs()` for source cells naming several studies. |
| `standardized_term.R` + `standardized_term_by_reference/` | per-source term files → `standardized_term_sensory.csv` |
| `sensory_long.csv` | merged values, one row per Species × Measure × Medium |
| `sensory_wide.csv` | in-air species × measure matrix |
| `sensory_unfiltered.csv` | every study-level row before dedupe/supersede, with population + study key |
| `sensory_dedupe_report.csv` | shared primary studies removed |
| `sensory_method_resolution_report.csv` | rows whose unstated method was resolved from another source reporting the same primary study |
| `_keys/sensory_method_basis.csv` | **the method basis of every source column**, with the source's own words; built by `_keys/build_sensory_method_basis.py`, which fails if a quoted statement is not verbatim in the file it is credited to |
| `sensory_superseded_report.csv` | within-lab values superseded by a later measurement |
| `comparison_vs_SensoryData_compiled.csv` | audit vs the Bath compilation check fixture |

## Adding the next source

1. Build the paper folder the usual way (`__HOWTO_build_a_dataset_file.md`).
2. Add `standardized_term_by_reference/<Item name>_standardized_terms.csv`, marking anything
   out of scope `NOT_MERGED_<reason>`.
3. If its compiled values carry per-value references, make sure those resolve to study keys —
   either parseable in the item's own reference table, or curated there as HH1992a's are.
4. Re-run `standardized_term.R`, then the compile; check the dedupe and supersede reports.

**Next sources, by how much they would add:** Kirk & Kay 2004 (lifts the rest of the VA
quarantine), Heffner 2004, Heffner & Heffner 2003, Heffner 1998. Best frequency, best
sensitivity and the binaural-cue measures are carried by the Bath compilation but by none of
the four built primaries yet — they enter with those papers.
