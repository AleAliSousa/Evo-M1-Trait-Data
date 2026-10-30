# Heffner & Heffner (2018) — Figure 3

Heffner, H. E., & Heffner, R. S. (2018). The evolution of mammalian hearing. *AIP Conference Proceedings*, 1965(1), 130001. https://doi.org/10.1063/1.5038516

**Item:** `Heffner_Heffner_2018_Figure3` · **Item encoded:** `10.1063%2F1.5038516_Figure3` · **Public TSV:** `__Public/comparative-data/10.1063%2F1.5038516_Figure3.tsv`

**FIGURE 3.** Relationship between the width of the field of best vision (75% isodensity contour) and sound-localization thresholds for 22 species of mammals (p. 130001-4; caption: "From Heffner and Heffner, 2016⁵"). Log–log; r = .89, n = 22; every point labelled with a common name.

## Data role — secondary, figure-derived

The figure is reproduced from Heffner & Heffner (2016, *Acoustics Today* 12:20–27, 35) and prints **no per-point sources**. All 22 rows are `data_role = secondary`, `value_origin = digitised_from_figure`. Use them only where no published table/text value exists (registry recommendation). Five points are traced, value-confirmed, to their original studies through `Heffner_etal_1999_ResultsText` (Egyptian fruit bat → Heffner et al. 1999; big brown bat → Koay, Kearns et al. 1998; Norway rat → H. E. Heffner & Heffner 1985; least weasel → R. S. Heffner & Heffner 1987; ferret → Kavanagh & Kelly 1987); they are in `candidate_original_source` and `reference_tables/Heffner_Heffner_2018_Figure3_references.csv`. The remaining 17 points are untraced in this paper. `Heffner_Heffner_1992_b` (Fig. 34.10 legend) lists 1990-era sources for cat, cow, pig, gerbil, grasshopper mouse, opossum, dog and human, but its keys are internally inconsistent (e.g. cat and man both keyed to R. Heffner & Heffner 1988a, a horse paper), so they are **not** used as traces here.

## Constructed snapshot — how the values were obtained

Figure 3 is a **raster** image (embedded bitmap 1144 × 812 px, 8-bit grey; no vector paths), so values were pixel-digitised from the native embedded bitmap — not from a re-render — by `Heffner_Heffner_2018_Figure3_extract.py` (conda env `python`; pymupdf, numpy, scipy). Run 2026-10-28; a second run reports "snapshot unchanged" (the script refuses to overwrite a differing frozen copy).

- **Calibration points:** the seven printed ticks on each axis, located as 2-px dark runs outside the 4-px axis lines. y (threshold, deg): 40, 30, 20, 10, 6, 3, 1 at pixel rows 36.5, 85.5, 157.5, 276.5, 364.5, 483.5, 662.5. x (field of best vision, deg): 1, 3, 10, 30, 100, 180, 200 at pixel columns 204.5, 363.5, 548.5, 704.5, 884.5, 963.5, 992.5.
- **Axis assumption:** both axes log10. The printed ticks are not exactly log-spaced (a single least-squares log fit leaves residuals of −2.1 to +2.7% on y and −4.8 to +4.3% on x, worst at the crowded 180/200 x ticks). Primary values therefore use **piecewise-linear log interpolation between adjacent printed ticks**; the single-fit values are kept as `*_globalfit` and their difference (`calibration_spread_pct_*`, within ±4%) is the calibration uncertainty. The human point (x ≈ 0.70°) lies below the lowest tick and is extrapolated from the 1–3° segment.
- **Markers:** open circles (radius ≈ 9.7–10.0 px). Ring-template cross-correlation found exactly 22 strong peaks (scores 129.7–143.8; the next-best hits, 72–79, are axis-label glyphs), matching the caption's n = 22; centres from an algebraic circle fit to the ring pixels (125–149 ring pixels each).
- **Labels:** assigned visually (labels adjacent to markers or joined by leader lines; one label per marker), in `reference_tables/Heffner_Heffner_2018_Figure3_label_assignment.csv`, all `high` confidence. Overlay check: `Heffner_Heffner_2018_Figure3_digitisation_check.png` (detected circles, ticks, label and values drawn on the bitmap).

