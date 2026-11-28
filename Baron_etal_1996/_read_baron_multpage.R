# Convert a printed multi-page Baron table grid into the historical analysis
# columns. Source-page markers, caption, repeated headers, and notes stay in
# the snapshot; page/heading metadata are inferred here.
read_baron_multpage <- function(path, item, codes, first_page) {
  g <- utils::read.csv(path, header=FALSE, check.names=FALSE,
                       stringsAsFactors=FALSE, colClasses="character",
                       na.strings=character(0), blank.lines.skip=FALSE)
  stopifnot(ncol(g)==length(codes)+1L)
  number <- sub("^Table", "", item)
  page <- first_page - 1L
  rows <- list()
  for (i in seq_len(nrow(g))) {
    label <- g[[1]][i]
    if (startsWith(label, paste0("Table ", number, ".")) ||
        identical(label, paste0("> Table ", number, " <"))) {
      page <- page + 1L
      next
    }
    if (page < first_page || !nzchar(label)) next
    values <- unlist(g[i, -1L], use.names=FALSE)
    has_values <- any(nzchar(values))
    heading <- grepl("^[[:space:]]*[A-Z][A-Z ]+(?: \\((?:cont|cant)\\.\\))?$", label, perl=TRUE)
    if (!has_values && !heading) next
    if (has_values && !all(is.na(suppressWarnings(as.numeric(values[nzchar(values)]))))) {
      rows[[length(rows)+1L]] <- c(label, NA_character_, page, values)
    } else if (heading && !has_values) {
      rows[[length(rows)+1L]] <- c(label, "TRUE", page, values)
    }
  }
  stopifnot(length(rows)>0L)
  out <- as.data.frame(do.call(rbind, rows), stringsAsFactors=FALSE)
  names(out) <- c("species_printed", "is_header", "source_pdf_page", codes)
  out$source_pdf_page <- as.integer(out$source_pdf_page)
  out$is_header <- as.logical(out$is_header)
  for (code in codes) out[[code]] <- suppressWarnings(as.numeric(ifelse(out[[code]]=="", NA_character_, out[[code]])))
  out$species_row <- seq_len(nrow(out))
  out
}
