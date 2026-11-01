# Mink_etal_1981_TABLE1_extract_snapshot.R -----------------------------------
#
# Builds the frozen snapshot of Mink, Blumenschine & Adams (1981) TABLE 1
# ("Ratios of CNS metabolism to resting body metabolism", Am J Physiol
# 241: R208-R209, PDF pages 7-8).
#
# The source is a 1981 scanned journal page printed SIDEWAYS across two pages.
# Its text layer is OCR and is unreliable (it drops the whole Animal column and
# garbles digits), so the values here are a HAND TRANSCRIPTION read from
# 500-dpi page renders, per __HOWTO_make_a_snapshot.md method 5 / the
# Jacobs_etal_2018_extract_snapshot.R pattern: the printed layout is written
# out verbatim below, this script freezes it to .xlsx, and the build
# (Mink_etal_1981_TABLE1.R) READS that frozen file. No cleaning happens here.
#
# Fidelity decisions, all of them reversible from the frozen file:
#
#  * One snapshot row per PRINTED ROW. The printed table has 42 animal rows and
#    no blank or section rows: every vertical gap in the Animal column is
#    occupied by the second printed line of a neighbouring cell (a wrapped
#    species name, a two-line Body2 range, or the second Body metabolic-rate
#    value that footnote b defines). Counted from the page renders, page R208
#    carries 37 Animal-column text lines = 30 species + 7 wrapped names, and 9
#    continuation-only lines; page R209 carries 12 species. 30 + 12 = 42, which
#    is the 42 species the RESULTS section states.
#  * A cell printed on two lines is ONE cell holding a real newline, so the
#    snapshot row grid still matches the page line for line in Excel.
#  * Superscript footnote markers are written as a trailing "^<letter>"
#    (0.014^j for 0.014 with a superscript j). Reference numbers printed in
#    parentheses are kept as printed ("0.045 (56)").
#  * Column order and the two printed spanning headers are preserved, with
#    blank padding. Column H carries NO spanner on the page: the
#    "Metabolic Rate" rule stops after G and the "Metabolism, cm3 O2/min" rule
#    begins at I. That blank is reproduced, not repaired.
#  * The printed footnote block is kept as footnote rows below the table.
#
# Transcribed by an AI assistant (Claude) on 2026-10-31 from 500-dpi renders of
# PDF pages 7 and 8, read column by column at 2-3x zoom. The publisher's
# "Downloaded from ajpregu.physiology.org on July 13, 2009" watermark is
# overprinted along column H on both pages; the blue glyphs were suppressed by
# channel difference before reading, and the three cells still partly covered
# by black watermark glyphs are listed in the README.
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
item_name <- sub("_extract_snapshot\\.R$", "", basename(.sp))

suppressPackageStartupMessages(library(openxlsx))

