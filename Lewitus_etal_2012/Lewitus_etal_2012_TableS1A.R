## Lewitus E, Sherwood CC, Hof PR (2012). Cellular signatures in the primary visual cortex of phylogeny and
## placentation. Brain Struct Funct 217(2):531-547. Electronic supplementary material Table S1A.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published; harmonisation to the project key happens downstream.
##
## Input : Lewitus_etal_2012_TableS1A_snapshot.csv  (converted from the embedded spreadsheet in 429_2011_338_MOESM1_ESM.doc; 3 title rows, header, 36 species rows, 2 footnote rows)
## Output: <script stem>.csv   one row per species (36)
##         <Item encoded>.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

options(scipen = 999)
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
folder      <- dirname(.sp)                              # this paper's folder
item_name   <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name <- sub("_Table[^_]*$", "", item_name)         # Lewitus_etal_2012_Table1 -> Lewitus_etal_2012
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim; header is row 3) ----
raw <- read.csv(snapshot_csv, header = FALSE, check.names = FALSE, stringsAsFactors = FALSE,
                colClasses = "character", fill = TRUE, na.strings = character(0))
hdr_row <- which(trimws(raw[[1]]) == "Species")[1]
foot    <- grep("^\\*Data from", raw[[1]])[1]
snap    <- raw[(hdr_row + 1):(foot - 1), ]
snap[snap == "--" | snap == "NA" | snap == ""] <- NA            # '--' = not measured, 'NA' = not available
num <- function(x) suppressWarnings(as.numeric(trimws(x)))

## units as printed: densities cells/mm3; brain mass g; body mass kg*; gestation d*  (*Jones et al. 2009)
clean <- data.frame(
  species = trimws(snap[[1]]),
  glia_neuron_ratio_V1 = num(snap[[2]]),
  neuronal_density_V1_cells_mm3 = num(snap[[3]]),
  glial_cell_density_V1_cells_mm3 = num(snap[[4]]),
  brain_mass_g = num(snap[[6]]),
  body_mass_kg = num(snap[[7]]),
  gestation_length_d = num(snap[[8]]),
  source = source_name, stringsAsFactors = FALSE)
stopifnot(nrow(clean) == 36, sum(!is.na(clean$glia_neuron_ratio_V1)) == 32)
write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
