# Holmes_etal_2024_SupplementaryTable2_snapshot.R ----------------------
#
# Holmes, Honhar, Tinaz, ... Carson & Matuskey (2024). Synaptic loss and its
# association with symptom severity in Parkinson's disease.
# npj Parkinson's Disease 10:42. https://doi.org/10.1038/s41531-024-00655-9
#
# Writes the two FROZEN sources of item Holmes_etal_2024_SupplementaryTable2:
#
#   1. Holmes_etal_2024_SupplementaryTable2_snapshot.xlsx  (sheet
#      "SupplementaryTable2") -- Supplementary Table 2 of the journal-supplied
#      supplement 41531_2024_655_MOESM1_ESM.pdf (page 2), laid out as printed:
#      caption, two-line column headers, the italic section rows "Primary" /
#      "Secondary", 26 region rows in printed order, the footnote. Cells keep the
#      printed "mean (SD)" strings. The Bonferroni-significant row, printed in
#      bold, is bold in the xlsx (the footnote gives bold its meaning).
#   2. Holmes_etal_2024_data_from_text_snapshot.csv -- the reference-region
#      (centrum semiovale) VT and K1 that the paper prints only in running text
#      (Methods, "Quantitative analysis of PET data", article p. 7, right column).
#
# Values are read from the PDF text layer at run time (pdftools::pdf_data, word
# positions + font names); no table value is typed in this script. Column
# boundaries are derived from the printed header words. Printed literals that
# ARE typed here are anchors (caption, header and footnote words) and the unit
# strings of the text passage, whose super/subscripts the text layer splits off.
# Refuses to overwrite a frozen copy that differs from a fresh extraction.
#
# Run once (Rscript <this file>); the build script reads the frozen files.

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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("_snapshot\\.R$", "", basename(.sp))
base <- item_name
paper <- sub("_SupplementaryTable2$", "", item_name)            # Holmes_etal_2024

suppressPackageStartupMessages({ library(pdftools); library(openxlsx); library(readxl) })

supp_pdf    <- "41531_2024_655_MOESM1_ESM.pdf"
article_pdf <- "Holmes-2024-Synaptic loss and its association.pdf"
stopifnot(file.exists(supp_pdf), file.exists(article_pdf))

## ---- 1. Supplementary Table 2 (supplement p. 2) -------------------------------
w <- pdf_data(supp_pdf, font_info = TRUE)[[2]]
w <- as.data.frame(w[, c("x", "y", "width", "height", "text", "font_name")])
line_at <- function(y0) w[w$y == y0, ][order(w$x[w$y == y0]), ]

## anchors
y_cap  <- w$y[w$text == "Supplementary" & vapply(w$y, function(yy)
            any(w$y == yy & w$text == "Table") && any(w$y == yy & w$text == "2."), logical(1))]
stopifnot(length(y_cap) == 1L)
y_h1   <- w$y[w$text == "Region" & w$y > y_cap][1]
y_h2   <- min(w$y[w$text == "(n=30)" & w$y > y_h1])
y_foot <- w$y[w$text == "Values" & w$y > y_h2][1]
stopifnot(!is.na(y_h1), is.finite(y_h2), !is.na(y_foot))
cap_words <- w[abs(w$y - y_cap) <= 5, ]; cap_words <- cap_words[order(cap_words$x), ]
caption <- gsub("BP ND", "BPND", paste(cap_words$text, collapse = " "))
stopifnot(startsWith(caption, "Supplementary Table 2. BPND values across HC and PD groups."))
footnote <- paste(line_at(y_foot)$text, collapse = " ")
stopifnot(identical(footnote, "Values in bold imply significance after Bonferroni correction"))

