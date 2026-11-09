# Latimer_Sawin_1955_TABLE4

**Item name** `Latimer_Sawin_1955_TABLE4` · **Item number** `TABLE 4` · **Item encoded** `10.1002%2Fcne.901030307_TABLE4`
(as `__ReadMe.xlsx` resolves it for row 996, read 2026-11-07).

Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and the weight and length of the spinal cord in the rabbit (race X). *Journal of Comparative Neurology*, 103(3), 513–539. <https://doi.org/10.1002/cne.901030307>

**Item full original title:** TABLE 4. *Weights of the brain and of its parts in 35 normal and in 15 dwarf male
rabbits* (p. 524, PDF page 12).

> **R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The frozen snapshot, the analysis CSV, the public TSV and every table-check result quoted here were
> produced on 2026-11-07 by a Python mirror of the R scripts in this folder. Run, in this order:
> `Latimer_Sawin_1955_extract_snapshot.R` (it should report all six frozen snapshots as identical), `Latimer_Sawin_1955_TABLE1.R`, `Latimer_Sawin_1955_TABLE2.R`, then `Latimer_Sawin_1955_TABLE4.R`
> (it reads `Latimer_Sawin_1955_TABLE1.csv` and `Latimer_Sawin_1955_TABLE2.csv` for its cross-table checks); then `render_errata()` on the paper folder.

This README also carries the **paper-level note** on how TABLES 4, 5 and 7 feed the MacLarnon (1996) and Mink et al.
(1981) rabbit rows (see *Paper-level note*, below).

## Source

PDF in this folder: `Latimer-1955-The weight of the brain, of its p.pdf` (27 pages, pp. 513–539), a 1955 journal scan
(Acrobat Paper Capture OCR over 300-ppi bitonal page images). Every value was read from a 300-dpi render of PDF page 12.

## Pipeline

