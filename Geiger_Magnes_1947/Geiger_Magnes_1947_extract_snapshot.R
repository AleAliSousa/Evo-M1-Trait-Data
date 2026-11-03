# Geiger_Magnes_1947_extract_snapshot.R ----------------------------------------------------
#
# Freezes the snapshots of Geiger, A., & Magnes, J. (1947). The isolation of the cerebral circulation and the perfusion of the brain in the living cat. American Journal of Physiology, 149(3), 517-537.
# DOI 10.1152/ajplegacy.1947.149.3.517. Source PDF: geiger_magnes_1947.pdf (journal pp. 517-537 (PDF pages 1-21)).
#
# Source: OCR text layer, garbled (Table 1 printed sideways, low-contrast); values read from 300/500-dpi renders. The printed layout of each table
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

## ---- TABLE1 (28 printed rows x 15 columns) --------------------
TABLE1_printed <- "
The Oxygen consumption of the perfused brain (ml. O2 consumed per 100 grams brains per min.). Division into 3 groups according to functional state of brain||||||||||||||
EXPERIMENT|DURATION OF PERFUSION, MINUTES|||||||||||||REMARKS
|0-15|15-30|30-45|45-60|60-75|75-90|90-105|105-120|120-135|135-150|150-165|165-180|180-195|
Group A||||||||||||||
23-5|4.65|4.65|4.50|4.80|4.65|4.42|4.35|3.78(1)|3.45|3.15(2)|3.22|3.34|3.34|(1) Added 60 mgm. % chloral hydrate. (2) Changed blood
30-5|4.75|4.23|3.60|3.30|3.08|3.22|3.15|3.00(1)|2.70|2.48|2.85*|||(1) Changed blood—strong vasoconstriction
6-6|4.57|3.98|3.74|3.45(1)|3.08*|2.80||||||||(1) Changed blood—vasoconstriction
13-6|5.45|4.20|4.12|4.42|3.90*|2.70||||||||
8-7|5.55|5.06|5.32|4.95|4.70|3.90(1)|3.00|2.85*||||||(1) Added 20 mgm. % Na-amytal
15-7|4.73|4.50|4.87|4.75|4.65|4.42(1)|4.42|3.75(2)|3.00|2.85*||||(1) Changed blood. (2) Added 20 mgm. % Na-amytal
Average.|4.95|4.44|4.36|4.28|4.01|||||||||
Group B||||||||||||||
30-1|3.68|3.75|3.38*|3.15||||||||||
4-2|4.27|3.45|3.67|3.67*|3.45|||||||||
7-2|4.35|4.10|3.00|2.93*|2.55|2.40||||||||
17-2|3.82|3.30|3.15*|3.15||||||||||
25-3|3.45|3.52|3.00|3.00*|2.65|2.40||||||||
17-6|3.45|3.38|3.45*|3.22(1)|2.92|||||||||(1) Added 20 mgm. % Na-pentothal
Average.|3.83|3.58|3.27|3.18|2.90|||||||||
Group C||||||||||||||
25-2|3.22*|2.93|2.78|2.70|2.70|||||||||
28-2|2.55|2.40|2.10*|2.03|2.10|||||||||
4-3|3.00*|3.15|2.82|3.15||||||||||
11-3|2.32*|2.32|2.22|2.22|2.10|||||||||
21-3|3.75*|3.00|2.92|2.63|2.40|||||||||
3-7|3.75*|2.81|2.64|2.66||||||||||
Average.|3.10|2.77|2.58|2.56|2.32|||||||||
* Loss of reflexes.||||||||||||||
"
g <- as_grid(TABLE1_printed, 15L)
stopifnot(nrow(g) == 28L, ncol(g) == 15L)
freeze(g, "TABLE1")

