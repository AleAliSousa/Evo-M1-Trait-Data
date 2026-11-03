# Schmidt_etal_1945_extract_snapshot.R -----------------------------------------------------
#
# Freezes the snapshots of Schmidt, C. F., Kety, S. S., & Pennes, H. H. (1945). The gaseous metabolism of the brain of the monkey. American Journal of Physiology, 143(1), 33-52.
# DOI 10.1152/ajplegacy.1945.143.1.33. Source PDF: schmidt_etal_1945.pdf (journal pp. 33-52 (PDF pages 1-20)).
#
# Source: OCR text layer, unusable for tables (TABLE 4 is printed sideways); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_extract_snapshot.R
# pattern); this script freezes each block to <paper>_<locus>_snapshot.csv and the
# item build scripts READ those frozen files. No cleaning happens here.
#
# Fidelity conventions: one snapshot row per printed row (caption, header tiers,
# section rows, footnotes included); blank padding under spanning headers;
# a cell printed on two lines is one cell holding a newline; superscript footnote
# letters are written ^a; asterisks, daggers and parenthesised numbers as printed;
# subscripts are written inline (CMRO2, Paco2); a printed superscript that is a
# typesetting slip is kept (^2).
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders at
# 300 and 500 dpi, read at 2-5x zoom; verified by re-reading every row across
# against fresh crops after the tables' own arithmetic was run (see README).
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


