# Latimer_Sawin_1955_TABLE1

**Item name** `Latimer_Sawin_1955_TABLE1` · **Item number** `TABLE 1` · **Item encoded** `10.1002%2Fcne.901030307_TABLE1` —
*the value the registry will resolve once column A of its row is fixed; today it resolves a broken code (see Registry).*

Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and the weight and length of the spinal cord in the rabbit (race X). *Journal of Comparative Neurology*, 103(3), 513–539. <https://doi.org/10.1002/cne.901030307>

**Item full original title:** TABLE 1. *Weight and length of the body for the entire group of 50 males and 50 females in
panel A. Panels B and C show similar data for the normal and dwarf males and females* (p. 517, PDF page 5).

> **R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The frozen snapshot, the analysis CSV, the public TSV and every table-check result quoted here were
> produced on 2026-11-06 by a Python mirror of the R scripts in this folder. Run, in this order:
> `Latimer_Sawin_1955_extract_snapshot.R` (it should report both frozen snapshots as identical), `Latimer_Sawin_1955_TABLE1.R`,
> `Latimer_Sawin_1955_TABLE2.R` — after fixing column A of the registry rows, or the two build scripts stop before the TSV.
> *Update 2026-11-07:* column A of both rows has been fixed by the owner, and the extract script now freezes six snapshots
> (TABLES 1, 2, 4, 5, 6, 7) and should report all six as identical; TABLES 4–7 have their own build scripts and READMEs.

## Source

PDF in this folder: `Latimer-1955-The weight of the brain, of its p.pdf` (27 pages, pp. 513–539). A 1955 journal scan:
Acrobat Paper Capture OCR laid over 300-ppi bitonal page images. The OCR text layer is unreliable (see *OCR traps*),
so every value was read from the page images.

## Pipeline

```
Source (scanned PDF, page 5)
  -> Latimer_Sawin_1955_extract_snapshot.R       writes the frozen snapshots of TABLES 1, 2, 4, 5, 6 and 7
  -> Latimer_Sawin_1955_TABLE1_snapshot.xlsx     FROZEN: 21 rows x 8 cols, sheet "TABLE1"
  -> Latimer_Sawin_1955_TABLE1.R                 clean + parse + table checks
  -> Latimer_Sawin_1955_TABLE1.csv               63 rows x 20 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fcne.901030307_TABLE1.tsv
  -> reference_tables/Latimer_Sawin_1955_TABLE1_definitions.csv
  -> reference_tables/Latimer_Sawin_1955_species_key_proposed.csv   (proposed _keys row, shared with TABLE 2)
  -> reference_tables/Latimer_Sawin_1955_errata.csv                 (E001 belongs to this item)
```

