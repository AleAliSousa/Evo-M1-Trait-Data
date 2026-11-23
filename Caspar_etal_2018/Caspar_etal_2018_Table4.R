## Table 4 reader: retain separate individual-by-task observations.
.sp <- local({
  for (i in rev(seq_len(sys.nframe()))) {
    p <- sys.frame(i)$ofile
    if (!is.null(p) && grepl('Table4[.]R$', p)) return(normalizePath(p))
    p <- sys.frame(i)$build_script
    if (!is.null(p) && grepl('Table4[.]R$', p)) return(normalizePath(p))
  }
  args <- grep('^--file=', commandArgs(FALSE), value = TRUE)
  if (length(args)) return(normalizePath(sub('^--file=', '', args[1])))
  stop('Run with Rscript or source the saved item script.')
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, '_snapshot.csv')),
                 header = FALSE, fill = TRUE, check.names = FALSE,
                 colClasses = 'character', na.strings = '', fileEncoding = 'UTF-8')
stopifnot(ncol(snap) == 8L, snap[1, 1] == 'Table 4')
heads <- which(snap[[1]] == 'Subject')
stopifnot(identical(heads, c(2L, 21L)), snap[2, 3] == 'HI_TT',
          snap[21, 3] == 'I_OCT', snap[nrow(snap), 1] == 'Notes.')
tube <- snap[3:20, , drop = FALSE]
oct <- snap[22:(nrow(snap) - 1L), , drop = FALSE]
stopifnot(nrow(tube) == 18L, nrow(oct) == 11L)
key <- utils::read.csv(file.path(base, '_keys', 'General', 'species_key.csv'),
                stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
key <- key[key$source_publication == sub('_Table4$', '', item_name), ]
get_species <- function(x) {
  idx <- match(x, key$variant_name)
  stopifnot(!anyNA(idx), !anyDuplicated(key$variant_name))
  key$accepted_name[idx]
}
to_num <- function(x) as.numeric(chartr('−', '-', x))
to_p <- function(x) {
  y <- chartr('⁰¹²³⁴⁵⁶⁷⁸⁹⁻', '0123456789-', x)
  y <- sub(' × 10', 'e', y, fixed = TRUE)
  as.numeric(y)
}
tube_out <- data.frame(
  source_row = seq_len(nrow(tube)), task = 'tube task',
  index_as_published = 'HI_TT', subject_as_published = tube[[1]],
  species_as_published = tube[[2]], Species = get_species(tube[[2]]),
  handedness_index = to_num(tube[[3]]),
  bouts = as.integer(tube[[4]]), insertions = as.integer(tube[[5]]),
  z_score = to_num(tube[[6]]), p_as_published = tube[[7]],
  p_value = to_p(tube[[7]]), hand_preference_as_published = tube[[8]],
  observation_level = 'individual-task', source_locator = 'Table 4',
  data_role = 'primary', stringsAsFactors = FALSE)
oct_out <- data.frame(
  source_row = seq_len(nrow(oct)) + nrow(tube), task = 'object-choice task',
  index_as_published = 'I_OCT', subject_as_published = oct[[1]],
  species_as_published = oct[[2]], Species = get_species(oct[[2]]),
  handedness_index = to_num(oct[[3]]),
  bouts = NA_integer_, insertions = NA_integer_,
  z_score = to_num(oct[[4]]), p_as_published = oct[[5]],
  p_value = to_p(oct[[5]]), hand_preference_as_published = oct[[6]],
  observation_level = 'individual-task', source_locator = 'Table 4',
  data_role = 'primary', stringsAsFactors = FALSE)
final.dataframe <- rbind(tube_out, oct_out)
stopifnot(nrow(final.dataframe) == 29L,
          all(abs(final.dataframe$handedness_index) <= 1),
          !anyNA(final.dataframe$handedness_index),
          !anyNA(final.dataframe$z_score), !anyNA(final.dataframe$p_value),
          all(final.dataframe$p_value >= 0 & final.dataframe$p_value <= 1),
          !anyDuplicated(final.dataframe[c('task', 'subject_as_published')]))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, '.csv')),
          row.names = FALSE, na = '', fileEncoding = 'UTF-8')
filecodes <- readxl::read_excel(file.path(base, '__ReadMe.xlsx'), sheet = 'Sheet1')
registry_source <- '__ReadMe.xlsx'
if (!item_name %in% filecodes[['Item name']]) {
  filecodes <- readxl::read_excel(file.path(base, '__ReadMeAddON.xlsx'), sheet = 'Sheet1')
  registry_source <- '__ReadMeAddON.xlsx'
}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']] == item_name)
stopifnot(length(rr) == 1L)
item_encoded <- filecodes[['Item encoded']][rr]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl('_$', item_encoded))
tsv_dir <- file.path(base, '__Public', 'comparative-data')
stopifnot(dir.exists(tsv_dir))
utils::write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, '.tsv')),
            sep = '\t', row.names = FALSE, na = '', fileEncoding = 'UTF-8')
cat('Registry:', registry_source, '; item:', item_name,
    '; tube:', nrow(tube_out), '; OCT:', nrow(oct_out), '\n')
