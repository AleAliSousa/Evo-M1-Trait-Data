# Bauernfeind_etal_2013_Table3.R
#
# Preparation step. Turn the journal-faithful snapshot of Bauernfeind et al. (2013)
# Table 3 -- SPECIES AVERAGES (mean +/- SD) of left and right insular subdivision
# volumes in humans and great apes -- into a tidy, analysis-ready CSV. Output comes
# from the snapshot only.
#
# Table 3 is the species-mean summary of the per-individual Tables 1 (left) and 2
# (right). It is kept as its own faithful snapshot/CSV for traceability; the merge
# (__merging_volumes) recomputes species means from the per-individual tables.
#
# Snapshot layout (Bauernfeind_etal_2013_Table3_snapshot.xlsx, sheet Table3): one header
# row, then 6 species rows. Two side-by-side blocks (left | right), each: n + the five
# subdivisions (Granular, Dysgranular, Agranular, FI, Total) printed as "mean +/- SD"
# (single value where n = 1). Volumes are cm3, exactly as printed.
#
# THIS script reshapes to tidy long form, splitting "mean +/- SD" into numeric mean / sd
# and converting cm3 -> mm3 (x1000).
#
# Input  : Bauernfeind_etal_2013_Table3_snapshot.xlsx   sheet: Table3
# Output : Bauernfeind_etal_2013_Table3.csv   (Species x hemisphere x subdivision, long)

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

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
})
options(scipen = 999)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
raw <- read_excel(snapshot_file)

split_mean <- function(x) suppressWarnings(as.numeric(str_trim(str_extract(x, "^[^\u00b1]+"))))
split_sd   <- function(x) suppressWarnings(as.numeric(str_trim(str_extract(x, "(?<=\u00b1).+"))))

subdiv <- c("Granular", "Dysgranular", "Agranular", "FI", "Total")
long <- bind_rows(lapply(c("left", "right"), function(side) {
  cols <- paste0(subdiv, "_", side)
  raw %>%
    select(Species, n = all_of(paste0("n_", side)), all_of(cols)) %>%
    pivot_longer(all_of(cols), names_to = "subdivision", values_to = "cell") %>%
    mutate(Species     = str_squish(Species),
           hemisphere  = side,
           n           = as.integer(n),
           subdivision = str_remove(subdivision, paste0("_", side)),
           mean_mm3    = split_mean(cell) * 1000,
           sd_mm3      = split_sd(cell)   * 1000) %>%
    select(Species, hemisphere, n, subdivision, mean_mm3, sd_mm3)
}))

write.csv(long, paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(long), " rows = ",
        n_distinct(long$Species), " species x 2 hemispheres x ", length(subdiv), " subdivisions)")

## ---- DOI-coded public TSV (__HOWTO_build_a_dataset_file.md sec 4, invariant 2) -----------
## Added 2026-08-05: the script wrote the analysis CSV but never the public TSV, so the table
## was built but unpublished. Same object, same columns - only the separator differs.
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA_character_
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; public TSV skipped.")
} else if (is.na(tsv_dir) || !dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
} else {
  write.table(long, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
