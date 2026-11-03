# Holliday__1971_TABLEI

**Item name** `Holliday__1971_TABLEI` · **Item number** `TABLE I` · **Item encoded** `PMID%3A5551034_TABLEI` — *derived, awaiting registration*
(The paper has a PMID but its DOI could not be confirmed here; the code is derived from the col-C alternative code `PMID:5551034` (owner to confirm). Paste `Holliday__1971_TABLEI_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Holliday, M. A. (1971). Metabolic rate and organ size during growth from infancy to maturity and during late gestation and early infancy. *Pediatrics*, 47(1, Suppl. 2), 169-179. PMID 5551034.

**Item full original title:** TABLE I. VO2, organ metabolic rate (OMR/kilogram body weight), metabolic rate and percent BMR derived from each organ system in adult man, p. 170.

## Source

PDF in this folder: `holliday_1971.pdf` (copied from `References.Data/PDF/3926934886/`; 11 pages). Table II (height, weight, sum of organ weight and BMR by age) carries no organ rate and is not built.

## Pipeline

```
Source (PDF)
  -> Holliday__1971_extract_snapshot.R   writes the frozen snapshot(s)
  -> Holliday__1971_TABLEI_snapshot.csv   FROZEN: 14 rows x 6 cols
  -> Holliday__1971_TABLEI.R   clean + convert units + table checks
  -> Holliday__1971_TABLEI.csv   8 rows x 24 cols  ("use this")
  -> __Public/comparative-data/PMID%3A5551034_TABLEI.tsv
  -> reference_tables/Holliday__1971_TABLEI_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-03 from 170/330-dpi renders of PDF page 2, typed as a verbatim printed-layout block into `Holliday__1971_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The PDF is a poor scan of a bound volume with a garbled OCR layer (footnote marks lost), so the OCR text was not a usable second reading; every cell was re-read at 330 dpi and against the earlier working transcription (`classic_human_brain_partition.csv`: brain 4.2, 1.40 kg, 23.3%, total BMR 1,780). The Muscle superscript is faint and read as 4. The build script reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row incl. the two footnotes; row numbers `1)`..`5)`, footnote marks `^6 ^7 ^8 ^9 ^4`, asterisk, dagger and em-dashes kept; thousands commas kept.
* The analysis CSV has one row per printed row (4 organs, Total 1-4, Muscle, Total 1-5, 70 kg man); VO2 mL/100 g/min -> µmol (x 44.64): brain 4.2 mL = 187.49 µmol/100 g/min.
* **Observation level**: reference-organ values for a 70 kg man, not measurements.


## Table checks

Result of an actual R run (2026-11-03, `Rscript`, conda env `r`): **21 pass, 4 mismatch, 0 not evaluable**, of 25 checks. Rule: rounding of each printed factor (half a unit of its last printed decimal) or, for a percentage recomputed from a printed total, one unit of its last decimal (HOWTO 7a). Every mismatch is kept as printed and explained below; nothing was changed to make a check pass.

Not-pass checks (the passing checks are in the table_checks object of the build and listed by `build_dataset_item()`):

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `pct_organ_4` | Kidney: 100 x printed OMR / 1,780 vs printed % BMR | 6.51685 | 7.1 | -0.583146 | 0.1 | mismatch |
| `pct_total_organs_1_4_5` | Total 1–4: 100 x printed OMR / 1,780 vs printed % BMR | 66.1236 | 66.7 | -0.576404 | 0.1 | mismatch |
| `sum_pct_1_5` | printed Total 1-4 % + Muscle % vs printed Total 1-5 % | 94.8 | 94.2 | 0.6 | 0.2 | mismatch |
| `rate_70kg_man` | printed 1,780 kcal/day / 70 kg vs printed 25.5 kcal/kg/day | 25.4286 | 25.5 | -0.0714286 | 0.05 | mismatch |

## Printed-vs-recomputed discrepancies

1. **Kidney % BMR**: printed 7.1; 116/1,780 = 6.5% (E001). The printed Total 1-4 % (66.7) carries the 7.1 (23.3 + 26.1 + 10.2 + 7.1) but 1,177/1,780 = 66.1% (E002); and 66.7 + 28.1 = 94.8 whereas the printed Total 1-5 is 94.2 = 1,677/1,780.
2. **70 kg man rate**: printed 25.5 kcal/kg/day; 1,780/70 = 25.4 (E003).
3. **Muscle rate**: printed 17.6; VO2 0.26 x 70.56 = 18.3 (E004; within the loose tolerance, recorded because the gap is 4%).
4. Pass within rounding: the four other organ rates from VO2 (brain 296.4 vs 296, liver 289.3 vs 290, heart 606.8 vs 606, kidney 388.1 vs 388); OMR = rate x weight for every row; Total 1-4 OMR 1,176 (sum) vs 1,177 printed; 1,177/3.60 = 326.9 vs 327.

## Data role

**secondary** (VO2 values are literature values attributed to the cited primaries; weights are standard organ weights). Not merged as a primary; the brain row is NOT an independent measurement.

## Species names

`species_as_published` keeps the printed label. Rows for this paper folder were appended to `_keys/General/species_key.csv` (collection General; 2026-11-03, pending owner sign-off) and the build stops if the key returns no rows for the folder. Printed "Man" (caption "in Adult Man").

## Per-row source citations

`reference_tables/Holliday__1971_TABLEI_references.csv`: superscripts 6 (Kennedy & Sokoloff 1957, brain), 7 (Brauer 1963, liver), 8 (Rowe et al. 1959, heart), 9 (Crosley et al. 1961, kidney), 4 (Andres et al. 1956, muscle) and 10 (Peters & Van Slyke 1946, the 4.9 kcal/L factor). Note: ref 6 is a study in children although the caption says adult man; the 1967 paper cites Kety & Schmidt 1948 for the brain. The primaries were not checked here.

## Compilation comparison (done AFTER the snapshot was frozen)

The working transcriptions and the cross-source comparison live in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (`CLASSIC_COMPILATIONS_FINDINGS.md`); they were compared with this snapshot only after it was frozen, and no printed value was changed. The merged `__merging_cerebral_metabolic_rate` was not modified. The 4.2 mL/100 g/min brain rate (23.3% of BMR) is the Holliday 1971 entry of `classic_human_brain_partition.csv`; its note there ("text cites Kennedy & Sokoloff adults 4.18") could not be re-verified: the primary is not in the project PDFs.

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Holliday__1971_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Holliday__1971-E001 | pct_BMR | TABLE I p. 170, row 4) Kidney, column % BMR | 7.1 |  | publication_error | 6.5 | proposed | 116 kcal/day / 1,780 kcal/day = 6.5%. The printed Total 1-4 % (66.7) is the sum of the printed organ % including 7.1 (23.3 + 26.1 + 10.2 + 7.1), but 66.7 + 28.1 (muscle) = 94.8 whereas the printed Total 1-5 is 94.2 = 1,677/1,780. | Kept as printed. With 6.5 the Total 1-4 % would be 66.1 (= 1,177/1,780). |
| Holliday__1971-E002 | pct_BMR | TABLE I p. 170, row Total 1-4, column % BMR | 66.7 |  | publication_error | 66.1 | proposed | 1,177/1,780 = 66.1%; follows from the kidney % (erratum E001). | Kept as printed. |
| Holliday__1971-E003 | rate_kcal_kg_OW_day | TABLE I p. 170, row 70 kg man, column Metabolic Rate | 25.5 |  | publication_error | 25.4 | proposed | 1,780 kcal/day / 70 kg = 25.43. | Difference 0.07; the text elsewhere uses 25 cal/kg/day. |
| Holliday__1971-E004 | rate_kcal_kg_OW_day | TABLE I p. 170, row 5) Muscle, column Metabolic Rate | 17.6 |  | publication_ambiguity |  | proposed | Footnote dagger: rate = VO2 x 10 x 1,440/1,000 x 4.9 = VO2 x 70.56; for VO2 0.26 this gives 18.3, whereas 17.6 corresponds to VO2 0.249. The OMR 500 = 17.6 x 28.3 follows the printed rate. | Within the tolerance of the printed 0.26 (half unit x 70.56 = 0.35) + 0.5 only because of the generous rule; recorded because the gap is 4%. Kept as printed. |

4 recorded, 4 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
