# Frahm_etal_1982_Table2

## Source

PDF: `frahm_stephan_1982.pdf` (in this folder). Paper: Frahm, H. D., & Stephan, H. (1982), *Comparison of brain structure volumes in Insectivora and Primates. I. Neocortex*, J. Hirnforsch. 23(4), 375-389. PMID 7161477.

This folder captures **Table 2** — the neocortex **volumes** (total, white matter, grey matter, lamina 1, laminae 2-6) — which is the table that matches `Frahm_1982.csv`. (Table 1 of the paper holds the *relative* measures and the total-neocortex size index; not snapshotted here, by design — see below.)

## Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `frahm_stephan_1982.pdf` | The publication. |
| `frahm_stephan_1982.xlsx` | **Raw** Adobe-PDF-to-Excel export of the whole paper. The neocortex volumes table is split across the sheets **`Table 51`** (Tenrec … Tupaia glis) and **`Table 52`** (Urogale … Homo). Kept for provenance; not read by the scripts. |
| `Frahm_etal_1982_Table2_snapshot.xlsx` | **Snapshot** (sheet `Table2`): Table 2 reproduced to read like the journal page — caption, column header, printed column numbers, then the 38 species in taxonomic order with blank rows separating groups. |
| `Frahm_etal_1982_Table2.R` | Preparation -> `Frahm_etal_1982_Table2.csv` (+ DOI/PMID-named TSV). Reads only the snapshot. |
| `reference_tables/Frahm_etal_1982_Table2_definitions.csv` | Data dictionary + the size-index method (5 structure-specific slopes). |
| `comparison/Frahm_1982.csv` | The formatted volumes table, audited only. |
| `comparison/Frahm_etal_1982_Table2_compare_to_Frahm_1982_csv.R` | Checking (QA): snapshot vs `Frahm_1982.csv`. |

## Snapshot layout

A single **`species`** column followed by the 7 measure columns (total neocortex, white matter, white % of neocortex, grey matter, lamina 1, lamina 1 % of grey, laminae 2-6), with the printed column numbers `(1)`-`(7)`. n is shown in parentheses after the name for the few species with n > 1 (Tupaia glis (2), Microcebus murinus (4), Propithecus verreauxi (2)); the rest are n = 1. The 38 species run in the journal's taxonomic order, with blank rows separating groups (no group/family header rows, no Mean rows, no per-species superscripts — Table 2 doesn't print them). Volumes are from `Frahm_1982.csv`; the two % columns are computed.

This species set includes 7 Old-World monkeys/apes/human (Papio anubis, Cercopithecus ascanius, Colobus badius, Hylobates lar, Pan troglodytes, Pongo sp., Homo sapiens) that have neocortex but no AOB, so they are absent from the Stephan 1982 (AOB) table.

## Why volumes only (not the size-index table)

The paper splits its data: **Table 1** = total-neocortex relative size (% of total brain weight / net brain / telencephalon) + size index; **Table 2** = the volumes. Your `Frahm_1982.csv` is the volumes (Table 2), so that is what the snapshot reproduces. The size indices are a deterministic function of these volumes and **body weights** (external to this table) via reference lines of fixed, structure-specific slope through the basal-Insectivora centroid — **total 0.67, white matter 0.86, grey matter 0.63, lamina 1 0.65, laminae 2-6 0.62** (recorded in the definitions). Recompute them downstream where body weights are joined; the paper's printed Table 1 gives the total-neocortex index for validation.

## Preparation -> `Frahm_etal_1982_Table2.csv`

One row per species (38): `Species_Frahm1982, n, total_neocortex_mm3, white_matter_mm3, white_pct_neocortex, grey_matter_mm3, lamina_1_mm3, lamina_1_pct_grey, laminae_2_6_mm3`. The R script reads past the 3 header rows, keeps the species rows (skipping the blank group separators), and splits the parenthetical n off the name. Current accepted names + taxonomy are applied later via `../_keys/Stephan/`. Also writes a DOI/PMID-named TSV to `../__Public/comparative-data/`.

## Checking -> `comparison/`

Matches snapshot to `Frahm_1982.csv` by species (on either the 1982 name or the canonical name, so OCR artifacts in the CSV's name column still resolve) and compares the five volumes + n. Verified: **38 matched, 0 value mismatches.**

## Data note

`Frahm_1982.csv` carries a few OCR artifacts in `Species_Frahm1982` (`Microceblls murinus`, truncated `Daubentonia madagascar.`, a blank name for Pongo). The snapshot uses clean journal names; the comparison matches across them via the canonical name. Worth fixing at the source CSV.
