# Poulsen_etal_1997_Table2

**Item name** `Poulsen_etal_1997_Table2` · **Item number** `Table 2` · **Item encoded**
`10.1016%2FS0165-0270(97)00127-1_Table2` — *derived, awaiting registration* (not yet in
`__ReadMe.xlsx`; the code is what the registry formula builds from the DOI and `Item number`). Until the
owner pastes `Poulsen_etal_1997_Table2_registry_row.xlsx` the build writes only the analysis CSV and
prints `not yet registered - TSV skipped`.

Poulsen, P. H., Smith, D. F., Østergaard, L., Danielsen, E. H., Gee, A., Hansen, S. B., Astrup, J., &
Gjedde, A. (1997). In vivo estimation of cerebral blood flow, oxygen consumption and glucose metabolism
in the pig by [15O]water injection, [15O]oxygen inhalation and dual injections of
[18F]fluorodeoxyglucose. *Journal of Neuroscience Methods*, 77(2), 199–209.
<https://doi.org/10.1016/S0165-0270(97)00127-1> (DOI verified on Crossref 2026-11-11.)

**Item full original title:** Table 2. Blood flow and metabolism: average (standard deviation in brackets (n = 7)) (p. 205).

## Source

`Poulsen-1997-In vivo estimation of cerebral bl.pdf` in this folder (copied from
`_other_sources_metab_correlates_candidates/`). The PDF text layer interleaves Table 2's headers with
its cells and renders "±" as "9"; nothing was taken from it.

## Pipeline

```
Source (PDF p. 205; Abstract p. 199; Results pp. 203-206)
  -> Poulsen_etal_1997_Table2_snapshot.R    writes the frozen snapshot (refuses to overwrite a differing copy)
  -> Poulsen_etal_1997_Table2_snapshot.csv   FROZEN: 6 rows x 6 cols
  -> reference_tables/Poulsen_etal_1997_data_from_text_snapshot.csv   FROZEN, constructed: 28 prose values
  -> Poulsen_etal_1997_Table2.R              fold the two printed Hemisphere lines, split cells, table checks
  -> Poulsen_etal_1997_Table2.csv            2 rows x 22 cols ("use this")
  -> __Public/comparative-data/10.1016%2FS0165-0270(97)00127-1_Table2.tsv   (after registration only)
  -> reference_tables/Poulsen_etal_1997_Table2_definitions.csv
```

Build order: the snapshot scripts first (`Poulsen_etal_1997_Table1_snapshot.R`, `Poulsen_etal_1997_Table2_snapshot.R`, `Poulsen_etal_1997_data_from_text_snapshot.R`, one frozen file each); `Poulsen_etal_1997_Table2.R`
also reads the Table 1 snapshot (arterial O2) and the data-from-text snapshot for its checks.

## Who read the values, when, and how it was checked

**Hand transcription** (snapshot HOWTO method 5) by an AI assistant (Claude) on 2026-11-11 from
300/400-dpi renders of PDF page 7 (Table 2) and 250/220-dpi renders of pages 1, 2, 5, 7 and 8 (the prose
values), typed as verbatim printed-layout blocks into `Poulsen_etal_1997_Table2_snapshot.R` (the prose values: `Poulsen_etal_1997_data_from_text_snapshot.R`). Each
printed row was read across. Three independent checks:

1. **Restatements.** The Abstract and Results 3.1–3.3 restate every Hemisphere cell; the build compares
   them one by one (below). 24 of 25 restatements agree exactly.
2. **Staged cross-check.** The earlier-session extraction `s5_cross_species_extracted_values.csv` agrees
   on every Table 2 mean and SD it carries (9 cells: Hemisphere CBF, CMRO2 and the four CMRglc cells;
   Basal Ganglia CBF, CMRO2, CMRglc; it was used only as a cross-check; the PDF is the authority).
3. **Compilation reprint** (Kaufman 2004, below) — compared only after the snapshot was frozen.

The build script reads the frozen files and contains no table values; it was run with
`Rscript --vanilla` (conda env `evom1-r`, R 4.4.3) from a clean session on 2026-11-11.

### Structure of the snapshot

* One snapshot row per printed line: rows 1–2 title and caption, row 3 the headers (first header cell
  blank as printed), rows 4–5 **Hemisphere** (two printed lines), row 6 **Basal Ganglia**.
