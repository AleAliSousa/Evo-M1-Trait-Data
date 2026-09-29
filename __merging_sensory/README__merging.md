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

## More of the Heffner lab

The repo holds **33 Heffner/Koay folders**; this merge originally read 4 items. Twelve more are
now declared in `HEFFNER_EXTRA` (`heffner_extra` in the R twin) — every one whose values are
attributable **per row**, which is what the repo's "no value without a traceable source" rule
requires. They are declared rather than coded because the only thing that varies is which
column holds what: each paper keeps its own column names, and each carries a curated
`data_role` (did this lab measure the species, or compile it) and `source` (which study, when
compiled). All of them read the limit at the **same 60 dB SPL criterion** already used by Koay
Figure 6, which is what makes them poolable with the values already merged.

| measure | before | after |
|---|---|---|
| `Audible_freq_low_60dB.kHz` | 1 | **21** |
| `Hearing_range.octaves` (recomputed) | 1 | **21** |
| `Sound_localization_threshold.deg` | 23 | **35** |
| `Audible_freq_high_60dB.kHz` | 64 | **71** |
| `Interaural_distance_functional.us` | — | **71** (new) |

Species 135 → 139, merged rows 244 → 373. The extra traffic exercises the provenance
machinery hard: 11 values are dropped as the same primary study reported twice (was 2) and 29
are superseded within the lab (was 1).

### Functional interaural distance

The head-size covariate Heffner's programme is built on — "time for sound to travel from one
auditory meatus to the other" — carried from five items that print it, under three different
column names (`functional_interaural_distance_us`, `delta_t_us`, `functional_head_size_us`).
It is **not a percept**: it is computed from head geometry, so it carries `is_percept = FALSE`
and `measure_class = sensory_anatomy_derived`, and it pools only with itself. It is in this
merge rather than a morphology one because it is the canonical predictor of the
high-frequency hearing limit, and the two are most useful side by side.

### Precision outranks recency

Adding these exposed a flaw in the supersede rule. It kept the later measurement whenever one
lab had measured a species twice — which meant Koay 1998's **figure-digitised** interaural
distances displaced Heffner & Heffner 1992a's **printed table** values for 23 species
(*Elephas* 3378.09 for 3350, *Homo* 870.54 for 875). A digitised reading carries the
digitisation error on top of whatever was measured. A printed value is now never superseded by
a digitised one; within one provenance tier the later measurement still wins. Every row in
`sensory_superseded_report.csv` says which rule applied.

### What still cannot enter, and why

- **`Heffner_etal_2020` Figure 3** (79 points, interaural distance + hearing limit). Beyond
  printing no per-point reference, the curation records that **45 of its 79 points are
  unlabelled in the figure**, 7 have a marker claimed by two labels, 4 have an unvalidated
  leader line, and 5 carry `CHECK_value_differs_from_Koay1998`. Only 17 are validated. Its
  text values are already in.
- **`Heffner_Heffner_2010_b_Table1`** (20 species, interaural distance + hearing limit). Its
  footnote table *does* hold the citations (letters `c`–`jj`), but the per-row letters were
  never carried into the table — `source` is a generic pointer. **Recoverable**: assigning
  the letters from the paper's Table 1 would release 20 species of both measures. The one
  row the paper measured itself is already in.
- **`Heffner__2004_Table1`** (19 primates, high and low limits). No attribution column at
  all; its footnotes are methodological ("Extrapolated value based on a threshold of 50 dB or
  higher", "Tested using headphones"), not citations.
- **`Heffner__1998_Table1`** (19 species) is birds, excluded by the mammal gate.
- **`Heffner_etal_2016`, `Koay_etal_2003`** print per-frequency thresholds, not a limit — a
  different quantity, and a full audiogram merge rather than a column here.

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
`Evo-M1-Trait-Data-restricted/other_checks/sensory_data_refs_check/data_raw/SensoryData_compiled.csv` (the Bath compilation, reshaped; moved there 2026-09-29 from `____Sensory_audiovisual/SensoryData_compiled_check/`, which now holds a pointer):
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

## Errata flags (2026-09-29)

The merge is the third rendering of the errata convention
(`_tools/dataset_builder/ERRATA_CONVENTION.md`). Both scripts read every
`<Paper>/reference_tables/<Paper>_errata.csv` and add three columns to
`sensory_unfiltered.csv` (`errata_id`, `errata_status`, `errata_issue_type`)
and two to `sensory_long.csv` (`errata_id`, `errata_status`). A study row is
flagged when an erratum's `item` is the row's `Source_item`, its `variable` is
`*` or the column the row was read from, and its `locator` — which by
convention names the printed row label — contains the species as printed.
Flags ride through dedupe and supersession into the pooled row (ids are
unioned), and a derived `Hearing_range.octaves` inherits the flags of the two
limits it was computed from. **Flags only, never substitution**: a
`proposed_value` is never merged; `withdrawn` errata are ignored.

Current state: 12 errata exist in the repo (Heffner__1998 ×4, Wenstrup__1984,
Zilles_Rehkämper_1988 ×2, DeCasien_Higham_2019 ×5); none of those items is a
source of this merge, so every flag column is empty and
`sensory_errata_report.csv` shows `item_in_merge = FALSE` throughout. The
matcher was exercised with a synthetic erratum on `Koay_etal_1998_Figure6`
(flags the Rousettus rows; a mismatched `variable` or `withdrawn` status
blocks it). If `Heffner__1998_Table1` is added as a source, its four corrected
low-frequency limits (birds) arrive already flagged `repo_transcription_error
/ confirmed`.

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
| `sensory_errata_report.csv` | every non-withdrawn row of every `<Paper>/reference_tables/<Paper>_errata.csv` in the repo, with `item_in_merge` and `study_rows_flagged` — the ledger of which errata this merge could see and which it actually flagged |

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
