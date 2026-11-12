# Andersen_etal_2022_TableS1

**Item name** `Andersen_etal_2022_TableS1` · **Item number** `Table S1` ·
**Item encoded** (expected once registered) `10.1016%2Fj.nucmedbio.2022.06.007_TableS1`

Andersen, K. B., Hansen, A. K., Knudsen, K., Schacht, A. C., Damholdt, M. F., Brooks, D. J., &
Borghammer, P. (2022). Healthy brain aging assessed with [18F]FDG and [11C]UCB-J PET. *Nuclear Medicine
and Biology* 112–113, 52–58. <https://doi.org/10.1016/j.nucmedbio.2022.06.007> (DOI verified from the
article PDF, p. 1; open access, CC BY).

**Item full original title:** Table S1. Relative [18F]FDG uptake vs. [11C]UCB-J uptake differences (%)

## Sample sizes (printed in the main text)

26 healthy subjects, all scanned with both tracers (Methods 2.1; main-text **Table 1**, p. 53):
**HC young n = 11** (age 24.8 ± 1.2 y; male/female 7/4) and **HC old n = 15** (72.7 ± 4.2 y; 8/7). The
supplement's own Fig. S1 panel labels print the same sizes ("Young HC=11", "Old HC=15"); the build reads
n from there and asserts 15/11. **Both groups are healthy controls**; there is no disease group.

## What the data are