* The `(1st) CMRglc` cells carry their printed labels (`Multilinear:`, `Graphical:`). The `(2nd) CMRglc`
  cells are **unlabelled in the print**; the build assigns line 1 = multilinear, line 2 = graphical, and
  the Abstract ("27 ± 3 and 24 ± 3 … multilinear and linear regression analysis, respectively") and
  Results 3.3 confirm it (checks pass).
* Blank cells are kept blank: Basal Ganglia prints no graphical, no session-2 CMRglc and no PaCO2.

## What the data are

Two ROIs × one cohort of **7 anaesthetised, ventilated pigs** (Table 1 animals): **Hemisphere** (the
average of the separate-hemisphere ROIs; grey and white matter not separable at 9.45 mm FWHM; PET
co-registered to a T1 MR image of *a* pig brain; whether cerebellum/brainstem are included is not
stated — a cerebral-hemisphere value, **not** whole brain) and **Basal Ganglia** (nuclei not specified).
Mean (SD) of:

* **CBF** — [15O]water bolus, CBF = 100 × K1 (water clearance), **ml/100 cm³/min**;
* **CMRO2** — single-breath [15O]O2, multilinear one-compartment fit, **µmol/100 cm³/min**;
* **CMRglc** — FDG double injection, sessions 1 (45 min) and 2 (30 min), multilinear and graphical
  (Patlak-Gjedde) analysis, lumped constant estimated per animal (0.45, 0.42), **µmol/100 cm³/min**.
  The authors prefer multilinear; graphical underestimates by ~13%.
* **PaCO2** 4.3 (0.9) kPa ("moderately hyperventilated").

**Units: per 100 cm³ of tissue volume, not per 100 g.** Kept as printed in the CSV (column names carry
`100cm3`); no density conversion is applied. A per-100 g user must state a density (1 g/cm³ leaves the
numbers unchanged; ~1.04 g/cm³ lowers them ~4%). The paper's own O2 factor is 1 ml O2 = 44.64 µmol
(STPD, p. 206).

**Anaesthesia.** Midazolam + ketamine (~9 mg/kg/h) + pancuronium infusion after i.m. midazolam/ketamine
sedation; mechanically ventilated (30% O2), 12 h fasted, rectal temperature 39.2 °C. The authors note
ketamine can raise CMRO2 and that the single-breath method "may overestimate oxygen consumption
slightly" (p. 207).

**Context values printed only in prose** (OEF 0.46 ± 0.09, range 0.32–0.62; oxygen-glucose ratio
6.1 ± 0.8; lumped constants; CMRO2 range 157–205; body weight 40 ± 2 kg; CO2 reactivity 8.9 ml/100 cm³
/min/kPa in two pigs) are in `reference_tables/Poulsen_etal_1997_data_from_text_snapshot.csv`, one row per
printed value with the passage quoted (sub/superscripts flattened; en dashes as hyphens).

**Brain size.** No brain mass or volume is reported, so these per-volume rates cannot be turned into
whole-brain rates from this paper. Pig brain masses exist in `__merging_brain_mass/brain_mass_long.csv`
(*Sus scrofa* 112 g measured; *Sus scrofa domesticus* 137.65 g, Lewitus, secondary; 62.57 g excluding
olfactory bulb) — mentioned only, **not merged**; none is from 40 kg Yorkshire landrace pigs.

## Table checks

Result of an actual R run (2026-11-11): **29 pass, 3 mismatch, 0 not evaluable, of 32 checks**
(`table_checks` in `Poulsen_etal_1997_Table2.R`).

* **25 restatements** (tolerance 0): every Hemisphere mean/SD against the Abstract (text rows 2, 5, 6,
  8–11) and Results 3.1–3.3 (rows 17, 20, 21, 25–27). **One mismatch:** CBF SD — Table 2 `37 (4)`, Abstract
  `37 ± 3` → errata E001.
* **6 range checks** (Samuelson bound: no one of n = 7 animals can lie more than SD × 6/√7 from the
  mean; ±0.5 printed unit). CMRO2 157–205 passes (bound 130–212); the Abstract's CBF 33–41 passes
  (bound 27.9–46.1); **Results 3.2's CBF maximum 54 fails** → errata E002.