```
Source (scanned PDF, page 12)
  -> Latimer_Sawin_1955_extract_snapshot.R       writes the frozen snapshots of TABLES 1, 2, 4, 5, 6 and 7
  -> Latimer_Sawin_1955_TABLE4_snapshot.xlsx     FROZEN: 22 rows x 8 cols, sheet "TABLE4"
  -> Latimer_Sawin_1955_TABLE4.R                 clean + parse + table checks (reads Latimer_Sawin_1955_TABLE1.csv and _TABLE2.csv)
  -> Latimer_Sawin_1955_TABLE4.csv               98 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fcne.901030307_TABLE4.tsv
  -> reference_tables/Latimer_Sawin_1955_TABLE4_definitions.csv
  -> reference_tables/Latimer_Sawin_1955_species_key_proposed.csv   (shared by all six items)
  -> reference_tables/Latimer_Sawin_1955_errata.csv                 (E003 belongs to this item; E002, on TABLE 2, is referenced by one of its checks)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant on 2026-11-07 from a 300-dpi render of PDF page 12
(`pdftoppm -r 300`), read at 1× and 2× zoom, and at 4× for every cell the text layer reads differently, and typed as a
verbatim printed-layout block into `Latimer_Sawin_1955_extract_snapshot.R` (freezes; refuses to overwrite a differing copy). The block was
then cross-read cell by cell twice: against the PDF's OCR text layer (98 numeric cells, **three disagreements**, all text-layer errors; below) and against an independent tesseract
OCR of the same render (98 cells, no disagreement). The build script reads the frozen file and contains no table values.

**R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The mirror parses the printed-layout block out of the R extract script and follows the build script step by step, writing the CSV and the TSV as R's `write.csv` / `write.table` would. No R run has confirmed the outputs yet.

### OCR traps (text layer vs page image)

| where | text layer | page image |
|---|---|---|
| Weights in grams, Brain, NORMAL Average (snapshot B6) | `9.205` | **9.265** (100 × 0.459/9.265 = 4.95, as printed; 9.205 would give 4.99) |
| Percentages of net body weight, Medulla, DWARF Average (E16) | `O.OG39` | **0.0639** |
| Percentages of net body weight, Cerebellum, “t” (H15) | `3.5-1` | **3.54** |
| group header | `DWAEB` | DWARF |
| column headers | `Sgrtd.`, `Stp~d.`; several header words missing | Stand. dev., Coef. var. |
| row labels, grams block | `Nesencephalon`, `llledulla` | Mesencephalon, Medulla |
| block headings | `Weights in granis`, `Fercentages of net body Tveiglit` | Weights in grams, Percentages of net body weight |
| footnote | `“ t ”`, `a t 1%and`, `a t 5%` | “t”, at 1% and, at 5% |

### Structure of the snapshot

* **One snapshot row per printed row**, 22 in all: the table number, the caption, two header tiers ("NORMAL" / "DWARF"
  spanning Average, Stand. dev., Coef. var.; "“t” VALUES" spanning both tiers), then three blocks of data rows, each under its
  printed heading — "Weights in grams" (5 rows), "Percentages of net body weight" (5), "Percentages of brain weight" (4, no
  Brain row); last, the printed footnote: "In tables 4, 5, and 7, “t” values of 2.68 and above are significant at 1% and those between 2.01 and 2.67, are significant at 5% level.".
* Unlike TABLE 2, the grams block prints its heading, and the third heading reads "brain weight", not "total brain weight".
  The group headers print no n; the caption does (35 normal, 15 dwarf).
* Block headings sit in the first column; spanning headers sit in the first column of their span with blank padding;
  two-line headers are one cell holding a newline; numbers are kept as printed text, trailing zeros included
  (`0.610`, `0.0060`, `9.70`).

### Structure of the analysis CSV

**Long**: one row per printed numeric cell, 14 printed rows × 7 cells = **98 rows × 21 columns**, the columns of
`Latimer_Sawin_1955_TABLE2.csv`: `printed_row`, `snapshot_cell`, `block` (`weight`, `pct_net_body_weight`, `pct_brain_weight`),
`block_as_published`, `group_label_as_published` (NORMAL / DWARF), `sex` (male), `group` (normal / dwarf; "normal vs
dwarf" on the t rows), `n` (35 / 15, from the caption), `n_compared` ("35 vs 15" on the t rows),
`structure_as_published`, `measure` (e.g. `brain_weight`, `medulla_pct_brain_weight`), `statistic` (mean / sd / cv / t),
`statistic_as_published`, `unit`, `value_printed`, `value`, **`mass.mg`**, `species`, `species_as_published`, `data_role`
(primary), `note`.

* **Project unit:** brain and brain-part mass in mg, `mass.mg` = printed grams × 1000, for the Average and Stand. dev. of the
  grams block (build HOWTO §6); NA elsewhere. The printed grams stay in `value_printed` / `value`.
* **"Medulla" includes the pons** (MATERIAL AND METHODS, p. 515; canonical structure `PonsMedulla`), and **total brain weight
  is the sum of the four parts** (p. 515).
* **Measure codes follow the printed headings:** the percentage of brain weight is `*_pct_brain_weight` here and
  `*_pct_total_brain_weight` in TABLE 2 — the same quantity (definitions Measure `pct.Brain` in both).
* **Observation level: group summaries of the 35 normal and the 15 dwarf males, not species means.** Dwarf = heterozygous
  for the dwarf gene (lethal when homozygous), normal = homozygous non-dwarf (p. 516). All 50 males are in TABLE 2: pool
  explicitly (n-weighted) or use TABLE 2, and never merge both.
* The percentages are means of per-animal percentages: not interchangeable with ratios of the printed means.

## Table checks

TABLE 4 prints a total (Brain, the sum of its four parts by the paper's own definition), a percentage block that must add
to 100, Coef. var. and t values; and its two groups together are the males of TABLE 2. `Latimer_Sawin_1955_TABLE4.R` re-runs all of these
into `table_checks` (build HOWTO §7a); comparisons are in the printed units and nothing is changed to make a check pass.

| relation | rule and tolerance |
|---|---|
| Coef. var. = 100 × Stand. dev. / Average, every group (28) | worst case of 100 × (SD + ½ unit) / (Average − ½ unit) minus the recomputed value, plus ½ unit of the printed Coef. var. |
| "t" values, NORMAL vs DWARF (14) | **pooled-variance Student t** from the printed Averages, SDs and n = 35 + 15 (SDs taken as divisor-(n − 1) SDs); tolerance as for TABLES 1 and 2: rounding of the inputs (worst case) + ½ unit of the printed t, and, only below the recomputed t, down to the divisor-n value (the formula is not stated) |
| Brain = Prosencephalon + Mesencephalon + Cerebellum + Medulla, grams, each group (2) | ½ unit (0.0005 g) per summed cell and of the printed Brain = 0.0025 g |
| Percentages of brain weight add to 100, each group (2) | no total is printed; 100 by definition; ½ unit (0.005) per summed cell = 0.02 |
| Across tables: NORMAL n + DWARF n (caption) = TABLE 2 n (1) | exact |
| Across tables: NORMAL and DWARF Averages pooled (n-weighted) = TABLE 2 MALES Average, every grams row (5) | ½ unit of each group Average, n-weighted, plus ½ unit of the TABLE 2 Average = 0.001 g |
| Percentages of net body weight vs the ratio of the printed means, 100 × Average grams / TABLE 1 Panel B Average net body weight of the same group (10) | **informative only**: a mean of per-animal ratios need not equal a ratio of means; no pass criterion, status `not_evaluable` |

**Result of the Python mirror: 49 pass, 3 mismatch, 10 not evaluable (the 10 informative comparisons), of 62.** (R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.)

| family | checks | pass | mismatch | not evaluable |
|---|---|---|---|---|
| Coef. var. = 100 × SD / Average | 28 | 28 | 0 | 0 |
| “t” (pooled-variance Student t) | 14 | 14 | 0 | 0 |
| Brain = sum of its four parts (g) | 2 | 1 | 1 | 0 |
| % of brain weight add to 100 | 2 | 2 | 0 | 0 |
| n against TABLE 2 | 1 | 1 | 0 | 0 |
| NORMAL + DWARF pooled against TABLE 2 (g) | 5 | 3 | 2 | 0 |
| informative: % of net body weight vs ratio of means | 10 | 0 | 0 | 10 |

**Mismatches.** Every cell involved was re-read from the page image at 4× zoom; the printed values are kept in the snapshot,
the CSV and the TSV, and each mismatch is written into the `note` of the row(s) it concerns.

| check | snapshot cell(s) | recomputed | printed | difference (recomputed − printed) | tolerance |
|---|---|---|---|---|---|
| `brain_sum_of_parts_normal` | B6 | 9.2940 | 9.265 | +0.0290 | 0.0025 |
| `pooled_vs_TABLE2_brain_weight_male` | B6, E6 | 9.1402 | TABLE 2: 9.156 | -0.0158 | 0.0010 |
| `pooled_vs_TABLE2_prosencephalon_weight_male` | B7, E7 | 6.1381 | TABLE 2: 6.118 | +0.0201 | 0.0010 |

* `brain_sum_of_parts_normal` and `pooled_vs_TABLE2_prosencephalon_weight_male` point at **the same cell, the NORMAL Prosencephalon Average (B7, 6.241 g)**. The NORMAL parts add to 9.294 g against a printed Brain of 9.265 g; pooled with the DWARF 5.898 g, the prosencephalon gives 6.138 g against TABLE 2's 6.118 g. A NORMAL prosencephalon of 6.212 g would satisfy both exactly, and would also fit the row's printed percentage of brain weight (100 × 6.212/9.265 = 67.05 against the printed 67.02; 6.241 gives 67.36, while the other seven part percentages of this table sit within 0.03 of their ratio of means). Against it, the row's Coef. var. (5.48) and t (2.95) follow 6.241. Recorded as errata **Latimer_Sawin_1955-E003** (proposed, `publication_ambiguity`); 6.212 is not proposed as a value. The DWARF parts add to their Brain exactly (8.849 g).
* `pooled_vs_TABLE2_brain_weight_male`: the NORMAL and DWARF Brain Averages pool to **9.140 g**, against TABLE 2's 9.156 g. This is errata **Latimer_Sawin_1955-E002** (on TABLE 2) seen from this table: the pool agrees with the sum of TABLE 2's own male parts (9.141 g), not with its printed Brain. Noted on both Brain rows (B6, E6) with E002.

All fourteen t checks:

| row (block) | recomputed t (SDs as divisor n−1) | t with divisor-n SDs | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| brain_weight | 2.655 | 2.595 | 2.63 | +0.025 | 0.074 | pass |
| prosencephalon_weight | 2.972 | 2.905 | 2.95 | +0.022 | 0.084 | pass |
| mesencephalon_weight | 0.261 | 0.255 | 0.27 | -0.009 | 0.060 | pass |
| cerebellum_weight | 2.767 | 2.707 | 2.75 | +0.017 | 0.119 | pass |
| medulla_weight | 1.500 | 1.470 | 1.48 | +0.020 | 0.087 | pass |
| brain_pct_net_body_weight | 3.957 | 3.882 | 3.92 | +0.037 | 0.155 | pass |
| prosencephalon_pct_net_body_weight | 3.680 | 3.611 | 3.62 | +0.060 | 0.178 | pass |
| mesencephalon_pct_net_body_weight | 4.873 | 4.780 | 4.85 | +0.023 | 0.184 | pass |
| cerebellum_pct_net_body_weight | 3.573 | 3.506 | 3.54 | +0.033 | 0.116 | pass |
| medulla_pct_net_body_weight | 4.753 | 4.657 | 4.71 | +0.043 | 0.192 | pass |
| prosencephalon_pct_brain_weight | 0.871 | 0.856 | 0.86 | +0.011 | 0.045 | pass |
| mesencephalon_pct_brain_weight | 2.440 | 2.396 | 2.40 | +0.040 | 0.124 | pass |
| cerebellum_pct_brain_weight | 0.373 | 0.365 | 0.37 | +0.003 | 0.051 | pass |
| medulla_pct_brain_weight | 0.305 | 0.299 | 0.30 | +0.005 | 0.062 | pass |

Sums:

| check | sum of the printed cells | recomputed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `brain_sum_of_parts_normal` | 6.241 + 0.751 + 1.403 + 0.899 | 9.294 | 9.265 | +0.029 | 0.0025 | **mismatch** |
| `brain_sum_of_parts_dwarf` | 5.898 + 0.756 + 1.331 + 0.864 | 8.849 | 8.849 | +0.000 | 0.0025 | pass |
| `pct_brain_weight_sum_normal` | 67.02 + 8.12 + 15.16 + 9.70 | 100.000 | 100 (reference) | +0.000 | 0.0200 | pass |
| `pct_brain_weight_sum_dwarf` | 66.63 + 8.55 + 15.06 + 9.76 | 100.000 | 100 (reference) | +0.000 | 0.0200 | pass |

Across tables — the two groups pooled against TABLE 2 (all 50 males; TABLE 2's values read as printed from `Latimer_Sawin_1955_TABLE2.csv`):

| check | pooled from | recomputed | printed in TABLE 2 | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_vs_TABLE2_male` | NORMAL n + DWARF n | 50 | 50 | +0 | 0 | pass |
| `pooled_vs_TABLE2_brain_weight_male` | (35 x 9.265 + 15 x 8.849) / 50 | 9.1402 | 9.156 | -0.0158 | 0.0010 | **mismatch** |
| `pooled_vs_TABLE2_prosencephalon_weight_male` | (35 x 6.241 + 15 x 5.898) / 50 | 6.1381 | 6.118 | +0.0201 | 0.0010 | **mismatch** |
| `pooled_vs_TABLE2_mesencephalon_weight_male` | (35 x 0.751 + 15 x 0.756) / 50 | 0.7525 | 0.753 | -0.0005 | 0.0010 | pass |
| `pooled_vs_TABLE2_cerebellum_weight_male` | (35 x 1.403 + 15 x 1.331) / 50 | 1.3814 | 1.381 | +0.0004 | 0.0010 | pass |
| `pooled_vs_TABLE2_medulla_weight_male` | (35 x 0.899 + 15 x 0.864) / 50 | 0.8885 | 0.889 | -0.0005 | 0.0010 | pass |

