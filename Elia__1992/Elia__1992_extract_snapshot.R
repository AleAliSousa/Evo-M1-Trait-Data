# Elia__1992_extract_snapshot.R ----------------------------------------------------
#
# Freezes the two printed tables of
#   Elia, M. (1992). Organ and tissue contribution to metabolic rate. In J. M. Kinney &
#   H. N. Tucker (Eds.), Energy Metabolism: Tissue Determinants and Cellular Corollaries
#   (pp. 61-77 in the PDF held; the chapter runs to p. 79/80 in other citations). New York: Raven Press.
#
#   Elia__1992_TABLE1_snapshot.csv   TABLE 1, p. 63 (PDF page 3; the page is scanned sideways)
#   Elia__1992_TABLE3_snapshot.csv   TABLE 3, p. 66 (PDF page 6)
#
# The source is a photocopy scan whose OCR text layer is garbled (digits and column
# structure unusable), so it was NOT used. The values below are a HAND TRANSCRIPTION
# read from 200/300/400/500/700/800-dpi renders of PDF pages 3 and 6 (__HOWTO_make_a_snapshot.md
# method 5, printed-layout-block pattern as Mink_etal_1981_TABLE1_extract_snapshot.R).
# A first, independent transcription made earlier in
# Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations
# (elia_1992_table3_transcribed.csv and the Elia rows of classic_human_brain_partition.csv)
# was compared with this one only AFTER this one was typed (see the README, 'Re-verification').
# This script writes the frozen files and refuses to overwrite a frozen copy that differs.
# The build scripts READ those files; no cleaning happens here.
#
# Fidelity decisions:
#  * One snapshot row per printed row; header tiers kept (blank padding under spanning
#    headers); a printed line break inside one cell is a real newline in the frozen file.
#    Footnote marks are written ^x (superscripts a, b, c; x in 'body weight^x' is the exponent
#    symbol of the caption, not a footnote).
#  * The printed hyphen/en dash in ranges and compounds ("7-9", "25-32%", "female-see ... ref. 2-and")
#    is written as ASCII "-"; all words, including the printed "timed" (sic, footnote b of TABLE 1),
#    are kept as read.
#  * TABLE 1 is on a scan page set sideways with a publisher overprint, and two scan highlights
#    (yellow, brain % body weight 2.00 / 2.07 and brain metabolic rate % 20 / 21) are the
#    reader's marks, not print; they are ignored.
#  * TABLE 3: the right edge of the scan cuts the last column. Cells that are cut are written
#    with the visible glyphs followed by [cut]: header "All orga" (organs), "39.[cut]" and "17.[cut]"
#    (guinea pig, rat, all organs minus lung), the K x W^x entry "0.448W^[cut]" and the correlation
#    "0.[cut]". The visible integer digits are NOT completed from arithmetic.
#  * The printed gap between the rat row and the KW row is kept as an empty row.
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

printed_TABLE1 <- r"---(
TABLE 1||||||||||
Contribution of different organs and tissues to body weight and basal metabolic rate in the reference male, reference female, and a child||||||||||
|Tissue or organ weight (kg)^a|||Tissue or organ weight\n(% body weight)|||Organ\nmetabolic\nrate (kcal/kg/\nday)|Metabolic rate (% total)^b||
|Reference\nmale|Reference\nfemale|Child\n(0.5 y)|Reference\nmale|Reference\nfemale|Child\n(0.5 y)||Reference\nmale|Reference\nfemale|Child\n(0.5 y)
Liver^c|1.8|1.4|0.263|2.57|2.41|3.51|200|21|21|14
Brain|1.4|1.2|0.713|2.00|2.07|9.51|240|20|21|44
Heart|0.33|0.24|0.040|0.47|0.41|0.53|440|9|8|4
Kidneys|0.31|0.275|0.053|0.44|0.47|0.71|440|8|9|6
Muscle|28.00|17.00|1.875|40.00|29.31|25.00|13|22|16|6
Adipose tissue|15.00|19.00|1.50|21.43|32.75|20.00|4.5|4|6|2
Miscellaneous\ntissues by\ndifference (e.g.,\nbone, skin,\nintestines,\nglands)|23.16|18.885|3.056|33.09|32.58|40.74|12|16|19|24
Total|70.00|58|7.5|100|100|100||100\n(1680 kcal/\nday)|100\n(1340 kcal/\nday)|100\n(390 kcal/\nday)
^a Tissue and organ weights for the reference male and reference female were taken from reference 2. Those for the 0.5-year-old child are consistent with results given by various authors (2, 7-9).||||||||||
^b The metabolic rates for the reference male (1,680 kcal/day) and reference female (1,340 kcal/day) are close to the mean values obtained by various standards for 30-year-old adults with a body mass index of 22.5 kg/m². The metabolic rate for the 0.5-year-old child (390 kcal/day) is close to the mean value timed by various standards for a male child with a weight of 7.5 kg and height of 0.65 m. If metabolic rate is expressed in relation to body weight, the values are 24.0, 23.3, and 52.0 kcal/day for reference male, reference female, and child, respectively. If metabolic rate is expressed in relation to fat-free mass (56.5 kg for the reference male, 42.0 kg for reference female-see reference man, ref. 2-and 6.1 kg for child) the values are 29.7, 31.9, and 63.9 kcal/kg fat-free mass/day, respectively.||||||||||
^c Several workers have estimated that the "liver" is responsible for 25-32% of adult BMR (see 10-13). These values are probably overestimates, since they were usually calculated from the O2 consumption of liver plus portal drained viscera.||||||||||
)---"

printed_TABLE3 <- r"---(
TABLE 3||||||||
Relation of organ weight to body weight (organ weight = K × body weight^x) in\napproximately mature mammals^a||||||||
|Live\nweight\n(g)|Liver\n(g)|Kidneys\n(g)|Brain\n(g)|Heart\n(g)|Lung\n(g)|All 5\norgans\n(g)|All orga\nminus\nlung\n(g)
Elephant|6,650,000|6,300|1,200|5,700|2,200|(6,650)|22,050|15,400
Steer|700,000|5,000|1,000|500|2,300|3,900|12,700|8,800
Horse|600,000|6,700|1,600|670|4,250|5,400|13,220|18,620
Dairy cow|488,000|6,460|1,160|400|1,880|3,600|13,440|9,840
Hog|125,000|1,600|260|120|350|1,300|3,530|2,230
Human|60,000|1,700|250|1,300|320|1,000|4,570|3,570
Sheep|52,000|960|160|106|280|710|2,216|1,506
Dog|10,000|420|70|75|85|120|770|650
Monkey|4,500|110|21|42|23|30|226|196
Guinea pig|800|27|5.6|4.7|2.3|5.0|44.6|39.[cut]
Rat|250|12|2.1|2.0|0.94|1.3|18.34|17.[cut]
||||||||
KW^x,b||0.39W^0.70|0.066W^0.71|0.76W^0.71|0.03W^0.88|0.016W^0.92|0.406W^0.77|0.448W^[cut]
Correlation\ncoefficient||0.97|0.97|0.94|0.96|0.97|0.97|0.[cut]
^a Calculated using data from Brody (17).||||||||
^b K, constant; W, body weight in grams; x, exponent.||||||||
)---"

write_frozen(printed_TABLE1, file.path(folder, paste0(paper, "_TABLE1_snapshot.csv")), 11L)
write_frozen(printed_TABLE3, file.path(folder, paste0(paper, "_TABLE3_snapshot.csv")), 9L)
