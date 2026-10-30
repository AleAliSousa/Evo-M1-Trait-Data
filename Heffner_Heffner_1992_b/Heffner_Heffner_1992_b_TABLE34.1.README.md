# Heffner & Heffner (1992b) — Table 34.1

Heffner, R. S., & Heffner, H. E. (1992). Evolution of sound localization in mammals. In D. B. Webster, R. R. Fay, & A. N. Popper (Eds.), *The evolutionary biology of hearing* (pp. 691–715). Springer. https://doi.org/10.1007/978-1-4612-2784-7_43

**Item:** `Heffner_Heffner_1992_b_TABLE34.1` · **Item encoded:** `10.1007%2F978-1-4612-2784-7_43_TABLE34.1` · **Public TSV:** `__Public/comparative-data/10.1007%2F978-1-4612-2784-7_43_TABLE34.1.tsv`

**TABLE 34.1.** Effect of head size and azimuth on interaural time difference and the frequency at which binaural phase becomes ambiguous (p. 692). Four species (house mouse, dog, human, elephant): head radius (mm); interaural time difference (µs) at 90° and **10°** azimuth; frequency of phase ambiguity (kHz) at 90° and **30°** azimuth. Footnote: *"Interaural time difference and frequency of phase ambiguity calculated using the formula from Kuhn (1977)."*

## Data role

**primary (calculated).** The ITD and phase-ambiguity values are the authors' own model calculations (Kuhn 1977 spherical-head formula), not behavioural or anatomical measurements, and are not reused from another paper. The head radii carry no citation anywhere in the chapter. Kuhn (1977) is the *method* source, kept as `method_ref_key` and resolved in `reference_tables/Heffner_Heffner_1992_b_TABLE34.1_references.csv`. Not a candidate for any volume/cell-count merge.

## Pipeline (reader named)

`Source → Snapshot → Data readable → Online database`

1. **Source:** `heffner_heffner_1992_bookchapter.pdf` (scanned book chapter; OCR text layer garbles the header — "~sec", "900", "100").
2. **Snapshot:** `Heffner_Heffner_1992_b_TABLE34.1_snapshot.csv` — transcribed by an AI assistant on 2026-10-28 from a 250-dpi render of PDF page 2 (journal p. 692); every cell re-read on the image. Layout as printed: three header rows (group heading / "Azimuth" / "Animal (in mm) 90° 10° 90° 30°"), four data rows in printed order, the footnote as the last row. Cell strings as printed (`3,200`, `12.700`).
3. **Data readable:** `Heffner_Heffner_1992_b_TABLE34.1.R` reads the snapshot positionally (skip = 3), strips the thousands separator, runs the table checks below, reshapes long (one row per animal × quantity × azimuth = 16 rows) and resolves species through `_keys/General/species_key.csv` (`source_publication = Heffner_Heffner_1992_b`; the script stops if that filter returns zero rows). Printed animal name kept in `animal_as_printed`; printed cell kept in `value_as_printed`.
4. **Online database:** public TSV written by the same script (Item encoded looked up by Item name in `__ReadMe.xlsx`).

Run 2026-10-28: `Rscript --vanilla Heffner_Heffner_1992_b_TABLE34.1.R` in conda env `evom1-r` (R 4.5.3) — completed, 16 rows × 11 columns.

## Table checks

The Kuhn low-frequency model makes the table self-checking: ITD ∝ sin(azimuth), and phase becomes ambiguous at f = 1/(2·ITD), so f(30°) = 2·f(90°). Tolerances are half a unit of each printed last digit, propagated. Result (actual R run): **8 pass, 4 mismatch.**

| check | observed | printed | difference | tolerance |
|---|---|---|---|---|
| f(90°) = 1/(2·ITD90), Dog | 1.2048 | 1.210 | −0.0052 | 0.0020 |
| f(30°) = 2·f(90°), Dog | 2.420 | 2.410 | +0.0100 | 0.0015 |
| f(30°) = 2·f(90°), Human | 1.272 | 1.270 | +0.0020 | 0.0015 |
| ITD10 = ITD90·sin10°, Elephant | 555.67 | 555 | +0.67 | 0.59 |

The **Dog 90° value 1.210 kHz** is inconsistent with both its own ITD (1/(2×415 µs) = 1.205 kHz) and the printed 30° value (2.410/2 = 1.205 kHz): recorded as a proposed `publication_error` in `reference_tables/Heffner_Heffner_1992_b_errata.csv`; the CSV keeps 1.210. The Human and Elephant misses are 1–2 units in the last printed digit (Elephant passes if `3,200` is itself rounded) — rounding of unprinted intermediate values, reported here only.

## Species

Common names only are printed. Binomials come from the key (curator judgement, high confidence): House mouse → *Mus musculus*; Dog → *Canis lupus familiaris*; Human → *Homo sapiens*; Elephant → *Elephas maximus* (the text says "Indian elephant"; the chapter's Fig. 34.10 legend prints *Elephas maximus*).

## Files

| file | what it is |
|---|---|
| `Heffner_Heffner_1992_b_TABLE34.1_snapshot.csv` | frozen snapshot (printed layout) |
| `Heffner_Heffner_1992_b_TABLE34.1.R` | snapshot → analysis CSV + public TSV, with table checks |
| `Heffner_Heffner_1992_b_TABLE34.1.csv` | analysis data (long, 16 rows) |
| `reference_tables/Heffner_Heffner_1992_b_TABLE34.1_definitions.csv` | data dictionary (10-column schema) |
| `reference_tables/Heffner_Heffner_1992_b_TABLE34.1_references.csv` | Kuhn (1977) method citation, verbatim from the bibliography |
| `Heffner_Heffner_1992_b_TABLE34.1_registry_row.xlsx` | paste-ready registry row (owner pastes; `__ReadMe.xlsx` not edited) |

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Heffner_Heffner_1992_b_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Heffner_Heffner_1992_b-E001 | value | Table 34.1 p.692, row Dog, Frequency of phase ambiguity (in kHz), Azimuth 90° | 1.210 |  | publication_error | 1.205 | proposed | Table 34.1 footnote: values from Kuhn (1977) formula, phase ambiguity at f = 1/(2 ITD). Printed Dog ITD 90° = 415 µs gives 1/(2x415 µs) = 1.205 kHz; printed Dog 30° value 2.410 kHz / 2 = 1.205 kHz. The other three species satisfy both relations to the last digit. | CSV keeps the printed 1.210 (HOWTO 7a); detected by table_checks f90_halfperiod_Dog and f30_double_Dog. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
