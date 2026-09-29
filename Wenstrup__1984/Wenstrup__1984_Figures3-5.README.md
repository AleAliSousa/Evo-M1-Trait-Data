# Wenstrup__1984_Figures3-5

## Source
Wenstrup, J. J. (1984). Auditory sensitivity in the fish-catching bat,
*Noctilio leporinus*. *Journal of Comparative Physiology A*, 155, 91-101.
doi:10.1007/BF00610934

Registry Item **Figures 3-5** (name retained from the pre-existing
candidate row), printed p. 96 (Results text) and Figs. 3-5 (individual
audiogram curves, pp. 94-95). Public copy:
`Wenstrup__1984/Wenstrup__1984.pdf`.

## N.B. -- built from text, not from digitizing the named figures
The candidate-row note anticipated needing to digitize Figs. 3-5 ("check
Results text for stated values before digitising"). On inspection, the
Results text (p. 96) does state usable group-level summary numbers in
prose, so this item is built entirely from that text; the figures were
*not* digitized. The item name is kept as `Figures3-5` to match the
pre-existing registry row this build fills in, even though the content is
in fact a text-based summary.

## Why this item exists
Three fish-catching bats (NL7, NL9, NL21) were tested with operant
conditioning for behavioral pure-tone audiograms. The Results state: "Within
the range of frequencies corresponding to the fundamental of the bats'
orientation signals, sensitivity was very good; thresholds were always less
than 10 dB SPL between 32 kHz and 57 kHz. Maximum auditory sensitivity
occurred near the frequency of the CF (56-58 kHz) in all three bats and
ranged from -1 to +4 dB SPL... The low frequency limit ... averaged 7 kHz in
the three bats... the 60 dB high frequency limit was 101 kHz for NL9 and
115 kHz for NL21" (NL7 was not tested at that edge, so no 60-dB high-limit
value exists for it).

## Pipeline
Results text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Wenstrup__1984_Figures3-5_snapshot.csv` | frozen source, one row per bat |
| `Wenstrup__1984_Figures3-5.R` | reads the snapshot, writes CSV + public TSV |
| `Wenstrup__1984_Figures3-5.csv` | tidy analysis rows |
| `reference_tables/Wenstrup__1984_Figures3-5_definitions.csv` | data dictionary |

## Data role
All 3 rows are this paper's own new behavioral measurements.

## Observation level
Per-individual bat (n=3), but note that the CF frequency and CF-region
threshold range are **not** broken out per animal in the text -- the same
group-level range (56-58 kHz; -1 to +4 dB SPL) is stated for all three, and
is therefore repeated identically across the three rows rather than
fabricated as distinct per-bat values. Only the high-frequency 60-dB limit
(101/115 kHz) is genuinely per-animal in the source text.

## Units
- `cf_frequency_kHz`, `audible_freq_low/high_60dBSPL_kHz`: kHz.
- `threshold_at_cf_dB_low/high`: dB SPL, the group range at the CF peak.

## Relationship to SensoryData_compiled cross-reference
This registry row's own N.B. (from the pre-existing candidate entry) states
SensoryData_compiled uses `best_sensitivity: Noctilio leporinus = 3 dB;
best_frequency: Noctilio leporinus = 56 kHz` -- a single point value. The
text supports a peak frequency near 56-58 kHz (consistent with "56 kHz")
but only a *range* of -1 to +4 dB SPL for the group, not a single "3 dB"
value; 3 dB falls within that range but is not itself printed. This
discrepancy is flagged here rather than silently reconciled.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Wenstrup__1984_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Wenstrup__1984-E001 | cf_frequency_kHz | Summary point 3 and Results (PDF p2, p5): CF component 56-59 kHz; 'abrupt increase in threshold above 56 to 58 kHz' | 56-59 kHz (band); no single best frequency printed | 57 | publication_ambiguity | 56-59 (band) | confirmed | Text read 2026-09-29: maximum sensitivity is stated for the region of the CF sonar component, given as 56-59 kHz (abstract, results) and 56-58 kHz (summary); the paper never states one best frequency. The repo's 57 is a declared approximation (definitions note), not a printed value. | Merges should treat cf_frequency_kHz as a band centre, not a measured best frequency. The Bath workbook holds 56 (the lower bound). |

1 recorded, 0 open (proposed), 1 confirmed, 0 withdrawn.
<!-- errata:end -->
