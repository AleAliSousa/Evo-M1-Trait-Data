# Collins et al. 2013 contribution to Charvet Figure 7

Run `Rscript --vanilla Charvet_etal_2013/internal_checks/Charvet_etal_2013_Figure7_Collins2013_point.R`
from the repository root. The script reads the existing Collins Table 1 CSV and
writes one audit row here. Table 1 prints *M. mulatta* V1 **1.880 ± 0.085 g**
and **213.76 ± 54.27 million neurons** (SD; two hemispheres from two animals).
They are already single-hemisphere estimates. The source table has mass, not
volume. Applying the 1.036 g/cm³ conversion specified by Charvet's Figure 8
caption yields 1,814.67 mm³; using that same conversion in Figure 7 is an
explicit inference, not a Collins measurement. Charvet displays a single
downward triangle without its published SDs. This is a table-derived check,
not a digitization of Figure 7. The values align approximately with the
plotted triangle; human visual signoff is pending.
