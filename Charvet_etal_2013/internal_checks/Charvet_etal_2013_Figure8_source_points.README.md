# Figure 8 source table reconstruction

Run from the repository root:

```sh
Rscript --vanilla Charvet_etal_2013/internal_checks/Charvet_etal_2013_Figure8_source_points.R
Rscript --vanilla Charvet_etal_2013/internal_checks/Charvet_etal_2013_Figure8_source_points_replot.R
```

The first script reads the **already built** source-item CSVs and writes
`Charvet_etal_2013_Figure8_source_points.csv` here. It uses cerebral cortex
mass and neurons from Herculano-Houzel et al. 2007 SI Table 2 (six primates),
Gabi et al. 2010 Table 1 (five primates), and Herculano-Houzel et al. 2011
Table 1 (ten rodents). It excludes the 2007 tree shrew and 2011 rabbit because
Figure 8 labels those plotted series primates and rodents. The 2011 bilateral
summaries combine some animals measured on both sides with others estimated by
doubling one side; dividing by two reconstructs the **comparison scale**, not
an independently measured hemisphere for every animal.

For each of the 21 comparison points, published bilateral mass and neurons are
divided by two. The unilateral mass (g) is divided by **1.036 g/cm³**, exactly
as Charvet's Figure 8 caption states, to obtain volume in cm³. Both axes are
natural logs; the neuron axis logs counts in millions. The source values,
sample counts, SDs where published, cortex definition, and scope remain in
the CSV. Cerebral cortex includes limbic components and must not be relabeled
as isocortex. Reep et al. (2007) supplies anatomical context in the caption,
not a Figure 8 point.

The final six rows are this study's Table 2 isocortical neuron counts. Their
neuron coordinates are built, but volume coordinates are blank because that
table does not print them. Later reconstruction must use a documented volume
source or digitize Figure 8/2B; do not substitute another species mean. The
replot script reads this CSV directly and plots the 21 full table-based points
with the source's series symbols, axis scales and units. It omits the six
Charvet points for lack of x values, as annotated on the PNG. The PNG was
run and inspected against the published Figure 8 on 2026-11-24; it is an
automated visual check, not human visual signoff. No source figure was
digitized, smoothed or refitted.
