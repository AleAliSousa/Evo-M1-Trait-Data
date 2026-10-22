# Sawaguchi 1988 — Appendix (troop size, home ranges, body and brain weight; 47 primates)

Sawaguchi T (1988). *Correlations of cerebral indices for 'extra' cortical parts and ecological variables in primates.* Brain Behav Evol 32(3):129-140. doi:10.1159/000116540

## Source -> snapshot
`Sawaguchi__1988.pdf` (EndNote 6581; scanned, no text layer). The species table is the **Appendix**, journal pp. 137-138 (PDF pp. 9-10). `Sawaguchi__1988_Appendix_snapshot.csv` is a **constructed (transcribed) snapshot** from 3.2x renders: 47 rows in printed order, values as printed (thousands commas kept). The block headers (Prosimians / New World monkeys / Old World monkeys; superfamily) are repeated into `Group` / `Superfamily` columns instead of header rows.

## What is and is not in the table
Printed columns: TS (troop size), HRt (troop home range, ha), HRi (individual home range, ha), P (body weight, g), E (brain weight, g). **The cerebral indices Nc, Ve and Se are not printed anywhere as a table**; the paper gives their formulae (Methods, p. 130). The build script therefore adds `Nc_extra_neurons_derived`, `Ve_...`, `Se_...` **recomputed from P and E**; they are derived by this repo, not published values. (Diet is not a variable of the paper.)

## Fidelity checks
- 47 species = paper's "47 species"; groups 12 / 8 / 27 match the paper's counts (Lemuroidea 7 + Lorisoidea 5; Ceboidea 8; Cercopithecoidea 27).
- Recomputed Nc/Ve/Se vs **Table I** (log Nc, Ve, Se against log E and log P): all 18 coefficients reproduce to 2 decimals (e.g. prosimians E 0.98/0.99/0.99, P 0.90/0.92/0.93; OW P 0.63/0.60/0.67 vs printed 0.62/0.60/0.67), which validates P, E and the formulae.
- vs **Table II** (indices against log TS, HRt, HRi) agreement is exact for prosimians TS (0.71), HRt ~ (0.56 vs 0.55) and OW HRt/HRi (0.75/0.80 vs 0.74/0.81), but NW monkeys (TS 0.64 vs 0.59, HRt 0.83 vs 0.77, HRi 0.62 vs 0.56) and prosimian HRi (0.27 vs 0.17) differ. The ecological columns were re-read against the render and match the print; the paper's correlations may have been computed on slightly different input. Owner may wish to flag.
- HRi should equal HRt/TS (stated in Methods): holds for 44 of 47 rows; the three printed exceptions are kept as printed: *Lemur fulvus* (0.9/9.5 = 0.09, printed 1.41), *Cercopithecus pogonias* (78/15 = 5.2, printed 3.2), *Macaca radiata* (520/35 = 14.9, printed 9.0).
- RA side-by-side check of the 47 x 5 values still to do.

## Caveats
- Printed spellings kept: *Cercopithecus nictitaus*, *Micopithecus talapoin*, *Saimiri oerstedii*, *Callicebus moloch*; *Cebus capucinus* and *Cebus apella* are separate rows. *Macaca mulatta* etc. harmonise downstream.
- All values are secondary: TS/HRt from field studies cited by Milton & May 1976 and Clutton-Brock & Harvey 1977a,b; P and E are female/male means from Harvey & Clutton-Brock 1985 (no per-row citations printed). Prefer the primary sources for pooling.
- For solitary prosimians TS = 1 and HRi = HRt by definition.

## Lewitus 2014 (ref 4)
Lewitus cites this paper dataset-wide. Comparable quantities: `brain_weight_g`, `body_weight_g`, `troop_size` (group size), `troop_home_range_ha` / `indiv_home_range_ha` (home range), and the derived cerebral indices.

## Build
`Sawaguchi__1988_Appendix.R` -> `..._Appendix.csv` (47 rows). TSV skipped until `__ReadMe.xlsx` has the Item encoded. Registry row: `Sawaguchi__1988_Appendix_registry_row.xlsx`.

## Tables not built
- Table I (correlations of indices with E and P; 3 groups) and Table II (correlations of indices with TS, HRt, HRi): summary statistics, not species-level data. Fig. 1 scatterplots: not tabular. Used here only as validation checks.
