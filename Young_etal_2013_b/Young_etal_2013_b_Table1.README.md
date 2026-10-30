# Young et al. 2013b — epileptic baboons (Tables S1 + S2)

Young NA, Szabo CA, Phelix CF, Flaherty DK, Balaram P, Foust-Yeoman KB, Collins CE, Kaas JH (2013).
*Epileptic baboons have lower numbers of neurons in specific areas of cortex.* PNAS
110(47):19107–19112. doi:10.1073/pnas.1318894110 · Team **Kaas** · flow/isotropic fractionator.

Registry (`__ReadMe.xlsx`): Item name **`Young_etal_2013_Table1`** (⚠️ shared with the M1 paper in
folder `Young_etal_2013`; disambiguated by DOI), encoded `10.1073%2Fpnas.1318894110_Table1`.
Local files use `Young_etal_2013_b_Table1` to stay unambiguous.

## ⚠️ This is a within-species DISEASE study — not comparative data
Four baboons: **two neurologically normal** (09-27, 11-31) and **two with epilepsy** (10-04, 11-45).
It exists to measure how epilepsy reduces cortical neuron numbers, **not** to add a species to the
comparative dataset. It is built here for provenance and is **deliberately not added to any merge**.

| case | condition | comparative_use | note |
|---|---|---|---|
| **09-27** | Normal | `exclude_duplicate_Collins2010` | **same brain as Collins 2010 Dataset S1** (4.67 B cells, 186 cm²) |
| 11-31 | Normal | `include` | the only genuinely new, normal, non-duplicate baboon |
| 10-04 | Epilepsy | `exclude_epileptic` | disease state |
| 11-45 | Epilepsy | `exclude_epileptic` | disease state |

The `comparative_use` and `specimen_duplicate_of` columns carry these flags on every row.

## What the data are
Per-case **cell and neuron numbers** for the whole cortex and for V1, S1, M1 (Table S2), joined to
case metadata — age, sex, body/brain weight, hemisphere, cortical surface area, perfusion (Table S1).
16 rows = 4 cases × 4 regions.

## Source → Snapshot → Data readable
Tables S1 + S2 (SI PDF) → `Young_etal_2013_b_Table1_snapshot.xlsx` (two sheets, verbatim — including
the printed "billion/million" text and the source's "Cell censity" typo). `Young_etal_2013_b_Table1.R`
→ `Young_etal_2013_b_Table1.csv` (**use this**): counts converted to absolute numbers
(4.67 billion → 4.67e9), `PHA`/`PHX` expanded (Table S1 legend), flags applied. Columns in
`reference_tables/Young_etal_2013_b_Table1_definitions.csv`.

## Relationship to the other Kaas tables
- **Collins 2010** — case 09-27 is the same baboon (duplicate; flagged).
- **Young 2013 (M1, folder `Young_etal_2013`)** — same lab/method; this paper adds V1/S1/M1 counts for
  baboons under normal vs epileptic conditions. Species labels here are baboon-specific (PHA/PHX).
- If a baboon cortical cell-count value is ever needed for a comparative merge, use **case 11-31**
  (normal, non-duplicate) only — never the epileptic cases or 09-27.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅ (provenance only; excluded from merges)
