# Latimer_Sawin_1955_TABLE7

**Item name** `Latimer_Sawin_1955_TABLE7` · **Item number** `TABLE 7` · **Item encoded** `10.1002%2Fcne.901030307_TABLE7`
(as `__ReadMe.xlsx` resolves it for row 999, read 2026-11-07).

Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and the weight and length of the spinal cord in the rabbit (race X). *Journal of Comparative Neurology*, 103(3), 513–539. <https://doi.org/10.1002/cne.901030307>

**Item full original title:** TABLE 7. *Weights, lengths and percentage weights and lengths of the spinal cord in the normal and
dwarf rabbits* (p. 527, PDF page 15).

> **R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The frozen snapshot, the analysis CSV, the public TSV and every table-check result quoted here were
> produced on 2026-11-07 by a Python mirror of the R scripts in this folder. Run, in this order:
> `Latimer_Sawin_1955_extract_snapshot.R` (it should report all six frozen snapshots as identical), `Latimer_Sawin_1955_TABLE1.R`, `Latimer_Sawin_1955_TABLE6.R`, then `Latimer_Sawin_1955_TABLE7.R`
> (it reads `Latimer_Sawin_1955_TABLE1.csv` and `Latimer_Sawin_1955_TABLE6.csv` for its cross-table checks); then `render_errata()` on the paper folder.

## Source

PDF in this folder: `Latimer-1955-The weight of the brain, of its p.pdf` (27 pages, pp. 513–539), a 1955 journal scan
(Acrobat Paper Capture OCR over 300-ppi bitonal page images). Every value was read from a 300-dpi render of PDF page 15.
TABLE 7's normal groups are the primary source of the MacLarnon (1996) cord weights and of Mink et al. (1981)'s rabbit cord
weight: see the paper-level note in `Latimer_Sawin_1955_TABLE4.README.md`.

## Pipeline

