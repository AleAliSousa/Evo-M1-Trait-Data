# Kastak_Schusterman_1998_TablesI-II

## Source
Kastak, D., & Schusterman, R. J. (1998). Low-frequency amphibious hearing in
pinnipeds: Methods, measurements, noise, and ecology. *Journal of the
Acoustical Society of America*, 103(4), 2216-2228. doi:10.1121/1.421367

Registry Item **Tables I-II**, printed pp. 2220-2221. Public copy:
`Kastak_Schusterman_1998/Kastak-1998-Low-frequency amphibious hearing i.pdf`.

## Why this item exists
This paper is a comparative low-frequency amphibious hearing study across
three pinnipeds: California sea lion (*Zalophus californianus*, subjects
Rocky and, underwater only, Rio), harbor seal (*Phoca vitulina*, subject
Sprouts), and northern elephant seal (*Mirounga angustirostris*, subject
Burnyce). Because the entire point of the paper is the aerial-vs-underwater
comparison, both of its printed data tables are captured together as one
item: Table I (aerial sound-detection thresholds, dB re 20 uPa, at
100-6400 Hz) and Table II (underwater sound-detection thresholds, dB re
1 uPa, at 75-6400 Hz), each with the paired false-alarm rate. This is the
paper's actual reported result set (not a single-value summary), so the full
tables are transcribed rather than digitizing a figure.

## Pipeline
Printed Table I + Table II -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Kastak_Schusterman_1998_TablesI-II_snapshot.csv` | frozen source, printed table layout (medium, frequency, subject, species, threshold, FA%) |
| `Kastak_Schusterman_1998_TablesI-II.R` | reads the snapshot, writes CSV + public TSV |
| `Kastak_Schusterman_1998_TablesI-II.csv` | tidy analysis rows |
| `reference_tables/Kastak_Schusterman_1998_TablesI-II_definitions.csv` | data dictionary |

## Data role
All rows are `primary` -- both tables report this paper's own new behavioral
measurements.

## Observation level
Per-subject, per-frequency, per-medium threshold (dB) and false-alarm rate
(%). Aerial testing used one animal per species (3 subjects x 7 frequencies
= 21 rows). Underwater testing used two sea lions (Rocky and Rio) in
addition to the harbor seal and elephant seal, and not every subject was
tested at every frequency (3200 Hz and 6300 Hz are elephant-seal-only rows,
reflecting that species' higher effective upper limit; 6400 Hz has no
elephant-seal row because 6300 Hz was its highest frequency tested) --
these gaps are exactly as printed, not filled in.

## Units
Aerial thresholds are dB re 20 uPa; underwater thresholds are dB re 1 uPa
(kept as separate reference pressures, not converted to a common scale, to
match how the paper itself reports and later compares them). False-alarm
rate is percent of catch trials.