## The printed sheet, one line per worksheet row, cells separated by "|",
## an empty field where the page (or the printed header tier) is blank.
## "\\n" inside a field is a printed line break WITHIN one cell.
printed <- "
TABLE 1. Ratios of CNS metabolism to resting body metabolism||||||||||||
|Weight, g||||Metabolic Rate, cm3 O2 . 100 g-1 . min-1||||Metabolism, cm3 O2/min|||
Animal|A|B|C|D|E|F|G|H|I|J|K|Metabolic Ratio^i
|Body1|Brain|Spinal|Body2^a|Body^b|Brain^c|Spinal^d|Body^e|Brain^f|Spinal^g|CNS^h|
Goldfish, Carassius\\nauratus|9.52 (20)|0.097 (20)|0.014^j|7–\\n140 (6)|0.44 (6)|2.77|2.77|0.042|0.0027|0.00039|0.0031|0.074
Toad, Bufo sp|44.50 (22)|0.073 (22)|0.0339^k|61 (75)|0.092 (75)\\n0.099|2.94|2.84|0.0441|0.0021|0.000963|0.0031|0.070
Frog (small), Rana pipiens|45.86 (56)|0.097 (56)|0.045 (56)|45 (21)|0.15 (21)|2.83|2.60 (82)|0.069|0.0027|0.0012|0.0039|0.057
Trout, Salvelinus\\nfontinalis|230.1 (20)|0.466 (20)|0.312 (1)|250 (5)|0.253 (5)|2.31|1.57|0.582|0.0108|0.00490|0.0157|0.0270
Bullfrog, Rana catesbiana|519.9 (20)|0.4625 (20)|0.368^m|350 (21)|0.072 (21)\\n0.065|2.31|1.52|0.338|0.0107|0.00560|0.0163|0.048
Turtle, Chrysemys sp|839.79 (56)|0.727 (56)|0.874 (56)|779 (33)|0.0677 (33)|2.18|1.24|0.5685|0.0158|0.0108|0.0266|0.0467
Shark, Squalus acanthias|4,200 (69)|3.87 (69)|2.71^n|2,600–\\n7,000 (81)|0.0802 (81)|1.75|0.84|3.37|0.0677|0.0227|0.0904|0.027
Alligator, Alligator\\nmississipiensis|52,400 (18)|7.23 (18)|20.08^o|52,000 (7)|0.012 (7)|1.69|0.59|6.29|0.122|0.118|0.240|0.038
Shrew, Sorex sp|5.3 (4)|0.11 (4)|0.022 (92)|3.6 (70)|17.67 (70)\\n16|9.7|9.7|0.85|0.011|0.0021|0.013|0.015
Mouse, Mus musculus|16.5 (52)|0.425 (52)|0.075 (52)|17.0 (70)|2.83 (70)|8.10|6.89|0.467|0.0344|0.0052|0.0396|0.0848
Swallow, Hirundo sp|18 (52)|0.535 (52)|0.08 (52)|18 (31)|6.39 (31)|7.86|6.60|1.15|0.042|0.0053|0.047|0.041
Bat, Desmodus sp|28.0 (20)|0.936 (20)|0.183^p|29.4 (75)|3.7 (75)|7.31|5.41|1.04|0.0684|0.00990|0.0784|0.0754
Sparrow, Passer\\ndomesticus|27 (52)|1.0 (52)|0.085 (52)|25.5 (40)|5.88 (40)|7.24|6.01|1.6|0.072|0.0051|0.077|0.048
Mole, Scalopus aquaticus|39.6 (20)|1.16 (20)|0.244 (92)|69.0 (70)|3.17 (70)\\n3.64|7.11|4.98|1.44|0.0825|0.0122|0.0947|0.0658
Rat, Rattus sp|278 (20)|2.3 (20)|0.83 (59)|280 (8)|1.32 (8)|7.6 (68)|4.41|3.67|0.17|0.037|0.21|0.057
Pigeon, Columba sp|326 (52)|1.79 (52)|0.575 (52)|300 (8)|1.45 (8)|6.72|4.10|4.73|0.120|0.0236|0.144|0.030
Crow, Corvus sp|337 (20)|9.3 (20)|0.82 (92)|640 (54)|1.79 (54)\\n2.11|5.6|3.25|7.11|0.52|0.027|0.55|0.077
Guinea pig, Cavia sp|649.44 (60)|4.0062 (60)|1.1249 (60)|624 (51)|1.00 (51)|6.048|3.387 (65)|6.50|0.2423|0.03810|0.2804|0.0431
Hedgehog, Erinaceus\\neuropaeus|747.8 (12)|3.8 (12)|1.1 (92)|684.0 (47)|1.22 (47)|6.1|3.4|9.12|0.23|0.037|0.27|0.030
Squirrel, Citellus sp|878 (20)|5.63 (20)|1.31^q|880 (86)|0.90 (86)|5.79|3.13|7.9|0.326|0.0410|0.367|0.046
Opossum, Didelphis sp|1,147 (20)|4.8 (20)|1.3^r|1,200 (26)|0.757 (26)|5.9|3.2|8.68|0.28|0.042|0.32|0.037
Chicken, Gallus\\ndomesticus|1,800 (52)|3.68 (52)|2.175 (52)|1,800 (8)|0.844 (8)|6.12|3.06|15.2|0.225|0.0666|0.292|0.0192
Marmot, Arctomys\\nmarmota|1,980 (52)|13.2 (52)|4.15 (52)|1,868 (47)|0.729 (47)|5.18|2.33|14.43|0.684|0.0967|0.781|0.0541
Rabbit, Oryctolagus sp|2,480.0 (61)|9.755 (61)|3.945 (61)|2,460 (62)|0.702 (62)|5.39|2.43|17.4|0.524|0.0959|0.620|0.0356
Cat, Felis domestica|2,673.13 (57)|27.56 (57)|7.96 (57)|3,000 (8)|0.733 (8)\\n0.754|4.5 (30)|1.8|20.2|1.2|0.143|1.3|0.064
Fox, Vulpes lagopus|3,385 (20)|44.50 (20)|7.35^s|4,000 (86)|0.846 (86)\\n0.882|4.42|1.81|29.9|1.97|0.133|2.1|0.070
Macaque, Macaca rhesus|3,627 (20)|93.1 (20)|6.52 (52)|3,700 (14)|0.765 (14)|3.7 (84)|1.55|27.8|3.4|0.101|3.5|0.13
Baboon, Papio papio|6,619 (80)|147 (80)|10.3^t|6,760 (14)|0.670 (14)|3.79|1.48|44.3|5.57|0.152|5.72|0.129
Dog, Canis familiaris|10,784 (56)|78.07 (56)|12.89 (56)|10,300 (8)|0.597 (8)|3.4 (32)|1.3|64.4|2.65|0.17|2.8|0.043
Orangutan, Pongo sp|21,000 (52)|316 (52)|9.5 (52)|16,200 (14)|0.515 (14)\\n0.482|3.43|1.34|101|10.8|0.13|10.9|0.11
Chimpanzee, Pan sp|25,850 (20)|430.5 (20)|12.9^u|24,500 (14)|0.419 (14)|3.29|1.22|108|14.2|0.157|14.4|0.133
Seal, Phoca sp|39,680 (20)|255 (20)|12.8 (92)|29,000 (43)|0.913 (43)\\n0.84|3.52|1.30|333|8.98|0.166|9.15|0.0275
Sheep, Ovis sp|40,230 (20)|108.8 (20)|32 (52)|40,000 (8)|0.370 (8)|3.94|1.3|149|4.29|0.42|4.71|0.0316
Pig, Sus scrofa|51,500 (53)|100.0 (53)|29.4^v|50,000 (13)|0.428 (13)|3.98|1.31|220|3.98|0.385|4.37|0.0199
Human, Homo sapiens|54,333 (52)|1,273.7 (52)|29.7 (52)|54,000 (8)|0.383 (8)|3.3 (50)|1.1|208|42|0.37|42|0.20
Dolphin, Tursiops\\ntruncatus|120,000 (79)|1,296 (79)|36 (79)|170,000 (42)|0.588 (42)\\n0.642|2.85|0.903|770|36.94|0.33|37.2|0.048
Ostrich, Struthio camelus|123,000 (20)|42.11 (20)|69.9^w|100,000 (54)|0.333 (54)\\n0.316|4.45|1.29|389|1.87|0.902|2.77|0.00712
Camel, Camelus sp|453,590 (20)|569.5 (20)|227.8^x|407,000 (85)|0.1654 (85)\\n0.161|3.175|0.762|730|18.08|1.736|19.82|0.0272
Cattle, Bos sp|506,000 (20)|420 (20)|168^x|500,000 (8)|0.174 (8)|3.30|0.83 (37)|880|13.9|1.4|15.3|0.0174
Horse, Equus caballus|548,870 (76)|650 (76)|260 (52)|587,000 (8)|0.246 (8)|3.12|0.72|1,350|20.3|1.9|22.2|0.0164
Elephant, Elephas sp|3,048,000 (15)|4,717 (15)|NA^y|3,672,000 (8)|0.193 (8)\\n0.202|2.41|NA^y|6,160|114|10.3^y|124|0.0201
Whale, Balaenoptera\\nphysalus|48,000,000 (73)|8,100 (73)|188.9 (89)|31,000,000 (46)|0.098 (46)\\n0.071|2.25|0.54|34,000|182|1.02|183|0.0054
Nos. in parentheses are reference nos. CNS, central nervous system.||||||||||||
a Body1 weight is for animal from whom CNS weight was determined. Body2 weight is for animal from whom body metabolic rate was determined. If body1 weight and body2 weight differ by more than 10%, the expected metabolic rate for an animal of body1 weight is calculated as explained in footnote b and is used in column H.||||||||||||
b Metabolic rate conversion: when two body metabolic rate values appear, the bottom value (corresponding to body1 weight) will be used in all later calculations, and it is calculated from the top metabolic rate (corresponding to body2 weight) according to log BM2 - log BM1 = 0.75 (log BW2 - log BW1) where BM is body metabolism and BW is body weight (Eq. 5). When necessary metabolic values are converted from calories to cubic centimeters of O2 according to: 4.8 cal = 1 cm3 O2; when converted from grams of O2 to cubic centimeters of O2: 1.32 mg O2 = 1 cm3 O2.||||||||||||
c Direct determinations are used where available, in which case the source is footnoted. Indirect determinations for cold-blooded vertebrates are derived from Eq. 3: log brain metabolic rate = 0.32 - 0.13 log brain weight. Indirect determinations for warm-blooded vertebrates are derived from Eq. 1: log brain metabolic rate = 0.86 - 0.13 log brain weight.||||||||||||
d Direct determinations are used where available, in which case the source is footnoted. Indirect determinations are derived from Eq. 4: log spinal metabolic rate - log brain metabolic rate = -0.25 - 0.16 log spinal cord weight.||||||||||||
e Body metabolism (H) calculated as E x A/100. In this figure, as well as in the figure calculated for I and J, the number of significant digits is determined as follows. If the number of significant digits in the two figures substituted into the equation are the same, then the same number of significant digits are used in H, I, and J. If they are different, then the number of digits used in H, I, or J is one greater than the smallest number of significant digits in any figure substituted into the equation.||||||||||||
f Brain metabolism (I) calculated as F x B/100.||||||||||||
g Spinal cord metabolism (J) calculated as G x C/100.||||||||||||
h Central nervous system metabolism (K) calculated as I + J.||||||||||||
i Metabolic ratio calculated as K/H. In this figure, the number of significant digits is limited to the smallest number of significant digits in any figure substituted into the equations used to calculate H, I, and J, with the exception that it is not limited by figures used to calculate J when J is an order of magnitude smaller than I.||||||||||||
j Based on direct observation of Carassius auratus. Spinal cord weight was found to be 14% of brain weight.||||||||||||
k Extrapolated from brain-to-spinal cord weight ratio of Rana pipiens [Latimer (56)].||||||||||||
l Based on direct observation of Perca flavescens. Spinal cord weight was found to be 67% of brain weight.||||||||||||
m Based on direct observation of Rana catesbiana. Spinal cord weight was found to be 79.6% of brain weight.||||||||||||
n Based on direct observation of Squalus acanthias. Spinal cord weight was found to be 70% of brain weight.||||||||||||
o Extrapolated from the brain-to-spinal cord volume ratio of Alligator mississipiensis (77).||||||||||||
p Extrapolated from the brain-to-spinal cord weight ratio of Vespertilio serotinus (92).||||||||||||
q Extrapolated from brain-to-spinal cord weight ratio of Sciurus vulgaris (92).||||||||||||
r Extrapolated from brain-to-spinal cord weight ratio of Cavia porcellus (60).||||||||||||
s Extrapolated from average brain-to-spinal cord weight ratio of Canis familiaris (52).||||||||||||
t Extrapolated from brain-to-spinal cord weight ratio of Macaca sinicus (52).||||||||||||
u Extrapolated from brain-to-spinal cord weight ratio of Homo sapiens (52).||||||||||||
v Extrapolated from brain-to-spinal cord weight ratio of Ovis aries (52).||||||||||||
w Extrapolated from brain-to-spinal cord weight ratio of Dromaeus novae-hollandiae (35).||||||||||||
x Extrapolated from brain-to-spinal cord weight ratio of Equus caballus (52).||||||||||||
y Estimated spinal cord metabolism of Elephas extrapolated from spinal cord-to-brain metabolic ratio in other large mammals (see METHODS).||||||||||||
"

