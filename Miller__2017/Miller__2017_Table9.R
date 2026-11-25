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
stopifnot(nrow(snap) == 27L, !anyDuplicated(snap$Case))
lesion_percent <- rep(NA_real_, nrow(snap))
has_percent <- grepl('%$', snap$Degree)
lesion_percent[has_percent] <- as.numeric(sub('%$', '', snap$Degree[has_percent]))
recovery_days <- suppressWarnings(as.numeric(snap$Recovery))
final.dataframe <- data.frame(
 source_row = seq_len(nrow(snap)), genus_as_published = snap$Genus,
 case_id = snap$Case, stain_as_published = snap$Stain, side_as_published = snap$Side,
 degree_as_published = snap$Degree, lesion_percent_as_published = lesion_percent,
 recovery_as_published = snap$Recovery, recovery_days = recovery_days,
 control = snap$Degree == 'N/A', observation_level = 'individual specimen',
 data_role = 'primary', stringsAsFactors = FALSE)
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
