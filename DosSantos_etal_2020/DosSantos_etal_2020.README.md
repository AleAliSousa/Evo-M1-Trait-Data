# Dos Santos et al. (2020) — paper folder

Dos Santos, S. E., Medeiros, M., Porfirio, J., Tavares, W., Pessôa, L., Grinberg, L., Leite, R. E. P.,
Ferretti-Rebustini, R. E. L., Suemoto, C. K., Jacob Filho, W., Noctor, S. C., Sherwood, C. C., Kaas, J. H.,
Manger, P. R., & Herculano-Houzel, S. (2020). Similar microglial cell densities across brain structures
and mammalian species: implications for brain tissue function. *Journal of Neuroscience* 40(24),
4622–4643. https://doi.org/10.1523/JNEUROSCI.2339-19.2020

## How this paper is used

**The published Table 1 is the source.** `DosSantos_etal_2020_Table1` feeds
`__merging_cell_counts_isotropic_fractionator` as printed, with two qualifications:

1. **Ten printed cells are corrected in the merge** (step 3.4e of
   `cell_counts_isotropic_fractionator_compiled.R`), each guarded so the merge stops if the printed
   value is not the expected one. They are the rows of the errata table below that carry a proposed
   value. The CSV, the snapshot and the public TSV keep the printed values.
2. **Structure mass, C, N and N/mg are re-reported values** (Table 1 footnote a). In the merge the
   primary Herculano-Houzel-team tables outrank Table 1 for those four measures; Table 1 fills them
   only where no primary table has the cell. Its own microglia measures (I/mg and I/N measured, I
   derived as I/N × N) have no competitor.

No erratum has been published for this paper. The errata recorded here are ours. Every one is
*found* from the publication itself — Table 1's own arithmetic, Table 5, Table 2 and Figure 5 — and
eight of the ten corrected values are also *derived* from it. The other two (E007, E008) take their
value from the authors' unpublished workbook, named as the source in the errata row.

### Where a corrected value comes from (curator rule, 2026-11-21)

In this order; the more of them agree, the firmer the correction:

1. **A published table** — this paper's, or the earlier paper a re-reported value comes from.
2. **Calculation from published numbers** — preferring the quantity measured first (a measured
   density such as I/mg over a count derived from it).
3. **The authors' unpublished table** — only when 1 and 2 fail, and always named as the source.
4. **A figure** — read off the published plot; the last resort for a value, but good support.

