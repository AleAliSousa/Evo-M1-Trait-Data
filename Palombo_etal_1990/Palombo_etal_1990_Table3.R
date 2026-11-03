# Palombo_etal_1990_Table3.R --------------------------------------------------
#
# Palombo, Porrino, Bankiewicz, Crane, Sokoloff & Kopin (1990), J Neurosci
# 10(3): 860-869. Table 3, rates of glucose utilization (µmol/100 gm/min) in
# cerebral hemispheres, p. 864, of MPTP-induced hemiparkinsonian monkeys (mean ± SEM).
#
# Reads the frozen snapshot (Palombo_etal_1990_Table3_snapshot.csv, written by
# Palombo_etal_1990_extract_snapshot.R). The five Palombo table scripts are the
# same reader; only the item name (taken from this file's name) differs, and
# the table checks that apply to this table are selected by `locus`.
#   - one analysis row per printed cell (structure x 4 arms), in printed order,
#     reading along each row: Controls Right, Controls Left, Hemiparkinsonian
#     Lesioned side, Hemiparkinsonian Unlesioned side;
#   - mean / SEM lexemes and footnote marks split out; footnote letters are
#     table-specific (see the printed footnote rows of the snapshot);
#   - units µmol/100 g/min are the project unit; no conversion.
# All 8 monkeys (Macaca mulatta) were CONSCIOUS, seated in a primate chair, at
# least 3 h after light halothane/N2O anesthesia for catheter placement.
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
stopifnot(ncol(snap) == 5L, grepl(paste0("^", sub("Table", "Table ", locus), "\\. Rates of glucose utilization"), snap[1, 1]),
          identical(snap[2, ], c("", "Controls (n = 4)", "", "Hemiparkinsonian (n = 4)", "")),
          identical(snap[3, ], c("Structure", "Right", "Left", "Lesioned", "Unlesioned")))
rows <- which(seq_len(nrow(snap)) > 3L & grepl("±", snap[, 2]))
footnotes <- snap[-c(1:3, rows), 1]
stopifnot(all(rows == 3L + seq_along(rows)))

spanner <- snap[2, ]; for (j in 3:5) if (!nzchar(spanner[j])) spanner[j] <- spanner[j - 1]
arms <- data.frame(
  col       = 2:5,
  group     = spanner[2:5],
  column    = snap[3, 2:5],
  arm_id    = c("control_right", "control_left", "mptp_lesioned_side", "mptp_unlesioned_side"),
  n         = 4L,
  measure   = "CMRglc",
  unit      = "µmol/100 gm/min",
  disp_type = "SEM",
  stringsAsFactors = FALSE)
final.dataframe <- long_cells(snap, rows, arms, section = rep(NA_character_, nrow(snap)),
                              species = "Macaca mulatta")
final.dataframe$footnote_text <- vapply(final.dataframe$footnote_marks, function(m) {
  if (is.na(m)) return(NA_character_)
  ks <- strsplit(m, "; ", fixed = TRUE)[[1]]
  paste(vapply(ks, function(k) { f <- footnotes[grepl(paste0("\\^", k, " "), footnotes)]
    if (length(f)) f[1] else NA_character_ }, character(1)), collapse = " | ")
}, character(1), USE.NAMES = FALSE)
stopifnot(!anyNA(final.dataframe$value_numeric))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## No totals are printed. What the paper allows:
##  (1) RESULTS p. 862 (and the abstract) restate side-to-side % differences for
##      named structures; recomputed as 100 x (lesioned/unlesioned - 1). Each
##      printed integer mean is uncertain by ±0.5, so the tolerance is the
##      propagated relative rounding of the two means plus half a unit of the
##      printed percentage.
##  (2) footnote b of Tables 2 and 3: "the 2 sides differ by less than 5%".
##      Checked as: is a difference below 5% reachable within rounding of the
##      two printed means? observed = smallest reachable % difference.

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

cell <- function(structure, arm) final.dataframe$value_numeric[
  final.dataframe$structure_as_published == structure & final.dataframe$arm_id == arm]
pct_check <- function(id, structure, printed_pct, where) {
  L <- cell(structure, "mptp_lesioned_side"); U <- cell(structure, "mptp_unlesioned_side")
  obs <- 100 * (L / U - 1)
  tol <- 100 * (L / U) * (0.5 / L + 0.5 / U) + 0.5
  chk(id, paste0(where, ": ", structure, " lesioned vs unlesioned side, printed ", printed_pct, "%"),
      obs, printed_pct, tol)
}
lt5_check <- function(id, structure) {
  L <- cell(structure, "mptp_lesioned_side"); U <- cell(structure, "mptp_unlesioned_side")
  reach <- 100 * max(0, abs(L - U) - 1) / (max(L, U) + 0.5)
  chk(id, paste0("footnote b: ", structure, " lesioned ", L, " vs unlesioned ", U,
                 " 'differ by less than 5%'; observed = smallest % difference reachable within rounding"),
      reach, 5, 0, sprintf("printed means differ by %.1f%%; pass means a <5%% difference is reachable within rounding",
                           100 * abs(L - U) / max(L, U)))
}
fix_lt <- function(tc) { tc$status <- ifelse(tc$observed < tc$printed, "pass", "mismatch"); tc }

table_checks <- switch(locus,
  Table1 = rbind(
    pct_check("pct_GPe_results",  "Globus pallidus external", 41, "RESULTS p. 862 '(+41% compared to the unlesioned side)'"),
    pct_check("pct_GPe_abstract", "Globus pallidus external", 40, "Abstract p. 860 '(+40%)'"),
    pct_check("pct_DLcaudate",    "Dorsolateral caudate", 10, "RESULTS p. 862 '(+10%)'"),
    pct_check("pct_post_dorsal_putamen",  "Posterior dorsal putamen", 19, "RESULTS p. 862 '(+17 to +19%)' upper"),
    pct_check("pct_post_ventral_putamen", "Posterior ventral putamen", 17, "RESULTS p. 862 '(+17 to +19%)' lower"),
    pct_check("pct_STN",          "Subthalamic nucleus", -17, "RESULTS p. 862 / Abstract '(-17%)'"),
    chk("n_rows", "structure rows in Table 1", length(rows), 18, 0)),
  Table2 = rbind(
    fix_lt(lt5_check("lt5_VA", "Ventral anterior")),
    fix_lt(lt5_check("lt5_Pf", "Parafascicular nucleus")),
    chk("n_rows", "structure rows in Table 2", length(rows), 15, 0)),
  Table3 = rbind(
    fix_lt(lt5_check("lt5_premotor", "Premotor cortex")),
    chk("n_rows", "structure rows in Table 3", length(rows), 14, 0)),
  Table4 = rbind(
    chk("n_rows", "structure rows in Table 4", length(rows), 15, 0)),
  Table5 = rbind(
    pct_check("pct_PPN", "Pedunculopontine nucleus", 15, "RESULTS p. 862 / Abstract '(+15%)'"),
    chk("n_rows", "structure rows in Table 5", length(rows), 20, 0))
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
doi <- "10.1523/JNEUROSCI.10-03-00860.1990"
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
