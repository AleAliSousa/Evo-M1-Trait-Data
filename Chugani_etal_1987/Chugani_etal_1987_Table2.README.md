# Chugani et al. (1987) — Table 2, lCMRGlc during development

Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). *Positron emission tomography study of
human brain functional development.* Annals of Neurology, 22(4), 487-497.
https://doi.org/10.1002/ana.410220408

**Item:** `Chugani_etal_1987_Table2` · **Item encoded:** `10.1002%2Fana.410220408_Table2` ·
**Public TSV:** `__Public/comparative-data/10.1002%2Fana.410220408_Table2.tsv`

**Table 2** (p. 493). Local cerebral metabolic rate for glucose (lCMRGlc), in µmol/min/100 gm, for
14 brain structures × four developmental age bins (n = 7 / 4 / 12 / 6 — the 29 patients of Table 1)
plus a normal adult group (19–30 years, n = 7). Each cell is printed `mean ± SEM`; a `Ratio` column
(footnote b: ratio to the mean adult lCMRGlc) accompanies each developmental bin.

## Source and transcription

- **Frozen source:** `Chugani_etal_1987_Table2_snapshot.csv` — **transcribed by an AI assistant on
  2026‑10‑31** from a 290‑ppi render of the embedded page bitmap (PDF p. 7), typed into the frozen
  file as printed. The OCR text layer of this scan is unreliable and was not used.
- The snapshot keeps the printed caption, the **two‑tier header with blank padding** under each
  spanning age‑group heading, the three section rows (`Cerebral cortex`, `Basal ganglia and
  thalamus`, `Cerebellum`), `mean ± SEM` in one cell as printed, and the two footnotes — 22 rows
  for 22 printed rows, 10 columns in printed order.
- The R script drops the section and footnote rows, splits `mean ± SEM`, and reshapes the five
  printed column pairs to **long form**: one row per structure × age group, 14 × 5 = **70 rows**.
  Units are already µmol/min/100 g — no conversion.

## Pipeline

| file | role |
|---|---|
| `Chugani_etal_1987_Table2_snapshot.csv` | frozen snapshot (as printed, two-tier header preserved) |
| `Chugani_etal_1987_Table2.R` | snapshot → analysis CSV + public TSV; `table_checks` |
| `Chugani_etal_1987_Table2.csv` | analysis data, 70 rows × 13 cols |
| `reference_tables/Chugani_etal_1987_Table2_definitions.csv` | data dictionary |
| `reference_tables/Chugani_etal_1987_errata.csv` | errata |
| public TSV | `__Public/comparative-data/10.1002%2Fana.410220408_Table2.tsv` |

## Table checks (actual R run, 2026‑10‑31) — 56 checks, **55 pass, 1 mismatch**

The table checks itself: footnote b makes every printed `Ratio` recomputable from two printed means
in the same row. All 56 developmental ratios were recomputed at the printed precision (tolerance
0.0055 = half a unit of the last printed decimal plus propagated rounding of the two means).

| check | observed | printed | difference | status |
|---|---|---|---|---|
| Transverse temporal cortex, Birth–1 year | 0.853 | 0.86 | −0.007 | **mismatch** |
| the other 55 ratios | — | — | ≤ 0.0055 | pass |

The one mismatch is recorded as `Chugani_etal_1987-E001` (publication_error, proposed 0.85); the CSV
keeps the printed 0.86 and both printed means, so any user can recompute it.

A second discrepancy is recorded as `Chugani_etal_1987-E002` (publication_ambiguity): the running
text on pp. 493–494 says brainstem lCMRGlc is "approximately 82% of mature rates" in the first year
with peak values "approximately 170% of corresponding adult values (see Table 2)", where Table 2
prints 0.89 and 1.46. The parallel cerebellum sentence (175% peak) does agree with Table 2 (1.71).

## Cross-check against Figure 2

Figure 2 plots the individual values behind these means. The digitised Figure 2 items
(`Chugani_etal_1987_Figure2A`, `Chugani_etal_1987_Figure2B-D`) are checked back against this table,
region by region and bin by bin; the agreement is reported in those READMEs. The **13 adult group
means** of Figure 2 reproduce the adult column of this table to a mean of +0.03 and a maximum of
0.26 µmol/min/100 g.

## Observation level and data role

**primary.** One row per structure × **age-group mean** — not per individual and not per species.
`species_as_published = "human"`, resolved to *Homo sapiens* through
`_keys/General/species_key.csv`. Precision: values as printed, two decimals; SEMs as printed.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Chugani_etal_1987_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Chugani_etal_1987-E001 | ratio_to_adult_as_printed | Table 2, p. 493, row 'Transverse temporal cortex', column 'Birth-1 year', Ratio | 0.86 | 0.86 | publication_error | 0.85 | proposed | Footnote b defines the Ratio as the ratio to the mean adult lCMRGlc. The same printed row gives 25.47 +/- 2.44 for Birth-1 year and 29.86 +/- 1.33 for Adult 19-30 years; 25.47 / 29.86 = 0.8530, which rounds to 0.85 at the printed two decimals. The other 55 ratios of Table 2 all reproduce from their own printed row to within 0.0055 (Chugani_etal_1987_Table2.R, table_checks). | The CSV keeps the printed 0.86. Both printed means are kept too, so the ratio is recomputable by any user. |
| Chugani_etal_1987-E002 | ratio_to_adult_as_printed | pp. 493-494 running text, section 'Brainstem', against Table 2 row 'Brainstem' | approximately 82% of mature rates ... subsequent peak values were approximately 170% of corresponding adult values (see Table 2) | 0.89 (Birth-1 year); 1.46 (3-8 years) | publication_ambiguity |  | proposed | The text cites Table 2 for both figures, but Table 2 prints Brainstem ratios of 0.89 for Birth-1 year and 1.46 for 3-8 years (the peak bin), not 0.82 and 1.70. The parallel cerebellum sentence on p. 493 ('approximately 175% of adult rates') does agree with Table 2 (1.71), so the discrepancy is specific to the brainstem sentence. | The CSV keeps the printed Table 2 values; the running-text percentages are not used anywhere in the build. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
