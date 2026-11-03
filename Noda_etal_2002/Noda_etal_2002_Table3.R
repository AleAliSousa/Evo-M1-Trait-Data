# Noda_etal_2002_Table3.R -----------------------------------------------------
#
# Noda et al. (2002), Brain Research 936: 76-81. Table 2 (rCBF, ml/100 g/min) or
# Table 3 (rCMRglc, µmol/100 g/min), p. 79; selected by `locus` (the two Noda
# scripts are the same reader). Six young-adult (6.2 ± 0.8 y) and six aged
# (20.9 ± 1.2 y) male rhesus monkeys (Macaca mulatta), CONSCIOUS: head fixed by
# an implanted head-holder to a monkey chair after > 1 month of habituation.
#
# Reads the frozen snapshot and writes one analysis row per printed cell:
# 7 ROIs x (young, aged) x (Average, R or A, L or P), plus the printed Y–A (%)
# cells. Blank printed cells (Cerebellum R/L) are not rows. "R or A" = right
# hemisphere (anterior cingulate for the Cingulate row); "L or P" = left
# (posterior cingulate). No table value is typed in this script.

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
stopifnot(identical(dim(snap), c(15L, 10L)), identical(snap[4, 2:10], rep(c("Average", "R or A", "L or P"), 3)))
is_cbf <- grepl("blood flow", snap[2, 1])
rows <- 5:11
spanner <- snap[3, ]; for (j in 3:10) if (!nzchar(spanner[j])) spanner[j] <- spanner[j - 1]
grp <- ifelse(grepl("^Young", spanner), "young", ifelse(grepl("^Aged", spanner), "aged", "Y_minus_A"))
arms <- data.frame(col = 2:10, group = gsub("\n", " ", spanner[2:10], fixed = TRUE), column = snap[4, 2:10],
  arm_id = paste0(grp[2:10], "_", c("average", "R_or_A", "L_or_P")),
  n = c(rep(6L, 6), rep(NA_integer_, 3)),
  measure = c(rep(if (is_cbf) "CBF" else "CMRglc", 6), rep(if (is_cbf) "CBF_pct_Y_minus_A" else "CMRglc_pct_Y_minus_A", 3)),
  unit = c(rep(if (is_cbf) "ml/100 g/min" else "µmol/100 g/min", 3), rep(if (is_cbf) "ml/100 g/min" else "µml/100 g/min", 3), rep("%", 3)),
  disp_type = c(rep("SD", 6), rep(NA, 3)), stringsAsFactors = FALSE)
final.dataframe <- long_cells(snap, rows, arms, section = rep(NA_character_, nrow(snap)), species = "male rhesus monkeys (Macaca mulatta)")
final.dataframe <- final.dataframe[nzchar(final.dataframe$cell_as_printed), ]
if (is_cbf) {
  final.dataframe$CBF.ml_100g_min <- ifelse(final.dataframe$measure == "CBF", final.dataframe$value_numeric, NA_real_)
  final.dataframe$CMRglc.umol_100g_min <- NULL
}
final.dataframe$side_or_part <- ifelse(grepl("R_or_A", final.dataframe$arm_id),
  ifelse(final.dataframe$structure_as_published == "Cingulate", "anterior cingulate", "right hemisphere"),
  ifelse(grepl("L_or_P", final.dataframe$arm_id),
  ifelse(final.dataframe$structure_as_published == "Cingulate", "posterior cingulate", "left hemisphere"), "average"))
final.dataframe$note[grepl("^aged", final.dataframe$arm_id) & !is_cbf] <- "Aged-column unit printed 'µml/100 g/min' (sic); read as µmol/100 g/min like the young column."
final.dataframe$note[grepl("Y_minus_A", final.dataframe$arm_id)] <- "Y-A (%) = (Y - A)/Y x 100; marks a/b/c: P < 0.05 / 0.01 / 0.005."
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 7L * 9L - 6L)   # Cerebellum prints no R/L cells

## ---- table checks (HOWTO section 7a) ------------------------------------------
## (1) Average = (R or A + L or P)/2 (tolerance 0.1 = rounding of the inputs and
##     of the printed average); (2) Y–A (%) = 100 x (Y - A)/Y from the two printed
##     means of the same column (tolerance: rounding of the means, propagated, +
##     0.5 for the printed integer); (3) plausibility: the SD of a two-part
##     average cannot exceed the mean of the two parts' SDs (+ 0.1 rounding).

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}


v <- function(s, a, what = "value_numeric") { x <- final.dataframe[[what]][final.dataframe$structure_as_published == s & final.dataframe$arm_id == a]; if (length(x)) x else NA_real_ }
structs <- unique(final.dataframe$structure_as_published)
tc <- list()
for (s in structs) for (g in c("young", "aged")) {
  R <- v(s, paste0(g, "_R_or_A")); L <- v(s, paste0(g, "_L_or_P")); A <- v(s, paste0(g, "_average"))
  if (!is.na(R)) {
    tc[[length(tc) + 1L]] <- chk(paste0("avg_", g, "_", s), paste0(s, ", ", g, ": Average vs (R or A + L or P)/2"), (R + L) / 2, A, 0.1)
    sR <- v(s, paste0(g, "_R_or_A"), "dispersion_numeric"); sL <- v(s, paste0(g, "_L_or_P"), "dispersion_numeric"); sA <- v(s, paste0(g, "_average"), "dispersion_numeric")
    ok <- sA <= (sR + sL) / 2 + 0.1
    tc[[length(tc) + 1L]] <- data.frame(check_id = paste0("sd_plausible_", g, "_", s),
      basis = paste0(s, ", ", g, ": SD of Average <= mean of the two part SDs + 0.1"), observed = sA, printed = (sR + sL) / 2,
      difference = sA - (sR + sL) / 2, tolerance = 0.1, status = ifelse(ok, "pass", "mismatch"),
      note = "an SD this large for a two-part mean is impossible if the part SDs are per-animal SDs", stringsAsFactors = FALSE)
  }
}
for (s in structs) for (p in c("average", "R_or_A", "L_or_P")) {
  Y <- v(s, paste0("young_", p)); A <- v(s, paste0("aged_", p)); P <- v(s, paste0("Y_minus_A_", p))
  if (!is.na(Y)) tc[[length(tc) + 1L]] <- chk(paste0("pct_", p, "_", s), paste0(s, ", ", p, ": Y–A (%) vs 100 x (Y - A)/Y"),
                                             100 * (Y - A) / Y, P, 100 * (0.05 / Y + 0.05 * A / Y^2) + 0.5)
}
table_checks <- do.call(rbind, tc)

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
doi <- "10.1016/S0006-8993(02)02558-1"
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
