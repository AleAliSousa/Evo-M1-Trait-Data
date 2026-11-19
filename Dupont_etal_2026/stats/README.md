# Outline

Phylogenetic comparative analyses of mammalian intermembral proportions (IP) and arboreality.
Analysis code used to produce the statistical analysis and plots for the article "Morphometric and ecological correlates of phalangeal elongation in extant arboreal mammals and implication for inferring arboreality in fossils".

Response variables (all log10): `IPHand3and4`, `IPHand1`, `IPFoot3and4`, `IPFoot1`.
Predictors: `TpsArboricolie` (time in trees), `Bodymasslog10`.

## Sections

File `statProcB.R`

1. **Paired *t*-tests** (l. 14–37) — compare IP variants (digits 2–5 vs 2 & 5 vs 3 & 4) for hand and foot; Holm-corrected.
2. **contMap** (l. 40–175) — fan-tree continuous trait maps for each IP variable.
3. **Blomberg's *K*** (l. 178–193) — phylogenetic signal on the four log10 IPs.
4. **Global PGLS** (l. 196–450) — each IP regressed on `TpsArboricolie` and `Bodymasslog10`, with phylomorphospace plots painted by clade; Holm-corrected.
5. **Per-clade PGLS** (l. 452–1567) — same block repeated for Primates, Carnivora, Marsupialia, Rodentia, Scandentia, Pholidota.
6. **Synthesis plots** (l. 1569–1749) — overlay PGLS lines from global + clade fits on combined scatterplots and phylomorphospaces.
7. **Fossil prediction (SMA)** (l. 1752–1911) — `sma` regression of logit(TpsArboricolie) on each IP; predicts arboreality for fossil specimens via `fit_sma()`.

## Dependencies & Notes

`ggplot2`, `car`, `ape`, `caper`, `geiger`, `phytools`, `glue`, `ggrepel`, `patchwork`, `smatr`.

This code is provided for traceability purposes, it is not meant to be broadly shared or reused and is therefore not formatted for that purpose.
Data used in the study is available in the publication, in a different format than the one that was used in this analysis code. To avoid confusion with the same data formatted differently, we don't provide the alternative views of the data used in this analysis.

### Session info

The analysis was run under the following environment (`sessionInfo()`):

```
R version 4.5.2 (2025-10-31)

attached base packages:
stats     graphics  grDevices utils     datasets  methods   base

other attached packages:
smatr_3.4-8     patchwork_1.3.2 ggrepel_0.9.6   glue_1.8.0      geiger_2.0.11   phytools_2.5-2  maps_3.4.3
caper_1.0.4     mvtnorm_1.3-3   MASS_7.3-65     ape_5.8-1       car_3.1-3       carData_3.0-5   ggplot2_4.0.1
```
