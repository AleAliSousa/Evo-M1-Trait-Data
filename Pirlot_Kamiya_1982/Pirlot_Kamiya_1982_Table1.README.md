# Pirlot & Kamiya 1982 — Table 1 (brain components, % of total brain and absolute volumes)

Pirlot P, Kamiya T (1982). *Relative size of brain and brain components in three gliding
placentals (Dermoptera: Rodentia).* Can J Zool 60:565–572. doi (not assigned by journal at
publication date; registry key uses `PMID` per house convention — see registry row for the
identifier actually used).

## What this covers

Table 1 reports, for 11 brain components, each component's volume as a **percentage of total
brain volume** and its **absolute volume** (parentheses in the original) in three individually
perfused gliding-mammal specimens — *Cynocephalus* (colugo, n=1), *Iomys* (flying squirrel, n=1),
*Glaucomys* (northern flying squirrel, n=1, immature) — plus a fourth column, **Pteropodids**, a
7-species **average** (not a specimen) drawn from Stephan et al. (1974) for comparison, printed as
a percentage plus a min–max volume range across those 7 species.

## Source → snapshot → CSV

- **Source:** `Pirlot-1982-Relative Size of Bra.pdf`, in this folder. The PDF's text layer garbles
  the numeric columns of Tables 1 and 3 (columns collapse/drop under `pdftotext`), so **Table 1 and
  Table 3 were transcribed from a 200 dpi page render** (page 4 of 9) and cross-checked; Table 2
  extracted cleanly from the text layer and was cross-checked against the same page image.
- **Snapshot:** `Pirlot_Kamiya_1982_Table1_snapshot.csv` — journal-faithful layout: one row per
  brain-component code, with %/volume pairs per taxon, preserving the printed abbreviation
  footnote and the Pteropodids range format.
- **Analysis CSV:** `Pirlot_Kamiya_1982_Table1.csv` — long format, one row per
  (species × brain component): `species`, `species_sci`, `specimen_type`, `body_weight_g`,
  `brain_weight_g`, `brain_component_code`, `brain_component_name`, `pct_of_total_brain`,
  `volume_mm3` (individual specimens) or `volume_mm3_min`/`volume_mm3_max` (Pteropodids row only),
  `total_brain_volume_mm3`.

## Verification

- Each specimen's 11 `pct_of_total_brain` values sum to exactly 100.00 (checked by script).
- Each specimen's 11 component volumes sum to within 0.2 mm³ of the printed table Total
  (5781.3 vs. printed 5781.1 for *Cynocephalus*; 2094.5 vs. 2094.6 for *Iomys*; 899.3 vs. 899.3 for
  *Glaucomys* — exact) — consistent with normal rounding in a hand-tabulated 1982 print table, not a
  transcription error.

## Not registered as separate items

The paper's **Table 2** (percentage data on the telencephalon: Tel/Br, N/Tel, RH/Tel, St/Tel,
H/Tel) and **Table 3** (progression indices for brain components, relative to a basal-insectivore
reference) are both **derived from Table 1's absolute volumes**, not independent measurements —
consistent with this registry's convention of registering the primary volumetric table and treating
ratio/index tables computed from it as supplementary, not separate registry rows. Both are kept as
reference images/notes in `reference_tables/` for anyone who wants the printed ratios without
recomputing them, but are not exposed as their own `__ReadMe.xlsx` Item.

## Units

The paper does not print an explicit unit for the Table 1 volumes. mm³ is used here, consistent with
every other Stephan/Pirlot-lineage volumetric table already in this registry (e.g. `Stephan_Pirlot_1970`,
`Kamiya_Pirlot_1980`), which share the same measurement method (Stephan 1967) and always report in mm³.
