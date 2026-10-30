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
