# Heiss_etal_1985_Text.R --------------------------------------------
#
# Heiss, Pawlik, Herholz, Wagner & Wienhard (1985), Brain Research 327: 362-366.
# Values printed in the ABSTRACT (p. 362) and RESULTS (p. 364) rather than in a
# table. Reads the constructed, frozen snapshot
# Heiss_etal_1985_Text_snapshot.csv (one row per printed value,
# written by Heiss_etal_1985_extract_snapshot.R), classifies each value as NEW
# (printed nowhere else) or a RESTATEMENT of a TABLE I cell, and checks every
# restatement against the frozen TABLE I snapshot.
#
# Only one value is new: the non-dreamers' whole-brain rate DURING SLEEP,
# 31.6 ± 1.42 µmol/100 g/min (RESULTS, p. 364). TABLE I prints that state only
# as a % change.
# No value is typed in this script.

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

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## ---- cell helpers: a printed cell "57 ± 5^b,c" / "- 9.2 ± 9.84" / "34.1**" ---------
## is split into its printed mean lexeme, printed dispersion lexeme and footnote
## marks; the numbers are parsed from those lexemes. Nothing is repaired.
marks_of <- function(x) {
  m <- ifelse(grepl("\\^[a-z](,[a-z])*$", x), sub("^.*\\^([a-z](,[a-z])*)$", "\\1", x),
       ifelse(grepl("\\*+$", x), sub("^.*?(\\*+)$", "\\1", x), NA_character_))
  gsub(",", "; ", m, fixed = TRUE)
}
strip_marks <- function(x) trimws(sub("(\\^[a-z](,[a-z])*|\\*+)$", "", x))
mean_lexeme <- function(x) { s <- strip_marks(x); trimws(sub("\\s*±.*$", "", s)) }
disp_lexeme <- function(x) { s <- strip_marks(x); ifelse(grepl("±", s), trimws(sub("^.*±\\s*", "", s)), NA_character_) }
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))   # "- 9.2" -> -9.2, "+ 7.4" -> 7.4

tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 8L, identical(tx$text_row, as.character(1:8)))
t1 <- read_snapshot(paste0(paper, "_TABLEI_snapshot.csv"))
stopifnot(identical(dim(t1), c(33L, 5L)))
t1_cell <- function(region_label, col) t1[match(region_label, gsub("\n", " ", t1[, 1], fixed = TRUE)), col]
WB <- "Whole brain (all regions weighted according to size)"

final.dataframe <- data.frame(
  text_row             = as.integer(tx$text_row),
  page                 = tx$page,
  location             = tx$location,
  passage_as_printed   = tx$passage_as_printed,
  subjects_as_printed  = tx$subjects_as_printed,
  state_as_printed     = tx$state_as_printed,
  region_as_printed    = tx$region_as_printed,
  value_printed        = tx$value_printed,
  dispersion_printed   = ifelse(nzchar(tx$dispersion_printed), tx$dispersion_printed, NA_character_),
  dispersion_type      = ifelse(nzchar(tx$dispersion_printed), "SD", NA_character_),
  units_printed        = tx$units_printed,
  value_numeric        = num_of(tx$value_printed),
  dispersion_numeric   = num_of(tx$dispersion_printed),
  stringsAsFactors = FALSE)
final.dataframe$measure <- ifelse(grepl("^%", tx$units_printed), "CMRglc_pct_change_asleep", "CMRglc")
final.dataframe$CMRglc.umol_100g_min <- ifelse(final.dataframe$measure == "CMRglc",
                                               final.dataframe$value_numeric, NA_real_)
final.dataframe$n <- ifelse(grepl("non-dream|3 of the subjects", tx$subjects_as_printed), 3L, 1L)
## which TABLE I cell (if any) the text value restates
restates <- c(`1` = paste0("TABLE I | ", WB, " | Non-dreamers % Change asleep"),
              `2` = "TABLE I | Lentiform nucleus | Dreamer % Change asleep",
              `3` = "TABLE I | Sup. front. cortex | Dreamer % Change asleep",
              `4` = paste0("TABLE I | ", WB, " | Dreamer % Change asleep"),
              `5` = paste0("TABLE I | ", WB, " | Dreamer Awake"),
              `6` = paste0("TABLE I | ", WB, " | Non-dreamers Awake"),
              `7` = NA_character_,
              `8` = paste0("TABLE I | ", WB, " | Dreamer % Change asleep"))
final.dataframe$restates_cell <- unname(restates[tx$text_row])
final.dataframe$value_status  <- ifelse(is.na(final.dataframe$restates_cell), "new", "restatement")
final.dataframe$species_as_published <- "healthy male volunteers"
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$text_row == 7L] <-
  "Non-dreamers' whole-brain rate during sleep. Printed only here; TABLE I gives this state only as a % change (-12.6 ± 4.73)."
final.dataframe$note[final.dataframe$text_row == 1L] <-
  "Printed as a positive 'decrease ... averaging 12.6'; TABLE I prints the same quantity as -12.6."

## ---- table checks ---------------------------------------------------------------

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

v <- function(r) final.dataframe$value_numeric[final.dataframe$text_row == r]
s <- function(r) final.dataframe$dispersion_numeric[final.dataframe$text_row == r]
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
  ## inputs (±0.05 each, propagated) + half a unit of the printed 31.6.
  ## (A mean of ratios need not equal the ratio of means; this is a consistency
  ## check, not an identity.)
  chk("sleep_rate_vs_pct", "text row 7 31.6 vs TABLE I whole brain non-dreamers Awake x (1 + % change/100)",
      num_of(mean_lexeme(wb_nd_awake)) * (1 + num_of(mean_lexeme(wb_nd_pct)) / 100), v(7),
      0.05 * (1 + num_of(mean_lexeme(wb_nd_pct)) / 100) +
        num_of(mean_lexeme(wb_nd_awake)) * 0.05 / 100 + 0.05,
      "consistency, not identity: mean of individual ratios vs ratio of means")
)

tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not
## yet registered, the code is derived exactly as the registry formula would
## build it (DOI with "/" percent-encoded, "_", item locus) and the README says
## the item awaits registration; the registry stays the authority.
doi <- "10.1016/0006-8993(85)91537-9"
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
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
