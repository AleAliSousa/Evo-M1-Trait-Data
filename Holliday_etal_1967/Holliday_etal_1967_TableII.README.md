# Holliday_etal_1967_TableII

**Item name** `Holliday_etal_1967_TableII` · **Item number** `Table II` · **Item encoded** `10.1203%2F00006450-196705000-00005_TableII` — *derived, awaiting registration*
( Paste `Holliday_etal_1967_TableII_registry_row.xlsx`, run `_tools/file_list.R`, rename the TSV if the registry differs.)

Holliday, M. A., Potter, D., Jarrah, A., & Bearg, S. (1967). The relation of metabolic rate to body weight and organ size. *Pediatric Research*, 1(3), 185-195. <https://doi.org/10.1203/00006450-196705000-00005>

**Item full original title:** Table II. Organ metabolic rate, OMR, cal/day compared to whole body BMR for a 10 kg infant and a 70 kg adult, p. 189.

## Source

PDF in this folder: `Holliday_etal_1967.pdf` (copied from `References.Data/PDF/0374138644/`; 11 pages, image only). Table I (BMR/kg of 16 species, p. 187), Table IV (rat kidney QO2) and the figures are not built; Table III is the sibling item `Holliday_etal_1967_TableIII`.

## Pipeline

```
Source (PDF)
  -> Holliday_etal_1967_extract_snapshot.R   writes the frozen snapshot(s)
  -> Holliday_etal_1967_TableII_snapshot.csv   FROZEN: 11 rows x 9 cols
  -> Holliday_etal_1967_TableII.R   clean + convert units + table checks
  -> Holliday_etal_1967_TableII.csv   14 rows x 23 cols  ("use this")
  -> __Public/comparative-data/10.1203%2F00006450-196705000-00005_TableII.tsv
  -> reference_tables/Holliday_etal_1967_TableII_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (method 5) by an AI assistant (Claude) on 2026-11-03 from 170/350-dpi renders of PDF page 5 (journal p. 189), typed as a verbatim printed-layout block into `Holliday_etal_1967_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The PDF is a scanned reprint with **no text layer** (0 characters on all 11 pages), so there is no machine second reading; instead every cell was re-read against the page image and against the earlier working transcription (`holliday_1967_table3_transcribed.csv`, `classic_human_brain_partition.csv`): no cell differs. The build script reads the frozen file, contains no table values, and was run with `Rscript` (conda env `r`) on 2026-11-03.

### Snapshot and analysis CSV

* One snapshot row per printed row (caption; spanning header *10 kg infant* / *70 kg adult*; column header; 5 organ rows; gap; two total rows). Values as printed: leading-point decimals (.92, .3), parenthesised estimate (200), lung weight `12`.
* The analysis CSV is **long**: one row per printed row and age group (organs, *Total derived from 5 organs*, *Total BMR*) = 14 rows. The printed `[21]` etc. is split into `ref_key`.
* Units: the printed "cal" are kilocalories (text: BMR 25 cal/kg/day). Organ rate converted to mL O2/100 g/min at the paper's own factor 4.9 kcal/L O2 (÷ 70.56) and to µmol (x 44.64): brain 260 kcal/kg/day = 3.685 mL/100 g/min = 164.5 µmol/100 g/min (the paper rounds to 3.7 mL/100 g/min).
* **Observation level**: reference values for a hypothetical 10 kg infant / 70 kg adult, not measurements.


## Table checks

Result of an actual R run (2026-11-03, `Rscript`, conda env `r`): **26 pass, 4 mismatch, 0 not evaluable**, of 30 checks. Rule: rounding of each printed factor (half a unit of its last printed decimal) or, for a percentage recomputed from a printed total, one unit of its last decimal (HOWTO 7a). Every mismatch is kept as printed and explained below; nothing was changed to make a check pass.

Not-pass checks (the passing checks are in the table_checks object of the build and listed by `build_dataset_item()`):

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `OMR_inf_5` | 10 kg infant, Lung (estimated): rate x weight vs printed OMR cal/organ/day | 2400 | 24 | 2376 | 106.5 | mismatch |
| `sum_weight_inf` | 10 kg infant: sum of the 5 organ weights (kg) vs printed total | 13.34 | 1.46 | 11.88 | 0.525 | mismatch |
| `BMR_per_kg_inf` | 10 kg infant: total BMR / body mass vs text p. 188 (adult 25, infant 56 cal/kg/day) | 54 | 56 | -2 | 0.5 | mismatch |
| `pct_total_adu` | 70 kg adult: 100 x printed total derived OMR / total BMR vs printed total % | 77.809 | 79 | -1.19101 | 1 | mismatch |

