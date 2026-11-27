args <- grep('^--file=', commandArgs(FALSE), value=TRUE)
stopifnot(length(args) == 1L)
folder <- dirname(normalizePath(sub('^--file=', '', args[1])))
root <- dirname(folder)
item <- 'Terborgh__1983_Chapter7Tables'
s <- read.csv(file.path(folder, paste0(item, '_snapshot.csv')),
              stringsAsFactors=FALSE, check.names=FALSE, colClasses='character')
stopifnot(nrow(s) == 150L,
          identical(as.integer(s$source_order), seq_len(150L)),
          identical(names(table(s$table_number)), paste0('7.', 1:5)),
          identical(as.integer(table(s$table_number)), c(35L, 50L, 17L, 16L, 32L)))
# Only plain printed numbers are parsed; inequalities, parentheses, and
# unresolved footnote glyphs remain in the source string and have NA here.
plain_number <- function(x) {
  ok <- grepl('^[0-9]+(\\.[0-9]+)?$', x)
  out <- rep(NA_real_, length(x))
  out[ok] <- as.numeric(x[ok])
  out
}
out <- data.frame(source_order=as.integer(s$source_order),
                  table_number=s$table_number,
                  source_print_page=as.integer(s$source_print_page),
                  Species=s$species_as_printed,
                  sample_as_printed=s$sample_as_printed,
                  measure_as_printed=s$measure_as_printed,
                  unit_as_printed=s$unit_as_printed,
                  value_as_printed=s$value_as_printed,
                  value_numeric=plain_number(s$value_as_printed),
                  source_role=s$source_role,
                  source_note=s$source_note,
                  stringsAsFactors=FALSE)
write.csv(out, file.path(folder, paste0(item, '.csv')),
          row.names=FALSE, na='', fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root, '__ReadMe.xlsx'), sheet='Sheet1')
hit <- which(!is.na(reg[['Item name']]) & reg[['Item name']] == item)
stopifnot(length(hit) == 1L)
code <- reg[['Item encoded']][hit]
write.table(out, file.path(root, '__Public', 'comparative-data', paste0(code, '.tsv')),
            sep='\t', row.names=FALSE, na='', fileEncoding='UTF-8')
cat(item, ':', nrow(out), 'source measurements ->', code, '\n')
