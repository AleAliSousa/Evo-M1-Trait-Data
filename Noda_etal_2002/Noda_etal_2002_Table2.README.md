# Noda_etal_2002_Table2

**Item name** `Noda_etal_2002_Table2` · **Item number** `Table 2` · **Item encoded** `10.1016%2FS0006-8993(02)02558-1_Table2` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx`; code derived as the registry formula builds it: DOI percent-encoded + `_` + locus, the
Mink_etal_1981 convention. Paste `Noda_etal_2002_Table2_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Noda, A., Ohba, H., Kakiuchi, T., Futatsubashi, M., Tsukada, H., & Nishimura, S. (2002). Age-related changes in cerebral blood flow and glucose metabolism in conscious rhesus monkeys. *Brain Research*, 936(1-2), 76-81. <https://doi.org/10.1016/S0006-8993(02)02558-1>

**Item full original title:** Table 2. Regional cerebral blood flow in young and aged monkeys, p. 79.

## Source

PDF in this folder: `Noda-2002-Age-related changes in cerebral bloo.pdf`, MOVED here from `cereb metabol refs/`.

Not built: Table 1 (physiological variables). Fig. 1 (individual rCBF vs rCMRglc points) was not digitised.

## Pipeline

```
Source (PDF)
  -> Noda_etal_2002_extract_snapshot.R   writes the frozen snapshot(s)
  -> Noda_etal_2002_Table2_snapshot.csv   FROZEN: 15 rows x 10 cols
  -> Noda_etal_2002_Table2.R   clean + parse + table checks
  -> Noda_etal_2002_Table2.csv   57 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1016%2FS0006-8993(02)02558-1_Table2.tsv
  -> reference_tables/Noda_etal_2002_Table2_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-02 from 330-dpi renders of PDF page 4, typed into `Noda_etal_2002_extract_snapshot.R` (one script writes both tables; freezes; refuses to overwrite). The born-digital text layer ("±" encoded as "6", superscripts detached) agrees on all 76 mean ± SD pairs. The build `Noda_etal_2002_Table2.R` reads the frozen file, contains no table values, and was run with `Rscript`
(conda env `r`) on 2026-11-02.

### Snapshot and analysis CSV

* One snapshot row per printed row (caption, header tiers with blank padding under spanners, section headings and gaps,
  data rows in printed order, footnote rows); superscripts `^x`; odd prints kept verbatim (see errata).
* The analysis CSV is **long**: one row per printed cell (structure x arm); `mean_printed` / `dispersion_printed`
  keep the printed lexemes. **Observation level: printed group means per arm**, not species means.

### Arms printed

young_/aged_ x average, R_or_A, L_or_P (n = 6 each; mean ± S.D.); Y_minus_A_* = printed Y–A (%).

## Table checks

Result of an actual R run (2026-11-02): **37 pass, 6 mismatch, 0 not evaluable**, of 43 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `sd_plausible_young_Temporal cortex` | Temporal cortex, young: SD of Average <= mean of the two part SDs + 0.1 | 6.5 | 2.75 | 3.75 | 0.1 | mismatch |
| `sd_plausible_aged_Temporal cortex` | Temporal cortex, aged: SD of Average <= mean of the two part SDs + 0.1 | 4.6 | 1.9 | 2.7 | 0.1 | mismatch |
| `sd_plausible_young_Frontal cortex` | Frontal cortex, young: SD of Average <= mean of the two part SDs + 0.1 | 6.4 | 2.8 | 3.6 | 0.1 | mismatch |
| `sd_plausible_aged_Frontal cortex` | Frontal cortex, aged: SD of Average <= mean of the two part SDs + 0.1 | 3.6 | 2.15 | 1.45 | 0.1 | mismatch |
| `sd_plausible_young_Cingulate` | Cingulate, young: SD of Average <= mean of the two part SDs + 0.1 | 9.6 | 3.95 | 5.65 | 0.1 | mismatch |
| `sd_plausible_aged_Cingulate` | Cingulate, aged: SD of Average <= mean of the two part SDs + 0.1 | 2.1 | 1 | 1.1 | 0.1 | mismatch |

(Only non-passing checks listed; the other 37 pass.)

## Data role

**primary** (the authors' own measurements).

## Species names

`species_as_published` keeps the paper's wording (male rhesus monkeys (Macaca mulatta)). No `_keys/`
file was edited; proposals are in `reference_tables/Noda_etal_2002_species_key_proposed.csv`.

## Compilation comparison (done AFTER the snapshot was frozen)

Compared with `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build_wave2.csv`
only after freezing; no printed value changed. Row-by-row reconstruction:
`primary_items_extract/_compilation_check_wave2_meguro_buchsbaum_noda.csv`; comparison extract `primary_items_extract/noda_2002.csv`.

Both compilations copied the YOUNG-ADULT group (6.2 y, n = 6), 'Average' column, and never the aged group or the R/L or A/P columns. Kaufman 2004 (11 rows): 7 rCMRglc rows from Table 3, exact mean ± SD (Basal ganglia = Striatum 40.9 ± 9.1, Cerebellum 26.8 ± 5.9, ...). It also takes 4 rCBF rows from Table 2: Basal ganglia 60.5 ± 11.1 (striatum); Cerebellum 47.8 and Hippocampus 53.9 with the printed SDs (5.1, 7.6) omitted; Neocortex 53.0 ± 7.5 = mean of occipital, temporal, frontal and cingulate (52.98). Karbowski 2007 (7 single-source rows): the same young Average rCMRglc values in µmol/g/min (e.g. Cerebellum 0.27 ± 0.06; Neocortex 0.37 ± 0.08 = mean of the 4 cortical ROIs). Compilation errors: only Kaufman's omitted CBF SDs. Both compilations carry the paper's implausible young Average SDs for temporal, frontal and cingulate (errata Noda_etal_2002-E001/E002).

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Noda_etal_2002_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Noda_etal_2002-E001 | dispersion_numeric | Table 2 p. 79, rows 'Temporal cortex', 'Frontal cortex', 'Cingulate', columns 'Average' (young and aged) | 6.5; 6.4; 9.6 (young), 4.6; 3.6; 2.1 (aged) |  | publication_ambiguity |  | proposed | An Average of two parts per animal cannot have an SD larger than the mean of the two parts' SDs. The printed Average SDs exceed it in 6 cells (young temporal 6.5 vs 2.75, frontal 6.4 vs 2.8, cingulate 9.6 vs 3.95; aged 4.6 vs 1.9, 3.6 vs 2.15, 2.1 vs 1.0); for Hippocampus, Striatum and Occipital the Average SD is consistent. Either the R/L (A/P) SDs of these 3 rows are SEM-like, or the Average SDs were computed on another basis. Re-read at 330 dpi; text layer agrees. | Detected by table_checks sd_plausible_*. Both compilations copied the young Average SDs of these rows. Kept as printed. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
