# Seymour_etal_2019_rspb20192208si002.R
#
# Purpose
#   Build the supplementary data file (electronic supplementary material 002) of
#   Seymour et al. (2019) into a lean, analysis-ready CSV. One row per great-ape
#   SPECIMEN (118): museum/accession, taxon, sex, endocranial volume, and the
#   bilateral (Right + Left) internal carotid foramen measurements.
#
#   Seymour RS, Bosiocic V, Snelling EP, et al. (2019). Cerebral blood flow rates in
#   recent great apes are greater than in Australopithecus species that had equal or
#   larger brains. Proc Biol Sci 286:20192208. DOI 10.1098/rspb.2019.2208.
#
# Input
#   Seymour_etal_2019_rspb20192208si002_snapshot.xlsx   sheet: SI002
#     Frozen, journal-faithful copy of rspb20192208_si_002.xlsx. Rows 1-2 title/author,
#     row 4 the two-tier "Right"/"Left" group header, row 5 the column names, row 6 the
#     units, rows 7-124 the specimen data, then a museum-abbreviation key.
#
# Outputs
#   Seymour_etal_2019_rspb20192208si002.csv             one row per specimen (118)
#   <DOI>.tsv in __Public/comparative-data/             named from __ReadMe.xlsx
#
# Cleaning
#   - Data rows are those with a Genus in column C (drops title/header/unit rows and
#     the museum-abbreviation footnotes).
#   - Genus is trimmed ("Pan " -> "Pan"); Species keeps the printed epithet (incl.
#     "sp." for indeterminate); Species_binomial = Genus + epithet is emitted as the
#     canonical join name and harmonised via _keys/Stephan/species_key.csv
#     (token Seymour2019).
#   - Both foramina are kept (Right_* and Left_*); the merge combines sides downstream.
#   - Units as printed: ECV ml; foramen area mm2; diameters and radii mm.

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file  <- "Seymour_etal_2019_rspb20192208si002_snapshot.xlsx"
snapshot_sheet <- "SI002"
output_file    <- paste0(item_name, ".csv")

num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a."))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
names(raw) <- paste0("V", seq_len(ncol(raw)))

# 16 fixed columns: Museum, Accession#, Genus, Species, Sex, ECV(ml),
# Right{Area,MajorDiam,MinorDiam,Radius from D,Radius from area},
# Left {Area,MajorDiam,MinorDiam,Radius from D,Radius from area}
data_rows <- raw %>%
  filter(!is.na(V3), str_squish(V3) != "", str_squish(V3) != "Genus")

final.dataframe <- data_rows %>%
  transmute(
    Museum                  = str_squish(V1),
    Accession               = str_squish(V2),
    Genus                   = str_squish(V3),
    Species                 = str_squish(V4),
    Species_binomial        = str_squish(paste(str_squish(V3), str_squish(V4))),
    Sex                     = str_squish(V5),
    ECV_ml                  = num(V6),
    Right_foramen_area_mm2  = num(V7),
    Right_major_diam_mm     = num(V8),
    Right_minor_diam_mm     = num(V9),
    Right_radius_from_D_mm  = num(V10),
    Right_radius_from_area_mm = num(V11),
    Left_foramen_area_mm2   = num(V12),
    Left_major_diam_mm      = num(V13),
    Left_minor_diam_mm      = num(V14),
    Left_radius_from_D_mm   = num(V15),
    Left_radius_from_area_mm = num(V16)
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV ----
write.csv(final.dataframe, file = output_file, row.names = FALSE)
message("Wrote ", output_file, "  (", nrow(final.dataframe), " specimen rows)")

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
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