## column boundaries from the printed header words (rows y_h1 .. y_h2)
hdr <- w[w$y >= y_h1 - 3 & w$y <= y_h2, ]
span <- function(words) { h <- hdr[hdr$text %in% words, ]; c(min(h$x), max(h$x + h$width)) }
hc  <- span(c("HC", "group", "(n=30)"))[1]               # left edge of the HC block
hcs <- hdr[hdr$x >= hc - 1 & hdr$x < hc + 60, ]; hc_r <- max(hcs$x + hcs$width)
pd  <- hdr[hdr$text %in% c("PD", "group", "(n=30)") & hdr$x > hc_r, ]
pd_l <- min(pd$x); pd_r <- max(pd$x + pd$width)
pv  <- span("p-value"); df <- span(c("%", "Difference")); cd <- span(c("Cohen\u2019s", "d", "magnitude"))
cuts <- c(-Inf, hc - 5, (hc_r + pd_l) / 2, (pd_r + pv[1]) / 2, (pv[2] + df[1]) / 2,
          (df[2] + cd[1]) / 2, Inf)
header1 <- c("Region", "HC group", "PD group", "p-value", "%", "Cohen\u2019s d")
header2 <- c("", "(n=30)", "(n=30)", "", "Difference", "magnitude")
for (k in 2:6) {                                     # each printed header lands in its own column
  got <- hdr$text[findInterval(hdr$x, cuts) == k]
  stopifnot(all(strsplit(trimws(paste(header1[k], header2[k])), " ")[[1]] %in% got))
}

## body lines
body <- w[w$y > y_h2 + 2 & w$y < y_foot - 2, ]
ys <- sort(unique(body$y))
rows <- lapply(ys, function(yy) {
  b <- body[body$y == yy, ]; b <- b[order(b$x), ]
  col <- findInterval(b$x, cuts)
  cells <- vapply(1:6, function(k) paste(b$text[col == k], collapse = " "), character(1))
  list(cells = cells,
       bold   = any(grepl("Bold", b$font_name)),
       italic = all(grepl("Italic", b$font_name)) && all(cells[2:6] == ""))
})
cells <- do.call(rbind, lapply(rows, `[[`, "cells"))
is_bold   <- vapply(rows, `[[`, logical(1), "bold")
is_italic <- vapply(rows, `[[`, logical(1), "italic")

## structure checks: 2 italic section rows, 26 data rows, each data cell well formed
stopifnot(sum(is_italic) == 2L, identical(cells[is_italic, 1], c("Primary", "Secondary")))
dat <- cells[!is_italic, , drop = FALSE]
stopifnot(nrow(dat) == 26L,
          all(grepl("^-?[0-9]+\\.[0-9]+ \\([0-9]+\\.[0-9]+\\)$", dat[, 2])),
          all(grepl("^-?[0-9]+\\.[0-9]+ \\([0-9]+\\.[0-9]+\\)$", dat[, 3])),
          all(grepl("^[0-9]\\.[0-9]+$", dat[, 4])),
          all(grepl("^-?[0-9]+(\\.[0-9]+)?$", dat[, 5])),
          all(grepl("^[0-9]\\.[0-9]+$", dat[, 6])))

snap <- rbind(c(caption, rep("", 5)), header1, header2, cells, c(footnote, rep("", 5)))
dimnames(snap) <- NULL
bold_rows   <- 3L + which(is_bold)        # sheet rows (1 = caption, 2-3 = header)
italic_rows <- 3L + which(is_italic)

