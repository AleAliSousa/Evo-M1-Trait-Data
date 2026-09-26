# deSousa__2008_Table5.6_extract_snapshot.R ------------------------------------------------------
#
# Build the frozen snapshot of de Sousa (2008) dissertation Table 5.6
# "Species mean volumes of cortical areas and brain nuclei" (printed p. 195;
# PDF page 214, landscape).
#
# The dissertation PDF has a real text layer, so NO value is typed into this
# script: every cell is read from the page at run time with pdftools::pdf_data()
# and placed by its printed x position. Only the caption, the printed header
# row, the "Notes:" line and the two footnotes are anchored printed literals.
#
# COMPILATION, NOT PRIMARY. Printed footnote a states the values "are derived
# from previous studies which have included hominoid brain specimens from the
# Zilles collection" -- so this item is registered Data role = secondary and is
# NOT merged. Per-structure attribution is recorded in the README.
#
# Units are already mm3 (printed footnote b), so the reformat does no volume
# conversion; only the brain column is carried to project brain units.
#
# Run:  Rscript deSousa__2008_Table5.6_extract_snapshot.R
# Output: deSousa__2008_Table5.6_snapshot.xlsx   (sheet "Table5.6")

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

pdf_file  <- file.path(paper_dir, "desousa_2008.pdf")
pdf_page  <- 214L      # printed p. 195
out_file  <- "deSousa__2008_Table5.6_snapshot.xlsx"
out_sheet <- "Table5.6"

band_edges <- c(60, 155, 215, 245, 278, 310, 350, 400, 440, 480, 560, 600, Inf)
band_names <- c("species", "brain", "vmo", "vii", "xii", "area_13", "area_10",
                "lateral", "basal", "accessory_basal", "area_44", "area_45")

d   <- pdf_data(pdf_file)[[pdf_page]]
d   <- d[order(d$y, d$x), ]
dat <- d[d$y > 145 & d$y < 235, ]          # below the header row, above "Notes:"
stopifnot(nrow(dat) > 0)

cell_of <- function(tok) {
  out <- ""
  for (i in seq_len(nrow(tok)))
    out <- paste0(out, tok$text[i], if (i < nrow(tok) && isTRUE(tok$space[i])) " " else "")
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
keep <- !is.na(grid[, "species"]) & grepl("^[A-Z][a-z]+ [a-z]+$", grid[, "species"])
grid <- grid[keep, , drop = FALSE]
stopifnot(nrow(grid) == 6L)

caption <- c("Table 5.6. Species mean volumes of cortical areas and brain nucleia",
             rep(NA_character_, 11))
hdr <- c("Species", "Brainb", "Vmo", "VII", "XII", "area 13", "area 10",
         "lateral", "basal", "accessory basal", "area 44", "area 45")
notes1 <- c("Notes:", rep(NA_character_, 11))
notes2 <- c(paste("a. The data are derived from previous studies which have included",
                  "hominoid brain specimens from the Zilles collection."),
            rep(NA_character_, 11))
notes3 <- c("b. All volumes are in mm3.", rep(NA_character_, 11))

sheet <- rbind(caption, hdr, unname(grid), rep(NA_character_, 12), notes1, notes2, notes3)
dimnames(sheet) <- NULL

wb <- createWorkbook()
addWorksheet(wb, out_sheet)
writeData(wb, out_sheet, as.data.frame(sheet, stringsAsFactors = FALSE),
          colNames = FALSE, keepNA = FALSE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold"),
         rows = 1, cols = seq_len(12), gridExpand = TRUE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold", wrapText = TRUE),
         rows = 2, cols = seq_len(12), gridExpand = TRUE)
setColWidths(wb, out_sheet, cols = 1:12,
             widths = c(20, 13, 9, 9, 9, 10, 11, 10, 10, 16, 10, 10) - 0.71)
saveWorkbook(wb, file.path(paper_dir, out_file), overwrite = TRUE)
message(sprintf("%s [%s]: %d rows x %d cols (%d species rows)",
                out_file, out_sheet, nrow(sheet), ncol(sheet), nrow(grid)))