```
Source (scanned PDF, page 15)
  -> Latimer_Sawin_1955_extract_snapshot.R       writes the frozen snapshots of TABLES 1, 2, 4, 5, 6 and 7
  -> Latimer_Sawin_1955_TABLE7_snapshot.xlsx     FROZEN: 14 rows x 8 cols, sheet "TABLE7"
  -> Latimer_Sawin_1955_TABLE7.R                 clean + parse + table checks (reads Latimer_Sawin_1955_TABLE1.csv and _TABLE6.csv)
  -> Latimer_Sawin_1955_TABLE7.csv               56 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fcne.901030307_TABLE7.tsv
  -> reference_tables/Latimer_Sawin_1955_TABLE7_definitions.csv
  -> reference_tables/Latimer_Sawin_1955_species_key_proposed.csv   (shared by all six items)
  -> reference_tables/Latimer_Sawin_1955_errata.csv                 (E006 belongs to this item)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant on 2026-11-07 from a 300-dpi render of PDF page 15
(`pdftoppm -r 300`), read at 1× and 2× zoom, and at 4× for the cell the text layer reads differently, and typed as a verbatim
printed-layout block into `Latimer_Sawin_1955_extract_snapshot.R` (freezes; refuses to overwrite a differing copy). Cross-read cell by cell
against the PDF's OCR text layer (56 numeric cells, **one disagreement**, a text-layer error, below) and against an independent
tesseract OCR of the same render (56 cells, no disagreement). The build script reads the frozen file and contains no table values.

**R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The mirror parses the printed-layout block out of the R extract script and follows the build script step by step, writing the CSV and the TSV as R's `write.csv` / `write.table` would. No R run has confirmed the outputs yet.

### OCR traps (text layer vs page image)

| where | text layer | page image |
|---|---|---|
| block "30 normal and 20 dwarf females", Cord L., % of B.L., DWARF Stand. dev. (snapshot F14) | `1.61` | **1.64** (read at 4×; 100 × 1.64/61.5 = 2.67 against the printed Coef. var. 2.68; 1.61 would give 2.62) |
| male block, fourth row label (A9) | `Cord r,., % of` | Cord L., % of |
| column header | `par.` | var. |
| “t” header | `,y,` | “t” |
| caption | `R e i g h t s`, `perceniage`, `Yyinal`, `i n` | Weights, percentage, spinal, in |

### Structure of the snapshot

* **One snapshot row per printed row**, 14 in all: the table number, the caption (its two printed lines joined), two header
  tiers ("NORMAL" / "DWARF" spanning Average, Stand. dev., Coef. var.; "“t” VALUES" spanning both tiers), then two blocks, each
  under its printed heading — "35 normal and 15 dwarf males" and "30 normal and 20 dwarf females" — of four data rows. The
  column headers are printed once, above the first block. No footnote of its own (TABLE 4's covers tables 4, 5 and 7).
* **Row labels printed on two lines** ("Cord, % of" over "net B.W."; "Cord L., % of" over "B.L.") are one cell holding a newline,
  on the row of their numbers. The female block breaks one of them differently — "Cord, % of net" over "B.W." — and is kept so.
  The wide spaces in "Cord,  gm" and "net  B.W." are justification and are written as one space.
* Numbers are kept as printed text, trailing zeros included (`267.0`, `13.0`), and with the printed number of decimals: the
  30 normal females' cord-weight Stand. dev. prints **`0.38`** — two decimals where the rest of the column prints three. Kept
  (its checks use a correspondingly wider rounding allowance).

### Structure of the analysis CSV

**Long**: one row per printed numeric cell, 8 printed rows × 7 cells = **56 rows × 21 columns**: `printed_row`,
`snapshot_cell`, `block` (males / females), `block_as_published` (the printed block heading), `group_label_as_published` (NORMAL /
DWARF), `sex`, `group` (normal / dwarf; "normal vs dwarf" on the t rows), `n` (35 / 15 males, 30 / 20 females, from the block
headings), `n_compared`, `measure`, `measure_as_published` (the printed label, its two lines joined), `statistic` (mean / sd / cv
/ t), `statistic_as_published`, `unit`, `value_printed`, `value`, **`mass.mg`**, `species`, `species_as_published`, `data_role`
(primary), `note`.

* Measure codes and units as in TABLE 6: `cord_weight` (Cord, gm; g), `cord_length` (Cord, mm; mm),
  `cord_weight_pct_net_body_weight` (Cord, % of net B.W.; %), `cord_length_pct_body_length` (Cord L., % of B.L.; %).
* **Project unit:** cord mass in mg, `mass.mg` = printed grams × 1000, for the Average and Stand. dev. of `cord_weight`; cord
  length in mm as printed.
* **What was measured:** as for TABLE 6 (MATERIAL AND METHODS, p. 515; see `Latimer_Sawin_1955_TABLE6.README.md`).
* **Observation level: group summaries of the normal and dwarf animals of each sex, not species means.** Dwarf = heterozygous
  for the dwarf gene, normal = homozygous non-dwarf (p. 516). All 50 of each sex are in TABLE 6: pool explicitly (n-weighted)
  or use TABLE 6, and never merge both.
* The percentages are means of per-animal percentages: not interchangeable with ratios of the printed means.

## Table checks

TABLE 7 prints Coef. var. and t values that can be recomputed from its own cells, and its normal and dwarf groups together are
the animals of TABLE 6. `Latimer_Sawin_1955_TABLE7.R` re-runs these into `table_checks` (build HOWTO §7a); nothing is changed to make a check pass.

| relation | rule and tolerance |
|---|---|
| Coef. var. = 100 × Stand. dev. / Average, every group (16) | worst case of 100 × (SD + ½ unit) / (Average − ½ unit) minus the recomputed value, plus ½ unit of the printed Coef. var. |
| "t" values, NORMAL vs DWARF within each sex (8) | **pooled-variance Student t** from the printed Averages, SDs and n (35 + 15, 30 + 20); tolerance as for TABLES 1 and 2 |
| Across tables: NORMAL n + DWARF n (block heading) = TABLE 6 n, each sex (2) | exact |
| Across tables: NORMAL and DWARF Averages pooled (n-weighted) = TABLE 6 Average, cord weight and cord length, each sex (4) | ½ unit of each group Average, n-weighted, plus ½ unit of the TABLE 6 Average (0.001 g; 0.1 mm) |
| The two percentage rows vs the ratio of the printed means, with TABLE 1 Panels B and C (net body weight; nose–anus length) of the same group (8) | **informative only**: no pass criterion, status `not_evaluable` |

**Result of the Python mirror: 27 pass, 3 mismatch, 8 not evaluable (the 8 informative comparisons), of 38.** (R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.)

| family | checks | pass | mismatch | not evaluable |
|---|---|---|---|---|
| Coef. var. = 100 × SD / Average | 16 | 16 | 0 | 0 |
| “t” (pooled-variance Student t) | 8 | 6 | 2 | 0 |
| n against TABLE 6 | 2 | 2 | 0 | 0 |
| NORMAL + DWARF pooled against TABLE 6 | 4 | 3 | 1 | 0 |
| informative: % rows vs ratio of means | 8 | 0 | 0 | 8 |

**Mismatches.** Every cell involved was re-read from the page image at 4× zoom; the printed values are kept in the snapshot, the
CSV and the TSV, and each mismatch is written into the `note` of the row(s) it concerns.

| check | snapshot cell(s) | recomputed | printed | difference (recomputed − printed) | tolerance |
|---|---|---|---|---|---|
| `t_cord_length_male` | H7 | 3.563 | 3.62 | -0.057 | 0.046 |
| `t_cord_length_female` | H12 | 8.217 | 8.38 | -0.163 | 0.075 |
| `pooled_vs_TABLE6_cord_weight_male` | B6, E6 | 3.9360 | TABLE 6: 3.925 | +0.0110 | 0.0010 |

* `pooled_vs_TABLE6_cord_weight_male` (B6, E6): the 35 normal (3.945 g) and 15 dwarf (3.915 g) males pool to **3.936 g**
  against TABLE 6's all-male **3.925 g** (+0.011 g; rounding allows 0.001 g). The male cord length and both
  female rows pool exactly. Every cell's own statistics follow its printed value — TABLE 6's Coef. var. and t, and the text's
  "0.25% less than in the entire group" (p. 527), follow 3.925; this table's NORMAL Coef. var. (9.26) and t (0.24) follow 3.945 —
  and the SD rebuilt from the two groups (0.384 g) equals TABLE 6's whichever mean is used. The faulty cell cannot be identified:
  errata **Latimer_Sawin_1955-E006** (proposed, `publication_ambiguity`), recorded here because **3.945 g is the normal-male cord weight that
  MacLarnon (1996) and Mink et al. (1981) copy**.
* `t_cord_length_male` and `t_cord_length_female`: printed 3.62 and 8.38 against 3.56 and 8.22
  recomputed (3.49 and 8.04 with divisor-n SDs) — 1–4% off, beyond rounding. Row notes only (errata are raised for a t
  only beyond 5%, as for TABLE 6's cord-length t, E005); significant at 1% either way. TABLE 1's Panel C length t misses in
  the same way.

All eight t checks:

| check | recomputed t (SDs as divisor n−1) | t with divisor-n SDs | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| cord_weight_male | 0.251 | 0.245 | 0.24 | +0.011 | 0.019 | pass |
| cord_length_male | 3.563 | 3.489 | 3.62 | -0.057 | 0.046 | **mismatch** |
| cord_weight_pct_net_body_weight_male | 6.831 | 6.690 | 6.70 | +0.131 | 0.431 | pass |
| cord_length_pct_body_length_male | 2.181 | 2.132 | 2.16 | +0.021 | 0.254 | pass |
| cord_weight_female | 5.692 | 5.579 | 5.72 | -0.028 | 0.065 | pass |
| cord_length_female | 8.217 | 8.042 | 8.38 | -0.163 | 0.075 | **mismatch** |
| cord_weight_pct_net_body_weight_female | 7.441 | 7.288 | 7.40 | +0.041 | 0.460 | pass |
| cord_length_pct_body_length_female | 2.979 | 2.919 | 2.94 | +0.039 | 0.282 | pass |

Across tables — the two groups pooled against TABLE 6 (all 50 of each sex; TABLE 6's values read as printed from
`Latimer_Sawin_1955_TABLE6.csv`):

| check | pooled from | recomputed | printed in TABLE 6 | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_vs_TABLE6_male` | NORMAL n + DWARF n | 50 | 50 | +0 | 0 | pass |
| `n_vs_TABLE6_female` | NORMAL n + DWARF n | 50 | 50 | +0 | 0 | pass |
| `pooled_vs_TABLE6_cord_weight_male` | (35 x 3.945 + 15 x 3.915) / 50 | 3.9360 | 3.925 | +0.0110 | 0.0010 | **mismatch** |
| `pooled_vs_TABLE6_cord_length_male` | (35 x 280.6 + 15 x 267.0) / 50 | 276.52 | 276.5 | +0.02 | 0.10 | pass |
| `pooled_vs_TABLE6_cord_weight_female` | (30 x 4.537 + 20 x 3.926) / 50 | 4.2926 | 4.292 | +0.0006 | 0.0010 | pass |
| `pooled_vs_TABLE6_cord_length_female` | (30 x 298.5 + 20 x 273.0) / 50 | 288.30 | 288.3 | +0.00 | 0.10 | pass |

