# Fritsches et al. (2005) — Figure 2

**Source paper.** Fritsches, K. A., Brill, R. W., & Warrant, E. J. (2005). Warm eyes provide superior
vision in swordfish. *Current Biology*, 15(1), 55–58.

**Data location.** The paper publishes no table. The three-species comparison of retinal temperature
sensitivity appears in Figure 2 and in the main text on p. 55, so this is a constructed snapshot and
is named for its locus.

## Files in this folder

| file | what it is |
| --- | --- |
| `Fritsches_etal_2005_Fig2_snapshot.csv` | the three-species comparison as stated in the paper |
| `Fritsches_etal_2005_Fig2.csv` | cleaned, analysis-ready data ("use this") |
| `Fritsches_etal_2005_Fig2.R` | script that turns the snapshot into the clean CSV |
| `Fritsches_etal_2005_Fig2.ReadMe.md` | this file |

## Pipeline

`Source → Snapshot → Data readable → (Species notes) → Online database`

## Snapshot

**Method.** Manual entry from the stated values, transcribed by an AI assistant on 10 September 2026
from the Figure 2 legend and the paragraph on p. 55 supplied by M. Windley.

**Sentences the values come from.** *"The light-adapted swordfish retina showed a Q10 (the fractional
increase in FFF per 10°C) of 5.1 (n = 6, r2 = 0.80). … The surface-living yellowfin tuna (Thunnus
albacares) and the deep-diving bigeye tuna (Thunnus obesus) revealed Q10 values of 2.3 (nyellowfin
tuna = 5, r2 = 0.72) and 2.5 (nbigeye tuna = 6, r2 = 0.76), respectively."* The Figure 2 legend gives
the same sample sizes: swordfish n = 6 (2A), bigeye n = 6 and yellowfin n = 5 (2B).

**Columns.**

- `Common name`
- `Species`
- `Habitat descriptor as printed` — the paper applies "surface-living" and "deep-diving" to the two
  tunas only; blank for the swordfish
- `Retinal Q10 (light-adapted)`
- `n` — number of retinas measured
- `r-squared` — goodness of fit for the Q10 curve
- `Source in paper`

Species: *Xiphias gladius*, *Thunnus albacares*, *Thunnus obesus*.

**What was NOT included in the snapshot.**

- FFF values at particular temperatures. The paper reports none for the swordfish; the temperature
  response is published only as the curve in Figure 2A, which prints no per-point values and no
  per-point source. The "40 Hz" figure quoted elsewhere in the text belongs to Figure 3A, which plots
  FFF against light intensity at a fixed retinal temperature of 22 °C.
- The diving-depth and light-attenuation modelling in the rest of the paper.

## Cleaning applied (in `.R`)

- Column names → snake_case; common names lowercased.
- Q10, `n` and r² coerced to numeric.

## Notes for the database

- The swordfish Q10 of 5.1 is more than twice that of either tuna, which the authors attribute to the
  heater organ warming the eye and brain 10–15 °C above ambient.
- Both tunas achieve whole-body warming by vascular counter-current exchange rather than a
  dedicated cranial heater, so the two thermal mechanisms are not equivalent.
- Species names may need updating for NCBI taxonomic consistency at the repo level.

## Public export

Add the row to `__ReadMe.xlsx` (`Item name = Fritsches_etal_2005_Fig2` plus the derived `Item
encoded`) and run the `.R`, which writes `__Public/comparative-data/<Item encoded>.tsv`.
