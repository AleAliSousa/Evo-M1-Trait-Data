# Energetics compiled merge (Part IV)

`energetics_merged.R` builds a two-tier merge of brain metabolic rate from `energetics_long.csv`,
mirroring `__merging_volumes/volumes_long.csv` for the volume data type.

## Inputs
- Heiss_etal_2004 - Homo sapiens regional CMRgl (PET).
- Kaufman__2004 - 12 genera, weighted-mean CMRgl / CMRO2 / CBF.
- Karbowski 2007 - NOT included: the source xlsx headers are OCR-garbled and were never parsed
  into `energetics_long.csv`; it needs a dedicated extraction pass before it can be merged.

## Schema (`energetics_merged_long.csv`)
`Species, Region, Measure, Units, Value, Teams, n_teams, Volume_term`
- Measure in {CMRgl, CMRO2, CBF}; Units = umol/100g/min (CMRgl, CMRO2) or mL/100g/min (CBF).
- `Region` is a canonical label (Heiss/Kaufman synonyms harmonized); `Volume_term` links to the
  matching `*_Vol.mm3` term in the volume merge where a clean single counterpart exists (else NA).

## Resolution
Each paper is an independent Tier-2 team; values are averaged within a team, then ACROSS teams per
(Species, Region, Measure). Only Homo sapiens overlaps the two teams (Heiss + Kaufman), giving
6 cross-team averaged cells. Kaufman values are the weighted means (unweighted dropped if present).

## Caveats
- Heiss anatomical lobes (Frontal/Occipital/Parietal/Temporal lobe, incl. white matter) are aligned
  to Kaufman's grey-matter '* Cortex' under one canonical `*_cortex` label so the two human series
  can be averaged; treat those averaged cortical cells as lobe~cortex approximations.
- Kaufman species are genus-level (e.g. `Macaca`, `Canis`); only `Homo` was harmonized to a binomial
  (`Homo sapiens`) to align with Heiss. Genus-level rows are kept as-is.

## Cross-check (independent human cortical CMRgl)
Heiss cerebral-cortex global-average CMRgl (33.5) vs Kaufman Homo Cortex CMRgl (36.78) -> averaged
in the merge; same order of magnitude, good agreement.
