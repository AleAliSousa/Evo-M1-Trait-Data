# Buchsbaum_etal_1989_TableI

**Item name** `Buchsbaum_etal_1989_TableI` · **Item number** `Table I` · **Item encoded** `10.1016%2F0024-3205(89)90021-0_TableI` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx`; code derived as the registry formula builds it: DOI percent-encoded + `_` + locus, the
Mink_etal_1981 convention. Paste `Buchsbaum_etal_1989_TableI_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Buchsbaum, M. S., Gillin, J. C., Wu, J., Hazlett, E., Sicotte, N., Dupont, R. M., & Bunney, W. E., Jr. (1989). Regional cerebral glucose metabolic rate in human sleep assessed by positron emission tomography. *Life Sciences*, 45(15), 1349-1356. <https://doi.org/10.1016/0024-3205(89)90021-0>

**Item full original title:** MEAN GLUCOSE METABOLIC RATE IN HUMAN SLEEP (micromoles/100g/min), p. 1354 (no number printed; called "Table I" in the text).

## Source

PDF in this folder: `Buchsbaum-1989-Regional cerebral glucose metab.pdf`, MOVED here from `cereb metabol refs/`.

The Summary also states the study involved 36 volunteers; the table arms are n = 10 / 12 / 12 (2 awake subjects lacked blood samples).

## Pipeline

```
Source (PDF)
  -> Buchsbaum_etal_1989_extract_snapshot.R   writes the frozen snapshot(s)
  -> Buchsbaum_etal_1989_TableI_snapshot.csv   FROZEN: 27 rows x 7 cols
  -> Buchsbaum_etal_1989_TableI.R   clean + parse + table checks
  -> Buchsbaum_etal_1989_TableI.csv   48 rows x 18 cols  ("use this")
  -> __Public/comparative-data/10.1016%2F0024-3205(89)90021-0_TableI.tsv
  -> reference_tables/Buchsbaum_etal_1989_TableI_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-02 from 200/400-dpi renders of PDF pages 1, 5 and 6, typed into `Buchsbaum_etal_1989_extract_snapshot.R` (freezes; refuses to overwrite). The OCR layer (typewriter face; "i" for "l") agrees on all 96 table numbers. The build `Buchsbaum_etal_1989_TableI.R` reads the frozen file, contains no table values, and was run with `Rscript`
(conda env `r`) on 2026-11-02.

### Snapshot and analysis CSV

* One snapshot row per printed row (caption, header tiers with blank padding under spanners, section headings and gaps,
  data rows in printed order, footnote rows); superscripts `^x`; odd prints kept verbatim (see errata).
* The analysis CSV is **long**: one row per printed cell (structure x arm); `mean_printed` / `dispersion_printed`
  keep the printed lexemes. **Observation level: printed group means per arm**, not species means.

### Arms printed

awake (n = 10), nrem_sleep (n = 12), rem_sleep (n = 12); mean, SD.

## Table checks

Result of an actual R run (2026-11-02): **12 pass, 0 mismatch, 0 not evaluable**, of 12 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `mean_Lateral_cortex_awake` | Lateral cortex Mean vs mean of its 4 regions, awake | 21.35 | 21.4 | -0.05 | 0.1 | pass |
| `mean_Subcortical_gray_awake` | Subcortical gray Mean vs mean of its 4 regions, awake | 24.7 | 24.7 | 0 | 0.1 | pass |
| `mean_Medial_cortex_awake` | Medial cortex Mean vs mean of its 4 regions, awake | 21.88 | 21.9 | -0.025 | 0.1 | pass |
| `grand_mean_awake` | Grand Mean vs mean of the 12 regions, awake | 22.64 | 22.6 | 0.04167 | 0.1 | pass |
| `mean_Lateral_cortex_nrem_sleep` | Lateral cortex Mean vs mean of its 4 regions, nrem_sleep | 14.03 | 14 | 0.025 | 0.1 | pass |
| `mean_Subcortical_gray_nrem_sleep` | Subcortical gray Mean vs mean of its 4 regions, nrem_sleep | 17.2 | 17.2 | 0 | 0.1 | pass |
| `mean_Medial_cortex_nrem_sleep` | Medial cortex Mean vs mean of its 4 regions, nrem_sleep | 14.55 | 14.6 | -0.05 | 0.1 | pass |
| `grand_mean_nrem_sleep` | Grand Mean vs mean of the 12 regions, nrem_sleep | 15.26 | 15.3 | -0.04167 | 0.1 | pass |
| `mean_Lateral_cortex_rem_sleep` | Lateral cortex Mean vs mean of its 4 regions, rem_sleep | 19.2 | 19.2 | 0 | 0.1 | pass |
| `mean_Subcortical_gray_rem_sleep` | Subcortical gray Mean vs mean of its 4 regions, rem_sleep | 21.05 | 21.1 | -0.05 | 0.1 | pass |
| `mean_Medial_cortex_rem_sleep` | Medial cortex Mean vs mean of its 4 regions, rem_sleep | 20.6 | 20.6 | 0 | 0.1 | pass |
| `grand_mean_rem_sleep` | Grand Mean vs mean of the 12 regions, rem_sleep | 20.28 | 20.3 | -0.01667 | 0.1 | pass |

## Data role

**primary** (the authors' own measurements).

## Species names

`species_as_published` keeps the paper's wording (normal volunteers (male subjects)). No `_keys/`
file was edited; proposals are in `reference_tables/Buchsbaum_etal_1989_species_key_proposed.csv`.

## Compilation comparison (done AFTER the snapshot was frozen)

Compared with `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build_wave2.csv`
only after freezing; no printed value changed. Row-by-row reconstruction:
`primary_items_extract/_compilation_check_wave2_meguro_buchsbaum_noda.csv`; comparison extract `primary_items_extract/buchsbaum_1989.csv`.

Kaufman 2004 (6 rows) copied the AWAKE arm (n = 10) exactly, mean and SD: Frontal 23.5 ± 6.5, Parietal 23.2 ± 6.5, Temporal 17.6 ± 4.6, Thalamus 24.3 ± 7.2; Neocortex 21.4 ± 6.3 = the printed Lateral-cortex Mean; Basal ganglia 24.8 ± 6.4 = mean of caudate, putamen and globus pallidus. Kaufman n = 10 is correct. The 0.54-0.66x ratio to other human studies is in the paper itself: its awake rates are low (grand mean 22.6 µmol/100 g/min), and NREM (15.3) would be lower still. It is not an arm mix-up or a copying error. Kaufman did NOT copy a sleep arm. No compilation error found. There are no Karbowski single-source rows for this paper in the wave-2 file.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
<!-- errata:end -->
