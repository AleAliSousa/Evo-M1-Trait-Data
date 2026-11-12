## Extract the registered supplementary reference item (bibliography, mmc1 PDF section 4); no numeric data.
## Uses the hanging-indent bibliography (entries start at x < 78 pt, continuation lines are indented).
## R (pdftools/poppler) reproduces the frozen CSV byte for byte, so no Python snapshot script is needed.
## Writes only <item_name>_snapshot.csv.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error=function(e) NULL)
  if(!is.null(of) && nzchar(of)) return(normalizePath(of))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run this saved script with Rscript or Source it in RStudio")
})
folder <- dirname(.sp)
item_name <- sub("_snapshot$","",tools::file_path_sans_ext(basename(.sp)))
library(pdftools)
## Text lines of one page from poppler words: words whose y differ by <= 3 pt form a line (as pdfplumber's
## extract_text_lines), joined by a space unless poppler marks no space and the gap is <= 3 pt (superscripts such as "2nd").
## `y` is the poppler word top (about 1.7 pt above the pdfplumber top the original thresholds were set on).
lines_of <- function(p, tol=3) {
  if(!nrow(p)) return(data.frame(top=numeric(), x0=numeric(), text=character(), stringsAsFactors=FALSE))
  p <- p[order(p$y, p$x), ]
  g <- cumsum(c(1, diff(p$y) > tol))
  do.call(rbind, lapply(split(p, g), function(w) {
    w <- w[order(w$x), ]; n <- nrow(w)
    gap <- c(w$x[-1] - (w$x + w$width)[-n], Inf)
    sep <- ifelse(!w$space & gap <= tol, "", " "); sep[n] <- ""
    data.frame(top=min(w$y), x0=min(w$x), text=paste0(w$text, sep, collapse=""), stringsAsFactors=FALSE)
  }))
}
## Freeze as UTF-8 with BOM, LF line ends, a field quoted only if it holds , " CR or LF; never overwrite a differing frozen copy.
csv_field <- function(x) { x <- enc2utf8(as.character(x)); q <- grepl("[\",\r\n]", x)
  x[q] <- paste0("\"", gsub("\"", "\"\"", x[q], fixed=TRUE), "\""); x }
freeze <- function(item_name, rows) {
  txt <- paste0(paste(c(paste(csv_field(names(rows)), collapse=","),
                        do.call(paste, c(unname(lapply(rows, csv_field)), sep=","))), collapse="\n"), "\n")
  p <- file.path(folder, paste0(item_name, "_snapshot.csv"))
  if(file.exists(p)) {
    old <- readBin(p, "raw", file.size(p)); new <- c(as.raw(c(0xef, 0xbb, 0xbf)), charToRaw(txt))
    if(!identical(old, new)) stop("Refusing differing snapshot overwrite: ", p)
    message("Snapshot unchanged: ", p); return(invisible(p))
  }
  con <- file(p, "wb"); on.exit(close(con))
  writeBin(as.raw(c(0xef, 0xbb, 0xbf)), con); writeBin(charToRaw(txt), con)
  invisible(p)
}
pd <- pdf_data(file.path(folder, "1-s2.0-S0047248412000577-mmc1.pdf"))

refs <- list(); active <- FALSE
for(pg in 11:18) {
  L <- lines_of(pd[[pg]])
  for(k in seq_len(nrow(L))) {
    txt <- L$text[k]
    if(txt == "4. References") { active <- TRUE; next }
    if(!active || L$top[k] < 43 || L$top[k] > 790) next
    if(L$x0[k] < 78) {
      refs[[length(refs)+1L]] <- list(source_row=length(refs)+1L, source_pdf_page=as.character(pg), citation_as_printed=txt)
    } else if(length(refs)) {
      r <- refs[[length(refs)]]
      r$citation_as_printed <- paste0(r$citation_as_printed, "\n", txt)
      if(!(as.character(pg) %in% strsplit(r$source_pdf_page, ";", fixed=TRUE)[[1]])) r$source_pdf_page <- paste0(r$source_pdf_page, ";", pg)
      refs[[length(refs)]] <- r
    }
  }
}
rows <- do.call(rbind, lapply(refs, function(r) data.frame(r, stringsAsFactors=FALSE)))
rows[] <- lapply(rows, as.character)
stopifnot(all(grepl("\\(\\d{4}(?:[a-z]|-\\d{4})?\\)", rows$citation_as_printed, perl=TRUE)))
freeze(item_name, rows)
cat(nrow(rows), "bibliography entries\n")
