# Weigl__2005_Records.R — provisional OCR snapshot -> public comparison item.
# The frozen snapshot is an OCR capture, NOT a visually complete transcription.
# Keep every source row and review field; no species aggregation or merge wiring.
.sp <- local({
  a <- grep('^--file=', commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub('^--file=', '', a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  in_repo <- file.path(getwd(), 'Weigl_2005', 'Weigl__2005_Records.R')
  if (file.exists(in_repo)) return(normalizePath(in_repo))
  stop('Run with Rscript or sys.source.', call. = FALSE)
})
item_dir <- dirname(.sp)
root <- dirname(item_dir)
folder <- basename(item_dir)
base <- sub('\\.R$', '', basename(.sp))
item_name <- base
stopifnot(item_name == 'Weigl__2005_Records')

registry <- readxl::read_excel(file.path(root, '__ReadMe.xlsx'), sheet = 'Sheet1')
registry_row <- registry[which(registry[['Item name']] == item_name), , drop = FALSE]
stopifnot(nrow(registry_row) == 1L)
item_encoded <- registry_row[['Item encoded']][[1L]]
stopifnot(is.character(item_encoded), nzchar(item_encoded), !grepl('_$', item_encoded))

frozen <- file.path(item_dir, paste0(item_name, '_snapshot.csv'))
final.dataframe <- read.csv(frozen, colClasses = 'character', check.names = FALSE,
                            stringsAsFactors = FALSE, fileEncoding = 'UTF-8')
stopifnot(nrow(final.dataframe) == 4532L,
          !anyDuplicated(final.dataframe$source_id),
          all(c('taxon_printed_ocr', 'taxon_printed_verified',
                'age_years_verified', 'age_months_verified',
                'review_status') %in% names(final.dataframe)))

# Keep the printed-name candidate separate from verified transcription.
# These values are source labels, not harmonised species keys.
final.dataframe$Species_Weigl2005 <- ifelse(
  nzchar(final.dataframe$taxon_printed_verified),
  final.dataframe$taxon_printed_verified,
  final.dataframe$taxon_printed_ocr
)
final.dataframe$taxon_review_level <- ifelse(
  nzchar(final.dataframe$taxon_printed_verified),
  'image_checked', 'OCR_draft'
)
final.dataframe$age_review_level <- ifelse(
  nzchar(final.dataframe$age_visual_check),
  'image_checked', 'OCR_draft'
)

csv_file <- file.path(item_dir, paste0(item_name, '.csv'))
tsv_file <- file.path(root, '__Public', 'comparative-data', paste0(item_encoded, '.tsv'))
write.csv(final.dataframe, csv_file, row.names = FALSE, na = '', fileEncoding = 'UTF-8')
write.table(final.dataframe, tsv_file, sep = '\t', row.names = FALSE,
            quote = TRUE, na = '', fileEncoding = 'UTF-8')
cat('Built ', nrow(final.dataframe), ' draft records: ', csv_file, ' and ', tsv_file, '\n', sep = '')
