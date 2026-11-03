# Kennedy_etal_1978_Text

**Item name** `Kennedy_etal_1978_Text` · **Item number** `data from text` · **Item encoded** `10.1002%2Fana.410040402_Text` — *derived, awaiting registration*
(the item is not yet in `__ReadMe.xlsx`; the code was derived as the registry formula would build it,
DOI with `/` percent-encoded + `_` + item locus, the Mink_etal_1981 convention. Paste
`Kennedy_etal_1978_Text_registry_row.xlsx`, run `_tools/file_list.R`, and rename the TSV if the registry resolves a different code.)

Kennedy, C., Sakurada, O., Shinohara, M., Jehle, J., & Sokoloff, L. (1978). Local cerebral glucose utilization in the normal conscious macaque monkey. *Annals of Neurology*, 4(4), 293-301. <https://doi.org/10.1002/ana.410040402>

**Item full original title:** Values printed in the DISCUSSION (p. 298) and the legends of Fig 2 (p. 299) and Fig 3 (p. 300).

## Source

PDF in this folder: `kennedy_etal_1978.pdf`, COPIED from the EndNote library (References.Data/PDF/3226382154/).

## Pipeline

```
Source (PDF)
  -> Kennedy_etal_1978_extract_snapshot.R   writes the frozen snapshot(s)
  -> Kennedy_etal_1978_Text_snapshot.csv   FROZEN: 11 rows x 10 cols
  -> Kennedy_etal_1978_Text.R   clean + parse + table checks
  -> Kennedy_etal_1978_Text.csv   10 rows x 20 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fana.410040402_Text.tsv
  -> reference_tables/Kennedy_etal_1978_Text_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-02 from 300/500-dpi renders of PDF pages 5-8, typed as a verbatim printed-layout block into `Kennedy_etal_1978_extract_snapshot.R` (freezes, refuses to overwrite a differing copy). The OCR text layer is garbled (figure labels interleaved, "pmoles" for µmoles) and was not used.

The build script `Kennedy_etal_1978_Text.R` reads the frozen file and contains no table values. It was run with
`Rscript` (conda env `r`, R with readxl) from a clean session on 2026-11-02.

### Constructed snapshot

There is no printed table: the snapshot is **constructed**, one row per printed value, with the
page, location and the sentence it comes from (quoted). See `value_status` / `data_role` in the CSV
for which values are new, restatements, or cited.

## Table checks

Result of an actual R run (2026-11-02): **3 pass, 1 mismatch, 0 not evaluable**, of 4 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `equal_weight_gray_white_average` | DISCUSSION p. 298: (mean of 31 gray rows + mean of 8 white rows)/2 vs printed 29 | 30.04 | 29 | 1.04 | 1 | mismatch |
| `o2_to_glucose_equivalent` | DISCUSSION p. 298: 3.7 cc O2/100 g/min / 22.4 mL/mmol x 1000 / 6 vs printed 'approximately 28' | 27.53 | 28 | -0.4702 | 0.872 | pass |
| `restatement_28` | text row 5 vs text row 2 | 28 | 28 | 0 | 0 | pass |
| `restatement_31` | text row 6 vs text row 3 | 31 | 31 | 0 | 0 | pass |

## Data role

**primary** for the table. The text item is **both**: 29, 121, 47/67 and 107 are this paper's own; 3.7 cc O2 (Schmidt, Kety & Pennes 1945, ref 20), its glucose equivalent 28, and the human 31 (ref 22) are CITED and flagged `data_role = secondary` row by row; do not merge them as Kennedy 1978 data.

## Species names

The table prints no species; `species_as_published` carries the paper's own wording
(conscious man, monkey, normal conscious young men). No species harmonisation has been applied
and **no `_keys/` file was edited**. Proposed rows are in
`reference_tables/Kennedy_etal_1978_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema).

## Compilation comparison (done AFTER the snapshot was frozen)

The values Kaufman 2004 and Karbowski 2007 attribute to this paper
(`Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build.csv`)
were compared with the printed values only after the snapshot had been frozen. No printed value was changed.
The row-by-row reconstruction is in the restricted
`primary_items_extract/_compilation_check_glucose_primaries_5.csv`; the comparison extract is
`primary_items_extract/kennedy_1978.csv`.

Single printed arm (conscious, n = 7, mean ± S.E.M.). Karbowski 2007 (21 rows): 15 exact cells (S.E.M. carried as its dispersion); Cerebellum 0.38 = mean of Cerebellar cortex and Cerebellar nuclei; Neocortex 0.57 = mean of visual, auditory, parietal and motor cortex; Thalamus 0.47 fits dorsomedial + lateral geniculate (ambiguous). Hypothalamus 0.26 ± 0.04 is not reproducible (ventromedial nucleus prints 25 ± 1). Whole brain 0.36 µmol/g/min (and 35.98 µmol/min) is not printed in the paper; the paper's own estimate is 29, and its table gives 30.0 (erratum E001). Kaufman 2004 (5 rows): Hippocampus 39 ± 2 is an exact cell; Basal ganglia 45.5 = caudate + putamen + globus pallidus + subthalamic; Neocortex 55.8 ± 3.0 = mean of the 5 cortical rows; Thalamus 50.3 = dorsomedial + VPL + medial + lateral geniculate; White matter 12.0 ± 1.0 = Cerebellar white matter (or several 2-5-row means). Compilation error: Kaufman labels the species 'M fascic'; the paper studied rhesus (Macaca mulatta).

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to
lay the snapshot beside the page, read a few rows **across** (including mid-table rows), and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Kennedy_etal_1978_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Kennedy_etal_1978-E001 | value_numeric | DISCUSSION p. 298, right column, text row 4 ('then that average is found to be 29 µmoles per 100 gm of tissue per minute') | 29 |  | publication_ambiguity | 30 | proposed | The sentence defines the value: brain taken as equal fractions of gray and white matter, the arithmetic means of the rates in the gray structures and in the white structures averaged. From the paper's own table (31 gray rows mean 46.581, 8 white rows mean 13.500) the average is 30.04. Printed 29 differs by 1.04 against a rounding allowance of 1.0 (each integer cell ±0.5, plus half a unit of the printed 29). Every table cell was re-read from 500-dpi renders. Excluding the spinal rows makes the discrepancy larger (30.9). | Marginal (0.04 beyond the rounding allowance); could come from unrounded per-structure means. Value kept as printed. Relevant to the audit: the compilations' monkey whole-brain values do not use 29 either (Karbowski prints 0.36 µmol/g/min, not derivable from this paper). |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
