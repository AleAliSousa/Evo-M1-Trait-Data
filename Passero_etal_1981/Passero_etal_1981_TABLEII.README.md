# Passero_etal_1981_TABLEII

**Item name** `Passero_etal_1981_TABLEII` · **Item number** `TABLE II` · **Item encoded** `10.1016%2F0304-3940(81)90228-7_TABLEII` — *derived, awaiting registration*
(the item is not yet in `__ReadMe.xlsx`; the code was derived as the registry formula would build it,
DOI with `/` percent-encoded + `_` + item locus, the Mink_etal_1981 convention. Paste
`Passero_etal_1981_TABLEII_registry_row.xlsx`, run `_tools/file_list.R`, and rename the TSV if the registry resolves a different code.)

Passero, S., Carli, G., & Battistini, N. (1981). Depression of cerebral glucose utilization during animal hypnosis in the rabbit. *Neuroscience Letters*, 21(3), 345-349. <https://doi.org/10.1016/0304-3940(81)90228-7>

**Item full original title:** TABLE II. Local cerebral glucose utilization (µmol/100 g/min), p. 348.

## Source

PDF in this folder: `Passero-1981-Depression of cerebral glucose ut.pdf`, MOVED here from `cereb metabol refs/`.

## Pipeline

```
Source (PDF)
  -> Passero_etal_1981_extract_snapshot.R   writes the frozen snapshot(s)
  -> Passero_etal_1981_TABLEII_snapshot.csv   FROZEN: 26 rows x 4 cols
  -> Passero_etal_1981_TABLEII.R   clean + parse + table checks
  -> Passero_etal_1981_TABLEII.csv   66 rows x 20 cols  ("use this")
  -> __Public/comparative-data/10.1016%2F0304-3940(81)90228-7_TABLEII.tsv
  -> reference_tables/Passero_etal_1981_TABLEII_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-02 from 300-dpi renders of PDF page 4 (900 dpi for the caudate-putamen row), typed as a verbatim printed-layout block into `Passero_etal_1981_extract_snapshot.R` (freezes, refuses to overwrite). The OCR layer, read afterwards, agreed on all 66 numbers; it garbles only the significance stars.

The build script `Passero_etal_1981_TABLEII.R` reads the frozen file and contains no table values. It was run with
`Rscript` (conda env `r`, R with readxl) from a clean session on 2026-11-02.

### Structure of the snapshot and of the analysis CSV

* One snapshot row per printed row (title/caption, header tiers with blank padding under spanning
  headers, section headings and printed vertical gaps as rows, structure rows in printed order,
  footnote rows). Footnote marks are written `^x`; significance stars are kept on the cell.
* The analysis CSV is **long**: one row per printed cell (structure x arm), ordered as the page is
  read (along each row). `cell_as_printed` keeps the cell verbatim; `mean_printed` /
  `dispersion_printed` keep the exact printed lexemes; `CMRglc.umol_100g_min` is the parsed rate.
* **Observation level: printed group means per arm, not species means.** Pool or choose arms
  explicitly before any species-level use.

### Arms printed

control (n = 5), hypnosis (n = 5), mean ± S.E.; pct_decrease_hypnosis (printed % Decrease).

## Table checks

Result of an actual R run (2026-11-02): **21 pass, 1 mismatch, 0 not evaluable**, of 22 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `pct_decrease_13` | % Decrease = 100 x (Control - Hypnosis)/Control [row 13: Caudate-putamen] | 30.77 | 30.5 | 0.2692 | 0.1486 | mismatch |

(Only non-passing checks listed; the other 21 pass.)

## Data role

**primary**.

## Species names

The table prints no species; `species_as_published` carries the paper's own wording
(rabbits (New Zealand White)). No species harmonisation has been applied
and **no `_keys/` file was edited**. Proposed rows are in
`reference_tables/Passero_etal_1981_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema).

## Compilation comparison (done AFTER the snapshot was frozen)

The values Kaufman 2004 and Karbowski 2007 attribute to this paper
(`Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build.csv`)
were compared with the printed values only after the snapshot had been frozen. No printed value was changed.
The row-by-row reconstruction is in the restricted
`primary_items_extract/_compilation_check_glucose_primaries_5.csv`; the comparison extract is
`primary_items_extract/passero_1981.csv`.

Both compilations used the CONTROL arm (n = 5, mean ± S.E.), none the hypnosis arm. Karbowski 2007 (19 rows): 13 exact cells; Neocortex 0.83 ± 0.08 = mean of the 5 cortical rows (83.42); Sensorimotor 0.83 = sensory + motor; Thalamus 0.90 = thalamus + both geniculates; Whole brain 0.69 µmol/g/min and 7.93 µmol/min are not printed in the paper. Kaufman 2004 (8 rows): Hippocampus 58.1 ± 2.5 and White matter 26.1 ± 2.5 (internal capsule) as printed; Occipital 76.4 ± 19.7 and Parietal 73.1 ± 17.4 = visual and parietal cortex with S.E. x sqrt 5; Sensorimotor 82.65 ± 15.30 = sensory + motor, dispersion ≈ mean S.E. x sqrt 5 (15.32); Thalamus 89.7 and Basal ganglia 58.7 (caudate-putamen + pallidus + nigra) with S.E. unconverted. Compilation errors: Neocortex 77.4 ± 8.0 is not reproducible; its 8.0 equals the mean S.E. of the 5 cortical rows, whose mean is 83.4, so 77.4 is probably a Kaufman error. Kaufman labels the genus 'Lepus'; New Zealand White rabbits are Oryctolagus cuniculus. S.E. to S.D. conversion is applied to only 3 of 8 rows.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to
lay the snapshot beside the page, read a few rows **across** (including mid-table rows), and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Passero_etal_1981_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Passero_etal_1981-E001 | value_numeric | TABLE II p. 348, row 'Caudate-putamen', column '% Decrease' | 30.5*** |  | publication_error | 30.8 | proposed | % Decrease = 100 x (Control - Hypnosis)/Control. The same row prints Control 85.8 ± 5.2 and Hypnosis 59.4 ± 7.1, giving 30.77; printed 30.5 differs by 0.27 against a rounding allowance of 0.149. All three cells re-read at 900 dpi and unambiguous. The other 21 rows of the column reproduce the ratio of means within rounding. A Hypnosis mean of 59.6 would give 30.5, so the slip may be in either cell; the mean is kept as printed. | Detected by the item's own table_checks. CSV keeps the printed value. The % Decrease column is not used by the compilations. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
