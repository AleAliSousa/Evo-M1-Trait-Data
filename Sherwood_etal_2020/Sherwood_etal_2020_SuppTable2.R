# Rebuild the 25 species means from the frozen publisher spreadsheet.
script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file)) {
  args <- commandArgs(trailingOnly = FALSE)
  script_file <- sub('^--file=', '', args[grepl('^--file=', args)][1])
}
if (is.na(script_file) || !nzchar(script_file)) stop('Run this saved script with Rscript or source it.')
folder <- dirname(normalizePath(script_file))
if (!requireNamespace('readxl', quietly = TRUE)) stop('readxl is required')
x <- readxl::read_excel(file.path(folder, 'Sherwood_etal_2020_SuppTable2_snapshot.xlsx'), range = 'A1:N26')
if (nrow(x) != 25L || ncol(x) != 14L || !identical(names(x)[1:2], c('Species', 'Brain Mass'))) stop('Unexpected Supplementary Table 2 structure')
if (anyNA(x)) stop('Missing value in published data matrix')
names(x) <- c('species_as_published', 'brain_mass_g',
  'synapse_density_V1_II_III_per_mm3', 'synapse_density_V1_V_VI_per_mm3',
  'synapse_density_IT_II_III_per_mm3', 'synapse_density_IT_V_VI_per_mm3',
  'neuron_density_V1_II_III_per_mm3', 'neuron_density_V1_V_VI_per_mm3',
  'neuron_density_IT_II_III_per_mm3', 'neuron_density_IT_V_VI_per_mm3',
  'synapses_per_neuron_V1_II_III', 'synapses_per_neuron_V1_V_VI',
  'synapses_per_neuron_IT_II_III', 'synapses_per_neuron_IT_V_VI')
for (k in 1:4) {
  if (!isTRUE(all.equal(x[[10+k]], x[[2+k]]/x[[6+k]], tolerance = 1e-10)))
    stop('Published synapse-per-neuron ratio does not match densities')
}
out <- data.frame(Reference = 'Sherwood_etal_2020_SuppTable2', source_row = 2:26, x, check.names = FALSE)
write.csv(out, file.path(folder, 'Sherwood_etal_2020_SuppTable2.csv'), row.names = FALSE, na = '')

name <- 'Sherwood_etal_2020_SuppTable2'
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
