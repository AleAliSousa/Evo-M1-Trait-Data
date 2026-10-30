# Ricklefs__2010_SIAppendices_extract_snapshot.R
#
# Builds the two frozen snapshots of Ricklefs (2010) PNAS 107:10314 Supporting Information (sapp.pdf,
# 38 pp., downloaded by the owner 2026-10-23) from the PDF TEXT LAYER (word boxes, pdftools::pdf_data):
#   Ricklefs__2010_Appendix4_snapshot.csv  APPENDIX 4, Weibull mortality parameters (SI pp. 5-17)
#   Ricklefs__2010_Appendix6_snapshot.csv  APPENDIX 6, life-history variables from AnAge (SI pp. 19-29)
# Each appendix prints three sections (Mammals / Birds / Reptiles and amphibians) with different columns;
# a snapshot stacks them in printed order with a `section` column, column headers as printed in that
# section (a header shared by two sections is one column). Values are written exactly as printed
# ("." = no value, as printed; a cell with nothing printed stays empty).
# No values live in this script. A row printing all of its section's numeric columns (missing values
# print as ".") is read in printed order; a row with a cell left empty is placed by x position against
# the per-page, per-section column right edges (median over the complete rows). The number of numeric
# columns per section is fixed by the printed header. Text cells are taken in
# printed order (Class/Order/Family/Genus, then Species = remaining words before the numbers).
# Guard: refuses to overwrite an existing snapshot that differs from a fresh extraction.
# The omega column header is a Greek glyph with no text-layer character; it is written "ω".

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
item_dir <- dirname(.sp)
folder   <- basename(item_dir)
pdf_file <- file.path(item_dir, "sapp.pdf")

## Printed layout of each section: text columns, then numeric columns (header labels as printed).
spec <- list(
  Appendix4 = list(pages = 5:17, sections = list(
    "Mammals" = list(text = c("Order", "Family", "Genus", "Species"), status = TRUE, notes = TRUE,
                     num = c("b", "a", "m0", "\u03c9", "n", "oldest")),
    "Birds" = list(text = c("Order", "Family", "Genus", "Species"), status = FALSE, notes = FALSE,
                   num = c("b", "a", "m0", "\u03c9", "n", "oldest")),
    "Reptiles and amphibians" = list(text = c("Order", "Family", "Genus", "Species"), status = FALSE, notes = FALSE,
                   num = c("b", "a", "m0", "\u03c9", "n", "oldest")))),
  Appendix6 = list(pages = 19:29, sections = list(
    "Mammals" = list(text = c("Order", "Family", "Genus", "Species"), status = FALSE, notes = FALSE,
                     num = c("Age at maturity (d) Females", "Mass (g) Adult", "Mass (g) Neonate", "Mass (g) Weaning",
                             "Period (d) Gestation", "Period (d) Weaning", "Growth rate k (1/d)", "Oldest (y)")),
    "Birds" = list(text = c("Order", "Family", "Genus", "Species"), status = FALSE, notes = FALSE,
                   num = c("Female age at maturity (d)", "Adult mass (g)", "Egg mass (g)", "Incubation period (d)",
                           "Growth rate k (d)", "Oldest (y)")),
    "Reptiles and amphibians" = list(text = c("Class", "Order", "Family", "Genus", "Species"), status = FALSE, notes = FALSE,
                   num = c("Female age at maturity (d)", "Adult body mass (g)", "Adult length (m)",
                           "Incubation period (d)", "Longevity (y)")))))

num_re  <- "^(\\*?-?[0-9]*\\.?[0-9]+(E[-+][0-9]+)?|\\.)$"   # printed number, "." (no value), "*.2827" kept
heading <- "^(Mammals|Birds|Reptiles and amphibians)$"

