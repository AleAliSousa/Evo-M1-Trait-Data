# Latimer_Sawin_1955_TABLE5

**Item name** `Latimer_Sawin_1955_TABLE5` · **Item number** `TABLE 5` · **Item encoded** `10.1002%2Fcne.901030307_TABLE5`
(as `__ReadMe.xlsx` resolves it for row 997, read 2026-11-07).

Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and the weight and length of the spinal cord in the rabbit (race X). *Journal of Comparative Neurology*, 103(3), 513–539. <https://doi.org/10.1002/cne.901030307>

**Item full original title:** TABLE 5. *Weights of the brain and of its parts in 30 normal and in 20 dwarf female
rabbits* (p. 525, PDF page 13). (The registry's column M reads "80 dwarf", as the OCR text layer does; the page prints 20 — see Registry.)

> **R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The frozen snapshot, the analysis CSV, the public TSV and every table-check result quoted here were
> produced on 2026-11-07 by a Python mirror of the R scripts in this folder. Run, in this order:
> `Latimer_Sawin_1955_extract_snapshot.R` (it should report all six frozen snapshots as identical), `Latimer_Sawin_1955_TABLE1.R`, `Latimer_Sawin_1955_TABLE2.R`, then `Latimer_Sawin_1955_TABLE5.R`
> (it reads `Latimer_Sawin_1955_TABLE1.csv` and `Latimer_Sawin_1955_TABLE2.csv` for its cross-table checks); then `render_errata()` on the paper folder.

## Source

PDF in this folder: `Latimer-1955-The weight of the brain, of its p.pdf` (27 pages, pp. 513–539), a 1955 journal scan
(Acrobat Paper Capture OCR over 300-ppi bitonal page images). Every value was read from a 300-dpi render of PDF page 13.
The paper-level note (MacLarnon 1996, Mink et al. 1981) is in `Latimer_Sawin_1955_TABLE4.README.md`.

## Pipeline

```
Source (scanned PDF, page 13)
  -> Latimer_Sawin_1955_extract_snapshot.R       writes the frozen snapshots of TABLES 1, 2, 4, 5, 6 and 7
  -> Latimer_Sawin_1955_TABLE5_snapshot.xlsx     FROZEN: 21 rows x 8 cols, sheet "TABLE5"
  -> Latimer_Sawin_1955_TABLE5.R                 clean + parse + table checks (reads Latimer_Sawin_1955_TABLE1.csv and _TABLE2.csv)
  -> Latimer_Sawin_1955_TABLE5.csv               98 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fcne.901030307_TABLE5.tsv
  -> reference_tables/Latimer_Sawin_1955_TABLE5_definitions.csv
  -> reference_tables/Latimer_Sawin_1955_species_key_proposed.csv   (shared by all six items)
  -> reference_tables/Latimer_Sawin_1955_errata.csv                 (E004 belongs to this item)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant on 2026-11-07 from a 300-dpi render of PDF page 13
(`pdftoppm -r 300`), read at 1× and 2× zoom, and at 4× for every cell the text layer reads differently, and typed as a
verbatim printed-layout block into `Latimer_Sawin_1955_extract_snapshot.R` (freezes; refuses to overwrite a differing copy). The block was
then cross-read cell by cell twice: against the PDF's OCR text layer (98 numeric cells, **no numeric disagreement**; the caption's n and the labels are garbled instead; below) and against an independent tesseract
OCR of the same render (98 cells, no disagreement). The build script reads the frozen file and contains no table values.

**R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The mirror parses the printed-layout block out of the R extract script and follows the build script step by step, writing the CSV and the TSV as R's `write.csv` / `write.table` would. No R run has confirmed the outputs yet.

### OCR traps (text layer vs page image)

| where | text layer | page image |
|---|---|---|
| caption (snapshot A2) | `... in 30 normal and in 80 dwarf female rabbits` | **... in 20 dwarf female rabbits** (read at 4×; TABLE 1 Panel C prints "20 DWARF" and 30 + 20 = 50 females) |
| caption | `i t s` | its |
| group header and “t” header | `DWABF`, `Ut”` | DWARF, “t” |
| column headers | `Spe;d.`, `Spa.`, `Tar.` | Stand. dev., Coef. var. |
| row labels | `Srain`, `Frosencephalon`, `C’erebellum` | Brain, Prosencephalon, Cerebellum |
| block heading | `Percentages of iiet body weight` | Percentages of net body weight |

### Structure of the snapshot

* **One snapshot row per printed row**, 21 in all: the table number, the caption, two header tiers ("NORMAL" / "DWARF"
  spanning Average, Stand. dev., Coef. var.; "“t” VALUES" spanning both tiers), then three blocks of data rows, each under its
  printed heading — "Weights in grams" (5 rows), "Percentages of net body weight" (5), "Percentages of brain weight" (4, no
  Brain row). TABLE 5 prints no footnote (TABLE 4's covers tables 4, 5 and 7).
* Unlike TABLE 2, the grams block prints its heading, and the third heading reads "brain weight", not "total brain weight".
  The group headers print no n; the caption does (30 normal, 20 dwarf).
* Block headings sit in the first column; spanning headers sit in the first column of their span with blank padding;
  two-line headers are one cell holding a newline; numbers are kept as printed text, trailing zeros included
  (`8.740`, `0.100`, `9.70`).

### Structure of the analysis CSV

**Long**: one row per printed numeric cell, 14 printed rows × 7 cells = **98 rows × 21 columns**, the columns of
`Latimer_Sawin_1955_TABLE2.csv`: `printed_row`, `snapshot_cell`, `block` (`weight`, `pct_net_body_weight`, `pct_brain_weight`),
`block_as_published`, `group_label_as_published` (NORMAL / DWARF), `sex` (female), `group` (normal / dwarf; "normal vs
dwarf" on the t rows), `n` (30 / 20, from the caption), `n_compared` ("30 vs 20" on the t rows),
`structure_as_published`, `measure` (e.g. `brain_weight`, `medulla_pct_brain_weight`), `statistic` (mean / sd / cv / t),
`statistic_as_published`, `unit`, `value_printed`, `value`, **`mass.mg`**, `species`, `species_as_published`, `data_role`
(primary), `note`.

* **Project unit:** brain and brain-part mass in mg, `mass.mg` = printed grams × 1000, for the Average and Stand. dev. of the
  grams block (build HOWTO §6); NA elsewhere. The printed grams stay in `value_printed` / `value`.
* **"Medulla" includes the pons** (MATERIAL AND METHODS, p. 515; canonical structure `PonsMedulla`), and **total brain weight
  is the sum of the four parts** (p. 515).
* **Measure codes follow the printed headings:** the percentage of brain weight is `*_pct_brain_weight` here and
  `*_pct_total_brain_weight` in TABLE 2 — the same quantity (definitions Measure `pct.Brain` in both).
* **Observation level: group summaries of the 30 normal and the 20 dwarf females, not species means.** Dwarf = heterozygous
  for the dwarf gene (lethal when homozygous), normal = homozygous non-dwarf (p. 516). All 50 females are in TABLE 2: pool
  explicitly (n-weighted) or use TABLE 2, and never merge both.
* The percentages are means of per-animal percentages: not interchangeable with ratios of the printed means.

## Table checks

TABLE 5 prints a total (Brain, the sum of its four parts by the paper's own definition), a percentage block that must add
to 100, Coef. var. and t values; and its two groups together are the females of TABLE 2. `Latimer_Sawin_1955_TABLE5.R` re-runs all of these
into `table_checks` (build HOWTO §7a); comparisons are in the printed units and nothing is changed to make a check pass.

| relation | rule and tolerance |
|---|---|
| Coef. var. = 100 × Stand. dev. / Average, every group (28) | worst case of 100 × (SD + ½ unit) / (Average − ½ unit) minus the recomputed value, plus ½ unit of the printed Coef. var. |
| "t" values, NORMAL vs DWARF (14) | **pooled-variance Student t** from the printed Averages, SDs and n = 30 + 20 (SDs taken as divisor-(n − 1) SDs); tolerance as for TABLES 1 and 2: rounding of the inputs (worst case) + ½ unit of the printed t, and, only below the recomputed t, down to the divisor-n value (the formula is not stated) |
| Brain = Prosencephalon + Mesencephalon + Cerebellum + Medulla, grams, each group (2) | ½ unit (0.0005 g) per summed cell and of the printed Brain = 0.0025 g |
| Percentages of brain weight add to 100, each group (2) | no total is printed; 100 by definition; ½ unit (0.005) per summed cell = 0.02 |
| Across tables: NORMAL n + DWARF n (caption) = TABLE 2 n (1) | exact |
| Across tables: NORMAL and DWARF Averages pooled (n-weighted) = TABLE 2 FEMALES Average, every grams row (5) | ½ unit of each group Average, n-weighted, plus ½ unit of the TABLE 2 Average = 0.001 g |
| Percentages of net body weight vs the ratio of the printed means, 100 × Average grams / TABLE 1 Panel C Average net body weight of the same group (10) | **informative only**: a mean of per-animal ratios need not equal a ratio of means; no pass criterion, status `not_evaluable` |

**Result of the Python mirror: 51 pass, 1 mismatch, 10 not evaluable (the 10 informative comparisons), of 62.** (R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.)

| family | checks | pass | mismatch | not evaluable |
|---|---|---|---|---|
| Coef. var. = 100 × SD / Average | 28 | 28 | 0 | 0 |
| “t” (pooled-variance Student t) | 14 | 13 | 1 | 0 |
| Brain = sum of its four parts (g) | 2 | 2 | 0 | 0 |
| % of brain weight add to 100 | 2 | 2 | 0 | 0 |
| n against TABLE 2 | 1 | 1 | 0 | 0 |
| NORMAL + DWARF pooled against TABLE 2 (g) | 5 | 5 | 0 | 0 |
| informative: % of net body weight vs ratio of means | 10 | 0 | 0 | 10 |

**Mismatches.** Every cell involved was re-read from the page image at 4× zoom; the printed values are kept in the snapshot,
the CSV and the TSV, and each mismatch is written into the `note` of the row(s) it concerns.

| check | snapshot cell(s) | recomputed | printed | difference (recomputed − printed) | tolerance |
|---|---|---|---|---|---|
| `t_cerebellum_weight` | H9 | 6.188 | 4.35 | +1.838 | 0.203 |

* `t_cerebellum_weight` (H9): from the printed Averages, SDs and n (1.503 g, SD 0.087, n = 30 against 1.338 g, SD 0.100, n = 20) Student t is **6.19** (6.06 with divisor-n SDs); the page prints **4.35**, which would need an Average difference of 0.116 g instead of 0.165 g. Every other relation holds for this row (its Coef. var., the pooled Average against TABLE 2's 1.437 g, both groups' sums of parts), and the other 13 t values reproduce: the t is the faulty cell. Recorded as errata **Latimer_Sawin_1955-E004** (proposed, `publication_error`); significant at 1% either way (TABLE 4's footnote: 2.68 and above).

All fourteen t checks:

| row (block) | recomputed t (SDs as divisor n−1) | t with divisor-n SDs | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| brain_weight | 6.661 | 6.522 | 6.66 | +0.001 | 0.157 | pass |
| prosencephalon_weight | 6.180 | 6.054 | 6.12 | +0.060 | 0.147 | pass |
| mesencephalon_weight | 2.700 | 2.644 | 2.70 | +0.000 | 0.139 | pass |
| cerebellum_weight | 6.188 | 6.060 | 4.35 | +1.838 | 0.203 | **mismatch** |
| medulla_weight | 5.226 | 5.123 | 5.20 | +0.026 | 0.209 | pass |
| brain_pct_net_body_weight | 7.862 | 7.706 | 7.80 | +0.062 | 0.291 | pass |
| prosencephalon_pct_net_body_weight | 6.984 | 6.849 | 6.95 | +0.034 | 0.309 | pass |
| mesencephalon_pct_net_body_weight | 8.753 | 8.559 | 8.67 | +0.083 | 0.343 | pass |
| cerebellum_pct_net_body_weight | 8.229 | 8.055 | 8.14 | +0.089 | 0.272 | pass |
| medulla_pct_net_body_weight | 8.794 | 8.614 | 8.56 | +0.234 | 0.334 | pass |
| prosencephalon_pct_brain_weight | 1.294 | 1.270 | 1.28 | +0.014 | 0.065 | pass |
| mesencephalon_pct_brain_weight | 2.446 | 2.394 | 2.43 | +0.016 | 0.133 | pass |
| cerebellum_pct_brain_weight | 0.662 | 0.650 | 0.65 | +0.012 | 0.082 | pass |
| medulla_pct_brain_weight | 0.799 | 0.784 | 0.79 | +0.009 | 0.098 | pass |

Sums:

| check | sum of the printed cells | recomputed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `brain_sum_of_parts_normal` | 6.503 + 0.804 + 1.503 + 0.945 | 9.755 | 9.755 | +0.000 | 0.0025 | pass |
| `brain_sum_of_parts_dwarf` | 5.789 + 0.757 + 1.338 + 0.857 | 8.741 | 8.740 | +0.001 | 0.0025 | pass |
| `pct_brain_weight_sum_normal` | 66.64 + 8.25 + 15.41 + 9.70 | 100.000 | 100 (reference) | +0.000 | 0.0200 | pass |
| `pct_brain_weight_sum_dwarf` | 66.22 + 8.67 + 15.30 + 9.81 | 100.000 | 100 (reference) | +0.000 | 0.0200 | pass |

Across tables — the two groups pooled against TABLE 2 (all 50 females; TABLE 2's values read as printed from `Latimer_Sawin_1955_TABLE2.csv`):

| check | pooled from | recomputed | printed in TABLE 2 | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_vs_TABLE2_female` | NORMAL n + DWARF n | 50 | 50 | +0 | 0 | pass |
| `pooled_vs_TABLE2_brain_weight_female` | (30 x 9.755 + 20 x 8.740) / 50 | 9.3490 | 9.349 | +0.0000 | 0.0010 | pass |
| `pooled_vs_TABLE2_prosencephalon_weight_female` | (30 x 6.503 + 20 x 5.789) / 50 | 6.2174 | 6.218 | -0.0006 | 0.0010 | pass |
| `pooled_vs_TABLE2_mesencephalon_weight_female` | (30 x 0.804 + 20 x 0.757) / 50 | 0.7852 | 0.785 | +0.0002 | 0.0010 | pass |
| `pooled_vs_TABLE2_cerebellum_weight_female` | (30 x 1.503 + 20 x 1.338) / 50 | 1.4370 | 1.437 | -0.0000 | 0.0010 | pass |
| `pooled_vs_TABLE2_medulla_weight_female` | (30 x 0.945 + 20 x 0.857) / 50 | 0.9098 | 0.910 | -0.0002 | 0.0010 | pass |

Informative comparison (no pass criterion) — percentages of net body weight (printed mean of per-animal ratios) against
100 × the printed Average grams / the printed TABLE 1 Panel C Average net body weight of the same group (1959.3 g normal,
1398.4 g dwarf):

| row | group | ratio of the printed means | printed (mean of ratios) | ratio minus printed | relative |
|---|---|---|---|---|---|
| Brain | normal | 0.4979 | 0.504 | -0.0061 | -1.21% |
| Brain | dwarf | 0.6250 | 0.629 | -0.0040 | -0.64% |
| Prosencephalon | normal | 0.3319 | 0.336 | -0.0041 | -1.22% |
| Prosencephalon | dwarf | 0.4140 | 0.416 | -0.0020 | -0.49% |
| Mesencephalon | normal | 0.0410 | 0.0414 | -0.0004 | -0.88% |
| Mesencephalon | dwarf | 0.0541 | 0.0545 | -0.0004 | -0.67% |
| Cerebellum | normal | 0.0767 | 0.0775 | -0.0008 | -1.02% |
| Cerebellum | dwarf | 0.0957 | 0.0962 | -0.0005 | -0.54% |
| Medulla | normal | 0.0482 | 0.0487 | -0.0005 | -0.96% |
| Medulla | dwarf | 0.0613 | 0.0617 | -0.0004 | -0.67% |

The ratio of means is 0.5–1.2% below the printed mean of ratios in all ten cells — the
direction expected when the denominator (net body weight) varies more between animals than the numerator. Nothing here
suggests a misprint.

The 28 Coef. var. checks all pass; the closest to its tolerance is `cv_cerebellum_pct_brain_weight_normal` (difference
-0.0317, tolerance 0.0388).

### Observations (the AI assistant's arithmetic, not R checks)

* Standard deviations rebuilt from the two groups against TABLE 2's female SDs: Brain 0.725 (TABLE 2: 0.717), Prosencephalon 0.531 (0.528), Mesencephalon 0.064 (0.064), Cerebellum 0.123 (0.122), Medulla 0.072 (0.072): consistent.
* Percentages of brain weight against the ratio of the printed gram means: all eight cells within 0.03 percentage points.
* The text agrees with the printed Coef. var. (p. 523): "With one exception (female medulla) the brain and all of its parts are more variable in the dwarf rabbits" (here the medulla, 6.30 against 6.44, is the one dwarf CV below the normal); as percentages of brain weight the dwarfs are less variable "With two exceptions" (here the mesencephalon, 7.74 against 6.49; TABLE 4's cerebellum is the other).

## Data role

**primary** — the authors' own dissections and weighings of their own animals, as group summaries.

## Species names

As for TABLES 1 and 2: `species_as_published` = "rabbit (race X)" (the paper's title; the table prints no species); `species` (*Oryctolagus cuniculus*) is read from the species key — `_keys/General/species_key.csv` first, else the proposed row in `reference_tables/Latimer_Sawin_1955_species_key_proposed.csv` (its item list now names TABLES 1, 2 and 4–7). **No `_keys/` file was edited.**

## Registry

Row 997 of `__ReadMe.xlsx` (read 2026-11-07) was added by the owner: column A (the citation, ending with a single `https://doi.org/10.1002/cne.901030307`), D (`TABLE 5`) and M. Its formulas (E–L) resolve Item name `Latimer_Sawin_1955_TABLE5` and Item encoded `10.1002%2Fcne.901030307_TABLE5`, the name under which the public TSV was uploaded; L (Public TSV match) reads `notfound` until `_tools/file_list.R` is run. **Column M reads "... in 30 normal and in 80 dwarf female rabbits"** — the OCR text layer's reading. The page prints **20** (read at 4×; TABLE 1 Panel C prints "20 DWARF"; 30 + 20 = 50). The registry was not edited and the paste file keeps the owner's M verbatim; correct it by hand if wished.

* Columns N–AJ of the row still hold the owner's template copy of the TABLE 2 row. Paste N–AJ from `Latimer_Sawin_1955_TABLE4-7_registry_rows.xlsx` (find the row by Item name; HOW_TO_PASTE sheet). Never paste over E–L (formulas).
* `__ReadMe.xlsx` was not edited.

## Human visual check of snapshot

**Pending human RA.** The transcription and the checks above were done by an AI assistant; no person has yet compared the snapshot with the page. Lay `Latimer_Sawin_1955_TABLE5_snapshot.xlsx` beside PDF page 13, read a few rows **across** — including the four-row last block, which has no Brain row — and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column (AJ).

Errata for this item are recorded in `reference_tables/Latimer_Sawin_1955_errata.csv` (E004). The block below is rendered by
`render_errata(paper_dir)`, which has not been run yet (R not available here).

<!-- errata:begin -->
<!-- errata:end -->
