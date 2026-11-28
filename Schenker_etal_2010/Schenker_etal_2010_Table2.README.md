# Schenker et al. 2010 Table 2

Source: Schenker et al. (2010), *Cerebral Cortex* 20:730–742, DOI [10.1093/cercor/bhp138](https://doi.org/10.1093/cercor/bhp138), Table 2 (local PDF p. 5). The frozen CSV follows the printed column and row order, including the Mean, SD, and CV summary rows. AI compared the snapshot with the PDF on 2026-11-25; human visual signoff is pending.

The analysis has 48 rows: 12 individual chimpanzees × two hemispheres × BA44/BA45. `C` case codes, sex and age are printed in this table. Whole-brain and neocortical gray volumes are converted from cm³ to mm³ (×1,000); BA volumes are already in mm³ and corrected for tissue shrinkage. Printed coefficients of error are stereological method uncertainty, not between-animal SD. Whole-brain volume repeats across each case's four area rows; neocortical gray volume repeats for each hemisphere. Do not count these repeated cells as independent specimens.

Run `Rscript Schenker_etal_2010/Schenker_etal_2010_Table2.R` from the repository root. It reads only this item's frozen snapshot and writes the analysis CSV and public TSV. The source supplies no internal total that can validate the area measurements by summation. Table 3 holds the same cases and supplies neuron data; join by case, hemisphere and cortical area, without adding new animals. The 2007 dissertation Chapter III uses different printed case codes, and no code alias to this 2010 cohort is asserted.

## Snapshot layout correction (2026-11-27)

Restored the printed Table 2 caption, grouped measurement heading and bottom note. The R reader selects the 12 specimen rows from the corrected source grid. Run `Rscript --vanilla Schenker_etal_2010/Schenker_etal_2010_Table2.R` from repository root. Independent human source comparison remains separate.