NCOL <- 13L

grid <- do.call(rbind, lapply(
  strsplit(trimws(printed, which = "both"), "\n", fixed = TRUE)[[1]],
  function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- NCOL
    x
  }))
grid[] <- gsub("\\n", "\n", grid, fixed = TRUE)
grid[!is.na(grid) & grid == ""] <- NA_character_

## Structural guards: 4 header rows + 42 printed animal rows + 26 footnote rows.
stopifnot(ncol(grid) == NCOL, nrow(grid) == 4L + 42L + 26L)
data_rows <- 5:46
stopifnot(all(nzchar(grid[data_rows, 1])), !any(is.na(grid[data_rows, 13])))
stopifnot(identical(grid[3, 2:12], c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K")))

snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))

wb <- createWorkbook()
addWorksheet(wb, "TABLE1")
writeData(wb, "TABLE1", as.data.frame(grid, stringsAsFactors = FALSE),
          colNames = FALSE, keepNA = FALSE)
addStyle(wb, "TABLE1", createStyle(textDecoration = "bold", wrapText = TRUE),
         rows = 1:4, cols = seq_len(NCOL), gridExpand = TRUE)
addStyle(wb, "TABLE1", createStyle(wrapText = TRUE, valign = "top"),
         rows = data_rows, cols = seq_len(NCOL), gridExpand = TRUE)
