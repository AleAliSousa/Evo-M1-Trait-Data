# deSousa__2008_Table4.1_extract_snapshot.R ------------------------------------------------------
#
# Build the frozen snapshot of de Sousa (2008) dissertation Table 4.1
# "Samples used in analyses of V1, V2, VP and V5" (printed p. 120; PDF page 139,
# landscape).
#
# The dissertation PDF has a real text layer, so NO value is typed into this
# script: every cell is read from the page at run time with pdftools::pdf_data()
# and placed by its printed x position. Only the caption, the three printed
# header tiers and the six footnotes are anchored printed literals.
#
# Footnote superscripts. The markers a, b, c and d are set ABOVE the baseline,
# so pdf_data returns them on their own short line a couple of points above the
# species row, in the gap between the species name and the code column. They are
# collected from that gap and glued to the species string ("Homo sapiensa,b"),
# which is how the printed page reads and how the sibling snapshot
# deSousa_etal_2009_Table1_snapshot.xlsx stores them. The build script splits
# them back out into footnote_ref.
#
# Run:  Rscript deSousa__2008_Table4.1_extract_snapshot.R
# Output: deSousa__2008_Table4.1_snapshot.xlsx   (sheet "Table4.1")

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
pdf_page  <- 139L      # printed p. 120
out_file  <- "deSousa__2008_Table4.1_snapshot.xlsx"
out_sheet <- "Table4.1"

## printed column x-bands; the second band is the superscript gutter
band_edges <- c(60, 130, 170, 200, 250, 275, 308, 342, 382, 410, 458, 502, 545, 620, Inf)
band_names <- c("species", "footnote_marker", "code", "archive_number", "sex", "age",
                "body_mass", "brain_mass", "EQ", "neocortex", "left_V1", "left_LGN",
                "optic_nerve", "surface_area")

d   <- pdf_data(pdf_file)[[pdf_page]]
d   <- d[order(d$y, d$x), ]
dat <- d[d$y > 168 & d$y < 300, ]          # below the header tiers, above the footnotes
stopifnot(nrow(dat) > 0)

cell_of <- function(tok) {
  out <- ""
  for (i in seq_len(nrow(tok)))
    out <- paste0(out, tok$text[i], if (i < nrow(tok) && isTRUE(tok$space[i])) " " else "")
  trimws(out)
}

## cluster printed lines: a 1-point y jitter splits the Pongo row (238/239), while
## the raised superscript lines sit ~2 points above their row -- tolerance 1.5
## merges the former and keeps the latter separate.
ys <- sort(unique(dat$y))
grp <- cumsum(c(TRUE, diff(ys) > 1.5))
lines <- lapply(split(ys, grp), function(yy) dat[dat$y %in% yy, ])

parsed <- lapply(lines, function(tk) {
  bin <- cut(tk$x, breaks = band_edges, labels = band_names, right = FALSE)
  vapply(band_names, function(nm) {
    sub <- tk[!is.na(bin) & bin == nm, ]
    if (nrow(sub) == 0) NA_character_ else cell_of(sub)
  }, character(1))
})
grid <- do.call(rbind, parsed)

## a superscript line carries ONLY a footnote marker; it belongs to the next row
is_marker_line <- !is.na(grid[, "footnote_marker"]) & is.na(grid[, "code"])
is_data_line   <- !is.na(grid[, "code"]) & !is.na(grid[, "species"])
pending <- NA_character_
for (i in seq_len(nrow(grid))) {
  if (is_marker_line[i]) { pending <- grid[i, "footnote_marker"]; next }
  if (is_data_line[i] && !is.na(pending)) {
    grid[i, "species"] <- paste0(grid[i, "species"], gsub(" ", "", pending))
    pending <- NA_character_
  }
}
grid <- grid[is_data_line, setdiff(band_names, "footnote_marker"), drop = FALSE]
stopifnot(nrow(grid) == 9L)

## ---- printed caption, header tiers and footnotes (anchored literals) --------
ncol_out <- 13L
pad <- function(x) c(x, rep(NA_character_, ncol_out - length(x)))
caption <- pad("Table 4.1. Samples used in analyses of V1, V2, VP and V5")
hdr1 <- c(NA, NA, NA, NA, NA, "body", "brain", NA, "neocortex", "left V1", "left LGN",
          "optic nerve", "surface")
hdr2 <- c(NA, NA, "archive", NA, "age", "mass", "mass", NA, "volume", "vol", "vol",
          "cross sectional", "area")
hdr3 <- c("Species", "code", "number", "sex", "(yrs)", "(kg)", "(g)", "EQe",
          "(cm3)", "(mm3)", "(mm3)", "area (mm2)f", "(mm2)f")
foots <- lapply(c(
  "a. Used same sex species mean value for body weight (Zilles 1972)",
  "b. Used combined sex mean human neocortex value (n=8) based on unpublished data provided by Carol MacLeod",
  "c. Used same sex species mean value for body weight (Jungers and Susman 1984)",
  "d. Used combined sex species mean values for brain and body weight (Herndon et al. 1999. )",
  "e. Encephalization quotient (EQ) after Martin (1981) and Ruff et al. (1997)",
  "f. Species mean data from Stephan and Frahm 1981"), pad)

sheet <- rbind(caption, hdr1, hdr2, hdr3, unname(grid),
               rep(NA_character_, ncol_out), do.call(rbind, foots))
dimnames(sheet) <- NULL

wb <- createWorkbook()
addWorksheet(wb, out_sheet)
writeData(wb, out_sheet, as.data.frame(sheet, stringsAsFactors = FALSE),
          colNames = FALSE, keepNA = FALSE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold"),
         rows = 1, cols = seq_len(ncol_out), gridExpand = TRUE)
addStyle(wb, out_sheet, createStyle(textDecoration = "bold", wrapText = TRUE),
         rows = 2:4, cols = seq_len(ncol_out), gridExpand = TRUE)
setColWidths(wb, out_sheet, cols = 1:ncol_out,
             widths = c(22, 8, 12, 6, 8, 10, 10, 8, 12, 11, 11, 15, 12) - 0.71)
saveWorkbook(wb, file.path(paper_dir, out_file), overwrite = TRUE)
message(sprintf("%s [%s]: %d rows x %d cols (%d specimen rows)",
                out_file, out_sheet, nrow(sheet), ncol(sheet), nrow(grid)))