snap_file <- paste0(base, "_snapshot.xlsx")
if (file.exists(snap_file)) {
  old <- as.matrix(read_excel(snap_file, sheet = "SupplementaryTable2", col_names = FALSE,
                              col_types = "text", .name_repair = "minimal"))
  old[is.na(old)] <- ""; dimnames(old) <- NULL
  if (!identical(dim(old), dim(snap)) || !all(old == snap))
    stop(snap_file, " exists and differs from a fresh extraction - frozen copy NOT overwritten. ",
         "Inspect the difference; delete the frozen copy only on an explicit owner decision.")
  message(snap_file, ": frozen copy matches a fresh extraction (not rewritten)")
} else {
  wb <- createWorkbook()
  addWorksheet(wb, "SupplementaryTable2")
  writeData(wb, 1, as.data.frame(snap, stringsAsFactors = FALSE), colNames = FALSE)
  addStyle(wb, 1, createStyle(textDecoration = "bold"), rows = c(1L, bold_rows), cols = 1:6,
           gridExpand = TRUE)
  addStyle(wb, 1, createStyle(textDecoration = "italic"), rows = italic_rows, cols = 1,
           gridExpand = TRUE)
  setColWidths(wb, 1, cols = 1:6, widths = c(22, 13, 13, 9, 11, 11))
  saveWorkbook(wb, snap_file)
  message(snap_file, ": frozen snapshot written (", nrow(snap), " rows x 6 cols; bold rows ",
          paste(bold_rows, collapse = ","), ")")
}

## ---- 2. Reference-region VT and K1 from running text (article p. 7) ------------
pw <- pdf_pagesize(article_pdf)$width[7]
t7 <- as.data.frame(pdf_data(article_pdf)[[7]])
body_h <- as.numeric(names(sort(table(t7$height), decreasing = TRUE))[1])
t7 <- t7[t7$height >= body_h - 1, ]                     # drop split-off super/subscripts
t7$col <- ifelse(t7$x < pw / 2, 1L, 2L)                 # two-column page: read col 1 then col 2
t7 <- t7[order(t7$col, t7$y, t7$x), ]
s <- gsub("dif- ference", "difference", paste(t7$text, collapse = " "), fixed = TRUE)
num <- "([0-9]+\\.[0-9]+ \u00b1 [0-9]+\\.[0-9]+)"
pat <- paste0("for ([0-9]+) PD subjects and ([0-9]+) HC for whom arterial blood sampling was performed.*?",
              "volume of distribution \\(V , PD: ", num, " mL/cm , HC: ", num, " mL/cm , p = ([0-9.]+),",
              ".*?tracer uptake parameter \\(K , PD: ", num, " mL min cm , HC: ", num,
              " ml min cm , p = ([0-9.]+),")
m <- regmatches(s, regexec(pat, s, perl = TRUE))[[1]]
stopifnot(length(m) == 9L)
passage <- m[1]
locus <- "Article p. 7, Methods: 'Quantitative analysis of PET data' (right column)"
text_snap <- data.frame(
  locus = locus,
  quantity_as_printed = c(rep("one tissue compartment model (1TCM)-based volume of distribution (VT)", 2),
                          rep("tracer uptake parameter (K1)", 2)),
  region_as_printed = "reference region (centrum semiovale)",
  group_as_printed = c("PD", "HC", "PD", "HC"),
  n_as_printed = c(m[2], m[3], m[2], m[3]),
  value_as_printed = c(m[4], m[5], m[7], m[8]),
  unit_as_printed = c("mL/cm3", "mL/cm3", "mL min\u22121 cm\u22123", "ml min\u22121 cm\u22123"),
  p_value_as_printed = c(m[6], m[6], m[9], m[9]),
  passage_text_layer = passage,
  stringsAsFactors = FALSE)
text_file <- paste0(paper, "_data_from_text_snapshot.csv")
if (file.exists(text_file)) {
  old <- as.data.frame(readr::read_csv(text_file, col_types = readr::cols(.default = "c"),
                                       na = character()), stringsAsFactors = FALSE)
  if (!identical(dim(old), dim(text_snap)) || !all(as.matrix(old) == as.matrix(text_snap)))
    stop(text_file, " exists and differs from a fresh extraction - frozen copy NOT overwritten.")
  message(text_file, ": frozen copy matches a fresh extraction (not rewritten)")
} else {
  readr::write_csv(text_snap, text_file, na = "")          # readr: UTF-8 in any locale
  message(text_file, ": frozen text snapshot written (", nrow(text_snap), " rows)")
}
