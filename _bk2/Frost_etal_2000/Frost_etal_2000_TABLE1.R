# Frost_etal_2000_TABLE1.R ---------------------------------------------------
#
# Frost, Milliken, Plautz, Masterton & Nudo (2000), J Comp Neurol 421: 29-51.
# TABLE 1 "Area Measurements (in mm2) and Percentages of Body Part
# Representations Within Somatosensory Cortex", p. 36 (PDF page 8).
#
# Reads the frozen snapshot (Frost_etal_2000_TABLE1_snapshot.csv, written by
# Frost_etal_2000_TABLE1_extract_snapshot.R: one row per printed line, so each
# case's area line is followed by its percentage line) and does all the
# cleaning:
#   - one analysis row per printed value cell (cases 9213, 9321, 9324 and the
#     Average row x the seven measured columns), in the order the page is read
#     (along each row);
#   - each area cell paired with the percentage printed beneath it on the next
#     line; "mean +/- dispersion" split; numbers parsed;
#   - the printed column header kept verbatim beside a standardised label;
#   - the table's own relations re-run into `table_checks` (build HOWTO 7a),
#     with per-row notes where a printed value is not reproduced exactly.
# Areas are printed in mm2 and kept in mm2 (no conversion). No table value is
# typed in this script.
#
# 2026-11-07: rewritten for the line-by-line snapshot re-taken at the owner's
# request (area and percentage lines are separate snapshot rows); the analysis
# CSV keeps its 28 rows, 22 columns and values; only `snapshot_row` now points
# at the area line of the re-taken snapshot (3, 5, 7, 9). Table checks extended
# with the body-part percentage sums.
#
# R NOT RUN -- the analysis CSV and the public TSV now on disk were written on
# 2026-11-07 by a Python mirror of this script
# (Frost_etal_2000_TABLE1_python_mirror.py). Alexandra to run this script from a
# clean session and compare its outputs with the files on disk.
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

root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)

## ---- read the frozen snapshot ----------------------------------------------
## One row per printed line: 1 caption, 2 header, then an area line (case no.
## or "Average" in column 1) followed by its percentage line (column 1 blank)
## for each of the four printed rows, then the footnote lines ("^1..." first).
snap <- as.matrix(read.csv(paste0(base, "_snapshot.csv"), header = FALSE,
                           colClasses = "character", na.strings = character(0),
                           check.names = FALSE, encoding = "UTF-8"))
dimnames(snap) <- NULL
header_printed <- c("Case no.", "Tot. SS", "S1", "S2", "Digits", "Vibrissae", "Rostrum",
                    "HL/trunk")
fn_start  <- match(TRUE, startsWith(snap[, 1], "^1The three cases shown"))
stopifnot(!is.na(fn_start))
body      <- 3:(fn_start - 1L)
area_rows <- body[nzchar(snap[body, 1])]          # 3, 5, 7, 9
pct_rows  <- body[!nzchar(snap[body, 1])]         # 4, 6, 8, 10: the line beneath each
stopifnot(identical(dim(snap), c(13L, 8L)),
          startsWith(snap[1, 1], "TABLE 1. Area Measurements"),
          identical(snap[2, ], header_printed),
          identical(fn_start, 11L), identical(pct_rows, area_rows + 1L),
          all(grepl("^[0-9]{4}$", snap[area_rows[1:3], 1])), snap[area_rows[4], 1] == "Average",
          all(snap[pct_rows, 1:2] == ""), all(grepl("^\\(.*%\\)$", snap[pct_rows, 3:8])))

## ---- cell helpers: "4.33 +/- 0.65", "(68.0 +/- 3.6%)" ----------------------------
## Each printed cell is split into its printed mean lexeme and dispersion
## lexeme. Nothing is repaired: the lexemes are kept, and the numbers are parsed
## from them.
PM <- "\u00b1"
unparen     <- function(x) sub("^\\((.*)\\)$", "\\1", x)
mean_lexeme <- function(x) ifelse(is.na(x), NA_character_,
                                  trimws(sub(paste0("\\s*", PM, ".*$"), "", x)))
disp_lexeme <- function(x) ifelse(!is.na(x) & grepl(PM, x, fixed = TRUE),
                                  trimws(sub(paste0("^.*", PM, "\\s*"), "", x)), NA_character_)
