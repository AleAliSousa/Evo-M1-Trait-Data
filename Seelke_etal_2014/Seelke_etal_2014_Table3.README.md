# Seelke et al. 2014 - Table 3 (cortical field weights; Monodelphis domestica)

Seelke AMH, Dooley JC, Krubitzer LA (2014). The cellular composition of the marsupial neocortex. J Comp Neurol 522(10):2286-2298. doi:10.1002/cne.23534

## Source -> snapshot
`Seelke_etal_2014.pdf`, p.5 (journal p.2290), Table 3 Cortical Field Weights. Text layer was partly usable; the snapshot was **transcribed from a render** and cross-checked against the text layer. 6 rows, printed order, headers as printed, the "±" kept as printed.

## Method warning
METHOD WARNING: the paper states it used the **isotropic fractionator** (nuclei counted in a Neubauer chamber, NeuN fraction by flow cytometry); it is NOT stereological/histological sectioning counting. Measure codes follow the repo isotropic-fractionator set (C.n, N.n, O.n, p.C.N, Mass.g). Lewitus et al. 2014 (ref 61) cites this paper for marsupial cell composition: the comparable quantities are Table 4 (cells, % neurons, neurons, non-neurons per region; the intact "Whole neocortex" row is the one comparable to a whole-neocortex count) and Table 5 (densities).

## Interpretation caveats
- Values are **group means ± dispersion over 5 animals**, not per-animal data (per-animal data are not published; Table 1 lists only age/weight/sex). The dispersion is not labelled SD/SEM in the table (figure captions: SEM); stored as `*_pm` unchanged.
- "Whole neocortex" (intact hemisphere) and "Sigma neocortex" (other hemisphere dissected into regions and summed) are two measurements of the same quantity; Sigma values are less direct. Rem Ctx, V1, S1, A1 are sub-regions - do not pool them with whole-neocortex values.
- Weight unit: g (hemisphere). Counts in millions.

## Fidelity checks
- Sum of region weights Rem Ctx+V1+S1+A1 = 0.039+0.015+0.011+0.007 = 0.072 = Sigma neocortex (OK).
- % of Sigma neocortex: 54.1+20.7+15.3+9.8 = 99.9 (rounding; OK).
- Whole neocortex 0.073 vs Sigma 0.072 (text: "nearly identical").
