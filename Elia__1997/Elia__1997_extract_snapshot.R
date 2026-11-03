# Elia__1997_extract_snapshot.R ----------------------------------------------------
#
# Freezes TABLE 8 of
#   Elia, M. (1997). Tissue distribution and energetics in weight loss and undernutrition.
#   In J. M. Kinney & H. N. Tucker (Eds.), Physiology, Stress, and Malnutrition: Functional
#   Correlates, Nutritional Intervention (pp. 383-411). Philadelphia: Lippincott-Raven.
#
#   Elia__1997_TABLE8_snapshot.csv   TABLE 8, p. 401 (PDF page 19; the page is scanned landscape)
#
# TABLE 8 is a MODEL calculation (it assumes a normal-brain rate of 225 kcal/kg/day and a range of
# values for marasmic infants), not a measurement. Other tables of the chapter (TABLE 3 and 4, % loss of
# organ weights; TABLE 7, brain O2 consumption in starvation) are not organ partitions and were not built.
#
# The source is a British Library photocopy; its OCR text layer is garbled (the table region is
# unreadable), so it was NOT used. The values are a HAND TRANSCRIPTION read from 110/300-dpi renders
# of PDF page 19 (method 5, printed-layout block). This script writes the frozen file and refuses to
# overwrite a frozen copy that differs. The build script READS it; no cleaning happens here.
#
# Fidelity decisions:
#  * One snapshot row per printed LINE. TABLE 8 prints several lines per scenario: the marasmic
#    scenarios print 3 resp. 2 alternative brain-rate assumptions stacked under each other (brain
#    kcal/kg/day, brain kcal/day, FFM-brain kcal/day and kcal/kg/day move together line by line);
#    row labels wrap over lines ("Marasmus / (before treatment) / (12 months)"), and are kept as
#    printed on those lines.
#  * The three weight footnote marks print as small superscript '+' glyphs ("+", "++", "+++" in the
#    footnote legend); written ^+, ^++, ^+++. The table prints NO unit over the weight columns
#    (body weights of 10, 5 and 6 and the brain 0.9/0.8 identify them as kg).
#  * Typographic minus signs inside the percentage changes are written as ASCII "-"; the printed
#    en dash in "FFM - brain" headings is kept ("FFM – brain") in the title and spanners.
#  * The unlettered paragraph under the table (starting "These calculations assume ...") and
#    the lettered footnote ^a are kept as footnote rows.
#
# Transcribed by an AI assistant (Claude) on 2026-11-03 from page renders.
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
if (!isTRUE(l10n_info()[["UTF-8"]])) stop("Run in a UTF-8 locale (e.g. LC_ALL=en_US.UTF-8); non-ASCII glyphs would be mangled.", call. = FALSE)
folder <- dirname(.sp)
paper  <- basename(folder)

write_frozen <- function(block, file, ncol) {
  block <- sub("\n+$", "", block)
  x <- read.table(text = trimws(block, "left"), sep = "|", quote = "", comment.char = "", header = FALSE,
                  colClasses = "character", na.strings = character(0), fill = TRUE, strip.white = FALSE,
                  blank.lines.skip = FALSE, encoding = "UTF-8", check.names = FALSE)
  x <- as.matrix(x); dimnames(x) <- NULL
  stopifnot(ncol(x) == ncol)
  x <- gsub("\\n", "\n", x, fixed = TRUE)
  tmp <- tempfile(fileext = ".csv")
  write.table(x, tmp, sep = ",", row.names = FALSE, col.names = FALSE, qmethod = "double", na = "", fileEncoding = "UTF-8")
  new <- readLines(tmp, encoding = "UTF-8", warn = FALSE)
  if (file.exists(file) && file.size(file) > 0) {
    old <- readLines(file, encoding = "UTF-8", warn = FALSE)
    if (!identical(old, new)) stop("A DIFFERENT frozen snapshot already exists: ", file, "; refusing to overwrite.", call. = FALSE)
    message(basename(file), ": frozen copy identical (", nrow(x), " rows x ", ncol(x), " cols); left untouched")
  } else {
    file.copy(tmp, file, overwrite = TRUE)
    message(basename(file), ": frozen (", nrow(x), " rows x ", ncol(x), " cols)")
  }
}

printed_TABLE8 <- r"---(
TABLE 8||||||||||
Energy expenditure of the whole body, FFM brain, and FFM (FFM – brain) other than brain of a normal child and a marasmic child before nutritional therapy and at peak hypermetabolism during recovery^a||||||||||
|||||Metabolic rate|||||
|Weight||||Body||Brain||FFM – brain|
|Body|FFM|Brain|FFM – brain|kcal/day|kcal/kg/day|kcal/kg/day|kcal/day\n[(7) • (3)]|kcal/day\n[(5) - (8)]|kcal/kg/day\n[(9) ÷ (4)]
Normal|10^+|8|0.9|7.1|550|55|225|202.5|347.5|48.9
(12 months)||||||||||
Marasmus|5^++|4.5|0.8|3.7|302.5 (-45%)|60.5 (+10%)|225 (0%)|180 (-11%)|122.5 (-65%)|33.1 (-32%)
(before treatment)|||||||202.5 (-10%)|162 (-20%)|140.5 (-60%)|38.0 (-22%)
(12 months)|||||||180 (-20%)|144 (-29%)|158.5 (-54%)|42.8 (-12%)
Marasmus (during|6^+++|5.25|0.8|4.45|450 (-18%)|75.0 (+36%)|225 (0%)|180 (-11%)|270 (-22%)|60.7 (+24%)
treatment at peak|||||||270 (+30%)|216 (+7%)|234 (-33%)|52.6 (+8%)
hypermetabolism)||||||||||
(12 months)||||||||||
These calculations assume that FFM is responsible for all the metabolic rate of the body, which is not entirely true, partly because adipose tissue makes a small contribution to BMR (probably ~3% in children) and partly because some fat is present in organs such as the brain. Similar trends exist even if correlations are made for minor changes in hydration status (see text and Table 2).||||||||||
^a The calculations assume that the metabolic rate of normal brain is 225 kcal/kg/day. A range of values are assumed for the marasmic infants. +, 20% fat; ++, 10% fat; +++, 12.5% fat.||||||||||
)---"

write_frozen(printed_TABLE8, file.path(folder, paste0(paper, "_TABLE8_snapshot.csv")), 11L)
