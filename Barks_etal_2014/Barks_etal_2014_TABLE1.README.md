# Barks et al. 2014, Table 1

Source: `Barks-2014-Brain organization o.pdf`, printed Table 1 on PDF p. 2 (left table). The five columns are Subject, Sex, Age, Rearing history, and Brain volume (cm³). The source groups 36 gorillas into mountain, Grauer's, and western lowland sections and ends with the cerebellum footnote.

`Barks_etal_2014_TABLE1_snapshot.xlsx` retains that order and grouping. This layout pass restored the printed caption as a row and restored leading zeroes in four-character subject codes (for example, `0003`). `Barks_etal_2014_TABLE1.R` skips the caption and converts subject codes to the prior analysis form; the 36-row CSV and public TSV rebuilt, and the CSV matched the pre-change version byte for byte.

Run: `Rscript --vanilla Barks_etal_2014/Barks_etal_2014_TABLE1.R` from the repository root. The assistant checked layout against the rendered/source-text PDF; human visual signoff remains open.
