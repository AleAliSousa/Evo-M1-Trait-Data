# Matano_etal_1985_a_Table1

## Source

PDF: `Matano-1985-Volume comparisons i 2.pdf` (in this folder; 22 pp.). Paper: Matano, S., Baron, G., Stephan, H., & Frahm, H. D. (1985), *Volume comparisons in the cerebellar complex of primates. II. Cerebellar nuclei*, Folia Primatol. 44(3-4), 182–203. https://doi.org/10.1159/000156212. Registry sequence **a**, Item number **Table 1**.

**Table I — body weights and the cerebellar-nuclei volumes** (total TCN, medial MCN, interpositus ICN, lateral LCN) for 56 species (Insectivora, Scandentia, Prosimians, Simians). The printed table also carries size indices and ratios/percentages of the three nuclei; those are **derived/relative** and recomputed downstream, so only the **body-weight and four nuclear-volume** columns are snapshotted.

## Folder ↔ registry (now consistent)

This folder is registry **sequence a** = the cerebellar-nuclei paper (DOI 10.1159/000156212), and the data token is **Matano1985a** throughout (comparison CSV, `_keys/Stephan/species_key.csv`, `anatomy_key.csv`). The TSV is named by the standard Item-name lookup → `10.1159%2F000156212_Table1.tsv`. *(This folder previously held the ventral-pons paper; the a/b labels were flipped to match `__ReadMe.xlsx`.)*

## Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `Matano-1985-Volume comparisons i 2.pdf` | The publication (Part II, cerebellar nuclei). |
| `Matano-1985-Volume comparisons i 2.xlsx` | **Raw** Adobe-PDF-to-Excel export. Kept for provenance; not read by the scripts. |
| `Matano_etal_1985_a_Table1_snapshot.xlsx` | **Snapshot** (sheet `Table1`): the body-weight + four nuclear-volume columns of Table I (printed order: BoW, TCN, MCN, ICN, LCN), in code order, with grade headers and printed column numbers (1)–(8). |
| `Matano_etal_1985_a_Table1.R` | Preparation → `Matano_etal_1985_a_Table1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Matano_etal_1985_a_Table1_definitions.csv` | Data dictionary: the four nuclei + body weight + n. |
| `comparison/Matano_1985a.csv` | The formatted master table (nuclei rows), audited only. |
| `comparison/Matano_etal_1985_a_Table1_compare_to_Matano_1985a_csv.R` | Checking (QA): snapshot ↔ `Matano_1985a.csv`. |

## Preparation → `Matano_etal_1985_a_Table1.csv`

One row per species (56): `code, Species_Matano1985a, n, body_weight_g, TCN_mm3, MCN_mm3, ICN_mm3, LCN_mm3`. The R script reads past the 3 header rows and keeps the rows with a numeric TCN volume (dropping the grade-header rows). Volumes are already in mm³ (no conversion). *Alouatta seniculus* (code 3363) has its code restored from the printed table (the CSV left it blank). Also writes a DOI-named TSV (`10.1159%2F000156212_Table1.tsv`) to `../__Public/comparative-data/`.

## Checking → `comparison/`

Matches snapshot to `Matano_1985a.csv` by species (paper name or canonical, each CSV row resolved once) and compares TCN, MCN, ICN, LCN, body weight and n. Verified: **56 matched, 0 value mismatches.** `Rattus norvegicus` and `Spalax ehrenbergi` carry a TCN value but **no paper species name** in the CSV → reported as **csv-only**; these are partial additions from other sources (compatible older-style data), not Matano's measurements (see Frahm et al. 1997, the rat/Spalax volume paper).
