# Ravizza_etal_1969_ResultsText

## Source
Ravizza, R. J., Heffner, H. E., & Masterton, B. (1969). Hearing in
primitive mammals, I: Opossum (*Didelphis virginianus*). *The Journal of
Auditory Research*, 9, 1-7. (This pre-1970s journal was never
retroactively assigned a DOI; a placeholder DOI is used in the registry
per house convention -- see N.B.)

Registry Item **Results text**, printed pp. 4-6 (Results/Discussion).
Public copy: `Ravizza_etal_1969/Ravizza-1969-Hearing in primitive mammals_ I.pdf`.

## Why this item exists
This is the first paper in the Ravizza/Heffner/Masterton "Hearing in
Primitive Mammals" series (opossum = I; hedgehog = II; tree shrew = III;
bushbaby = IV), part of the broader "evolution of human hearing" program
(see also Masterton et al., 1969, JASA) that Owren et al. (1988, also
built in this project) explicitly cites. Using conditioned suppression
(lick-suppression) in two wild-born opossums, the paper establishes that
this neurologically primitive mammal (i) hears an unusually wide and
high-frequency range (measured to 60 kc/s, extrapolated to 70-80 kc/s) but
(ii) is comparatively insensitive overall (best thresholds only 15-30 dB
above the 0.0002 dyne/cm^2 reference, worse than most other mammals tested
at the time). No table of numeric thresholds is printed in this paper --
the audiogram exists only as Fig. 2 -- so the values captured here are the
explicit numeric statements given in the Results and Discussion text,
per house rule to prefer text over digitizing a figure.

## Pipeline
Results/Discussion text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Ravizza_etal_1969_ResultsText_snapshot.csv` | frozen source, one row per quoted numeric statement |
| `Ravizza_etal_1969_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Ravizza_etal_1969_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Ravizza_etal_1969_ResultsText_definitions.csv` | data dictionary |

## Data role
All rows are this paper's own new behavioral measurements on two wild-born
opossums (*Didelphis marsupialis virginianus*, ~3.5-4 kg); there is no
secondary/cited data in this item.

## Observation level
Mixed: some rows are pooled across both subjects (the overall measured and
extrapolated hearing-range bounds), while others are explicitly
per-individual (the two distinct "best sensitivity" values, 15 dB and 30
dB) or between-individual (the 14 dB and 20 dB disparities at 32 and 60
kc/s respectively). The paper does not label which of its two opossums
("Opossum #A" / "Opossum #8" in the figures) corresponds to the 15 dB vs.
30 dB best-sensitivity value, so `individual` is deliberately left
unresolved ("one of two, unspecified which") rather than guessed.

## Units
- Frequencies in kc/s (kilocycles per second, numerically identical to
  kHz), as printed.
- Sensitivity/disparity values in dB; overall-sensitivity values are dB
  re 0.0002 dynes/cm^2 (the paper's stated intensity reference), as
  printed; the 14/20 dB disparities are differences between the two
  individual audiograms at a given frequency and are not tied to a single
  absolute reference beyond that.
- The extrapolated upper bound is printed ambiguously in the source text
  as "70 or 80" kc/s; this is preserved verbatim (not resolved to a single
  number) and flagged in the `value`/`quoted_source_text` columns.
