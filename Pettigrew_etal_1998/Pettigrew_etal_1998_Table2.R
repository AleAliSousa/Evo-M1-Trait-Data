## Pettigrew_etal_1998_Table2.R -- snapshot -> analysis CSV + public TSV
##
## Pettigrew, J. D., Manger, P. R., & Fine, S. L. B. (1998). The sensory
## world of the platypus. Phil Trans R Soc Lond B 353(1372):1199-1210.
## doi:10.1098/rstb.1998.0276
##
## Source is a born-digital PDF; Table 2 (13 rows across 2 groups) was
## transcribed directly, cross-checked word-for-word against the extracted
## text layer.

## 0. PATHS --------------------------------------------------------
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Pettigrew_etal_1998_Table2"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                  colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 13)

binomial_map <- c(
  "human" = "Homo sapiens", "marmoset" = "Callithrix jacchus",
  "cat" = "Felis catus", "Tammar wallaby" = "Notamacropus eugenii",
  "ferret" = "Mustela putorius furo", "guinea pig" = "Cavia porcellus",
  "mouse" = "Mus musculus", "rabbit" = "Oryctolagus cuniculus",
  "platypus" = "Ornithorhynchus anatinus"
  ## aotus/agouti/hedgehog/flying fox: no species epithet printed; left NA
)

## 3. CLEAN -----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(x))
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  common_name = snap$Species,
  binomial    = unname(binomial_map[snap$Species]),
  pathway_group = ifelse(grepl("retinogeniculate", snap$`Species group`),
                          "retinogeniculate-dominant", "retinotectal-dominant"),
  linear_magnification_mm_per_deg = num(snap$`Linear magnification factor (mm cortex/deg)`),
  ganglion_cell_acuity_cyc_per_deg = num(snap$`Acuity from ganglion cell density (cycles/deg)`),
  ratio_cyc_per_mm = num(snap$`Ratio (cycles/mm)`),
  data_role = ifelse(snap$Species == "platypus", "primary", "secondary")
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
