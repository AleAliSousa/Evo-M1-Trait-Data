# Baron_etal_1987_Table1

## Source

PDF: `baron_etal_1987_VI_scan.pdf` (the lighter scan is in `old/`).

Paper: Baron, G., Stephan, H., and Frahm, H. D. (1987). *Comparison of Brain Structure Volumes in Insectivora and Primates. VI. Paleocortical Components.* Journal fuer Hirnforschung. (13 figures, 3 tables.)

Table: **Table 1** — volumes (mm3) of the paleocortical / olfactory structures. Per the abstract, 89 species: 2 Macroscelidea, 39 Insectivora, 3 Scandentia, 18 prosimians, 26 simians and man.

> **The two scans differ in legibility.** The regular scan carries a much richer OCR text layer (~67k characters) than the lighter scan (~19k, largely unreadable). The numeric grid does not OCR cleanly from either, so the snapshot was reconstructed from the formatted CSV (now `old/baron_etal_1987.csv`), not from OCR. The paper's Table 1 also reports size indices and a nucleus (NTO) not captured here.

## Layout

The **final outputs (csv, tsv) come only from the snapshot** — no crosswalk, no comparison files feed them. Checking is a self-contained step in `comparison/`.

| Path | Role |
|---|---|
| `Baron_etal_1987_Table1_snapshot.xlsx` | Faithful capture (sheet `Table1_snapshot`): caption, structure-code header, group sections, 89 species, abbreviation key. |
| `Baron_etal_1987_Table1.R` | **Preparation** -> `Baron_etal_1987_Table1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Baron_etal_1987_definitions.csv` | Data dictionary (7 structure codes -> full names + unit). Documentation only. |
| `comparison/Baron_1987.csv` | Formatted table, audited only. |
| `comparison/Baron_etal_1987_Table1_compare_to_baron_etal_1987_csv.R` | **Checking** (QA): snapshot vs `Baron_1987.csv`. |
| `old/` | Deprecated: the species crosswalk, `baron_etal_1987.csv`, the old snapshot csv, `Baron87_*` keys, the lighter scan. |

## The seven structures

BOL bulbus olfactorius (olfactory bulb); RB retrobulbar cortex (regio retrobulbaris, = anterior olfactory nucleus); PRPI prepiriform cortex; TOL tuberculum olfactorium (olfactory tubercle); TRL tractus olfactorius lateralis (lateral olfactory tract); COA commissura anterior (anterior commissure); SIN substantia innominata. All values are volumes in mm3 (see the definitions table).

## 1. Preparation — `Baron_etal_1987_Table1.R` -> `Baron_etal_1987_Table1.csv`

Reads **only** the snapshot. One row per species (89), 8 columns: `Species_Baron1987` (name as printed) and the seven structure-volume columns `BOL, RB, PRPI, TOL, TRL, COA, SIN` (numeric). The current/MDD species name is **not** included (it would come from the crosswalk); taxonomy is handled later. It also writes a tab-separated copy named by the item's encoded DOI (from `__ReadMe.xlsx`) into `__Public/comparative-data/`.

## 2. Checking — `comparison/Baron_etal_1987_Table1_compare_to_baron_etal_1987_csv.R`

Run from the `comparison/` folder. Matches the snapshot (`../...snapshot.xlsx`) to `Baron_1987.csv` by Baron 1987 species name and compares all seven structure volumes (mapping the CSV's full structure names to the codes). Verified: **0 value mismatches**; 81 of 89 species match by name. The other 8 are the same animals under slightly different name formats between the snapshot and the master (e.g. `Eulemur albifrons`/`Lemur albifrons`, `Daubentonia madagascariensis`/`madagasc`, `Tarsius sp`/`spp`, `Procolobus badius`/`Colobus badius`) and are surfaced as snapshot-only / csv-only rows for review.

## 3. Reference / definitions — `reference_tables/`

`Baron_etal_1987_definitions.csv` is the data dictionary (same format as your other `_definitions.csv` files): the 7 structure codes, full names, and unit (mm3). The species crosswalk has been moved to `old/` for the later cross-paper taxonomy step.

## Snapshot transcription typos worth a look

The source CSV carried several misspelled species names: `Scuisorex` -> Scutisorex somereni; `Microsoex` -> Microsorex hoyi (now *Sorex hoyi*); `Ruwensorisorex` -> Ruwenzorisorex suncoides; `Crocidura hildegardea` -> hildegardeae; `Sylvisorex negalura` -> likely *Sylvisorex / Suncus megalura*. The group label `SCADENTIA` was corrected to `SCANDENTIA` in the snapshot.
