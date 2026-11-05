# Llorente_etal_2009_TableII

**Item name** `Llorente_etal_2009_TableII` · **Item number** `Table II` · Item encoded: looked up live from `__ReadMe.xlsx`.

Llorente, M., Mosquera, M., & Fabré, M. (2009). Manual laterality for simple reaching and bimanual coordinated task in naturalistic housed Pan troglodytes. International Journal of Primatology, 30(1), 183–197. https://doi.org/10.1007/s10764-009-9338-1

**Item full original title:** Table II Laterality indices for tube task, simple reaching, and multitask evaluation (pp. 190-191).

## Source and pipeline
PDF in this folder. The table is printed across two pages (subjects Bongo-Sara on p. 190, Tico-Waty plus the group statistics on p. 191). `Llorente_etal_2009_TableII_snapshot.csv` is a **hand transcription from 2.2x renders of both pages** (the PDF text layer drops blank cells, so it could not be used alone): 33 rows x 14 subject columns + Mean value, SE, SD, t, df, p, Lateralized L/R/A, with blank cells kept. `Llorente_etal_2009_TableII.R` reshapes it to long format (individual and group_summary rows) and writes `Llorente_etal_2009_TableII.csv` + the public TSV.

## What it holds
Per chimpanzee and measure: tube-task SUMHI, M-HI, ABSHI, % right-hand use, n responses, HI by test, finger/tool use, technique counts; simple-reaching HI/ABSHI, posture and grip splits; multitask HI and consistency of preference. Group columns: mean, SE, SD, one-sample t-test, L/R/A lateralization counts. Role: **primary**. Püschel et al. 2026 take the *Pan troglodytes* handedness row from this paper (tube-task mean HI).

## Printed oddities (kept; the table checks flag them)
- The printed simple-reaching **ABSHI** row does not match |HI| subject by subject (e.g. Charly HI -0.481 vs ABSHI 0.027); the same numbers appear in a different order. Kept as printed.
- The first row under *Tube task* has no label and holds 0.000 for every subject (binomial test p). Named "binomial test (label not printed)" by analogy with the *Simple reaching* block.

## Table checks
Printed Mean vs mean of the individual values, and SE vs SD/sqrt(n), per row. Run 2026-11-04 (Rscript): **54 pass, 2 mismatch**, of 56 checks.

- **Tube task M-HI:** printed SE 0.198 does not equal printed SD / sqrt(14) = 0.126 (SD printed 0.470). SUMHI in the same block is consistent (SD 0.789, SE 0.211), and an SD of about 0.741 would give SE 0.198, so one of the two printed cells is probably wrong. Publication discrepancy: kept as printed, a candidate for the errata file.
- **Simple reaching, % right hand use:** mean of the 14 printed individual values is 61.04 against a printed Mean of 60.96 (tolerance 0.01); one individual cell or the Mean is probably misprinted. Kept as printed.
- The simple-reaching **ABSHI** row passes its mean check, so its values are the right numbers in the wrong order (a permutation of |HI|, printed under the wrong subjects). Kept as printed.

*Built 2026-11-04 by an AI assistant; the human visual check of the snapshot against the PDF is still pending.*
