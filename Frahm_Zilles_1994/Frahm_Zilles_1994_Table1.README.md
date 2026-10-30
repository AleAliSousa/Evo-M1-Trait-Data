# Frahm_Zilles_1994_Table1

## Source

PDF: `frahm_zilles_1994.pdf` (in this folder). Paper: Frahm, H. D., & Zilles, K. (1994), *Volumetric comparison of hippocampal regions in 44 primate species*, J. Hirnforsch. 35(3), 343–354. PMID 7983368. Registry Item number **Table 1**.

Hippocampal-region volumes for **48 species (4 Insectivora + 44 primates)**. The paper splits the data over **two printed tables**, both reproduced (as two sheets) in the one snapshot:

- **Table 1** (p. 347) — body weight + the main hippocampal volumes: total hippocampus, HP + HS fibres, retrocommissural hippocampus.
- **Table 2** (p. 348) — the six retrohippocampal region volumes: subiculum, CA1, CA2, CA3, hilus, fascia dentata.

(retrocommissural hippocampus = sum of the six Table-2 subfields; total hippocampus = retrocommissural + HP/HS fibres.) All volumes in mm³.

## Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `frahm_zilles_1994.pdf` | The publication (Table 1 p. 347; Table 2 p. 348). |
| `frahm_zilles_1994.xlsx` | **Raw** Adobe-PDF-to-Excel export (mostly article text; the tables did not extract cleanly). Kept for provenance; not read by the scripts. |
| `Frahm_Zilles_1994_Table1_snapshot.xlsx` | **Snapshot** with two sheets: `Table1` (body weight + total / HP+HS fibres / retrocommissural) and `Table2` (subiculum, CA1, CA2, CA3, hilus, fascia dentata). Species in printed taxonomic order, blank rows separating Insectivora / Prosimians / Simians (no grade headers, no n column — as printed). |
| `Frahm_Zilles_1994_Table1.R` | Preparation → `Frahm_Zilles_1994_Table1.csv` (+ PMID-named TSV). Reads only the snapshot; joins the two sheets by species. |
| `reference_tables/Frahm_Zilles_1994_Table1_definitions.csv` | Data dictionary: the 9 hippocampal volumes + body weight. |
| `comparison/Frahm_1994.csv` | The formatted master table (all regions), audited only. |
| `comparison/Frahm_Zilles_1994_Table1_compare_to_Frahm_1994_csv.R` | Checking (QA): merged snapshot ↔ `Frahm_1994.csv`. |

## Preparation → `Frahm_Zilles_1994_Table1.csv`

One row per species (48): `Species_Frahm1994, body_weight_g, hippocampus_total_mm3, HP_HS_fibers_mm3, hippocampus_retrocommissuralis_mm3, subiculum_mm3, CA1_mm3, CA2_mm3, CA3_mm3, hilus_mm3, fascia_dentata_mm3`. The R script reads past the 2 header rows on each sheet, keeps the species rows (numeric volume; drops blank separators and the footnote), and joins the two sheets by species. Volumes are already in mm³ (no conversion). Also writes a PMID-named TSV (`PMID%3A7983368_Table1.tsv`) to `../__Public/comparative-data/`.

## Checking → `comparison/`

Matches the merged snapshot to `Frahm_1994.csv` by species (paper name or canonical, each CSV row resolved once) and compares all ten shared measures (body weight, the three main hippocampal volumes, and the six subfields). Verified: **48 matched, 0 value mismatches, no snapshot-only or csv-only rows.**

## Data note

The printed journal names are kept in the snapshot and analysis CSV (e.g. *Lemur albifrons* = *Eulemur fulvus*; *Cebuella pygmaea* = *Callithrix pygmaea*; *Cercocebus albigena* = *Lophocebus albigena*; *Colobus badius* = *Piliocolobus badius*; *Tarsius spec.*; *Avahi laniger laniger* / *Avahi l. occidentalis*; *Gorilla gorilla* = canonical *Gorilla sp.*). Current accepted names + taxonomy are applied later via `../_keys/Stephan/`.
