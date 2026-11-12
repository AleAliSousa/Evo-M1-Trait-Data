## Extract the registered supplementary reference item (source-scope blocks, mmc1 PDF section 1.3); no numeric data.
## Reads the two-column single-species list column by column. Species numbers are data-row identifiers, not citations.
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

## First preserve the printed taxon/group-level scope blocks (pages 3-4, below the running header, above the species list).
lines <- list()
for(pg in 3:4) {
  L <- lines_of(pd[[pg]])
  for(k in seq_len(nrow(L))) {
    if(L$top[k] < 43) next
    if(pg == 4 && L$top[k] >= 287) break
    lines[[length(lines)+1L]] <- list(page=pg, text=L$text[k])
  }
}
scopes <- c("Mammals in general, various species:"="all_mammals", Rodentia="Rodentia", Carnivora="Carnivora", Primates="Primates")
prefix_scopes <- c(Canidae="Canidae", Mustelidae="Mustelidae", Cercopithecines="Cercopithecinae", Colobines="Colobinae",
                   Tarsiers="Tarsiidae", Platyrrhines="Platyrrhini", Lemurs="Lemuriformes", Lagomorpha="Lagomorpha")
prefix_scopes[["\u2018Insectivora\u2019"]] <- "Insectivora"
blocks <- list()
for(ln in lines) {
  txt <- ln$text
  hit <- names(prefix_scopes)[startsWith(txt, paste0(names(prefix_scopes), ":"))]
  if(txt %in% names(scopes)) {
    blocks[[length(blocks)+1L]] <- list(source_row=length(blocks)+1L, source_pdf_page=ln$page, scope_as_printed=txt,
      scope_key=scopes[[txt]], species_numbers_as_printed="", references_as_printed="")
  } else if(length(hit)) {
    blocks[[length(blocks)+1L]] <- list(source_row=length(blocks)+1L, source_pdf_page=ln$page, scope_as_printed=hit[1],
      scope_key=prefix_scopes[[hit[1]]], species_numbers_as_printed="", references_as_printed=trimws(substring(txt, nchar(hit[1])+2L)))
  } else if(length(blocks)) {
    b <- blocks[[length(blocks)]]
    b$references_as_printed <- paste0(b$references_as_printed, if(nzchar(b$references_as_printed)) "\n" else "", txt)
    blocks[[length(blocks)]] <- b
  }
}
## Then the explicitly numbered species citations, left column then right (page 4, below the group blocks).
p4 <- pd[[4]]
for(rng in list(c(65, 330), c(330, 575))) {
  w <- p4[p4$y > 296 & p4$y < 765 & p4$x >= rng[1] & p4$x + p4$width <= rng[2], ]
  pending <- ""
  for(txt in lines_of(w)$text) {
    pending <- paste0(pending, if(nzchar(pending)) "\n" else "", txt)
    m <- regmatches(pending, regexec("(?s)^(.+?)\\s*\\(([\\d, ]+)\\)$", pending, perl=TRUE))[[1]]
    if(length(m) == 3L) {
      blocks[[length(blocks)+1L]] <- list(source_row=length(blocks)+1L, source_pdf_page=4L, scope_as_printed="Single species",
        scope_key="explicit_species_numbers", species_numbers_as_printed=m[3], references_as_printed=m[2])
      pending <- ""
    }
  }
  stopifnot(!nzchar(trimws(pending)))
}
rows <- do.call(rbind, lapply(blocks, function(b) data.frame(b, stringsAsFactors=FALSE)))
rows[] <- lapply(rows, as.character)
stopifnot(sum(rows$scope_key == "explicit_species_numbers") == 51L)
freeze(item_name, rows)
cat(nrow(rows), "source-scope blocks\n")
