# Palombo_etal_1990_Table4

**Item name** `Palombo_etal_1990_Table4` · **Item number** `Table 4` · **Item encoded** `10.1523%2FJNEUROSCI.10-03-00860.1990_Table4` — *derived, awaiting registration*
(the item is not yet in `__ReadMe.xlsx`; the code was derived as the registry formula would build it,
DOI with `/` percent-encoded + `_` + item locus, the Mink_etal_1981 convention. Paste
`Palombo_etal_1990_Table4_registry_row.xlsx`, run `_tools/file_list.R`, and rename the TSV if the registry resolves a different code.)

Palombo, E., Porrino, L. J., Bankiewicz, K. S., Crane, A. M., Sokoloff, L., & Kopin, I. J. (1990). Local cerebral glucose utilization in monkeys with hemiparkinsonism induced by intracarotid infusion of the neurotoxin MPTP. *The Journal of Neuroscience*, 10(3), 860-869. <https://doi.org/10.1523/JNEUROSCI.10-03-00860.1990>

**Item full original title:** Table 4. Rates of glucose utilization (µmol/100 gm/min) in forebrain and hypothalamus of MPTP-induced hemiparkinsonian monkeys (mean ± SEM), p. 864.

## Source

PDF in this folder: `Palombo-1990-Local cerebral glucose utilizatio.pdf`, MOVED here from `cereb metabol refs/`.

Page range: the article runs pp. 860-869 (Crossref; the Table 1 page header reads 863). The task brief cited "J Neurosci 10:880"; that page number does not match the print.

## Pipeline

```
Source (PDF)
  -> Palombo_etal_1990_extract_snapshot.R   writes the frozen snapshot(s)
  -> Palombo_etal_1990_Table4_snapshot.csv   FROZEN: 18 rows x 5 cols
  -> Palombo_etal_1990_Table4.R   clean + parse + table checks
  -> Palombo_etal_1990_Table4.csv   60 rows x 21 cols  ("use this")
  -> __Public/comparative-data/10.1523%2FJNEUROSCI.10-03-00860.1990_Table4.tsv
  -> reference_tables/Palombo_etal_1990_Table4_definitions.csv
```

## Who read the values, when, and how it was checked

**Hand transcription** (HOWTO method 5) by an AI assistant (Claude) on 2026-11-02 from 450-dpi crops of PDF pages 4, 5 and 7, read row by row across all four columns, typed as verbatim printed-layout blocks into `Palombo_etal_1990_extract_snapshot.R` (one script writes all five table snapshots; freezes, refuses to overwrite). The OCR layer was NOT used: it confuses 5/7/1 (e.g. "51" for the printed 57 in Table 1 Body of caudate, "31" for the printed 37 in Table 2 Lateral geniculate).

The build script `Palombo_etal_1990_Table4.R` reads the frozen file and contains no table values. It was run with
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

control_right, control_left (Controls n = 4, right/left hemisphere); mptp_lesioned_side, mptp_unlesioned_side (Hemiparkinsonian n = 4); mean ± SEM.

## Table checks

Result of an actual R run (2026-11-02): **1 pass, 0 mismatch, 0 not evaluable**, of 1 checks.

| check | basis | observed | printed | difference | tolerance | status |
|---|---|---|---|---|---|---|
| `n_rows` | structure rows in Table 4 | 15 | 15 | 0 | 0 | pass |

## Data role

**primary** (the authors' own [14C]DG measurements).

## Species names

The table prints no species; `species_as_published` carries the paper's own wording
(Macaca mulatta). No species harmonisation has been applied
and **no `_keys/` file was edited**. Proposed rows are in
`reference_tables/Palombo_etal_1990_species_key_proposed.csv` (7-column `_keys/General/species_key.csv` schema).

## Compilation comparison (done AFTER the snapshot was frozen)

The values Kaufman 2004 and Karbowski 2007 attribute to this paper
(`Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/_compilation_rows_for_build.csv`)
were compared with the printed values only after the snapshot had been frozen. No printed value was changed.
The row-by-row reconstruction is in the restricted
`primary_items_extract/_compilation_check_glucose_primaries_5.csv`; the comparison extract is
`primary_items_extract/palombo_1990.csv`.

Both compilations used the CONTROL arm; neither used the MPTP lesioned or unlesioned columns. Kaufman 2004 (9 rows) used the Controls RIGHT column: Hippocampus 32 ± 1 and White matter 11 ± 1 as printed (S.E.M. unconverted); Cingulate 39 ± 4, Sensorimotor 46 ± 4, Occipital 66 ± 4 (striate + prestriate) and Frontal 54.7 ± 8.0 (orbitofrontal + DLPFC + FEF) carry S.E.M. x 2 (= x sqrt 4), i.e. an S.E.M.-to-S.D. conversion applied to only some rows; Basal ganglia 51.3 = mean of the 9 caudate + putamen subdivisions. Karbowski 2007 (17 rows) used the control right or left columns or their mean (e.g. Cingulate 0.40 = (39 + 41)/2; Superior colliculus 0.55 = the 'internal' layer R/L mean; Corpus callosum 0.11 = (11 + 10)/2); several rows cannot be assigned to one hemisphere. Cerebellum conflict (Karbowski 0.46 µmol/g/min vs Kaufman 24.5 µmol/100 g/min): neither copies the printed Cerebellar cortex (Controls R 34 ± 3, L 35 ± 2). Kaufman's 24.5 = mean of Cerebellar cortex and Cerebellar WHITE MATTER (Left (35 + 14)/2 = 24.5); Karbowski's 0.46 (= 46 µmol/100 g/min, so not a unit error) fits a gray-matter composite with deep nuclei (e.g. Fastigial R/L mean 45.5, or cortex + dentate 45.5), not uniquely. The difference is a composite-definition difference, and Kaufman's value mixes white matter into 'cerebellum'.

## Human visual check of snapshot

Pending human RA. The AI-assistant reading and checks are described above. A person still needs to
lay the snapshot beside the page, read a few rows **across** (including mid-table rows), and record
`DDMMYYYY_initials` in the `Human visual check of snapshot` column.

<!-- errata:begin -->
<!-- errata:end -->
