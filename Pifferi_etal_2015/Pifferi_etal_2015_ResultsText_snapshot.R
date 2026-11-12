# Pifferi_etal_2015_ResultsText_snapshot.R ---------------------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of the values Pifferi et al. (2015)
# print only in running text:
#   Pifferi, Dorieux, Castellano, Croteau, Masson, Guillermier, Van Camp,
#   Guesnet, Alessandri, Cunnane, Dhenain & Aujard (2015) "Long-chain n-3
#   PUFAs from fish oil enhance resting state brain glucose utilization and
#   reduce anxiety in an adult nonhuman primate, the grey mouse lemur",
#   J Lipid Res 56: 1511-1518. doi:10.1194/jlr.M058933
#
#   Pifferi_etal_2015_ResultsText_snapshot.csv
#       RESULTS, "Brain glucose uptake and metabolism", p. 1515 (PDF page 5),
#       right column: the SUVmax sentence (values plotted as curves in Fig. 3)
#       and the CMRglu sentence (values plotted as box plots in Fig. 4).
#       One row per printed clause "<region>, <control> versus <n-3>", in
#       printed order, with the printed lexemes untouched.
#
# The PDF is born-digital (typeset) and its text layer is clean, so the values
# are pulled from the text layer AT RUN TIME (HOWTO method 3, the
# Jacob_etal_2021 pattern): no value is typed in this script. Only the two
# sentence frames are anchored as printed literals. The subscripts "max" and
# "glu" are displaced by the text layer ("SUV , in g/ml) were max",
# "CMR values glu") and are matched as such; the "~" before "30%" is a
# private-use glyph and is outside the captured spans.
# Every captured value was checked against a 300-dpi render of the page
# (AI assistant (Claude), 2026-11-11).
# The script refuses to overwrite a frozen copy that differs.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))
suppressPackageStartupMessages(library(pdftools))

pdf_file <- file.path(folder, "Pifferi-2015-Long-chain n-3 PUFAs from fish oi.pdf")
stopifnot(file.exists(pdf_file))

## ---- page 5 (journal p. 1515), right column, Results section -----------------
w <- pdf_data(pdf_file)[[5]]
w <- w[w$x >= 315 & w$y >= 195 & w$y <= 575, ]          # right column, the subsection
w <- w[order(w$y, w$x), ]
w$line <- cumsum(c(1, diff(w$y) > 3))
lines <- tapply(seq_len(nrow(w)), w$line, function(i) paste(w$text[i][order(w$x[i])], collapse = " "))
txt <- paste(lines, collapse = " ")
stopifnot(startsWith(txt, "Brain glucose uptake and metabolism "))

grab <- function(start, end) {
  s <- regexpr(start, txt, fixed = TRUE); stopifnot(s > 0)
  rest <- substring(txt, s + attr(s, "match.length"))
  e <- regexpr(end, rest, fixed = TRUE); stopifnot(e > 0)
  substring(rest, 1, e - 1)
}
## printed sentence frames (anchored literals, as the text layer renders them)
suv_frame <- c(start = "Maximal SUVs (SUV , in g/ml) were max the following (control vs. n-3): ",
               end   = "). In addition, no signifi cant difference in SUVs")
cmr_frame <- c(start = "CMR values glu (\u00b5mol/min/100 g) in the different brain regions were the following ( Fig. 4 ) (control vs. n-3): ",
               end   = "). In addition, no signifi cant differences of CMR")

clauses <- function(span) {
  cl <- strsplit(span, "; ", fixed = TRUE)[[1]]
  region <- sub(",.*$", "", cl)
  vals   <- sub("^[^,]*, ", "", cl)
  ctrl   <- sub(" versus .*$", "", vals)                 # first "versus" separates the groups
  n3     <- sub("^.*? versus ", "", vals, perl = TRUE)
  data.frame(region_as_printed = region, control_printed = ctrl, n3_printed = n3,
             clause_as_printed = cl, stringsAsFactors = FALSE)
}
suv <- clauses(grab(suv_frame[["start"]], suv_frame[["end"]]))
cmr <- clauses(grab(cmr_frame[["start"]], cmr_frame[["end"]]))
stopifnot(nrow(suv) == 8L, nrow(cmr) == 8L)

snap <- rbind(
  data.frame(page = "1515", location = "RESULTS, Brain glucose uptake and metabolism, right column, 1st paragraph",
             measure_as_printed = "Maximal SUVs (SUVmax, in g/ml)", units_as_printed = "g/ml",
             figure_cited = "Fig. 3", groups_as_printed = "control vs. n-3", suv,
             stringsAsFactors = FALSE),
  data.frame(page = "1515", location = "RESULTS, Brain glucose uptake and metabolism, right column, 2nd paragraph",
             measure_as_printed = "CMRglu values (\u00b5mol/min/100 g)", units_as_printed = "\u00b5mol/min/100 g",
             figure_cited = "Fig. 4", groups_as_printed = "control vs. n-3", cmr,
             stringsAsFactors = FALSE))
snap <- cbind(text_row = seq_len(nrow(snap)), snap)

## ---- freeze -------------------------------------------------------------------
out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
tmp <- tempfile(fileext = ".csv")
write.csv(snap, tmp, row.names = FALSE, fileEncoding = "UTF-8")
if (file.exists(out)) {
  if (identical(readLines(out, encoding = "UTF-8"), readLines(tmp, encoding = "UTF-8"))) {
    message(basename(out), ": frozen copy identical - unchanged")
  } else stop(basename(out), " already exists and DIFFERS from the PDF text layer extraction. ",
              "The frozen snapshot is not overwritten.", call. = FALSE)
} else {
  file.copy(tmp, out)
  message(basename(out), ": frozen (", nrow(snap), " rows x ", ncol(snap), " cols)")
}
