# Bouilleret_etal_2000_Table2

**Item name** `Bouilleret_etal_2000_Table2` · **Item number** `Table 2` · **Item encoded** `10.1016%2FS0006-8993(99)02092-2_Table2` — *derived, awaiting registration*
(the item is not yet in `__ReadMe.xlsx`; the code was derived as the registry formula would build it,
DOI with `/` percent-encoded + `_` + item locus, the Mink_etal_1981 convention. Paste
`Bouilleret_etal_2000_Table2_registry_row.xlsx`, run `_tools/file_list.R`, and rename the TSV if the registry resolves a different code.)

Bouilleret, V., Boyet, S., Marescaux, C., & Nehlig, A. (2000). Mapping of the progressive metabolic changes occurring during the development of hippocampal sclerosis in a model of mesial temporal lobe epilepsy. *Brain Research*, 852(2), 255-262. <https://doi.org/10.1016/S0006-8993(99)02092-2>

**Item full original title:** Table 2. Effects of intrahippocampal kainate on LCMRglcs of adult mice, pp. 258-259.

## Source

PDF in this folder: `Bouilleret-2000-Mapping of the progressive met.pdf`, MOVED here from `cereb metabol refs/`.

## Pipeline

```
Source (PDF)
  -> Bouilleret_etal_2000_extract_snapshot.R   writes the frozen snapshot(s)
  -> Bouilleret_etal_2000_Table2_snapshot.csv   FROZEN: 67 rows x 6 cols
  -> Bouilleret_etal_2000_Table2.R   clean + parse + table checks
  -> Bouilleret_etal_2000_Table2.csv   240 rows x 23 cols  ("use this")
  -> __Public/comparative-data/10.1016%2FS0006-8993(99)02092-2_Table2.tsv
  -> reference_tables/Bouilleret_etal_2000_Table2_definitions.csv
```

## Who read the values, when, and how it was checked

**Text-layer extraction** (HOWTO method 3, Jacob_etal_2021 pattern): `Bouilleret_etal_2000_extract_snapshot.R` reads the born-digital text layer with `pdftools` at run time (no table value is typed in the script), decodes the publisher symbol font with a fixed documented map (`"` -> ±, trailing `U`/`UU` -> `*`/`**`, `Ž n s 4.` -> `(n = 4)`, `mmolr100 grmin` -> µmol/100 g/min), anchors on printed literals, and freezes the snapshots (refuses to overwrite). Every decoded cell and significance mark was then checked by an AI assistant (Claude) on 2026-11-02 against 330-dpi renders of PDF pages 4-5. In the RESULTS passage the parenthesis glyphs are separate, mis-positioned tokens in the text layer; they are dropped from the quoted passage (no digit affected).

The build script `Bouilleret_etal_2000_Table2.R` reads the frozen file and contains no table values. It was run with
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

control_saline (n = 4), KA_day0 (n = 3), KA_day15, KA_day30, KA_day120 (n = 4 each); mean ± S.D.

## Table checks

Result of an actual R run (2026-11-02): **3 pass, 0 mismatch, 0 not evaluable**, of 3 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_structures` | distinct structures (section + label, sides pooled) vs 2.4 '24 structures' | 24 | 24 | 0 | 0 | pass |
| `n_kainate_mice` | sum of KA group n vs 2.2 '15 receiving kainate' | 15 | 15 | 0 | 0 | pass |
| `n_destroyed` | 'destroyed' cells = CA1 and CA3 right at day 30 and 120 (RESULTS 3.3) | 4 | 4 | 0 | 0 | pass |

## Data role

**primary**.

## Species names

The table prints no species; `species_as_published` carries the paper's own wording
(adult male Swiss albino mice). No species harmonisation has been applied
and **no `_keys/` file was edited**. Proposed rows are in
`reference_tables/Bouilleret_etal_2000_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema).

## Compilation comparison (done AFTER the snapshot was frozen)

The values Kaufman 2004 and Karbowski 2007 attribute to this paper
(`Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build.csv`)
were compared with the printed values only after the snapshot had been frozen. No printed value was changed.
The row-by-row reconstruction is in the restricted
`primary_items_extract/_compilation_check_glucose_primaries_5.csv`; the comparison extract is
`primary_items_extract/bouilleret_2000.csv`.

Both compilations used the CONTROL (saline) arm, never a kainate day. Karbowski 2007 (16 single-source rows) averages right and left (and sub-nuclei): e.g. Caudate 1.25 ± 0.16 = (127 + 122)/2; Hippocampus 0.84 ± 0.13 = CA1 + CA3, both sides; Neocortex 1.07 ± 0.10 = all 10 cortical rows incl. piriform and entorhinal (106.8). Compilation error: Karbowski Pallidum 0.76 ± 0.03 has no source here, because Bouilleret Table 2 prints no globus pallidus. Whole brain 0.89 µmol/g/min and 0.32 µmol/min are not printed in the paper. Kaufman 2004 (6 rows): R/L means rounded half-up to integers, then printed with '.0' (Frontal 107.0 = 106.5; Sensorimotor 121.00 = 120.5); Neocortex 116.7 ± 10.3 = mean of Kaufman's own rounded Prefrontal 122, Frontal 107 and Sensorimotor 121; Hippocampus 84.3 ± 13.0, Thalamus 119.2 ± 10.0, White matter 39.5 ± 10.5 (genu R/L) as R/L means. The dentate-gyrus text values (27, 179, 58) are used by neither compilation.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to
lay the snapshot beside the page, read a few rows **across** (including mid-table rows), and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
