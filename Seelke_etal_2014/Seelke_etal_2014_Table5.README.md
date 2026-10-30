# Seelke et al. 2014 - Table 5 (cellular densities per cortical region; Monodelphis domestica)

Seelke AMH, Dooley JC, Krubitzer LA (2014). The cellular composition of the marsupial neocortex. J Comp Neurol 522(10):2286-2298. doi:10.1002/cne.23534

## Source -> snapshot
`Seelke_etal_2014.pdf`, p.7 (journal p.2292), Table 5 Cellular Density. Text layer was partly usable; the snapshot was **transcribed from a render** and cross-checked against the text layer. 6 rows, printed order, headers as printed, the "±" kept as printed.

## Method warning
METHOD WARNING: the paper states it used the **isotropic fractionator** (nuclei counted in a Neubauer chamber, NeuN fraction by flow cytometry); it is NOT stereological/histological sectioning counting. Measure codes follow the repo isotropic-fractionator set (C.n, N.n, O.n, p.C.N, Mass.g). Lewitus et al. 2014 (ref 61) cites this paper for marsupial cell composition: the comparable quantities are Table 4 (cells, % neurons, neurons, non-neurons per region; the intact "Whole neocortex" row is the one comparable to a whole-neocortex count) and Table 5 (densities).

## Interpretation caveats
- Values are **group means ± dispersion over 5 animals**, not per-animal data (per-animal data are not published; Table 1 lists only age/weight/sex). The dispersion is not labelled SD/SEM in the table (figure captions: SEM); stored as `*_pm` unchanged.
- "Whole neocortex" (intact hemisphere) and "Sigma neocortex" (other hemisphere dissected into regions and summed) are two measurements of the same quantity; Sigma values are less direct. Rem Ctx, V1, S1, A1 are sub-regions - do not pool them with whole-neocortex values.
- Weight unit: g (hemisphere). Counts in millions.

## Fidelity checks
- Cells/g ~ Table 4 cells / Table 3 weight: Whole 3.03/0.073 = 41.5 (41.70); Rem Ctx 1.66/0.039 = 42.6 (42.52); V1 0.57/0.015 = 38 (40.98); S1 0.50/0.011 = 45 (46.34); A1 0.30/0.007 = 43 (44.04) - consistent given weight rounding.
- Neurons/g + non-neurons/g ~ cells/g: Whole 10.92+30.78=41.70 (exact); Sigma 12.28+30.11=42.39 (exact); Rem Ctx 6.73+35.79=42.52; V1 17.31+23.68=40.99 (40.98); S1 20.29+26.05=46.34; A1 28.05+15.99=44.04 - all agree.
- Render vs text layer agree.