## ---- TABLE2 (17 printed rows x 7 columns) --------------------
TABLE2_printed <- "
TABLE 2||||||
The glucose consumption of the perfused brain||||||
EXPERIMENT|DURATION|GLUCOSE||PER 100 GRAMS BRAIN PER MINUTE||% GLUCOSE ACCOUNTED FOR BY OXIDATION
||Mgm.% in blood at start|Mgm. uptake by brain|Glucose mgm.|Oxygen ml.|
|minutes|||||
1|33|131|41.7|4.85|3.40|95
2|25|154|34.0|4.95|2.88|78
3|33|174|72.2|8.00|3.50|58
4|16|182|17.8|3.90|3.60|123
5|28|192|61.4|7.80|3.10|53
6|18|210|21.1|5.10|3.40|89
7|22|192|28.8|5.70|2.60|61
8|42|206|102.5|8.70|4.65|71
9|86|149|149.0|6.60|3.56|72
10|55|181|85.8|5.70|4.12|96.5
11|38|217|53.2|5.10|3.60|94
12|25|181|28.0|4.08|4.12|34
"
g <- as_grid(TABLE2_printed, 7L)
stopifnot(nrow(g) == 17L, ncol(g) == 7L)
freeze(g, "TABLE2")

## ---- Text: constructed snapshot, one row per printed number --------
## Columns up to region_as_printed are printed text (quoted, page-located);
## curator_* columns are the curator's classification of each value and are
## the only constructed content (see README).
txt_header <- c("text_row", "page", "location", "passage_as_printed", "value_printed", "dispersion_printed", "n_printed", "units_printed", "subjects_as_printed", "state_as_printed", "region_as_printed", "curator_value_role", "curator_cited_refs", "curator_note")
txt_printed <- "
1|526|Results, Oxygen consumption of the brain|The blood flow through the brain was high from the beginning of perfusion, well over 100 ml. per 100 grams brain per minute, with a perfusion pressure of about 120 mm.Hg.|100|||ml. per 100 grams brain per minute|cat (typical group A experiment, figure 8)|excellent cerebral activity|perfused brain|bound||perfusion flow; printed as a lower bound (\"well over 100\")
2|526|Results, Oxygen consumption of the brain|blood flow rate through the brain increased spontaneously, perfusion pressure remaining constant, reaching rates up to 150 ml. per 100 grams per minute.|150|||ml. per 100 grams per minute|cat (group A)|excellent cerebral activity|perfused brain|bound||perfusion flow; upper end of the range reached
3|526|Results, Oxygen consumption of the brain|The oxygen consumption of the brain was very high at the beginning of perfusion, sometimes 6 ml. of oxygen per minute.|6|||ml. of oxygen per minute (per 100 grams brain, footnote 2)|cat (group A)|beginning of perfusion|perfused brain|new||O2 consumption; footnote 2: figures for blood flow and oxygen consumption are calculated for 100 grams brain per minute
4|526|Results, Oxygen consumption of the brain|This high oxidation rate declined within 5 to 10 minutes, as shown in table 1, to a steadier level of oxidation between 4 to 5 ml. of oxygen.|4|||ml. of oxygen (per 100 grams brain per minute)|cat (group A)|steady level|perfused brain|range_low||O2 consumption range, low end; summarises TABLE 1 group A
5|526|Results, Oxygen consumption of the brain|This high oxidation rate declined within 5 to 10 minutes, as shown in table 1, to a steadier level of oxidation between 4 to 5 ml. of oxygen.|5|||ml. of oxygen (per 100 grams brain per minute)|cat (group A)|steady level|perfused brain|range_high||O2 consumption range, high end
6|529|Results|In group B signs of cortical activity were absent though reflex activity was excellent and correspondingly a rate of oxygen consumption between 3.2-3.8 ml. was found.|3.2|||ml. (per 100 grams brain per minute)|cat (group B)|cortical activity absent, reflexes excellent|perfused brain|range_low||O2 consumption range, low end
7|529|Results|In group B signs of cortical activity were absent though reflex activity was excellent and correspondingly a rate of oxygen consumption between 3.2-3.8 ml. was found.|3.8|||ml. (per 100 grams brain per minute)|cat (group B)|cortical activity absent, reflexes excellent|perfused brain|range_high||O2 consumption range, high end
8|529|Results, responses to narcotics|At the same time the rate of oxygen consumption dropped from 5.1 to 2.9 ml. (43 per cent) as shown in figure 10.|5.1|||ml. (per 100 grams brain per minute)|cat (one group A experiment, figure 10)|before amytal|perfused brain|new||O2 consumption before adding amytal (24 mgm. per 100 cc. of blood, figure 10 legend)
9|529|Results, responses to narcotics|At the same time the rate of oxygen consumption dropped from 5.1 to 2.9 ml. (43 per cent) as shown in figure 10.|2.9|||ml. (per 100 grams brain per minute)|cat (one group A experiment, figure 10)|after amytal|perfused brain|new||O2 consumption after amytal
10|529|Results, responses to narcotics|the addition of 24 mgm. of amytal to the perfusion blood of a cat without cortical activity caused a reduction of oxygen consumption from 3 ml. oxygen to 2.5ml. (17 per cent) only, as shown in figure 11.|3|||ml. oxygen (per 100 grams brain per minute)|cat without cortical activity (figure 11)|before amytal|perfused brain|new||O2 consumption before amytal
11|529|Results, responses to narcotics|the addition of 24 mgm. of amytal to the perfusion blood of a cat without cortical activity caused a reduction of oxygen consumption from 3 ml. oxygen to 2.5ml. (17 per cent) only, as shown in figure 11.|2.5|||ml. (per 100 grams brain per minute)|cat without cortical activity (figure 11)|after amytal|perfused brain|new||O2 consumption after amytal
12|531|Discussion of flow|Schmidt, Kety and Pennes (1945) measuring the blood flow and oxygen consumption of the monkey's brain also found that flow rate greatly influenced its oxygen consumption. In their experiments the flow rates varied between 33 to 72 ml. per 100 grams brain per minute.|33|||ml. per 100 grams brain per minute|monkey||brain|cited|Schmidt, Kety and Pennes (1945)|cited CBF range, low end
13|531|Discussion of flow|In their experiments the flow rates varied between 33 to 72 ml. per 100 grams brain per minute.|72|||ml. per 100 grams brain per minute|monkey||brain|cited|Schmidt, Kety and Pennes (1945)|cited CBF range, high end. Schmidt et al. 1945 TABLE 1 prints 33.4 and 73.6 as its extremes.
14|535|Summary 6|In group A cerebral activity was excellent (spontaneous movements, etc.) and O2 consumption was at its highest (4-5 ml. per 100 grams per min.).|4|||ml. per 100 grams per min.|cat (group A)|excellent cerebral activity|perfused brain|range_low||summary restatement
15|535|Summary 6|In group A cerebral activity was excellent (spontaneous movements, etc.) and O2 consumption was at its highest (4-5 ml. per 100 grams per min.).|5|||ml. per 100 grams per min.|cat (group A)|excellent cerebral activity|perfused brain|range_high||summary restatement. Midpoint 4.5 = the value Mink et al. 1981 cite for cat (ref. 30); 4.5 is not printed as such.
16|536|Summary 6|In group B with good reflex activity but without spontaneous movements, etc. the O2 consumption lay between 3.2-3.8 ml. per 100 grams brain per minute.|3.2|||ml. per 100 grams brain per minute|cat (group B)|good reflex activity, no spontaneous movements|perfused brain|range_low||summary restatement
17|536|Summary 6|In group B with good reflex activity but without spontaneous movements, etc. the O2 consumption lay between 3.2-3.8 ml. per 100 grams brain per minute.|3.8|||ml. per 100 grams brain per minute|cat (group B)|good reflex activity, no spontaneous movements|perfused brain|range_high||summary restatement
18|536|Summary 6|In group C with very weak or no reflex activity, O2 consumption was the lowest (2-3 ml. per 100 grams per min.).|2|||ml. per 100 grams per min.|cat (group C)|very weak or no reflex activity|perfused brain|range_low||summary restatement
19|536|Summary 6|In group C with very weak or no reflex activity, O2 consumption was the lowest (2-3 ml. per 100 grams per min.).|3|||ml. per 100 grams per min.|cat (group C)|very weak or no reflex activity|perfused brain|range_high||summary restatement
"
g <- as_grid(txt_printed, 14L)
stopifnot(nrow(g) == 19L, identical(g[, 1], as.character(seq_len(nrow(g)))))
freeze(g, "Text", header = txt_header)

