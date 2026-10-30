# Seelke et al. 2016 — Table 2

Source: Seelke, A. M. H., Yuan, S.-M., Perkeybile, A. M., Krubitzer, L. A., & Bales, K. L. (2016). Early experiences can alter the size of cortical fields in prairie voles (*Microtus ochrogaster*). *Environmental Epigenetics, 2*(3), dvw019. https://doi.org/10.1093/eep/dvw019

The printed mean ± SE cells are frozen in `Seelke_etal_2016_Table2_snapshot.csv`; group/sex sample sizes from Methods are frozen separately. The R script emits 70 rows: seven measurements across ten group × sex combinations. All percentages use the adjusted cortical-sheet area as denominator; no absolute mm² values are available.

The 64 animals comprise HC (6 male, 5 female), LC (7 male, 3 female), saline (8 male, 8 female), OT (11 male, 3 female), and OTA (8 male, 5 female). When both hemispheres were available the authors averaged them within animal before computing group means.

Three source-level concerns are retained as row-level flags rather than corrections:

- OTA male and female means are identical for six of the seven measures despite different sample sizes and uncertainty values, suggesting a possible printed copy error.
- Low-contact females have listed fields summing to 56.09% against a printed `%Myelin` value of 53.56%, leaving an impossible derived remainder of -2.53 percentage points.
- OT males received 3 µg oxytocin while OT females received 6 µg; the 25 µl injection volume was common, but dose was not.

Groups with n=3 are separately flagged. `derived_unlisted_myelin_pct`, `source_flags`, and `source_issue_note` expose these checks without changing any printed mean or SE.
