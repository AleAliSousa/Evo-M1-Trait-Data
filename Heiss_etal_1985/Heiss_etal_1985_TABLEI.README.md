# Heiss_etal_1985_TABLEI

**Item name** `Heiss_etal_1985_TABLEI` · **Item number** `TABLE I` · **Item encoded** `10.1016%2F0006-8993(85)91537-9_TABLEI` — *derived, awaiting registration*
(the item is not yet in `__ReadMe.xlsx`; the code was derived as the registry formula would build it,
DOI with `/` percent-encoded + `_` + item locus, the Mink_etal_1981 convention. Paste
`Heiss_etal_1985_TABLEI_registry_row.xlsx`, run `_tools/file_list.R`, and rename the TSV if the registry resolves a different code.)

Heiss, W.-D., Pawlik, G., Herholz, K., Wagner, R., & Wienhard, K. (1985). Regional cerebral glucose metabolism in man during wakefulness, sleep, and dreaming. *Brain Research*, 327(1-2), 362-366. <https://doi.org/10.1016/0006-8993(85)91537-9>

**Item full original title:** TABLE I. Regional cerebral metabolic rate for glucose in normal human subjects during sleep and wakefulness (µmol/100 g/min), p. 363.

## Source

PDF in this folder: `heiss_etal_1985.pdf`, COPIED (bytes identical) from the EndNote library (References.Data/PDF/3615254120/).

## Pipeline

```
Source (PDF)
  -> Heiss_etal_1985_extract_snapshot.R   writes the frozen snapshot(s)
  -> Heiss_etal_1985_TABLEI_snapshot.csv   FROZEN: 33 rows x 5 cols
  -> Heiss_etal_1985_TABLEI.R   clean + parse + table checks
  -> Heiss_etal_1985_TABLEI.csv   96 rows x 20 cols  ("use this")
  -> __Public/comparative-data/10.1016%2F0006-8993(85)91537-9_TABLEI.tsv
  -> reference_tables/Heiss_etal_1985_TABLEI_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-02 from 300/400-dpi renders of PDF pages 1-3, typed as a verbatim printed-layout block into `Heiss_etal_1985_extract_snapshot.R`, which freezes it and refuses to overwrite a differing frozen copy. The OCR text layer was read only afterwards, as a second reading: it agreed on every TABLE I value and every text value.

The build script `Heiss_etal_1985_TABLEI.R` reads the frozen file and contains no table values. It was run with
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

nondreamers_awake (n = 3, mean ± S.D.); nondreamers_pct_change_asleep (n = 3, % change asleep, mean ± S.D.); dreamer_awake (n = 1); dreamer_pct_change_asleep (n = 1).

## Table checks

Result of an actual R run (2026-11-02): **4 pass, 0 mismatch, 0 not evaluable**, of 4 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `dreamer_pct_min_is_lentiform` | Dreamer % Change asleep: smallest printed value is the Lentiform nucleus row (abstract: 'ranging from 2.1% in lentiform nucleus') | 2.1 | 2.1 | 0 | 0 | pass |
| `dreamer_pct_max_is_sup_front` | Dreamer % Change asleep: largest printed value is the Sup. front. cortex row (abstract: 'to 30.0% in the superior frontal cortex') | 30 | 30 | 0 | 0 | pass |
| `nondreamers_all_regions_decrease` | Non-dreamers % Change asleep: every region negative ('non-selective decrease'); observed = number of non-negative cells | 0 | 0 | 0 | 0 | pass |
| `dreamer_all_regions_increase` | Dreamer % Change asleep: every region positive ('higher metabolic rates in all regions'); observed = number of non-positive cells | 0 | 0 | 0 | 0 | pass |

## Data role

**primary** (the authors' own FDG-PET measurements). Nothing in TABLE I or the text values is cited from elsewhere.

## Species names

The table prints no species; `species_as_published` carries the paper's own wording
(normal human subjects). No species harmonisation has been applied
and **no `_keys/` file was edited**. Proposed rows are in
`reference_tables/Heiss_etal_1985_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema).

## Compilation comparison (done AFTER the snapshot was frozen)

The values Kaufman 2004 and Karbowski 2007 attribute to this paper
(`Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build.csv`)
were compared with the printed values only after the snapshot had been frozen. No printed value was changed.
The row-by-row reconstruction is in the restricted
`primary_items_extract/_compilation_check_glucose_primaries_5.csv`; the comparison extract is
`primary_items_extract/heiss_1985.csv`.

Kaufman 2004 (13 rows) copied the Non-dreamers AWAKE arm of TABLE I: 6 rows are exact cells (incl. Whole brain 36.2 ± 2.38) and 6 are means of printed sub-regions with their S.D.s averaged (Frontal 42.7 ± 2.0 = 4 frontal rows; Temporal, Parietal, Occipital, White matter, Basal ganglia = caudate + lentiform). Neocortex 41.1 ± 2.7 could not be reproduced (14 cortical rows average 40.56). Compilation error: Kaufman gives n = 6, but the copied arm has n = 3 (6 volunteers studied, 2 excluded, 1 dreamer). Karbowski 2007 (10 single-source rows) did not copy one arm: 9 rows equal the n-weighted pool of all 4 AWAKE subjects, (3 x non-dreamers + dreamer)/4 (e.g. Caudate 0.39 = 38.9; Hippocampus 0.37 = 36.6); Thalamus 0.36 is 0.01 below the pooled 0.37. Its S.D.s cannot come from the printed S.D.s. No sleep arm was used by either compilation; the sleep rate exists only as % change, plus the text's whole-brain 31.6 ± 1.42.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to
lay the snapshot beside the page, read a few rows **across** (including mid-table rows), and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
