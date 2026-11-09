# Latimer_Sawin_1955_TABLE2

**Item name** `Latimer_Sawin_1955_TABLE2` · **Item number** `TABLE 2` · **Item encoded** `10.1002%2Fcne.901030307_TABLE2` —
*the value the registry will resolve once column A of its row is fixed; today it resolves a broken code (see Registry).*

Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and the weight and length of the spinal cord in the rabbit (race X). *Journal of Comparative Neurology*, 103(3), 513–539. <https://doi.org/10.1002/cne.901030307>

**Item full original title:** TABLE 2. *Weights in grams and percentage weights of the brain and of its parts in 50 male
and in 50 female rabbits* (p. 518, PDF page 6).

> **R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The frozen snapshot, the analysis CSV, the public TSV and every table-check result quoted here were
> produced on 2026-11-06 by a Python mirror of the R scripts in this folder. Run, in this order:
> `Latimer_Sawin_1955_extract_snapshot.R`, `Latimer_Sawin_1955_TABLE1.R`, `Latimer_Sawin_1955_TABLE2.R` — after fixing column A of the registry rows, or the build
> scripts stop before the TSV. *Update 2026-11-07:* column A has been fixed by the owner, and the extract script now freezes
> six snapshots (TABLES 1, 2, 4, 5, 6, 7); TABLES 4 and 5 read this table's CSV for their cross-table checks.

## Source

PDF in this folder: `Latimer-1955-The weight of the brain, of its p.pdf` (27 pages, pp. 513–539), a 1955 journal scan
(Acrobat Paper Capture OCR over 300-ppi bitonal page images). Every value was read from the page image of PDF page 6.
The OCR traps on page 5 are in `Latimer_Sawin_1955_TABLE1.README.md`. Since 2026-11-07 the paper-level note on how TABLES 4,
5 and 7 feed the MacLarnon (1996) and Mink et al. (1981) rabbit rows is in `Latimer_Sawin_1955_TABLE4.README.md` (TABLES 4–7
built; TABLES 3 and 8 unregistered).

## Pipeline

