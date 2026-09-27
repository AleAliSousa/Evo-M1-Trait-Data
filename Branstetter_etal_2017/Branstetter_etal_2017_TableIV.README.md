# Branstetter_etal_2017_TableIV

## Source
Branstetter, B. K., St Leger, J., Acton, D., Stewart, J., Houser, D.,
Finneran, J. J., & Jenkins, K. (2017). Killer whale (*Orcinus orca*)
behavioral audiograms. *J Acoust Soc Am*, 141, 2387-2398.
doi:10.1121/1.4979116

Registry Item **Table IV**, printed p. 2395. Public copy:
`Branstetter_etal_2017/Branstetter_etal_2017.pdf`.

## Why this item exists
This paper measured behavioral audiograms for eight captive killer whales
(*Orcinus orca*) and combined them with historical data (Szymanski et al.,
1999) to build a composite species audiogram; it then applied the same
composite-audiogram procedure to three other odontocete species (beluga,
bottlenose dolphin, harbor porpoise) using data compiled from the
literature (see Table III), so that all four species' hearing limits could
be compared on a common basis. Table IV is the single, compact summary
table that reports, for each of the four species, the frequency and
absolute threshold of best sensitivity, the "best hearing range" (the
frequency span within the most sensitive part of the curve), and the
60-dB-SPL low- and high-frequency cutoffs -- exactly the four
"audible_freq_low/high_60dBSPL / best_sensitivity / best_frequency"
metrics used elsewhere in this project for *O. orca*. A companion
candidate row for **Table I** (the raw per-subject threshold matrix
underlying the *O. orca* composite audiogram) remains registered
separately as a "candidate" pointer; Table IV is the paper's own derived
summary and is what SensoryData_compiled actually draws its four O. orca
values from, so only Table IV was fully built here.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Branstetter_etal_2017_TableIV_snapshot.csv` | frozen source, printed layout |
| `Branstetter_etal_2017_TableIV.R` | reads the snapshot, writes CSV + public TSV |
| `Branstetter_etal_2017_TableIV.csv` | tidy analysis rows |
| `reference_tables/Branstetter_etal_2017_TableIV_definitions.csv` | data dictionary |

## Data role
Only the *Orcinus orca* row (species_row 1) is marked `primary`: it is the
species whose four values (audible_freq_low_60dBSPL = 0.60 kHz,
audible_freq_high_60dBSPL = 114 kHz, best_sensitivity = 49 dB,
best_frequency = 34 kHz) are used by SensoryData_compiled. The other three
species (*D. leucas*, *T. truncatus*, *P. phocoena*) are printed in the
same table but are marked `secondary` because they are not currently drawn
on by SensoryData_compiled; they are retained here for completeness and
future use since they are part of the same printed table.

## Observation level
Species-level composite audiogram metrics (one row per species). The
*O. orca* row is itself a composite/mean over N = 8 individual killer
whales (see Table I / Table II for per-subject detail); the other three
species' rows are composite audiograms built by the authors from
previously published individual-species data (their reference sources are
listed in the paper's Table III, not reproduced here).

## Units
Mass in kilograms; best sensitivity and lowest threshold in dB re 1 uPa;
all frequency values (best frequency, best hearing range, low/high
frequency cutoffs) in kHz. The "best hearing range" and the 60-dB-SPL
cutoffs are two distinct printed metrics -- do not conflate them: the
former is the (narrower) frequency span of best sensitivity, the latter is
the (wider) span audible at a criterion 60 dB SPL.
