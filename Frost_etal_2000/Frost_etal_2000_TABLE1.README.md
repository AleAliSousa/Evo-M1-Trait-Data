# Frost_etal_2000_TABLE1

> **R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.**
> The R scripts below are the deliverables. The frozen snapshot, the analysis CSV and the public TSV
> now on disk were written on 2026-11-07 by `Frost_etal_2000_TABLE1_python_mirror.py`, a line-for-line
> Python mirror of the two R scripts, because R was not available in the assistant's environment.
>
> **Snapshot re-taken 2026-11-07.** The AI assistant re-took the snapshot on 2026-11-07 at the owner's
> request (“Frost snapshot would have been better with all the rows with (%) left in for better visual
> check and also to allow numerical check”): every printed line is now its own snapshot row, so the
> percentage lines sit on their own rows beneath the area lines. See *Snapshot re-take* below.

**Item name** `Frost_etal_2000_TABLE1` · **Item number** `TABLE 1` · **Item encoded**
`10.1002%2F(SICI)1096-9861(20000522)421%3A1%3C29%3A%3AAID-CNE3%3E3.0.CO;2-9_TABLE1`
(registry row found by Item name in `__ReadMe.xlsx`, re-read 2026-11-07; the TSV is named by this code).

Frost, S. B., Milliken, G. W., Plautz, E. J., Masterton, R. B., & Nudo, R. J. (2000). Somatosensory and
motor representations in cerebral cortex of a primitive mammal (*Monodelphis domestica*): a window into
the early evolution of sensorimotor cortex. *Journal of Comparative Neurology*, 421(1), 29–51.
<https://doi.org/10.1002/(SICI)1096-9861(20000522)421:1<29::AID-CNE3>3.0.CO;2-9> (PMID 10813771)

**Item full original title:** TABLE 1. Area Measurements (in mm²) and Percentages of Body Part
Representations Within Somatosensory Cortex — p. 36 (PDF page 8).

## Source

PDF in this folder: `Frost-2000-Somatosensory and motor representat.pdf` (833,297 bytes, 23 pages).

* **Born-digital, not a scan.** Typeset by XPP and written by PDFlib in March 2000; the only images are
  the figures (`pdfimages -list`: 17 figure images on pages 5–20, no full-page scans), and
  `pdftotext` returns a clean text layer for the table, caption and footnote.
* **DOI.** The 2000 layout prints no DOI on the first page. Page 1 prints
  "THE JOURNAL OF COMPARATIVE NEUROLOGY 421:29–51 (2000)", which matches the citation; the PDF's
  embedded publisher metadata (`WPS-ARTICLEDOI`) is
  `10.1002/(SICI)1096-9861(20000522)421:1<29::AID-CNE3>3.0.CO;2-9`, identical to the registry
  citation's DOI. Europe PMC and Wikidata give the same DOI (in lower case; DOIs are case-insensitive),
  volume 421, issue 1, pages 29–51 and PMID 10813771. No difference found.

## Why this item exists

*Monodelphis domestica* (grey short-tailed opossum) is a sequenced species. The paper maps the
somatosensory (S1, S2) and the electrically excitable (ICMS, low-impedance and surface stimulation)
cortex of this marsupial, which the authors take as a model of the primitive sensorimotor condition.
TABLE 1 is the paper's only table: primary per-animal areas of S1, S2 and four body-part
representations within S1, for the three most complete maps, with the printed mean ± SD.

## Pipeline

```
Source (born-digital PDF)
  -> Frost_etal_2000_TABLE1_extract_snapshot.R   text layer -> frozen snapshot (refuses to overwrite a differing copy unless --retake)
  -> Frost_etal_2000_TABLE1_snapshot.csv          FROZEN: 13 rows x 8 cols, one row per printed line
  -> Frost_etal_2000_TABLE1.R                     clean + parse + table checks
  -> Frost_etal_2000_TABLE1.csv                   28 rows x 22 cols ("use this")
  -> __Public/comparative-data/10.1002%2F(SICI)1096-9861(20000522)421%3A1%3C29%3A%3AAID-CNE3%3E3.0.CO;2-9_TABLE1.tsv
  -> reference_tables/Frost_etal_2000_TABLE1_definitions.csv
```

