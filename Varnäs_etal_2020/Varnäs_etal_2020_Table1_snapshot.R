# Varnäs_etal_2020_Table1_snapshot.R -------------------------------------
#
# Varnäs, K., Stepanov, V., & Halldin, C. (2020). Autoradiographic mapping of
# synaptic vesicle glycoprotein 2A in non-human primate and human brain.
# Synapse 74(10): e22157. https://doi.org/10.1002/syn.22157
#
# Writes the FROZEN snapshot Varnäs_etal_2020_Table1_snapshot.xlsx (sheet
# "Table1") from TABLE 1 on PDF page 4 ("4 of 6"), laid out as printed: caption,
# the two spanning group headers (Non-human primate / Human) with blank padding,
# the seven column headers, 14 region rows in printed order with their printed
# blanks (Occipital cortex has no non-human-primate values; White matter has no
# ratio), and the Note. Cells keep the printed "mean (range)" strings.
#
# Values are read from the PDF text layer at run time (pdftools::pdf_data word
# positions); column boundaries come from the printed header words. Typed
# literals are anchors only (caption, header and note words). The publisher's
# vertical download watermark (x >= 578 pt) is excluded by an x limit taken from
# the header's right edge. Refuses to overwrite a frozen copy that differs.

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

suppressPackageStartupMessages({ library(pdftools); library(openxlsx); library(readxl) })

pdf_file <- "Varnas-2020-Autoradiographic mapping of synapt.pdf"
stopifnot(file.exists(pdf_file))
w <- as.data.frame(pdf_data(pdf_file, font_info = TRUE)[[4]])
w <- w[, c("x", "y", "width", "height", "text", "font_name")]

## ---- anchors -------------------------------------------------------------------
y_cap <- w$y[w$text == "TA" & grepl("Bold", w$font_name)]
stopifnot(length(y_cap) == 1L)
y_grp  <- w$y[w$text == "Non-human" & grepl("Bold", w$font_name) & w$y > y_cap][1]
y_hdr  <- w$y[w$text == "Brain" & grepl("Bold", w$font_name) & w$y > y_grp][1]
y_note <- w$y[w$text == "Note:" & w$y > y_hdr][1]
stopifnot(!is.na(y_grp), !is.na(y_hdr), !is.na(y_note))

## The page body (incl. the table) is set in Lato; the vertical download watermark
## is Times-Roman at the right margin. Keep Lato only, after checking that
## everything dropped is margin watermark.
is_lato <- grepl("Lato", w$font_name)
stopifnot(all(w$x[!is_lato & w$y > y_cap - 2 & w$y < y_note + 16] >= 570))
w <- w[is_lato, ]
hdr <- w[w$y >= y_grp - 1 & w$y <= y_hdr + 1, ]

join_words <- function(d) {          # join a set of words in reading order, gap-aware
  ## super/subscripts (smaller than body text) take the baseline of the word to
  ## their left, so they stay on that word's line
  body_h <- max(d$height)
  d$y_line <- d$y
  for (i in which(d$height < body_h - 1)) {
    left <- which(d$height >= body_h - 1 & d$x < d$x[i] & abs(d$y - d$y[i]) <= 6)
    if (length(left)) d$y_line[i] <- d$y[left[which.max(d$x[left])]]
  }
  d <- d[order(d$y_line, d$x), ]
  d$y <- d$y_line
  out <- d$text[1]
  for (i in seq_len(nrow(d))[-1]) {
    gap <- d$x[i] - (d$x[i - 1] + d$width[i - 1])
    out <- paste0(out, if (gap > 1.2 || d$y[i] - d$y[i - 1] > 6) " " else "", d$text[i])
  }
  out
}
caption <- join_words(w[abs(w$y - y_cap) <= 2, ])
caption <- sub("^TA ?B ?L ?E 1", "TABLE 1", caption)
stopifnot(identical(caption, paste0("TABLE 1 Binding of [11C]UCB-J to synaptic vesicle ",
                                    "glycoprotein 2A in non-human primate and human brain")))

