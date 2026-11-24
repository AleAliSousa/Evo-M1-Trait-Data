## Freeze the publisher's Appendix 2 / Table A2 from its legacy Word supplement.
## Run once from any directory: Rscript --vanilla Lindenfors__2002_TableA2_snapshot.R
a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=', '', a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('_snapshot[.]R$', '.R', sub('^--file=', '', a[1]))))
source_file <- file.path(folder, 'jeb_422_sm.doc')
snapshot <- file.path(folder, paste0(item_name, '_snapshot.csv'))
if (file.exists(snapshot)) stop('Frozen snapshot already exists; refusing to overwrite it')
if (!file.exists(source_file)) stop('Publisher supplement is missing')
if (!nzchar(Sys.which('antiword'))) stop('antiword is required for legacy Word table extraction')

xml_file <- tempfile(fileext='.xml')
error_file <- tempfile()
status <- system2('antiword', c('-x', 'db', shQuote(source_file)),
                  stdout=xml_file, stderr=error_file)
if (status != 0L) stop(paste(readLines(error_file, warn=FALSE), collapse='\n'))
doc <- xml2::read_xml(xml_file, options=c('RECOVER', 'NONET'))
entries <- xml2::xml_text(xml2::xml_find_all(doc, '//entry'))
table_entry <- entries[grepl('Lemur catta', entries, fixed=TRUE)]
if (length(table_entry) != 1L) stop('Could not identify the Table A2 data entry')
blocks <- strsplit(table_entry, '\n\n', fixed=TRUE)[[1]]
if (length(blocks) != 206L || !grepl('Species', blocks[1], fixed=TRUE) ||
    !grepl('^Data sources:', blocks[205])) stop('Unexpected Table A2 structure')

headers <- c('Species', 'Mating system', 'Male weight (kg)',
  'Female weight (kg)', 'Group size', 'Female sexual maturity (months)',
  'Female first birth (years)', 'Gestation length (days)',
  'Number of offspring per litter', 'Interbirth interval (years)',
  'Birth rate (offspring/(year)', 'Maximum recorded lifespan (years)',
  'Neonate weight (g)', 'Male neonate weight (g)',
  'Female neonate weight (g)', 'Age at weaning (days)',
  'Weight at weaning (kg)', 'Foetal growth rate', 'Postnatal growth rate')
rows <- lapply(blocks[2:204], function(block) {
  cells <- strsplit(block, '\n', fixed=TRUE)[[1]]
  if (!length(cells) %in% c(1L, 19L)) stop('Unexpected number of cells in species row')
  if (length(cells) == 1L) cells <- c(cells, rep('', 18L))
  cells <- gsub('\u00a0', '', cells, fixed=TRUE)
  cells <- trimws(cells)
  cells
})
if (sum(lengths(strsplit(blocks[2:204], '\n', fixed=TRUE)) == 1L) != 9L)
  stop('Unexpected count of name-only species rows')
species <- vapply(rows, `[`, character(1), 1L)
if (any(!nzchar(species)) || anyDuplicated(species)) stop('Invalid species labels')
caption <- c('Table A2', rep('', 18L))
source_note <- c(gsub('\u00a0', ' ', blocks[205], fixed=TRUE), rep('', 18L))
snapshot_rows <- rbind(caption, headers, do.call(rbind, rows), source_note)
utils::write.table(snapshot_rows, snapshot, sep=',', quote=TRUE,
                   row.names=FALSE, col.names=FALSE, na='', fileEncoding='UTF-8')
cat(item_name, ': froze ', length(species), ' species rows (',
    sum(vapply(rows, function(x) any(nzchar(x[-1])), logical(1))),
    ' with a reported trait)\n', sep='')