## Who read the values, when, and how it was checked

* **Reader: the extraction script, from the PDF text layer** (snapshot HOWTO method 3, the
  `Jacob_etal_2021_extract_snapshot.R` pattern). `Frost_etal_2000_TABLE1_extract_snapshot.R` finds the
  caption on PDF page 8, reads the table line by line from the text layer's physical layout, checks the
  caption, the column header and the footnote against anchored printed literals, places each cell under
  the printed column header nearest to it, checks every line's printed form (case numbers, areas,
  `(n%)`, `mean ± dispersion`) and writes the frozen snapshot. No table value is typed in any script.
  Written by an AI assistant (Claude) for A. de Sousa on 2026-11-06; rewritten for the line-by-line
  layout on 2026-11-07.
* **Text-layer quirks handled in the extract script:** the printed ± is encoded as U+2AFE in this
  font's text layer and is mapped back to ±; superscripts are flattened in the text layer ("mm2",
  "Cortex1", and a lone "1" before the footnote), so the caption is written "mm²" and the footnote mark
  "^1" (the Kennedy_etal_1978 convention). Nothing else is changed.
* **Check of the snapshot against the page:** on 2026-11-07 the AI assistant laid the re-taken snapshot
  beside a fresh 300-dpi render of PDF page 8 and read all 13 lines across: caption, column header, the
  three case area lines and their percentage lines, the Average line and its percentage line (65 printed
  numbers and the 3 case numbers) and the three footnote lines, with the footnote's line breaks; all
  match the page. As an independent machine reading, tesseract OCR of the same render returns the same
  13 lines in the same order and agrees on every value but one: it reads 9321 Rostrum as "(58%)", where
  the page (zoomed render) and the text layer both show **(53%)** (2.19 / 4.12 = 53.2%), so the snapshot
  keeps 53. **Human check still pending.**
* **R NOT RUN.** The snapshot, CSV and TSV on disk were written by
  `Frost_etal_2000_TABLE1_python_mirror.py` (poppler `pdftotext -layout` in place of
  `pdftools::pdf_text`, which uses the same physical-layout engine; R's `write.table`/`write.csv`
  quoting, `NA` handling and 15-significant-digit number format reproduced). To confirm, from the repo
  root, run the extract script first (without `--retake`) and then the build:

  ```
  Rscript Frost_etal_2000/Frost_etal_2000_TABLE1_extract_snapshot.R   # expect: "frozen snapshot already on disk and identical; nothing written."
  Rscript Frost_etal_2000/Frost_etal_2000_TABLE1.R                    # expect: table checks pass=52 mismatch=0 not_evaluable=3 (of 55)
  ```

  then compare the rewritten `Frost_etal_2000_TABLE1.csv` and public TSV with the mirror's copies. If
  they differ, the R output is authoritative. If the extract script instead stops and writes
  `Frost_etal_2000_TABLE1_snapshot_NEW.csv`, R's text layer differs from the mirror's: compare the two
  files against the page before doing anything else (never `--retake` without that comparison).
  Packages: `pdftools` (extract), `readxl` (registry lookup). Once the R reproduces the files, the mirror
  script can be deleted.

### Snapshot re-take (2026-11-07)

The AI assistant re-took the snapshot on 2026-11-07 at the owner's request. The 2026-11-06 snapshot
(7 rows x 8 columns) held each case's area and percentage together in one two-line cell
(`"5.06\n(71%)"`), so the percentage lines could not be read across on their own. The layout change is
deliberate, so the repo procedure for replacing a frozen snapshot was followed (snapshot HOWTO: the
frozen copy never changes silently; Kennedy_etal_1978 / Mink_etal_1981 guard: reconcile against the
PDF, move the superseded file to `archive/`, re-run):

1. The rewritten extract script was run without `--retake`: the frozen-file guard refused to overwrite
   the 7-row snapshot and wrote the new extraction to `Frost_etal_2000_TABLE1_snapshot_NEW.csv`.
