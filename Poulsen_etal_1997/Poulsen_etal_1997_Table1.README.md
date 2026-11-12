# Poulsen_etal_1997_Table1

**Item name** `Poulsen_etal_1997_Table1` · **Item number** `Table 1` · **Item encoded**
`10.1016%2FS0165-0270(97)00127-1_Table1` — *derived, awaiting registration* (the item is not yet in
`__ReadMe.xlsx`; the code is what the registry formula builds from the DOI and `Item number`). Until the
owner pastes `Poulsen_etal_1997_Table1_registry_row.xlsx` the build writes only the analysis CSV and
prints `not yet registered - TSV skipped`; once registered it writes
`__Public/comparative-data/<Item encoded>.tsv`.

Poulsen, P. H., Smith, D. F., Østergaard, L., Danielsen, E. H., Gee, A., Hansen, S. B., Astrup, J., &
Gjedde, A. (1997). In vivo estimation of cerebral blood flow, oxygen consumption and glucose metabolism
in the pig by [15O]water injection, [15O]oxygen inhalation and dual injections of
[18F]fluorodeoxyglucose. *Journal of Neuroscience Methods*, 77(2), 199–209.
<https://doi.org/10.1016/S0165-0270(97)00127-1> (DOI verified on Crossref 2026-11-11.)

**Item full original title:** Table 1. Physiological variables: average (standard deviation in brackets (n = 7)) (p. 203).

## Source

`Poulsen-1997-In vivo estimation of cerebral bl.pdf` in this folder, COPIED (not moved) from
`_other_sources_metab_correlates_candidates/`. A typeset 1997 Elsevier PDF with a text layer that is
**not usable for the tables**: it scrambles Table 1's column order and renders every "±" as "9".

## Pipeline

```
Source (PDF p. 203)
  -> Poulsen_etal_1997_Table1_snapshot.R    writes the frozen snapshot (refuses to overwrite a differing copy)
  -> Poulsen_etal_1997_Table1_snapshot.csv   FROZEN: 5 rows x 8 cols (title, caption, headers, values, footnote)
  -> Poulsen_etal_1997_Table1.R              split "mean (SD)", add cohort context
  -> Poulsen_etal_1997_Table1.csv            1 row x 23 cols ("use this")
  -> __Public/comparative-data/10.1016%2FS0165-0270(97)00127-1_Table1.tsv   (after registration only)
  -> reference_tables/Poulsen_etal_1997_Table1_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (snapshot HOWTO method 5) by an AI assistant (Claude) on 2026-11-11 from a
300-dpi and a 400-dpi render of PDF page 5, typed as a verbatim printed-layout block into
`Poulsen_etal_1997_Table1_snapshot.R`. The eight cells were read across the single printed row and
re-read against the render; the staged extraction `s5_cross_species_extracted_values.csv` (earlier
session) agrees for the one Table 1 value it carries (Pglc 7.8 (2.6)). The build script reads the
frozen file and contains no table values; it was run with `Rscript --vanilla` (conda env `evom1-r`,
R 4.4.3) from a clean session on 2026-11-11.

Snapshot notation: sub/superscripts flattened (`PaO2`, `Tp`, `Pglc`, `min^-1`); the table's own
`mean (SD)` notation kept verbatim; the abbreviation footnote is the last row.

## What the data are

One cohort of **7 young pigs (Danish Yorkshire land race), body weight 40 ± 2 kg** (Methods p. 200;
age and sex not reported), all normal — there is no disease or treatment group, so the whole cohort is
the control. Values are **mean (SD)** of the physiological variables recorded during the PET studies:
arterial haemoglobin, pH, mean arterial blood pressure, heart rate, PaO2, arterial O2 concentration
(**calculated**, Eq. 5, not measured), rectal temperature and plasma glucose. Units are as printed
(mM, kPa, mmHg, min⁻¹, °C); no project-unit conversion applies. The observation level is a cohort mean
(definitions `Method:observation_level`).

**Anaesthesia.** Sedation with i.m. midazolam + ketamine, induction with i.v. midazolam, maintenance by
continuous infusion of midazolam + ketamine (~9 mg/kg/h ketamine) + pancuronium; intubated and
mechanically ventilated with 30% O2 / 70% air; 12 h fasted; heating blanket at 39 °C. The cerebral
measurements of the sibling item `Poulsen_etal_1997_Table2` were made in these animals at PaCO2 4.3 kPa.

**Brain size.** No brain mass or volume is reported. Species-level pig brain masses exist in
`__merging_brain_mass/brain_mass_long.csv` (e.g. *Sus scrofa* 112 g measured; *Sus scrofa domesticus*
137.65 g, Lewitus, secondary) — mentioned only, not merged here.

## Table checks

Table 1 prints no totals and no internal relation, so there is nothing to check inside it. Its arterial
O2 (5.7 mM) is used by the Table 2 OEF check (see `Poulsen_etal_1997_Table2.README.md`).

## Data role

**primary** — the authors' own measurements in their own animals.

## Species names

The table prints no species. `species_as_published` = `pig` (title, Methods), `breed_as_published` =
`Danish Yorkshire land race`. **No `_keys/` file was edited.** Proposed row (`pig` → *Sus scrofa
domesticus*, NCBI 9825, verified by esummary 2026-11-11) in
`reference_tables/Poulsen_etal_1997_species_key_proposed.csv`. Note that Kaufman 2004 prints these
animals as `Sus` and the cerebral-metabolic-rate merge resolves that to *Sus scrofa* (9823).

## Suitability for `__merging_cerebral_metabolic_rate`

Not a metabolic-rate item: Table 1 is physiological context for Table 2 and has no place in that merge.
See the Table 2 README for the Table 2 assessment.

## Audit and validation (2026-11-11, actual R run)

`audit_dataset_item()` on the paper folder: snapshot, csv, readme, definitions all **PASS**, orphan_tsv
**PASS** (no TSV in the folder). `validate_dataset_item()`: csv, readme, definitions, frozen_source and
errata_file_valid **PASS**; **registry_row FAIL** and **tsv FAIL** (expected: the item is not yet in
`__ReadMe.xlsx`, so no public TSV is written); tsv_name_match and no_trailing_underscore **SKIP** (no
`Item encoded` yet). `build_dataset_item()` stops with "not found in registry" for the same reason.
All four will pass once the owner pastes the registry row, runs `_tools/file_list.R` and re-runs the
build script.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside p. 203, read the value row
**across**, and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.
