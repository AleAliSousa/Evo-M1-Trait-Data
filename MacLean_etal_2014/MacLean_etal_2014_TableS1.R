# Build analysis CSV for published supplementary Table S1.
# Run extract_supplement_snapshots.py first when the source DOCX files change.
args <- grep('^--file=', commandArgs(FALSE), value = TRUE)
if (length(args) != 1L) stop('Run this saved script with Rscript.')
folder <- dirname(normalizePath(sub('^--file=', '', args[[1L]])))

read_snapshot <- function(number, rows, columns) {
  path <- file.path(folder, sprintf('MacLean_etal_2014_TableS%d_snapshot.csv', number))
  x <- read.csv(path, check.names = FALSE, colClasses = 'character',
                na.strings = NULL, strip.white = FALSE, fileEncoding = 'UTF-8')
  if (nrow(x) != rows || ncol(x) != columns + 1L ||
      !identical(as.integer(x$source_row), seq_len(rows))) {
    stop(sprintf('Unexpected Table S%d snapshot structure', number))
  }
  x
}

numeric_or_missing <- function(x, missing = c('', 'NA', '-')) {
  y <- trimws(x)
  y[y %in% missing] <- NA_character_
  out <- suppressWarnings(as.numeric(y))
  if (any(!is.na(y) & is.na(out))) stop('Unexpected numeric cell: ', paste(unique(y[!is.na(y) & is.na(out)]), collapse = '; '))
  out
}

trim <- function(x) unname(trimws(gsub('\u00a0', ' ', x, fixed = TRUE)))

write_item <- function(number, data, definitions) {
  name <- sprintf('MacLean_etal_2014_TableS%d', number)
  data <- data.frame(Reference = name, data, check.names = FALSE)
  write.csv(data, file.path(folder, paste0(name, '.csv')), row.names = FALSE, na = '')
  definitions <- data.frame(
    output_column = names(data), source_header = definitions$source_header,
    unit = definitions$unit, value_type = definitions$value_type,
    note = definitions$note, check.names = FALSE)
  if (nrow(definitions) != ncol(data)) stop(name, ': definition count mismatch')
  write.csv(definitions, file.path(folder, paste0(name, '_definitions.csv')),
            row.names = FALSE, na = '')
  message(name, ': ', nrow(data), ' analysis rows')
}

defs <- function(headers, units = rep('', length(headers)),
                 types = rep('as published', length(headers)),
                 notes = rep('', length(headers))) {
  data.frame(source_header = headers, unit = units,
             value_type = types, note = notes, stringsAsFactors = FALSE)
}

# Table S1: anatomy and reference numbers. Preserve the printed Latin names.
x <- read_snapshot(1, 37L, 6L)
if (!identical(trim(unlist(x[1, paste0('c', 1:6)])),
               c('Common Name', 'Latin Name', 'Group', 'ECV (cc)', 'Body Mass (g)', 'Source #'))) stop('Table S1 headers changed')
y <- x[-1, ]
s1 <- data.frame(source_row = as.integer(y$source_row),
  common_name_as_published = trim(y$c1), species_as_published = trim(y$c2),
  group_as_published = trim(y$c3), ecv_cc = numeric_or_missing(y$c4),
  body_mass_g = numeric_or_missing(y$c5), source_numbers_as_published = trim(y$c6))
write_item(1, s1, defs(c('item key','source row','Common Name','Latin Name','Group','ECV (cc)','Body Mass (g)','Source #'),
  c('','','','','','cc','g',''),
  c('constant','row locator','text','text','text','numeric','numeric','text'),
  c('','','','','','Endocranial volume as supplied by authors','','Comma-separated printed reference numbers; rodent correction noted in source')))

