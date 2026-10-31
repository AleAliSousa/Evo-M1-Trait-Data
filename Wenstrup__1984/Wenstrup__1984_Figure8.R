## Wenstrup__1984_Figure8.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Wenstrup, J. J. (1984). Auditory sensitivity in the fish-catching bat, Noctilio
## leporinus. J Comp Physiol A 155:91-101. doi:10.1007/BF00610934
##
## THE ITEM IS A FIGURE. Figure 8 (p. 99) stacks three behavioural audiograms on one shared
## logarithmic frequency axis: Rhinolophus ferrumequinum (Long and Schnitzler 1975),
## Eptesicus fuscus (a composite of Dalland 1965 and Poussin and Simmons 1982, plotted as a
## solid series plus a dashed open-circle series) and Noctilio leporinus (NL 21 of this
## study). The caption names no sources; the attributions come from the Results text on the
## same page. Values are digitised by Wenstrup__1984_Figure8_extract_snapshot.py and frozen
## in the snapshot; this script attaches the species, the source and the data role.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Wenstrup__1984_Figure8"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, colClasses = "character")
refs <- read.csv(refs_csv,     stringsAsFactors = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 64, length(unique(snap$panel_label_as_printed)) == 3)

## 3. CLEAN ----------------------------------------------------------
src <- c("Rhinolophus ferrumequinum" = "Long and Schnitzler 1975",
         "Eptesicus fuscus"          = "Dalland 1965; Poussin and Simmons 1982",
         "Noctilio leporinus"        = "this study (NL 21)")
final.dataframe <- tibble(
  binomial_as_printed = snap$panel_label_as_printed,
  series_as_printed   = snap$series_as_printed,
  frequency_kHz       = as.numeric(snap$frequency_kHz_as_read),
  threshold_dB_SPL    = as.numeric(snap$intensity_dB_SPL_as_read),
  point_type          = snap$point_type,
  printed_dot_confirmed = snap$dot_confirmed,
  value_source = unname(src[snap$panel_label_as_printed]),
  authors_own  = ifelse(snap$panel_label_as_printed == "Noctilio leporinus", "TRUE", "FALSE"),
  data_role    = ifelse(snap$panel_label_as_printed == "Noctilio leporinus", "primary", "secondary"),
  value_origin = "digitised_from_figure",
  note = snap$note
) %>% arrange(binomial_as_printed, series_as_printed, frequency_kHz) %>%
  mutate(across(where(is.character), ~replace_na(., "")))

## every source key must resolve; the Eptesicus composite carries two, "; "-separated
stopifnot(all(unlist(strsplit(final.dataframe$value_source, "; ", fixed = TRUE)) %in% refs$ref_key))

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
## None. The README records the check against this paper's own Results text for NL 21 and
## against the existing erratum Wenstrup__1984-E001 (CF band 56-59 kHz), which Figure 8
## neither contradicts nor extends.
