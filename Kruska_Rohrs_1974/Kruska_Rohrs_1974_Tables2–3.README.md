# Kruska & Röhrs 1974 — Tables 2–3 (brain-section volumes, feral vs. domestic pigs)

Kruska D, Röhrs M (1974). *Comparative-quantitative investigations on the brains of feral pigs
from the Galapagos Islands and of European domestic pigs.* Z Anat Entwicklungsgesch 144:61–73.

## What this covers

Tables 2 and 3 report absolute volumes (mm³, by photographic/planimetric reconstruction) of 16
brain structures (5 fundamental sections, their allocortical/limbic subdivisions) plus brain
weight (g) and total brain volume (mm³), for:
- **4 feral pigs** from the Galapagos Islands (Table 2: specimens A23, A21, A26, A22)
- **6 domestic pigs** (Table 3: specimens Sd5, Sd9, Sd31, Sd19, Sd17, Sd12)

This is the structural counterpart to the paper's Table 1 (body/brain weights only, not part of
this item) and precedes Tables 4–6 (percentages and geometric-mean comparisons derived from these
same volumes — not separately registered, see below).

## Source → snapshot → CSV

- **Source:** `Kruska-1974-Comparative--quantit.pdf`, in this folder. Text-layer extraction was
  clean and numeric; every value was independently cross-checked against 200 dpi page-image
  renders (pages 5–6 of 13, printed pages 65–66) and all matched exactly, including the two
  "damaged olfactory bulb" footnote markers per table.
- **Snapshots:** `Kruska_Rohrs_1974_Table2_snapshot.csv` (feral) and
  `Kruska_Rohrs_1974_Table3_snapshot.csv` (domestic) — journal-faithful wide layout, one column
  per specimen, preserving the printed structure order and footnote.
- **Analysis CSV:** `Kruska_Rohrs_1974_Tables2-3.csv` — long format, one row per
  (population × specimen × structure): `population`, `specimen_id`, `structure_var`,
  `structure_label`, `volume_mm3`, `brain_weight_g`, `total_brain_volume_mm3`, `note`.

## Verification

Checked by script across all 10 specimens:
- **Telencephalon = Neocortex + Corpus striatum + Allocortex** — exact for 6/10 specimens; off by
  1 mm³ for A26, Sd5, Sd31 and Sd19 (rounding).
- **limbic structures = Septum + Hippocampus + Schizocortex** — exact for 6/10 (all 4 feral pigs and
  Sd9, Sd19); the printed total is 1 mm³ above the parts for Sd17 and Sd12 and 2 mm³ above for Sd5
  and Sd31. Re-checked against the PDF (Table 3, p. 66): these are the printed values, i.e. the
  paper's own rounding, and are kept as printed. (An earlier version of this README said "exact for
  all 10"; that was wrong, and the build's 1 mm³ tolerance stopped the script on Sd5/Sd31.)
- **Amygdaloid complex = centromedial group + basolateral group** — exact for 9/10, off by 1 mm³
  for A22 (rounding).
- **Tolerance used by the build:** a printed total may differ from the sum of its *k* printed
  (integer-rounded) parts by up to (*k* + 1)/2 mm³ from rounding alone — 2 mm³ for the 3-part
  sums, 1 mm³ for the 2-part amygdaloid sum. Anything larger stops the build.
- **Total brain volume ≠ sum of the 5 major divisions** (Medulla + Cerebellum + Mesencephalon +
  Diencephalon + Telencephalon) for any specimen — consistently 3,000–4,300 mm³ *higher* than that
  sum across all 10 specimens. This is a genuine, systematic feature of the source table (implying
  additional untabulated brain volume — e.g. corpus callosum, ventricular space — beyond the 5
  itemized divisions), not a transcription error. Retained as printed, flagged here per house
  convention for source arithmetic that does not fully reconcile (cf. `Baron_etal_1996`'s two
  documented Table 32 component-sum inconsistencies).

## Not registered as separate items

Tables 4 and 5 (percentages of total brain volume, same two populations) and Table 6 (geometric
means, variability coefficients, and t-test comparisons across the two populations) are all
**derived from Tables 2–3's absolute volumes**, not independent measurements — consistent with
this registry's convention of registering the primary volumetric table and treating
percentage/statistical tables computed from it as supplementary. Table 1 (individual body
weights, net body weights, capture data for the feral pigs only) is a different data type
(morphometric/collection metadata rather than brain-structure volumes) and is likewise not part
of this item.
