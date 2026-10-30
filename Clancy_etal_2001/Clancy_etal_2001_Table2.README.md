# Clancy, Darlington & Finlay 2001 — Table 2 (translation of developmental time across 9 species, calibrated to the rat)

Clancy B, Darlington RB, Finlay BL (2001). *Translating developmental time across mammalian species.* Neuroscience 105(1):7-17. doi:10.1016/s0306-4522(01)00171-3

## Source -> snapshot
`Clancy_etal_2001.pdf` (EndNote record 7053), PDF p.6 (journal p.12), upright. `Clancy_etal_2001_Table2_snapshot.csv` is a **constructed (transcribed) snapshot**: 50 printed rows x 13 columns (rat, hamster, mouse, rabbit, spiny mouse, ferret, cat; macaque and human x limbic/other/cortex). Headers carry the printed gestation time, e.g. `rat (G21.5)`; cells exactly as printed (PC days before birth, `Pn` after birth, `BIRTH` for the boxed cell); blank where a column ends (rat to cat after row 40, macaque after row 42).

## Build
`Clancy_etal_2001_Table2.R` -> `..._Table2.csv`, LONG: 556 rows = every printed cell (rat..cat 7 x 40 + macaque 3 x 42 + human 3 x 50). Adds `period`, `time_days_as_printed`, `gestation_days` and the DERIVED `PC_day_equivalent` (birth = gestation, postnatal = gestation + P day).

## Fidelity checks
- Row structure: rat column 9.0-21.0 in 0.5 steps (25 rows), BIRTH, P1-P14 (40 rows) as the text says (0.5-day increments to 1 day after birth; full days after).
- Every column is strictly increasing down the table (checked on PC_day_equivalent for all 13 columns). BIRTH is boxed once in each of rat, hamster, mouse, rabbit, spiny mouse, ferret, cat, macaque-cortex and human-cortex (9 cells); the macaque/human limbic and other columns have no BIRTH box (birth occurs at the cortex column's row). The last prenatal value before BIRTH is 1-2 days below the printed gestation G (hamster 15.4 vs G15.5; mouse 18.0 vs 18.5; rabbit 29.2 vs 31; ferret 39.6 vs 41; cat 62.2 vs 65; macaque cortex 161 vs 165; human cortex 263 vs 270) - expected from the row grid.
- Text example in the paper: "PC 19 in the rat brain ... PC 72 human limbic, 94 posterior cortex, 78 other; hamster on the day of birth; mouse PC 16.4; cat PC 40.4" — all reproduced (row 19.0).
- Cross-check vs Table 1 (rat model value as key): hamster/mouse/rabbit agree within 0.2 PC days; ferret/cat/spiny mouse differ by up to 0.9/1.1/0.6 (Table 1 higher). Not resolved; both kept as printed. Owner/RA may check whether Table 2 was generated with slightly different ferret/cat parameters.

## Caveats
This is a model-derived lookup (predictions), not observations; use only as a time-translation reference. Mixed time clock (PC vs postnatal days) in one column — use `period` / `PC_day_equivalent`. Macaque and human each have three columns for the primate-specific limbic/other/cortex adjustment; birth for the primate limbic/other columns is not boxed, so no BIRTH cell exists in them (PC_day_equivalent for postnatal cells is undefined there; none are printed).

## RA check still to do
Side-by-side read of the render against the snapshot (50 rows x 13 columns).
