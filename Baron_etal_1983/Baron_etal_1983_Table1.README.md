# Baron_etal_1983_Table1

## Source

PDF: `baron_etal_1983.pdf`

Paper: Baron, G., Frahm, H. D., Bhatnagar, K. P., and Stephan, H. (1983). *Comparison of Brain Structure Volumes in Insectivora and Primates. III. Main olfactory bulb (MOB).* Journal fuer Hirnforschung 24:551-568.

Table: **Table 1. Data on total MOB (layers 1-6 + periventricular zone).** 76 species.

## Layout

The **final outputs (csv, tsv) come only from the paper, via the snapshot** — no crosswalk, no comparison files feed them. Checking is a separate, self-contained step in `comparison/`.

| Path | Role |
|---|---|
| `Baron_etal_1983_Table1_snapshot.xlsx` | Faithful capture of the PDF table (sheet `Table1_snapshot`). Source of truth. |
| `Baron_etal_1983_Table1.R` | **Preparation** -> `Baron_etal_1983_Table1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Baron_etal_1983_definitions.csv` | Data dictionary (documentation only; not read by the script). |
| `comparison/Baron_1983.csv` | Formatted table, audited only. |
| `comparison/Baron_etal_1983_Table1_compare_to_Baron_1983_csv.R` | **Checking** (QA): snapshot vs `Baron_1983.csv`. |
| `comparison/..._comparison_report_from_R.csv`, `..._mismatches_from_R.csv` | Checking outputs. |
| `old/Baron_etal_1983_species_crosswalk.csv` | Deprecated. Taxonomy harmonization is a later, cross-paper step. |

## 1. Preparation — `Baron_etal_1983_Table1.R` -> `Baron_etal_1983_Table1.csv`

Reads **only** the snapshot. One row per species (76), 12 columns:

`code_Baron1983`, `Anatomy_code` (MOB), `Species_Baron1983`, `Species_former_synonym`, `n`, `n_note`, `volume_mm3`, `volume_note`, `SEM_pct`, `size_index`, `permille_net_brain`, `permille_telencephalon`.

Only obvious in-place fixes: footnote digits dropped; Baron's three abbreviations completed (`semispin.`->semispinosus, `madagascar.`->madagascariensis, `Avahi l.`->Avahi laniger); values parsed to numbers (dashes/blanks -> `NA`); the `*`/`+` markers split into `n_note`/`volume_note`. `Species_former_synonym` translates the superscript footnote into the former Stephan-1981a name — that is information printed in the paper's own Table 1 legend, so it still counts as coming from the paper. The current/MDD species name is **not** included here (it would come from the crosswalk); taxonomy is handled later.

On save it writes the CSV next to the script and a tab-separated copy named by the item's encoded DOI (from `__ReadMe.xlsx`) into the shared `__Public/comparative-data/` folder; if the DOI or folder is missing the TSV is skipped with a warning.

## 2. Checking — `comparison/Baron_etal_1983_Table1_compare_to_Baron_1983_csv.R`

Run from the `comparison/` folder. Matches `Baron_1983.csv` to the snapshot (`../...snapshot.xlsx`) by Baron code and reports two checks: **values** (`n`, MOB volume — 0 mismatches across all 76) and **faithful name** (snapshot vs the CSV's `Species_Baron1983` — **2** transcription typos: 0589 `Oryzoricles`, 3244 `Avahi I.`). No taxonomy/crosswalk is involved.

> **Encoding fix (retained).** `Baron_1983.csv` has a non-UTF-8 byte (`0xCA`) in "Scutisorex somereni" that silently truncated a UTF-8 read; the script reads it with `readr::locale(encoding = "latin1")`.

## 3. Reference / definitions — `reference_tables/`

`Baron_etal_1983_definitions.csv` is the data dictionary (same format as your other `_definitions.csv` files): `MOB`, each value column with its unit, and the legend symbols (`*`, `+`, superscript 1-12, N). It documents the output; the preparation script does not read it. The species crosswalk has been moved to `old/` and is reserved for a later cross-paper taxonomy step.
