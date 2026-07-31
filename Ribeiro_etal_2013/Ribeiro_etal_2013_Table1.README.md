# Ribeiro, Ventura-Antunes, Gabi, Mota, Grinberg, Farfel, Ferretti, Leite, Jacob Filho & Herculano-Houzel 2013 — human cortical neuronal-distribution zones

Ribeiro PFM, Ventura-Antunes L, Gabi M, Mota B, Grinberg LT, Farfel JM, Ferretti REL,
Leite REP, Jacob Filho W, Herculano-Houzel S (2013). *The human cerebral cortex is neither
one nor many: neuronal distribution reveals two quantitatively different zones in the gray
matter, three in the white matter, and explains local variations in cortical folding.*
Front. Neuroanat. 7:28. doi:**10.3389/fnana.2013.00028**

## Why it's here (coverage gap — finer REGIONS, within-human)

Isotropic-fractionator neuron numbers / densities sampled across many cortical sites in the
**human**, resolving grey-matter into two zones and white-matter into three. *Homo sapiens*
is already in the merge (whole-cortex, from HH 2015); this adds a **within-cortex regional
map** the merge has no scheme for.

## Region scheme — NEW regional, and a GRANULARITY decision

Unlike Gabi 2016 (a clean prefrontal-vs-rest split) this paper is **per-sampling-site /
per-zone within one species**. Two things to decide before ingest:

1. **What rows represent** — per grey-matter zone (2) + white-matter zone (3), or per
   sampled gyrus/site. A species×variable long table wants a small fixed set of zone
   variables, so the natural unit is the **zones** (e.g. `CortexGreyZone1_N.p.mg`,
   `CortexWhiteZone1_N.p.mg`, …), not every raw site.
2. **Whether this belongs in the cell-count merge at all**, or is better kept as a
   within-species reference table (like the HH 2013 mouse-area table currently is) that the
   merge does not consume. This is a within-human density map, not a cross-species row set —
   its cross-species value is low, its documentary value is high.

Resolve the shared regional-term decision in `__merging_cellcounts/HH_coverage_gaps_scaffold.md`
first; then decide (1)/(2) specifically for this paper.

## Needs (blockers)

- [ ] PDF (+ supplementary data) into `Ribeiro_etal_2013/`.
- [ ] Granularity + include-or-reference decision (above).
- [ ] If merged: register in `__ReadMe.xlsx`, fill extraction + standardized-terms stub,
      uncomment in `item_name`, re-run. If kept as a reference only: build the table +
      README for provenance and leave it out of `item_name` (like HH 2013 today).

Status: **SCAFFOLD** — folder + README + stub `.R` + definitions stub only. Not merged.
Lower priority than Gabi 2016 / Kazu 2014 (within-species, no new species or clade).
