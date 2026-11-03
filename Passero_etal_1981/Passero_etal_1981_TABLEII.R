# Passero_etal_1981_TABLEII.R -------------------------------------------------
#
# Passero, Carli & Battistini (1981), Neuroscience Letters 21: 345-349.
# TABLE II "Local cerebral glucose utilization (µmol/100 g/min)", p. 348.
# Conscious New Zealand White rabbits (catheters under local anesthesia ~1 h
# before the [14C]deoxyglucose pulse); Control (n = 5) vs animal Hypnosis
# (tonic immobility, n = 5), means ± S.E.
#
# Reads the frozen snapshot (Passero_etal_1981_TABLEII_snapshot.csv, written by
# Passero_etal_1981_extract_snapshot.R):
#   - one analysis row per printed cell (22 structures x 3 printed columns:
#     Control, Hypnosis, % Decrease), in printed order;
#   - significance stars kept in footnote_marks;
#   - units µmol/100 g/min are the project unit; no conversion.
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
stopifnot(identical(dim(snap), c(26L, 4L)), snap[1, 1] == "TABLE II",
          identical(snap[4, ], c("Structure", "Control (n = 5)", "Hypnosis (n = 5)", "% Decrease")))
rows <- 5:26
arms <- data.frame(
  col       = 2:4,
  group     = NA_character_,
  column    = snap[4, 2:4],
  arm_id    = c("control", "hypnosis", "pct_decrease_hypnosis"),
  n         = c(5L, 5L, 5L),
  measure   = c("CMRglc", "CMRglc", "CMRglc_pct_decrease"),
  unit      = c("µmol/100 g/min", "µmol/100 g/min", "% of control"),
  disp_type = c("SE", "SE", NA),
  stringsAsFactors = FALSE)
final.dataframe <- long_cells(snap, rows, arms, section = rep(NA_character_, nrow(snap)),
                              species = "rabbits (New Zealand White)")
final.dataframe$note[!is.na(final.dataframe$footnote_marks)] <-
  "Stars: * P < 0.05; ** P < 0.01; *** P < 0.005 by Student's t-test (hypnosis vs control)."
stopifnot(nrow(final.dataframe) == 66L, !anyNA(final.dataframe$value_numeric))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## % Decrease = 100 x (Control - Hypnosis) / Control, recomputed per row from the
## two printed means. Tolerance: rounding of the two printed means (±0.05 each,
## propagated) plus half a unit (0.05) of the printed percentage.

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

wide <- reshape(final.dataframe[, c("structure_order", "structure_as_published", "arm_id", "value_numeric")],
                idvar = c("structure_order", "structure_as_published"), timevar = "arm_id",
                direction = "wide")
C <- wide$value_numeric.control; H <- wide$value_numeric.hypnosis; P <- wide$value_numeric.pct_decrease_hypnosis
table_checks <- chk(paste0("pct_decrease_", wide$structure_order),
                    paste0("% Decrease = 100 x (Control - Hypnosis)/Control [row ", wide$structure_order,
                           ": ", wide$structure_as_published, "]"),
                    100 * (C - H) / C, P, 100 * 0.05 / C + 100 * H * 0.05 / C^2 + 0.05)

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
doi <- "10.1016/0304-3940(81)90228-7"
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