## ---- column boundaries from header words ---------------------------------------
hx <- function(word) sort(hdr$x[hdr$text == word])
x_n <- hx("n"); x_spec <- hx("Specific"); x_ratio <- hx("Ratio")
stopifnot(length(x_n) == 2L, length(x_spec) == 2L, length(x_ratio) == 2L,
          hx("Non-human")[1] == x_n[1], hx("Human")[1] == x_n[2])   # spanners start over n
cuts <- c(-Inf, x_n[1], x_spec[1], x_ratio[1], x_n[2], x_spec[2], x_ratio[2]) - 5
cuts <- c(cuts, Inf)
group_row  <- c("", "Non-human primate", "", "", "Human", "", "")
header_row <- c("Brain region", "n", "Specific binding (kBq/mm\u00b2)", "Ratio region/white matter",
                "n", "Specific binding (kBq/mm\u00b2)", "Ratio region/white matter")
## printed header words must fall in their own column (superscript 2 aside)
tokens <- function(s) { t <- strsplit(gsub("[()/]", " ", s), "\\s+")[[1]]; t[nzchar(t)] }
hcol <- findInterval(hdr$x, cuts)
for (k in 1:7) {
  got <- paste(hdr$text[hcol == k & hdr$y >= y_hdr - 12 & hdr$text != "2"], collapse = " ")
  stopifnot(setequal(tokens(got), tokens(gsub("\u00b2", "", header_row[k]))))
}

## ---- body ----------------------------------------------------------------------
body <- w[w$y > y_hdr + 3 & w$y < y_note - 2, ]
ys <- sort(unique(body$y))
cells <- do.call(rbind, lapply(ys, function(yy) {
  b <- body[body$y == yy, ]; b <- b[order(b$x), ]
  col <- findInterval(b$x, cuts)
  vapply(1:7, function(k) paste(b$text[col == k], collapse = " "), character(1))
}))
stopifnot(nrow(cells) == 14L, all(nzchar(cells[, 1])),
          all(grepl("^[0-9]$", cells[, 5])),                         # every region has human n
          all(grepl("^$|^[0-9]$", cells[, 2])))
mr <- "^[0-9.]+( \\([0-9.]+\u2013[0-9.]+\\))?$"
for (k in c(3, 4, 6, 7)) stopifnot(all(cells[, k] == "" | grepl(mr, cells[, k])))

note_words <- w[w$y >= y_note - 1 & w$y <= y_note + 16, ]
note <- join_words(note_words)
note <- sub("kBq/mm2,", "kBq/mm\u00b2,", note, fixed = TRUE)
stopifnot(startsWith(note, "Note: Values are presented as mean (range) for specific binding"),
          endsWith(note, "relative to the white matter."))

snap <- rbind(c(caption, rep("", 6)), group_row, header_row, cells, c(note, rep("", 6)))
dimnames(snap) <- NULL

snap_file <- paste0(base, "_snapshot.xlsx")
if (file.exists(snap_file)) {
  old <- as.matrix(read_excel(snap_file, sheet = "Table1", col_names = FALSE, col_types = "text",
                              .name_repair = "minimal"))
  old[is.na(old)] <- ""; dimnames(old) <- NULL
  if (!identical(dim(old), dim(snap)) || !all(old == snap))
    stop(snap_file, " exists and differs from a fresh extraction - frozen copy NOT overwritten.")
  message(snap_file, ": frozen copy matches a fresh extraction (not rewritten)")
} else {
  wb <- createWorkbook()
  addWorksheet(wb, "Table1")
  writeData(wb, 1, as.data.frame(snap, stringsAsFactors = FALSE), colNames = FALSE)
  addStyle(wb, 1, createStyle(textDecoration = "bold"), rows = 1:3, cols = 1:7, gridExpand = TRUE)
  setColWidths(wb, 1, cols = 1:7, widths = c(18, 5, 22, 22, 5, 22, 22))
  saveWorkbook(wb, snap_file)
  message(snap_file, ": frozen snapshot written (", nrow(snap), " rows x 7 cols)")
}
