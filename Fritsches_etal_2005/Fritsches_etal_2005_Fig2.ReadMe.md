# Fritsches et al. (2005) — Figure 2 (comparative retinal Q10 across billfish)

**Source paper.** Fritsches, K. A., Brill, R. W., & Warrant, E. J. (2005). Warm eyes provide superior vision in swordfish. *Current Biology*, 15(1), 55–58.

**Data location in the paper.** The paper does **not** publish a formal comparative table. The three-species comparison of retinal temperature sensitivity (Q10) and flicker fusion frequency (FFF) is presented in **Figure 2** and quoted in the main text on p. 55. This snapshot digitises those values.

Because the source is a figure and not a printed table, the folder is named `Fritsches_etal_2005_Fig2` rather than `..._Table1`. Placeholder files with `_Table1` in the name were used during scaffolding — those can be deleted; only the `_Fig2` files should be uploaded to the repo.

## Files in this folder (uploaded)

| file | what it is |
| --- | --- |
| `Fritsches_etal_2005_Fig2_snapshot.csv` | frozen, faithful copy of the three-species Figure 2 comparison |
| `Fritsches_etal_2005_Fig2.csv` | cleaned, analysis-ready data |
| `Fritsches_etal_2005_Fig2.R` | script that turns the snapshot into the clean CSV |
| `Fritsches_etal_2005_Fig2.ReadMe.md` | this file |

## Files NOT to upload (legacy placeholders)

- `Fritsches_etal_2005_Table1_snapshot.csv`
- `Fritsches_etal_2005_Table1.R`
- `Fritsches_etal_2005_Table1.ReadMe.md`

## Snapshot

**Method.** Manual entry from Fritsches et al. (2005) main text (p. 55) and Figure 2 legends. Values as reported by the authors — no digitisation of the Q10 curves themselves.

**Columns kept.**

- Species (Latin binomial)
- Common name
- Habitat depth (Fritsches' verbal description — kept as free text)
- Retinal Q10 (light-adapted) — Fritsches' reported value
- FFF at 10°C (Hz) — reported only for swordfish
- FFF at 20°C (Hz) — reported only for swordfish
- n (number of retinas measured)
- r-squared (goodness-of-fit for the Q10 curve)
- Source (paper location for each value)

## Why this in the database

Fritsches is a rare paper that places **visual acuity** and **thermoregulation** on the same species. The retinal Q10 quantifies how much visual temporal resolution changes per 10°C of retinal warming — swordfish's Q10 of 5.1 is more than double that of tunas (2.3, 2.5), which the authors attribute to the specialised heater organ that warms swordfish eyes ~10–15°C above ambient.

Direct extension of Caves (2018) into the aquatic thermal domain and of Siegel (2022)'s thermoregulation frame into the visual system.

## Cleaning applied (in `.R`)

- Column names → snake_case.
- Em-dashes `—` in the snapshot (marking values not reported per species) converted to `NA` on the numeric side.
- Common name lowercased.

## Notes

- Three species is small but the paper is the standard reference for the swordfish/tuna Q10 comparison; this is the whole point of the paper.
- Fritsches reports swordfish FFF at 20°C as ">40 Hz" (i.e. an inequality) rather than a point value. Preserved as the string `"greater than 40"` in the snapshot; user should decide downstream whether to code as `40` or leave as `NA`.
- Species names may need updating for NCBI taxonomic consistency at the repo level.
