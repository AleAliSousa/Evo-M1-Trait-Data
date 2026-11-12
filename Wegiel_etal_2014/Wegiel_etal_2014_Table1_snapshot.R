# Wegiel_etal_2014_Table1_snapshot.R ----------------------------------
#
# Wegiel J, Flory M, Kuchna I, et al. (2014) Acta Neuropathol Commun 2:141.
# doi:10.1186/s40478-014-0141-7
# Table 1 "Parameters and procedures applied to estimate the volume of brain
# subdivisions and number of neurons" (p. 6).
#
# FROZEN-SOURCE HELPER (not the item build). Pulls the printed table from the
# PDF text layer (pdftools::pdf_text, born-digital BMC PDF, layout preserved)
# and writes <item_name>_snapshot.xlsx in the PRINTED layout: caption, the
# header row (9 printed columns), 23 printed body rows in printed order
# (including the "Entorhinal c." group row, whose cells are blank on the page,
# and blank CE cells), and the four footnote lines. No table value is typed in
# this script: only the printed header literals are anchored (and checked
# against the page text). Cells are stored as text exactly as printed
# ("1000 × 1000", "1.25x", "1,418"). The printed label "Magnocellular basal
# complex (Ch1-Ch4)" wraps onto a second line on the page; it is one printed row
# and is joined with a single space.
# Refuses to overwrite a frozen copy that differs.

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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # Wegiel_etal_2014_Table1
base <- item_name

suppressPackageStartupMessages({ library(pdftools); library(openxlsx); library(readxl) })

pdf_file <- "Wegiel-2014-Stereological study of the neurona.pdf"
page_no  <- 6L
lines <- strsplit(pdf_text(pdf_file)[page_no], "\n", fixed = TRUE)[[1]]

## ---- locate the printed blocks (anchored on printed literals) ----------------
i_cap  <- grep("^Table 1 Parameters and procedures", lines)
i_head <- grep("^Structures and\\s+Number of\\s+Obj\\.\\s+Obj\\.", lines)
i_foot <- grep("^Number of sections examined = ", lines)
stopifnot(length(i_cap) == 1L, length(i_head) == 1L, length(i_foot) == 1L)
stopifnot(grepl("CE\\*\\s*$", lines[i_head]),
          grepl("sections examined \\(Vol\\.\\) \\(Numb\\.\\)", lines[i_head + 1L]),
          grepl("^\\s+\\(per case\\)\\s+fractionator", lines[i_head + 2L]))

caption <- trimws(lines[i_cap])
body    <- lines[(i_head + 3L):(i_foot - 1L)]
body    <- body[nzchar(trimws(body))]
foot    <- trimws(lines[i_foot:(i_foot + 3L)])
stopifnot(grepl("^\\*CE = ", foot[4]))

## ---- parse each printed row --------------------------------------------------
## label = text before the first run of >= 2 spaces. The two objective columns
## are separated by a single space on some rows ("1.25x 40x"), so the value
## part is parsed with an explicit pattern rather than a split.
val_re <- paste0("^(\\d+)\\s+([0-9.]+x)\\s+([0-9]+x)\\s+(\\d+ \u00d7 \\d+)\\s+",
                 "(\\d+ \u00d7 \\d+ \u00d7 \\d+)\\s+([0-9,]+)\\s+([0-9,]+)(?:\\s+([0-9.]+))?\\s*$")
rows <- list()
for (x in body) {
  lab  <- sub("\\s{2,}.*$", "", x)
  rest <- trimws(substring(x, nchar(lab) + 1L))
  if (!nzchar(rest) && grepl("^\\(", lab)) {          # wrapped second line of the label
    k <- length(rows); rows[[k]][1] <- paste(rows[[k]][1], lab); next
  }
  if (!nzchar(rest)) { rows[[length(rows) + 1L]] <- c(lab, rep(NA, 8)); next }   # group row
  m <- regmatches(rest, regexec(val_re, rest))[[1]]
  if (!length(m)) stop("Row not parsed: ", x)
  v <- m[-1]; v[v == ""] <- NA
  rows[[length(rows) + 1L]] <- c(lab, v)
}
dat <- do.call(rbind, rows)
stopifnot(nrow(dat) == 23L, ncol(dat) == 9L, sum(is.na(dat[, 2])) == 1L)

## ---- assemble the printed layout --------------------------------------------
snap <- rbind(
  c(caption, rep(NA, 8)),
  c("Structures and their subdivisions", "Number of sections examined (per case)",
    "Obj. (Vol.)", "Obj. (Numb.)", "Grid size (\u03bcm) for fractionator",
    "Test area frame \u00d7 height (\u03bcm)", "Number of counting spaces (per case)",
    "Number of neurons counted (per case)", "CE*"),
  dat,
  cbind(foot, matrix(NA, 4, 8))
)
dimnames(snap) <- NULL

## ---- freeze (refuse to overwrite a differing frozen copy) --------------------
out <- paste0(base, "_snapshot.xlsx")
if (file.exists(out)) {
  old <- as.matrix(read_excel(out, sheet = "Table1", col_names = FALSE,
                              col_types = "text", .name_repair = "minimal"))
  dimnames(old) <- NULL
  if (identical(dim(old), dim(snap)) && identical(old, snap)) {
    message(out, " unchanged (frozen copy identical to the PDF extraction).")
  } else {
    stop(out, " exists and DIFFERS from the PDF extraction; not overwritten. ",
         "Inspect and delete it by hand only if the frozen copy is wrong.")
  }
} else {
  wb <- createWorkbook()
  addWorksheet(wb, "Table1")
  writeData(wb, "Table1", as.data.frame(snap, stringsAsFactors = FALSE), colNames = FALSE)
  setColWidths(wb, "Table1", cols = 1:9, widths = c(36, 16, 8, 9, 14, 16, 14, 14, 7))
  saveWorkbook(wb, out, overwrite = FALSE)
  message("Frozen ", out, ": ", nrow(snap), " rows x ", ncol(snap), " cols (",
          nrow(dat), " printed body rows).")
}