| errata | value from | supported by |
|---|---|---|
| E001 *Tragelaphus* Br C | 2: Cx + Cb + RoB | 1: whole-brain neurons + other cells in Herculano-Houzel et al. 2015 Table 5 give the same total |
| E002 *Procavia* Cb N | 1: Herculano-Houzel et al. 2015 Table 2 (= the print without its stray digit) | 2: Br N − Cx N − RoB N |
| E003 *Mungos* RoB I/mg | 2: I / mass | 1: Table 5 Carnivora mean |
| E004 *Dendrohyrax* Br I/mg | 2: I / mass | 2: mass-weighted part densities |
| E005 *Tragelaphus* Hp I/N | 2: I / N (the footnote's own identity) | 2: I and N each pass another check |
| E006 *Tragelaphus* Hp I/mg | 2: I / mass | 2: mass-weighted Cx and Ctx densities |
| E007, E008 *Cebus*, *Papio* Cx C | **3: authors' unpublished workbook** (1 and 2 fail) | 4: Figure 5D and 5H, within 0.4% and 0.2% |
| E009, E010 *Petrodromus* RoB I, Hp I | 2: I/mg × mass (I/mg is measured, I is derived) | 1: Table 5 Afrotheria mean (RoB) |

## Internal check — the paper against itself

`internal_checks/DosSantos_etal_2020_Table1_internal_check.R` runs 1,331 checks on the frozen
snapshot of Table 1:

| family | what is compared |
|---|---|
| A | within a row: N ≤ C, I ≤ C, N/mg = N/mass, I/N = I/N (an identity by the footnote), I/mg against I/mass |
| B | across rows of a species: Br = Cx + Cb + RoB and Cx = Ctx + Hp, for counts, masses and (mass-weighted) densities |
| C | Table 1 against Table 5 (p. 4639): clade ranges and means of I% of all cells, I% of non-neuronal cells, I/mg, I/N |
| D | Table 1 against Table 2 (pp. 4628–4629): cortex I% against the gray/white-matter site means — descriptive band only |
| E | Table 1 against Figure 5D and 5H (p. 4638): the eight primate cortex markers, read off the figure |

Result as printed: **33 major or impossible failures**, in nine species or clade groups. With the ten
proposed values applied: **12**, all of them documented below and none of them a misprinted
cell (ten are the *Elephantulus myurus* rows, which the table itself marks as single-specimen against
species-average, E012; two are the *Petrodromus tetradactylus* I/N cells, E014 and E015).

| file in `internal_checks/` | |
|---|---|
| `DosSantos_etal_2020_Table1_internal_check.R` | the check (base R; reads the snapshot and the inputs below) |
| `DosSantos_etal_2020_Table1_internal_check.csv` | every check on the table as printed |
| `DosSantos_etal_2020_Table1_internal_check_after_errata.csv` | the same checks with the errata values applied |
| `DosSantos_etal_2020_Table5_printed.csv` | Table 5 as printed (64 cells, read back against the page) |
| `DosSantos_etal_2020_Table2_printed.csv` | Table 2 as printed (ranges and means per clade and species) |
| `DosSantos_etal_2020_Table1_clades.csv` | the clade of each Table 1 species |
| `DosSantos_etal_2020_Figure5_primate_cortex_points.py` | reads the primate markers off Figure 5D/5H from the PDF |
| `DosSantos_etal_2020_Figure5_primate_cortex_points.csv` | the sixteen markers (eight per panel) |
| `DosSantos_etal_2020_Figure5_primate_cortex_points_overlay.png` | the markers found, drawn on the figure |

Re-run, from the paper folder:

```
python  internal_checks/DosSantos_etal_2020_Figure5_primate_cortex_points.py     # only if the PDF changes
Rscript internal_checks/DosSantos_etal_2020_Table1_internal_check.R
```

Threshold used for a correction: the table's own evidence fails by more than 10% **and** identifies
the wrong cell. Smaller inconsistencies stay in the check report and are left as printed; three are
recorded as errata because several checks point at one cell (E011, E013) or because they explain a
correction (E014, E015).

## The authors' unpublished data

The authors' spreadsheet is not in this repository. Two values from it are used here, and named as
such: the cortex total cells of *Cebus apella* and *Papio anubis cynocephalus* (errata E007 and E008),
which no published table carries and which the publication's own numbers cannot fix exactly. Nothing
else from the spreadsheet is used or quoted. The comparison of Table 1, and of each erratum, with that
spreadsheet is a private check:
`Evo-M1-Trait-Data-restricted/restricted_checks/_cross_table/DosSantos_2020_published_vs_authors_unpublished/`.
Until 2026-11 the merge read an `DosSantos_etal_2020_unpublished` item built from it; that item, its
build script and its public TSV were removed when the merge moved to the published table.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/DosSantos_etal_2020_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| DosSantos_etal_2020-E001 | Br_C | Table 1, p. 4625, row "Tragelaphus strepsiceros Br" | 21 751 929 | 21751929 | publication_error | 21888835128 | confirmed | Printed whole-brain C (21,751,929) is smaller than the same row's N (4,911,651,549) and I (1,204,929,478), which is impossible, and is 0.1% of Cx + Cb + RoB = 13,064,871,626 + 5,308,593,750 + 3,515,369,752 = 21,888,835,128 (the footnote defines Br as the joint value of Cx, Cb and RoB). Of the 23 species where that sum can be tested, 21 close it within 2%; the other exception is E. myurus (E012). The print dropped the last three digits. Proposed value = the parts sum; it also equals the whole-brain neurons plus other cells printed in Herculano-Houzel et al. 2015 Table 5 (4,911,651,549 + 16,977,183,580 = 21,888,835,129), the compilation Table 1's whole-brain N matches exactly. Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). |
| DosSantos_etal_2020-E002 | Cb_N | Table 1, p. 4625, row "Procavia capensis Cb" | 488 3703 000 | 4883703000 | publication_error | 488373000 | confirmed | Printed as "488 3703 000", a ten-digit string that reads 4,883,703,000: more neurons than the row's total cells C (579,378,000), impossible. Removing the intruding 0 gives 488,373,000, which (i) equals Br N - Cx N - RoB N = 755,653,256 - 197,933,000 - 69,358,240 = 488,362,016 to 0.002%, (ii) reproduces the printed I/N: 7,806,491 / 488,373,000 = 0.0160 (printed 0.016), and (iii) is the value in Herculano-Houzel et al. 2015 Table 2, the source Table 1 re-reports. Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). |
| DosSantos_etal_2020-E003 | RoB_I/mg | Table 1, p. 4626, row "Mungos mungo RoB" | 1.915 | 1.915 | publication_error | 1915 | confirmed | Printed "1.915"; every other I/mg in the table is a whole number of at least 1,235. I / (mass x 1000) = 6,614,280 / 3454 = 1914.96, so the print carries a decimal point in place of the thousands space of 1 915. Table 5 (p. 4639) confirms it: the Carnivora RoB I/mg mean recomputed from the 6 Table 1 rows is 4,502 with 1.915 and 4,821 with 1,915; Table 5 prints 4821. Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). |
| DosSantos_etal_2020-E004 | Br_I/mg | Table 1, p. 4625, row "Dendrohyrax dorsalis Br" | 10 129 | 10129 | publication_error | 2123 | confirmed | Printed 10 129, above every one of the species' own parts (Cx 1832, Cb 1235, RoB 3299), which a whole-brain density cannot be. I / (mass x 1000) = 27,176,885 / 12802 = 2122.9, and the mass-weighted mean of the three printed part densities is 2,124; that mass-weighted identity holds to a median 0.03% across the table's 94 testable cases. The same row's N/mg (39 412) is consistent with N / mass. Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). |
| DosSantos_etal_2020-E005 | Hp_I/N | Table 1, p. 4625, row "Tragelaphus strepsiceros Hp" | 3.946 | 3.946 | publication_error | 1.034 | confirmed | The Table 1 footnote (p. 4627) defines I as (I/N) x N, so I/N = I / N must hold; 150 of the table's 153 rows satisfy it within rounding. Here I / N = 29,326,563 / 28,363,281 = 1.034 against a printed 3.946 (+282%). I is vouched for by Cx I = Ctx I + Hp I (within 1.0%) and N by N/mg = N / mass (within 0.02%), which leaves the printed ratio as the wrong cell. Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). |
| DosSantos_etal_2020-E006 | Hp_I/mg | Table 1, p. 4625, row "Tragelaphus strepsiceros Hp" | 4710 | 4710 | publication_error | 2682 | confirmed | Printed 4710 against I / (mass x 1000) = 29,326,563 / 10936 = 2,682 (+76%). Independent of the I column: densities are mass-additive, and the printed Cx (3718 /mg, 213.37 g) and Ctx (3772 /mg, 202.434 g) leave 2,718 /mg for the 10.936 g hippocampus, not 4710; with 4710 the Cx density would be 3,820, a 2.7% miss where the table's median miss is 0.03%. The same row's I/N is also wrong (E005). Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). |
| DosSantos_etal_2020-E007 | Cx_C | Table 1, p. 4627, row "Cebus apella Cx" | 3035 947 220 | 3035947220 | publication_error | 3707354000 | confirmed | Source of the proposed value: the authors' unpublished workbook (2020-PublishedDataMammalsMicroglia, received 22 March 2024; private repo, unpublished_data/____Unpublished__DosSantos_microglia_2024/), row "Cerebral cortex, total (GM+WM+hippoc)", which gives C = 3,707,354,000. Order of preference for a corrected value (curator rule, 2026-11-21): (1) a published table; (2) calculation from published numbers; (3) the authors' unpublished table, named as the source; (4) a figure. The more of these agree, the firmer the correction. (1) fails: no published table carries this cortex sample. The source Table 1 cites for the primates (Gabi et al. 2016) prints no absolute totals; Herculano-Houzel et al. 2015 Table 1 is a different sample (cortex 39.178 g and 1.14 x 10^9 neurons, against 53.784 g and 0.970 x 10^9 here); and none of the repo's 1,194 public tables contains this row's neuron number or the workbook's cell number. (2) fails for an exact value: Table 1 has no second route to C, and the Primata Cx mean and SE in Table 5 bound 100 I/C for the two affected primates only loosely (2.8-3.4% and 3.4-4.0%, without saying which is which). (3) is therefore used. (4) agrees: Figure 5 (p. 4638) plots 2.85% (panel D, 100 I/C) and 3.85% (panel H, 100 I/(C-N)) for this species, where the printed row implies 3.49% and 5.14%; the two readings give C = 3,719,616,374 and 3,722,000,364, +0.33% and +0.40% from the workbook value (markers read by internal_checks/DosSantos_etal_2020_Figure5_primate_cortex_points.py; the five self-consistent primate rows reproduce Table 1 within 0.9% in D and 2.3% in H). Also consistent: Figure 5A's Primata histogram has three species in the 2-3% bin (two without this one), and the Primata Cx mean of 100 I/C recomputed from Table 1 is 3.95% where Table 5 prints 3.75%. Only C is wrong in this row: the print is -18.1% against the workbook, while N, I, I/N, I/mg, N/mg and mass agree within about 2%. | Printed value read on the PDF page. The proposed value is the authors' unpublished figure, used and named as the source by curator decision (2026-11-21); until then this row proposed the Figure 5 reading (3,720,000,000). Substituted in the cell-counts merge (guarded step 3.4e), where it only affects the within-source microglia-per-cell ratio; merged total cells come from the primary source. |
| DosSantos_etal_2020-E008 | Cx_C | Table 1, p. 4627, row "Papio anubis cynocephalus Cx" | 4934 116 014 | 4934116014 | publication_error | 6740084000 | confirmed | Source of the proposed value: the authors' unpublished workbook (2020-PublishedDataMammalsMicroglia, received 22 March 2024; private repo, unpublished_data/____Unpublished__DosSantos_microglia_2024/), row "Cerebral cortex, total (GM+WM+hippoc)", which gives C = 6,740,084,000. Order of preference for a corrected value (curator rule, 2026-11-21): (1) a published table; (2) calculation from published numbers; (3) the authors' unpublished table, named as the source; (4) a figure. The more of these agree, the firmer the correction. (1) fails: no published table carries this cortex sample. The source Table 1 cites for the primates (Gabi et al. 2016) prints no absolute totals; Herculano-Houzel et al. 2015 Table 1 is a different sample (cortex 120.214 g and 2.875 x 10^9 neurons, against 94.744 g and 1.145 x 10^9 here), as is the Collins et al. 2010 baboon (one flattened hemisphere, 2.357 x 10^9 neurons); and none of the repo's 1,194 public tables contains this row's neuron number or the workbook's cell number. (2) fails for an exact value: Table 1 has no second route to C, and the Primata Cx mean and SE in Table 5 bound 100 I/C for the two affected primates only loosely (2.8-3.4% and 3.4-4.0%, without saying which is which). (3) is therefore used. (4) agrees: Figure 5 (p. 4638) plots 3.82% (panel D, 100 I/C) and 4.60% (panel H, 100 I/(C-N)) for this species, where the printed row implies 5.23% and 6.80%; the two readings give C = 6,750,949,620 and 6,753,251,442, +0.16% and +0.20% from the workbook value (markers read by internal_checks/DosSantos_etal_2020_Figure5_primate_cortex_points.py; the five self-consistent primate rows reproduce Table 1 within 0.9% in D and 2.3% in H). Also consistent: Figure 5A's Primata histogram has no species in the 5-6% bin, where the printed value would sit, and the Primata Cx mean of 100 I/C recomputed from Table 1 is 3.95% where Table 5 prints 3.75%. Only C is wrong in this row: the print is -26.8% against the workbook, while N, I, I/N, I/mg, N/mg and mass agree within about 2%. | Printed value read on the PDF page. The proposed value is the authors' unpublished figure, used and named as the source by curator decision (2026-11-21); until then this row proposed the Figure 5 reading (6,750,000,000). Substituted in the cell-counts merge (guarded step 3.4e), where it only affects the within-source microglia-per-cell ratio; merged total cells come from the primary source. |
| DosSantos_etal_2020-E009 | RoB_I | Table 1, p. 4625, row "Petrodromus tetradactylus RoB" | 1217 665 | 1217665 | publication_ambiguity | 1649430 | confirmed | Two published estimates of the same count disagree. The footnote's formula, I = (I/N) x N = 0.1 x 12,231,811, gives the printed 1,217,665; the measured density gives I/mg x mass = 1845 x 894 = 1,649,430 (-26% for the print). Across the table the two agree within 2% in 129 of 153 rows and within 5% in 144. The density-based values are the coherent set for this species: its printed I/mg values are mass-additive (Cx against Ctx + Hp -0.15%, Br against Cx + Cb + RoB +0.36%), while its printed I column misses the same sums by -2.0% and +2.5%. Table 5 sides with the density: the Afrotheria RoB I/mg range starts at 1845 (this row), and the Afrotheria RoB mean of 100 I/C recomputed from Table 1 is 4.68% with the printed I and 4.89% with the proposed one; Table 5 prints 4.89%. Proposed value = I/mg x mass. Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). Confirmed by the curator 2026-11-21. The printed I/N of this row then no longer equals I / N; see the I/N erratum for the same row. |
| DosSantos_etal_2020-E010 | Hp_I | Table 1, p. 4625, row "Petrodromus tetradactylus Hp" | 1067 062 | 1067062 | publication_ambiguity | 824704 | confirmed | Two published estimates of the same count disagree. The footnote's formula, I = (I/N) x N = 0.17 x 6,294,000, gives the printed 1,067,062; the measured density gives I/mg x mass = 3032 x 272 = 824,704 (+29% for the print). Across the table the two agree within 2% in 129 of 153 rows and within 5% in 144. The density-based values are the coherent set for this species: its printed I/mg values are mass-additive (Cx against Ctx + Hp -0.15%, Br against Cx + Cb + RoB +0.36%), while its printed I column misses the same sums by -2.0% and +2.5%. Hippocampus is not in Table 5, so the evidence here is the density additivity alone. Proposed value = I/mg x mass. Agrees with the private check against the authors' own data (restricted repo), which is not quoted here. | Printed value read on the PDF page. Substituted in the cell-counts merge (guarded step 3.4e). Confirmed by the curator 2026-11-21. The printed I/N of this row then no longer equals I / N; see the I/N erratum for the same row. |
| DosSantos_etal_2020-E011 | Cx_C | Table 1, p. 4627, row "Otolemur garnettii Cx" | 494 053 510 | 494053510 | publication_error |  | confirmed | Same pattern as C. apella and P. anubis cynocephalus (E007, E008), smaller: Table 1 gives 100 I/C = 7.97% and 100 I/(C-N) = 13.22%; Figure 5 plots 8.23% and 13.95%, and Table 5 prints the Primata Cx maxima as 8.26% and 14.03% (this species). Both ratios are reproduced by a C of about 4.78 x 10^8 (printed 494,053,510; -3.2%). | Below the 10% threshold for substitution: recorded, left as printed in the merge. |
| DosSantos_etal_2020-E012 | Br_I | Table 1, p. 4625, row "Elephantulus myurus Br*" | 2699 666 | 2699666 | publication_ambiguity |  | confirmed | The species' rows do not close: Br I is -15.6% against Cx + Cb + RoB, Cx I is +12.6% against Ctx + Hp, and Br mass and C miss their sums by -6.0% and -3.5%, although every row is consistent within itself. The table explains it: Cx, Hp and Br carry the footnote mark * (data available for only one specimen of the species), while Cb, RoB and Ctx do not. The starred rows describe one animal and the unstarred rows the species average, so sums across them cannot close. Consistently, Table 5's Afrotheria Cx mean of 100 I/C (6.04%) is reproduced only without this species' single-specimen Cx row (6.04% for the other four species). No cell is misprinted and none is corrected. | Not an error in any one cell; left as printed. Filed under Br I (the largest miss) but applies to all six E. myurus rows: do not combine starred and unstarred rows of this species. |
| DosSantos_etal_2020-E013 | Br_Structure mass (g) | Table 1, p. 4625, row "Loxodonta africana Br" | 4168.620 | 4168.62 | publication_error |  | confirmed | Printed 4168.62 g against Cx + Cb + RoB = 4,584.26 g (-9.1%). The row's own N/mg (56 071) and I/mg (4562) equal N and I divided by the parts sum (56,071 and 4,563), not by the printed mass, so the printed mass is the odd cell. | Below the 10% threshold for substitution: recorded, left as printed in the merge. |
| DosSantos_etal_2020-E014 | RoB_I/N | Table 1, p. 4625, row "Petrodromus tetradactylus RoB" | 0.100 | 0.1 | publication_ambiguity |  | confirmed | The printed, measured I/N (0.1) and the printed, measured I/mg (1845) cannot both hold with the printed N (12,231,811) and mass (0.894 g): I/N x N = 1,223,181, I/mg x mass = 1,649,430. Equivalently, the microglia samples had a neuronal density of I/mg / (I/N) = 18,450 /mg where the table re-reports 13,696 /mg. The table cannot say whether I/N or N is the cell that does not belong to these samples. | Left as printed. With the I erratum for this row applied, the printed I/N differs from I / N by design. |
| DosSantos_etal_2020-E015 | Hp_I/N | Table 1, p. 4625, row "Petrodromus tetradactylus Hp" | 0.170 | 0.17 | publication_ambiguity |  | confirmed | The printed, measured I/N (0.17) and the printed, measured I/mg (3032) cannot both hold with the printed N (6,294,000) and mass (0.272 g): I/N x N = 1,069,980, I/mg x mass = 824,704. Equivalently, the microglia samples had a neuronal density of I/mg / (I/N) = 17,835 /mg where the table re-reports 23,164 /mg. The table cannot say whether I/N or N is the cell that does not belong to these samples. | Left as printed. With the I erratum for this row applied, the printed I/N differs from I / N by design. |

15 recorded, 0 open (proposed), 15 confirmed, 0 withdrawn.
<!-- errata:end -->

## Other files

| file | |
|---|---|
| `DosSantos_etal_2020_Table1_snapshot.R` / `_snapshot.csv` | frozen copy of Table 1 as printed (pp. 4625–4627) |
| `DosSantos_etal_2020_Table1.R` / `.csv` / `.README.md` | reformat of the snapshot to one row per species; item notes |
| `reference_tables/DosSantos_etal_2020_Table1_definitions.csv` | one row per column of the item, with its role (measured, derived, re-reported) |
| `reference_tables/DosSantos_etal_2020_errata.csv` | the errata source file (rendered above by `render_errata`) |
| `DosSantos_etal_2020_definitions.csv` | older paper-level code list (structure and measure codes) |
