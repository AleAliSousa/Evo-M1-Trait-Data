# Smaers_etal_2011_SupplementaryTable_extract.R
#
# EXTRACTION step (source -> snapshot), now traceable. The two supplementary tables
# were originally typed in by hand; this script regenerates the snapshots from the
# Adobe-Acrobat "Export PDF -> Excel" of the supplementary-tables PDF, so the
# source->snapshot step is reproducible.
#
# Source : 000323671_sm_suppltables.xlsx  (Adobe export of 000323671_sm_suppltables.pdf)
#          sheet "Table 1" = Suppl. Table 1 data (frontal white/grey L/R + total brain)
#          sheet "Table 2" = Suppl. Table 1 CAPTION (the table topic, split onto its own sheet)
#          sheet "Table 3" = Suppl. Table 2 data (5th-section white/grey L/R)
#          sheet "Table 4" = Suppl. Table 2 caption
# Output : Smaers_etal_2011_SupplementaryTable1_snapshot.csv
#          Smaers_etal_2011_SupplementaryTable2_snapshot.csv
#
# The Adobe export has data only (no header row) and drops the captions onto separate
# sheets; this script supplies the printed column headers. Values are taken verbatim
# (no cleaning here — that is the .R reformat step).

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

suppressPackageStartupMessages({ library(readxl); library(readr) })
## Set working directory to this script folder
setwd(folder)
xlsx <- "000323671_sm_suppltables.xlsx"

st1 <- read_excel(xlsx, sheet = "Table 1", col_names = FALSE)
names(st1) <- c("Individual","Frontal left white","Frontal left grey",
                "Frontal right white","Frontal right grey","Total brain size")
write_csv(st1, "Smaers_etal_2011_SupplementaryTable1_snapshot.csv")

st2 <- read_excel(xlsx, sheet = "Table 3", col_names = FALSE)
names(st2) <- c("Individual","Section interval 5 left white","Section interval 5 left grey",
                "Section interval 5 right white","Section interval 5 right grey")
write_csv(st2, "Smaers_etal_2011_SupplementaryTable2_snapshot.csv")

message("Extracted snapshots from Adobe export: ST1 ", nrow(st1), " indiv, ST2 ", nrow(st2), " indiv.")
