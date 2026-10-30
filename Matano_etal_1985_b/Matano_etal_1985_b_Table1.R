# Matano_etal_1985_b_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Matano, Stephan & Baron
# (1985), "Volume comparisons in the cerebellar complex of primates. I. Ventral
# pons" (Folia Primatol. 44:171-181, DOI 10.1159/000156211) Table I into a lean,
# analysis-ready CSV. Output comes from the snapshot only.
#
# (Folder/registry now consistent: this folder = registry sequence 'b' = the
# ventral-pons paper; the data token is Matano1985b throughout.)
#
# Snapshot layout (the volumes columns of the printed Table I): row1 caption, row2
# headers, row3 printed column numbers (1)-(5), then species rows in code order
# with grade header rows (Insectivora / Scandentia / Prosimians / Simians). Only
# the body-weight and ventral-pons-volume columns are transcribed; the printed
# size-index / ratio / %-of-brainstem columns are derived and recomputed
# downstream (and the 1985 scan's index columns are unreliable to OCR).
#
# Input  : Matano_etal_1985_b_Table1_snapshot.xlsx       sheet: Table1
# Outputs: Matano_etal_1985_b_Table1.csv                 one row per species (48)
#          <DOI>.tsv in __Public/comparative-data/         named from __ReadMe.xlsx

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})
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
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_file  <- "Matano_etal_1985_b_Table1_snapshot.xlsx"
snapshot_sheet <- "Table1"
output_file    <- "Matano_etal_1985_b_Table1.csv"
header_rows    <- 3L

pos <- c("code","species_disp","n_raw","body_weight_g","ventral_pons_mm3")
num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a.", "__"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

final.dataframe <- dat %>%
  filter(!is.na(num(ventral_pons_mm3))) %>%   # species rows = numeric VPo volume (drops grade headers)
  transmute(
    code                = as.integer(num(code)),
    Species = str_squish(species_disp),
    n                   = as.integer(num(n_raw)),
    body_weight_g       = num(body_weight_g),
    ventral_pons_mm3    = num(ventral_pons_mm3)
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV (standard registry lookup by Item name) ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " species)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "	", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
