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

name <- 'Sherwood_etal_2020_SuppTable1'
data <- out

# Public TSV. `Item encoded` is looked up in __ReadMe.xlsx BY ITEM NAME -- the registry is the
# authority for the filename. Warns rather than guessing if the lookup fails.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, '__ReadMe.xlsx'))) root <- dirname(root)
if (file.exists(file.path(root, '__ReadMe.xlsx')) && requireNamespace('readxl', quietly = TRUE)) {
  registry <- readxl::read_excel(file.path(root, '__ReadMe.xlsx'), sheet = 'Sheet1')
  item_encoded <- registry[['Item encoded']][match(name, registry[['Item name']])]
  if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
      !grepl('_$', item_encoded)) {
    tsv_dir <- file.path(root, '__Public', 'comparative-data')
    dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
    write.table(data, file.path(tsv_dir, paste0(item_encoded, '.tsv')), sep = '\t',
                row.names = FALSE, quote = TRUE, na = '', fileEncoding = 'UTF-8')
    message(name, ': public TSV ', item_encoded, '.tsv')
  } else {
    warning(name, ": no usable 'Item encoded' for this Item name in __ReadMe.xlsx; ",
            'rerun _tools/file_list.R (or reopen the workbook so the formula recalculates), ',
            'then rerun this script. Public TSV not written.')
  }
}
