# Kruska 2014 — Tables 2–3 (brain-structure volumes, wild cavies vs. guinea pigs)

Kruska DCT (2014). *Comparative quantitative investigations on brains of wild cavies (Cavia
aperea) and guinea pigs (Cavia aperea f. porcellus). A contribution to size changes of CNS
structures due to domestication.* Mammalian Biology, http://dx.doi.org/10.1016/j.mambio.2013.12.005

## What this covers

Tables 2 and 3 report fresh (unfixed) brain weight (g) and absolute volumes (mm³, from serial-
section reconstruction) of 24 brain structures, plus each structure's percentage of "pure brain
tissue" (total brain volume minus rest tissue and ventricular space), for:
- **6 wild cavies** (Table 2: prep. nos. 19269, 19263, 19267 male; 19256, 19255, 19257 female)
- **6 guinea pigs** (Table 3: prep. nos. 18477, 18206, 18205, 18719 male; 18731, 18733 female)

This is a direct successor study to `Kruska_Rohrs_1974` (feral vs. domestic pigs) — same
wild-vs-domesticated comparative design, same house measurement lineage, applied to *Cavia*.

## Source → snapshot → CSV

- **Source:** `Kruska-2014-Comparative quantitative investiga.pdf`, in this folder. This is a
  born-digital PDF (not scanned) with a clean, accurate text layer; every value was nonetheless
  cross-checked against a 200 dpi page-image render (page 4 of 10) and matched exactly, including
  three-decimal-place volumes.
- **Snapshots:** `Kruska__2014_Table2_snapshot.csv` (wild) and `Kruska__2014_Table3_snapshot.csv`
  (guinea pig) — journal-faithful wide layout, printed percentages kept in parentheses exactly as
  shown.
- **Analysis CSV:** `Kruska__2014_Tables2-3.csv` — long format, one row per
  (population × specimen × structure): `population`, `specimen_id`, `sex`, `structure_var`,
  `structure_label`, `volume_mm3`, `pct_of_pure_brain` (printed, not recomputed), plus per-specimen
  `total_brain_weight_g`, `total_brain_volume_mm3`, `rest_tissue_mm3`, `ventricle_mm3`,
  `pure_brain_tissue_mm3`.

## Verification

Checked by script across all 12 specimens — **every level of this table's hierarchy reconciles
exactly** (< 0.01 mm³), unlike the companion `Kruska_Rohrs_1974` table, which has a systematic,
unreconciled gap at the top level:
- Telencephalon = Neocortex(total) + Corpus striatum + Allocortex(total)
- Neocortex(total) = Neocortex(grey matter) + Neocortex(white matter)
- Allocortex(total) = Olfactory allocortex + Non-olfactory allocortex
- Olfactory allocortex = Bulbus olfactorius + Regio retrobulbaris + Tuberculum olfactorium +
  Regio praepiriformis + Nucleus amygaloideus + Basal nuclei
- Non-olfactory allocortex = Septum telencephali + Hippocampus + Schizocortex
- Pure brain tissue = Medulla oblongata + Cerebellum + Mesencephalon + Diencephalon + Telencephalon
- Pure brain tissue = Total brain volume − Rest tissue − Ventricle

## Not registered as separate items

**Table 1** (percentage shrinkage of brain volume due to fixation, per specimen) is fixation
methodology, not a comparative brain-structure measurement, and is not part of this item. **Table 4**
(geometric means, variability coefficients, and between-group percentage differences) is derived
from Tables 2–3's absolute volumes, not an independent measurement — consistent with this
registry's convention (see `Pirlot_Kamiya_1982`, `Pirlot_Kamiya_1985`, `Kruska_Rohrs_1974` for the
same pattern applied to their respective papers' derived tables).
