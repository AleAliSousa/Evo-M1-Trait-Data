# Heffner_etal_2015_TableI

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2015). Sound localization in
common vampire bats: Acuity and use of the binaural time cue by a small
mammal. *Journal of the Acoustical Society of America*, 137(1), 42–52.
doi:10.1121/1.4904529

Registry Item **Table I**, printed p. 46. Public copy:
`Heffner_etal_2015/Heffner-2015-Sound localization in common vamp.pdf`.

## Why this item exists
This paper reports the first passive sound-localization and binaural-cue-use
data for the common vampire bat (*Desmodus rotundus*). Table I places this
new measurement alongside seven previously published bat values (the same
comparison set used in the paper's Fig. 3), giving each species' functional
head size, minimum audible angle, and (where used) the highest frequency at
which the binaural phase-difference (time) cue was demonstrated.

## Pipeline
Printed table → snapshot → analysis csv → public TSV.

| file | role |
|---|---|
| `Heffner_etal_2015_TableI_snapshot.csv` | frozen source, printed layout |
| `Heffner_etal_2015_TableI.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_2015_TableI.csv` | one row per species (8) |
| `reference_tables/Heffner_etal_2015_TableI_definitions.csv` | data dictionary |

## Data role — mixed, by row
Only the *Desmodus rotundus* row is this paper's own new data. The other
seven rows are secondary — reproduced in the paper's own Table I from
Heffner et al. (2007, 2010a, 2010b, 2001c), Koay et al. (1998), and Heffner
et al. (1999, 2008) for comparison. `data_role` marks this per row.

## Printed oddities carried as-is
- The source table's footnote system (superscript a–i) is flattened into the
  `source` column and the boolean `phase_cue_used`/blank `phase_cue_upper_limit_kHz`
  pairing, exactly reproducing the printed "Cue not used" cells.

## Observation level
Species mean (minimum audible angle averaged across 3 tested vampire bats;
comparison species are likewise species means from their own source papers).

## Units
Microseconds (functional head size), degrees (minimum audible angle), kHz
(phase-cue upper frequency limit).
