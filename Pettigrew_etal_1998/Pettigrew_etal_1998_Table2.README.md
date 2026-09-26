# Pettigrew_etal_1998_Table2

## Source
Pettigrew, J. D., Manger, P. R., & Fine, S. L. B. (1998). The sensory world
of the platypus. *Philosophical Transactions of the Royal Society of London
B*, 353(1372), 1199–1210. doi:10.1098/rstb.1998.0276

Registry Item **Table 2**, printed p. 1201 ("Visual cortical magnification
and retinal acuity in some mammals"). Public copy:
`Pettigrew_etal_1998/Pettigrew-1998-The sensory world of the platyp.pdf`.

## Why this item exists
This paper reports the first estimate of visual cortical magnification and
retinal-ganglion-cell-based acuity for the platypus. Table 2 places this new
measurement alongside 12 previously published mammal values (the same
comparison set used in the paper's own Fig. 4 and its retinotectal/
retinogeniculate discussion), split into two groups by which visual pathway
dominates the species' retinal projections.

## Pipeline
Printed table → snapshot → analysis csv → public TSV.

| file | role |
|---|---|
| `Pettigrew_etal_1998_Table2_snapshot.csv` | frozen source, printed layout, two group headers kept as printed |
| `Pettigrew_etal_1998_Table2.R` | reads the snapshot, writes CSV + public TSV |
| `Pettigrew_etal_1998_Table2.csv` | one row per species (13) |
| `reference_tables/Pettigrew_etal_1998_Table2_definitions.csv` | data dictionary |

## Data role — mixed, by row
Only the *platypus* row is this paper's own new data (computed from the
paper's own cortical mapping in Fig. 3 and the retinal ganglion-cell map in
Fig. 2). The other 12 rows are secondary — reproduced in the paper's own
Table 2 from prior literature for comparison. `data_role` marks this per row.

## Printed oddities carried as-is
- Several species are named only generically in the printed table (aotus,
  agouti, hedgehog, ferret, flying fox) — no species epithet is given, so
  `binomial` is left at genus/family level for those rows rather than guessed.
- "cat" magnification is printed as "ca. 1" (approximate); stored as the
  bare value `1`.

## Observation level
Species-level summary value (not per-individual); the platypus row derives
from the paper's own cortical-mapping dataset (Table 1 of the same paper,
not separately registered here).

## Units
mm cortex per degree (magnification), cycles per degree (acuity), cycles per
mm (ratio).
