## Table 4 reader: scientific values come only from the frozen item snapshot.
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
                 header = FALSE, check.names = FALSE, colClasses = 'character',
                 na.strings = '', fileEncoding = 'UTF-8')
stopifnot(nrow(snap) == 8L, ncol(snap) == 5L,
          snap[1, 1] == 'Table 4', snap[2, 1] == 'Species', snap[8, 1] == 'a')
d <- snap[3:7, , drop = FALSE]
parse_pm <- function(x) {
  parts <- strsplit(x, ' ± ', fixed = TRUE)
  stopifnot(all(lengths(parts) == 2L))
  out <- matrix(as.numeric(unlist(parts)), ncol = 2L, byrow = TRUE)
  stopifnot(!anyNA(out))
  out
}
patches <- parse_pm(d[[2]])
diameters <- parse_pm(d[[3]])
key <- utils::read.csv(file.path(base, '_keys', 'General', 'species_key.csv'),
                stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
key <- key[key$source_publication == sub('_Table4$', '', item_name), ]
idx <- match(d[[1]], key$variant_name)
stopifnot(!anyNA(idx), !anyDuplicated(key$variant_name), nrow(d) == 5L)
final.dataframe <- data.frame(
  source_row = seq_len(nrow(d)), species_as_published = d[[1]],
  Species = key$accepted_name[idx],
  patch_count_per_hemisphere = patches[, 1],
  patch_count_plusminus_as_published = patches[, 2],
  patch_count_printed = d[[2]],
  patch_diameter_um = diameters[, 1],
  patch_diameter_plusminus_um_as_published = diameters[, 2],
  patch_diameter_printed = d[[3]],
  linear_patch_density_per_mm = as.numeric(d[[4]]),
  patch_density_per_mm2 = as.numeric(d[[5]]),
  plusminus_type = 'not specified in Table 4',
  observation_level = 'species summary', source_locator = 'Table 4',
  data_role = 'primary', stringsAsFactors = FALSE)
stopifnot(!anyNA(final.dataframe$linear_patch_density_per_mm),
          !anyNA(final.dataframe$patch_density_per_mm2))
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
    '; species summaries:', nrow(final.dataframe), '\n')
