# Merging sensory data

Pipeline for compiling the comparative **sensory performance** dataset — the psychophysical
counterpart of `__merging_volumes/` (structure) and `__merging_cellcounts/` (cells), built on
the **compilation-aware** pattern of `__merging_cerebral_metabolic_rate/`. It opens a measure
class the repo did not previously have: *performance / psychophysics*, as distinct from
volumetrics and cell counts.

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
| `Heffner_Heffner_1992_a_Table1` | **both** | *Primary:* field of best vision (13 spp), binocular field (18), and the unfootnoted acuities (its own ganglion-cell estimates). *Compiled:* all 24 localization thresholds and the footnoted acuities, each carrying a printed footnote source. |
| `Veilleux_Kirk_2014_SupplementalTable1` | **both** | *Primary:* `this study` acuities. *Compiled:* bracket-sourced acuities resolving through its 122-entry data-source list. |
| `Koay_etal_1998_Figure6` | **both** | *Primary:* the *Rousettus aegyptiacus* audiogram ("present report"). *Compiled:* 66 further high-frequency limits, each with a caption audiogram source. All figure-digitised. |
| `Heffner_etal_2020_Figure3` | **primary** | *Cottontail rabbit only*, from the paper's **text** (300 Hz, 56 kHz, MAA 27.6°). |

### What is deliberately excluded

- **`Heffner_etal_2020` Figure 3 comparative points.** That figure prints **no per-point
  reference**, so its ~79 values have no traceable primary and fail the repo's "no value
  without a traceable source" rule. Only its text values enter. (Contrast Koay Fig. 6, whose
  caption sources every point — which is exactly why Koay's points *can* be used.)
- **Non-mammals.** A class gate is part of the design; all four current sources are
  mammal-only, so it does not bite yet. Keep it when adding sources.
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

**130 species, 217 merged rows** from 230 study-level rows: 97 visual acuity, 65 high-frequency
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
| `sensory_compiled.R` | canonical house-style R equivalent of the same pipeline |
| `standardized_term.R` + `standardized_term_by_reference/` | per-source term files → `standardized_term_sensory.csv` |
| `sensory_long.csv` | merged values, one row per Species × Measure × Medium |
| `sensory_wide.csv` | in-air species × measure matrix |
| `sensory_unfiltered.csv` | every study-level row before dedupe/supersede, with population + study key |
| `sensory_dedupe_report.csv` | shared primary studies removed |
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