2. That file was reconciled against the 300-dpi page render, line by line (above).
3. The script was re-run with `--retake`: it moved the superseded snapshot to
   `archive/Frost_etal_2000_TABLE1_snapshot_superseded_2026-11-07.csv` (byte-identical to the
   2026-11-06 frozen file), wrote the 13-row snapshot and removed the `_NEW` file.
4. A further run without `--retake` reported "frozen snapshot already on disk and identical".

No printed value changed: the new snapshot holds the same 65 numbers, case numbers, caption, header and
footnote text as the old one, laid out one printed line per row. Steps 1–4 were run by the Python
mirror (R NOT RUN).

### Structure of the snapshot

`Frost_etal_2000_TABLE1_snapshot.csv`, 13 rows x 8 columns (Case no., Tot. SS, S1, S2, Digits,
Vibrissae, Rostrum, HL/trunk), one row per printed line, in printed order:

| row | printed line |
|---|---|
| 1 | caption, in column 1 (`mm²`, footnote mark `^1`) |
| 2 | column header |
| 3, 5, 7 | area lines of cases 9213, 9321 and 9324: case no., Tot. SS and the six areas (mm²) |
| 4, 6, 8 | the percentage line printed beneath each, e.g. `(71%)`, under S1 … HL/trunk; Case no. and Tot. SS blank, as printed |
| 9 | Average line: `Average` and `mean ± dispersion` in each value column (the dispersion is printed on the same line as the mean), e.g. `6.35 ± 0.82` |
| 10 | the Average percentage line, e.g. `(68.0 ± 3.6%)`, including the HL/trunk cell typeset `(17.7% ± 1.0%)` with a second `%` |
| 11–13 | the footnote, in column 1, broken where the page breaks it (`^1The three cases … Tot. SS. Area` / `measurements of the digits … within S1. For` / `abbreviations, see list. Table was produced by using Canvas 3.5.5.`) |

Printed text is verbatim (parentheses, `%`, `±`, superscripts as `²` and `^1`); there are no
multi-line cells. Lay it beside PDF page 8 and read across: row *n* of the snapshot is printed line *n*
of the table.

### Structure of the analysis CSV

* **Long:** one row per printed value cell (3 cases + Average) x 7 measured columns = 28 rows, in the
  order the page is read (along each row). `snapshot_row` points at the value's area line in the
  snapshot (3, 5, 7, 9) and `snapshot_col` at its column; the printed percentage, where there is one,
  is on the next snapshot row (4, 6, 8, 10).
* `case_id` = the printed case number (NA on the Average row); `statistic` = `individual case` or
  `mean of cases`; `n_cases` = 1 or 3.
* `column_as_printed` keeps the printed header verbatim (Tot. SS, S1, S2, Digits, Vibrissae, Rostrum,
  HL/trunk) beside the standardised `representation` (Tot_SS, S1, S2, S1_digits, S1_vibrissae,
  S1_rostrum, S1_hindlimb_trunk), `cortical_field` and `percentage_base` (footnote 1: S1 and S2 are % of
  Tot. SS; the body parts are % of S1 and measured within S1 only).
* `cell_as_printed` (the area line and the percentage line beneath, joined with one space),
  `area_printed`, `percentage_printed`; `area_mm2` (value or printed mean) and `area_sd_mm2`;
  `percentage` and `percentage_sd`; `dispersion_type` = SD on the Average row (see below);
  `species_as_published`, `species`, `data_role` = primary, `note`.
* **Change on 2026-11-07:** the CSV keeps its 28 rows, 22 columns and every value, note included,
  except `snapshot_row`, which now points into the re-taken snapshot: 9213 stays 3; 9321 4 → 5; 9324
  5 → 7; Average 6 → 9 (21 cells). The public TSV changes in the same way.
* **Observation level:** individual animals plus the printed mean of those same animals. Use the case
  rows or the printed Average, not both. One hemisphere was mapped per animal (METHODS p. 31).
* **Units:** areas printed in mm² and kept in mm² (no conversion); percentages as printed.