Informative comparison (no pass criterion) — the percentage rows against the ratio of the printed means, with TABLE 1 Panel B
(males: net body weight 1650.0 g normal, 1367.9 g dwarf; nose–anus length 463.7 mm, 433.6 mm) and Panel C (females: 1959.3 g,
1398.4 g; 496.8 mm, 444.3 mm):

| row | group | ratio of the printed means | printed (mean of ratios) | ratio minus printed | relative |
|---|---|---|---|---|---|
| Cord, % of net B.W. | male normal | 0.2391 | 0.241 | -0.0019 | -0.79% |
| Cord, % of net B.W. | male dwarf | 0.2862 | 0.288 | -0.0018 | -0.62% |
| Cord L., % of B.L. | male normal | 60.5133 | 60.5 | +0.0133 | +0.02% |
| Cord L., % of B.L. | male dwarf | 61.5775 | 61.6 | -0.0225 | -0.04% |
| Cord, % of net B.W. | female normal | 0.2316 | 0.233 | -0.0014 | -0.62% |
| Cord, % of net B.W. | female dwarf | 0.2807 | 0.282 | -0.0013 | -0.44% |
| Cord L., % of B.L. | female normal | 60.0845 | 60.1 | -0.0155 | -0.03% |
| Cord L., % of B.L. | female dwarf | 61.4450 | 61.5 | -0.0550 | -0.09% |

