# Dalland__1965_ResultsText

## Source
Dalland, J. I. (1965). Hearing sensitivity in bats. *Science*, 150(3700),
1185-1186. https://doi.org/10.1126/science.150.3700.1185

Registry Item **Results text** (no printed data table; the paper's only
figure, Fig. 1, plots the same audiogram points that are also stated
numerically in the Abstract/Results). Public copy:
`Dalland__1965/Dalland-1965-Hearing Sensitivity in Bats.pdf`.

## Why this item exists
This short *Science* report used operant conditioning (method of limits) to
measure absolute pure-tone hearing thresholds for one *Eptesicus fuscus*
(big brown bat) and one *Myotis lucifugus* (little brown bat), testing
2.5-100+ kHz. Its headline finding -- widely cited in later comparative
hearing work, including being cited by Heffner et al. (1969) in this same
registry cluster -- is that absolute hearing sensitivity in echolocating
bats is *not* superior to other mammals despite their precise echolocation
abilities; both bats' best thresholds (-68 dB re 1 dyne/cm2 at 20 kHz for
Eptesicus, -64 dB re 1 dyne/cm2 at 40 kHz for Myotis) are unremarkable
compared to other mammals' peak sensitivities. There is no printed table;
every number is stated once, in running text, in the Abstract and Results
section.

## Pipeline
Verbatim Results/Abstract text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Dalland__1965_ResultsText_snapshot.csv` | frozen verbatim quotes, one row per species |
| `Dalland__1965_ResultsText.R` | re-keys the two numbers per species quoted in the snapshot, writes CSV + public TSV |
| `Dalland__1965_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Dalland__1965_ResultsText_definitions.csv` | data dictionary |

## Data role
Primary for both rows -- this is the paper's own new behavioral audiogram
data for these two individual bats (one animal per species).

## Observation level
Per-individual-animal (n=1 per species; only one bat of each species was
tested).

## Units
Thresholds in **dB re 1 dyne/cm2** as printed -- this is the older
acoustics-reference convention (1 dyne/cm2 = 1000 microbar = 74 dB SPL re
the modern 20 uPa reference), *not* modern dB SPL; no conversion has been
applied, values are kept exactly as printed. A negative value here (e.g.
-68) means the threshold pressure was 68 dB *below* the 1 dyne/cm2
reference, i.e. a very low (sensitive) absolute threshold. Frequency in
kHz. `range_criterion` records the exact printed intensity criterion under
which each species' tested/audible frequency range was established (the two
bats were tested under slightly different criteria, both stated verbatim in
the snapshot quotes).

## N.B. / anomalies
- The Myotis 10-kHz data point is explicitly flagged by the authors
  themselves as uncertain (harmonic-distortion confound suspected); this is
  preserved verbatim in the snapshot quote and is why the 10-kHz endpoint of
  Myotis's audible range is looser than the other values. Not corrected or
  omitted here, only flagged, per house rule.
- "decibles" is a typo in the OCR'd/rendered text for "decibels"; the
  snapshot preserves it verbatim with a `[sic]` note rather than silently
  fixing it.