Informative comparison (no pass criterion) — percentages of net body weight (printed mean of per-animal ratios) against
100 × the printed Average grams / the printed TABLE 1 Panel B Average net body weight of the same group (1650.0 g normal,
1367.9 g dwarf):

| row | group | ratio of the printed means | printed (mean of ratios) | ratio minus printed | relative |
|---|---|---|---|---|---|
| Brain | normal | 0.5615 | 0.571 | -0.0095 | -1.66% |
| Brain | dwarf | 0.6469 | 0.654 | -0.0071 | -1.09% |
| Prosencephalon | normal | 0.3782 | 0.382 | -0.0038 | -0.98% |
| Prosencephalon | dwarf | 0.4312 | 0.436 | -0.0048 | -1.11% |
| Mesencephalon | normal | 0.0455 | 0.0462 | -0.0007 | -1.48% |
| Mesencephalon | dwarf | 0.0553 | 0.0559 | -0.0006 | -1.13% |
| Cerebellum | normal | 0.0850 | 0.0864 | -0.0014 | -1.59% |
| Cerebellum | dwarf | 0.0973 | 0.0987 | -0.0014 | -1.42% |
| Medulla | normal | 0.0545 | 0.0551 | -0.0006 | -1.12% |
| Medulla | dwarf | 0.0632 | 0.0639 | -0.0007 | -1.15% |

