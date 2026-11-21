# Spinelli_etal_2009_Table2

Spinelli, S., Chefer, S., Suomi, S. J., Higley, J. D., Barr, C. S., & Stein, E. (2009). Early-life stress induces long-term morphologic changes in primate brain. Archives of General Psychiatry, 66(6), 658–665. https://doi.org/10.1001/archgenpsychiatry.2009.52

**Item number:** Table 2. **Source:** [PDF p.6, printed p.663](https://www.psychiatry.wisc.edu/courses/Nitschke/seminar/Spinelli%20S%2C%20Arch%20Gen%20Psych%2066%2C%202009.pdf); PDF `spinelli2009.pdf` (SHA256 in reference_tables provenance).

## Source and build

Table 2. Normalized and Absolute Volumes of Brain Areas Measured in MR and PR Groups

The `_snapshot.csv` is a frozen source-layout transcription, retaining headers, row/column order, all groups, missing cells, significance markers and notes. `Spinelli_etal_2009_Table2_snapshot.R` writes only that snapshot and refuses a differing overwrite. `Spinelli_etal_2009_Table2.R` reads its own snapshot, splits means and SEM, and writes the long analysis CSV. Source values are never inferred from percentages or altered to satisfy checks. Source PDF preserved untouched. AI extraction/check date: 2026-11-20; human RA visual signoff remains pending.

## Interpretation

Random assignment at birth; MR n=15, PR n=13. PR animals nursery/peer reared without mothers for first 6 months, then groups housed together. One mPFC trace unavailable; group of missing animal not specified, so subgroup effective n is unknown. PFL includes gray and white matter; mPFC and dmPFC nested within PFL, dmPFC nested within mPFC. CC and CBV are midsagittal areas, not volumes, despite the spanning mm3 header. Preserve printed percentage differences and test independently.

Species as published: rhesus monkeys (Macaca mulatta). Accepted species: Macaca mulatta. Primary data; group means, not individuals and not species means. No global trait merges or species keys edited.

## Registration and units

Main registry has no matching item as of 2026-11-20. Registry-row workbook is prepared against the live header schema. Owner pastes A-D and M onward, preserves E-L formulas, runs `_tools/file_list.R`, and verifies Item encoded. The R reader writes the public TSV only after the live main registry resolves exactly one Item name. No derived identifier is substituted for the registry. Analysis proceeds from the CSV independently of pending registration.

Physical units: volume mm3 (Sarabdjitsingh μl converted 1:1), area mm2, or source-normalized dimensionless values x1000. In Spinelli, areas are explicitly identified from footnote a; their source header is preserved in the snapshot. Normalized means are the published means of animal-level ratios, not ratios reconstructed from group means.

## Checks and limitations

The reader leaves a `table_checks` object recomputing all 13 printed percentage differences. ICV is inconsistent with the two printed means (1.61% printed, approximately 1.581% recomputed); preserve this source discrepancy. CC and CBV are excluded from volume-only fits and all volumetric energy budgets.
