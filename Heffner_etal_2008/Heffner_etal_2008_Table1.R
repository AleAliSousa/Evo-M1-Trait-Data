## Heffner_etal_2008_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2008). Sound-localization
## acuity and its relation to vision in large and small fruit-eating bats:
## II. Non-echolocating species, Eidolon helvum and Cynopterus brachyotis.
## Hearing Research 241:80-86. doi:10.1016/j.heares.2008.05.001
##
## Source is a born-digital PDF; Table 1 (7 rows) was transcribed directly,
## cross-checked word-for-word against the extracted text layer.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2008_Table1"
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
grid <- read.csv(snapshot_csv, skip = 1, header = FALSE, col.names = c("Species", "Common name", "Threshold"),
                 stringsAsFactors = FALSE, check.names = FALSE, colClasses = "character", encoding = "UTF-8",
                 blank.lines.skip = FALSE)
stopifnot(grid$Species[1] == "Species")
species_rows <- grid[grepl("^[0-9]+(?:\\.[0-9]+)?$", grid$Threshold), , drop = FALSE]
stopifnot(nrow(species_rows) == 7, !anyDuplicated(species_rows$Species))
context <- read.csv(file.path(folder, "reference_tables", "Heffner_etal_2008_Table1_analysis_context.csv"),
                    stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(setequal(context$species, species_rows$Species))
## The source table prints non-echolocators first; retain the prior analysis order here.
analysis_order <- c("Phyllostomus hastatus", "Artibeus jamaicensis", "Cynopterus brachyotis",
                    "Eidolon helvum", "Rousettus aegyptiacus", "Eptesicus fuscus", "Carollia perspicillata")
species_rows <- species_rows[match(analysis_order, species_rows$Species), , drop = FALSE]
context <- context[match(species_rows$Species, context$species), , drop = FALSE]
final.dataframe <- tibble(
  species_row = seq_len(nrow(species_rows)),
  binomial = species_rows$Species,
  common_name = species_rows$`Common name`,
  echolocation_status = context$echolocation_status,
  localization_threshold_deg = as.numeric(species_rows$Threshold),
  data_role = ifelse(species_rows$Species %in% c("Cynopterus brachyotis", "Eidolon helvum"),
                     "primary", "secondary"),
  source = context$source
)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  ## Without this guard a missing registry row made paste0(NA, ".tsv") = "NA.tsv":
  ## this item's Sheet1 row had been overwritten with "TEST_PROBE_VALUE", and the
  ## script wrote __Public/comparative-data/NA.tsv (flagged by
  ## _checks/check_item_name_resolution.R, sweep 2026-09-25).
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv. Run _tools/restore_registry_rows.R, then _tools/file_list.R.",
         call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
