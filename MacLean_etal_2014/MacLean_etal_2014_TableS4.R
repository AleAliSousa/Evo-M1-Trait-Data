# Build analysis CSV for published supplementary Table S4.
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

# Table S4: all 567 named subjects. Keep free-text ages and both task markers.
x <- read_snapshot(4, 568L, 7L)
if (!identical(trim(unlist(x[1, paste0('c', 1:7)])),
               c('Species','Population','Subject','Sex','Age','Cylinder','A not B'))) stop('Table S4 headers changed')
y <- x[-1, ]
if (!all(trim(y$c6) %in% c('*','-')) || !all(trim(y$c7) %in% c('*','-'))) stop('Unexpected Table S4 participation mark')
s4 <- data.frame(source_row = as.integer(y$source_row),
  species_common_name_as_published = trim(y$c1), population_as_published = trim(y$c2),
  subject_as_published = trim(y$c3), sex_as_published = trim(y$c4),
  age_as_published = trim(y$c5), cylinder_marker = trim(y$c6),
  a_not_b_marker = trim(y$c7), cylinder_participated = trim(y$c6) == '*',
  a_not_b_participated = trim(y$c7) == '*')
if (anyDuplicated(s4[c('species_common_name_as_published','population_as_published','subject_as_published')])) stop('Unexpected Table S4 subject key duplication')
write_item(4, s4, defs(c('item key','source row','Species','Population','Subject','Sex','Age','Cylinder','A not B','Cylinder','A not B'),
  types = c('constant','row locator',rep('text',7),'boolean','boolean'),
  notes = c('','','Common name, not binomial','','','F/M/unknown as printed','Age may be text or task-specific age (a)/(b)','Asterisk = participated','Asterisk = participated','Derived from asterisk','Derived from asterisk')))