```
Source (scanned PDF, page 6)
  -> Latimer_Sawin_1955_extract_snapshot.R       writes the frozen snapshots of TABLES 1, 2, 4, 5, 6 and 7
  -> Latimer_Sawin_1955_TABLE2_snapshot.xlsx     FROZEN: 20 rows x 8 cols, sheet "TABLE2"
  -> Latimer_Sawin_1955_TABLE2.R                 clean + parse + table checks (reads Latimer_Sawin_1955_TABLE1.csv for one informative check)
  -> Latimer_Sawin_1955_TABLE2.csv               98 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fcne.901030307_TABLE2.tsv
  -> reference_tables/Latimer_Sawin_1955_TABLE2_definitions.csv
  -> reference_tables/Latimer_Sawin_1955_species_key_proposed.csv   (shared with TABLE 1)
  -> reference_tables/Latimer_Sawin_1955_errata.csv                 (E002 belongs to this item)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant on 2026-11-06 from the PDF's own 300-ppi image of page 6
(extracted with `pdfimages`, no resampling), read at 1× and 2× zoom and typed as a verbatim printed-layout block into
`Latimer_Sawin_1955_extract_snapshot.R` (freezes; refuses to overwrite a differing copy). Cross-read cell by cell against the OCR text
layer: 98 numeric cells, **no numeric disagreement**; the text layer garbles the labels and headers instead ("Erdn" for
Brain in the first row, "dverage", "' :d." and "v","rf." for the column headers, "wrights" for weights, "fcmale" for
female). The build script reads the frozen file and contains no table values.

**R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The mirror parses the printed-layout block out of the R extract script and follows the build script step by
step, writing the CSV and the TSV as R's `write.csv` / `write.table` would. No R run has confirmed the outputs yet.

### Structure of the snapshot

* **One snapshot row per printed row**, 20 in all: the table number, the caption, two header tiers ("MALES" / "FEMALES"
  spanning Average, Stand. dev., Coef. var.; "“t” VALUES" spanning both tiers), then three blocks of data rows. The first
  block (weights in grams, five rows) **prints no block heading** — the caption names it; the other two are headed
  "Percentages of net body weight" (five rows) and "Percentages of total brain weight" (four rows, no Brain row).
  Reproduced as printed.
* Spanning headers sit in the first column of their span with blank padding; two-line headers are one cell holding a
  newline; numbers are kept as printed text, trailing zeros included (`0.060`, `66.90`).

### Structure of the analysis CSV

**Long**: one row per printed numeric cell, 14 printed rows × 7 cells = **98 rows × 21 columns**, read along
each printed row. Columns: `printed_row`, `snapshot_cell`, `block` (`weight`, `pct_net_body_weight`,
`pct_total_brain_weight`), `block_as_published` (NA for the grams block, which prints no heading),
`group_label_as_published`, `sex`, `group` (all), `n` (50 per sex, from the caption), `n_compared` ("50 vs 50" on the t
rows), `structure_as_published`, `measure` (structure + block, e.g. `brain_weight`, `medulla_pct_total_brain_weight`),
`statistic` (mean / sd / cv / t), `statistic_as_published`, `unit`, `value_printed`, `value`, **`mass.mg`**, `species`,
`species_as_published`, `data_role` (primary), `note`.

* **Project unit:** brain and brain-part mass in mg, `mass.mg` = printed grams × 1000, for the Average and Stand. dev. of
  the grams block (build HOWTO §6); NA elsewhere. The printed grams stay in `value_printed` / `value`.
* **"Medulla" includes the pons** (MATERIAL AND METHODS, p. 515: the brain "was divided into 4 parts: prosencephalon,
  mesencephalon, cerebellum and medulla (including the pons)"); its canonical structure in the definitions is
  `PonsMedulla`. The brain was weighed with the pia mater, cranial nerves and the hypophysial stalk cut close, and
  separated from the cord at the upper root filaments of the first cervical nerve; **total brain weight is the sum of
  the four parts** (p. 515).
* **Observation level: group summaries, not species means.** Each sex pools its normal and dwarf animals (15 of 50 males,
  20 of 50 females carry the dwarf gene); TABLES 4 and 5 (built 2026-11-07) give the two groups separately: pooled
  (n-weighted) they reproduce this table's gram Averages within rounding except the male Brain (E002) and the male
  Prosencephalon (E003).
* The percentages are means of per-animal percentages: not interchangeable with ratios of the printed means.

## Table checks

TABLE 2 prints a total (Brain, whose weight the paper defines as the sum of its four parts), a percentage block that
must add to 100, Coef. var. and t values. `Latimer_Sawin_1955_TABLE2.R` re-runs them into `table_checks` (build HOWTO §7a); comparisons
are in the printed units and nothing is changed to make a check pass.

| relation | rule and tolerance |
|---|---|
| Coef. var. = 100 × Stand. dev. / Average, every group (28) | worst case of 100 × (SD + ½ unit) / (Average − ½ unit) minus the recomputed value, plus ½ unit of the printed Coef. var. |
| "t" values, male vs female (14) | **pooled-variance Student t** from the printed Averages, SDs and n = 50 + 50 (SDs taken as divisor-(n − 1) SDs); tolerance as for TABLE 1: rounding of the inputs (worst case) + ½ unit of the printed t, and, only below the recomputed t, down to the divisor-n value (the formula is not stated). |
| Brain = Prosencephalon + Mesencephalon + Cerebellum + Medulla, grams (2) | ½ unit (0.0005 g) per summed cell and of the printed Brain = 0.0025 g |
| Percentages of total brain weight add to 100 (2) | no total is printed; 100 by definition; ½ unit (0.005) per summed cell = 0.02 |
| Percentages of net body weight vs the ratio of the printed means, 100 × Average grams / TABLE 1 Panel A Average net body weight (10) | **informative only**: a mean of per-animal ratios need not equal a ratio of means; no pass criterion, status `not_evaluable` |

**Result of the Python mirror: 44 pass, 2 mismatch, 10 not evaluable (the 10 informative comparisons), of 56 rows.** (R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.)

| family | checks | pass | mismatch | not evaluable |
|---|---|---|---|---|
| Coef. var. = 100 × SD / Average | 28 | 28 | 0 | 0 |
| “t” (pooled-variance Student t) | 14 | 13 | 1 | 0 |
| Brain = sum of its four parts (g) | 2 | 1 | 1 | 0 |
| % of total brain weight add to 100 | 2 | 2 | 0 | 0 |
| informative: % of net body weight vs ratio of means | 10 | 0 | 0 | 10 |

**Mismatches.** Every cell involved was re-read from the page image; the printed values are kept in the snapshot, the CSV
and the TSV, and each mismatch is written into the `note` of the row it concerns.

| check | snapshot cell | recomputed | printed | difference (recomputed − printed) | tolerance |
|---|---|---|---|---|---|
| `t_brain_weight` | H5 | 1.523 | 1.48 | +0.043 | 0.029 |
| `brain_sum_of_parts_male` | B5 | 9.1410 | 9.156 | -0.0150 | 0.0025 |

* `brain_sum_of_parts_male`: the four printed male part Averages, 6.118 + 0.753 + 1.381 + 0.889, add to **9.141 g**, but
  the male Brain Average prints **9.156 g** (+0.015 g; rounding allows 0.0025 g). The female parts agree (9.350 vs
  9.349). Recorded as errata **Latimer_Sawin_1955-E002** (proposed, `publication_ambiguity`). Evidence either way: TABLE 4 (p. 524)
  prints 9.265 g for the 35 normal and 8.849 g for the 15 dwarf males, which pool to 9.140 g — the parts sum, not 9.156;
  yet the row's own Coef. var. (5.86) can be reached from 9.156 and not from 9.141, and its t (1.48) is already lower than
  9.156 gives. The faulty cell cannot be identified from the paper; flag the male mean before using it as brain mass
  (0.16% of the mean).
* `t_brain_weight`: printed 1.48 against 1.52 recomputed (1.51 with divisor-n SDs); not significant either way, as the
  text says ("slightly, but not significantly, heavier").

All fourteen t checks:

| row (block) | recomputed t (SDs as divisor n−1) | t with divisor-n SDs | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| brain_weight | 1.523 | 1.508 | 1.48 | +0.043 | 0.029 | **mismatch** |
| prosencephalon_weight | 1.044 | 1.034 | 1.03 | +0.014 | 0.027 | pass |
| mesencephalon_weight | 2.579 | 2.553 | 2.56 | +0.019 | 0.130 | pass |
| cerebellum_weight | 2.622 | 2.596 | 2.59 | +0.032 | 0.089 | pass |
| medulla_weight | 1.418 | 1.404 | 1.43 | -0.012 | 0.083 | pass |
| brain_pct_net_body_weight | 2.640 | 2.614 | 2.66 | -0.020 | 0.085 | pass |
| prosencephalon_pct_net_body_weight | 2.777 | 2.749 | 2.74 | +0.037 | 0.149 | pass |
| mesencephalon_pct_net_body_weight | 1.250 | 1.237 | 1.55 | -0.300 | 0.755 | pass |
| cerebellum_pct_net_body_weight | 1.998 | 1.978 | 2.01 | -0.012 | 0.504 | pass |
| medulla_pct_net_body_weight | 2.661 | 2.634 | 2.45 | +0.211 | 0.813 | pass |
| prosencephalon_pct_total_brain_weight | 1.654 | 1.637 | 1.63 | +0.024 | 0.066 | pass |
| mesencephalon_pct_total_brain_weight | 1.382 | 1.368 | 1.37 | +0.012 | 0.110 | pass |
| cerebellum_pct_total_brain_weight | 1.627 | 1.611 | 1.61 | +0.017 | 0.099 | pass |
| medulla_pct_total_brain_weight | 0.182 | 0.180 | 0.18 | +0.002 | 0.098 | pass |

The coarse rounding of the percentage-of-body-weight block (three decimals on values near 0.05) makes its t tolerances
wide (up to ±0.8); those checks are weak.

Sums:

| check | sum of the printed cells | recomputed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `brain_sum_of_parts_male` | 6.118 + 0.753 + 1.381 + 0.889 | 9.141 | 9.156 | -0.015 | 0.0025 | **mismatch** |
| `brain_sum_of_parts_female` | 6.218 + 0.785 + 1.437 + 0.910 | 9.350 | 9.349 | +0.001 | 0.0025 | pass |
| `pct_total_brain_sum_male` | 66.90 + 8.25 + 15.13 + 9.72 | 100.000 | 100 (reference) | +0.000 | 0.0200 | pass |
| `pct_total_brain_sum_female` | 66.47 + 8.42 + 15.37 + 9.74 | 100.000 | 100 (reference) | +0.000 | 0.0200 | pass |

Informative comparison (no pass criterion) — percentages of net body weight (printed mean of per-animal ratios) against
100 × the printed Average grams / the printed TABLE 1 Panel A Average net body weight (1565.4 g males, 1734.9 g females):

| row | sex | ratio of the printed means | printed (mean of ratios) | ratio minus printed | relative |
|---|---|---|---|---|---|
| Brain | male | 0.5849 | 0.596 | -0.0111 | -1.9% |
| Brain | female | 0.5389 | 0.554 | -0.0151 | -2.7% |
| Prosencephalon | male | 0.3908 | 0.398 | -0.0072 | -1.8% |
| Prosencephalon | female | 0.3584 | 0.368 | -0.0096 | -2.6% |
| Mesencephalon | male | 0.0481 | 0.049 | -0.0009 | -1.8% |
| Mesencephalon | female | 0.0452 | 0.047 | -0.0018 | -3.7% |
| Cerebellum | male | 0.0882 | 0.090 | -0.0018 | -2.0% |
| Cerebellum | female | 0.0828 | 0.085 | -0.0022 | -2.6% |
| Medulla | male | 0.0568 | 0.058 | -0.0012 | -2.1% |
| Medulla | female | 0.0525 | 0.054 | -0.0015 | -2.9% |

The ratio of means is 1.8–3.7% below the printed mean of ratios in all ten cells. That is the direction expected: net
body weight varies far more between animals than brain weight does (Coef. var. 15.6% and 19.4% against 5.9% and 7.7%),
so the mean of the per-animal ratios exceeds the ratio of the means. Nothing here suggests a misprint.

The 28 Coef. var. checks all pass; the closest to its tolerance is `cv_medulla_pct_total_brain_weight_female` (difference
+0.0481, tolerance 0.0589).

## Data role

**primary** — the authors' own dissections and weighings of their own 100 animals, as group summaries.

## Species names

As for TABLE 1: `species_as_published` = "rabbit (race X)" (from the title; the table says "rabbits"); `species`
(*Oryctolagus cuniculus*) read from the species key, falling back to the proposed row in
`reference_tables/Latimer_Sawin_1955_species_key_proposed.csv`. **No `_keys/` file was edited.**

## Registry

**Update 2026-11-07:** the owner has fixed column A: read on 2026-11-07 the row resolves Item encoded
`10.1002%2Fcne.901030307_TABLE2`, the name of the public TSV, and N–AJ hold the pasted values. The rest of this section
records the state on 2026-11-06.

Row 995 of `__ReadMe.xlsx` has the same column A fault as row 994: it ends
`https://doi.org/https://doi.org/10.1002/cne.901030307 ` (duplicated prefix and a trailing space), so Item encoded
resolves to `https%3A%2F%2Fdoi.org%2F10.1002%2Fcne.901030307 _TABLE2`.

* **Fix:** make column A end `https://doi.org/10.1002/cne.901030307`, nothing after it (corrected citation in column A of
  `Latimer_Sawin_1955_registry_rows.xlsx`). Item encoded then becomes **`10.1002%2Fcne.901030307_TABLE2`**, the name of the public TSV
  already written to `__Public/comparative-data/`.
* Until then `Latimer_Sawin_1955_TABLE2.R` writes the analysis CSV and then **stops** before the TSV (whitespace / "https" guard, as in
  `Munger_etal_2022`).
* `__ReadMe.xlsx` was not edited; paste-ready values are in `Latimer_Sawin_1955_registry_rows.xlsx` (HOW_TO_PASTE sheet).

## Human visual check of snapshot

**Pending human RA.** No person has yet compared the snapshot with the page. Lay `Latimer_Sawin_1955_TABLE2_snapshot.xlsx` beside PDF
page 6, read a few rows **across** — including rows from the middle block and the four-row last block, which has no
Brain row — and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column (AJ).

Errata for this item are recorded in `reference_tables/Latimer_Sawin_1955_errata.csv` (E002). The block below is rendered by
`render_errata(paper_dir)`, which has not been run yet (R not available here).

<!-- errata:begin -->
<!-- errata:end -->
