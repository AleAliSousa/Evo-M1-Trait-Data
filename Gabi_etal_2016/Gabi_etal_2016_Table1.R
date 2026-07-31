## Gabi et al. 2016 — prefrontal cortex neuron counts  [SCAFFOLD / STUB]
## doi:10.1073/pnas.1610178113
##
## SCAFFOLD: sets up paths + extraction plan, then stops. Needs the PDF/supplement, the
## regional-term design decision (see __merging_cellcounts/HH_coverage_gaps_scaffold.md),
## registry entry, and a completed standardized-terms file. See Gabi_etal_2016_Table1.README.md.

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
table_name   <- "Gabi_etal_2016_Table1"                              # confirm printed label vs supplement
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_csv   <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
pdf_file <- file.path(paper_dir, "TODO_Gabi_etal_2016.pdf")

stop("SCAFFOLD: add the Gabi 2016 PDF/supplement, make the regional-term decision, register ",
     "the table in __ReadMe.xlsx, and complete the extraction + standardized-terms file ",
     "before running. See Gabi_etal_2016_Table1.README.md.", call. = FALSE)

## 1. PACKAGES + 2. EXTRACT -----------------------------------------------------------------
## library(rJava); library(tabulapdf); library(tidyverse); library(readxl)
## TODO: extract prefrontal vs rest-of-cortex neuron/other-cell numbers (grey/white if split);
## keep printed Species as Species_Gabi2016; save frozen snapshot before cleaning.

## 3. SAVE (LOCAL CSV + PUBLIC TSV) ---------------------------------------------------------
## item_encoded <- read_excel(readme_xlsx,"Sheet1")$`Item encoded`[match(table_name, ...)]
## write.csv(...); write.table(..., paste0(item_encoded, ".tsv"), sep="\t", row.names=FALSE)