The ratio of means is 1.0–1.7% below the printed mean of ratios in all ten cells — the
direction expected when the denominator (net body weight) varies more between animals than the numerator. Nothing here
suggests a misprint.

The 28 Coef. var. checks all pass; the closest to its tolerance is `cv_mesencephalon_pct_net_body_weight_normal` (difference
+0.1022, tolerance 0.1291).

### Observations (the AI assistant's arithmetic, not R checks)

* Standard deviations rebuilt from the two groups (within- plus between-group sums of squares, divisor n − 1) against TABLE 2's male SDs: Brain 0.538 (TABLE 2: 0.537), Prosencephalon **0.403 (0.424)**, Mesencephalon 0.062 (0.060), Cerebellum 0.090 (0.089), Medulla 0.077 (0.076). The prosencephalon is again the one that does not fit (E003).
* Percentages of brain weight against the ratio of the printed gram means: within 0.03 percentage points for seven of the eight cells; the NORMAL prosencephalon is 0.34 off (67.36 against 67.02), and 0.03 off if its mean were 6.212 g.
* The text agrees with the printed Coef. var.: in grams the brain and its parts are "more variable in the dwarf rabbits" (p. 523; here dwarf higher in all five rows), and as percentages of brain weight they are less variable in the dwarfs "With two exceptions" (p. 523; here three of four, the cerebellum, 5.94 against 5.68, being one exception; TABLE 5's mesencephalon is the other). One statement does not fit: "With the exception of the forebrain in the normal males, all are less variable than in the entire group" (p. 523, percentages of net body weight), but the printed NORMAL prosencephalon Coef. var. (13.03) is below TABLE 2's 13.30 like all the others: one more oddity on the E003 row.

## Data role

**primary** — the authors' own dissections and weighings of their own animals, as group summaries.

## Species names

As for TABLES 1 and 2: `species_as_published` = "rabbit (race X)" (the paper's title; the table prints no species); `species` (*Oryctolagus cuniculus*) is read from the species key — `_keys/General/species_key.csv` first, else the proposed row in `reference_tables/Latimer_Sawin_1955_species_key_proposed.csv` (its item list now names TABLES 1, 2 and 4–7). **No `_keys/` file was edited.**

## Registry

Row 996 of `__ReadMe.xlsx` (read 2026-11-07) was added by the owner: column A (the citation, ending with a single `https://doi.org/10.1002/cne.901030307`), D (`TABLE 4`) and M. Its formulas (E–L) resolve Item name `Latimer_Sawin_1955_TABLE4` and Item encoded `10.1002%2Fcne.901030307_TABLE4`, the name under which the public TSV was uploaded; L (Public TSV match) reads `notfound` until `_tools/file_list.R` is run.

* Columns N–AJ of the row still hold the owner's template copy of the TABLE 2 row. Paste N–AJ from `Latimer_Sawin_1955_TABLE4-7_registry_rows.xlsx` (find the row by Item name; HOW_TO_PASTE sheet). Never paste over E–L (formulas).
* `__ReadMe.xlsx` was not edited.

## Paper-level note: TABLES 4, 5 and 7 behind the MacLarnon (1996) and Mink et al. (1981) rabbit rows

* **MacLarnon (1996) Table 1**, race X ("small") rabbit, takes the **NORMAL** groups of this paper: normal males — body
  1972.3 g (TABLE 1 Panel B, gross), cord 3.945 g (TABLE 7), brain 9.265 g (this table); normal females — body 2480.0 g
  (TABLE 1 Panel C, gross), cord 4.537 g (TABLE 7), brain 9.755 g (TABLE 5). These six numbers are the primary values
  behind its rabbit rows.
* **Mink et al. (1981) Table 1, row 24** (rabbit; their reference 61) prints body 2480.0 g, brain 9.755 g and cord 3.945 g:
  the normal-female body and brain weights with the normal-male cord weight. That mix is recorded as erratum
  `Mink_etal_1981-E005` in the Mink et al. folder.
* Flags carried by those primary values here: the normal-male brain 9.265 g sits in the row whose parts do not add up
  (E003, recorded on the NORMAL prosencephalon); the normal-male cord 3.945 g is in E006 (TABLE 7's males pool to 3.936 g
  against TABLE 6's 3.925 g); the normal-male body weight 1972.3 g enters TABLE 1's marginal Panel A gross-weight
  mismatch (0.21 g in 1870.0 g; row note only). The normal-female values (2480.0 g, 9.755 g, 4.537 g) pass every check
  that involves them.
* A cross-source comparison of MacLarnon (1996) and Mink et al. (1981) against these tables is being set up in the
  restricted repository (`Evo-M1-Trait-Data-restricted`, per `REPO_BOUNDARY.md`); there is no comparison folder here.
  Nothing in the MacLarnon or Mink folders was changed by this build.
* Not registered, not built: TABLE 3 (empirical formulae) and TABLE 8 (correlations).

## Human visual check of snapshot

**Pending human RA.** The transcription and the checks above were done by an AI assistant; no person has yet compared the snapshot with the page. Lay `Latimer_Sawin_1955_TABLE4_snapshot.xlsx` beside PDF page 12, read a few rows **across** — including the four-row last block, which has no Brain row, and the footnote — and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column (AJ).

Errata for this item are recorded in `reference_tables/Latimer_Sawin_1955_errata.csv` (E003; E002, on TABLE 2, is referenced by the pooled Brain check). The block below is rendered by
`render_errata(paper_dir)`, which has not been run yet (R not available here).

<!-- errata:begin -->
<!-- errata:end -->
