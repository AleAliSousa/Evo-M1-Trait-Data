# Plavcan & van Schaik 1997b Table 1

Source: `Plavcan-1997-Interpreting hominid behavior on.pdf`, Table 1 on
printed pp. 347–348 (PDF pp. 3–4). The frozen snapshot preserves the table's
87 species rows, source order, 13 printed value columns, centered-dot decimal
marks, and em dashes for missing canine values. The extraction script reads
only those two PDF pages and refuses to overwrite a snapshot if its bytes
change. The author text describes 86 body-weight species, while Table 1
contains 87 rows; the printed table is retained without dropping a species.

From the repo root, run
`Rscript Plavcan_vanSchaik_1997_b/Plavcan_vanSchaik_1997_b_Table1_snapshot.R`
to verify the frozen snapshot, then
`Rscript Plavcan_vanSchaik_1997_b/Plavcan_vanSchaik_1997_b_Table1.R`
to rebuild the analysis CSV and registered public TSV. The printed male/female
weight ratio was checked against the printed weights for all 87 rows: maximum
absolute difference 0.005781, within a 0.02 rounding tolerance. The reported
ratio itself is never replaced by the recalculation.

Species names are retained as printed, including historical taxon concepts;
`Species` is provisional, not a modern taxonomy crosswalk. Body weights come
largely from another Plavcan & van Schaik 1997 source, and canine dimensions
from Plavcan 1990, per the Methods. Treat this table as a secondary compilation
and check observation overlap before a pooled merge. The male canine size
columns have no unit printed in Table 1 and stay in source units. Competition
level is an ordinal category, not a continuous measurement.

The PDF text layer and extracted rows were checked on 2026-11-26. No human
visual signoff is claimed. The existing main-registry row has an encoded item
name and public TSV path; descriptive metadata and signoff are staged in
`Plavcan_vanSchaik_1997_b_Table1_registry_row.xlsx` for owner review.

## Snapshot layout correction (2026-11-27)

Restored the printed caption, Weight/Mandibular/Maxillary/Male spanning headers, and the continuation caption and repeated headings at the page break after Presbytis potenziani. R selects the 87 source data rows and assigns analytic column names. `source_row` now identifies physical snapshot rows. Run `Rscript --vanilla Plavcan_vanSchaik_1997_b/Plavcan_vanSchaik_1997_b_Table1.R` from repository root. Independent human source comparison remains separate.
