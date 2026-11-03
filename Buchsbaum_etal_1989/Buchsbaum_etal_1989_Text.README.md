# Buchsbaum_etal_1989_Text

**Item name** `Buchsbaum_etal_1989_Text` · **Item number** `Text` · **Item encoded** `10.1016%2F0024-3205(89)90021-0_Text` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx`; code derived as the registry formula builds it: DOI percent-encoded + `_` + locus, the
Mink_etal_1981 convention. Paste `Buchsbaum_etal_1989_Text_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Buchsbaum, M. S., Gillin, J. C., Wu, J., Hazlett, E., Sicotte, N., Dupont, R. M., & Bunney, W. E., Jr. (1989). Regional cerebral glucose metabolic rate in human sleep assessed by positron emission tomography. *Life Sciences*, 45(15), 1349-1356. <https://doi.org/10.1016/0024-3205(89)90021-0>

**Item full original title:** Values printed in the Summary (p. 1349) and RESULTS (p. 1353).

## Source

PDF in this folder: `Buchsbaum-1989-Regional cerebral glucose metab.pdf`, MOVED here from `cereb metabol refs/`.

The Summary also states the study involved 36 volunteers; the table arms are n = 10 / 12 / 12 (2 awake subjects lacked blood samples).

## Pipeline

```
Source (PDF)
  -> Buchsbaum_etal_1989_extract_snapshot.R   writes the frozen snapshot(s)
  -> Buchsbaum_etal_1989_Text_snapshot.csv   FROZEN: 9 rows x 10 cols
  -> Buchsbaum_etal_1989_Text.R   clean + parse + table checks
  -> Buchsbaum_etal_1989_Text.csv   8 rows x 18 cols  ("use this")
  -> __Public/comparative-data/10.1016%2F0024-3205(89)90021-0_Text.tsv
  -> reference_tables/Buchsbaum_etal_1989_Text_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-02 from 200/400-dpi renders of PDF pages 1, 5 and 6, typed into `Buchsbaum_etal_1989_extract_snapshot.R` (freezes; refuses to overwrite). The OCR layer (typewriter face; "i" for "l") agrees on all 96 table numbers. The build `Buchsbaum_etal_1989_Text.R` reads the frozen file, contains no table values, and was run with `Rscript`
(conda env `r`) on 2026-11-02.

### Constructed snapshot

One row per printed value, sentence quoted; `value_status` says whether a value restates the table or is derived from it.

## Table checks

Result of an actual R run (2026-11-02): **10 pass, 3 mismatch, 0 not evaluable**, of 13 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `nrem_mean` | text 14.0 vs table Lateral cortex Mean NREM | 14 | 14 | 0 | 0 | pass |
| `nrem_sd` | text SD 3.7 vs table Lateral cortex Mean NREM SD | 3.7 | 4.1 | -0.4 | 0 | mismatch |
| `awake_mean` | text 21.4 vs table Lateral cortex Mean Awake | 21.4 | 21.4 | 0 | 0 | pass |
| `awake_sd` | text SD 6.3 vs table Lateral cortex Mean Awake SD | 6.3 | 6.3 | 0 | 0 | pass |
| `rem_mean` | text 19.2 vs table Lateral cortex Mean REM | 19.2 | 19.2 | 0 | 0 | pass |
| `rem_sd` | text SD 4.3 vs table Lateral cortex Mean REM SD | 4.3 | 3.9 | 0.4 | 0 | mismatch |
| `medial_frontal_diff` | text 10.5 vs table Medial frontal Awake - NREM | 10.5 | 10.5 | 0 | 0.1 | pass |
| `medial_frontal_pct` | text 38.2% vs 100 x (Awake - NREM)/Awake, Medial frontal | 38.18 | 38.2 | -0.01818 | 0.4 | pass |
| `putamen_diff` | text 7.5 vs table Putamen Awake - NREM | 7.5 | 7.5 | 0 | 0.1 | pass |
| `putamen_pct` | text 28.4% vs 100 x (Awake - NREM)/Awake, Putamen | 28.41 | 28.4 | 0.009091 | 0.4 | pass |
| `largest_pct_is_medial_frontal` | largest % NREM decrease among the 12 regions = Medial frontal (observed = its rank) | 1 | 1 | 0 | 0 | pass |
| `smallest_pct_is_putamen` | smallest % NREM decrease among the 12 regions = Putamen (observed = its rank from the bottom) | 1 | 1 | 0 | 0 | pass |
| `summary_23pct` | Summary 'about a 23% reduction ... across the entire brain' vs 100 x (Awake - NREM)/Awake of the Grand Mean | 32.3 | 23 | 9.301 | 1.5 | mismatch |

## Data role

**primary** (the authors' own measurements).

## Species names

`species_as_published` keeps the paper's wording (normal volunteers). No `_keys/`
file was edited; proposals are in `reference_tables/Buchsbaum_etal_1989_species_key_proposed.csv`.

## Compilation comparison (done AFTER the snapshot was frozen)

Compared with `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build_wave2.csv`
only after freezing; no printed value changed. Row-by-row reconstruction:
`primary_items_extract/_compilation_check_wave2_meguro_buchsbaum_noda.csv`; comparison extract `primary_items_extract/buchsbaum_1989.csv`.

Kaufman 2004 (6 rows) copied the AWAKE arm (n = 10) exactly, mean and SD: Frontal 23.5 ± 6.5, Parietal 23.2 ± 6.5, Temporal 17.6 ± 4.6, Thalamus 24.3 ± 7.2; Neocortex 21.4 ± 6.3 = the printed Lateral-cortex Mean; Basal ganglia 24.8 ± 6.4 = mean of caudate, putamen and globus pallidus. Kaufman n = 10 is correct. The 0.54-0.66x ratio to other human studies is in the paper itself: its awake rates are low (grand mean 22.6 µmol/100 g/min), and NREM (15.3) would be lower still. It is not an arm mix-up or a copying error. Kaufman did NOT copy a sleep arm. No compilation error found. There are no Karbowski single-source rows for this paper in the wave-2 file.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Buchsbaum_etal_1989_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Buchsbaum_etal_1989-E001 | value_numeric | Summary p. 1349 ('showed about a 23% reduction in metabolic rate across the entire brain') | 23 |  | publication_ambiguity | 32 | proposed | The paper's own table gives Grand Mean Awake 22.6 and NREM 15.3: 100 x (22.6 - 15.3)/22.6 = 32.3%; the lateral-cortex means (21.4 vs 14.0) give 34.6%, subcortical 30.4%, medial 33.3%. No printed aggregate gives 23%. Summary re-read at 250 dpi. | Possibly a transposed 32. Value kept as printed. |
| Buchsbaum_etal_1989-E002 | dispersion_numeric | RESULTS p. 1353 ('NREM sleep (mean 14.0, SD=3.7 ...) ... waking (21.4 ±6.3) and REM (19.2 ±4.3)') | 3.7; 4.3 |  | publication_ambiguity |  | proposed | The three means equal the table's Lateral-cortex "Mean" row (14.0, 21.4, 19.2), and the waking SD matches (6.3), but the table prints SD 4.1 for NREM and 3.9 for REM where the text prints 3.7 and 4.3. Both passages re-read at 250/400 dpi. | Cannot be adjudicated: the text SDs may come from the hemisphere-level ANOVA data. Both kept as printed. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
