# Schmidt_etal_1945_TABLE6_internal_check.R ------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Schmidt, Kety & Pennes (1945), Am J Physiol
# 143(1): 33-52, TABLE 6. The "Normal" rows summarise TABLE 1 (average, minimum, maximum O2 uptake
# and blood flow: compared with the TABLE 1 snapshot, Schmidt_etal_1945_TABLE1_snapshot.csv); the
# other rows (highest / lowest O2 uptake, recovery pair) should be traceable to a printed row of
# TABLES 1-5 (compared with the sibling analysis CSVs Schmidt_etal_1945_TABLE1.csv ... TABLE5.csv).
#
# The checks that use only the TABLE 6 snapshot (1400 g human value = 14 x monkey value per 100 g)
# stay in Schmidt_etal_1945_TABLE6.R (table_checks, build HOWTO 7a).
#
# Read-only: reads the TABLE 6 snapshot, the TABLE 1 snapshot and the TABLE 1-5 analysis CSVs in
# the paper folder, writes only Schmidt_etal_1945_TABLE6_internal_check.csv next to this script.
# It never changes a value; a mismatch is warned and kept as printed.

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

## ---- cross-item checks -------------------------------------------------------------------
t1n <- function(r, c) num(t1[r, c])
o2 <- sapply(6:16, function(r) t1n(r, 7)); fl <- sapply(6:16, function(r) t1n(r, 6))
add_check("normal_mean_O2", '"Normal" mean O2 uptake = TABLE 1 Average', t1n(17, 7), cell_num(4, 2), hu(t1[17, 7]) + hu(cell_lex(4, 2)))
add_check("normal_mean_CBF", '"Normal" mean blood flow = TABLE 1 Average', t1n(17, 6), cell_num(4, 3), hu(t1[17, 6]) + hu(cell_lex(4, 3)))
add_check("normal_min_O2", '"Normal" minimum O2 uptake = TABLE 1 minimum', min(o2), cell_num(5, 2), hu(t1[6, 7]) + hu(cell_lex(5, 2)))
add_check("normal_min_CBF", '"Normal" minimum blood flow = TABLE 1 minimum', min(fl), cell_num(5, 3), hu(t1[6, 6]) + hu(cell_lex(5, 3)))
add_check("normal_max_O2", '"Normal" maximum O2 uptake = TABLE 1 maximum', max(o2), cell_num(6, 2), hu(t1[6, 7]) + hu(cell_lex(6, 2)))
add_check("normal_max_CBF", '"Normal" maximum blood flow = TABLE 1 maximum', max(fl), cell_num(6, 3), hu(t1[6, 6]) + hu(cell_lex(6, 3)))
prev <- do.call(rbind, lapply(file.path(paper_dir, paste0(paper, "_TABLE", 1:5, ".csv")), function(f) read.csv(f, stringsAsFactors = FALSE, encoding = "UTF-8")))
po2 <- prev[prev$variable == "CMRO2_ml_100g_min" & !is.na(prev$value), ]
pfl <- prev[prev$variable == "CBF_ml_100g_min" & !is.na(prev$value), ]
both <- merge(po2[, c("item_name", "printed_row", "value")], pfl[, c("item_name", "printed_row", "value")],
              by = c("item_name", "printed_row"), suffixes = c("_o2", "_flow"))
hit_o2 <- both[which.max(both$value_o2), ]
add_check("highest_O2", "Highest of all O2 uptake = largest O2 uptake printed in TABLES 1-5", max(po2$value), cell_num(7, 2), hu(cell_lex(7, 2)),
          paste0("largest printed: ", hit_o2$item_name, " row ", hit_o2$printed_row))
add_check("highest_CBF", "Highest of all (picrotoxin convulsion) blood flow vs flow printed on the row with the largest O2 uptake", hit_o2$value_flow, cell_num(7, 3), NA_real_,
          paste0("that row prints flow ", hit_o2$value_flow, "; the largest flow printed anywhere in TABLES 1-5 is ", max(pfl$value),
                 "; the printed 91 does not occur in TABLES 1-5"), status = "not_evaluable")
rec <- both[abs(both$value_o2 - cell_num(8, 2)) < 1e-9 & abs(both$value_flow - cell_num(8, 3)) < 1e-9, ]
add_check("lowest_with_recovery_pair", "Lowest with recovery (hemorrhage): O2 uptake and flow pair printed on one row of TABLES 1-5",
          if (nrow(rec)) cell_num(8, 2) else NA_real_, cell_num(8, 2), 0,
          if (nrow(rec)) paste0("found: ", rec$item_name[1], " row ", rec$printed_row[1]) else "pair not found")
low <- both[which.min(both$value_o2), ]
add_check("lowest_of_all_O2", "Lowest of all (moribund) O2 uptake vs smallest O2 uptake printed in TABLES 1-5", min(po2$value), cell_num(9, 2), NA_real_,
          paste0("smallest printed: ", low$value_o2, " (", low$item_name, " row ", low$printed_row, ", flow ", low$value_flow,
                 "); 0.39 and 5 do not occur in TABLES 1-5"), status = "not_evaluable")

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