num_of  <- function(x) suppressWarnings(as.numeric(gsub("[()%]", "", x)))
unit_of <- function(lex) {             # one unit in the last printed decimal place
  s <- gsub("[^0-9.]", "", lex)
  ifelse(is.na(s), NA_real_,
         ifelse(grepl(".", s, fixed = TRUE), 10^-nchar(sub("^[^.]*\\.", "", s)), 1))
}

## ---- standardised labels ----------------------------------------------------
## From the paper's own definitions: abbreviation list (p. 30: Tot. SS = total
## somatosensory area; S1 = primary, S2 = secondary somatosensory cortex;
## HL = hindlimb), footnote 1 (percentage bases: S1 and S2 relative to Tot. SS;
## body parts relative to S1, measured within S1 only) and Results p. 33
## (rostrum = glabrous snout, mystacial vibrissae, lower jaw, lips, oral cavity).
labels <- data.frame(
  column_as_printed = header_printed[-1],
  representation    = c("Tot_SS", "S1", "S2", "S1_digits", "S1_vibrissae", "S1_rostrum",
                        "S1_hindlimb_trunk"),
  cortical_field    = c("S1+S2", "S1", "S2", "S1", "S1", "S1", "S1"),
  percentage_base   = c(NA, "Tot. SS", "Tot. SS", "S1", "S1", "S1", "S1"),
  stringsAsFactors = FALSE)

## ---- long table: one row per printed value cell, read along each row ---------
## The area comes from the area line (snapshot_row); the percentage printed
## beneath it from the next snapshot row (blank under Tot. SS).
cells <- expand.grid(snapshot_col = 2:8, snapshot_row = area_rows)
area_printed <- snap[cbind(cells$snapshot_row, cells$snapshot_col)]
pct_printed  <- snap[cbind(cells$snapshot_row + 1L, cells$snapshot_col)]
pct_printed[!nzchar(pct_printed)] <- NA_character_
case_no <- snap[cells$snapshot_row, 1]
is_avg  <- case_no == "Average"
lab     <- labels[match(snap[2, cells$snapshot_col], labels$column_as_printed), ]
pct_inner    <- unparen(pct_printed)
n_cases      <- length(unique(case_no[!is_avg]))

final.dataframe <- data.frame(
  snapshot_row         = cells$snapshot_row,
  snapshot_col         = cells$snapshot_col,
  case_no_as_printed   = case_no,
  case_id              = ifelse(is_avg, NA_character_, case_no),
  statistic            = ifelse(is_avg, "mean of cases", "individual case"),
  n_cases              = ifelse(is_avg, n_cases, 1L),
  column_as_printed    = lab$column_as_printed,
  representation       = lab$representation,
  cortical_field       = lab$cortical_field,
  percentage_base      = lab$percentage_base,
  cell_as_printed      = ifelse(is.na(pct_printed), area_printed, paste(area_printed, pct_printed)),
  area_printed         = area_printed,
  percentage_printed   = pct_printed,
  area_mm2             = num_of(mean_lexeme(area_printed)),
  area_sd_mm2          = num_of(disp_lexeme(area_printed)),
  percentage           = num_of(mean_lexeme(pct_inner)),
  percentage_sd        = num_of(disp_lexeme(pct_inner)),
  dispersion_type      = NA_character_,
  species_as_published = "Monodelphis domestica",   # title and METHODS; the table prints none
  species              = NA_character_,
  data_role            = "primary",
  note                 = NA_character_,
  stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 28L, !anyNA(final.dataframe$area_mm2),
          sum(is.na(final.dataframe$percentage)) == 4L)     # Tot. SS prints no percentage

