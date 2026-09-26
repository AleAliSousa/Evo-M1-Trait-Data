# Heffner_etal_2008_Table1

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2008). Sound-localization acuity
and its relation to vision in large and small fruit-eating bats: II.
Non-echolocating species, *Eidolon helvum* and *Cynopterus brachyotis*.
*Hearing Research*, 241, 80–86. doi:10.1016/j.heares.2008.05.001

Registry Item **Table 1**, printed p. 84. Public copy: `Heffner_etal_2008/Heffner-2008-Sound localization acuity and its.pdf`.

## Why this item exists
This paper reports the first passive sound-localization thresholds for two
non-echolocating Old World fruit bats (Pteropodidae): the straw-colored fruit
bat (*Eidolon helvum*) and the dog-faced fruit bat (*Cynopterus brachyotis*).
Table 1 places these two new measurements alongside five previously published
bat thresholds for comparison — the same comparison set the paper's own
discussion and Fig. 3 use.

## Pipeline
Printed table → snapshot → analysis csv → public TSV.

| file | role |
|---|---|
| `Heffner_etal_2008_Table1_snapshot.csv` | frozen source, printed layout |
| `Heffner_etal_2008_Table1.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_2008_Table1.csv` | one row per species (7) |
| `reference_tables/Heffner_etal_2008_Table1_definitions.csv` | data dictionary |

## Data role — mixed, by row
Only the *Eidolon helvum* and *Cynopterus brachyotis* rows are this paper's
own new data (measured with the same conditioned suppression/avoidance
procedure used throughout the Heffner lab's bat series). The other five rows
are secondary — reproduced in the paper's own Table 1 from Heffner et al.
(2007), Heffner et al. (2001), Heffner et al. (1999), and Koay et al. (1998)
for comparison. `data_role` marks this per row; only `primary` rows should be
counted as this item's own contribution when merging.

## Observation level
Species mean threshold (minimum audible angle), not per-individual. The paper
tested 2 individuals each of *E. helvum* and *C. brachyotis*; per-bat values
are in the paper's Fig. 1 discussion (11.7° mean for *E. helvum*, 10.5° mean
for *C. brachyotis*) but only the species mean is printed in Table 1.

## Units
Degrees (minimum audible angle at 50% corrected-detection performance for a
100-ms broadband noise burst).
