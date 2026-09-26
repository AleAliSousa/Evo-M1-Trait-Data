# deSousa__2008_Suppl.Table5.2_extract_snapshot.R ---------------------------------------------------
#
# Build the frozen snapshot of de Sousa (2008) dissertation Suppl. Table 5.2
# "Comparison of adjusted values to published data of Semendeferi et al. (1998,
# 2002)" (printed p. 198; PDF page 217, landscape).
#
# Registered under Item number "Sup Table 5.2" following the same-author
# precedent deSousa_etal_2010_SupTable2; the printed label "Suppl. Table 5.2"
# is kept verbatim in the snapshot caption and in "Item full original title".
#
# The dissertation PDF has a real text layer, so NO value is typed into this
# script: every cell is read from the page at run time with pdftools::pdf_data()
# and placed by its printed x position. Only the caption, the two printed header
# tiers and the two printed footnotes are anchored printed literals.
#
# The table is a two-block comparison: the left block is Semendeferi et al.
# (1998, 2002) as published (SECONDARY, not de Sousa data); the right block is
# the dissertation's own adjusted values ("Current study"). Both blocks are kept
# and are distinguished by column prefix in the reformat -- never pooled.
#
# Run:  Rscript deSousa__2008_Suppl.Table5.2_extract_snapshot.R
# Output: deSousa__2008_Suppl.Table5.2_snapshot.xlsx   (sheet "Suppl.Table5.2")

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
pdf_page  <- 217L      # printed p. 198
out_file  <- "deSousa__2008_Suppl.Table5.2_snapshot.xlsx"
out_sheet <- "Suppl.Table5.2"

band_edges <- c(60, 110, 140, 215, 240, 300, 350, 410, 440, 500, 545, Inf)
band_names <- c("species", "code", "code2",
                "sem_CF", "sem_brain_vol", "sem_area_13", "sem_area_10",
                "cur_CF", "cur_brain_vol", "cur_area_13", "cur_area_10")

d   <- pdf_data(pdf_file)[[pdf_page]]
d   <- d[order(d$y, d$x), ]
dat <- d[d$y > 158 & d$y < 240, ]          # below the two header tiers, above the footnotes
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
keep <- !is.na(grid[, "species"]) & !is.na(grid[, "code"])
grid <- grid[keep, , drop = FALSE]
stopifnot(nrow(grid) == 6L)

caption <- c("Suppl. Table 5.2. Comparison of adjusted values to published data of Semendeferi et al. (1998, 2002)",
             rep(NA_character_, 10))
hdr1 <- c("Species", "code", "code", "Semendeferi et al. 1998; 2002", NA, NA, NA,
          "Current study", NA, NA, NA)
hdr2 <- c(NA, NA, NA, "CF", "brain vol.", "area 13 vol.", "area 10 vol.",
          "CF", "brain vol.", "area 13 vol.", "area 10 vol.")
foot1 <- c(paste("* the brain volume differs because Semendeferi calculated it from the fixed weight (1200g),",
                 "whereas I calculated it from the fresh weight (1349g)"), rep(NA_character_, 10))
foot2 <- c("** the fresh weight for this specimen is 440g", rep(NA_character_, 10))

sheet <- rbind(caption, hdr1, hdr2, unname(grid), rep(NA_character_, 11), foot1, foot2)
dimnames(sheet) <- NULL

wb <- createWorkbook()
addWorksheet(wb, out_sheet)
writeData(wb, out_sheet, as.data.frame(sheet, stringsAsFactors = FALSE),
          colNames = FALSE, keepNA = FALSE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold"),
         rows = 1, cols = seq_len(11), gridExpand = TRUE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold", wrapText = TRUE),
         rows = 2:3, cols = seq_len(11), gridExpand = TRUE)
setColWidths(wb, out_sheet, cols = 1:11,
             widths = c(12, 8, 12, 8, 12, 13, 13, 8, 12, 13, 13) - 0.71)
saveWorkbook(wb, file.path(paper_dir, out_file), overwrite = TRUE)
message(sprintf("%s [%s]: %d rows x %d cols (%d specimen rows)",
                out_file, out_sheet, nrow(sheet), ncol(sheet), nrow(grid)))
