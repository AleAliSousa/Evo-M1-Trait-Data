# Heiss_etal_1985_Text_internal_check.R ---------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Heiss, Pawlik, Herholz, Wagner & Wienhard
# (1985), Brain Research 327: 362-366. The values printed in the ABSTRACT (p. 362) and RESULTS
# (p. 364) -- item Heiss_etal_1985_Text -- that restate a TABLE I cell are compared with that
# cell in the sibling item Heiss_etal_1985_TABLEI (read from ITS frozen snapshot). The one new
# value (text row 7, the non-dreamers' whole-brain rate during sleep) is compared with the
# table's awake rate and % change.
#
# Read-only: reads the Text snapshot and the TABLEI snapshot in the paper folder, writes only
# Heiss_etal_1985_Text_internal_check.csv next to this script. It never changes a value; a
# mismatch is warned and kept as printed. The item script Heiss_etal_1985_Text.R reads only
# its own snapshot.

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
folder <- dirname(.sp); setwd(folder)                       # <Paper>/internal_checks
item_name <- sub("_internal_check\\.R$", "", basename(.sp))
base <- item_name
paper <- basename(dirname(folder))
paper_dir <- dirname(folder)                                # snapshots live in the paper folder

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file.path(paper_dir, file), header = header, colClasses = "character",
                na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## ---- cell helpers (as in Heiss_etal_1985_Text.R) -----------------------------------
strip_marks <- function(x) trimws(sub("(\\^[a-z](,[a-z])*|\\*+)$", "", x))
mean_lexeme <- function(x) { s <- strip_marks(x); trimws(sub("\\s*\u00b1.*$", "", s)) }
disp_lexeme <- function(x) { s <- strip_marks(x); ifelse(grepl("\u00b1", s), trimws(sub("^.*\u00b1\\s*", "", s)), NA_character_) }
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))   # "- 9.2" -> -9.2, "+ 7.4" -> 7.4

tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 8L, identical(tx$text_row, as.character(1:8)))
t1 <- read_snapshot(paste0(paper, "_TABLEI_snapshot.csv"))
stopifnot(identical(dim(t1), c(33L, 5L)))
t1_cell <- function(region_label, col) t1[match(region_label, gsub("\n", " ", t1[, 1], fixed = TRUE)), col]
WB <- "Whole brain (all regions weighted according to size)"

## the text values as the item script reads them (value_numeric / dispersion_numeric)
text_row           <- as.integer(tx$text_row)
value_numeric      <- num_of(tx$value_printed)
dispersion_numeric <- num_of(tx$dispersion_printed)

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

v <- function(r) value_numeric[text_row == r]
s <- function(r) dispersion_numeric[text_row == r]
wb_nd_awake <- t1_cell(WB, 2); wb_nd_pct <- t1_cell(WB, 3)
wb_dr_awake <- t1_cell(WB, 4); wb_dr_pct <- t1_cell(WB, 5)
table_checks <- rbind(
  chk("restate_1_mean", "text row 1 (abstract) 12.6 vs |TABLE I whole-brain non-dreamers % change|",
      v(1), abs(num_of(mean_lexeme(wb_nd_pct))), 0),
  chk("restate_1_sd",   "text row 1 (abstract) S.D. 4.73 vs TABLE I whole-brain non-dreamers % change S.D.",
      s(1), num_of(disp_lexeme(wb_nd_pct)), 0),
  chk("restate_2", "text row 2 (abstract) 2.1% vs TABLE I Lentiform nucleus, Dreamer % change",
      v(2), num_of(t1_cell("Lentiform nucleus", 5)), 0),
  chk("restate_3", "text row 3 (abstract) 30.0% vs TABLE I Sup. front. cortex, Dreamer % change",
      v(3), num_of(t1_cell("Sup. front. cortex", 5)), 0),
  chk("restate_4", "text row 4 (abstract) 16.4% vs TABLE I whole brain, Dreamer % change",
      v(4), num_of(wb_dr_pct), 0),
  chk("restate_5", "text row 5 (p. 364) 30.3 vs TABLE I whole brain, Dreamer Awake",
      v(5), num_of(wb_dr_awake), 0),
  chk("restate_6_mean", "text row 6 (p. 364) 36.2 vs TABLE I whole brain, Non-dreamers Awake",
      v(6), num_of(mean_lexeme(wb_nd_awake)), 0),
  chk("restate_6_sd", "text row 6 (p. 364) S.D. 2.38 vs TABLE I whole brain, Non-dreamers Awake S.D.",
      s(6), num_of(disp_lexeme(wb_nd_awake)), 0),
  chk("restate_8", "text row 8 (p. 364) + 16.4% vs TABLE I whole brain, Dreamer % change",
      v(8), num_of(wb_dr_pct), 0),
  ## the one new value against the table's awake rate and % change:
  ## 36.2 x (1 - 12.6/100) = 31.64; tolerance = rounding of the two printed
  ## inputs (+/-0.05 each, propagated) + half a unit of the printed 31.6.
  ## (A mean of ratios need not equal the ratio of means; this is a consistency
  ## check, not an identity.)
  chk("sleep_rate_vs_pct", "text row 7 31.6 vs TABLE I whole brain non-dreamers Awake x (1 + % change/100)",
      num_of(mean_lexeme(wb_nd_awake)) * (1 + num_of(mean_lexeme(wb_nd_pct)) / 100), v(7),
      0.05 * (1 + num_of(mean_lexeme(wb_nd_pct)) / 100) +
        num_of(mean_lexeme(wb_nd_awake)) * 0.05 / 100 + 0.05,
      "consistency, not identity: mean of individual ratios vs ratio of means")
)

## ---- output: this check's own CSV (never a snapshot, analysis CSV or TSV) ------
tally <- table(factor(table_checks$status, levels = c("pass", "mismatch", "not_evaluable")))
message(item_name, ": internal check  pass=", tally[[1]], "  mismatch=", tally[[2]],
        "  not_evaluable=", tally[[3]])
if (tally[[2]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$basis[i], bad$observed[i], bad$printed[i], bad$difference[i],
                    bad$tolerance[i]), call. = FALSE)
}
write.csv(table_checks, paste0(base, "_internal_check.csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(table_checks), " checks written to ", base, "_internal_check.csv")
