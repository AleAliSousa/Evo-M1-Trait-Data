# Latimer_Sawin_1955_TABLE6

**Item name** `Latimer_Sawin_1955_TABLE6` · **Item number** `TABLE 6` · **Item encoded** `10.1002%2Fcne.901030307_TABLE6`
(as `__ReadMe.xlsx` resolves it for row 998, read 2026-11-07).

Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and the weight and length of the spinal cord in the rabbit (race X). *Journal of Comparative Neurology*, 103(3), 513–539. <https://doi.org/10.1002/cne.901030307>

**Item full original title:** TABLE 6. *Weights, lengths and percentage weights and lengths of the spinal cord in 50 male and
50 female rabbits* (p. 526, PDF page 14).

> **R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The frozen snapshot, the analysis CSV, the public TSV and every table-check result quoted here were
> produced on 2026-11-07 by a Python mirror of the R scripts in this folder. Run, in this order:
> `Latimer_Sawin_1955_extract_snapshot.R` (it should report all six frozen snapshots as identical), `Latimer_Sawin_1955_TABLE1.R`, then `Latimer_Sawin_1955_TABLE6.R`
> (it reads `Latimer_Sawin_1955_TABLE1.csv` for its cross-table checks); then `render_errata()` on the paper folder.
Run it before `Latimer_Sawin_1955_TABLE7.R`, which reads this CSV.

## Source

PDF in this folder: `Latimer-1955-The weight of the brain, of its p.pdf` (27 pages, pp. 513–539), a 1955 journal scan
(Acrobat Paper Capture OCR over 300-ppi bitonal page images). Every value was read from a 300-dpi render of PDF page 14.
The paper-level note (MacLarnon 1996, Mink et al. 1981) is in `Latimer_Sawin_1955_TABLE4.README.md`.

## Pipeline

