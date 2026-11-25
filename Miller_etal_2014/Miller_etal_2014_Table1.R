# Miller et al. 2014 Table 1. One chimpanzee, multiple methods and hemispheres.
# Read only the frozen five-column transcription of the published table.
script_arg <- grep('^--file=', commandArgs(FALSE), value = TRUE)
if (length(script_arg) != 1L) stop('Run with Rscript')
script_path <- normalizePath(sub('^--file=', '', script_arg))
folder <- dirname(script_path)
item_name <- tools::file_path_sans_ext(basename(script_path))
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, '_snapshot.csv')),
                        check.names = FALSE, colClasses = 'character',
                        na.strings = NULL, stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 18L,
          identical(names(snap), c('Tissue', 'Quantification', 'Parameter', 'Sample', 'Estimate')),
          all(snap$Tissue %in% c('Flat', 'Slice')),
          all(snap$Parameter %in% c('All cells', 'Neurons', 'Percent neurons',
                                    'Volume (mm³)', 'Cell density', 'Neuron density')))
number <- function(x) as.numeric(gsub('[,%]', '', x))
estimate <- number(snap$Estimate)
parameter <- snap$Parameter
metric <- function(label) ifelse(parameter == label, estimate, NA_real_)
final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  species_as_published = 'Pan troglodytes',
  canonical_specimen = 'KAAS-PAN-11_38',
  tissue_as_published = snap$Tissue,
  hemisphere_from_methods = ifelse(snap$Tissue == 'Flat', 'right', 'left'),
  quantification_as_published = snap$Quantification,
  parameter_as_published = parameter,
  sample_as_published = snap$Sample,
  sample_n = as.integer(sub('^n = ', '', snap$Sample)),
  estimate_as_published = snap$Estimate,
  n_cells = metric('All cells'),
  n_neurons = metric('Neurons'),
  percent_neurons = metric('Percent neurons'),
  volume_mm3 = metric('Volume (mm³)'),
  cell_density_per_mm3 = metric('Cell density'),
  neuron_density_per_mm3 = metric('Neuron density'),
  observation_level = 'one biological specimen; method-specific estimate',
  data_role = 'primary',
  source = item_name,
  stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(all(rowSums(!is.na(final.dataframe[c('n_cells','n_neurons','percent_neurons',
                                             'volume_mm3','cell_density_per_mm3',
                                             'neuron_density_per_mm3')])) == 1L))
options(scipen = 999)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, '.csv')),
                 row.names = FALSE, na = '', fileEncoding = 'UTF-8')
registry_paths <- file.path(root, c('__ReadMe.xlsx', '__ReadMeAddON.xlsx'))
matches <- lapply(registry_paths, function(path) {
  tab <- readxl::read_excel(path, sheet = 'Sheet1')
  tab[tab[['Item name']] == item_name, , drop = FALSE]
})
matches <- matches[vapply(matches, nrow, integer(1)) == 1L]
if (length(matches) != 1L) stop('Expected exactly one master/AddON registry row')
item_encoded <- as.character(matches[[1]][['Item encoded']][1])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, '_'))
  stop('Invalid Item encoded')
utils::write.table(final.dataframe,
  file.path(root, '__Public', 'comparative-data', paste0(item_encoded, '.tsv')),
  sep = '\t', row.names = FALSE, na = '', fileEncoding = 'UTF-8')
cat(item_name, ': ', nrow(final.dataframe), ' rows\n', sep = '')