Digitised by an AI assistant on 2026-10-28.

## Cross-checks against printed numbers (actual R run)

| point | measure | printed | digitised | diff |
|---|---|---|---|---|
| Egyptian fruit bat | threshold | 11.6° (Heffner et al. 1999) | 11.44° | −1.4% |
| Egyptian fruit bat | field of best vision | 27° (Heffner et al. 1999) | 28.45° | +5.4% |
| big brown bat | threshold | 14° (Koay, Kearns et al. 1998 via 1999) | 13.80° | −1.5% |
| big brown bat | field of best vision | 139° (same) | 153.96° (global fit 148.6°) | +10.8% |
| Norway rat | threshold | 12° (this paper, text) | 11.93° | −0.6% |
| chinchilla | threshold | 17° (this paper, text) | 15.42° | **−9.3%** |
| gerbil | threshold | 27° (this paper, text) | 26.52° | −1.8% |

Five agree within the digitisation uncertainty. The **chinchilla** point disagrees with the paper's own text (17°) by more than the calibration spread — recorded as a proposed `publication_ambiguity` erratum; the CSV keeps the figure reading. The big brown bat field-of-best-vision difference sits where the x ticks are least regular; it may also be a revised value in the 2016 figure — not resolvable from this paper.

## Pipeline (reader named)

1. **Source:** `Heffner-2018-The evolution of mammalian hearin.pdf` (born-digital; figure embedded as bitmap).
2. **Snapshot:** `Heffner_Heffner_2018_Figure3_snapshot.csv` (22 markers: pixel centre, radius, ring pixels, match score, both calibrations) written by the extract script.
3. **Data readable:** `Heffner_Heffner_2018_Figure3.R` joins snapshot + label assignment, resolves species via `_keys/General/species_key.csv` (`source_publication = Heffner_Heffner_2018`; stops on zero rows), adds calibration spread, source keys and the cross-check above. Run 2026-10-28 with `Rscript --vanilla` (env `evom1-r`, R 4.5.3): 22 rows × 15 columns.
4. **Online database:** public TSV from the same script.

## Files

| file | what it is |
|---|---|
| `Heffner_Heffner_2018_Figure3_extract.py` | reproducible bitmap digitisation → frozen snapshot |
| `Heffner_Heffner_2018_Figure3_snapshot.csv` | constructed snapshot (22 markers) |
| `Heffner_Heffner_2018_Figure3_digitisation_check.png` | overlay check |
| `Heffner_Heffner_2018_Figure3.R` | snapshot + assignment → analysis CSV + public TSV |
| `Heffner_Heffner_2018_Figure3.csv` | analysis data (22 rows) |
| `reference_tables/Heffner_Heffner_2018_Figure3_label_assignment.csv` | label → marker assignment |
| `reference_tables/Heffner_Heffner_2018_Figure3_definitions.csv` | data dictionary |
| `reference_tables/Heffner_Heffner_2018_Figure3_references.csv` | caption source + 5 traced original studies |
| `Heffner_Heffner_2018_Figure3_registry_row.xlsx` | paste-ready registry update |

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Heffner_Heffner_2018_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Heffner_Heffner_2018-E001 | sound_localization_threshold_deg | Figure 3 p.130001-4, point "chinchilla" vs text p.130001-5 | 17° (text); figure point reads 15.42° (digitised) |  | publication_ambiguity |  | proposed | Text p.130001-5: "chinchillas and gerbils ... have thresholds of 17° and 27°, respectively". Digitised Figure 3 chinchilla point = 15.42° (global-fit calibration 15.32°); calibration spread there <1%, and the gerbil point in the same sentence agrees (26.5° vs 27°). | Figure and text of the same paper disagree; CSV keeps the figure reading. Prefer a primary chinchilla MAA source (Heffner et al. 1994, Hear Res 80:247-257) over either. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
