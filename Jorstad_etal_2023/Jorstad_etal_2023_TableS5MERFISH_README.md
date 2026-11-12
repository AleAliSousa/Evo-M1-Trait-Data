# Table S5 sheet 1: MERFISH proportions and E:I ratios

## Publication
Jorstad, N. L., et al. (2023). Transcriptomic cytoarchitecture reveals principles of human neocortex organization. Science, 382(6667), eadf6812. https://doi.org/10.1126/science.adf6812

- DOI: 10.1126/science.adf6812
- DOI-encoded key: `10.1126%2Fscience.adf6812`
- Source table/result set: Table S5 / MERFISH
- Data role: Derived from primary MERFISH cell-level measurements
- Rows: 194
- Columns: 5

## Source and snapshot
The supplied source is a digital-native table. The frozen snapshot is therefore an unchanged byte-for-byte copy of the supplied CSV/XLSX source. SHA-256 values are recorded in `MANIFEST.csv`. No values were estimated, digitized from figures, or reconstructed.

## Build
x <- tidyr::pivot_longer(x, cols = -c(Area, Metric, Grouping), names_to = "donor", values_to = "value", values_drop_na = TRUE)
x$Grouping <- trimws(gsub(" ", " ", x$Grouping, fixed = TRUE))
x <- x[, c("donor", "Area", "Metric", "Grouping", "value")]

## Scope and cautions
- Adult human neocortical data only; these are donor-, area-, layer-, class-, and subclass-level results, not cross-species species means.
- Preserve donor identifiers, cortical-area abbreviations, subclass labels, units/scales, missing cells, and published precision.
- Blank values remain blank.
- Table S5 proportions and E:I ratios are reported/analysis outputs from the publication and are classified as derived from primary snRNA-seq or MERFISH measurements.
- Visual review remains advisable for interpretation of layer labels and metric denominators, but no visual transcription was used.