## Parse a printed block: one line per printed row, cells separated by "|";
## "\\n" inside a field is a printed line break within one cell.
as_grid <- function(block, ncol) {
  lines <- strsplit(sub("^\n", "", sub("\n$", "", block)), "\n", fixed = TRUE)[[1]]
  g <- do.call(rbind, lapply(lines, function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    if (length(x) > ncol) stop("row has more than ", ncol, " cells: ", line, call. = FALSE)
    length(x) <- ncol; x[is.na(x)] <- ""; x }))
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
  Encoding(g) <- "UTF-8"   # the source file is UTF-8 whatever the session locale
  g
}
read_frozen <- function(file, header) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
## Refuse to silently overwrite a frozen copy that differs: a snapshot is
## evidence, and a changed value must be a deliberate, reviewed edit.
freeze <- function(grid, locus, header = NULL) {
  file <- file.path(folder, paste0(paper, "_", locus, "_snapshot.csv"))
  if (file.exists(file)) {
    old <- read_frozen(file, header = !is.null(header))
    if (!identical(dim(old), dim(grid)) || !identical(unname(old), unname(grid)))
      stop(paper, "_", locus, ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and move ",
           "the superseded file to archive/ before re-running.", call. = FALSE)
    message(paper, "_", locus, ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    ## written byte-for-byte as UTF-8 (every field quoted, quotes doubled), so the
    ## result does not depend on the session locale
    q <- function(x) paste0('"', gsub('"', '""', x, fixed = TRUE), '"')
    rows <- c(if (!is.null(header)) paste(q(header), collapse = ","),
              apply(grid, 1, function(r) paste(q(r), collapse = ",")))
    con <- file(file, open = "wb"); writeLines(enc2utf8(rows), con, useBytes = TRUE); close(con)
    message(paper, "_", locus, ": wrote ", basename(file), " (", nrow(grid), " rows x ", ncol(grid), " cols)")
  }
  invisible(file)
}

## ---- TABLE1 (17 printed rows x 12 columns) --------------------
TABLE1_printed <- "
TABLE 1|||||||||||
EXPT. NO.|GENERAL CONDITION|BLOOD PRES-SURE|CEREBRAL||||O2 CONSUMED||CERE-BRAL R.Q.|WEIGHT|
|||A-V diff.||Blood flow|O2 uptake|Total|% by brain||Ani-mal|Brain
|||O2|CO2|||||||
|||vols. %||ml./100g./min.||ml./min.|||kg.|grams
5|Good—light anesthesia|135|7.0|6.0|53.4|3.7|||0.85|2.8|90
9|Good—deep anesthesia|84|6.6|6.9|38.0|2.5|||1.05|3.2|90
13|Good—light anesthesia|114|8.7|7.3|33.5|2.9|29|9.0|0.84|3.5|88
14|Excellent—active movements|100|10.1|10.2|33.4|3.4|30|11.7|1.01|3.5|114
22|Excellent—active movements|134|7.8|8.0|41.0|3.1|40|6.9|1.02|4.1|89
24|Excellent—reflexes very active|124|6.0|6.0|73.6|4.4|31|12.1|1.00|3.7|85
25|Excellent—reflexes very active|150|9.7|8.2|46.6|4.5|41|8.8|0.85|4.1|80
26|Excellent—reflexes very active|116|8.2|7.6|40.4|3.3|31|8.7|0.92|3.3|82
27|Excellent—reflexes very active|102|8.8|10.7|49.7|4.4|35|9.4|1.22|3.0|75
30|Excellent—reflexes very active|110|7.8|7.5|53.0|4.1|37|12.3|0.96|5.8|105
31|Excellent—reflexes very active|100|8.2|8.1|53.7|4.4|48|10.0|0.99|5.3|108
Average||115|8.0|8.0|46.9|3.7|36|10.0|1.00|3.8|91
"
g <- as_grid(TABLE1_printed, 12L)
stopifnot(nrow(g) == 17L, ncol(g) == 12L)
freeze(g, "TABLE1")

## ---- TABLE2 (25 printed rows x 14 columns) --------------------
TABLE2_printed <- "
TABLE 2|||||||||||||
EXPT. NO.|EXPERIMENTAL CONDITIONS|BLOOD PRES-SURE|O2 CONTENT||CO2 CONTENT||CEREBRAL|||O2 CONSUMED||CONDITION OF ANIMAL|COR-NEAL REFLEX
|||Art.|Vein|Art.|Vein|AV-O2|Blood flow|O2 up-take|Total|% by brain||
||mm. Hg|vols. %||vols. %||vols. %|ml./100 g./min.||ml./min.|||
26|Control|116|14.4|6.1|45.6|53.2|8.2|40.4|3.30|31|8.7|Excellent|++
|Bleeding 10 ml.|88|14.5|5.3|45.5|55.2|9.3|33.9|3.14|28|9.2|V. good|++
|Bleeding 10 ml.|70|14.9|3.3|43.9|56.3|11.7|27.9|3.26|28|9.6|V. good|++
|Bleeding 10 ml.|58|14.8|0.8|41.2|57.4|14.0|20.2|2.83|25|9.3|Fair|±
|Bleeding 10 ml.|44|14.7|0.6|35.8|55.8|14.1|13.2|1.85|21|7.2|Bad|0
|Blood returned|114|11.6|3.4|46.0|53.7|8.1|46.0|3.72|34|9.0|Good|+
|15 min. later|110|12.9|3.4|47.4|57.3|9.5|41.4|3.94|35|9.2|Good|+
24|Control|124|11.6|5.6|50.9|56.9|6.0|73.6|4.43|31|12.2|Excellent|+++
|Bleeding 10 ml.|80|12.7|3.4|53.5|61.3|9.3|39.6|3.69|28|11.1|Fair|+
|Bleeding 6 ml.|64|12.5|2.2|54.6|64.4|10.3|30.2|3.12|27.5|9.8|Bad|0
|Blood returned|105|12.2|3.2|51.9|60.3|9.0|32.2|2.92|32|7.8|Bad|0
|Gelatin 10 cc.|138|11.4|5.1|51.5|57.5|6.3|56.5|3.55|34|8.8|Good|++
30|Control|110|12.5|4.7|52.1|59.6|7.8|53.0|4.13|35|12.3|Excellent|++++
|Bleeding 75 ml.|56|10.3|1.5|49.7|59.6|8.8|32.9|3.04|27|11.1|Good|++
|Bleeding 35 ml.|40|9.4|0.9|45.7|54.8|8.5|24.6|2.09|12|18.3|Bad|±
|Blood returned|100|10.0|5.3|45.1|49.1|4.7|62.2|2.93|35|8.9|Good|++
25|Control|150|14.6|4.9|45.9|54.1|9.7|46.6|4.52|41|8.8|Excellent|+++
|Bleeding 10 ml.|100|15.2|2.0|46.7|58.3|13.2|29.5|3.90|32|9.7|Fair|+
|3 min. later|96|13.7|1.3|51.6|59.6|12.4|28.0|3.48|30|9.0|Bad|0
|Transfused 25 ml.|114|13.2|3.3|57.5|65.4|9.9|31.2|3.10|art.|resp.|Bad|0
|30 min. later|56|8.1|3.2|79.6|83.0|4.9|11.2|0.56|art.|resp.|Moribund|0
"
g <- as_grid(TABLE2_printed, 14L)
stopifnot(nrow(g) == 25L, ncol(g) == 14L)
freeze(g, "TABLE2")

## ---- TABLE3 (20 printed rows x 15 columns) --------------------
TABLE3_printed <- "
TABLE 3||||||||||||||
EXPT. NO.|EXPERIMENTAL CONDITIONS|BLOOD PRES-SURE|O2 CONTENT||CO2 CONTENT||CEREBRAL|||O2 CONSUMED||CONDITION OF ANIMAL|COR-NEAL REFLEX|BRAIN WEIGHT
|||Art.|Vein|Art.|Vein|A-VO2|Blood flow|O2 up-take|Total|% by brain|||
||mm. Hg|vols. %||vols. %||vols. %|ml./100 g./min.||ml./min.||||grams
30|Control (nat. resp.)|110|12.5|4.7|52.1|59.6|7.8|53.0|4.13|35|12.3|Excellent|++++|105
|Epineph. infusion|125|10.7|4.6|51.8|58.0|6.1|62.3|3.80|33|12.2|Excellent|++++|
31|Control (nat. resp.)|96|15.4|6.1|46.6|55.0|9.3|45.9|4.26|53|8.7|Excellent|++++|108
|Epineph. infusion|145|13.0|8.4|49.2|52.8|4.6|76.8|3.53|29|13.1|Excellent|++++|
|After epineph.|79|10.6|2.6|45.6|52.3|8.0|51.0|4.08|75|5.9|Excellent|++++|
32|Control (art. resp.)|36|9.6|0.8|67.8|74.6|8.8|21.0|1.85|||Bad|0|95
|Epineph. infusion|112|8.5|4.9|66.6|69.0|3.6|85.6|3.08|||Fair|+|
8|Control (art. resp.)|32|11.7|2.0|44.3|54.7|9.7|18.9|1.83|||Bad|0|95
|Epineph. infusion|94|11.5|6.5|43.9|48.3|5.0|41.5|1.96|||Bad|0|
|Epineph. continued|88|9.9|5.7|42.1|46.3|4.2|44.0|1.85|||Bad|0|
15|Control (art. resp.)|64|14.2|4.0|81.1|89.3|10.2|17.7|1.80|||Bad|0|109
|Epineph. infusion|154|12.5|7.1|80.3|87.3|5.4|44.7|2.40|||Bad|0|
|After epineph.|46|8.2|1.8|83.7|90.4|6.4|9.6|0.61|||Moribund|0|
12|Control (art. resp.)|77|13.1|8.5|67.7|79.9|4.6|22.7|1.05|||Bad|0|90
|Epineph. infusion|164|11.1|5.7|67.8|72.1|5.4|22.4|1.21|||Bad|0|
|After epineph.|54|6.9|2.8|52.8|61.1|4.1|10.6|0.43|||Moribund|0|
"
g <- as_grid(TABLE3_printed, 15L)
stopifnot(nrow(g) == 20L, ncol(g) == 15L)
freeze(g, "TABLE3")

## ---- TABLE4 (51 printed rows x 15 columns) --------------------
TABLE4_printed <- "
TABLE 4||||||||||||||
EXPT. NO.|EXPERIMENTAL CONDITIONS|BLOOD PRES-SURE|O2 CON-TENT||CO2 CON-TENT||CEREBRAL|||O2 CON-SUMED||CONDITION OF ANIMAL|COR-NEAL REFLEX|BRAIN WEIGHT
|||Art.|Vein|Art.|Vein|A-VO2|Blood flow|O2 up-take|Total|% by brain|||
||mm. Hg|vols. %||vols. %||vols. %|ml./100g./min.||ml./min.||||grams
13|Control (nat. resp.)|114|16.7|8.1|40.9|48.2|8.6|33.5|2.90|29|9|V. good|++|88
|Metrazol 100 mg. i.a.|96|15.4|4.5|31.5|49.2|10.9|47.5|5.17|34|13.8|Convuls.|++|
|Pentothal 5 mg. i.a.|74|16.5|9.8|35.3|36.6|6.7|38.0|2.89|31|9.3|Depressed|0|
|8 min. later|56|14.1|3.0|30.0|42.7|11.1|17.1|1.89|29|5.9|Better|+|
|Transfusion|83|13.2|3.0|34.4|44.1|10.2|31.1|3.16|35|8.0|V. good|++|
14|Control (nat. resp.)|100|13.5|3.5|39.6|49.7|10.0|33.4|3.36|32.6|11.6|Excellent|++++|114
|Pentothal 5 mg. i.a.|100|13.9|2.6|42.9|52.6|11.3|19.0|2.15|26|8.9|Depressed|0|
|Metrazol 100 mg. i.a.|80|12.7|0.6|37.3|46.9|12.1|28.8|3.50|25|16|Convuls.|++|
|15 min. later|64|14.1|2.3|45.7|54.7|11.8|17.3|2.04|30|7.7|Depressed|0|
|30 min. after met.|110|11.7|2.4|43.3|53.1|9.3|31.4|2.92|36|9.2|V. good|++|
10|Control (nat. resp.)|100|12.9|5.0|58.3|68.3|7.9|29.2|2.30|||Poor|0|85
|Metrazol 100 mg. i.a.|136|11.1|4.2|56.7|69.4|6.9|59.8|4.13|||Convuls.|++|
|15 min. later|100|5.7|1.6|66.3|71.0|4.1|20.6|0.85|||Bad|0|
18|Control (nat. resp.)|94|15.4|3.4|14.4|27.6|12.0|22.6|2.71|29.4|10.9|Fair|0|102
|Metrazol 100 mg. i.a.|124|14.6|2.9|15.7|27.0|11.7|30.1|3.53|33.3|9.3|Convuls.|++|
8|Control (art. resp.)|88|9.9|5.7|42.1|46.3|4.2|44.0|1.85|||Bad|0|95
|Metrazol 100 mg. i.a.|80|10.1|7.1|39.8|44.1|3.0|65.7|1.97|||Sl. convul.|++|
32|Control (art. resp.)|112|8.5|4.9|66.6|69.0|3.6|85.6|3.08|||Bad|0|95
|Metrazol 200 mg. i.v.|80|5.3|0.6|61.9|68.4|4.7|62.2|2.92|||No convul.|0|
|Coramine 500 mg. i.v.|80|6.3|0.8|36.4|51.7|5.5|66.4|3.65|||Convuls.|++|
|17 min. later|40|5.8|0.3|40.4|52.8|5.5|27.4|1.51|||Bad|0|
|12 min. later|34|5.7|0.3|45.9|53.3|5.4|24.6|1.32|||Moribund|0|
22|Control (nat. resp.)|128|8.5|2.4|62.0|67.6|6.1|32.1|1.95|42|4.0|Poor|0|
|Coramine 50 mg. i.a.|70|8.8|2.5|65.4||6.3|26.6|1.67|40|3.8|No convul.|0|
|9 min. later|122|8.8|2.6|59.7|67.0|6.2|29.3|1.82|37|4.3|Poor|0|
|Pentothal 5 mg. i.a.|52|9.1|2.7|71.3|74.8|6.4|13.5|0.87|||Bad|0|
24|Control (nat. resp.)|106|11.1|4.1|51.5|60.0|7.1|54.2|3.85|36|6.2|Good|+|85
|Coramine 50 mg. i.a.|130|9.7|4.5|49.9|56.8|5.2|64.4|3.24|41|6.8|No convul.|+|
|4 min. later|106|8.4|0.7|55.6|60.5|7.7|28.7|2.21|31|6.1|Poor|0|
27|Control (nat. resp.)|102|13.0|4.2|40.2|50.9|8.8|49.7|4.37|35|9.4|Excellent|++++|75
|Picrotoxin 3 mg. i.a.|116|12.5|3.6|41.7|50.7|8.9|57.0|5.06|40|9.5|Convuls.|++++|
|19 min. later|70|12.7|3.7|51.7|62.8|9.0|41.0|3.68|||Poor|0|
|8 min. later|102|12.8|2.0|53.8|65.0|10.8|60.1|6.50|||Twitching|++|
|8 min. later|80|12.5|2.1|49.4|62.5|10.4|51.5|5.35|||Convuls.|++|
|42 min. later|124|11.8|2.0|44.8|51.8|9.8|48.6|4.77|36|10|Excellent|++++|
|Pentothal 2.5 mg. i.a.|116|11.4|3.1|46.2|54.3|8.3|45.9|3.81|38|7.6|Depressed|±|
|15 min. later|124|10.5|2.2|46.5|52.5|8.7|50.3|4.37|38|8.7|Excellent|++++|
28|Control (art. resp.)|83|14.5|7.5|68.4|74.9|7.0|33.8|2.36|||Bad|0|88
|Picrotoxin 7 mg. i.a.|104|14.2|2.0|70.2|84.1|12.2|34.6|4.22|36|10.2|Good|+|
|25 min. later|102|14.1|1.9|65.5|78.4|12.2|29.2|3.57|36|8.6|Good|+|
|Benzedrine 1 mg. i.a.|106|12.7|3.1|65.0|75.8|9.6|27.0|2.59|36|6.4|Poor|0|
|18 min. later|106|11.8|2.6|67.1|74.9|9.2|30.5|2.80|52|4.8|Fair|0|
2|Control (art. resp.)|80|9.5|3.5|34.4|38.3|6.0|25.2|1.51|||Bad|0|95
|Benzedrine 5 mg. i.v.|94|10.5|3.3|35.4|40.1|7.2|29.0|2.1|||Bad|0|
|5 min. later|86|6.7|2.0|36.5|40.7|4.7|25.4|1.2|||Bad|0|
5|Control (art. resp.)|64|12.7|4.6|38.4|47.5|8.1|36.4|2.95|||Bad|0|90
|Benzed. 5 mg. i.v.|70|11.0|1.7|36.9|47.1|9.3|20.8|1.94|||Bad|0|
"
g <- as_grid(TABLE4_printed, 15L)
stopifnot(nrow(g) == 51L, ncol(g) == 15L)
freeze(g, "TABLE4")

## ---- TABLE5 (8 printed rows x 16 columns) --------------------
TABLE5_printed <- "
TABLE 5|||||||||||||||
EXPT. NO.|EXPERIMENTAL CONDITIONS|B-P|O2 CON-TENT||CO2 CON-TENT||CEREBRAL|||O^2 CON-SUMED||BLOOD SUGAR|CONDI-TION|C.R.|WT. OF BRAIN
|||Art.|Vein|Art.|Vein|A-VO2|Blood flow|O2 up-take|Total|% by brain||||
|||vols. %||vols. %||vols. %|ml./100g./min.)||ml./min.||mgm. %|||
31|Control|79|10.6|2.6|45.6|52.3|8.0|51.0|4.08|75|5.9|159|Excel.|++++|108
|10' after insulin-20 u|66|9.9|2.4|46.4|54.2|7.5|47.2|3.54|70|5.0|98|Excel.|++++|
|1 hr. after insulin|66|9.1|1.7|47.2|54.5|7.4|49.3|3.64|75|4.9|41|Excel.|++++|
|After glucose-5 g.|69|6.0|1.2|49.3|52.7|4.8|60.3|2.89|76|3.8|197|Excel.|++++|
"
g <- as_grid(TABLE5_printed, 16L)
stopifnot(nrow(g) == 8L, ncol(g) == 16L)
freeze(g, "TABLE5")

