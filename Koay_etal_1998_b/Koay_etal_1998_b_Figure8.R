## Koay_etal_1998_b_Figure8.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Koay, G., Kearns, D., Heffner, H. E., & Heffner, R. S. (1998). Passive sound-localization
## ability of the big brown bat (Eptesicus fuscus). Hear Res 119:37-48.
## doi:10.1016/s0378-5955(98)00037-9
##
## THE ITEM IS A FIGURE. Figure 8 (p. 45) is a single logarithmic scale bar from 1 to 180
## degrees on which 30 species labels are placed by tick marks and leaders -- "Azimuthal
## sound-localization acuity for 29 species of mammals". Values are digitised by
## Koay_etal_1998_b_Figure8_extract_snapshot.py and frozen in the snapshot; this script
## splits the two labels that name two species each, attaches the binomials the paper
## itself prints (Figure 9 caption key), and marks the one primary point.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Koay_etal_1998_b_Figure8"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
key_csv      <- file.path(folder, "reference_tables", paste0(item_name, "_species_key.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, colClasses = "character")
key  <- read.csv(key_csv,      stringsAsFactors = FALSE, colClasses = "character")
refs <- read.csv(refs_csv,     stringsAsFactors = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 28, nrow(key) == 30, all(key$label_as_printed %in% snap$label_as_printed))

## 3. JOIN + CLEAN ---------------------------------------------------
## one row per species (the two "a, b" labels become two rows sharing one tick)
sk <- snap[match(key$label_as_printed, snap$label_as_printed), ]
final.dataframe <- tibble(
  label_as_printed  = key$label_as_printed,
  species_as_printed = key$species_as_printed,
  binomial          = key$binomial,
  binomial_source   = key$binomial_source,
  sound_localization_threshold_deg = as.numeric(sk$sound_localization_threshold_deg_as_read),
  position_in_figure = sk$position,
  leader_type        = sk$leader_type,
  stimulus_over_100ms = ifelse(grepl("^\\(", key$label_as_printed), "TRUE", "FALSE"),
  shares_tick_with   = sk$shares_tick_with,
  two_species_on_one_tick = ifelse(grepl(",", key$label_as_printed), "TRUE", "FALSE"),
  threshold_source = ifelse(key$species_as_printed == "big brown bat", "this study", "Heffner et al. (1994)"),
  data_role    = ifelse(key$species_as_printed == "big brown bat", "primary", "secondary"),
  value_origin = "digitised_from_figure",
  note = sk$note
) %>% mutate(across(where(is.character), ~replace_na(., "")))

stopifnot(all(final.dataframe$threshold_source %in% refs$ref_key))
stopifnot(nrow(final.dataframe) == 30,
          length(unique(final.dataframe$species_as_printed)) == 30)

## 4. WRITE CSV + PUBLIC TSV ---------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  stopifnot(!is.na(item_encoded), !grepl("_$", item_encoded))
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

## 5. COMPARISON -----------------------------------------------------
## None here. The README records the agreement with Heffner et al. (1994) Table 1
## (built in this repo as Heffner_etal_1994_c_Table1) for the 12 species the two share.