## Table checks

The table carries its own arithmetic, so `Frost_etal_2000_TABLE1.R` re-runs it into `table_checks`
(build HOWTO §7a), reading the areas from the area lines and the percentages from the percentage lines
beneath them. Tolerance = only what rounding of the printed cells can explain: half a unit of each
input's last printed decimal per summed cell; one unit of the printed percentage for a recomputed
percentage; for a mean, half a unit of the inputs plus half a unit of the printed mean; for an SD,
√(n/(n−1)) × half a unit of the inputs plus half a unit of the printed SD. Each check's `note` also
says whether the printed value is reproduced exactly at its printed precision.

**Result — Python mirror, R execution pending: 52 pass, 0 mismatch, 3 not evaluable, of 55.**
51 of the 52 passes reproduce the printed value exactly at its printed precision.

| relation | checks | result | largest difference |
|---|---|---|---|
| Tot. SS = S1 + S2 (each case and the Average means) | 4 | 4 pass, all exact | 0 |
| S1 %, S2 % = 100 × area / Tot. SS; body-part % = 100 × area / S1 (each case); printed % vs the recomputed % rounded to the printed precision | 18 | 18 pass; all 18 recomputed percentages round to the printed integer | 0.46 points (HL/trunk, 9324: 16.54 → 17) |
| S1 % + S2 % = 100 (each case and the Average) | 4 | 4 pass, all exact | 0 |
| Body-part % (Digits + Vibrissae + Rostrum + HL/trunk) summed within each case | 3 | 3 not evaluable: no total of 100 exists (below) | — |
| Average area = mean of the 3 cases; dispersion = sample SD (n − 1) | 14 | 14 pass, all exact | see below |
| Average % = mean of the 3 printed case percentages; dispersion = sample SD | 12 | 12 pass, 11 exact | HL/trunk SD (below) |

Average-row checks (observed from the case rows vs printed):

| column | mean area (obs / printed) | SD area | mean % | SD % |
|---|---|---|---|---|
| Tot. SS | 6.353 / 6.35 | 0.819 / 0.82 | — | — |
| S1 | 4.330 / 4.33 | 0.651 / 0.65 | 68.000 / 68.0 | 3.606 / 3.6 |
| S2 | 2.023 / 2.02 | 0.326 / 0.33 | 32.000 / 32.0 | 3.606 / 3.6 |
| Digits | 1.030 / 1.03 | 0.350 / 0.35 | 23.333 / 23.3 | 4.726 / 4.7 |
| Vibrissae | 0.607 / 0.61 | 0.246 / 0.25 | 14.000 / 14.0 | 3.464 / 3.5 |
| Rostrum | 2.197 / 2.20 | 0.021 / 0.02 | 51.333 / 51.3 | 6.658 / 6.7 |
| HL/trunk | 0.770 / 0.77 | 0.151 / 0.15 | 17.667 / 17.7 | **0.577 / 1.0** |

**The one value not reproduced exactly:** the printed HL/trunk percentage SD (1.0%). The printed case
percentages 18, 18, 17% give 0.577; percentages recomputed from the printed areas (100 × HL/trunk / S1
= 18.38, 18.20, 16.54%) give 1.018, which does round to 1.0. It is within the rounding tolerance of the
printed cells, so the check passes; the value is kept as printed and flagged in the row's `note`. The
other five percentage columns are the reverse: their printed means and SDs reproduce from the printed
integer percentages and not from the area ratios (e.g. S1 68.0 vs 68.11 from areas; Vibrissae 14.0 vs
13.68), so the HL/trunk Average percentage cell (also the only one typeset with a second `%`) appears to
have been computed from unrounded percentages, unlike the other five. No publication error is claimed
and no erratum is filed.

