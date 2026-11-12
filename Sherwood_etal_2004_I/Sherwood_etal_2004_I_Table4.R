# Sherwood et al. 2004 (I) - Table 4 reformat
# Sherwood CC et al. (2004). Brain Behav Evol (doi:10.1159/000075672).
# NOTE: this is GLI (grey-level index) cytoarchitecture of primary motor cortex
# (M1), NOT brain-structure volume data -> it is NOT part of the volume merge.
# Built to the 4-file convention as a standalone cytoarchitecture dataset.
# Split from the retired combined script Sherwood_etal_2004_I.R (one script per output):
# Sherwood_etal_2004_I_Table4.R writes Sherwood_etal_2004_I_Table4.csv (+ its public TSV)
#
# Table 4 = species mean GLI by cortical layer (II, III, V, VI) + cortical mean (+SEM).

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

library(tidyverse); library(readxl)
base <- base
folder <- file.path(base, "Sherwood_etal_2004_I")
xls <- file.path(folder, "Sherwood_etal_2004_I_Table4_snapshot.xlsx")

# ---- numeric coercion (added 2026-08-05) ------------------------------------------------
# The Adobe export leaves two artefacts that silently made whole columns CHARACTER, so the
# built CSVs carried text where numbers belong (sec 6, "encoding & parsing gotchas"):
#   * Table 5 minus signs are EN DASHES ("–0.9664"), not ASCII "-"
#   * Table 4 Pongo cells carry a leading newline ("\n10.34")
# Both are transcription artefacts of the export, not anything the journal printed, so they
# are fixed here in the reformat - never in the frozen snapshot.
num <- function(x) {
  x <- trimws(gsub("[\r\n]", "", as.character(x)))
  x <- gsub("−|–|—", "-", x)   # minus sign, en dash, em dash -> ASCII -
  x[x %in% c("", "NA", "n.a.", "-")] <- NA
  suppressWarnings(as.numeric(x))
}

# Clean, analysis-ready tidy tables (species in rows). Species stays character; every other
# column is a measure and is coerced to numeric.
# The snapshot keeps the table as printed: row 1 is the printed caption, row 2 the column headings.
paper <- sub("_Table[0-9]+$", "", item_name)                 # = "Sherwood_etal_2004_I"
t4 <- read_excel(xls, sheet = "publishedTable4", skip = 1) %>%   # skip the printed caption row
  select(where(~ !all(is.na(.)))) %>%                       # drop the export's empty columns
  mutate(across(-Species, num),
         Species = trimws(gsub("[\r\n]", "", Species)),
         source  = paper)
write_csv(t4, file.path(folder, paste0(item_name, ".csv")))

# ---- DOI-coded public TSVs (sec 4, invariant 2) -----------------------------------------
# Added 2026-08-05: both tables were built but never published. item_name here is the SCRIPT
# name (Sherwood_etal_2004_I), which is not a registry Item name - the two tables are
# registered separately, so each is looked up explicitly.
publish <- function(df, item) {
  if (is.na(base) || !file.exists(file.path(base, "__ReadMe.xlsx"))) {
    warning("Repo root not found; public TSV skipped for ", item); return(invisible(NULL))
  }
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- filecodes$"Item encoded"[match(item, filecodes$"Item name")]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for '", item, "' in __ReadMe.xlsx; public TSV skipped.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
  } else {
    write.table(df, file.path(tsv_dir, paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
publish(t4, item_name)

message("Sherwood 2004_I: Table4 ", nrow(t4), " species (GLI, non-volume).")
