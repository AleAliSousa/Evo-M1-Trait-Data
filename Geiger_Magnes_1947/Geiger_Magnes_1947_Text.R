# Geiger_Magnes_1947_Text.R ------------------------------------------
#
# Geiger, A., & Magnes, J. (1947). The isolation of the cerebral circulation and the perfusion of the brain in the living cat. American Journal of Physiology, 149(3), 517-537.
# DOI 10.1152/ajplegacy.1947.149.3.517.
#
# Values printed in running text rather than in a table. Reads the constructed,
# frozen snapshot Geiger_Magnes_1947_Text_snapshot.csv (one row per printed
# number, written by Geiger_Magnes_1947_extract_snapshot.R), parses each printed lexeme
# (single value, range 'a-b', bound '<x'), attaches the variable the passage
# reports (curator mapping by text_row below) and the merge's standard units,
# and checks restatements against the paper's own tables. No value is typed here.
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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base  <- item_name
paper <- basename(folder)
locus <- sub(paste0("^", paper, "_"), "", item_name)

doi <- "10.1152/ajplegacy.1947.149.3.517"

## ---- read the frozen snapshot (written by <paper>_extract_snapshot.R) ----------
read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)

## ---- cell helpers --------------------------------------------------------------
## A printed cell can carry a mean, "\u00b1 dispersion", a parenthesised number (n or a
## remark key, per item), trailing footnote marks (^a,b or * / **) and a second
## printed line. Each part is peeled off into its own field; nothing is repaired.
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
snake <- function(x) { x <- tolower(gsub("[^A-Za-z0-9]+", "_", x)); gsub("^_+|_+$", "", x) }

## Half a unit in the last printed decimal place ("3.39" -> 0.005, "76" -> 0.5).
hu <- function(lex) { s <- gsub("[^0-9.]", "", lex)
  d <- ifelse(grepl("\\.", s), nchar(sub("^[^.]*\\.", "", s)), 0); 0.5 * 10^(-d) }
## Half a unit in the last SIGNIFICANT digit (integer trailing zeros not significant: "660" -> 5).
hu_sig <- function(lex) { s <- gsub("[^0-9.]", "", lex)
  ifelse(grepl("\\.", s), hu(lex), { z <- nchar(s) - nchar(sub("0+$", "", s)); 0.5 * 10^z }) }
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

## ---- unit standardisation (the merge's factors) -----------------------------------
## CMRO2: ml O2 -> umol x 44.64 (as __merging_cerebral_metabolic_rate, O2_UMOL_PER_ML).
## CMRgl: mg glucose -> umol x 1000/180.16 (glucose molar mass 180.16 g/mol).
## CBF: ml/100 g/min is already the project unit.
O2_UMOL_PER_ML <- 44.64
GLC_UMOL_PER_MG <- 1000 / 180.16
std_of <- function(variable, value) {
  if (grepl("^CMRO2", variable)) return(list(value * O2_UMOL_PER_ML, "umol/100g/min", "ml O2 x 44.64"))
  if (grepl("^CMRgl", variable)) return(list(value * GLC_UMOL_PER_MG, "umol/100g/min", "mg glucose x 1000/180.16"))
  if (grepl("^CBF", variable))   return(list(value, "mL/100g/min", "none (already mL/100g/min)"))
  list(NA_real_, NA_character_, NA_character_)
}

## Byte-exact UTF-8 writer (write.csv in a non-UTF-8 session locale would escape
## characters such as en dashes as <U+2013>): character fields quoted, quotes doubled.
write_utf8_table <- function(df, file, sep, na) {
  cols <- lapply(df, function(x) {
    if (is.character(x)) { out <- paste0('"', gsub('"', '""', enc2utf8(x), fixed = TRUE), '"'); out[is.na(x)] <- na; out }
    else { out <- as.character(x); out[is.na(x)] <- na; out } })
  lines <- c(paste0('"', names(df), '"', collapse = sep), do.call(paste, c(cols, sep = sep)))
  con <- file(file, open = "wb"); writeLines(lines, con, useBytes = TRUE); close(con)
}

stopifnot(nrow(tx) == 19L, identical(tx$text_row, as.character(seq_len(19L))))
## curator mapping: the variable each printed number reports (by text_row)
variable_by_text_row <- c("CBF_ml_100g_min", "CBF_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CBF_ml_100g_min", "CBF_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min", "CMRO2_ml_100g_min")
lex <- trimws(tx$value_printed)
is_range <- grepl("^[0-9.]+-[0-9.]+$", lex); is_bound <- grepl("^[<>]", lex)
value <- ifelse(is_range | is_bound, NA_real_, num(lex))
value_low  <- ifelse(is_range, num(sub("-.*$", "", lex)), NA_real_)
value_high <- ifelse(is_range, num(sub("^.*-", "", lex)), ifelse(is_bound, num(sub("^[<>]", "", lex)), NA_real_))
final.dataframe <- data.frame(
  item_name = item_name, text_row = as.integer(tx$text_row), page = tx$page, location = tx$location,
  passage_as_printed = tx$passage_as_printed, variable = variable_by_text_row,
  value_printed = tx$value_printed, value = value, value_low = value_low, value_high = value_high,
  value_shape = ifelse(is_range, "range", ifelse(is_bound, "bound", "single")),
  dispersion_printed = ifelse(nzchar(tx$dispersion_printed), tx$dispersion_printed, NA_character_),
  dispersion = num(tx$dispersion_printed),
  dispersion_type = ifelse(nzchar(tx$dispersion_printed), "none", NA_character_),
  n_printed = ifelse(nzchar(tx$n_printed), tx$n_printed, NA_character_), n = num(tx$n_printed),
  units_printed = tx$units_printed, subjects_as_printed = tx$subjects_as_printed,
  state_as_printed = tx$state_as_printed, region_as_printed = tx$region_as_printed,
  value_role = tx$curator_value_role, cited_refs = ifelse(nzchar(tx$curator_cited_refs), tx$curator_cited_refs, NA_character_),
  stringsAsFactors = FALSE)
std <- lapply(seq_len(nrow(final.dataframe)), function(i) {
  v <- final.dataframe$variable[i]
  if (grepl("regression|^CO2|^pct|weight|total_brain", v)) return(list(NA_real_, NA_character_, NA_character_))
  std_of(v, final.dataframe$value[i]) })
final.dataframe$value_std  <- vapply(std, function(s) s[[1]], numeric(1))
final.dataframe$units_std  <- vapply(std, function(s) s[[2]], character(1))
final.dataframe$conversion <- vapply(std, function(s) s[[3]], character(1))
final.dataframe$note <- tx$curator_note

## ---- table checks (build HOWTO s.7a): restatements against the paper's tables --
## The text gives ranges and single-experiment values (figures 8, 10, 11) that no
## table prints exactly, so there is no exact relation to check.


tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$basis[i], bad$observed[i], bad$printed[i], bad$difference[i],
                    bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
write_utf8_table(final.dataframe, paste0(base, ".csv"), sep = ",", na = "NA")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not
## yet registered, the code is derived exactly as the registry formula would build
## it (DOI with "/" percent-encoded, "_", item locus) and the README says the item
## awaits registration; the registry stays the authority.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(gsub("/", "%2F", doi, fixed = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ",
          item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write_utf8_table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", na = "")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")

