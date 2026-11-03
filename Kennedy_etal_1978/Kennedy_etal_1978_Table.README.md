# Kennedy_etal_1978_Table

**Item name** `Kennedy_etal_1978_Table` · **Item number** `Table (unnumbered)` · **Item encoded** `10.1002%2Fana.410040402_Table` — *derived, awaiting registration*
(the item is not yet in `__ReadMe.xlsx`; the code was derived as the registry formula would build it,
DOI with `/` percent-encoded + `_` + item locus, the Mink_etal_1981 convention. Paste
`Kennedy_etal_1978_Table_registry_row.xlsx`, run `_tools/file_list.R`, and rename the TSV if the registry resolves a different code.)

Kennedy, C., Sakurada, O., Shinohara, M., Jehle, J., & Sokoloff, L. (1978). Local cerebral glucose utilization in the normal conscious macaque monkey. *Annals of Neurology*, 4(4), 293-301. <https://doi.org/10.1002/ana.410040402>

**Item full original title:** Values for Local Cerebral Glucose Utilization in Normal, Conscious Monkeys, p. 298.

## Source

PDF in this folder: `kennedy_etal_1978.pdf`, COPIED from the EndNote library (References.Data/PDF/3226382154/).

## Pipeline

```
Source (PDF)
  -> Kennedy_etal_1978_extract_snapshot.R   writes the frozen snapshot(s)
  -> Kennedy_etal_1978_Table_snapshot.csv   FROZEN: 52 rows x 2 cols
  -> Kennedy_etal_1978_Table.R   clean + parse + table checks
  -> Kennedy_etal_1978_Table.csv   39 rows x 20 cols  ("use this")
  -> __Public/comparative-data/10.1002%2Fana.410040402_Table.tsv
  -> reference_tables/Kennedy_etal_1978_Table_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-02 from 300/500-dpi renders of PDF pages 5-8, typed as a verbatim printed-layout block into `Kennedy_etal_1978_extract_snapshot.R` (freezes, refuses to overwrite a differing copy). The OCR text layer is garbled (figure labels interleaved, "pmoles" for µmoles) and was not used.

The build script `Kennedy_etal_1978_Table.R` reads the frozen file and contains no table values. It was run with
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

conscious_normal (n = 7; 6 for rows marked a), mean ± S.E.M.

## Table checks

Result of an actual R run (2026-11-02): **3 pass, 0 mismatch, 0 not evaluable**, of 3 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_gray_rows` | structure rows under 'Gray matter' vs RESULTS p. 297 '31 gray ... structures' | 31 | 31 | 0 | 0 | pass |
| `n_white_rows` | structure rows under 'White matter' vs RESULTS p. 297 '8 white structures' | 8 | 8 | 0 | 0 | pass |
| `highest_is_inferior_colliculus` | highest printed value is the Inferior colliculus row (RESULTS p. 297: 'The highest value was in the inferior colliculus') | 103 | 103 | 0 | 0 | pass |

## Data role

**primary** for the table. The text item is **both**: 29, 121, 47/67 and 107 are this paper's own; 3.7 cc O2 (Schmidt, Kety & Pennes 1945, ref 20), its glucose equivalent 28, and the human 31 (ref 22) are CITED and flagged `data_role = secondary` row by row; do not merge them as Kennedy 1978 data.

## Species names

The table prints no species; `species_as_published` carries the paper's own wording
(rhesus monkey). No species harmonisation has been applied
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
<!-- errata:end -->
