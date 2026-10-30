# Rebuild the analysis CSV from the frozen publisher Supplementary Table 1.
script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file)) {
  args <- commandArgs(trailingOnly = FALSE)
  script_file <- sub('^--file=', '', args[grepl('^--file=', args)][1])
}
if (is.na(script_file) || !nzchar(script_file)) stop('Run this saved script with Rscript or source it.')
folder <- dirname(normalizePath(script_file))
source_file <- file.path(folder, 'Sherwood_etal_2020_SuppTable1_snapshot.xlsx')
if (!requireNamespace('readxl', quietly = TRUE)) stop('readxl is required')
x <- readxl::read_excel(source_file, col_types = c('text', 'text', 'text', 'text'))
if (nrow(x) != 27L || !identical(names(x), c('Species', 'Sex', 'Age (y)', 'Hemisphere'))) stop('Unexpected Supplementary Table 1 structure')
out <- data.frame(Reference = 'Sherwood_etal_2020_SuppTable1',
  source_row = seq_len(nrow(x)) + 1L,
  species_as_published = x[['Species']], sex = x[['Sex']],
  age_years_as_published = x[['Age (y)']], hemisphere_as_published = x[['Hemisphere']],
  check.names = FALSE)
write.csv(out, file.path(folder, 'Sherwood_etal_2020_SuppTable1.csv'), row.names = FALSE, na = '')
