# Mota & Herculano-Houzel 2015 — Table S1 (cortical folding: exposed area, folding index, thickness)

Mota B, Herculano-Houzel S (2015). *Cortical folding scales universally with surface area and
thickness, not number of neurons.* Science 349(6243):74–77. doi:10.1126/science.aaa9101

Table S1 = **"Datasets used in this study. All values refer to one cortical hemisphere only."**
For 63 mammal species (66 records) it reports, per hemisphere: exposed cortical surface area
(**AG**, mm²), a **folding index (FI)**, and mean cortical thickness (**T**, mm), in two blocks —
the authors' **own dataset** and values compiled from **other datasets** (with a reference code).

## Important: FI here is NOT the Zilles GI
Mota & Herculano-Houzel's **folding index (FI)** is a different measure from the Zilles
**gyrification index (GI)** used by Lewitus 2014 and Zilles 2013. The two are **not
interchangeable and are never pooled**. This table was built for completeness of the folding
cluster; it is **excluded from the GI-only merge** (`__merging_gyrification`), which uses GI
sources only. AG (exposed surface area) belongs with the cortical-surface data, not GI.

## Why this was built
The paper was present as raw supplement (`mota.sm.xlsx`, `mota.sm.pdf`) and registered in
`__ReadMe.xlsx` as `Mota_Herculano-Houzel_2015_TableS1`, but had no snapshot, script, or CSV/TSV.
This build adds the house pipeline.

## Source → snapshot → CSV
- **Source:** `mota.sm.xlsx` (sheet "Table 2" = the supplement's Table S1), in this folder.
- **Snapshot:** `Mota_etal_2015_TableS1_snapshot.xlsx` (sheet `TableS1`) — a **verbatim** copy of
  the supplement sheet, preserving the two-tier header ("Our dataset" / "Other datasets"), the
  taxonomic section-header rows, the species *Globicephala macrorhyncha* printed **split across two
  rows**, an in-cell newline in *Cercopithecus aethiops*, `n.a.` for missing values, and the
  paper's trailing reference list.
- **Reformat:** `Mota_etal_2015_TableS1.R` drops the title/group/header rows, tracks the running
  `taxon_group`, re-joins the split Globicephala row, repairs the newline, maps `n.a.`→NA, resolves
  species (`species_sci` = accepted binomial, `Species` = printed), keeps one row per printed
  record (duplicate species with >1 record kept), stops at the reference list, and writes:
  - `Mota_etal_2015_TableS1.csv` (66 records, 63 species)
  - `__Public/comparative-data/10.1126%2Fscience.aaa9101_TableS1.tsv`

## Columns
`species_sci`, `Species`, `taxon_group`, `AG_own_mm2`, `FI_own`, `T_own_mm`,
`AG_other_mm2`, `FI_other`, `T_other_mm`, `Reference`.

## File naming (registry override)
On-disk files follow the folder (`Mota_etal_2015_TableS1`); the `__ReadMe.xlsx` registry Item name
is `Mota_Herculano-Houzel_2015_TableS1`. The script sets `registry_item_name` explicitly for the
Item-encoded (DOI) TSV lookup — same override pattern as `Zilles_Rehkämper_1988`.

## Duplicate species
*Vulpes vulpes* (2 records), *Homo sapiens* (2), *Equus caballus* (2) each appear more than once
with different measurements; kept as separate rows.

## Checks
Snapshot↔CSV diff = row-structure cleanup only (group headers removed, split row joined, newline
repaired, `n.a.`→NA) + `species_sci`. 36 of 63 species resolve to a canonical binomial in
`_keys/species_reference.csv`; the rest (mostly non-primate) pass through as cleaned printed names.

## Correction (2026-08-25) — AG is the TOTAL surface, not the exposed surface
`Mota_etal_2015_definitions.csv` originally defined AG as "exposed (pial)" surface. The paper
defines the folding index as *"the ratio of total surface area AG to exposed surface area AE"*
(FI = AG/AE), so **AG is the total (pial incl. sulcal) grey surface of one hemisphere**; AE = AG
only for lissencephalic species (FI = 1). The definitions file is corrected (Measure now
`TotalSurface.mm2`). This also removed a wrong prescription in
`__merging_cortical_areas/README__merging.md` that said to totalize via `AG × FI` — that would have
double-folded the values.

## Merge note — WIRED into `__merging_cortical_areas` (2026-08-25, owner decision)
**Own columns only**: `AG_own_mm2` → `CorticalSurface_Area.mm2`, `FI_own` → `FoldingIndex_MHH`,
`T_own_mm` → `CorticalThickness.mm` (all per ONE hemisphere). The `_other` columns are values
compiled from other papers — secondary, never merged. **Lineage supersede:** Mota et al. 2019
(PNAS) re-reports the same hemisphere measurements (identical AT values where both print), so every
2015 own surface/thickness value is `superseded_by_Mota_etal_2019` in the merge long table;
`FoldingIndex_MHH` exists only here and stays active. Printed-name repairs (Giraffa/Tragelaphus/
Dasyprocta/Papio) live in the merge's `sp_alias`. Still excluded from `__merging_gyrification`
(FI ≠ Zilles GI).
