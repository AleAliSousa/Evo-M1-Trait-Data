## Heffner_etal_2013_Table1.R -- frozen printed Table 1 -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2013). Hearing in American leaf-nosed bats. IV:
## the Common vampire bat, Desmodus rotundus. Hearing Research 296:42-50.
## doi:10.1016/j.heares.2012.09.011
##
## Table 1 (p. 48, PDF page 7): predicted vs observed high-frequency hearing limit and
## the excess in octaves for 9 laryngeal echolocators and 3 non-echolocating bats.
## The snapshot Heffner_etal_2013_Table1_snapshot.csv is a transcription of the born-digital PDF table
## (row order, group headers, footnote marks, bold means, footnotes kept; checked
## against a 220-dpi page render 2026-10-30). Each species row carries a footnote mark
## whose footnote cites the source of the OBSERVED limit; mark d = "Current report"
## (primary). All other rows are SECONDARY (compiled). The printed footnote text is
## parsed into source_ref_keys ("; "-separated), joinable on ref_key in
## reference_tables/Heffner_etal_2013_Table1_references.csv. Predicted limits come from the footnote-l
## regression on functional interaural distance (distances not printed in the table).
## Table checks: excess = log2(observed / predicted); group means = printed means.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2013_Table1"
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

## UTF-8 output even under Rscript in a C locale (printed labels carry µ, °, −)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv, rows with
## source_publication == this folder's name). No mapping is hand-coded here.
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder),
       "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ",
                        paste(bad, collapse = "; "), call. = FALSE)
  out
}

## 2. LOAD -------------------------------------------------------------
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", fileEncoding = "UTF-8", na.strings = NULL)
refs <- read.csv(refs_csv, stringsAsFactors = FALSE, colClasses = "character", fileEncoding = "UTF-8")
stopifnot(sum(snap$Row_type == "species") == 12L)

## 3. CLEAN -------------------------------------------------------------
snap$group <- NA_character_
g <- NA_character_
for (i in seq_len(nrow(snap))) {
  if (snap$Row_type[i] == "group_header") g <- snap$Row_as_printed[i]
  snap$group[i] <- g
}
fn  <- snap[snap$Row_type == "footnote", c("Footnote_marker_as_printed", "Printed_note")]
fnt <- setNames(fn$Printed_note, fn$Footnote_marker_as_printed)
to_keys <- function(txt) {             # "Dalland, 1965; Koay et al., 1997." -> keys
  txt <- sub("\\.$", "", sub(" \\(note.*$", "", txt))
  paste(trimws(strsplit(txt, ";")[[1]]), collapse = "; ")
}
num <- function(x) as.numeric(gsub("\u2212", "-", x))
sp <- snap[snap$Row_type == "species", ]
final.dataframe <- tibble(
  table_row = seq_len(nrow(sp)),
  group_as_printed = sp$group,
  common_name_as_printed = sp$Row_as_printed,
  footnote_marker = sp$Footnote_marker_as_printed,
  species_as_published = sp$Scientific_name_as_printed,
  species = resolve(sp$Scientific_name_as_printed),
  predicted_high_freq_limit_kHz = num(sp$Predicted_high_frequency_hearing_limit_kHz),
  observed_high_freq_limit_60dB_kHz = num(sp$Observed_high_frequency_hearing_limit_kHz),
  excess_high_freq_hearing_octaves = num(sp$Excess_high_frequency_hearing_octaves),
  source_footnote_as_printed = unname(fnt[sp$Footnote_marker_as_printed]),
  source_ref_keys = vapply(unname(fnt[sp$Footnote_marker_as_printed]), to_keys, character(1), USE.NAMES = FALSE),
  data_role = ifelse(sp$Footnote_marker_as_printed == "d", "primary", "secondary"))
keys <- unique(unlist(strsplit(final.dataframe$source_ref_keys, "; ")))
stopifnot(all(keys %in% refs$ref_key))

## 7a. TABLE CHECKS ------------------------------------------------------
dev <- abs(log2(final.dataframe$observed_high_freq_limit_60dB_kHz /
                final.dataframe$predicted_high_freq_limit_kHz) - final.dataframe$excess_high_freq_hearing_octaves)
stopifnot(all(dev < 0.002))
mn <- snap[snap$Row_type == "mean_deviation", ]
for (k in seq_len(nrow(mn))) {
  got <- mean(final.dataframe$excess_high_freq_hearing_octaves[final.dataframe$group_as_printed == mn$group[k]])
  stopifnot(abs(got - num(mn$Excess_high_frequency_hearing_octaves[k])) < 0.0015)
}
cat("table_checks: 12/12 excess = log2(obs/pred) within 0.002; 2/2 group means match\n")

## WRITE CSV + PUBLIC TSV ---------------------------------------------
final.dataframe <- final.dataframe %>% mutate(across(where(is.character), ~replace_na(., "")))
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
