# Smaers_etal_2017_TableS1part2.R
#
# Smaers JB, Gomez-Robles A, Parks AN, Sherwood CC (2017), Current Biology 27:714-720,
# "Exceptional Evolutionary Expansion of Prefrontal Cortex in Great Apes and Humans."
# DOI 10.1016/j.cub.2017.01.020.  Supplemental Table S1 (file mmc1).  This is PART 2 of 2
# -- the "Brodmann data" SURFACE-AREA block only: 4 cortical regions (primary visual,
# prefrontal, other cortical association areas, frontal motor), 10 primate species.
# (Part 1 = the Smaers volume block; see Smaers_etal_2017_TableS1part1.R.)
#
# Provenance: surface areas are taken from Brodmann (1909) [S3]; only 9 of the 10 species
# carry the full set (Saimiri sciureus has primary visual only).  Units mm2 (as printed).
#
# Input is a direct transcription of the printed mmc1.pdf, PDF page 4.
# Input  : Smaers_etal_2017_TableS1part2_pdf_transcription.csv
# Outputs: Smaers_etal_2017_TableS1part2.csv             one row per species (10)
#          <DOI>_TableS1_part2_surfacearea.tsv in __Public/comparative-data/

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

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})
## Set working directory to this script folder
setwd(folder)
snapshot_file  <- "Smaers_etal_2017_TableS1part2_pdf_transcription.csv"
output_file    <- "Smaers_etal_2017_TableS1part2.csv"

pos <- c("species_disp",
         "primary_visual_surface","prefrontal_surface","other_association_surface","frontal_motor_surface")
num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))

dat <- read.csv(snapshot_file, colClasses = "character", na.strings = c("", "NA"))
stopifnot(nrow(dat) == 10L, identical(names(dat), pos))

final.dataframe <- dat %>%
  filter(!is.na(species_disp), species_disp != "") %>%
  transmute(
    species                   = str_replace_all(str_squish(species_disp), " ", "_"),
    primary_visual_surface    = num(primary_visual_surface),
    prefrontal_surface        = num(prefrontal_surface),
    other_association_surface = num(other_association_surface),
    frontal_motor_surface     = num(frontal_motor_surface),
    source                    = "Smaers_etal_2017"
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV (named from __ReadMe.xlsx 'Item encoded') ----
item_name <- tryCatch(gsub("\\.R$", "", basename(.sp)),
                      error = function(e) tools::file_path_sans_ext(output_file))
if (is.null(item_name) || !nzchar(item_name)) item_name <- tools::file_path_sans_ext(output_file)
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

readme_file <- file.path(base, "__ReadMe.xlsx")
tsv_dir     <- paste0(file.path(base, "__Public", "comparative-data"), "/")
filecodes    <- read_excel(readme_file, sheet = "Sheet1")
# __ReadMe 'Item name' is a formula that strips spaces & underscores from the Item
# number (e.g. "Table S1 part2 surface area" -> "...TableS1part2surfacearea"), so match
# on a separator-insensitive key rather than the literal file stem.
norm_key     <- function(x) tolower(gsub("[ _]", "", as.character(x)))
item_encoded <- filecodes$"Item encoded"[match(norm_key(item_name), norm_key(filecodes$"Item name"))]
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = paste0(tsv_dir, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_dir, item_encoded, ".tsv")
}
