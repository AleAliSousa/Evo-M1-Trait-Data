## Ribeiro et al. 2013 — human cortical neuronal-distribution zones  [SCAFFOLD / STUB]
## doi:10.3389/fnana.2013.00028
##
## SCAFFOLD: paths + plan, then stops. Needs the PDF/supplement, a granularity decision
## (per-zone vs per-site) AND an include-or-reference decision (this is a within-human map;
## it may stay a reference table like HH 2013 rather than enter the merge). See the README
## and __merging_cellcounts/HH_coverage_gaps_scaffold.md.

## 0. PATHS — self-contained ----------------------------------------------------------------
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
paper_dir    <- dirname(.sp)
table_name   <- "Ribeiro_etal_2013_Table1"                           # confirm printed label vs supplement
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_csv   <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
pdf_file <- file.path(paper_dir, "TODO_Ribeiro_etal_2013.pdf")

stop("SCAFFOLD: add the Ribeiro 2013 PDF, make the granularity + include/reference decisions, ",
     "then complete the build. See Ribeiro_etal_2013_Table1.README.md.", call. = FALSE)

## 1. PACKAGES + 2. EXTRACT + 3. SAVE ------------------------------------------------------
## TODO: extract per-zone neuron densities/numbers (grey 2 zones, white 3 zones); keep the
## printed labels; save frozen snapshot before cleaning; write CSV + public TSV via the
## __ReadMe.xlsx Item encoded lookup (only if the merge-include decision is "yes").