Within each group the length percentages sit within 0.1 of the ratio of means and the weight percentages 0.4–0.8% above it,
as expected for groups less heterogeneous than the whole sex. Nothing here suggests a misprint.

The 16 Coef. var. checks all pass (including the two-decimal `0.38`); the closest to its tolerance is
`cv_cord_weight_pct_net_body_weight_female_normal` (difference +0.2321, tolerance 0.2404).

### Observations (the AI assistant's arithmetic, not R checks)

* Standard deviations rebuilt from the two groups against TABLE 6: male cord weight 0.384 g (TABLE 6: 0.384), male cord length
  13.8 mm (13.8), female cord weight 0.476 g (0.470), **female cord length 16.5 mm (16.0)**. The last does not fit; it bears on
  TABLE 6's female cord-length row, whose t is E005 (even 16.5 mm would not give the printed t).
* The text (p. 527) agrees with TABLES 6 and 7: dwarf males' cord 0.25% lighter than the entire group (3.915 against 3.925 g),
  dwarf females' 8.5% (3.926 against 4.292 g); cord length 3.4% shorter in dwarf males (267.0 against 276.5 mm) and 5.3% in
  dwarf females (273.0 against 288.3 mm).

## Data role

**primary** — the authors' own dissections, weighings and measurements of their own animals, as group summaries.

## Species names

As for TABLES 1 and 2: `species_as_published` = "rabbit (race X)" (the paper's title; the table prints no species); `species` (*Oryctolagus cuniculus*) is read from the species key — `_keys/General/species_key.csv` first, else the proposed row in `reference_tables/Latimer_Sawin_1955_species_key_proposed.csv` (its item list now names TABLES 1, 2 and 4–7). **No `_keys/` file was edited.**

## Registry

Row 999 of `__ReadMe.xlsx` (read 2026-11-07) was added by the owner: column A (the citation, ending with a single `https://doi.org/10.1002/cne.901030307`), D (`TABLE 7`) and M. Its formulas (E–L) resolve Item name `Latimer_Sawin_1955_TABLE7` and Item encoded `10.1002%2Fcne.901030307_TABLE7`, the name under which the public TSV was uploaded; L (Public TSV match) reads `notfound` until `_tools/file_list.R` is run.

* Columns N–AJ of the row still hold the owner's template copy of the TABLE 2 row. Paste N–AJ from `Latimer_Sawin_1955_TABLE4-7_registry_rows.xlsx` (find the row by Item name; HOW_TO_PASTE sheet). Never paste over E–L (formulas).
* `__ReadMe.xlsx` was not edited.

## Human visual check of snapshot

**Pending human RA.** The transcription and the checks above were done by an AI assistant; no person has yet compared the snapshot with the page. Lay `Latimer_Sawin_1955_TABLE7_snapshot.xlsx` beside PDF page 15, read a few rows **across** — including both blocks and the rows whose labels are printed on two lines — and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column (AJ).

Errata for this item are recorded in `reference_tables/Latimer_Sawin_1955_errata.csv` (E006). The block below is rendered by
`render_errata(paper_dir)`, which has not been run yet (R not available here).

<!-- errata:begin -->
<!-- errata:end -->
