# Lewitus_etal_2014_TableS1_compare_to_public_tsv.R
#
# Checking step for a DIGITAL-NATIVE build. There is no snapshot to audit against
# (the source IS the machine-readable supplement). We audit the build OUTPUT
# against the founder DOI-coded TSV that already existed in __Public before this
# project began ("already there"). The founder TSV is the comparison anchor; it is
# never treated as a snapshot. This regression-guards every re-run.
#
# Match : by Species (printed name).
# Compare: every shared column except species_sci / Species (numeric where possible,
#          else string; "NA"/blank treated as missing; NA==NA counts as a match).
# Inputs : ../Lewitus_etal_2014_TableS1.csv                        (this build)
#          10.1371%2Fjournal.pbio.1002000_TableS1.tsv              (founder public TSV)
# Outputs: Lewitus_etal_2014_TableS1_comparison_report_from_R.csv (+ _mismatches_from_R.csv)
#
# EXPECTED RESULT: 104/104 species matched, 0 cell mismatches (the source-direct
# build reproduces the founder public TSV). A nonzero count means the source
# changed or the founder TSV was corrupted (cf. Smaers 2011 ST2).

suppressPackageStartupMessages({ library(readr); library(dplyr) })

## ---- paths: self-contained (Rscript or RStudio) ------------------------------
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
cmp_dir <- dirname(.sp); setwd(cmp_dir)
base <- local({
  d <- cmp_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

built_csv <- file.path("..", "Lewitus_etal_2014_TableS1.csv")
pretsv    <- if (!is.na(base))
  file.path(base, "__Public/comparative-data",
            "10.1371%2Fjournal.pbio.1002000_TableS1.tsv") else
  "10.1371%2Fjournal.pbio.1002000_TableS1.tsv"

built <- as.data.frame(read_csv(built_csv, show_col_types = FALSE), check.names = FALSE)
pre   <- as.data.frame(read_tsv(pretsv,   show_col_types = FALSE), check.names = FALSE)

is_miss <- function(x) is.na(x) || trimws(as.character(x)) %in% c("", "NA")
cell_match <- function(a, b) {
  if (is_miss(a) && is_miss(b)) return(TRUE)
  if (is_miss(a) || is_miss(b)) return(FALSE)
  na <- suppressWarnings(as.numeric(gsub(",", "", as.character(a))))
  nb <- suppressWarnings(as.numeric(gsub(",", "", as.character(b))))
  if (!is.na(na) && !is.na(nb)) return(abs(na - nb) <= 1e-6)
  trimws(as.character(a)) == trimws(as.character(b))
}

cmp_cols <- setdiff(intersect(names(built), names(pre)), c("species_sci", "Species"))
rows_out <- list(); bad_cells <- 0L; matched_rows <- 0L; pre_only <- setdiff(pre$Species, built$Species)
for (i in seq_len(nrow(built))) {
  pv <- pre[pre$Species == built$Species[i], , drop = FALSE]
  if (nrow(pv) == 0) {
    rows_out[[length(rows_out)+1L]] <- data.frame(Species = built$Species[i],
      status = "build_only_not_in_pretsv", mismatched_cols = "", stringsAsFactors = FALSE); next
  }
  bad <- cmp_cols[!vapply(cmp_cols, function(cn) cell_match(built[i, cn], pv[1, cn]), logical(1))]
  bad_cells <- bad_cells + length(bad)
  if (length(bad) == 0) matched_rows <- matched_rows + 1L
  rows_out[[length(rows_out)+1L]] <- data.frame(Species = built$Species[i],
    status = if (length(bad)) "MISMATCH" else "matched",
    mismatched_cols = paste(bad, collapse = "; "), stringsAsFactors = FALSE)
}
rep <- do.call(rbind, rows_out)
write_csv(rep, "Lewitus_etal_2014_TableS1_comparison_report_from_R.csv")
write_csv(filter(rep, status != "matched"),
          "Lewitus_etal_2014_TableS1_comparison_mismatches_from_R.csv")

message("Lewitus TableS1 vs founder public TSV: matched rows ", matched_rows, "/", nrow(built),
        " | mismatched cells ", bad_cells, " over ", length(cmp_cols), " compared columns",
        if (length(pre_only)) paste0(" | pretsv_only: ", paste(pre_only, collapse = ", ")) else "")
if (any(rep$status == "MISMATCH"))
  warning("Value mismatches vs the founder public TSV — investigate before regenerating it.")
