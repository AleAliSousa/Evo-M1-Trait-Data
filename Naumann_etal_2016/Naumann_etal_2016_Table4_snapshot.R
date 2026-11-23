# Freeze Table 4 from the open Europe PMC full-text XML. This script writes only
# the source-facing snapshot; the item reader is separate.
args <- grep('^--file=', commandArgs(FALSE), value = TRUE)
if (!length(args)) stop('Run this script with Rscript.')
folder <- dirname(normalizePath(sub('^--file=', '', args[1])))
item_name <- tools::file_path_sans_ext(basename(sub('_snapshot[.]R$', '.R', args[1])))
source_file <- file.path(folder, 'Naumann_etal_2016_fullText.xml')
doc <- xml2::read_xml(source_file)
table <- xml2::xml_find_first(doc, "//table-wrap[@id='cne23865-tbl-0004']")
if (inherits(table, 'xml_missing')) stop('Table 4 not found in frozen XML.')
txt <- function(node) trimws(gsub('[[:space:]]+', ' ', xml2::xml_text(node)))
heads <- vapply(xml2::xml_find_all(table, './table/thead/tr/th'), txt, character(1))
body <- lapply(xml2::xml_find_all(table, './table/tbody/tr'), function(r)
  vapply(xml2::xml_find_all(r, './td'), txt, character(1)))
stopifnot(length(heads) == 5L, length(body) == 5L,
          all(lengths(body) == 5L), heads[1] == 'Species')
caption_node <- xml2::xml_find_first(table, './caption/p')
marker <- txt(xml2::xml_find_first(caption_node, './xref'))
xml2::xml_remove(xml2::xml_find_first(caption_node, './xref'))
caption <- paste0(txt(caption_node), ' [', marker, ']')
note <- txt(xml2::xml_find_first(table, './table-wrap-foot/fn/p'))
snap <- rbind(c('Table 4', caption, rep('', 3)), heads,
              do.call(rbind, body), c('a', note, rep('', 3)))
out <- file.path(folder, paste0(item_name, '_snapshot.csv'))
tmp <- tempfile(tmpdir = folder, fileext = '.csv')
write.table(snap, tmp, sep = ',', quote = TRUE, row.names = FALSE,
            col.names = FALSE, na = '', fileEncoding = 'UTF-8')
if (file.exists(out) && !identical(readBin(out, 'raw', file.info(out)$size),
                                   readBin(tmp, 'raw', file.info(tmp)$size))) {
  unlink(tmp)
  stop('Frozen snapshot differs; inspect source and existing snapshot before replacing it.')
}
if (!file.exists(out)) invisible(file.copy(tmp, out))
unlink(tmp)
cat('Snapshot:', out, '; source rows:', length(body), '\n')
