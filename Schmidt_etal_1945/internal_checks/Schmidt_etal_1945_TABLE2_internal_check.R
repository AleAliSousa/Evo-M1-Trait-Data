# Schmidt_etal_1945_TABLE2_internal_check.R ------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Schmidt, Kety & Pennes (1945), Am J Physiol
# 143(1): 33-52, TABLE 2. The "% O2 by brain" column is recomputed as O2 uptake x brain weight /
# 100 / Total x 100, with the brain weight (g) taken from the sibling item TABLE 1 (read from ITS
# frozen snapshot Schmidt_etal_1945_TABLE1_snapshot.csv, same experiment number).
#
# The checks that use only the TABLE 2 snapshot (A-V O2 = Art. - Vein; O2 uptake = A-V O2 x blood
# flow / 100) stay in Schmidt_etal_1945_TABLE2.R (table_checks, build HOWTO 7a).
#
# Read-only: reads the two frozen snapshots in the paper folder, writes only
# Schmidt_etal_1945_TABLE2_internal_check.csv next to this script. It never changes a value; a
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

## ---- cell helpers (as in the Schmidt_etal_1945 item scripts) ------------------------
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

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
t1   <- read_snapshot(paste0(paper, "_TABLE1_snapshot.csv"))
data_rows <- c(5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25)

## ---- cross-item check: % O2 by brain, brain weight from TABLE 1 -------------------------
chk_rows <- data_rows
expt <- sapply(chk_rows, function(r) one_line(snap[r, 1]))
for (i in seq_along(expt)) if (!nzchar(expt[i]) && i > 1) expt[i] <- expt[i - 1]
bw <- setNames(sapply(6:16, function(r) num(t1[r, 12])), sapply(6:16, function(r) t1[r, 1]))
brain_g <- unname(bw[expt])
for (i in seq_along(chk_rows)) {
  r <- chk_rows[i]; tag <- paste0(" [row ", r, ": expt ", expt[i], ", ", one_line(snap[r, 2]), "]")
  tot <- cell_num(r, 11); pc <- cell_num(r, 12); o <- cell_num(r, 10)
  if (!is.na(tot) && !is.na(pc) && !is.na(brain_g[i])) {
    obs <- o * brain_g[i] / 100 / tot * 100
    add_check(paste0("pct_by_brain_row", r), paste0("% O2 by brain = O2 uptake x brain weight/100 / Total x 100", tag), obs, pc,
              obs * (hu(cell_lex(r, 10)) / o + hu(cell_lex(r, 11)) / tot) + hu(cell_lex(r, 12)),
              paste0("brain weight ", brain_g[i], " g (TABLE 1, same experiment number)"))
  }
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
