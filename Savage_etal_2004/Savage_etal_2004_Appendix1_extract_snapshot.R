# Savage_etal_2004_Appendix1_extract_snapshot.R
#
# Builds the frozen snapshot Savage_etal_2004_Appendix1_snapshot.csv from the TEXT LAYER of the
# born-digital journal PDF (Functional Ecology 18:257-282, Appendix 1, printed pp. 268-281).
# No table values live in this script: every value is captured at run time from the PDF word
# boxes (pdftools::pdf_data) and written exactly as printed (middle-dot decimal "·", thousands
# groups joined with a single space, reference text, row order). Continuation lines (references
# wrapped onto a second line) are appended to the row above with a single space.
# Guard: refuses to overwrite an existing snapshot whose content differs.

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
item_dir  <- dirname(.sp)
item_name <- sub("_extract_snapshot\\.R$", "", basename(.sp))     # "Savage_etal_2004_Appendix1"
pdf_file  <- file.path(item_dir, "Savage-2004-The predominance of quarter-power.pdf")
snap_file <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))

## Read word boxes (pdf_data), not the line text: the rotated running footer
## "(c) 2004 British Ecological Society, Functional Ecology, 18, 257-282" is printed in the left
## margin and interleaves with the last data rows in pdf_text(), splitting Order/Family cells.
## Footer and running-head words are set in a larger face (box height >= 7) than the table body
## (height 6), so they are dropped by height; rows are rebuilt by y and cells by x against the
## page's own header positions (Order / Family / Species / References).
words <- pdftools::pdf_data(pdf_file)
txt   <- pdftools::pdf_text(pdf_file)
num_re <- "^[0-9]+(?:\u00b7[0-9]+)?$"   # a printed digit group; "1024·3" is printed unspaced
out <- list(); last <- 0L
for (pg in seq_along(words)) {
  head3 <- strsplit(txt[pg], "\n", fixed = TRUE)[[1]][1:3]
  if (!any(grepl("Appendix 1", head3)) || any(grepl("Appendix 2", head3))) next
  d <- as.data.frame(words[[pg]], stringsAsFactors = FALSE)
  hy <- d$y[d$text == "Order" & d$y < 120]
  if (length(hy) != 1L) stop("no Appendix 1 header on PDF page ", pg, call. = FALSE)
  hx <- function(w) d$x[d$text == w & abs(d$y - hy) <= 1][1]
  x_fam <- hx("Family"); x_sp <- hx("Species"); x_ref <- hx("References")
  body <- d[d$y > hy + 2 & d$height <= 6, ]
  body <- body[order(body$y, body$x), ]
  ## cluster into printed rows: same baseline within 1.5 pt
  grp <- cumsum(c(TRUE, diff(body$y) > 1.5))
  for (g in unique(grp)) {
    w <- body[grp == g, ]; w <- w[order(w$x), ]
    cell <- function(sel) paste(w$text[sel], collapse = " ")
    if (all(w$x >= x_ref - 2)) {                        # wrapped References continuation
      if (last == 0L) stop("continuation before first row, page ", pg, call. = FALSE)
      out[[last]]$References <- paste(out[[last]]$References, cell(TRUE)); next
    }
    is_num <- grepl(num_re, w$text, perl = TRUE) & w$x >= x_sp & w$x < x_ref - 2
    first_num <- which(is_num)[1]
    if (is.na(first_num)) stop("row without numbers on page ", pg, ": ", cell(TRUE), call. = FALSE)
    nw <- w[first_num:max(which(w$x < x_ref - 2)), ]
    if (!all(grepl(num_re, nw$text, perl = TRUE)))
      stop("non-numeric word inside the numeric block on page ", pg, ": ", cell(TRUE), call. = FALSE)
    ## join thousands groups: next word starts within 4 pt of the previous word's right edge
    gap <- c(Inf, nw$x[-1] - (nw$x[-nrow(nw)] + nw$width[-nrow(nw)]))
    nums <- tapply(nw$text, cumsum(gap > 4), paste, collapse = " ")
    if (!length(nums) %in% c(2L, 4L))
      stop(length(nums), " numeric cells on page ", pg, ": ", cell(TRUE), call. = FALSE)
    last <- last + 1L
    out[[last]] <- data.frame(
      Order   = cell(w$x < x_fam - 2),
      Family  = cell(w$x >= x_fam - 2 & w$x < x_sp - 2),
      Species = cell(w$x >= x_sp - 2 & seq_len(nrow(w)) < first_num),
      `Mass (g)` = nums[[1]], `BMR (W)` = nums[[2]],
      `Species avg. mass (g)` = if (length(nums) == 4L) nums[[3]] else "",
      `Species avg. BMR (W)`  = if (length(nums) == 4L) nums[[4]] else "",
      References = cell(w$x >= x_ref - 2),
      check.names = FALSE, stringsAsFactors = FALSE)
  }
}
snap <- do.call(rbind, out)

tmp <- tempfile(fileext = ".csv")
write.csv(snap, tmp, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (file.exists(snap_file) && !identical(unname(tools::md5sum(tmp)), unname(tools::md5sum(snap_file))))
  stop("existing snapshot differs from a fresh extraction -- not overwriting ", basename(snap_file), call. = FALSE)
invisible(file.copy(tmp, snap_file, overwrite = TRUE))
message("Snapshot ", basename(snap_file), ": ", nrow(snap), " measurement rows, ",
        sum(nzchar(snap$`Species avg. mass (g)`)), " species-average rows")
