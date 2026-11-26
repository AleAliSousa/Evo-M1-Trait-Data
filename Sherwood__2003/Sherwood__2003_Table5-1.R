# Sherwood 2003 dissertation Table 5-1: specimen identities and preparation.
# Read only the frozen source transcription. No journal measurements are copied.
arg <- grep('^--file=', commandArgs(FALSE), value = TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
script <- normalizePath(sub('^--file=', '', arg))
folder <- dirname(script)
root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(script))
snap <- read.csv(file.path(folder, paste0(item, '_snapshot.csv')),
                 check.names = FALSE, colClasses = 'character',
                 na.strings = NULL, stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 12L,
          identical(names(snap), c('Species', 'ID', 'Sex', 'Age at Death',
                                   'Fixation', 'Postmortem Interval')),
          !anyDuplicated(paste(snap$Species, snap$ID)),
          all(snap$Sex %in% c('F', 'M')))
age <- suppressWarnings(as.numeric(snap[['Age at Death']]))
age_lt <- ifelse(grepl('^<[0-9]+$', snap[['Age at Death']]),
                 as.numeric(sub('^<', '', snap[['Age at Death']])), NA_real_)
stopifnot(all(!is.na(age) | !is.na(age_lt)),
          all(!is.na(age) != !is.na(age_lt)))
out <- data.frame(
  source_row = seq_len(nrow(snap)),
  taxon_as_published = snap$Species,
  specimen_id_as_published = snap$ID,
  sex_as_published = snap$Sex,
  age_at_death_as_published = snap[['Age at Death']],
  age_at_death_years = age,
  age_less_than_years = age_lt,
  fixation_as_published = snap$Fixation,
  postmortem_interval_as_published = snap[['Postmortem Interval']],
  observation_level = 'individual specimen',
  data_role = 'primary',
  source = item, check.names = FALSE)
write.csv(out, file.path(folder, paste0(item, '.csv')),
          row.names = FALSE, na = '', fileEncoding = 'UTF-8')
registry_paths <- file.path(root, c('__ReadMe.xlsx', '__ReadMeAddON.xlsx'))
matches <- lapply(registry_paths, function(path) {
  tab <- readxl::read_excel(path, sheet = 'Sheet1')
  tab[tab[['Item name']] == item, , drop = FALSE]
})
matches <- matches[vapply(matches, nrow, integer(1)) == 1L]
if (length(matches) != 1L) stop('Expected exactly one master/AddON registry row')
encoded <- as.character(matches[[1]][['Item encoded']][1])
if (is.na(encoded) || !nzchar(encoded) || endsWith(encoded, '_'))
  stop('Invalid Item encoded')
write.table(out, file.path(root, '__Public', 'comparative-data',
                           paste0(encoded, '.tsv')),
            sep = '\t', row.names = FALSE, na = '', fileEncoding = 'UTF-8')
cat(item, ': ', nrow(out), ' specimen rows\n', sep = '')