## ---- species ------------------------------------------------------------------
## Collection-scoped key: _keys/General/species_key.csv, rows with
## source_publication == this folder's name. Until those rows are adopted, the
## proposed rows in reference_tables/<paper>_species_key_proposed.csv (same
## schema) are used and the run says so. No mapping is hand-coded here.
read_key <- function(f) {
  if (!file.exists(f)) return(NULL)
  k <- read.csv(f, stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
  k[trimws(k$source_publication) == paper, , drop = FALSE]
}
key <- read_key(file.path(root, "_keys", "General", "species_key.csv"))
if (is.null(key) || nrow(key) == 0L) {
  key <- read_key(file.path(folder, "reference_tables", paste0(paper, "_species_key_proposed.csv")))
  message(item_name, ": no '", paper, "' rows in _keys/General/species_key.csv yet; species ",
          "resolved from reference_tables/", paper, "_species_key_proposed.csv (adopt those rows).")
}
if (is.null(key) || nrow(key) == 0L) stop("No species key rows for ", paper, call. = FALSE)
final.dataframe$species <- key$accepted_name[match(tolower(trimws(final.dataframe$species_as_published)),
                                                   tolower(trimws(key$variant_name)))]
stopifnot(!anyNA(final.dataframe$species))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## Relations the table prints or its footnote defines:
##  (1) Tot. SS = S1 + S2, for each case and for the Average means;
##  (2) S1 % and S2 % = 100 x area / Tot. SS, body-part % = 100 x area / S1
##      (footnote 1), for each case; the note gives the recomputed percentage
##      rounded to the printed precision;
##  (3) S1 % + S2 % = 100, for each case and for the Average means;
##  (4) body-part percentages summed within each case: recorded, not tested.
##      They have no total of 100 to meet: the rostrum includes the vibrissae
##      (Results p. 33), so the four parts overlap, and they need not cover S1.
##      Status not_evaluable, with the sums in the note;
##  (5) Average = mean of the cases, and its dispersion = their sample SD
##      (n - 1), for every area column and every percentage column.
## Tolerance = only what rounding of the printed cells can explain: half a unit
## of each input's last printed decimal per summed cell; one unit of the printed
## percentage for a recomputed percentage; for a mean, half a unit of the inputs
## plus half a unit of the printed mean; for an SD, sqrt(n / (n - 1)) x half a
## unit of the inputs plus half a unit of the printed SD. `note` says whether the
## printed value is also reproduced exactly at its printed precision. Values are
## never changed; mismatches are warned and kept as printed.
CASE <- "individual case"; AVG <- "mean of cases"
lx <- data.frame(rep = final.dataframe$representation, stat = final.dataframe$statistic,
                 uA   = unit_of(mean_lexeme(area_printed)),
                 uAsd = unit_of(disp_lexeme(area_printed)),
                 uP   = unit_of(mean_lexeme(pct_inner)),
                 uPsd = unit_of(disp_lexeme(pct_inner)), stringsAsFactors = FALSE)
v <- function(col, r, s) final.dataframe[[col]][final.dataframe$representation == r &
                                                  final.dataframe$statistic == s]
u <- function(col, r, s) lx[[col]][lx$rep == r & lx$stat == s]
lbl <- function(r) labels$column_as_printed[match(r, labels$representation)]
base_of <- function(r) labels$representation[match(labels$percentage_base[match(r, labels$representation)],
                                                   labels$column_as_printed)]
case_ids <- unique(final.dataframe$case_no_as_printed[final.dataframe$statistic == CASE])
sd_factor <- sqrt(n_cases / (n_cases - 1))
f3 <- function(x) sprintf("%.3f", x)
exact <- function(observed, printed, unit) abs(observed - printed) <= unit / 2 + 1e-9
at_precision <- function(x, unit) sprintf("%.*f", as.integer(round(-log10(unit))), x)

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable",
                             ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
exact_note <- function(observed, printed, unit)
  paste0("exact at printed precision: ", ifelse(exact(observed, printed, unit), "yes", "no"))

## (1) Tot. SS = S1 + S2
tc_sum <- chk(paste0("tot_ss_eq_s1_plus_s2_", c(case_ids, "Average")),
              paste0("Tot. SS = S1 + S2 (areas) [", c(case_ids, "Average"), "]"),
              c(v("area_mm2", "S1", CASE) + v("area_mm2", "S2", CASE),
                v("area_mm2", "S1", AVG) + v("area_mm2", "S2", AVG)),
              c(v("area_mm2", "Tot_SS", CASE), v("area_mm2", "Tot_SS", AVG)),
              c(u("uA", "S1", CASE) / 2 + u("uA", "S2", CASE) / 2,
                u("uA", "S1", AVG) / 2 + u("uA", "S2", AVG) / 2))

## (2) percentage = 100 x area / base area, per case
pct_reps <- labels$representation[!is.na(labels$percentage_base)]
tc_pct <- do.call(rbind, lapply(pct_reps, function(r) {
  b <- base_of(r)
  obs <- 100 * v("area_mm2", r, CASE) / v("area_mm2", b, CASE)
  chk(paste0("pct_", r, "_", case_ids),
      paste0(lbl(r), " % = 100 x ", lbl(r), " / ", lbl(b), " (areas) [", case_ids, "]"),
      obs, v("percentage", r, CASE), u("uP", r, CASE),
      paste0(exact_note(obs, v("percentage", r, CASE), u("uP", r, CASE)),
             " (recomputed ", f3(obs), "% rounds to ", at_precision(obs, u("uP", r, CASE)),
             "%; printed ", mean_lexeme(pct_inner[final.dataframe$representation == r &
                                                  final.dataframe$statistic == CASE]), ")"))
}))

## (3) S1 % + S2 % = 100
tc_100 <- chk(paste0("pct_s1_plus_s2_eq_100_", c(case_ids, "Average")),
              paste0("S1 % + S2 % = 100 [", c(case_ids, "Average"), "]"),
              c(v("percentage", "S1", CASE) + v("percentage", "S2", CASE),
                v("percentage", "S1", AVG) + v("percentage", "S2", AVG)),
              100,
              c(u("uP", "S1", CASE) / 2 + u("uP", "S2", CASE) / 2,
                u("uP", "S1", AVG) / 2 + u("uP", "S2", AVG) / 2))

## (4) body-part percentages within each case: summed and recorded, not tested
bp_reps <- pct_reps[labels$percentage_base[match(pct_reps, labels$representation)] == "S1"]
tc_bpsum <- do.call(rbind, lapply(seq_along(case_ids), function(i) {
  p <- vapply(bp_reps, function(r) v("percentage", r, CASE)[i], numeric(1))
  q <- vapply(bp_reps, function(r) 100 * v("area_mm2", r, CASE)[i] / v("area_mm2", "S1", CASE)[i],
              numeric(1))
  up <- vapply(bp_reps, function(r) u("uP", r, CASE)[i], numeric(1))
  nv <- bp_reps != "S1_vibrissae"
  data.frame(check_id = paste0("pct_body_parts_sum_", case_ids[i]),
             basis = paste0(paste(lbl(bp_reps), "%", collapse = " + "), " summed [", case_ids[i], "]"),
             observed = sum(p), printed = 100, difference = sum(p) - 100,
             tolerance = sum(up) / 2, status = "not_evaluable",
             note = paste0("No total of 100 to test: the Vibrissae area lies within the Rostrum ",
                           "area (Results p. 33) and the four parts need not cover S1. Printed ",
                           "percentages sum to ", sum(p), "%; from 100 x area / S1 ", f3(sum(q)),
                           "%; without Vibrissae ", sum(p[nv]), "% (", f3(sum(q[nv])),
                           "% from areas). Kept as printed."),
             stringsAsFactors = FALSE)
}))

## (5a) Average areas = mean and sample SD of the cases
tc_area <- do.call(rbind, lapply(labels$representation, function(r) {
  x <- v("area_mm2", r, CASE); ux <- max(u("uA", r, CASE))
  m <- v("area_mm2", r, AVG);  s  <- v("area_sd_mm2", r, AVG)
  rbind(
    chk(paste0("mean_area_", r),
        paste0("Average ", lbl(r), " area = mean of the ", n_cases, " cases"),
        mean(x), m, ux / 2 + u("uA", r, AVG) / 2, exact_note(mean(x), m, u("uA", r, AVG))),
    chk(paste0("sd_area_", r),
        paste0("Average ", lbl(r), " area dispersion = sample SD (n - 1) of the ", n_cases, " cases"),
        sd(x), s, sd_factor * ux / 2 + u("uAsd", r, AVG) / 2,
        exact_note(sd(x), s, u("uAsd", r, AVG))))
}))

## (5b) Average percentages = mean and sample SD of the printed case percentages.
## The note also gives the same statistic from percentages recomputed from the
## printed areas (100 x area / base), to show which basis the print used.
tc_ppct <- do.call(rbind, lapply(pct_reps, function(r) {
  p <- v("percentage", r, CASE); up <- max(u("uP", r, CASE))
  q <- 100 * v("area_mm2", r, CASE) / v("area_mm2", base_of(r), CASE)
  m <- v("percentage", r, AVG); s <- v("percentage_sd", r, AVG)
  um <- u("uP", r, AVG); us <- u("uPsd", r, AVG)
  alt <- function(stat, printed, unit)
    paste0("; from 100 x area / ", lbl(base_of(r)), ": ", f3(stat), " (exact: ",
           ifelse(exact(stat, printed, unit), "yes", "no"), ")")
  rbind(
    chk(paste0("mean_pct_", r),
        paste0("Average ", lbl(r), " % = mean of the ", n_cases, " printed case percentages"),
        mean(p), m, up / 2 + um / 2,
        paste0(exact_note(mean(p), m, um), alt(mean(q), m, um))),
    chk(paste0("sd_pct_", r),
        paste0("Average ", lbl(r), " % dispersion = sample SD (n - 1) of the ", n_cases,
               " printed case percentages"),
        sd(p), s, sd_factor * up / 2 + us / 2,
        paste0(exact_note(sd(p), s, us), alt(sd(q), s, us))))
}))

table_checks <- rbind(tc_sum, tc_pct, tc_100, tc_bpsum, tc_area, tc_ppct)
rownames(table_checks) <- NULL
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]], "  (of ", nrow(table_checks), ")")
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- per-row notes kept with the data --------------------------------------------
add_note <- function(df, rows, txt) {
  df$note[rows] <- ifelse(is.na(df$note[rows]), txt, paste(df$note[rows], txt, sep = " | "))
  df
}
avg_rows <- which(final.dataframe$statistic == AVG)
sd_all_pass <- all(table_checks$status[grepl("^sd_", table_checks$check_id)] == "pass")
final.dataframe$dispersion_type[avg_rows] <- if (sd_all_pass) "SD" else "not stated"
final.dataframe <- add_note(final.dataframe, avg_rows, paste0(
  "Average row: printed mean ", PM, " dispersion of the ", n_cases, " cases. The print does not ",
  "say SD or SEM; ", if (sd_all_pass)
    "every printed dispersion reproduces as the sample SD (n - 1) of the case rows within rounding (table_checks)."
  else "not every printed dispersion reproduces as the sample SD of the case rows (see table_checks)."))

