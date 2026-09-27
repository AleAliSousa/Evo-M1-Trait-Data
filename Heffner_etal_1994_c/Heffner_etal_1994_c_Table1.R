## Heffner_etal_1994_c_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Heffner, H. E., Kearns, D., Vogel, J., & Koay, G. (1994).
## Sound localization in chinchillas. I: Left/right discriminations. Hearing
## Research 80:247-257. doi:10.1016/0378-5955(94)90116-3
##
## Table 1 (p. 253), "Sound-localization thresholds of eleven species of
## rodents", was transcribed directly from a 400-dpi render of PDF page 7
## (printed p. 253) because the born-scanned OCR text layer mangled several
## digits (e.g. "12.8" -> "[2_8," "15.6" -> "[5.6,"); every threshold and
## every citation string below was re-read from the image and matches the
## printed table exactly, including the printed dash ("--") for pocket
## gopher (no threshold obtainable) and the identical "Heffner and Heffner,
## 1988a" citation printed for BOTH the wood rat and grasshopper mouse rows
## (kept as printed -- flagged, not corrected, see README).
##
## Binomial names were filled in only where independently confirmed
## elsewhere in this same paper's text/reference list (grasshopper mouse =
## Onychomys leucogaster; gerbil = Meriones unguiculatus; pocket gopher =
## Geomys bursarius; wood rat = Neotoma floridana, from the companion 1994b
## paper; naked/blind mole rat and groundhog per the paper's own citations).
## "Kangaroo rat" species is left blank -- the cited source (Heffner and
## Masterton, 1980) does not specify the species in this paper's text.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_1994_c_Table1"
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
stopifnot(nrow(snap) == 12)

binomial_lookup <- c(
  "Norway rat (domestic)" = "Rattus norvegicus",
  "Norway rat (wild)"     = "Rattus norvegicus",
  "Chinchilla"             = "Chinchilla laniger",
  "Spiny mouse"            = "Acomys cahirinus",
  "Wood rat"               = "Neotoma floridana",
  "Grasshopper mouse"      = "Onychomys leucogaster",
  "Gerbil"                 = "Meriones unguiculatus",
  "Kangaroo rat"           = NA_character_,   # species not specified in this paper's text
  "Groundhog"              = "Marmota monax",
  "Naked mole rat"         = "Heterocephalus glaber",
  "Blind mole rat"         = "Spalax ehrenbergi",
  "Pocket gopher"          = "Geomys bursarius"
)

## 3. CLEAN -----------------------------------------------------------
final.dataframe <- tibble(
  species_row = seq_len(nrow(snap)),
  group       = tolower(snap$Group),
  binomial    = unname(binomial_lookup[snap$Species]),
  common_name = snap$Species,
  localization_threshold_deg = as.numeric(snap$`Threshold (deg)`),  # "" -> NA for pocket gopher
  data_role = ifelse(snap$Source == "Present report", "primary", "secondary"),
  source = snap$Source
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
