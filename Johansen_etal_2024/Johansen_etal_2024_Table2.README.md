# Johansen et al. 2024 — Table 2 (human regional SV2A synaptic density)

Johansen A, Beliveau V, Colliander E, Raval NR, Dam VH, et al. (2024). *An In Vivo High-Resolution
Human Brain Atlas of Synaptic Density.* J. Neurosci. 44(33):e1750232024.
doi:10.1523/JNEUROSCI.1750-23.2024.

Registry (`__ReadMe.xlsx`): Item name **`Johansen_etal_2024_Table2`**, encoded
`10.1523%2FJNEUROSCI.1750-23.2024_Table2`.

## ⚠️ Single-species (human) reference atlas — not comparative across species
This is an **in vivo human** synaptic-density atlas (SV2A Bmax via [11C]UCB-J PET), one species only.
It contributes human regional data points — notably **primary motor cortex** — to the comparative
dataset rather than a cross-species row set. The supplementary `.xlsx` files (s007/s008) are
**regression-coefficient tables** (age/sex/IQ effects) and are deliberately **not** extracted (derived
statistics, cf. house rule §7); Table 2 is the values table and is what is built here.

## What the data are
**49 rows** = brain regions (Desikan–Killiany cortical parcellation + subcortical), grouped by
**Lobe**, each with SV2A Bmax (**pmol/mL**) as a whole-region weighted average (**Total**) and
separately for **Left** and **Right** hemispheres, plus **SD** and **COV (%)**, and a **left/right
ratio**. Two flags: `is_M1` (Precentral = primary motor cortex; total 547 pmol/mL) and
`is_lobe_total` (the four "… (total)" lobe aggregates — exclude when treating individual regions as
units). Midline structures (Pons, White matter) have only Total values.

## Source → Snapshot → Data readable  (printed PDF → snapshot required)
The source is a **printed PDF table**, so a hand-verified snapshot is the frozen source (§0a
invariant 1). Table 2 (p.5) → **`Johansen_etal_2024_Table2_snapshot.xlsx`** (sheet "Table2", captured
and validated cell-by-cell) → `Johansen_etal_2024_Table2.R` → **`Johansen_etal_2024_Table2.csv`**
(use this) + the public TSV
`__Public/comparative-data/10.1523%2FJNEUROSCI.1750-23.2024_Table2.tsv`. Column meanings:
`reference_tables/…_definitions.csv`.

Units: SV2A density kept as **pmol/mL** (source unit; a distinct measure class). Left/right ratio is
derived and carried as printed.

## Build note
Generated in an environment without R; outputs were produced by the equivalent step and
`Johansen_etal_2024_Table2.R` reproduces them from the frozen snapshot (readxl → CSV + TSV with the
`Item encoded` lookup). Re-run in R to regenerate.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → definitions ✅ → README ✅ · single-species human reference (M1 = Precentral row).
