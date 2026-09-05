# Heffner & Heffner (1992) — Table 1 ("1992a")

**Source paper.** Heffner, R. S., & Heffner, H. E. (1992). Visual factors in sound localization in mammals. *Journal of Comparative Neurology*, 317(3), 219–232. https://doi.org/10.1002/cne.903170302

The `_a` suffix distinguishes this from the Heffners' other 1992 papers (the blind-mole-rat paper and the *Evolutionary Biology of Hearing* chapter); it matches the "Heffner and Heffner 1992a" short code used throughout the Bath sensory compilation. First Route-A source folder of the sensory ingestion plan (`____Sensory_audiovisual/SENSORY_AUDIOVISUAL_DATA_PLAN.md`).

**Table.** Table 1: *"Values of Parameters Examined as Predictors of Sound Localization Acuity in Mammals"* — 24 rows (23 species; wild and domestic Norway rat are separate rows) × 6 measures: sound localization threshold (deg), functional interaural distance Δt (µsec), width of field of best vision (deg), maximum visual acuity (c/deg), binocular field (deg), trophic level (1–5).

## Files in this folder

| file | what it is |
| --- | --- |
| `Heffner-1992-Visual factors in sound localizat.pdf` | the publication (copy of the archive PDF) |
| `Heffner_Heffner_1992_a_Table1_snapshot.csv` | frozen, hand-verified copy of Table 1 as printed |
| `Heffner_Heffner_1992_a_Table1.R` | canonical reformat: snapshot → CSV + public TSV |
| `Heffner_Heffner_1992_a_Table1.csv` | analysis-ready data ("use this") |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |
| `reference_tables/…_footnotes.csv` | the 30 printed footnotes, verbatim |
| `reference_tables/…_species_crosswalk.csv` | printed common name → binomial, with per-species basis |
| `…_compare_to_SensoryData_compiled_csv.R` (moved 2026-09-05 to `Evo-M1-Trait-Data-restricted/restricted_checks/Heffner_Heffner_1992_a/comparison/`) | QA script for both audits (fixture + student sheet) |

Public TSV: `__Public/comparative-data/10.1002%2Fcne.903170302_Table1.tsv`.

## Snapshot

**The PDF is a scan; its OCR text layer is unusable for values** — printed superscript footnote markers fuse into the numbers (`1.1²` reads as "1.12", `12.0¹⁴` as "12.0~~"). The snapshot was therefore transcribed and verified cell-by-cell against the 400 dpi rendered page image. Superscript footnote markers are captured in separate `threshold_footnote` / `acuity_footnote` columns (a CSV cannot carry superscripts; markers are never merged into values). Missing cells are the printed em-dash `—`. Row order, spellings (".7" for man's field of best vision) and units as printed. Header footnotes: ¹ on the threshold column (threshold criterion), ²³ on the acuity column (ganglion-cell method).

## Cleaning applied (in `.R`)

Em-dash → NA; values → numeric (no unit conversions — all kept in printed units); footnote numbers resolved to their printed citation text (`threshold_source`, `acuity_source`); unfootnoted acuity values are this paper's own ganglion-cell estimates per header footnote 23. Binomials joined from the species crosswalk — the printed common name survives verbatim as `Species_HH1992a` (invariant 3), and every binomial carries its `basis` (stated in text / from the cited primary / inferred / ambiguous). **Macaque is left as `Macaca sp.`**: the cited primaries mix macaque species (Brown et al. '80 "old world monkeys"; Cowey & Ellis '67 rhesus); the Bath compilation's "Japanese macaque" is an interpretation the paper does not support.

## Comparisons (0 value mismatches)

- **vs `____Sensory_audiovisual/SensoryData_compiled_check/`** (rows citing "Heffner and Heffner 1992a"): **81 agree, 0 mismatches**, 6 rows the compilation assigned to species that are **not in Table 1**:
  - *Delphinus delphis* (threshold 1.1, trophic 1): the compilation assigned Table 1's single "dolphin" row to **both** *Tursiops truncatus* and *Delphinus delphis*. The paper's cited primary (Renaud & Popper '75) is the bottlenose porpoise *Tursiops truncatus* — the *Delphinus* rows are a duplication/misassignment in the compilation.
  - *Hemiechinus auritus* (threshold 19, binocular field 35, trophic 2): Table 1's "hedgehog" is *Paraechinus hypomelas* per the paper's own reference list (Chambers '71 thesis title). The compilation's *Hemiechinus* assignment conflicts with the citation.
  - *Inia geoffrensis* (trophic 1): no *Inia* in Table 1 — unsupported by this citation.

  These three findings are compilation defects, not paper defects; they carry forward to the eventual sensory merge as rows to exclude or re-source.
- **vs the Bath student extraction** (`hearing data.xlsx`, sheet "Heffner Heffner 1992a"): **77 value comparisons agree, 0 mismatches** (19 both-missing).

## Primary vs secondary (Data role: both)

- **Primary** (first publication in numeric form): field of best vision (13 spp, new RGC isodensity data), binocular field ("determined specifically for this analysis"), functional interaural distance (previously graphic-only in Heffner & Heffner '87), trophic level (ranking constructed here), and the unfootnoted visual acuities (own ganglion-cell estimates).
- **Secondary** (compiled from cited sources): all 24 sound localization thresholds ("All of the thresholds have been published and no new thresholds are reported here" — per-row primary preserved in `threshold_source`) and the footnoted acuities (sources 24–30 in `acuity_source`).

Only the primary columns are candidates for any future `__merging_sensory` compile; the thresholds would be merged from their own primaries (mostly Heffner-lab papers, several already on the Route-A list).

## Notes for the database

- Table 2 of the paper (correlation coefficients) is derived statistics — not transcribed, per house rule.
- Species-name standardisation to the repo backbone is deferred to the repo-level step; rows for `species_key.csv` should use token `HeffnerHeffner1992a`.
- Trophic level is an ecological ranking, not a psychophysical measure — flag if it ever enters a merge.