extract <- function(sp) {
  W <- pdftools::pdf_data(pdf_file); out <- list(); section <- NA_character_
  for (pg in sp$pages) {
    d <- as.data.frame(W[[pg]], stringsAsFactors = FALSE)
    d <- d[order(d$y, d$x), ]; d$xr <- d$x + d$width
    d$line <- cumsum(c(TRUE, diff(d$y) > 2))
    lines <- split(d, d$line)
    ## tag each printed line with the section it falls in
    blocks <- list()
    for (w in lines) {
      txt <- paste(w$text, collapse = " ")
      if (grepl(heading, txt)) { section <- txt; next }
      s <- sp$sections[[section]]
      if (is.null(s)) next
      is_row <- nrow(w) >= length(s$text) + 1 && grepl("^[A-Z][a-z]+$", w$text[1]) &&
                sum(grepl(num_re, w$text)) >= 1 && !grepl("^(Order|Class)$", w$text[1])
      if (!is_row) next
      blocks[[section]] <- c(blocks[[section]], list(w))
    }
    for (sec in names(blocks)) {
      s <- sp$sections[[sec]]; rows <- blocks[[sec]]
      ## numeric words = the run of number tokens after the text cells (Notes letters a/b may follow)
      first_num <- function(w) { k <- which(grepl(num_re, w$text) & seq_len(nrow(w)) > length(s$text)); k[1] }
      num_part  <- function(w) { t <- w[first_num(w):nrow(w), ]; t[grepl(num_re, t$text), ] }
      nk <- length(s$num)
      full <- Filter(function(w) nrow(num_part(w)) == nk, rows)
      if (!length(full)) stop(sprintf("page %d %s: no complete row to locate columns", pg, sec), call. = FALSE)
      ## column right edges = per-position median over complete rows (robust to a misaligned printed row)
      edges <- apply(do.call(rbind, lapply(full, function(w) num_part(w)$xr)), 2, median)
      for (w in rows) {
        k <- first_num(w)
        tail_w <- w[k:nrow(w), ]
        notes <- tail_w$text[!grepl(num_re, tail_w$text)]
        tail_w <- tail_w[grepl(num_re, tail_w$text), ]
        rec <- setNames(as.list(rep("", nk)), s$num)
        if (nrow(tail_w) == nk) {                       # complete row: printed order
          rec[] <- as.list(tail_w$text)
        } else if (nrow(tail_w) < nk) {                 # a cell printed empty: place by x
          cols <- vapply(seq_len(nrow(tail_w)), function(j) which.min(abs(edges - tail_w$xr[j])), 1L)
          if (any(abs(edges[cols] - tail_w$xr) > 12) || any(duplicated(cols)) || is.unsorted(cols))
            stop(sprintf("page %d %s: cannot place values of row %s", pg, sec, paste(w$text, collapse = " ")), call. = FALSE)
          rec[cols] <- as.list(tail_w$text)
        } else stop(sprintf("page %d %s: %d values for %d columns on row %s", pg, sec, nrow(tail_w), nk, paste(w$text, collapse = " ")), call. = FALSE)
        head_w <- w$text[seq_len(k - 1)]
        status <- ""
        if (isTRUE(s$status)) { st <- which(head_w %in% c("zoo", "wild")); if (length(st) != 1L) stop("page ", pg, ": no Status on row ", paste(w$text, collapse = " "), call. = FALSE); status <- head_w[st]; head_w <- head_w[-st] }
        nt <- length(s$text)
        txt <- c(head_w[seq_len(nt - 1)], paste(head_w[nt:length(head_w)], collapse = " "))
        row <- c(list(section = sec), setNames(as.list(txt), s$text))
        if (isTRUE(s$status)) row$Status <- status
        row <- c(row, rec)
        if (isTRUE(s$notes)) row$Notes <- paste(notes, collapse = " ")
        out[[length(out) + 1L]] <- as.data.frame(row, check.names = FALSE, stringsAsFactors = FALSE)
      }
    }
  }
  cols <- unique(unlist(lapply(out, names)))
  cols <- c("section", intersect("Class", cols), setdiff(cols, c("section", "Class")))   # Class (reptile section only) before Order
  do.call(rbind, lapply(out, function(r) { r[setdiff(cols, names(r))] <- ""; r[cols] }))
}

for (it in names(spec)) {
  sp <- spec[[it]]
  snap <- extract(sp)
  snap_file <- file.path(item_dir, paste0(folder, "_", it, "_snapshot.csv"))
  tmp <- tempfile(fileext = ".csv")
  write.csv(snap, tmp, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  if (file.exists(snap_file) && !identical(unname(tools::md5sum(tmp)), unname(tools::md5sum(snap_file))))
    stop("existing snapshot differs from a fresh extraction -- not overwriting ", basename(snap_file), call. = FALSE)
  invisible(file.copy(tmp, snap_file, overwrite = TRUE))
  message(basename(snap_file), ": ", nrow(snap), " rows (", paste(names(table(snap$section)), table(snap$section), sep = " ", collapse = "; "), ")")
}