* **1 Fick check:** OEF = CMRO2 / (CBF × CaO2) = 171 / (37 × 5.7) = **0.81** vs printed **0.46**
  (tolerance 0.025 from rounding) → **mismatch**, errata E003. The paper's own K1 values give the same
  0.8 (O2 0.31 vs water 0.39 ml/cm³/min).

| check | observed | printed | difference | tolerance |
|---|---|---|---|---|
| `CBF_sd_text5` | 4 | 3 | 1 | 0 |
| `CBF_range_max_text19` | 46.07 (bound) | 54 | −7.93 | 0.5 |
| `OEF_fick_text12` | 0.811 | 0.46 | 0.351 | 0.025 |

The printed values are kept everywhere (snapshot, CSV). Not a check, for information: the ratio of
the printed means CMRO2 / CMRglc(session 1, multilinear) is 171/27 = 6.3, against the printed mean
oxygen-glucose ratio 6.1 ± 0.8 — consistent, since a mean of ratios need not equal a ratio of means.

## Data role

**primary** — the authors' own PET measurements.

## Species names

`species_as_published` = `pig`, `breed_as_published` = `Danish Yorkshire land race` (title, Methods;
the table prints no species). **No `_keys/` file was edited.** Proposed row in
`reference_tables/Poulsen_etal_1997_species_key_proposed.csv` (`pig` → *Sus scrofa domesticus*, NCBI
9825). The merge currently carries this study as *Sus scrofa* (9823) via Kaufman's printed `Sus`.

## Compilation comparison (done AFTER the snapshot was frozen)

Kaufman (2004) Table A14 row 121 of `Kaufman__2004/Kaufman__2004_TableA14_snapshot.csv` reprints this
paper as `Sus`, `(Poulsen et al., 1997)`, n 7, `Ketamine, Midazolam`, PET, "Whole Brain (direct
measurement)": CMRgl **25.25 ± 3.00**, CMRO2 **171.00 ± 18.00**, CBF **37.00 ± 3.00** (read from the
Kaufman snapshot; the Kaufman PDF was not re-read here).

* CMRO2 171 ± 18 = Table 2 exactly.
* CMRgl 25.25 is not a printed value: it is the mean of the four Hemisphere CMRglc cells
  (27 + 23 + 27 + 24)/4, i.e. Kaufman averages two sessions and two analysis methods, including the
  graphical estimates the authors say underestimate by ~13%; the session-1 multilinear value is 27 (3).
* CBF SD 3.00 follows the Abstract, not Table 2's (4) — see E001.
* Kaufman relabels the cerebral-hemisphere ROI as whole brain and the per-100 cm³ units as per 100 g.