**Body-part percentage sums (not evaluable):** the four S1 body-part columns are not a partition of S1.
The Results (p. 33) define the rostrum as "the glabrous snout, mystacial vibrissae, lower jaw, lips, and
oral cavity", so the vibrissae lie within the rostrum, and the four parts need not cover all of S1; the
table prints no total. Their printed percentages sum to 107, 108 and 104% for cases 9213, 9321 and 9324
(107.1, 108.0 and 103.4% from 100 × area / S1); without the vibrissae, 89, 96 and 92% (89.5, 96.4 and
91.6%). The build records these sums as `not_evaluable`: there is no total of 100 to test, and nothing
is wrong with the print.

The `table_checks` data frame stays in the R session (it is QA metadata, not data; HOWTO §7a).

## Flags and notes (kept as printed)

* **HL/trunk Average percentage** `(17.7% ± 1.0%)`: second `%` and the SD basis above — both in the
  row's `note`.
* **Vibrissae lies within Rostrum:** every Vibrissae and Rostrum row carries a note; never sum the four
  body-part columns.
* **Dispersion is unlabelled in print.** Neither the table nor its footnote says SD or SEM; every printed
  dispersion reproduces as the sample SD (n − 1) of the three cases, so `dispersion_type` = SD
  (inferred). The Results (p. 33) quote the rostrum as "51.3 ± 6.7%" without naming it either.
* **The Average percentages are means of the printed integer percentages**, not ratios of the mean areas
  (e.g. 4.33 / 6.35 = 68.2%, printed 68.0%). Do not expect them to equal 100 × mean area / mean base.
* **Text consistency:** the Results restate the table — "An average of 23% of S1 was devoted to the
  distal forelimb (see Table 1)" (p. 32; the Digits column), vibrissae "ranged from 12% to 18% of S1"
  (p. 33), rostrum "Half (51.3 ± 6.7%)" (p. 33), the posterior body (HL/trunk) "averaged 17.7% of the
  total S1 area" (p. 33); the abstract gives "~51%" for the rostrum. All agree with the table.
* Case 9321 is identified as a female in the Results (p. 39); the sex of 9213 and 9324 is not printed.

## Data role

**primary** — the authors' own measurements of their own maps (three of the five somatosensory maps;
footnote 1: "the highest resolution, the most definable boundaries ... fairly complete").

## Species names

