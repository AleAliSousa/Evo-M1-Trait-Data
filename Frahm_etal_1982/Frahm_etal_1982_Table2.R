# Frahm_etal_1982_Table2.R
#
# Preparation step. Turn the journal-faithful snapshot of Frahm & Stephan (1982,
# Part I, neocortex) Table 2 -- the neocortex volumes -- into a lean, analysis-
# ready CSV. Output comes from the snapshot only.
#
# Snapshot layout (matches the printed Table 2): row 1 caption, row 2 column
# headers, row 3 the printed column numbers (1)-(7), then the species rows in
# taxonomic order with blank rows separating groups. One leading "species"
# column (n > 1 shown in parentheses, e.g. "Tupaia glis (2)") followed by the 7
# measures. THIS script reads past the header, keeps the species rows (skipping
# the blank group separators), and splits the parenthetical n off the name.
#
# Size indices are NOT recomputed here: they are a deterministic function of the
# volumes and BODY WEIGHTS (external to this volumes table), via reference lines
# of fixed, structure-specific slope through the basal-Insectivora centroid --
# total 0.67, white matter 0.86, grey matter 0.63, lamina 1 0.65, laminae 2-6
# 0.62 (Frahm & Stephan 1982, Methods). Recompute downstream where body weights
# (Stephan et al. 1981) are joined; the paper's Table 1 gives the total-neocortex
# index for validation.
#
# Input  : Frahm_etal_1982_Table2_snapshot.xlsx       sheet: Table2
# Outputs: Frahm_etal_1982_Table2.csv                 one row per species (38)
#          <DOI/PMID>.tsv in __Public/comparative-data/  named from __ReadMe.xlsx

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
snapshot_file  <- "Frahm_etal_1982_Table2_snapshot.xlsx"
snapshot_sheet <- "Table2"
output_file    <- "Frahm_etal_1982_Table2.csv"
header_rows    <- 3L   # row1 caption + row2 headers + row3 column numbers; data (and blank separators) from row 4

pos <- c("species_disp","total_neocortex","white_matter","white_pct_neocortex",
         "grey_matter","lamina_1","lamina_1_pct_grey","laminae_2_6")
num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

final.dataframe <- dat %>%
  filter(!is.na(species_disp), str_squish(species_disp) != "", !is.na(num(total_neocortex))) %>%
  transmute(
    Species   = str_squish(str_remove(species_disp, "\\s*\\(\\d+\\)\\s*$")),  # drop the "(n)" suffix
    n                   = ifelse(str_detect(species_disp, "\\((\\d+)\\)\\s*$"),
                                 as.integer(str_match(species_disp, "\\((\\d+)\\)\\s*$")[, 2]), 1L),
    total_neocortex_mm3 = num(total_neocortex),
    white_matter_mm3    = num(white_matter),
    white_pct_neocortex = num(white_pct_neocortex),
    grey_matter_mm3     = num(grey_matter),
    lamina_1_mm3        = num(lamina_1),
    lamina_1_pct_grey   = num(lamina_1_pct_grey),
    laminae_2_6_mm3     = num(laminae_2_6)
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI/PMID-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "	", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
