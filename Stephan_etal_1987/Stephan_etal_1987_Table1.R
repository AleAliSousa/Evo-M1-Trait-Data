## Stephan H, Frahm HD, Baron G (1987). Comparison of brain structure volumes:
## amygdaloid complex. J Hirnforsch. Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI/PMID-coded public TSV.
## Input : <script stem>_snapshot.xlsx
## Output: <script stem>.csv
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)

options(scipen = 999)
suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(stringr)
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
folder        <- dirname(.sp)                              # this paper's folder
item_name     <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name   <- sub("_(Table|TABLE).*", "", item_name)   # e.g., Frahm_etal_1998_Table1 -> Frahm_etal_1998
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
output_csv    <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base          <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot ----
snapshot_sheet <- "Table1"
header_rows <- 2L   # row 1 caption + row 2 header

pos <- c(
  "species_disp",
  "Amygdala_mm3",
  "Complexus_centromedialis_mm3",
  "Complexus_corticobasolateralis_mm3",
  "Nucleus_amygdalae_basalis_pars_magnocellularis_mm3",
  "Nucleus_tractus_olfactorius_mm3"
)

num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))

raw <- read_excel(snapshot_xlsx, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")

dat <- raw %>%
  slice(-(seq_len(header_rows)))

names(dat)[seq_along(pos)] <- pos

## ---- clean ----
clean <- dat %>%
  filter(!is.na(num(Amygdala_mm3))) %>%
  transmute(
    species = str_squish(species_disp),
    amygdala_mm3 = num(Amygdala_mm3),
    complexus_centromedialis_mm3 = num(Complexus_centromedialis_mm3),
    complexus_corticobasolateralis_mm3 = num(Complexus_corticobasolateralis_mm3),
    nucleus_amygdalae_basalis_pars_magnocellularis_mm3 = num(Nucleus_amygdalae_basalis_pars_magnocellularis_mm3),
    nucleus_tractus_olfactorius_mm3 = num(Nucleus_tractus_olfactorius_mm3),
    source = source_name
  )

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