## Printed-vs-recomputed discrepancies

1. **Infant lung weight printed `12` (kg)**: the five weights add to the printed 1.46 kg only if it is .12, and 200 x .12 = 24 = the printed OMR. Decimal point lost in print (erratum `Holliday_etal_1967-E001`). Kept as printed; the check `sum_weight_inf` (13.34 vs 1.46) and `OMR_inf_5` (2400 vs 24) flag it.
2. **Adult total %**: printed 79 (= sum of the printed organ %: 21 + 10 + 7 + 32 + 9) but 1385/1780 = 77.8% (E002). The infant total, 427/540 = 79.1%, is consistent.
3. **Infant BMR/kg**: 540 cal / 10 kg = 54 cal/kg/day, the text p. 188 says 56 (E003). The adult 1780/70 = 25.4 agrees with the text's 25.
4. Within rounding (pass): brain infant 260 x .92 = 239.2 (printed 240); brain adult 260 x 1.4 = 364 (printed 365); infant brain 44.4% (printed 45); liver adult 31.5% (printed 32).

## Data role

**secondary** (each rate is a literature value attributed to a cited primary; the lung rate is an estimate). Not merged as a primary: the brain row is a re-use of Kety & Schmidt 1948 [21].

## Species names

`species_as_published` keeps the printed label. Rows for this paper folder were appended to `_keys/General/species_key.csv` (collection General; 2026-11-03, pending owner sign-off) and the build stops if the key returns no rows for the folder. The table names no species; `human` is inferred ("10 kg infant", "70 kg adult"; text: BMR of man).

## Per-row source citations

`reference_tables/Holliday_etal_1967_TableII_references.csv`: `[21]` Kety & Schmidt 1948 (brain), `[39]` Rowe et al. 1959 (heart), `[11]` Crosley et al. 1961 (kidney), `[6]` Brauer 1963 (liver/splanchnic); lung has no reference ("estimated"). Verbatim entries are from the paper's reference list (p. 194). Bind by splitting `ref_key` on `"; "` and joining on `ref_key`. The primaries were **not** checked here; they are a roadmap, never to be re-ingested as if primary.

## Compilation comparison (done AFTER the snapshot was frozen)

The working transcriptions and the cross-source comparison live in `Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations/` (`CLASSIC_COMPILATIONS_FINDINGS.md`); they were compared with this snapshot only after it was frozen, and no printed value was changed. The merged `__merging_cerebral_metabolic_rate` was not modified. The brain row (260 kcal/kg/day, 1.4 kg, 365 kcal/day, 21%) matches `classic_human_brain_partition.csv` (which prints 1,780 kcal/day for total BMR and 21% share).

## Human visual check of snapshot

Pending human RA (record `DDMMYYYY_initials` in `__ReadMe.xlsx`).

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Holliday_etal_1967_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Holliday_etal_1967-E001 | weight_kg | Table II p. 189, row Lung (estimated), 10 kg infant, column Weight (kg) | 12 |  | publication_error | .12 | proposed | The five infant weights add to the printed total 1.46 kg only if the lung weight is .12 (.92 + .05 + .07 + .30 + .12); rate x weight (200 x .12 = 24) reproduces the printed 24 cal/organ/day. Page image re-read at 350 dpi: no decimal point. | Decimal point lost in print. Kept as printed ("12"); the table check sum_weight_inf and OMR_inf_5 flag it. |
| Holliday_etal_1967-E002 | pct_BMR | Table II p. 189, row Total derived from 5 organs, 70 kg adult, column % | 79 |  | publication_ambiguity |  | proposed | 1385/1780 = 77.8%; the printed 79 equals the sum of the five printed organ % (21 + 10 + 7 + 32 + 9), each rounded up (liver 31.5 -> 32, kidney 6.7 -> 7, brain 20.5 -> 21). The text p. 188 repeats "79% in the adult". | Kept as printed. The infant total 427/540 = 79.1% is consistent. |
| Holliday_etal_1967-E003 | OMR_kcal_day | Table II p. 189, row Total BMR, 10 kg infant, column OMR total | 540 |  | publication_ambiguity |  | proposed | 540/10 kg = 54 cal/kg/day, whereas the text p. 188 says "56 cal/kg/day in infants" (and 25 in adults, which 1780/70 = 25.4 confirms). | Cross-statement inconsistency (table vs text), neither known to be wrong. Kept as printed. |

3 recorded, 3 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