## ---- TABLE6 (9 printed rows x 6 columns) --------------------
TABLE6_printed <- "
TABLE 6|||||
|FINDINGS IN MONKEYS' BRAINS ML./100 G./MIN.||QO2|CORRESPONDING VALUE FOR 1400 G. HUMAN BRAIN (ML./MIN.)|
|O2 uptake|Blood flow||O2 uptake|Blood flow
\"Normal\" mean|3.7|47|11.1|52|660
\"Normal\" minimum|2.5|33|7.5|35|460
\"Normal\" maximum|4.5|74|13.5|63|1040
Highest of all (picrotoxin convulsion)|6.5|91|19.5|91|1275
Lowest with recovery (hemorrhage)|1.85|13.2|5.6|26|185
Lowest of all (moribund)|0.39|5|1.17|6|70
"
g <- as_grid(TABLE6_printed, 6L)
stopifnot(nrow(g) == 9L, ncol(g) == 6L)
freeze(g, "TABLE6")

## ---- Text: constructed snapshot, one row per printed number --------
## Columns up to region_as_printed are printed text (quoted, page-located);
## curator_* columns are the curator's classification of each value and are
## the only constructed content (see README).
txt_header <- c("text_row", "page", "location", "passage_as_printed", "value_printed", "dispersion_printed", "n_printed", "units_printed", "subjects_as_printed", "state_as_printed", "region_as_printed", "curator_value_role", "curator_cited_refs", "curator_note")
txt_printed <- "
1|46|Discussion|it seems proper to regard the highest of our \"normal\" values as our closest approximation to the situation in the intact, unanesthetized monkey. This (4.5 ml. per 100 grams of wet brain per min.) gives a QO2 of 13.5|4.5|||ml. per 100 grams of wet brain per min.|monkeys|highest \"normal\" value|brain|restatement||O2 uptake; restates TABLE 6 \"Normal\" maximum
2|46|Discussion|the mean and maximum blood flow values encountered in these monkeys were distinctly below the corresponding figures (60 and 113 ml. per 100 grams per min. respectively) in our earlier work (6).|60|||ml. per 100 grams per min.|monkeys (earlier work)|mean|brain|cited|6|mean CBF in the authors' earlier monkey experiments
3|46|Discussion|the mean and maximum blood flow values encountered in these monkeys were distinctly below the corresponding figures (60 and 113 ml. per 100 grams per min. respectively) in our earlier work (6).|113|||ml. per 100 grams per min.|monkeys (earlier work)|maximum|brain|cited|6|maximum CBF in the authors' earlier monkey experiments
"
g <- as_grid(txt_printed, 14L)
stopifnot(nrow(g) == 3L, identical(g[, 1], as.character(seq_len(nrow(g)))))
freeze(g, "Text", header = txt_header)

