# Matano_etal_1985_b_Table1

## Source

PDF: `Matano-1985-Volume comparisons i.pdf` (in this folder; scanned image, 11 pp.). Paper: Matano, S., Stephan, H., & Baron, G. (1985), *Volume comparisons in the cerebellar complex of primates. I. Ventral pons*, Folia Primatol. 44(3-4), 171–181. https://doi.org/10.1159/000156211. Registry sequence **b**, Item number **Table 1**.

**Table I — body weights and ventral pons (VPo) volumes** for 48 species (Insectivora, Scandentia, Prosimians, Simians). The printed table also carries size indices (VPo, neocortex, cerebellum), VPo:NEO and VPo:CER ratios, and VPo as % of brain stem; those are **derived/relative** and recomputed downstream (and the 1985 scan's index columns are unreliable to OCR), so only the **body-weight and ventral-pons-volume** columns are snapshotted.

**Structure-key rule:** the paper defines VPo as the ventral/basilar part of
the pons and distinguishes it from the dorsal/tegmental part in the
Introduction. Therefore `ventral_pons_mm3` maps only to
`Ventral_pons_Vol.mm3`; it is not a global alias of `Pons_Vol.mm3`. The Pongo
`Pons = 4300` value in `Stephan_primates` comes instead from Zilles & Rehkamper
Table 12-2's broader pons row, as the absence of Pongo from Matano Table I also
shows.

## Folder ↔ registry (now consistent)

This folder is registry **sequence b** = the ventral-pons paper (DOI 10.1159/000156211), and the data token is **Matano1985b** throughout (comparison CSV, `_keys/Stephan/species_key.csv`, `anatomy_key.csv`). The TSV is named by the standard Item-name lookup → `10.1159%2F000156211_Table1.tsv`. *(This folder previously held the cerebellar-nuclei paper; the a/b labels were flipped to match `__ReadMe.xlsx`.)*

## Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `Matano-1985-Volume comparisons i.pdf` | The publication (Part I, ventral pons). |
| `Matano-1985-Volume comparisons i.xlsx` | **Raw** Adobe-PDF-to-Excel (OCR) export. Kept for provenance; not read by the scripts. |
| `Matano_etal_1985_b_Table1_snapshot.xlsx` | **Snapshot** (sheet `Table1`): the body-weight + ventral-pons-volume columns of Table I, in code order, with grade headers (Insectivora / Scandentia / Prosimians / Simians) and the printed column numbers (1)–(5). |
| `Matano_etal_1985_b_Table1.R` | Preparation → `Matano_etal_1985_b_Table1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Matano_etal_1985_b_Table1_definitions.csv` | Data dictionary: VPo volume + body weight + n. |
| `comparison/Matano_1985b.csv` | The formatted master table (VPo rows), audited only. |
| `comparison/Matano_etal_1985_b_Table1_compare_to_Matano_1985b_csv.R` | Checking (QA): snapshot ↔ `Matano_1985b.csv`. |

## Preparation → `Matano_etal_1985_b_Table1.csv`

One row per species (48): `code, Species_Matano1985b, n, body_weight_g, ventral_pons_mm3`. The R script reads past the 3 header rows and keeps the rows with a numeric VPo volume (dropping the grade-header rows). Volumes are already in mm³ (no conversion). Also writes a DOI-named TSV (`10.1159%2F000156211_Table1.tsv`) to `../__Public/comparative-data/`.

## Checking → `comparison/`

Matches snapshot to `Matano_1985b.csv` by species (paper name or canonical, each CSV row resolved once) and compares VPo volume, body weight and n. Verified: **48 matched, 0 value mismatches.** `Pongo sp.` carries a VPo value (4300) but **no paper species name** in the CSV → reported as **csv-only** — an expected post-1985 addition (Matano measured *Pan*, *Gorilla* and *Homo* among the apes, not *Pongo*); see `_checks/check_Zilles_Rehkamper_1988_provenance.R`.