## A printed Average percentage that the printed case percentages do not
## reproduce exactly is explained on its row, with both bases.
for (r in pct_reps) {
  p <- v("percentage", r, CASE)
  q <- 100 * v("area_mm2", r, CASE) / v("area_mm2", base_of(r), CASE)
  row <- which(final.dataframe$representation == r & final.dataframe$statistic == AVG)
  for (what in c("mean", "SD")) {
    fun     <- if (what == "mean") mean else sd
    printed <- if (what == "mean") final.dataframe$percentage[row] else final.dataframe$percentage_sd[row]
    lexeme  <- if (what == "mean") mean_lexeme(pct_inner[row]) else disp_lexeme(pct_inner[row])
    unit    <- if (what == "mean") u("uP", r, AVG) else u("uPsd", r, AVG)
    status  <- table_checks$status[match(paste0(if (what == "mean") "mean_pct_" else "sd_pct_", r),
                                         table_checks$check_id)]
    if (!exact(fun(p), printed, unit))
      final.dataframe <- add_note(final.dataframe, row, paste0(
        "Printed percentage ", what, " ", lexeme, " is not reproduced from the printed case ",
        "percentages (", paste(p, collapse = ", "), " give ", f3(fun(p)), ") ",
        if (exact(fun(q), printed, unit)) "but is reproduced" else "nor",
        " from 100 x area / ", lbl(base_of(r)), " (", paste(f3(q), collapse = ", "), " give ",
        f3(fun(q)), "); ", if (status == "pass")
          "within the rounding tolerance of the printed cells (table_checks: pass)"
        else paste0("table_checks: ", status), "; kept as printed."))
  }
}
stray <- which(final.dataframe$statistic == AVG & grepl("%", mean_lexeme(pct_inner), fixed = TRUE))
final.dataframe <- add_note(final.dataframe, stray, paste0(
  "Percentage cell typeset with a '%' after the mean as well as after the dispersion, unlike ",
  "the other Average percentage cells; kept as printed."))
overlap <- which(final.dataframe$representation %in% c("S1_vibrissae", "S1_rostrum"))
final.dataframe <- add_note(final.dataframe, overlap, paste0(
  "Not additive with the other S1 body-part columns: the Results (p. 33) define the rostrum ",
  "as the glabrous snout, mystacial vibrissae, lower jaw, lips and oral cavity, so the ",
  "Vibrissae area lies within the Rostrum area."))

## ---- outputs ----------------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ----------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name (never by row number).
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  if (dir.exists(tsv_dir)) {
    write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
    message(item_name, ": public TSV ", item_encoded, ".tsv")
  } else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
} else warning(item_name, ": __ReadMe.xlsx not found above ", folder, "; public TSV not written.")
