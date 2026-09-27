# Heffner_etal_2014_Resultstext

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas
(*Vicugna pacos*): audiogram, localization acuity, and use of binaural
locus cues. *Journal of the Acoustical Society of America*, 135(2), 778-788.
doi:10.1121/1.4861344

Registry Item **Results text**, printed pp. 781-783 (Sections III.A-D).
Public copy: `Heffner_etal_2014/Heffner_etal_2014.pdf`.

## Why this item exists
This paper reports the first behavioral audiogram, sound-localization
acuity, and binaural-cue-use data for the alpaca, a large domestic South
American camelid. Three young adult males were tested with a conditioned
suppression/avoidance procedure. The paper's headline results are stated
explicitly and completely in the Results text (Sections III.A Audiogram,
III.B Broadband noise localization, III.C Localization of pure tones,
III.D Front/back localization), so this item transcribes those printed
sentences directly rather than digitizing any of Figs. 3-6.

## Pipeline
Results text -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_etal_2014_Resultstext_snapshot.csv` | frozen source, one row per stated trait |
| `Heffner_etal_2014_Resultstext.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_2014_Resultstext.csv` | tidy analysis rows |
| `reference_tables/Heffner_etal_2014_Resultstext_definitions.csv` | data dictionary |

## Data role
All rows are this paper's own new measurements (n=3 alpacas for the
audiogram and MAA; n=1-2 for the binaural-cue and pinna-cue sub-experiments).

## Observation level
Species mean thresholds/angles across the tested subjects, as printed in
the Results text (not per-individual raw data, which is shown only in the
figures).

## Units and important omission
- `audible_freq_low/high_60dBSPL`, `best_frequency`: kHz/Hz as printed.
- `best_sensitivity`: dB SPL re 20 uPa.
- `sound_localization_threshold`: degrees (minimum audible angle, 50%
  corrected-detection threshold for 100-ms broadband noise).
- `binaural_phase_cue`/`binaural_intensity_cue`: Y/N, whether the alpacas
  could use that cue to localize pure tones (phase/time cue: yes, for tones
  at/below ~1 kHz; intensity cue: no, for tones at/above ~2 kHz).
- `pinna_cue_use`: Y, alpaca A could discriminate front/back sound sources
  using high-frequency (3-kHz-high-pass) but not low-frequency noise.
- **Functional interaural distance is deliberately NOT included as a
  numeric value in this item.** The paper's Figs. 8 and 11 plot alpacas'
  functional interaural distance against a fitted cross-species
  relationship, and other project documentation (this registry's own
  candidate-row note, echoing `SensoryData_compiled.csv`) cites a value of
  544 us for this species/paper -- but that number is not printed anywhere
  in this item's Results-text sections as searched, only shown graphically.
  Per house rule (never fabricate a value not actually stated in the
  source), it is omitted here rather than copied from the external
  cross-reference sheet without being able to verify it against the primary
  text. If a printed number is later found (e.g. in a table this search
  missed), add it as a tenth row.
