# Seymour_etal_2017_TableS1.R
#
# Purpose
#   Build Seymour, Bosiocic & Snelling (2017) Table S1 ("Revised data" from the
#   Correction to 'Fossil skulls reveal that blood flow rate to the brain increased
#   faster than brain volume during human evolution') into a lean, analysis-ready
#   CSV. One row per fossil-hominin SPECIMEN (30): the ICA morphometrics
#   (foramen/lumen radii), the derived total ICA blood flow rate, body mass, brain
#   volume, their source references, and specimen age.
#
#   Seymour RS, Bosiocic V, Snelling EP (2017). Correction ... R Soc Open Sci 4:170846.
#   DOI 10.1098/rsos.170846.
#
# Input
#   Seymour_etal_2017_TableS1_snapshot.xlsx        sheet: TableS1
#     Frozen, journal-faithful snapshot built from the Word supplement
#     (rsos170846supp1.docx) by Seymour_etal_2017_TableS1_snapshot_extract.py.
#     Row 1 caption, row 2 the 11 column headers, rows 3-32 the 30 specimen rows
#     (footnote superscripts kept verbatim, e.g. body mass "70.0a", age "0.05A"),
#     then the footnote-letter notes and the numbered reference list.
#
# Outputs
#   Seymour_etal_2017_TableS1.csv                  one row per specimen (30)
#   <DOI>.tsv in __Public/comparative-data/        named from __ReadMe.xlsx
#
# Cleaning
#   - Data rows are those whose "Original (O) / Cast (C)" cell is O or C.
#   - Body mass: strip the trailing lower-case footnote letter (a-i) into
#     Body_mass_note; parse kg; convert to project unit g (Body_mass_g = kg*1000).
#   - Age: strip the trailing upper-case footnote letter (A-I) into Age_note; keep
#     the printed value/range verbatim (Age_Mya).
#   - Foramen/lumen radii (cm), total ICA flow (cm3 s-1) and brain volume (cm3 = ml)
#     are kept as printed. Brain mass g = Vbr*1.036 is a documented derivation.
#   - The journal's printed species label (abbreviated, e.g. "H. floresiensis") is
#     preserved as `Species`; accepted binomials are resolved downstream via
#     _keys/Stephan/species_key.csv (token Seymour2017).

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

snapshot_file  <- "Seymour_etal_2017_TableS1_snapshot.xlsx"
snapshot_sheet <- "TableS1"
output_file    <- paste0(item_name, ".csv")

num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a."))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
names(raw) <- paste0("V", seq_len(ncol(raw)))

data_rows <- raw %>% filter(str_squish(V3) %in% c("O", "C"))

final.dataframe <- data_rows %>%
  transmute(
    Species               = str_squish(V1),                 # printed (abbreviated) name preserved
    Specimen              = str_squish(V2),
    Original_or_Cast      = str_squish(V3),
    Foramen_radius_cm     = num(V4),
    Lumen_radius_cm       = num(V5),
    Total_QICA_cm3_s      = num(V6),
    Body_mass_note        = str_match(str_squish(V7), "([a-i])$")[, 2],
    Body_mass_kg          = num(str_remove(str_squish(V7), "[a-i]$")),
    Body_mass_g           = num(str_remove(str_squish(V7), "[a-i]$")) * 1000,  # kg -> g
    Body_mass_ref         = str_squish(V8),
    Brain_volume_cm3      = num(V9),                          # cm3 = ml
    Brain_volume_ref      = str_squish(V10),
    Age_note              = str_match(str_squish(V11), "([A-I])$")[, 2],
    Age_Mya               = str_squish(str_remove(str_squish(V11), "[A-I]$"))
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
