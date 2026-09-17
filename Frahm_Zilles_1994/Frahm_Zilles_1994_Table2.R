# Frahm_Zilles_1994_Table2.R
#
# Preparation step. Turn the journal-faithful snapshot of Frahm & Zilles (1994),
# "Volumetric comparison of hippocampal regions in 44 primate species"
# (J. Hirnforsch. 35:343-354), into a lean, analysis-ready CSV. Output comes from
# the snapshot only.
#
# Printed Table 2 reports the volumes of six retrohippocampal regions:
# subiculum, CA1, CA2, CA3, hilus, and fascia dentata. All volumes are in mm3
# (no conversion). Species run in the printed taxonomic order with blank rows
# separating Insectivora / Prosimians / Simians (no grade headers or n column,
# as printed).
#
# THIS script reads past the 2 header rows, keeps species rows with a numeric CA1
# volume, and drops blank separators. It produces one row per species (48).
#
# Input  : Frahm_Zilles_1994_Table2_snapshot.xlsx   sheet: Table2
# Outputs: Frahm_Zilles_1994_Table2.csv             one row per species (48)
#          <PMID>.tsv in __Public/comparative-data/ named from __ReadMe.xlsx

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

snapshot_file <- "Frahm_Zilles_1994_Table2_snapshot.xlsx"
header_rows   <- 2L   # caption + column header

num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a.", "__"))

# --- printed Table 2: retrohippocampal subfields ---
pos <- c("species_disp", "subiculum_mm3", "CA1_mm3", "CA2_mm3", "CA3_mm3", "hilus_mm3", "fascia_dentata_mm3")
raw <- read_excel(snapshot_file, sheet = "Table2", col_names = FALSE, col_types = "text")
if (ncol(raw) != length(pos)) {
  stop("Expected ", length(pos), " columns in sheet Table2; found ", ncol(raw), ".", call. = FALSE)
}
names(raw) <- pos

final.dataframe <- raw %>%
  slice(-(seq_len(header_rows))) %>%
  filter(!is.na(species_disp), !is.na(num(CA1_mm3))) %>%
  transmute(
    Species = str_squish(species_disp),
    subiculum_mm3 = num(subiculum_mm3),
    CA1_mm3 = num(CA1_mm3),
    CA2_mm3 = num(CA2_mm3),
    CA3_mm3 = num(CA3_mm3),
    hilus_mm3 = num(hilus_mm3),
    fascia_dentata_mm3 = num(fascia_dentata_mm3)
  )

if (anyDuplicated(final.dataframe$Species)) {
  stop("Duplicate species remained after parsing Table2.", call. = FALSE)
}
if (nrow(final.dataframe) != 48L) {
  warning("Expected 48 species; found ", nrow(final.dataframe), ".")
}

options(scipen = 999)

## ---- SAVE: local CSV + PMID-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " species)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (PMID) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
