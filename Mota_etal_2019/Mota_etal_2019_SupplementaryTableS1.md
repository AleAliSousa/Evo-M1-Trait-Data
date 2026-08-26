# Mota et al. 2019 — Supplementary Table S1 (README)

Mota B, Dos Santos SE, Ventura-Antunes L, et al. (2019). *White matter volume and white/gray
matter ratio in mammalian species as a consequence of the universal scaling of cortical folding.*
PNAS 116(30):15253–15261. https://doi.org/10.1073/pnas.1716956116

*(This file was a placeholder stub — "1 File" — until 2026-08-25; expanded when the table was
wired into a merge.)*

## What the data are
One row per species (38 mammals), the Mota/Herculano-Houzel lab's own hemisphere measurements:
`VT/VG/VW` = total / gray / white cortical volume (mm³); `AT` = **total** cortical surface,
`AE` = **exposed** cortical surface (mm²); `T` = mean cortical thickness (mm); `N` = number of
cortical neurons. **All per ONE cortical hemisphere** (lab convention, as in Mota & HH 2015).

## Source → Snapshot → Data readable
`pnas.1716956116.sd01.docx` + `pnas.1716956116.sapp.pdf` (frozen) →
`Mota_etal_2019_SupplementaryTableS1.xlsx` (snapshot) → `Mota_etal_2019_SupplementaryTableS1.R` →
`Mota_etal_2019_SupplementaryTableS1.csv` (**use this**) → public TSV
`10.1073%2Fpnas.1716956116_SupplementaryTableS1.tsv`. Registry item
`Mota_etal_2019_SupplementaryTableS1` (FINISHED).

## Printed-name errors (repaired at merge level, not in the frozen data)
The printed table contains species-name typos: `Girafa camelopardalis` (→ *Giraffa*),
`Tragelaphus stripceros` (→ *T. strepsiceros*), `Dasyprocta primnolopha` (→ *D. prymnolopha*;
the 2015 paper prints a different misspelling, `promnolopha`), and `Papio anubis` (= the merge's
*Papio cynocephalus anubis*). The TSV keeps the printed names; the aliases live in
`__merging_cortical_areas/cortical_areas_compiled.R` (`sp_alias`).

## Printed-value errors found 2026-08-25 (frozen data untouched; repaired at merge level)
1. **T column:** 6 species (*Cavia, Dasyprocta, Hydrochoerus, Callimico, Macaca radiata,
   M. fascicularis*) print the AT/AE folding ratio where thickness belongs; *Sarcophilus* prints
   1198 (decimal slip). The intended value is the paper's own definition T = VG/AT, which the other
   31 rows satisfy exactly and which matches Mota 2015's printed T for the shared hemispheres.
2. **VG column (Cavia only):** printed VG = 412.4 fails VG + VW = VT (506.9 ≠ 906.9); the only
   additivity failure in the table. Recovered as VT − VW = 812.4 (→ T = 1.515 = the 2015 value).
   **Anyone wiring VT/VG/VW into `__merging_volumes` later must carry this Cavia repair.**
Repair logic + audit: `__merging_cortical_areas/cortical_areas_compiled.R` and its README.

## Relationship to Mota & Herculano-Houzel 2015 (Science) Table S1
Same lab, same hemisphere-measurement program. Where both tables print the same species, the
values are identical (agouti AT 1412.7 ≈ AG 1413; kudu 22,203; giraffe 40,128) — **2019 is a
re-report/extension, not an independent series.** In the merge, 2019 supersedes the 2015 own
columns per species × term.

## Merge note — partially WIRED into `__merging_cortical_areas` (2026-08-25, owner decision)
- **Wired:** `AT_mm2` → `CorticalSurface_Area.mm2`, `AE_mm2` → `CorticalExposedSurface_Area.mm2`,
  `T_mm` → `CorticalThickness.mm` (38 species with values; all per one hemisphere).
- **HELD:** `VT/VG/VW` cortical volumes — await a `__merging_volumes` overlap audit (grey/white
  cortical volumes vs Stephan/HH cortex volumes) before any wiring.
- **Skipped:** `N` (cortical neurons) — largely a compilation of the lab's previously published
  counts already in `__merging_cellcounts` via the HH-team tables; ingesting it would double-count.
- Excluded from `__merging_gyrification` (the derivable AT/AE folding index is MHH's FI, not the
  Zilles GI).
