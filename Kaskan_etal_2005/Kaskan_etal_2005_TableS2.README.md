# Kaskan et al. 2005 — Electronic Appendix B, Table 2 (retinal area, rod & cone counts)

Kaskan PM, Franco ECS, Yamada ES, Silveira LCL, Darlington RB, Finlay BL (2005). *Peripheral
variability and central constancy in mammalian visual system evolution.* Proc R Soc Lond B
272:91–100. doi:10.1098/rspb.2004.2925.

## ⚠️ Registration mismatch — please review

**This item was pre-registered in `__ReadMe.xlsx` as two entries, `Kaskan_etal_2005_Figure2` and
`Kaskan_etal_2005_Figure3`.** Having now read the actual PDFs, neither figure is buildable:

- **Figure 2** ("Cortical area scaling") and **Figure 3** ("Visual cortical scaling in nocturnal
  and diurnal [mammals]") both plot **phylogenetically independent contrasts** (CAIC method) —
  regression slopes of log-transformed cortical-area ratios, not raw comparable measurements. The
  underlying raw surface-area values are not tabulated anywhere in this paper or its supplement;
  the electronic Appendix A "Table 1" lists only *which* named cortical areas were present per
  species (a presence/naming table), not their sizes. Digitizing points off Figures 2–3 would only
  reconstruct derived contrast statistics, not source data — this repository's own convention
  (`PROJECT_SCOPE_AND_DATASET_ROADMAP.md`) explicitly excludes ingesting "secondary slopes, PCA
  loadings, or plot points" as a new measurement team, so these were **not built**.
- Instead, the paper's supplement (`pb050091supp.pdf`) contains a genuinely tabular, buildable
  dataset not mentioned in the original registration: **Electronic Appendix B, Table 2** — retinal
  area and rod/cone photoreceptor counts for 5 New World primate species, individual specimens.
  **This is what was built here**, registered as `Kaskan_etal_2005_TableS2` — a different Item
  name than either pre-registered row. **The two pre-existing registry rows
  (`Kaskan_etal_2005_Figure2`, `Kaskan_etal_2005_Figure3`) are left untouched; this is a third,
  additional row**, pending the owner's decision on whether to keep, retitle, or remove the
  Figure2/Figure3 placeholders.

## What this covers

Retinal area (mm²), total cone count, and total rod count for individual specimens of 5 New World
primates — *Callithrix jacchus* (n=2), *Saguinus m. niger* (n=4), *Aotus* sp. (n=2), *Saimiri
ustius* (n=4), *Cebus apella* (n=7) — 19 specimens total. This is the primary data behind the
paper's Figure 4 discussion of "total rod and cone numbers" contrasting nocturnal and diurnal
species' visual peripheries.

## Source → snapshot → CSV

- **Source:** `pb050091supp.pdf` (the paper's electronic supplement), in this folder — a
  born-digital PDF; text extraction was clean and every value was cross-checked against a 200 dpi
  page-image render (page 3 of 3). The main paper PDF (`Kaskan-2005-Peripheral variability and
  central.pdf`) contains no additional tabulated data usable here.
- **Snapshot:** `Kaskan_etal_2005_TableS2_snapshot.csv` — journal-faithful layout including the
  printed per-species mean and standard-deviation rows.
- **Analysis CSV:** `Kaskan_etal_2005_TableS2.csv` — long format, **individual specimens only**
  (mean/SD rows excluded, since they are simple descriptive statistics of the rows already
  present); adds two derived columns not printed in the source, `cone_density_per_mm2` and
  `rod_density_per_mm2` (= count / retinal_area_mm2).

## Verification

Every species' printed mean and standard deviation for all three columns (retinal area, cone
count, rod count) were independently recomputed from the individual case values and matched the
printed summary statistics exactly (checked by script, all 5 species × 3 columns × 2 statistics =
30 values, zero discrepancies).
