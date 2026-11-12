# Nemoto_etal_1994_TABLE3_internal_check.R ------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Nemoto, Yao, Yonas & Darby (1994), J Neurosurg
# Anesthesiol 6(3): 170-174, TABLE 3. TABLE 3 is derived from TABLE 2 (RESULTS: totals are the
# averages of the three conscious measurements; METHODS: basal = isoelectric-EEG values,
# active = total - basal). This script compares the TABLE 3 Total and Basal cells with the
# means of the TABLE 2 measurements (read from the sibling item's frozen snapshot
# Nemoto_etal_1994_TABLE2_snapshot.csv).
#
# The checks that use only the TABLE 3 snapshot (Active = Total - Basal; Basal % + Active % = 100;
# OGI) stay in Nemoto_etal_1994_TABLE3.R (table_checks, build HOWTO 7a).
#
# Read-only: reads the two frozen snapshots in the paper folder, writes only
# Nemoto_etal_1994_TABLE3_internal_check.csv next to this script. It never changes a value; a
# mismatch is warned and kept as printed.

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
snap <- read_snapshot(paste0(base, "_snapshot.csv"))
t2   <- read_snapshot(paste0(paper, "_TABLE2_snapshot.csv"))

## ---- cell helpers (as in Nemoto_etal_1994_TABLE3.R) ----------------------------
one_line   <- function(x) trimws(gsub("\\s*\n\\s*", " ", x))
marks_of   <- function(x) {
  m <- ifelse(grepl("\\^[a-z](,[a-z])*\\s*$", x), sub("^.*\\^([a-z](,[a-z])*)\\s*$", "\\1", x),
       ifelse(grepl("\\*+\\s*$", x), sub("^.*?(\\*+)\\s*$", "\\1", x), NA_character_))
  gsub(",", "; ", m, fixed = TRUE)
}
strip_marks <- function(x) trimws(sub("(\\^[a-z](,[a-z])*|\\*+)\\s*$", "", x))
paren_of    <- function(x) ifelse(grepl("\\(([0-9]+)\\)", x), gsub("^.*\\(([0-9]+)\\).*$", "\\1", x), NA_character_)
strip_paren <- function(x) trimws(gsub("\\s*\\([0-9]+\\)", "", x))
mean_lex    <- function(x) trimws(sub("\\s*\u00b1.*$", "", x))
disp_lex    <- function(x) ifelse(grepl("\u00b1", x), trimws(sub("^.*\u00b1\\s*", "", x)), NA_character_)
num         <- function(x) suppressWarnings(as.numeric(gsub(",", "", x)))
parse_cell  <- function(cell) {
  s <- one_line(cell)
  marks <- marks_of(s); s <- strip_marks(s)
  par <- paren_of(s);   s <- strip_paren(s)
  marks2 <- marks_of(s); s <- strip_marks(s)        # a mark printed before "(n)"
  marks <- ifelse(is.na(marks), marks2, marks)
  m <- mean_lex(s); d <- disp_lex(s)
  d_marks <- marks_of(ifelse(is.na(d), "", d)); if (!is.na(d)) d <- strip_marks(d)
  if (is.na(marks) && !is.na(d_marks)) marks <- d_marks
  list(value_printed = m, dispersion_printed = d, paren = par, marks = marks)
}
## Half a unit in the last printed decimal place ("3.39" -> 0.005, "76" -> 0.5).
hu <- function(lex) { s <- gsub("[^0-9.]", "", lex)
  d <- ifelse(grepl("\\.", s), nchar(sub("^[^.]*\\.", "", s)), 0); 0.5 * 10^(-d) }
cell_num <- function(r, c) num(parse_cell(snap[r, c])$value_printed)
cell_lex <- function(r, c) parse_cell(snap[r, c])$value_printed
table_checks <- data.frame(check_id = character(), basis = character(), observed = numeric(),
                           printed = numeric(), difference = numeric(), tolerance = numeric(),
                           status = character(), note = character(), stringsAsFactors = FALSE)
add_check <- function(id, basis, observed, printed, tolerance, note = NA_character_, status = NULL) {
  if (is.null(status)) status <- if (is.na(observed) || is.na(printed)) "not_evaluable" else
    if (abs(observed - printed) <= tolerance + 1e-9) "pass" else "mismatch"
  table_checks[nrow(table_checks) + 1L, ] <<- list(id, basis, observed, printed,
    observed - printed, tolerance, status, note)
}

## ---- cross-item checks -------------------------------------------------------------
## TABLE 3 Total / Basal vs the means of the TABLE 2 measurements 1-3 / 4-6.
t2n <- function(r, c) num(parse_cell(t2[r, c])$value_printed)
t2h <- function(r, c) hu(parse_cell(t2[r, c])$value_printed)
for (spec in list(list(r3 = 3L, c2 = 2L, nm = "CBF"), list(r3 = 5L, c2 = 3L, nm = "CMRO2"), list(r3 = 7L, c2 = 4L, nm = "CMRG"))) {
  tot <- mean(sapply(4:6, function(i) t2n(i, spec$c2))); bas <- mean(sapply(8:10, function(i) t2n(i, spec$c2)))
  add_check(paste0("total_", spec$nm), paste0("TABLE 3 ", spec$nm, " Total = mean of TABLE 2 measurements 1-3"),
            tot, cell_num(spec$r3, 2), t2h(4, spec$c2) + hu(cell_lex(spec$r3, 2)))
  add_check(paste0("basal_", spec$nm), paste0("TABLE 3 ", spec$nm, " Basal = mean of TABLE 2 measurements 4-6"),
            bas, cell_num(spec$r3, 3), t2h(8, spec$c2) + hu(cell_lex(spec$r3, 3)))
}

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
