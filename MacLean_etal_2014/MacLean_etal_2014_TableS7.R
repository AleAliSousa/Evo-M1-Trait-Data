# Build analysis CSV for published supplementary Table S7.
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

# Table S7: Word merged-cell grid repeats df in c5. Rendered table has one df.
x <- read_snapshot(7, 46L, 8L)
if (!identical(trim(unlist(x[1, paste0('c', 1:8)])),
               c('Explanatory Variable','Dependent Measure','t','df','p','p','r2','λ'))) stop('Table S7 headers changed')
y <- x[-1, ]
if (!all(trim(y$c4) == trim(y$c5))) stop('Table S7 duplicated Word grid cell changed')
s7 <- data.frame(source_row = as.integer(y$source_row),
  explanatory_variable_as_published = trim(y$c1), dependent_measure_as_published = trim(y$c2),
  t_statistic = numeric_or_missing(y$c3), df = numeric_or_missing(y$c4),
  p_as_published = trim(y$c6), r2_as_published = trim(y$c7),
  lambda = numeric_or_missing(y$c8))
write_item(7, s7, defs(c('item key','source row','Explanatory Variable','Dependent Measure','t','df','p','r2','λ'),
  c('','','','','','','','',''),
  c('constant','row locator','text','text','numeric','numeric','text','text','numeric'),
  c('','','','','','Grid c5 is duplicate of df from a merged Word cell','Preserves < 0.01','Preserves < 0.01','')))
