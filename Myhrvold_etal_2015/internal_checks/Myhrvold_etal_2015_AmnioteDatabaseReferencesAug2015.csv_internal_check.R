## =============================================================================
## Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv_internal_check.R
##
## Cross-item internal check (build HOWTO 7b) for Myhrvold et al. (2015), Amniote Life-History
## Database (Aug 2015 release). The References item (per-cell source-tracking layer) must be
## row-for-row, taxon-for-taxon aligned with the sibling Database item (value layer), otherwise a
## reference cell does not name the source of the value cell beside it. This script compares the
## two frozen snapshots:
##   Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv   (this item's own)
##   Myhrvold_etal_2015_AmnioteDatabaseAug2015_snapshot.csv             (sibling item's)
## It replaces the alignment guard that the References item script used to run on the Database
## snapshot (the guard stopped the build with an error; here a mismatch is a warning and a
## `mismatch` row, nothing is changed). Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv.R
## now reads only its own snapshot. (The Database item script still reads the References snapshot
## to fill its `reference` column: that is a data dependency, flagged separately, not a check.)
##
## The registry "Item name" carries the source file's ".csv" extension, so item_name, base and the
## output name carry it too (as in the item script).
##
## Read-only: reads the two snapshots in the paper folder, writes only
## Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv_internal_check.csv next to this script.
## =============================================================================

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

TAX <- c("class", "order", "family", "genus", "species", "subspecies", "common_name")
rd <- function(f) utils::read.csv(file.path(paper_dir, f), colClasses = "character",
                                  check.names = FALSE, na.strings = character(0), encoding = "UTF-8")
item_stem <- tools::file_path_sans_ext(item_name)
x <- rd(paste0(item_stem, "_snapshot.csv"))                              # References (own)
v <- rd("Myhrvold_etal_2015_AmnioteDatabaseAug2015_snapshot.csv")        # Database (sibling)

tc <- function(id, basis, observed, printed, note = NA_character_) {
  d <- observed - printed
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = d, tolerance = 0,
             status = ifelse(is.na(d), "not_evaluable", ifelse(d == 0, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
same_cols <- length(names(v)) == length(names(x))
n_col_diff <- if (same_cols) sum(names(v) != names(x)) else abs(length(names(v)) - length(names(x)))
if (nrow(v) == nrow(x)) {
  n_tax_diff <- sum(as.matrix(v[, TAX]) != as.matrix(x[, TAX]))
  tax_note <- paste0(nrow(x), " rows x ", length(TAX), " taxonomy columns compared cell by cell")
} else {
  n_tax_diff <- NA_real_
  tax_note <- "row counts differ; cells not compared"
}
table_checks <- rbind(
  tc("columns_aligned", "Database vs References snapshot: number of column positions whose name differs (0 = same column list)",
     n_col_diff, 0),
  tc("row_count_aligned", "Database vs References snapshot: number of rows (observed = References, printed = Database)",
     nrow(x), nrow(v)),
  tc("taxonomy_aligned", "Database vs References snapshot: number of taxonomy cells (class ... common_name) that differ row for row (0 = aligned)",
     n_tax_diff, 0, tax_note)
)

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