Build order: `Latimer_Sawin_1955_TABLE1.R` before `Latimer_Sawin_1955_TABLE2.R` (TABLE 2's informative check reads this CSV).

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant on 2026-11-06 from the PDF's own 300-ppi image of page 5
(extracted with `pdfimages`, no resampling), read at 1×, 2× and 4× zoom and typed as a verbatim printed-layout block into
`Latimer_Sawin_1955_extract_snapshot.R`, which freezes it to the .xlsx and refuses to overwrite a differing copy. The block was then
cross-read cell by cell against the OCR text layer: 63 numeric cells, **one disagreement**, resolved from the image (below).
The build script reads the frozen file and contains no table values.

**R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.** The mirror parses the printed-layout block out of the R extract script, so the two cannot drift apart, follows
the build script step by step and writes the CSV and the TSV as R's `write.csv` / `write.table` would. No R run has
confirmed the outputs yet.

### OCR traps (text layer vs page image)

| where | text layer | page image |
|---|---|---|
| Panel B, 15 DWARF, Body length nose–anus, Coef. var. (snapshot G14) | `2.47` | **4.47** (100 × 19.4/433.6 = 4.47) |
| Panel A group header | `5 0 XALES` | 50 MALES |
| Panel A, second row label | `Cody weight, net` | Body weight, net |
| Panel C group header | `30 I O R X A L` | 30 NORMAL |
| caption and footnote | `t h e`, `Paiiels`, `valnes` | the, Panels, values |
| row labels | `nose-anus` (hyphen) | nose–anus (en dash; the running text prints a hyphen) |

Seen in passing elsewhere in the paper (not an exhaustive check; relevant when those tables are built): the text layer
reads TABLE 4's 35-normal-male Brain as `9.205` where the page prints 9.265, and TABLE 7's dwarf-female cord length as %
of body length, Stand. dev., as `1.61` where the page prints 1.64. Both were confirmed from the page images when TABLES 4–7
were built on 2026-11-07; their READMEs list every OCR trap of pages 12–15.

### Structure of the snapshot

* **One snapshot row per printed row**, 21 in all: the table number; the caption (its printed line breaks joined with a
  space); for each panel its title (Panels B and C also a subtitle), its group-header row(s) and its three data rows; and
  the printed footnote last. The table prints no blank rows.
* Columns as printed: row label | first group (Average, Stand. dev., Coef. var.) | second group (the same) | "t" VALUES.
  A spanning group header sits in the first column of its span with blank padding; "“t” VALUES" spans both header tiers
  and sits in the upper one. A header printed on two lines is one cell holding a newline.
* **Panels B and C print only their group labels** ("35 NORMAL", "15 DWARF"; "30 NORMAL", "20 DWARF"): no statistic
  header and no "t" header. Reproduced as printed, not repaired.
* Small capitals are written as capitals; the typographic quotes around t are kept (“t”); numbers are kept as printed
  text, trailing zeros included (`1870.0`).

### Structure of the analysis CSV

**Long**: one row per printed numeric cell, 9 printed rows × 7 cells = **63 rows × 20 columns**, read along
each printed row. `printed_row` and `snapshot_cell` point back to the snapshot; `panel`, `panel_as_published` and
`group_label_as_published` carry the printed headings; `sex`, `group` (all / normal / dwarf) and `n` come from the printed
group headers (on the t rows `sex` is "male vs female" or `group` "normal vs dwarf", `n` is NA and `n_compared` reads
"50 vs 50", "35 vs 15" or "30 vs 20"); `measure` (`body_weight_gross`, `body_weight_net`, `body_length_nose_anus`) with
`measure_as_published`; `statistic` (mean / sd / cv / t) with `statistic_as_published`; `unit`; `value_printed` (verbatim)
and `value`; `species` (*Oryctolagus cuniculus*, from the species key), `species_as_published` ("rabbit (race X)"),
`data_role` (primary) and `note`.

* **Units are not printed.** Body weight is in grams and length in millimetres (MATERIAL AND METHODS, p. 516: data
  "grouped in 200 gm or 20 mm intervals"). Grams are the project unit for body mass, so nothing is converted.
* **Gross vs net body weight** (p. 516): gross = the live animal before anaesthetisation; net = gross minus the contents
  of the digestive tube and all dissectable fat. Gross is the body mass; net is the denominator of TABLE 2's percentages.
* **Observation level: group summaries, not species means.** 15 of the 50 males and 20 of the 50 females carry the dwarf
  gene (heterozygotes; the gene is lethal when homozygous). Panel A is the whole sample; Panels B and C split it. Choose
  or pool groups explicitly before any species-level use.

## Table checks

TABLE 1 prints no totals, but it prints four kinds of relation that can be recomputed from its own cells.
`Latimer_Sawin_1955_TABLE1.R` re-runs all of them into `table_checks` (build HOWTO §7a). Comparisons are in the printed units; a
tolerance is only what rounding of the printed cells can explain (and, for t, the stated formula allowance); nothing is
changed to make a check pass.

| relation | rule and tolerance |
|---|---|
| Coef. var. = 100 × Stand. dev. / Average, every group (18) | worst case of 100 × (SD + ½ unit) / (Average − ½ unit) minus the recomputed value, plus ½ unit of the printed Coef. var. |
| "t" values (9) | **pooled-variance Student t**: t = \|A₁ − A₂\| / √{[(n₁ − 1)s₁² + (n₂ − 1)s₂²] / (n₁ + n₂ − 2) × (1/n₁ + 1/n₂)}, the printed SDs taken as divisor-(n − 1) SDs. Tolerance: rounding of the four printed inputs (worst case) plus ½ unit of the printed t; and, only where the printed t is below the recomputed one, down to the t obtained if the SDs were computed with divisor n — the paper does not state its formula ("the usual statistical constants", p. 516). |
| Panel A n = normal n + dwarf n (2) | exact |
| Panel A Average = n-weighted mean of the Panel B (males) or Panel C (females) normal and dwarf Averages (6) | ½ unit of each subgroup Average, n-weighted, plus ½ unit of the Panel A Average (= 0.10) |

**Result of the Python mirror: 32 pass, 3 mismatch, 0 not evaluable, of 35 checks.** (R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.)

| family | checks | pass | mismatch | not evaluable |
|---|---|---|---|---|
| Coef. var. = 100 × SD / Average | 18 | 18 | 0 | 0 |
| “t” (pooled-variance Student t) | 9 | 8 | 1 | 0 |
| Panel A n = normal n + dwarf n | 2 | 2 | 0 | 0 |
| Panel A Average = n-weighted Panels B/C | 6 | 4 | 2 | 0 |

**Mismatches.** Every cell involved was re-read from the page image; the printed values are kept in the snapshot, the CSV
and the TSV, and each mismatch is written into the `note` of the row it concerns.

| check | snapshot cell | recomputed | printed | difference (recomputed − printed) | tolerance |
|---|---|---|---|---|---|
| `t_C_body_length_nose_anus` | H20 | 10.084 | 10.20 | -0.116 | 0.052 |
| `pooled_mean_A_vs_B_body_weight_gross_male` | B6 | 1869.79 | 1870.0 | -0.21 | 0.10 |
| `pooled_mean_A_vs_C_body_length_nose_anus_female` | E8 | 475.80 | 478.3 | -2.50 | 0.10 |

* `pooled_mean_A_vs_C_body_length_nose_anus_female` is the substantive one: Panel A's female nose–anus length (478.3 mm)
  is 2.50 mm above the n-weighted mean of Panel C, (30 × 496.8 + 20 × 444.3)/50 = 475.80 mm. Recorded as errata
  **Latimer_Sawin_1955-E001** (proposed, `publication_ambiguity`): the paper does not let us tell whether the Panel A row or a Panel C
  cell is wrong. Panel C's own length t (printed 10.20, the first mismatch above) does not fit its Averages and SDs either, and Panel A's SD for this row (33.7) is
  larger than the SD reconstructed from Panel C's two groups (about 31.5; computed by the AI assistant, not an R check).
* The male gross body weight mismatch is marginal (0.21 g in 1870 g, about twice the rounding allowance); it is noted on
  the row only, with no erratum.

All nine t checks (printed t vs the stated formula):

| Panel, row (groups compared) | recomputed t (SDs as divisor n−1) | t with divisor-n SDs | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| A, body_weight_gross (male all n = 50 vs female all n = 50) | 4.152 | 4.110 | 4.11 | +0.042 | 0.049 | pass |
| A, body_weight_net (male all n = 50 vs female all n = 50) | 2.877 | 2.848 | 2.86 | +0.017 | 0.036 | pass |
| A, body_length_nose_anus (male all n = 50 vs female all n = 50) | 4.045 | 4.004 | 4.00 | +0.045 | 0.069 | pass |
| B, body_weight_gross (male normal n = 35 vs male dwarf n = 15) | 4.207 | 4.127 | 4.20 | +0.007 | 0.087 | pass |
| B, body_weight_net (male normal n = 35 vs male dwarf n = 15) | 4.364 | 4.279 | 4.32 | +0.044 | 0.093 | pass |
| B, body_length_nose_anus (male normal n = 35 vs male dwarf n = 15) | 4.781 | 4.687 | 4.76 | +0.021 | 0.126 | pass |
| C, body_weight_gross (female normal n = 30 vs female dwarf n = 20) | 8.237 | 8.084 | 8.24 | -0.003 | 0.007 | pass |
| C, body_weight_net (female normal n = 30 vs female dwarf n = 20) | 9.732 | 9.553 | 9.73 | +0.002 | 0.189 | pass |
| C, body_length_nose_anus (female normal n = 30 vs female dwarf n = 20) | 10.084 | 9.871 | 10.20 | -0.116 | 0.052 | **mismatch** |

All six Panel A vs Panels B/C Average checks:

| check | pooled from | recomputed | printed Panel A | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `pooled_mean_A_vs_B_body_weight_gross_male` | (35 x 1972.3 + 15 x 1630.6) / 50 | 1869.79 | 1870.0 | -0.21 | 0.10 | **mismatch** |
| `pooled_mean_A_vs_C_body_weight_gross_female` | (30 x 2480.0 + 20 x 1762.1) / 50 | 2192.84 | 2192.9 | -0.06 | 0.10 | pass |
| `pooled_mean_A_vs_B_body_weight_net_male` | (35 x 1650.0 + 15 x 1367.9) / 50 | 1565.37 | 1565.4 | -0.03 | 0.10 | pass |
| `pooled_mean_A_vs_C_body_weight_net_female` | (30 x 1959.3 + 20 x 1398.4) / 50 | 1734.94 | 1734.9 | +0.04 | 0.10 | pass |
| `pooled_mean_A_vs_B_body_length_nose_anus_male` | (35 x 463.7 + 15 x 433.6) / 50 | 454.67 | 454.6 | +0.07 | 0.10 | pass |
| `pooled_mean_A_vs_C_body_length_nose_anus_female` | (30 x 496.8 + 20 x 444.3) / 50 | 475.80 | 478.3 | -2.50 | 0.10 | **mismatch** |

The 18 Coef. var. checks all pass; the largest difference is +0.0110 (Panel C, body_length_nose_anus, female, normal; row 20), within its
tolerance of 0.0154. Both n checks pass (35 + 15 = 50 males; 30 + 20 = 50 females).

## Data role

**primary** — the authors' own measurements of their own 100 animals, as group summaries.

## Species names

The table prints no species; `species_as_published` carries the paper's own wording from the title, "rabbit (race X)".
MATERIAL AND METHODS: 50 male and 50 female rabbits of inbred race X, descended from Castle's small size race, from the
Roscoe B. Jackson Memorial Laboratory, Bar Harbor. `species` (*Oryctolagus cuniculus*) is read from the species key, never
from an inline map: the build reads `_keys/General/species_key.csv` first and falls back to
`reference_tables/Latimer_Sawin_1955_species_key_proposed.csv` (one proposed row, the 7-column `_keys/General/species_key.csv` schema,
NCBI taxid 9986). **No `_keys/` file was edited**; adopting the row changes nothing in the output.

## Registry

**Update 2026-11-07:** the owner has fixed column A of both rows: read on 2026-11-07 they resolve Item encoded
`10.1002%2Fcne.901030307_TABLE1` and `_TABLE2`, the names of the public TSVs, and N–AJ hold the pasted values. The rest of
this section records the state on 2026-11-06.

Rows 994 (TABLE 1) and 995 (TABLE 2) of `__ReadMe.xlsx` were added by the owner. Their column A ends
`https://doi.org/https://doi.org/10.1002/cne.901030307 ` — a duplicated prefix and a trailing space — so the registry
formulas resolve DOI (or Alt) to `https%3A%2F%2Fdoi.org%2F10.1002%2Fcne.901030307 ` and **Item encoded** to
`https%3A%2F%2Fdoi.org%2F10.1002%2Fcne.901030307 _TABLE1`.

* **Fix:** make column A end `https://doi.org/10.1002/cne.901030307`, with nothing after it (the corrected citation is in
  column A of `Latimer_Sawin_1955_registry_rows.xlsx`). Item encoded then becomes **`10.1002%2Fcne.901030307_TABLE1`** — the name under
  which the public TSV has already been written to `__Public/comparative-data/`.
* Until then `Latimer_Sawin_1955_TABLE1.R` writes the analysis CSV and then **stops**, with a message naming the fix, rather than write
  a misnamed TSV: it refuses any Item encoded that contains whitespace or "https" (the `Munger_etal_2022` guard).
* `__ReadMe.xlsx` was not edited. Paste-ready values for columns A, D and N–AJ of both rows, with a HOW_TO_PASTE sheet,
  are in `Latimer_Sawin_1955_registry_rows.xlsx`.
* Column M of row 994 is truncated after "in panel A."; the printed caption continues "Panels B and C show similar data
  for the normal and dwarf males and females".

## Other tables of this paper

* **Update 2026-11-07:** TABLES 4, 5, 6 and 7 were registered by the owner (registry rows 996–999) and built
  (`Latimer_Sawin_1955_TABLE4` … `_TABLE7`). The paper-level note on MacLarnon (1996) and Mink et al. (1981) is now kept in
  `Latimer_Sawin_1955_TABLE4.README.md`, with the new flags on those values (E003 on the normal-male brain row, E006 on the
  normal-male cord weight). TABLE 3 and TABLE 8 remain unregistered. The bullets below are the text of 2026-11-06.
* **TABLES 4 and 5** (pp. 524–525) give the weights of the brain and of its parts, in grams and as percentages, for the
  35 normal vs 15 dwarf males and the 30 normal vs 20 dwarf females; **TABLE 7** (p. 527) gives the spinal-cord weights
  and lengths (also as percentages of net body weight and of body length) for the same normal and dwarf groups. TABLE 3
  (empirical formulae), TABLE 6 (spinal cord, all 50 + 50) and TABLE 8 (correlations) are not registered either.
* TABLES 4, 5 and 7 are the **primary source of the rabbit rows of MacLarnon (1996) Table 1 and of Mink et al. (1981)
  Table 1**. MacLarnon's "small" race rows (male 1,972 g body, 3,945 mg cord, 9,265 mg brain; female 2,480 g, 4,537 mg,
  9,755 mg) are the NORMAL groups: gross body weight from this table (Panel B 1972.3 g, Panel C 2480.0 g), cord weight
  from TABLE 7 (3.945 g, 4.537 g) and brain weight from TABLES 4 and 5 (9.265 g, 9.755 g). Mink et al.'s rabbit row
  (2,480.0 g body, 9.755 g brain, 3.945 g cord; their reference 61) combines the normal-female body and brain weights with
  the normal-male cord weight. Those two items are being flagged separately; nothing in them was changed here.

## Human visual check of snapshot

**Pending human RA.** The transcription and the checks above were done by an AI assistant; no person has yet compared the
snapshot with the page. Lay `Latimer_Sawin_1955_TABLE1_snapshot.xlsx` beside PDF page 5, read a few rows **across** — including the
Panel B and C rows under their short headers — and record `DDMMYYYY_initials` in the `Human visual check of snapshot`
column (AJ).

Errata for this item are recorded in `reference_tables/Latimer_Sawin_1955_errata.csv` (E001). The block below is rendered by
`render_errata(paper_dir)`, which has not been run yet (R not available here).

<!-- errata:begin -->
<!-- errata:end -->
