## Frahm HD, Stephan H, Baron G (1984). Comparison of brain structure volumes...
## Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Input : <script stem>_snapshot.xlsx
## Output: <script stem>.csv
##         <Item encoded>.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

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
source_name   <- sub("_Table[^_]*$", "", item_name)
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
output_csv    <- paste0(item_name, ".csv")
base          <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot ----
header_rows <- 2L
cols <- c(
  "species_disp",
  "n_raw",
  "Area_striata_mm3",
  "Area_striata_grey_matter_mm3",
  "Area_striata_lamina_1_mm3",
  "Area_striata_laminae_2_6_mm3",
  "Area_striata_white_matter_mm3"
)

num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))

raw <- read_excel(snapshot_xlsx, sheet = "Table1", col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(cols)] <- cols

## ---- Table 1 footnote: species-name synonymy vs Stephan et al. (1981) ----
## Printed footnote (p.1 of the paper): "Classification and species names are
## adapted to the list given by Corbet and Hill (1980). Different names used
## in former papers and in Stephan et al. (1981) are: 1) Lemur fulvus;
## 2) Lemur variegatus; 3) Galago crassicaudatus; 4) Galago demidovii;
## 5) Saguinus tamarin; 6) Cercopithecus talapoin (for Tables 1-3) and
## 7) Aethechinus algirus; and 8) Crocidura occidentalis (for Table 4)."
## Footnotes 1-6 mark species in Table 1 (this table); 7-8 apply to Table 4
## only. Full mapping: reference_tables/Frahm_etal_1984_Table1_footnotes.csv
footnotes <- read_csv(
  file.path("reference_tables", "Frahm_etal_1984_Table1_footnotes.csv"),
  show_col_types = FALSE
)

## ---- clean ----
clean <- dat %>%
  filter(!is.na(num(Area_striata_mm3))) %>%
  transmute(
    Species = str_squish(species_disp),
    n = as.integer(num(n_raw)),
    Area_striata_mm3 = num(Area_striata_mm3),
    Area_striata_grey_matter_mm3 = num(Area_striata_grey_matter_mm3),
    Area_striata_lamina_1_mm3 = num(Area_striata_lamina_1_mm3),
    Area_striata_laminae_2_6_mm3 = num(Area_striata_laminae_2_6_mm3),
    Area_striata_white_matter_mm3 = num(Area_striata_white_matter_mm3),
    source = source_name
  ) %>%
  left_join(
    footnotes %>% select(species_in_table, former_name_stephan1981),
    by = c(Species = "species_in_table")
  )

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
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