```
Source (scanned PDF, page 14)
  -> Latimer_Sawin_1955_extract_snapshot.R       writes the frozen snapshots of TABLES 1, 2, 4, 5, 6 and 7
  -> Latimer_Sawin_1955_TABLE6_snapshot.xlsx     FROZEN: 8 rows x 8 cols, sheet "TABLE6"
  -> Latimer_Sawin_1955_TABLE6.R                 clean + parse + table checks (reads Latimer_Sawin_1955_TABLE1.csv for the informative checks)
  -> Latimer_Sawin_1955_TABLE6.csv               28 rows x 19 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fcne.901030307_TABLE6.tsv
  -> reference_tables/Latimer_Sawin_1955_TABLE6_definitions.csv
  -> reference_tables/Latimer_Sawin_1955_species_key_proposed.csv   (shared by all six items)
  -> reference_tables/Latimer_Sawin_1955_errata.csv                 (E005 belongs to this item; E006, on TABLE 7, involves its male cord weight)
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant on 2026-11-07 from a 300-dpi render of PDF page 14
(`pdftoppm -r 300`), read at 1× and 2× zoom, and at 4× where a reader disagreed, and typed as a verbatim printed-layout block
into `Latimer_Sawin_1955_extract_snapshot.R` (freezes; refuses to overwrite a differing copy). Cross-read cell by cell against the PDF's OCR
text layer (28 numeric cells, **no numeric disagreement**; the labels and headers are garbled instead, below) and against an
independent tesseract OCR of the same render (one disagreement, a tesseract misread: `0.0382` for the printed **0.032**, the
50 FEMALES Stand. dev. of "Cord, % of net B.W.", snapshot F7; read at 4× and consistent with its Coef. var., 100 × 0.032/0.253
= 12.6 against the printed 12.85 within rounding). The build script reads the frozen file and contains no table values.

**R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The mirror parses the printed-layout block out of the R extract script and follows the build script step by step, writing the CSV and the TSV as R's `write.csv` / `write.table` would. No R run has confirmed the outputs yet.

### OCR traps (text layer vs page image)

| where | text layer | page image |
|---|---|---|
| group headers | `5 0 MALES`, `5 0 FEMALES` | 50 MALES, 50 FEMALES |
| column headers | `Bveragr`, `SEd.`, `SEg.`, `VBiT.` | Average, Stand. dev., Coef. var. |
| “t” header | `“t ’` over `YAI.UE` | “t” over VALUE (singular) |
| caption | `W e i g h t s`, `weigkts`, `tlic`, `i i ~`, `fentale` | Weights, weights, the, in, female |

### Structure of the snapshot

* **One snapshot row per printed row**, 8 in all: the table number, the caption (its two printed lines joined), two header
  tiers ("50 MALES" / "50 FEMALES" spanning Average, Stand. dev., Coef. var.; "“t” VALUE" spanning both tiers — singular here,
  plural in TABLES 1, 2, 4, 5 and 7), and four data rows. No block heading, no footnote (TABLE 1's footnote covers tables 1, 2
  and 6).
* **Two row labels are printed on two lines** — "Cord, % of" over "net B.W." and "Cord L., % of" over "B.L." — with the numbers
  level with the second line. Each is one cell holding a newline, on the row of its numbers (wrapped in the .xlsx). The wide
  space in "Cord,  gm" is justification and is written as one space.
* Numbers are kept as printed text, trailing zeros included (`0.470`, `16.0`).

### Structure of the analysis CSV

**Long**: one row per printed numeric cell, 4 printed rows × 7 cells = **28 rows × 19 columns**: `printed_row`,
`snapshot_cell`, `group_label_as_published` ("50 MALES" / "50 FEMALES"), `sex` (male / female; "male vs female" on the t rows),
`group` (all), `n` (50, from the group header, checked against the caption), `n_compared` ("50 vs 50"), `measure`,
`measure_as_published` (the printed label, its two lines joined), `statistic` (mean / sd / cv / t), `statistic_as_published`,
`unit`, `value_printed`, `value`, **`mass.mg`**, `species`, `species_as_published`, `data_role` (primary), `note`. TABLE 2's
columns without its block pair, which this table has no use for, and with the printed row label as `measure_as_published`
(TABLE 1's convention), since the labels name measures, not structures.

| printed label | `measure` | `unit` |
|---|---|---|
| Cord, gm | `cord_weight` | g |
| Cord, mm | `cord_length` | mm |
| Cord, % of net B.W. | `cord_weight_pct_net_body_weight` | % |
| Cord L., % of B.L. | `cord_length_pct_body_length` | % |

* B.W. is the net body weight and B.L. the nose–anus body length: the text (p. 526) calls these "percentages of the net body
  weight and nose-anus length, respectively". The codes are set in the build script's `measure_of` list; a label not in it
  stops the run.
* **Project unit:** cord mass in mg, `mass.mg` = printed grams × 1000, for the Average and Stand. dev. of `cord_weight` (as for
  brain mass); NA elsewhere. Cord length is printed in mm and is not converted.
* **What was measured** (MATERIAL AND METHODS, p. 515): after a complete laminectomy and with the dura slit and folded back, the
  cord was measured in place "from the anterior cut end to the tip of the conus medularis" (sic) with an inelastic string read on
  a steel tape; the anterior cut is where the brain was severed, "at the level of the upper root fila of the first cervical
  nerve". The cord was then removed from the caudal end, "leaving the dura, spinal nerves, severed close to the cord, and all
  large blood vessels", kept in a moist chamber and weighed fresh (analytical balance, 0.1 mg).
* **Observation level: group summaries of all 50 males and all 50 females, normal and dwarf pooled** (15 males and 20 females
  carry the dwarf gene); TABLE 7 gives the two groups separately. Not species means; never merge both tables for the same
  animals.
* The percentages are means of per-animal percentages: not interchangeable with ratios of the printed means.

## Table checks

TABLE 6 prints Coef. var. and t values that can be recomputed from its own cells, and two percentage rows that can be set
against TABLE 1's body measures. `Latimer_Sawin_1955_TABLE6.R` re-runs them into `table_checks` (build HOWTO §7a). The pooling of TABLE 7's
normal and dwarf groups against this table runs in `Latimer_Sawin_1955_TABLE7.R` (it needs this CSV).

| relation | rule and tolerance |
|---|---|
| Coef. var. = 100 × Stand. dev. / Average, every group (8) | worst case of 100 × (SD + ½ unit) / (Average − ½ unit) minus the recomputed value, plus ½ unit of the printed Coef. var. |
| "t" values, males vs females (4) | **pooled-variance Student t** from the printed Averages, SDs and n = 50 + 50; tolerance as for TABLES 1 and 2 |
| The two percentage rows vs the ratio of the printed means: 100 × Average cord weight / TABLE 1 Panel A Average net body weight, and 100 × Average cord length / TABLE 1 Panel A Average nose–anus length (4) | **informative only**: no pass criterion, status `not_evaluable` |

**Result of the Python mirror: 11 pass, 1 mismatch, 4 not evaluable (the 4 informative comparisons), of 16.** (R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.)

| family | checks | pass | mismatch | not evaluable |
|---|---|---|---|---|
| Coef. var. = 100 × SD / Average | 8 | 8 | 0 | 0 |
| “t” (pooled-variance Student t) | 4 | 3 | 1 | 0 |
| informative: % rows vs ratio of means | 4 | 0 | 0 | 4 |

**Mismatch.** The cells were re-read from the page image at 4× zoom; values kept as printed and noted on the row.

| check | snapshot cell(s) | recomputed | printed | difference (recomputed − printed) | tolerance |
|---|---|---|---|---|---|
| `t_cord_length` | H6 | 3.949 | 3.64 | +0.309 | 0.091 |

* `t_cord_length` (H6): from 276.5 mm (SD 13.8) and 288.3 mm (SD 16.0), n = 50 each, Student t is **3.95**
  (3.91 with divisor-n SDs; with equal n the unpooled form gives the same); the page prints **3.64**, 7–8% lower. The
  Averages pool exactly from TABLE 7's groups and both Coef. var. agree with the SDs, so the t is the faulty cell. Recorded as
  errata **Latimer_Sawin_1955-E005** (proposed, `publication_error`); significant at 1% either way. Errata are raised for a t only where the
  printed value is more than 5% from every reading of the formula; smaller misses (TABLE 7's cord-length t, 1–4%) are row notes.

All four t checks:

| row | recomputed t (SDs as divisor n−1) | t with divisor-n SDs | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| cord_weight | 4.276 | 4.233 | 4.23 | +0.046 | 0.064 | pass |
| cord_length | 3.949 | 3.909 | 3.64 | +0.309 | 0.091 | **mismatch** |
| cord_weight_pct_net_body_weight | 0.317 | 0.314 | 0.41 | -0.093 | 0.171 | pass |
| cord_length_pct_body_length | 0.581 | 0.575 | 0.58 | +0.001 | 0.299 | pass |

Informative comparison (no pass criterion) — the percentage rows (printed mean of per-animal ratios) against the ratio of the
printed means, with TABLE 1 Panel A (net body weight 1565.4 g males, 1734.9 g females; nose–anus length 454.6 mm males, 478.3 mm
females):

| row | group | ratio of the printed means | printed (mean of ratios) | ratio minus printed | relative |
|---|---|---|---|---|---|
| Cord, % of net B.W. | male | 0.2507 | 0.255 | -0.0043 | -1.67% |
| Cord, % of net B.W. | female | 0.2474 | 0.253 | -0.0056 | -2.22% |
| Cord L., % of B.L. | male | 60.8227 | 60.9 | -0.0773 | -0.13% |
| Cord L., % of B.L. | female | 60.2760 | 60.7 | -0.4240 | -0.70% |

The weight percentages sit 1.7–2.2% above the ratio of means, as for the brain (TABLE 2), because net body weight varies much
more between animals than cord weight. The length percentages should sit much closer (both lengths vary by about 5%): the males
do (−0.08), the **females do not (-0.42, -0.7%)**. Their denominator is TABLE 1's Panel A female
length, 478.3 mm, the cell of errata **Latimer_Sawin_1955-E001** (it is 2.50 mm above what Panel C's groups pool to). With the pooled 475.80 mm
the difference would be −0.11 (−0.2%), in line with the males and with TABLE 7's groups (all within 0.1%), and the mean of TABLE 7's
female group percentages, (30 × 60.1 + 20 × 61.5)/50 = 60.66, matches this table's 60.7. This points at Panel A's 478.3 as E001's
faulty cell; it is circumstantial (AI-assistant arithmetic, not an R check) and E001 was not edited.

The 8 Coef. var. checks all pass; the closest to its tolerance is `cv_cord_weight_pct_net_body_weight_female` (difference -0.2018,
tolerance 0.2281).

**Across tables (run by TABLE 7).** TABLE 7's normal and dwarf groups pool to this table's cord length (males 276.52 mm, females
288.30 mm) and female cord weight (4.2926 g), but its males pool to **3.936 g against this table's 3.925 g**: errata
**Latimer_Sawin_1955-E006**, recorded on TABLE 7. This table's own Coef. var. (9.78) and t (4.23) and the text (p. 527, "0.25% less than in the
entire group") all follow the printed 3.925.

**The text agrees with the table** (p. 526: the cord weights as percentages of body weight "are 24% more variable in the males and
17% more variable in the females than the corresponding weights in grams"): 12.15/9.78 = 1.24 and 12.85/10.96 = 1.17.

## Data role

**primary** — the authors' own dissections, weighings and measurements of their own 100 animals, as group summaries.

## Species names

As for TABLES 1 and 2: `species_as_published` = "rabbit (race X)" (the paper's title; the table prints no species); `species` (*Oryctolagus cuniculus*) is read from the species key — `_keys/General/species_key.csv` first, else the proposed row in `reference_tables/Latimer_Sawin_1955_species_key_proposed.csv` (its item list now names TABLES 1, 2 and 4–7). **No `_keys/` file was edited.**

## Registry

Row 998 of `__ReadMe.xlsx` (read 2026-11-07) was added by the owner: column A (the citation, ending with a single `https://doi.org/10.1002/cne.901030307`), D (`TABLE 6`) and M. Its formulas (E–L) resolve Item name `Latimer_Sawin_1955_TABLE6` and Item encoded `10.1002%2Fcne.901030307_TABLE6`, the name under which the public TSV was uploaded; L (Public TSV match) reads `notfound` until `_tools/file_list.R` is run.

* Columns N–AJ of the row still hold the owner's template copy of the TABLE 2 row. Paste N–AJ from `Latimer_Sawin_1955_TABLE4-7_registry_rows.xlsx` (find the row by Item name; HOW_TO_PASTE sheet). Never paste over E–L (formulas).
* `__ReadMe.xlsx` was not edited.

## Human visual check of snapshot

**Pending human RA.** The transcription and the checks above were done by an AI assistant; no person has yet compared the snapshot with the page. Lay `Latimer_Sawin_1955_TABLE6_snapshot.xlsx` beside PDF page 14, read a few rows **across** — including the two rows whose labels are printed on two lines — and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column (AJ).

Errata for this item are recorded in `reference_tables/Latimer_Sawin_1955_errata.csv` (E005; E006, on TABLE 7, concerns this table's male cord weight). The block below is rendered by
`render_errata(paper_dir)`, which has not been run yet (R not available here).

<!-- errata:begin -->
<!-- errata:end -->
