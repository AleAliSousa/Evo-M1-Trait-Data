## Koay_etal_1998_b_Figure9.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Koay, G., Kearns, D., Heffner, H. E., & Heffner, R. S. (1998). Passive sound-localization
## ability of the big brown bat (Eptesicus fuscus). Hear Res 119:37-48.
## doi:10.1016/s0378-5955(98)00037-9
##
## THE ITEM IS A FIGURE. Figure 9 (p. 46) plots sound-localization threshold (deg, log y)
## against width of the field of best vision (deg, log x) for the 23 species keyed in its
## caption, plus the paper's own big brown bat. 18 of the 24 points are drawn as the
## caption's key NUMBER at the data position; only 6 carry a filled disc. Values are
## digitised by Koay_etal_1998_b_Figure9_extract_snapshot.py and frozen in the snapshot.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Koay_etal_1998_b_Figure9"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
key_csv      <- file.path(folder, "reference_tables", paste0(item_name, "_caption_key.csv"))
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
stopifnot(nrow(snap) == 24, nrow(key) == 24, setequal(snap$caption_key_label, key$caption_key_label))

## 3. JOIN + CLEAN ---------------------------------------------------
sk <- snap[match(key$caption_key_label, snap$caption_key_label), ]
final.dataframe <- tibble(
  caption_key_label      = key$caption_key_label,
  common_name_as_printed = key$common_name_as_printed,
  binomial_as_printed    = key$binomial_as_printed,
  width_of_field_of_best_vision_deg = as.numeric(sk$width_of_field_of_best_vision_deg_as_read),
  sound_localization_threshold_deg  = as.numeric(sk$sound_localization_threshold_deg_as_read),
  point_drawn_as = sk$point_drawn_as,
  subterranean   = ifelse(grepl("[*]$", key$caption_key_label), "TRUE", "FALSE"),
  value_source = ifelse(key$caption_key_label == "Big Brown Bat", "this study", "Heffner et al. (1994)"),
  data_role    = ifelse(key$caption_key_label == "Big Brown Bat", "primary", "secondary"),
  value_origin = "digitised_from_figure",
  note = paste0(sk$note, ifelse(nzchar(sk$note) & nzchar(key$note), ". ", ""), key$note)
) %>% mutate(across(where(is.character), ~replace_na(., "")))
stopifnot(all(final.dataframe$value_source %in% refs$ref_key), nrow(final.dataframe) == 24)

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
## None. The README records the agreement with Heffner et al. (1994) Table 1 and with
## Figure 8 of this same paper, including the one place they disagree (label 20, ferret).