The table prints case numbers only; `species_as_published` is "Monodelphis domestica" as printed in the
title, abstract and METHODS ("Gray Short-tailed opossums (*Monodelphis domestica*; 7 male, 5 female)").
**No `_keys/` file was edited.** The build resolves `species` from `_keys/General/species_key.csv` rows
with `source_publication = Frost_etal_2000`; there are none yet (re-checked 2026-11-07), so it falls back
to the proposed row in `reference_tables/Frost_etal_2000_species_key_proposed.csv` (same 7-column
schema; NCBI taxid 13616, as in the General key's existing *Monodelphis domestica* rows) and says so
when run. Adopt that row into the General key.

## Other numeric data in the paper (possible further items; not registered)

TABLE 1 is the paper's only table. Values printed elsewhere that could become items:

* **Results text (constructed text snapshot, e.g. `Frost_etal_2000_ResultsText`)** — ICMS motor maps
  (pp. 35–36): average threshold 50 µA (range 9 to 100 µA); excitable area 3.3 ± 2.1 mm² over the five
  complete maps, range 1.21–6.25 mm²; females (n = 2) 1.53 ± 0.45 mm², males (n = 3) 4.47 ± 1.94 mm²;
  per 100 g body weight 2.73 ± 0.5 (females) and 4.64 ± 2.68 mm²/100 g (males); laterality of ICMS
  responses 72.2 ± 15% contralateral, 16.6 ± 7% ipsilateral, 11.4 ± 12% bilateral. Low-impedance depth
  stimulation (pp. 36–39): thresholds 90–300 µA; 70.3% contralateral (89% ipsilateral in case 9321);
  excitable zone 4.1 mm² (4.9 mm²/100 g) in the most complete case, 9321. Bipolar surface stimulation
  (p. 39): thresholds 0.6–3 mA; 98 ± 1.5% contralateral; excitable zone 9.1 ± 2.5 mm²
  (10.9 ± 6.2 mm²/100 g); surface maps on average 2.75 times larger than ICMS maps (Discussion, p. 44).
  Body weights (pp. 30, 36): 45–139 g overall; females 45–67 g, males 89–139 g; 12 animals (7 male,
  5 female). These are the motor-map quantities most relevant to the M1-evolution axis.
* **Figures 12 (p. 44) and 14 (p. 46)** — per-site ICMS movement thresholds (µA) printed beside the
  stimulation sites for cases 9213 and 9211, with the matching sensory receptive fields (input/output
  coupling); printed in the figure graphics, so a transcription from the page image.
* **Figures 7, 8, 11 and 13** (ICMS maps: 9213 in Figs 7 and 11, four animals in Fig. 8, 9211 in
  Fig. 13), **Figure 9**
  (low-impedance map, 9321) and **Figure 10** (bipolar surface maps, 9316 and 9317): per-animal motor
  map areas and contralateral / ipsilateral / bilateral zones could be measured only by digitising the
  maps against their scale bars.
* **Figures 1–6 and 13** — somatosensory maps and receptive fields for cases 9213, 9321, 9324, 9212
  and 9211; 9212 and 9211 are not in TABLE 1, so their S1/S2 areas would need digitising.

## Files

| file | role |
|---|---|
| `Frost-2000-Somatosensory and motor representat.pdf` | the publication (born-digital) |
| `Frost_etal_2000_TABLE1_extract_snapshot.R` | text layer -> frozen snapshot (guarded; `--retake` only for a deliberate re-take) |
| `Frost_etal_2000_TABLE1_snapshot.csv` | frozen snapshot, one row per printed line, 13 rows x 8 cols (never edited by hand) |
| `archive/Frost_etal_2000_TABLE1_snapshot_superseded_2026-11-07.csv` | the superseded 7-row snapshot of 2026-11-06, kept for provenance; not read by any script |
| `Frost_etal_2000_TABLE1.R` | snapshot -> analysis CSV + public TSV + `table_checks` |
| `Frost_etal_2000_TABLE1.csv` | analysis CSV ("use this"), 28 rows x 22 cols |
| `Frost_etal_2000_TABLE1_python_mirror.py` | R NOT RUN stand-in that wrote the outputs; delete once the R reproduces them |
| `reference_tables/Frost_etal_2000_TABLE1_definitions.csv` | data dictionary (10-column schema) |
| `reference_tables/Frost_etal_2000_species_key_proposed.csv` | proposed `_keys/General/species_key.csv` row |
| `__Public/comparative-data/10.1002%2F(SICI)1096-9861(20000522)421%3A1%3C29%3A%3AAID-CNE3%3E3.0.CO;2-9_TABLE1.tsv` | public TSV (repo level) |

The paste helper `Frost_etal_2000_TABLE1_registry_row.xlsx` written on 2026-11-06 is no longer in this
folder (checked 2026-11-07); the registry row, found by Item name, already holds the values pasted from
it.

## Registry follow-up (owner)

The registry row still describes the 2026-11-06 snapshot and checks. After the re-take these cells are
out of date: **P** (N.B.: add that the snapshot was re-taken line by line on 2026-11-07, 13 rows, the
7-row file in `archive/`), **Q** (Progress stage: "build 52/52 checks" is now 52 pass, 0 mismatch,
3 not evaluable, of 55), **U** (Flags pre-addressed: the check counts, plus the body-part sums recorded
as not evaluable) and **AJ** (Human visual check: the AI assistant's check of 06112026 was of the
superseded snapshot; the AI assistant re-checked the new one on 07112026; human check pending). R
(Snapshot) and M (title) need no change.

## Human visual check of snapshot

**Pending human RA.** The AI assistant checked the re-taken snapshot against a 300-dpi page render on
2026-11-07 (described above); that is not a human check, and the check of 2026-11-06 was of the
superseded layout. A person still needs to lay `Frost_etal_2000_TABLE1_snapshot.csv` beside PDF page 8,
read a few rows **across** (including the middle case, 9321, its percentage line, and the Average and
its percentage line), and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column (AJ)
of `__ReadMe.xlsx`.