The only source here with **[18F]FDG (glucose uptake) and [11C]UCB-J (SV2A synaptic density) in the
same healthy subjects**. Per VOI (13 composite bilateral Hammers VOIs; Table S1 has no hippocampus), for
each age group the table gives the **grey-matter-normalised** regional uptake of each tracer ("Region
(GM norm)", each value relative to the individual's whole-brain GM mean), the **relative difference (%)
of FDG over UCB-J** (the average of the individual relative differences, per the caption) and an
uncorrected P. A third part (cited in the main text as "Table S1 C") repeats the young and old relative
differences with an uncorrected young-vs-old P.

Output: **26 rows** = 13 VOIs × 2 groups, with the part-C P on both rows of a VOI. Values are relative
(GM-normalised) ratios and percent, so this is **not rCMRglc** (there was no arterial input) and not
Bmax/VT. Use it as a relative metabolic-vs-synaptic pattern. The project units (mm³, g, mg) do not
apply, and nothing is converted. The supplement does not state whether these GM-normalised VOI values
are PVC-corrected; the main text says the VOI results were PVC-corrected (GTM).

VOI labels are kept as printed (`FCX`, `Amg`, `MTCx`, …). Full names, and the basis of each reading, are
in `reference_tables/Andersen_etal_2022_region_labels.csv`. **SN and Amg are not defined anywhere in the
paper or supplement**; they are read as substantia nigra and amygdala, which is an interpretation.

## Frozen source (digital-native)

`Andersen_etal_2022_TableS1_snapshot.docx` is a **copy-rename of the journal-supplied supplement**
`1-s2.0-S0969805122020662-mmc1.docx` (Elsevier "mmc1", already in this folder and kept). It was copied
with `shutil.copy2` and never opened or re-saved. The house regex for snapshots (csv/xlsx/xls/tsv)
does not cover `.docx`; the precedent is `Jacobs_etal_2019`, which does the same.

**OneDrive note.** After the copy, the OneDrive/SharePoint sync added one empty
`MediaServiceImageTags` property to `docProps/custom.xml` of the two new copies, so their MD5 differs from
the original. `word/document.xml` (the tables) and every other part are byte-identical to the original.
This was checked part by part on 2026-11-11.

The reader (`Andersen_etal_2022_TableS1.R`) parses `word/document.xml` with xml2. It locates Table S1 by
its caption paragraph, the three Word tables that follow it and the "HC old" / "HC young" labels, and
asserts every printed header. **No value is typed in the script.** The values were not retyped.

## Pipeline

```
Source: 1-s2.0-S0969805122020662-mmc1.docx (journal supplement)
  -> Andersen_etal_2022_TableS1_snapshot.docx     FROZEN: copy-rename of the download
  -> Andersen_etal_2022_TableS1.R                 xml2 read + reshape + table checks
  -> Andersen_etal_2022_TableS1.csv               26 rows x 15 cols ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv written only once the registry row exists
  -> reference_tables/Andersen_etal_2022_TableS1_definitions.csv
  -> reference_tables/Andersen_etal_2022_region_labels.csv
  -> reference_tables/Andersen_etal_2022_species_key_proposed.csv
  -> reference_tables/Andersen_etal_2022_errata.csv            (E001, this item)
```

The reader was built by an AI assistant (Claude) on 2026-11-11 and run from a clean `Rscript` session.
As an independent check, the docx was re-parsed in Python (lxml on `word/document.xml`) and compared
cell by cell with the two Andersen CSVs: **324 cells (Tables S1 and S2), 0 mismatches**. An
`officer::docx_summary` dump was also inspected by eye.

## Table checks

Part C prints the Young and Old relative differences a second time. The reader checks all 26 pairs for
identity in units of 0.01: **26/26 pass** (actual R run, 2026-11-11).

The relative difference itself cannot be recomputed exactly, because it is a mean of individual ratios.
It tracks 100 × (FDG − UCB-J) / FDG of the printed means to within about ±1.7 points (Thal −2.4 / −2.8),
except one row, which is recorded as an erratum (below).

## Cross-check

The staged earlier-session extraction holds only the main-text Results 3.4 pooled percentages (n = 26),
not Table S1. As a consistency check, the 15/11-weighted pool of the printed old/young relative
differences reproduces the main-text pooled values to the printed integer for 10 of the 11 VOIs cited
(Str 11.5, OCx 8.6, CBL 8.05, PCCx 4.0, FCx 3.8, AMY −20.4, LTCx −17.0, ACCx −13.8, mTCx −12.6, ICx −9.5).
The exception is Thal, which gives 32.5 against the text's 34 %; the text's Fig. 3B may use a different
computation.

## Species

Single species, *Homo sapiens* (not printed in the table). The proposed key row is in
`reference_tables/Andersen_etal_2022_species_key_proposed.csv` (collection *General*); it has not been
added to `_keys/General/species_key.csv`.

## Registration

The item is **not yet registered**. The build prints `not yet registered - TSV skipped` until the owner
pastes `Andersen_etal_2022_TableS1_registry_row.xlsx` and runs `_tools/file_list.R`.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Andersen_etal_2022_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Andersen_etal_2022-E001 | rel_diff_FDG_over_UCBJ.pct | Table S1, 'HC young' part (docx table 2), row 'CBL', column 'Relative difference (%)' (also repeated in part C, column 'Relative difference (%) Young') | 5.24 |  | publication_ambiguity |  | proposed | The same printed row gives [18F]FDG 0.84 and [11C]UCB-J 0.84, i.e. a 0.00% difference of the group means, with P <0.001. Across the other 25 rows of Table S1 the printed relative difference tracks 100 x (FDG - UCB-J) / FDG of the printed means to within about +/-1.7 points (Thal -2.4 and -2.8); this row is +5.24. 5.24 is also the printed value of row 'FCX' in the same HC young part. Against that, the main-text pooled value for CBL (Results 3.4, Fig. 3B, n = 26: 'CBL (8 %)') equals (15 x 10.11 + 11 x 5.24) / 26 = 8.05, consistent with 5.24. Either the 5.24 or one of the two printed means (0.84 / 0.84) is misprinted; the paper cannot adjudicate which. | Value kept exactly as printed in the CSV; the caption defines the relative difference as the average of individual differences, so an exact recomputation from group means is not possible. Not a table_checks item (no exact printed relation). |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
