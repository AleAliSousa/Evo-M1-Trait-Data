# Heffner_etal_2016_Table1

## Source
Heffner, H. E., Koay, G., & Heffner, R. S. (2016). Budgerigars
(*Melopsittacus undulatus*) do not hear infrasound: the audiogram from 8 Hz
to 10 kHz. *Journal of Comparative Physiology A*, 202(12), 853-857.
doi:10.1007/s00359-016-1125-9

Registry Item **Table 1**, printed p. 856. Public copy:
`Heffner_etal_2016/Heffner-2016-Budgerigars (Melopsittacus undula.pdf`.

## Taxon note (non-mammal, deliberately included)
*Melopsittacus undulatus* (budgerigar) is a **bird**, not a mammal. This
folder was nonetheless deliberately included in this hearing/audiogram
data cluster, most likely as a comparative low-frequency-hearing reference
point: the paper's central finding is that budgerigars, unlike pigeons and
domestic chickens (the only other two bird species with published
infrasound data), do **not** hear infrasound, which is directly useful for
contextualizing the low-frequency hearing limits of the mammals in this
same registry cluster (e.g., the elephant and rhinoceros items, which are
each argued in their own papers to have unusually good low-frequency
hearing for a mammal). Built and registered per the house instruction to
include it and clearly flag the taxon.

## Why this item exists
This is the first published audiogram of any bird tested down to 8 Hz.
Table 1 gives the full individual and mean pure-tone thresholds for three
budgerigars (P1, P2, P3) at 14 test frequencies from 8 Hz to 10 kHz. At 60
dB SPL, the budgerigar's hearing range extends from 77 Hz to 7.6 kHz (6.6
octaves), with best sensitivity of 1.1 dB at 3 kHz -- unlike pigeons and
chickens, budgerigars do not have better low-frequency hearing than humans.

## Pipeline
Printed table -> snapshot -> analysis csv (long format) -> public TSV.

| file | role |
|---|---|
| `Heffner_etal_2016_Table1_snapshot.csv` | frozen source, printed layout (wide: one row per frequency) |
| `Heffner_etal_2016_Table1.R` | reshapes snapshot to long format, writes CSV + public TSV |
| `Heffner_etal_2016_Table1.csv` | one row per frequency x individual/mean (14 x 4 = 56 rows) |
| `reference_tables/Heffner_etal_2016_Table1_definitions.csv` | data dictionary |

## Data role
All rows are this paper's own new measurements (primary); no secondary/cited
comparison rows are included in Table 1 itself (the paper's Fig. 1 and Fig.
2 compare this audiogram with earlier budgerigar/human/pigeon/chicken
studies, but those comparison curves are not reproduced in Table 1 and are
out of scope for this item).

## Observation level
Individual bird thresholds (P1 female, P2 male, P3 female) plus the
paper's own printed across-bird mean, one row per frequency per
individual/mean combination. Each printed mean was independently
recomputed in Python (and re-verified by the assertion in the R script)
from the three individual thresholds and reproduces exactly to the printed
precision at all 14 frequencies -- no arithmetic discrepancies found.

## Units
Frequency in Hz; threshold in dB SPL (re 20 uN/m^2), determined via an
operant conditioning (food-reinforced key-peck) go/no-go procedure with a
0.50 corrected-performance criterion.
