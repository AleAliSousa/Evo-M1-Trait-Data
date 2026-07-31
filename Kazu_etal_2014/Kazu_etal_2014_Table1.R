## Kazu et al. 2014 — Table 1 (Artiodactyla cell counts)  [SCAFFOLD / STUB]
## doi:10.3389/fnana.2014.00128  (use corrigendum doi:10.3389/fnana.2015.00039)
##
## This is a SCAFFOLD. It sets up the self-contained paths and documents the extraction
## plan, then stops: the PDF/corrigendum table is not yet in the folder, the table is not
## registered in __ReadMe.xlsx, and the standardized-terms file is a stub. Complete the
## TODOs (see Kazu_etal_2014_Table1.README.md) and remove the stop() to make it a real build.

## 0. PATHS — self-contained (Rscript or RStudio; full repo or lone folder) ----------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir   <- dirname(.sp)
table_name  <- "Kazu_etal_2014_Table1"                               # must match __ReadMe.xlsx Item name
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_csv   <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
# --- YOU SET THIS MANUALLY once the PDF is in the folder ---
pdf_file <- file.path(paper_dir, "TODO_Kazu_etal_2014.pdf")

## --- SCAFFOLD GUARD: remove once the PDF + registry + terms file are in place -------------
stop("SCAFFOLD: add the Kazu 2014 (corrigendum) PDF, register the table in __ReadMe.xlsx, ",
     "and complete the extraction below + the standardized-terms file before running. ",
     "See Kazu_etal_2014_Table1.README.md.", call. = FALSE)

## 1. PACKAGES -----------------------------------------------------------------------------
library(rJava); library(tabulapdf); library(tidyverse); library(readxl)

## 2. EXTRACT TABLE 1 (from the corrigendum) ----------------------------------------------
## TODO: point tabula at the corrected Table 1 page/area (see HerculanoHouzel_etal_2020 for
## the extract_tables(area=, columns=) pattern). Save the frozen snapshot BEFORE cleaning.
## Expected columns (standard HH scheme): Species, n, body mass (g), brain mass (g),
## cortex/cerebellum/RoB mass (g), neuron number, other-cell number, densities, O/N.
# df0 <- extract_tables(pdf_file, pages = , guess = FALSE, area = list(c()), columns = list(c()), output = "matrix")
# write.csv(df_snapshot, snapshot_csv, row.names = FALSE)

## 3. CLEAN + UNITS ------------------------------------------------------------------------
## TODO: strip thousands commas; n.a./— → NA; keep printed Species as Species_Kazu2014;
## project units (mass g→mg only where the merge expects mg; HH tables keep structure Mass.g).

## 4. SAVE (LOCAL CSV + PUBLIC TSV) --------------------------------------------------------
# filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
# item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
# if (is.na(item_encoded)) stop("Register ", table_name, " in __ReadMe.xlsx first.")
# write.csv(final.dataframe, final_csv, row.names = FALSE)
# dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
# write.table(final.dataframe, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
#             sep = "\t", row.names = FALSE)
