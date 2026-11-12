# Poulsen_etal_1997_Table2_snapshot.R ---------------------------------------
#
# Builds the frozen snapshot of Poulsen, Smith, Ostergaard, Danielsen, Gee,
# Hansen, Astrup & Gjedde (1997) "In vivo estimation of cerebral blood flow,
# oxygen consumption and glucose metabolism in the pig by [15O]water
# injection, [15O]oxygen inhalation and dual injections of
# [18F]fluorodeoxyglucose", J Neurosci Methods 77: 199-209.
# doi:10.1016/S0165-0270(97)00127-1
#
#   Poulsen_etal_1997_Table2_snapshot.csv   Table 2, p. 205 (PDF page 7)
#
# The PDF has a text layer, but it scrambles both tables (Table 1's eight
# columns come out in the order Pglc, Tp, Hgb, O2 headers, then values in a
# different order; Table 2's cells are interleaved with its headers) and it
# renders every "±" as "9" ("171918" for 171 ± 18). Nothing was taken from it.
# The values below are a HAND TRANSCRIPTION read from 300/400-dpi renders of
# PDF pages 1, 2, 5, 7 and 8 (__HOWTO_make_a_snapshot.md method 5; the
# Mink_etal_1981 / Kennedy_etal_1978 printed-layout-block pattern). This
# script writes the frozen file and REFUSES TO OVERWRITE a frozen copy that
# differs; the build script Poulsen_etal_1997_Table2.R READS it. No cleaning happens here.
#
# Fidelity decisions:
#  * One snapshot row per printed line. Table 2's Hemisphere row prints two
#    lines in the CMRglc columns ("Multilinear: 27 (3)" over "Graphical:
#    23 (4)", and "27 (3)" over "24 (3)"), so it is two snapshot rows, the
#    second with a blank row label, exactly as on the page.
#  * Caption and the Table 1 abbreviation footnote are kept as rows.
#  * Subscripts/superscripts are flattened to plain text: CMRO2, CMRglc,
#    PaO2, PaCO2, Tp, Pglc, cm^3, min^-1, 1^st, 2^nd. Units are kept exactly
#    as printed in the headers (ml/100 cm^3/min, µmol/100 cm^3/min, mM, kPa).
#  * The table's own "x (y)" notation (mean, SD in brackets) is kept verbatim.
#
# Transcribed by an AI assistant (Claude) on 2026-11-11 from page renders.
# ---------------------------------------------------------------------------

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
folder <- dirname(.sp)
paper  <- basename(folder)
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Poulsen_etal_1997_Table2

## ---- Table 2, p. 205 ---------------------------------------------------------
printed_Table2 <- "
Table 2|||||
Blood flow and metabolism: average (standard deviation in brackets (n = 7))|||||
|CBF (ml/100 cm^3/min)|CMRO2 (µmol/100 cm^3/min)|(1^st) CMRglc (µmol/100 cm^3/min)|(2^nd) CMRglc (µmol/100 cm^3/min)|PaCO2 (kPa)
Hemisphere|37 (4)|171 (18)|Multilinear: 27 (3)|27 (3)|4.3 (0.9)
|||Graphical:   23 (4)|24 (3)|
Basal Ganglia|45 (7)|186 (34)|Multilinear: 35 (7)||
"

block_to_matrix <- function(txt) {
  lines <- strsplit(sub("^\n", "", sub("\n$", "", txt)), "\n", fixed = TRUE)[[1]]
  cells <- strsplit(lines, "|", fixed = TRUE)
  k <- max(lengths(cells), lengths(regmatches(lines, gregexpr("|", lines, fixed = TRUE))) + 1L)
  do.call(rbind, lapply(seq_along(cells), function(i) {
    x <- cells[[i]]
    n_sep <- lengths(regmatches(lines[i], gregexpr("|", lines[i], fixed = TRUE)))
    x <- c(x, rep("", n_sep + 1L - length(x)))      # trailing empty cells
    c(x, rep("", k - length(x)))
  }))
}

freeze <- function(m, file, header = FALSE) {
  tmp <- tempfile(fileext = ".csv")
  if (header) {
    df <- as.data.frame(m[-1, , drop = FALSE], stringsAsFactors = FALSE)
    names(df) <- m[1, ]
    write.csv(df, tmp, row.names = FALSE, fileEncoding = "UTF-8")
  } else {
    write.table(m, tmp, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
  }
  if (file.exists(file)) {
    if (identical(readLines(file, encoding = "UTF-8"), readLines(tmp, encoding = "UTF-8"))) {
      message(basename(file), ": frozen copy identical - unchanged")
      return(invisible(FALSE))
    }
    stop(basename(file), " already exists and DIFFERS from this script's transcription. ",
         "The frozen snapshot is not overwritten. Fix a transcription error deliberately ",
         "(delete the old file by hand, record an errata row) and re-run.", call. = FALSE)
  }
  file.copy(tmp, file)
  message(basename(file), ": frozen (", nrow(m), " rows x ", ncol(m), " cols)")
  invisible(TRUE)
}
t2 <- block_to_matrix(printed_Table2); stopifnot(identical(dim(t2), c(6L, 6L)))

freeze(t2, file.path(folder, paste0(item_name, "_snapshot.csv")))
