# Kastak_Schusterman_1999_ResultsText

## Source
Kastak, D., & Schusterman, R. J. (1999). In-air and underwater hearing
sensitivity of a northern elephant seal (*Mirounga angustirostris*).
*Canadian Journal of Zoology*, 77(11), 1751-1758. doi:10.1139/z99-151

Registry Item **Results text**, printed p. 1751 (Abstract). Public copy:
`Kastak_Schusterman_1999/Kastak-1999-In-air and underwater hearing sens.pdf`.

## Why this item exists
This paper extends the low-frequency work of Kastak & Schusterman (1998) to
the full audible range for a single female northern elephant seal
("Burnyce"), comparing her in-air and underwater hearing. The paper prints
no data table -- all thresholds are shown only in Figs. 2-4 -- but the
Abstract (repeated in the Results section and again, in French, in the
Resume) states the core audiogram summary numbers explicitly: the
best-sensitivity frequency range, the single best frequency and threshold,
and the (paper's own words) "approximately" stated upper frequency cutoff,
for each medium, plus the pressure- and intensity-referenced underwater-vs-
air differences. These are transcribed rather than digitizing the figures.

## Pipeline
Printed Abstract/Results-text sentences -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Kastak_Schusterman_1999_ResultsText_snapshot.csv` | frozen source, one row per medium (Air, Underwater), as printed |
| `Kastak_Schusterman_1999_ResultsText.R` | reads the snapshot, writes CSV + public TSV |
| `Kastak_Schusterman_1999_ResultsText.csv` | tidy analysis rows |
| `reference_tables/Kastak_Schusterman_1999_ResultsText_definitions.csv` | data dictionary |

## Data role
Both rows are `primary` -- this paper's own new measurements on a single
subject.

## Observation level
Per-medium summary for one individual (Burnyce): best-sensitivity frequency
range, single best frequency/threshold, and upper frequency limit. No
per-frequency raw threshold table is available in this source (see N.B. in
the registry row).

## Units
Frequencies in kHz. Thresholds in dB, but with medium-specific reference
pressures (20 uPa in air, 1 uPa underwater) exactly as the paper states --
not converted to a common scale. The upper frequency limits (20 kHz in air,
55 kHz underwater) are explicitly flagged `upper_freq_is_approx = TRUE`
because the paper itself calls them "approximately" in both languages of the
abstract. The underwater-vs-air differences (19 dB pressure, 52 dB
intensity) are overall comparison statistics from the Discussion/Abstract,
not per-frequency values, and are repeated identically on both rows.
