# Schenker et al. 2010 Table 3

Source: Schenker et al. (2010), *Cerebral Cortex* 20:730–742, DOI [10.1093/cercor/bhp138](https://doi.org/10.1093/cercor/bhp138), Table 3 (local PDF p. 6). The frozen CSV preserves printed columns and Mean, SD and CV rows. AI compared it with the PDF on 2026-11-25; human visual signoff is pending.

The 48 analysis rows are the same 12 individual chimpanzees × two hemispheres × BA44/BA45 as Table 2. Printed density in thousands/mm³ is converted to neurons/mm³ (×1,000); printed total neurons in millions is converted to absolute neurons (×1,000,000). Counts and densities are not separate animals. The coefficient of error belongs to the total-neuron stereological estimate, not biological variation. The source's density is based on shrinkage-corrected volume. Table 2 has sex, age and volumes; join by case, hemisphere and area.

Run `Rscript Schenker_etal_2010/Schenker_etal_2010_Table3.R` from the repository root. It reads only its snapshot and writes the CSV and public TSV. Published quantities are estimates rounded to printed precision, so neuron density × volume need not reproduce the printed neuron count exactly; this is not used as a table check.

## Snapshot layout correction (2026-11-27)

Restored the printed Table 3 caption, grouped measurement heading and bottom note, with the separate subject/area header tiers. The R reader selects the 12 specimen rows from the corrected source grid. Run `Rscript --vanilla Schenker_etal_2010/Schenker_etal_2010_Table3.R` from repository root. Independent human source comparison remains separate.
