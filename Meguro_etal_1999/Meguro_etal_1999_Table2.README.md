# Meguro_etal_1999_Table2

**Item name** `Meguro_etal_1999_Table2` · **Item number** `Table 2` · **Item encoded** `10.1093%2Fbrain%2F122.8.1519_Table2` — *derived, awaiting registration*
(not yet in `__ReadMe.xlsx`; code derived as the registry formula builds it: DOI percent-encoded + `_` + locus, the
Mink_etal_1981 convention. Paste `Meguro_etal_1999_Table2_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Meguro, K., Blaizot, X., Kondoh, Y., Le Mestric, C., Baron, J.-C., & Chavoix, C. (1999). Neocortical and hippocampal glucose hypometabolism following neurotoxic lesions of the entorhinal and perirhinal cortices in the non-human primate as shown by PET: implications for Alzheimer's disease. *Brain*, 122(8), 1519-1531. <https://doi.org/10.1093/brain/122.8.1519>

**Item full original title:** Table 2. Regional CMRglc values in the 19 brain regions in each group (n = 3 per group; analysis II, see Results) at the four time points, and corresponding statistical findings, p. 1525.

## Source

PDF in this folder: `Meguro-1999-Neocortical and hippocampal glucos.pdf`, MOVED here from `cereb metabol refs/`.

Not built: Table 1 (lesion-damage scores, no metabolic value). "Analysis I" (all 8 baboons, baseline and day 30) is shown only in figures and was **not digitised**: the compilations use the Table 2 values.

## Pipeline

```
Source (PDF)
  -> Meguro_etal_1999_extract_snapshot.R   writes the frozen snapshot(s)
  -> Meguro_etal_1999_Table2_snapshot.csv   FROZEN: 42 rows x 9 cols
  -> Meguro_etal_1999_Table2.R   clean + parse + table checks
  -> Meguro_etal_1999_Table2.csv   152 rows x 26 cols  ("use this")
  -> __Public/comparative-data/10.1093%2Fbrain%2F122.8.1519_Table2.tsv
  -> reference_tables/Meguro_etal_1999_Table2_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-02 from 280-dpi renders of PDF page 7, typed as a verbatim printed-layout block into `Meguro_etal_1999_extract_snapshot.R` (freezes; refuses to overwrite). The text layer was used afterwards as an independent second reading: all 152 mean (SD) pairs agree. A first freeze had a spurious empty 10th column (structural slip, no value affected); it was moved to `archive/` before any comparison and the table re-frozen with 9 columns. The build `Meguro_etal_1999_Table2.R` reads the frozen file, contains no table values, and was run with `Rscript`
(conda env `r`) on 2026-11-02.

### Snapshot and analysis CSV

* One snapshot row per printed row (caption, header tiers with blank padding under spanners, section headings and gaps,
  data rows in printed order, footnote rows); superscripts `^x`; odd prints kept verbatim (see errata).
* The analysis CSV is **long**: one row per printed cell (structure x arm); `mean_printed` / `dispersion_printed`
  keep the printed lexemes. **Observation level: printed group means per arm**, not species means.

### Arms printed

RH_baseline/day30/day45/day80 (rhinal-lesioned, n = 3) and SH_baseline/day30/day45/day80 (sham, n = 3); Baseline = pre-surgery; mean (SD), mg/100 g/min.

## Table checks

Result of an actual R run (2026-11-02): **2 pass, 2 mismatch, 0 not evaluable**, of 4 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_regions` | distinct regions vs Table 2 title '19 brain regions' | 19 | 19 | 0 | 0 | pass |
| `rh_lower_postop` | post-operative region x time cells with RH >= SH (RESULTS: 'consistently lower in the RH than the SH group postoperatively') | 2 | 0 | 2 | 0 | mismatch |
| `thalamus_baseline_rh_lower` | Thalamus baseline RH - SH < 0 (RESULTS: slightly lower in RH); observed = 1 if RH < SH | 1 | 1 | 0 | 0 | pass |
| `malformed_sd` | SD cells not of the form d.d | 1 | 0 | 1 | 0 | mismatch |

## Data role

**primary** (the authors' own measurements).

## Species names

`species_as_published` keeps the paper's wording (Papio anubis). No `_keys/`
file was edited; proposals are in `reference_tables/Meguro_etal_1999_species_key_proposed.csv`.

## Compilation comparison (done AFTER the snapshot was frozen)

Compared with `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build_wave2.csv`
only after freezing; no printed value changed. Row-by-row reconstruction:
`primary_items_extract/_compilation_check_wave2_meguro_buchsbaum_noda.csv`; comparison extract `primary_items_extract/meguro_1999.csv`.

Both compilations used the PRE-SURGERY BASELINE column of Table 2; neither used a post-lesion (Day 30/45/80) or sham post-operative arm. They used DIFFERENT groups, which explains their disagreement: Kaufman 2004 (10 rows) pools the baseline of both groups (RH + SH, n = 3 + 3) and converts mg -> µmol (x 5.55). Examples: Thalamus 43.8 = (6.6 + 9.2)/2 = 7.9 mg; Frontal 50.4 = 4 prefrontal cells; Hippocampus 30.8 = anterior + posterior; Basal ganglia 47.7 = caudate (ant, post) + putamen; Cerebellum 35.2. Occipital 31.6 and Temporal 43.5 reproduce only if each group is converted and rounded before pooling (0.1 above the pooled value). Kaufman S.D.s match the mean group S.D. for 4 regions but not for 6 (e.g. Thalamus 9.4 vs 9.16). Compilation error: Kaufman gives n = 8. Table 2 has n = 3 per group (6 pooled); the 8-baboon 'analysis I' baseline values are not tabulated. Karbowski 2007 (14 single-source rows) uses the SH (sham) BASELINE only, n = 3, converted. Examples: Thalamus 0.51 ± 0.16 = 9.2 ± 2.9 mg; Prefrontal 0.52 ± 0.14; Temporal 0.47 ± 0.14; Hippocampus 0.32 ± 0.07; Caudate 0.41 ± 0.08 = anterior caudate SH. Cingulate S.D. 0.17 is not reproducible; Neocortex 0.46 is ambiguous. Whole brain 0.44 µmol/g/min and 60.40 µmol/min are not printed in the paper. Because the RH baseline happens to be lower than the SH baseline in most regions (Thalamus 6.6 vs 9.2), Karbowski's values exceed Kaufman's by 4-16% in 6 regions (Thalamus 51 vs 43.8 = +16%; Temporal, Parietal, Sensorimotor, Occipital, Hippocampus) and are 9% LOWER for Cerebellum (ratio 0.909). The disagreement is an arm choice, not a transcription slip. Both are legitimate pre-lesion values; the pooled RH + SH baseline (n = 6) is the better-sampled one.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Meguro_etal_1999_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Meguro_etal_1999-E001 | dispersion_numeric | Table 2 p. 1525, row 'Anterior cingulate' SH, column 'Day 30 mean (SD)' | 11.8 (4.) |  | publication_error |  | proposed | The SD prints as "(4.)" with no digit after the decimal point; every other SD in the table prints one decimal. Re-read at 280 dpi; the text layer agrees ("11.8 (4.)"). | dispersion_printed kept as "4."; dispersion_numeric set to NA. |
| Meguro_etal_1999-E002 | value_numeric | Table 2 p. 1525, row 'Basal forebrain' RH, columns 'Day 45' and 'Day 80' | 6.3 (1.5); 6.3 (1.5) |  | publication_ambiguity |  | proposed | RH prints the identical cell "6.3 (1.5)" at Day 45 and Day 80 (a possible duplicated cell), and RH exceeds SH at both (SH 5.7 and 6.2), whereas RESULTS states the RH means were lower than SH "postoperatively, whatever the time point and region considered". These are the only 2 of 57 post-operative region x time cells with RH >= SH. | Detected by table_checks rh_lower_postop. Kept as printed. |

2 recorded, 2 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
