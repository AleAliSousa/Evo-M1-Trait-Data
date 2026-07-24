# Lewitus_etal_2014_TableS8_compare_to_public_tsv.R
#
# Checking step for a DIGITAL-NATIVE build. There is no snapshot to audit against
# here (the source IS the machine-readable supplement). Instead we audit the build
# OUTPUT against the founder DOI-coded TSV that already existed in __Public before
# this project began ("already there"). The founder TSV is the comparison anchor;
# it is never treated as a snapshot. This also regression-guards every re-run:
# re-building from the source must keep reproducing the public TSV exactly.
#
# Match : by Species (printed name). Compare : Neuronal_number (integer) + GI (numeric).
# Inputs : ../Lewitus_etal_2014_TableS8.csv                         (this build)
#          10.1371%2Fjournal.pbio.1002000_TableS8.tsv               (founder public TSV)
# Outputs: Lewitus_etal_2014_TableS8_comparison_report_from_R.csv (+ _mismatches_from_R.csv)
#
# EXPECTED RESULT: 25/25 species matched, 0 mismatches (the source-direct build
# reproduces the founder public TSV byte-for-byte). A nonzero mismatch count means
# either the source changed or the founder TSV was corrupted (cf. Smaers 2011 ST2).

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

built_csv <- file.path("..", "Lewitus_etal_2014_TableS8.csv")
pretsv    <- if (!is.na(base))
  file.path(base, "__Public/comparative-data",
            "10.1371%2Fjournal.pbio.1002000_TableS8.tsv") else
  "10.1371%2Fjournal.pbio.1002000_TableS8.tsv"

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", as.character(x))))
built <- as.data.frame(read_csv(built_csv, show_col_types = FALSE), check.names = FALSE)
pre   <- as.data.frame(read_tsv(pretsv,   show_col_types = FALSE), check.names = FALSE)

cols <- c("Neuronal_number", "GI")            # measured columns to audit
status <- vapply(seq_len(nrow(built)), function(i) {
  pv <- pre[pre$Species == built$Species[i], , drop = FALSE]
  if (nrow(pv) == 0) return("build_only_not_in_pretsv")
  a <- num(built[i, cols]); b <- num(pv[1, cols])
  if (all(mapply(function(x, y) isTRUE(abs(x - y) <= 1e-6), a, b))) "matched" else "MISMATCH"
}, character(1))

pre_only <- setdiff(pre$Species, built$Species)
rep <- built %>% mutate(status = status)
write_csv(rep, "Lewitus_etal_2014_TableS8_comparison_report_from_R.csv")
write_csv(filter(rep, status != "matched"),
          "Lewitus_etal_2014_TableS8_comparison_mismatches_from_R.csv")

message("Lewitus TableS8 vs founder public TSV: matched ",
        sum(rep$status == "matched"), " | mismatch ",
        sum(rep$status != "matched"),
        if (length(pre_only)) paste0(" | pretsv_only: ", paste(pre_only, collapse = ", ")) else "")
if (any(rep$status == "MISMATCH"))
  warning("Value mismatches vs the founder public TSV — investigate before regenerating it.")
