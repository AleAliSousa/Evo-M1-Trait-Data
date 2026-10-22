# Weisbecker & Goswami 2010 — SI Table S6 (brain, body, BMR, gestation, lactation, litter size; 52 marsupials)

Weisbecker V, Goswami A (2010). *Brain size, life history, and metabolism at the marsupial/placental dichotomy.* PNAS 107(37):16216-16221. doi:10.1073/pnas.0906486107. SI Appendix: `pnas.200906486si.pdf` (5 pages).

## Source -> snapshot
SI p.5 holds Table S6; `..._TableS6_snapshot.csv` is a **transcribed snapshot** from a 2.0x render (columns, row order, thousands separators and em-dashes as printed; 52 rows). **The SI contains no placental species table** (only S6, marsupials) and **no per-row source codes**, so there is no references table. SI pp.1-4 are the phylogeny reference list, Fig. S1 (tree) and Tables S1-S5 (statistics, skipped).

## Fidelity checks (build script output)
- 52 rows = 45 with gestation + 7 with an em-dash for gestation; the text says 45 marsupials for the full analysis and 7 additional species when gestation is left out (Table S4 note), 52 in total. Match.
- No duplicate species; no missing values other than the printed gestation dashes; brain weight < body weight in every row.
- Printed quirks kept: "Dasyurus maculates" (sic); Fig. S1 (tree) spells some names differently from Table S6 (e.g. Caluromys philander vs Caluromys derbianus), not reconciled.

## Sanity check against the repo (__merging_body_ecology/body_ecology_long.csv)
- 48 of 52 species found by name (not found: *Dasyurus maculates* [misspelling], *Parantechinus macdonnellensis*, *Macropus eugenii*, *M. parma*, probably held under other names).
- **BMR:** the merge holds whole-animal BMR in mL O2/h. With 1 mL O2 = 20.1 J, the ratio (Weisbecker kJ/h) / (merge) has median 1.00; 42/48 within +-25%, 33/48 within +-10%. Units consistent; same underlying compilation.
- **Body mass:** 48 compared with merge Body_Mass; 9 exactly equal, 19 within 10% (S6 gives the mass published with the brain weight / BMR; the merge holds adult means from other sources).
- Gestation, weaning and litter size overlap the merge in only 1 species (Didelphis virginiana; gestation and lactation within 10%, litter 7.7 vs 8.62), so no meaningful match rate.

## Caveats
- Secondary compilation; litter sizes are from Fisher et al. per the main-text Methods. Weaning age = printed "Lactation, d".
- Two body masses per species: use the one matching each trait.
- Lewitus et al. 2014 (ref 38): comparable columns are `brain_mass_g`, `body_mass_with_brain_g`, `BMR_kJ_per_h`, `gestation_length_d`, `lactation_d`, `litter_size`. Placental equivalents are not in the SI.

## Build
`Weisbecker_Goswami_2010_TableS6.R` -> `..._TableS6.csv` (52 rows). TSV skipped until the registry row (`..._TableS6_registry_row.xlsx`) is pasted into `__ReadMe.xlsx`. RA side-by-side check of render vs snapshot pending (52 x 8 values).