addStyle(wb, "TABLE1", createStyle(wrapText = TRUE, valign = "top"),
         rows = 47:nrow(grid), cols = 1, gridExpand = TRUE)
setColWidths(wb, "TABLE1", cols = 1, widths = 30)
setColWidths(wb, "TABLE1", cols = 2:NCOL, widths = 16)

## Refuse to silently overwrite a frozen copy that differs: a snapshot is
## evidence, and a changed value must be a deliberate, reviewed edit.
if (file.exists(snapshot_file)) {
  old <- as.matrix(readxl::read_excel(snapshot_file, sheet = "TABLE1",
                                      col_names = FALSE, .name_repair = "minimal"))
  new <- grid
  dimnames(old) <- NULL; dimnames(new) <- NULL
  old[is.na(old)] <- ""; new[is.na(new)] <- ""
  if (!identical(dim(old), dim(new)) || !identical(unname(old), unname(new))) {
    stop(item_name, ": the frozen snapshot on disk differs from the block in this ",
         "script. Refusing to overwrite. Reconcile the difference against the PDF ",
         "and move the superseded file to archive/ before re-running.", call. = FALSE)
  }
  message(item_name, ": frozen snapshot already on disk and identical; nothing written.")
} else {
  saveWorkbook(wb, snapshot_file, overwrite = FALSE)
  message(item_name, ": wrote ", basename(snapshot_file), " (",
          nrow(grid), " rows x ", NCOL, " cols; 42 printed animal rows)")
}
