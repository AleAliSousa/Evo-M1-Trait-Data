# Frost_Masterton_1994_Resultstext

## Source
Frost, S. B., & Masterton, R. B. (1994). Hearing in primitive mammals:
*Monodelphis domestica* and *Marmosa elegans*. *Hear Res*, 76, 67-72.
doi:10.1016/0378-5955(94)90088-4

Registry Item **Results text**, printed p. 70 (Section 3, "Results").
Public copy: `Frost_Masterton_1994/Frost_Masterton_1994.pdf`.

## Why this item exists
The paper reports the first behavioral audiograms for two small Didelphid
opossums, *Monodelphis domestica* and *Marmosa elegans*, extending
audiological data for the family beyond the much larger North American
opossum. In addition to plotting individual and averaged audiogram curves
(Figs. 1-3, registered separately as a lower-priority Figure 3 candidate
row), the Results section states the two headline summary statistics in
plain text for each species: the 60-dB-SPL hearing range and the average
lowest (best) threshold. These printed sentences are preferred here over
digitising the figures because they are the paper's own stated numbers,
not estimates read off a curve.

## Data role
Both species are marked `primary` -- both are values SensoryData_compiled
currently draws on for this paper.

## Observation level
Species-mean values: *Monodelphis domestica* (5 animals, Fig. 1) and
*Marmosa elegans* (2 animals, Fig. 2), averaged across individuals as
reported in the Results narrative.

## Units
Hearing-range values in kHz (60 dB SPL criterion, re 20 uPa); best
sensitivity in dB SPL; best frequency in kHz.

## Anomaly / discrepancy flag (do not silently correct)
The paper's Results section states, verbatim (verified against a 150-dpi
render of printed page 70): *"the average lowest reliable threshold was
20 dB at 8 and 16 kHz for Monodelphis and 33 dB at 32 kHz for Marmosa."*
This is consistent with the Abstract ("average lowest threshold near 20 dB
SPL for Monodelphis and 33 dB SPL for Marmosa").

- **Marmosa elegans**: 33 dB at 32 kHz matches exactly the value currently
  used by SensoryData_compiled (best_sensitivity 33 dB / best_frequency
  32 kHz).
- **Monodelphis domestica**: the paper prints **20 dB**, tied between
  **8 kHz and 16 kHz** (not a single best frequency). SensoryData_compiled
  is recorded elsewhere as using **23 dB / 16 kHz** for this species, which
  does **not** match the number printed in this paper. We did not find a
  20-versus-23 dB alternate reading anywhere else in the article (no table
  of per-frequency thresholds is printed), and the page image confirms
  "20 dB" unambiguously. We have kept the paper's printed value (20 dB;
  best frequency left blank because the paper itself reports a tie between
  two frequencies rather than a single best frequency) rather than
  silently reconciling it with the 23 dB figure used downstream. This
  discrepancy should be investigated at the SensoryData_compiled level
  (possible transcription slip, or the 23 dB value may come from a
  different source entirely) -- flagging here per house rule rather than
  correcting either number.