These are compilation-side observations; no errata row was written into `Kaufman__2004/` (outside this
item's folder) — the owner may want to add a `cross_source_disagreement` there.

## Suitability as a primary input to `__merging_cerebral_metabolic_rate`

Assessed against `__merging_cerebral_metabolic_rate/README__merging.md` ("Primary-item extension"):

* **Suitable as a primary item for provenance, not for the conservative pool.** Rule 1 admits only
  conscious, non-anaesthetised control arms; these pigs were anaesthetised (midazolam + ketamine) and
  ventilated, so the item falls under rule 4 (anaesthetised primaries are provenance only), like
  `Nilsson_Siesjö_1976` or `Meguro_etal_1999`. The study's Kaufman reprint is likewise already
  `anesthetized` and outside the pool.
* As a primary item it would govern Kaufman's reprint (rule 3, dedupe priority 0): it gives the
  printed session/method-specific CMRglc instead of Kaufman's 25.25 average, the Table 2 CBF SD, and the
  correct ROI label.
* Region mapping (rule 2): **Basal Ganglia → `Basal_ganglia`** is one-to-one; **Hemisphere has no
  canonical region** (it is not whole brain) and would stay in provenance under any mapping.
* Units: per 100 cm³; the merge standard is per 100 g, so ingestion needs an explicit density decision.
* Ingestion goes through the restricted-repo `primary_item_ingestion_manifest.csv` builder; nothing in
  the merge folder was edited.

## Audit and validation (2026-11-11, actual R run)

`audit_dataset_item()` on the paper folder: snapshot, csv, readme, definitions all **PASS**, orphan_tsv
**PASS** (no TSV in the folder). `validate_dataset_item()`: csv, readme, definitions, frozen_source and
errata_file_valid **PASS**; **registry_row FAIL** and **tsv FAIL** (expected: the item is not yet in
`__ReadMe.xlsx`, so no public TSV is written); tsv_name_match and no_trailing_underscore **SKIP** (no
`Item encoded` yet). `build_dataset_item()` stops with "not found in registry" for the same reason.
All four will pass once the owner pastes the registry row, runs `_tools/file_list.R` and re-runs the
build script.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside p. 205, read the Hemisphere (two
lines) and Basal Ganglia rows **across**, and record `DDMMYYYY_initials` in the `Human visual check of
snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Poulsen_etal_1997_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Poulsen_etal_1997-E001 | CBF_SD.ml_100cm3_min | Table 2, p. 205, row 'Hemisphere', column 'CBF (ml/100 cm^3/min)'; vs Abstract, p. 199 | 37 (4) |  | publication_ambiguity |  | proposed | Table 2 prints the hemispheric CBF as '37 (4)' (mean, SD). The Abstract restates it as 'an average of 37 ± 3 ml/100 cm^3/min'. Both read on 300/250-dpi page renders; unambiguous. Every other Table 2 value the Abstract or Results restate agrees exactly (Table 2 table_checks: 29 of 32 pass). Cannot tell from the paper which SD is right; Results 3.2 gives the mean only. | CSV keeps the Table 2 value (4). Kaufman (2004) Table A14 reprints this row as 37.00 ± 3.00, i.e. the Abstract SD (Kaufman__2004_TableA14_snapshot.csv row 121; not re-read against the Kaufman PDF here). |
| Poulsen_etal_1997-E002 | CBF.ml_100cm3_min | Results 3.2 CBF, p. 205, left column: 'The CBF estimates ranged from 33 to 54 ml/100 cm^3/min'; vs Abstract, p. 199: 'varied between 33 and 41' | 33 to 54 |  | publication_ambiguity |  | proposed | With the printed hemispheric mean 37, SD 4 and n = 7, no single animal can exceed 37 + 4 x 6/sqrt(7) = 46.1 (Samuelson inequality; 43.8 with the Abstract SD 3). The 54 of Results 3.2 is therefore impossible as an individual HEMISPHERIC value; the Abstract's 'Individual hemispheric CBF measurements varied between 33 and 41' is consistent (table_checks CBF_range_max_text4 pass, CBF_range_max_text19 mismatch). The 3.2 range may pool the Basal Ganglia ROI (45 (7), bound 61), or 54 may be a misprint of 41. | Affects no CSV cell (the ranges are prose, held in reference_tables/Poulsen_etal_1997_data_from_text_snapshot.csv rows 3-4 and 18-19). Recorded so the hemispheric range is not taken from Results 3.2. |
| Poulsen_etal_1997-E003 | CMRO2.umol_100cm3_min | Table 2, p. 205, row 'Hemisphere' (CBF 37, CMRO2 171) with Table 1, p. 203, 'O2 (mM)' 5.7; vs OEF 0.46 ± 0.09 (Abstract p. 199; Results 3.2 p. 205) | 171 (18) |  | publication_ambiguity |  | proposed | Fick: OEF = CMRO2 / (CBF x CaO2) = 171 / (37 x 5.7) = 0.81 (ml/100 cm^3/min x mM = µmol/100 cm^3/min), against the printed average OEF of 0.46 (range 0.32-0.62). Rounding of the printed cohort means allows +/- 0.03; a ratio of means vs a mean of ratios cannot bridge 0.81 vs 0.46 with CVs of ~10%. Equivalently, the paper's own K1 values (O2: 0.31 ml/cm^3/min, Results 3.1; water: 0.39, Results 3.2) give K1(O2)/K1(water) = 0.79. Either the OEF was computed by an unstated different definition, or CMRO2 and/or the water-clearance CBF are biased; the authors themselves say the single-breath method 'may overestimate oxygen consumption slightly' and report a high oxygen-glucose ratio (6.1). | Table 2 table_checks OEF_fick_text12 (mismatch). CSV keeps all printed values. Treat the pig CMRO2 (and OEF) with caution in any O2-based series. |

3 recorded, 3 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
