# Geiger_Magnes_1947_Text_snapshot.R ----------------------------------------------------
#
# Freezes the snapshots of Geiger, A., & Magnes, J. (1947). The isolation of the cerebral circulation and the perfusion of the brain in the living cat. American Journal of Physiology, 149(3), 517-537.
# DOI 10.1152/ajplegacy.1947.149.3.517. Source PDF: geiger_magnes_1947.pdf (journal pp. 517-537 (PDF pages 1-21)).
#
# Source: OCR text layer, garbled (Table 1 printed sideways, low-contrast); values read from 300/500-dpi renders. The printed layout of each table
# is written out verbatim below (method 5 / the Jacobs_etal_2018_Table3_snapshot.R
# pattern); this script freezes its block to Geiger_Magnes_1947_Text_snapshot.csv and the
# item build script Geiger_Magnes_1947_Text.R READS the frozen file. No cleaning happens here.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Geiger_Magnes_1947_Text

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
freeze <- function(grid, header = NULL) {
  file <- file.path(folder, paste0(item_name, "_snapshot.csv"))
  if (file.exists(file)) {
    old <- read_frozen(file, header = !is.null(header))
    if (!identical(dim(old), dim(grid)) || !identical(unname(old), unname(grid)))
      stop(item_name, ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and move ",
           "the superseded file to archive/ before re-running.", call. = FALSE)
    message(item_name, ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    ## written byte-for-byte as UTF-8 (every field quoted, quotes doubled), so the
    ## result does not depend on the session locale
    q <- function(x) paste0('"', gsub('"', '""', x, fixed = TRUE), '"')
    rows <- c(if (!is.null(header)) paste(q(header), collapse = ","),
              apply(grid, 1, function(r) paste(q(r), collapse = ",")))
    con <- file(file, open = "wb"); writeLines(enc2utf8(rows), con, useBytes = TRUE); close(con)
    message(item_name, ": wrote ", basename(file), " (", nrow(grid), " rows x ", ncol(grid), " cols)")
  }
  invisible(file)
}
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
freeze(g, header = txt_header)
