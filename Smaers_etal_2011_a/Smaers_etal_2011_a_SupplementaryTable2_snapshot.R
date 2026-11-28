# Smaers_etal_2011_a_SupplementaryTable2_snapshot.R
#
# EXTRACTION step (source -> snapshot), now traceable. The supplementary table
# was originally typed in by hand; this script regenerates the snapshot from the
# Adobe-Acrobat "Export PDF -> Excel" of the supplementary-tables PDF, so the
# source->snapshot step is reproducible.
#
# Source : 000323671_sm_suppltables.xlsx  (Adobe export of 000323671_sm_suppltables.pdf)
#          sheet "Table 3" = Suppl. Table 2 data (5th-section white/grey L/R)
#          sheet "Table 4" = Suppl. Table 2 caption
# Output : Smaers_etal_2011_a_SupplementaryTable2_snapshot.csv
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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (matches __ReadMe.xlsx)
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

st2 <- read_excel(xlsx, sheet = "Table 3", col_names = FALSE)
grid <- rbind(
  c("Individual", "Section interval 5 left", "", "Section interval 5 right", ""),
  c("", "white", "grey", "white", "grey"),
  trimws(as.matrix(st2))
)
write_csv(as.data.frame(grid, stringsAsFactors = FALSE), paste0(item_name, "_snapshot.csv"), col_names = FALSE)

message("Extracted snapshot from Adobe export: ST2 ", nrow(st2), " indiv.")
