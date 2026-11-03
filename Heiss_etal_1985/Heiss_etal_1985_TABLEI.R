# Heiss_etal_1985_TABLEI.R ----------------------------------------------------
#
# Heiss, Pawlik, Herholz, Wagner & Wienhard (1985), Brain Research 327: 362-366.
# TABLE I "Regional cerebral metabolic rate for glucose in normal human subjects
# during sleep and wakefulness (µmol/100 g/min)", p. 363.
#
# Reads the frozen snapshot (Heiss_etal_1985_TABLEI_snapshot.csv, written by
# Heiss_etal_1985_extract_snapshot.R) and does all the cleaning:
#   - one analysis row per printed cell (24 regions x 4 printed columns), in
#     printed order, reading along each row;
#   - splits each cell into its printed mean and S.D. lexemes and parses them;
#   - keeps the two kinds of column apart: the two "Awake" columns are rates
#     (µmol/100 g/min, the project unit, no conversion); the two "% Change
#     asleep" columns are percentages of the awake rate. The sleep RATE itself
#     is not printed (except for the whole brain of the non-dreamers, in the
#     text: see Heiss_etal_1985_Text) and is NOT computed here.
#   - writes the analysis CSV and the public TSV.
# No table value is typed in this script.

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

long_cells <- function(snap, rows, arms, section, species, structure = snap[rows, 1]) {
  out <- do.call(rbind, lapply(seq_len(nrow(arms)), function(k) {
    cell <- snap[rows, arms$col[k]]
    data.frame(printed_row = rows, structure_order = seq_along(rows),
               section_as_published = section[rows],
               structure_as_published = gsub("\n", " ", structure, fixed = TRUE),
               group_as_published = arms$group[k], column_as_published = arms$column[k],
               arm_id = arms$arm_id[k], n = arms$n[k],
               cell_as_printed = cell, mean_printed = mean_lexeme(cell),
               dispersion_printed = disp_lexeme(cell), dispersion_type = arms$disp_type[k],
               footnote_marks = marks_of(cell), measure = arms$measure[k],
               unit_as_printed = arms$unit[k], stringsAsFactors = FALSE)
  }))
  out$value_numeric        <- num_of(out$mean_printed)
  out$dispersion_numeric   <- num_of(out$dispersion_printed)
  out$CMRglc.umol_100g_min <- ifelse(out$measure == "CMRglc", out$value_numeric, NA_real_)
  out$species_as_published <- species
  out$note <- NA_character_
  out <- out[order(out$structure_order, match(out$arm_id, arms$arm_id)), ]
  rownames(out) <- NULL
  out
}

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(33L, 5L)), snap[1, 1] == "TABLE I",
          snap[3, 1] == "Region", snap[3, 2] == "Non-dreamers (n = 3)", snap[3, 4] == "Dreamer")
rows <- which(seq_len(nrow(snap)) > 4L & nzchar(snap[, 1]))
stopifnot(length(rows) == 24L)

spanner <- snap[3, ]; for (j in 3:5) if (!nzchar(spanner[j])) spanner[j] <- spanner[j - 1]
arms <- data.frame(
  col        = 2:5,
  group      = spanner[2:5],
  column     = gsub("\n", " ", snap[4, 2:5], fixed = TRUE),
  arm_id     = c("nondreamers_awake", "nondreamers_pct_change_asleep",
                 "dreamer_awake", "dreamer_pct_change_asleep"),
  n          = c(3L, 3L, 1L, 1L),                 # printed "(n = 3)"; the dreamer is one subject
  measure    = c("CMRglc", "CMRglc_pct_change_asleep", "CMRglc", "CMRglc_pct_change_asleep"),
  unit       = c("µmol/100 g/min", "% of awake", "µmol/100 g/min", "% of awake"),
  disp_type  = c("SD", "SD", NA, NA),
  stringsAsFactors = FALSE)

final.dataframe <- long_cells(snap, rows, arms, section = rep(NA_character_, nrow(snap)),
                              species = "normal human subjects")
final.dataframe$note[final.dataframe$printed_row == max(rows)] <-
  "Whole brain: all regions weighted according to size (printed row label)."
stopifnot(nrow(final.dataframe) == 96L, !anyNA(final.dataframe$value_numeric))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## The table prints no totals. Its whole-brain row is size-weighted with weights
## the paper does not give, so it cannot be recomputed from the regions. What
## the paper does allow: the abstract and RESULTS restate several cells, and
## the RESULTS text prints the non-dreamers' whole-brain SLEEP rate; those
## relations are checked in Heiss_etal_1985_Text.R. Here only the
## internal range claim of the abstract is structural and is checked there too.

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

wb <- final.dataframe[final.dataframe$printed_row == max(rows), ]
table_checks <- rbind(
  chk("dreamer_pct_min_is_lentiform",
      "Dreamer % Change asleep: smallest printed value is the Lentiform nucleus row (abstract: 'ranging from 2.1% in lentiform nucleus')",
      min(final.dataframe$value_numeric[final.dataframe$arm_id == "dreamer_pct_change_asleep"]),
      final.dataframe$value_numeric[final.dataframe$arm_id == "dreamer_pct_change_asleep" &
                                    final.dataframe$structure_as_published == "Lentiform nucleus"], 0),
  chk("dreamer_pct_max_is_sup_front",
      "Dreamer % Change asleep: largest printed value is the Sup. front. cortex row (abstract: 'to 30.0% in the superior frontal cortex')",
      max(final.dataframe$value_numeric[final.dataframe$arm_id == "dreamer_pct_change_asleep"]),
      final.dataframe$value_numeric[final.dataframe$arm_id == "dreamer_pct_change_asleep" &
                                    final.dataframe$structure_as_published == "Sup. front. cortex"], 0),
  chk("nondreamers_all_regions_decrease",
      "Non-dreamers % Change asleep: every region negative ('non-selective decrease'); observed = number of non-negative cells",
      sum(final.dataframe$value_numeric[final.dataframe$arm_id == "nondreamers_pct_change_asleep"] >= 0), 0, 0),
  chk("dreamer_all_regions_increase",
      "Dreamer % Change asleep: every region positive ('higher metabolic rates in all regions'); observed = number of non-positive cells",
      sum(final.dataframe$value_numeric[final.dataframe$arm_id == "dreamer_pct_change_asleep"] <= 0), 0, 0)
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
