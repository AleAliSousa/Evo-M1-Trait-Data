# Schusterman__1981_Table1

## Source
Schusterman, R. J. (1981). Behavioral capabilities of seals and sea
lions: A review of their hearing, visual, learning and diving skills.
*The Psychological Record*, 31, 125-143. https://doi.org/10.1007/BF03394729

Registry Item **Table 1**, printed p. 128. Public copy:
`Schusterman__1981/Schusterman-1981-Behavioral Capabilities of Se.pdf`.

## N.B. -- this source is a REVIEW/COMPILATION, not a primary data paper
This entire paper is a review ("Behavioral capabilities of seals and sea
lions ... are described and summarized in tabular form"). Table 1 itself
is a compilation: every row's underwater-audiogram summary is drawn from
and cites a previously published **primary** study, not new data measured
by Schusterman for this review:

| Species | Cited primary source |
|---|---|
| California sea lion | Schusterman, Balliet, & Nixon (1972) |
| Northern fur seal | Schusterman & Moore (1978b) |
| Harbor seal | Møhl (1968) -- the same paper built separately in this project as `Mohl__1968_Table2`, though that item transcribes the full air+water threshold table rather than this review's condensed best-range/high-cutoff summary |
| Harp seal | Terhune & Ronald (1972) |
| Ringed seal | Terhune & Ronald (1975a) |
| Gray seal | Ridgway (1973) -- an **evoked-potential** audiogram, not a behavioral one; flagged in `notes` |

This item was built anyway (rather than skipped as "not primary data")
because Table 1 is the only place among this project's source PDFs where
these six pinniped species' key underwater-audiogram features (best
sensitivity range and its dB values, and approximate high-frequency
cutoff) are tabulated side-by-side for direct cross-species comparison --
precisely the kind of comparative summary this registry curates. The
review's other hearing tables (Table 2 aerial audiograms, Table 3
frequency discrimination, Table 4 localization/MAA) were considered but
not selected, per house rule to build only one priority item per source.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Schusterman__1981_Table1_snapshot.csv` | frozen source, printed layout |
| `Schusterman__1981_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Schusterman__1981_Table1.csv` | tidy analysis rows |
| `reference_tables/Schusterman__1981_Table1_definitions.csv` | data dictionary |

## Data role
Every row is secondary (cited-from-elsewhere) data as far as this specific
review paper is concerned; `primary_source_cited` records which original
study each row's numbers came from, per the source table's own "Source"
column.

## Observation level
One row per species, summarizing (not replacing) that species' full
audiogram as a best-sensitivity frequency range + threshold range +
approximate high-frequency cutoff, with the number of subjects the
underlying primary study tested.

## Units
- `best_range_freq_low_kHz` / `best_range_freq_high_kHz`: the frequency
  span (kHz) over which that species showed its best (most sensitive)
  thresholds, as printed.
- `best_range_threshold_low_dB` / `best_range_threshold_high_dB`: the
  corresponding threshold range, in dB re 1 µBar (as stated in the source
  table footnote "a").
- `high_freq_cutoff_low_kHz` / `high_freq_cutoff_high_kHz`: the
  approximate high-frequency hearing cutoff, in kHz, as printed (a single
  value like "60" is stored as low=high=60).
