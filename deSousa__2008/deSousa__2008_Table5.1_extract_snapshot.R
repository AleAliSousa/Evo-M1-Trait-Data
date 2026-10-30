# deSousa__2008_Table5.1_extract_snapshot.R ------------------------------------------------------
#
# Build the frozen snapshot of de Sousa (2008) dissertation Table 5.1
# "Specimens and volumes" (printed p. 190; PDF page 209, landscape).
#
# The dissertation PDF has a real text layer, so NO value is typed into this
# script: every cell is read from the page at run time with pdftools::pdf_data()
# and placed by its printed x position. Only the caption, the two printed header
# tiers, the "Notes:" line and the footnote text are anchored printed literals.
#
# Faithful capture per __HOWTO_make_a_snapshot.md: printed row order, printed
# column order, original units (kg / g / cm3), the literal "NA" cells and the
# printed blanks are all kept as strings so trailing zeros ("1116.80", "2.00")
# survive verbatim. The reformat (deSousa__2008_Table5.1.R) does the typing and
# the unit conversion.
#
# Nothing is corrected here. Two printed oddities are carried as-is and flagged
# in the README instead:
#   * the siamang is printed "Syndactylus symphalangus" (genus and species
#     reversed; the accepted binomial is Symphalangus syndactylus).
#   * ptc1 / ptc3 / ptw1 / ptd carry no brain mass, and CF is the pooled 2.05.
#
# Run:  Rscript deSousa__2008_Table5.1_extract_snapshot.R
# Output: deSousa__2008_Table5.1_snapshot.xlsx   (sheet "Table5.1")

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir <- dirname(.sp)

suppressPackageStartupMessages({ library(pdftools); library(openxlsx) })

pdf_file   <- file.path(paper_dir, "desousa_2008.pdf")
pdf_page   <- 209L      # printed p. 190
out_file   <- "deSousa__2008_Table5.1_snapshot.xlsx"
out_sheet  <- "Table5.1"

## ---- printed column x-bands (left edge of each printed column) --------------
band_edges <- c(60, 190, 215, 240, 282, 360, 400, 430, 460, 490, 535, 575, 610, Inf)
band_names <- c("species", "code", "sex", "age", "collection", "plane_of_section",
                "body_mass_kg", "brain_mass_g", "CF", "brain_vol_cm3",
                "left_V1_vol_cm3", "left_LGN_vol_cm3", "neocortex_vol_cm3")

## ---- read the page ----------------------------------------------------------
d <- pdf_data(pdf_file)[[pdf_page]]
d <- d[order(d$y, d$x), ]

## the data band: below the header tiers (y 158/159) and above "Notes:" (y 516)
dat <- d[d$y > 165 & d$y < 510, ]
stopifnot(nrow(dat) > 0)

## one printed line per distinct y
cell_of <- function(tok) {
  ## join tokens of one printed cell, honouring the printed inter-word space
  out <- ""
  for (i in seq_len(nrow(tok))) {
    out <- paste0(out, tok$text[i], if (i < nrow(tok) && isTRUE(tok$space[i])) " " else "")
  }
  trimws(out)
}

rows <- lapply(sort(unique(dat$y)), function(yy) {
  tk  <- dat[dat$y == yy, ]
  bin <- cut(tk$x, breaks = band_edges, labels = band_names, right = FALSE)
  vapply(band_names, function(nm) {
    sub <- tk[!is.na(bin) & bin == nm, ]
    if (nrow(sub) == 0) NA_character_ else cell_of(sub)
  }, character(1))
})
grid <- do.call(rbind, rows)

## keep the specimen rows only: a printed species name AND a printed code
keep <- !is.na(grid[, "species"]) & grepl("^[A-Z][a-z]+ [a-z]+$", grid[, "species"]) &
        !is.na(grid[, "code"])
grid <- grid[keep, , drop = FALSE]
stopifnot(nrow(grid) == 29L)

## ---- printed header tiers, caption and footnote (anchored literals) ---------
caption <- c("Table 5.1 Specimens and volumes", rep(NA_character_, 12))
hdr1 <- c(NA, NA, NA, NA, NA, "plane of", "body", "brain", NA,
          "brain vol.", "left V1", "left LGN", "neocortex")
hdr2 <- c("species", "code", "sex", "age", "collection", "section", "mass (kg)", "mass (g)",
          "CF", "(cm3)", "vol. (cm3)", "vol. (cm3)", "vol. (cm3)a")
notes1 <- c("Notes:", rep(NA_character_, 12))
notes2 <- c("a. Neocortex volume includes grey matter and underlying white matter",
            rep(NA_character_, 12))

sheet <- rbind(caption, hdr1, hdr2, unname(grid), rep(NA_character_, 13), notes1, notes2)
dimnames(sheet) <- NULL

## ---- write ------------------------------------------------------------------
wb <- createWorkbook()
addWorksheet(wb, out_sheet)
writeData(wb, out_sheet, as.data.frame(sheet, stringsAsFactors = FALSE),
          colNames = FALSE, keepNA = FALSE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold"),
         rows = 1, cols = seq_len(13), gridExpand = TRUE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold", wrapText = TRUE),
         rows = 2:3, cols = seq_len(13), gridExpand = TRUE)
setColWidths(wb, out_sheet, cols = 1:13,
             widths = c(24, 8, 6, 9, 17, 11, 10, 10, 7, 11, 11, 11, 12) - 0.71)
saveWorkbook(wb, file.path(paper_dir, out_file), overwrite = TRUE)
message(sprintf("%s [%s]: %d rows x %d cols (%d specimen rows)",
                out_file, out_sheet, nrow(sheet), ncol(sheet), nrow(grid)))
