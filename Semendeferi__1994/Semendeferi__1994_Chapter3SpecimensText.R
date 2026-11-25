# Individual specimen dataset item; values come only from this item's frozen snapshot.
script_arg <- grep('^--file=', commandArgs(FALSE), value = TRUE)
if (length(script_arg) != 1L) stop('Run with Rscript')
script_path <- normalizePath(sub('^--file=', '', script_arg))
folder <- dirname(script_path)
item_name <- tools::file_path_sans_ext(basename(script_path))
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, '_snapshot.csv')),
                        check.names = FALSE, colClasses = 'character',
                        na.strings = NULL, stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 10L, !anyDuplicated(snap[['Specimen identifier']]))
num <- function(x) suppressWarnings(as.numeric(sub('^([0-9]+(?:\\.[0-9]+)?).*', '\\1', x, perl = TRUE)))
age <- num(snap$Age)
months <- grepl('months', snap$Age)
age[months] <- age[months] + num(sub('^[0-9]+ years, ', '', snap$Age[months])) / 12
mass <- num(snap[['Body weight']])
mass[grepl(' kg$', snap[['Body weight']])] <- mass[grepl(' kg$', snap[['Body weight']])] * 1000
mass[grepl(' lbs$', snap[['Body weight']])] <- round(mass[grepl(' lbs$', snap[['Body weight']])] * 453.59237)
final.dataframe <- data.frame(
 source_row = seq_len(nrow(snap)), species_as_published = snap$Species,
 specimen_id = snap[['Specimen identifier']], specimen_name = snap$Name,
 sex_as_published = snap$Sex, age_as_published = snap$Age, age_years = age,
 body_weight_as_published = snap[['Body weight']], body_mass_g = mass,
 brain_weight_as_published = snap[['Brain weight as published']],
 brain_mass_g = num(snap[['Brain weight as published']]),
 brain_weight_basis = ifelse(grepl('fresh', snap[['Brain weight as published']]), 'fresh',
                             ifelse(grepl('^[0-9]', snap[['Brain weight as published']]), 'unspecified', 'unknown')),
 fixed_brain_mass_g = num(snap[['Fixed brain weight']]),
 fixed_left_hemisphere_mass_g = num(snap[['Fixed left hemisphere weight']]),
 method_role_as_published = snap[['Method role']], source_printed_page = snap[['Source page']],
 observation_level = 'individual postmortem specimen', data_role = 'primary', stringsAsFactors = FALSE)
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
