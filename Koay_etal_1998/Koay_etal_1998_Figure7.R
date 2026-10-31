## Koay_etal_1998_Figure7.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Koay, G., Heffner, R. S., & Heffner, H. E. (1998). Hearing in a megachiropteran
## fruit bat (Rousettus aegyptiacus). J Comp Psychol 112(4):371-382.
## doi:10.1037/0735-7036.112.4.371
##
## THE ITEM IS A FIGURE. Figure 7 (p. 380) plots the low-frequency hearing limit
## (kHz, log y) against the high-frequency hearing limit (kHz, log x) -- both the
## limits audible at 60 dB SPL -- for 58 species. The caption prints no species
## names: it refers the reader to the Figure 6 caption (p. 379) for the key, which
## is transcribed verbatim (page-image verified) in
## reference_tables/Koay_etal_1998_Figure7_caption_key.csv, together with the
## audiogram reference for every point. Full citations for those references are
## resolved in reference_tables/Koay_etal_1998_Figure7_references.csv.
##
## EVERY VALUE IS DIGITISED FROM THE FIGURE (value_origin = digitised_from_figure):
## the numbers appear nowhere in print. The digitisation is this repo's own, made by
## Koay_etal_1998_Figure7_extract_snapshot.py from a 300 dpi render of the page and
## frozen as Koay_etal_1998_Figure7_snapshot.csv. 54 of the 58 points resolve to a
## distinct marker; 4 share a merged blob with a neighbour (see shared_marker_with).
## An older Bath-team digitisation of the same figure reads the low-frequency axis
## low for 57 of the 58 points, by up to 24% (median +8.5% here; one point reads
## 2.9% high). The high-frequency axis agrees to within 2.8%. See the README for the
## published anchors that decide it; this build does not use the Bath Figure-7 block.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Koay_etal_1998_Figure7"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
key_csv      <- file.path(folder, "reference_tables", paste0(item_name, "_caption_key.csv"))
xwalk_csv    <- file.path(folder, "reference_tables", paste0(item_name, "_species_crosswalk.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap  <- read.csv(snapshot_csv, stringsAsFactors = FALSE, colClasses = "character")
key   <- read.csv(key_csv,      stringsAsFactors = FALSE, colClasses = "character")
xwalk <- read.csv(xwalk_csv,    stringsAsFactors = FALSE, colClasses = "character")
refs  <- read.csv(refs_csv,     stringsAsFactors = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 58, nrow(key) == 58, setequal(snap$figure_id, key$figure_id))

## every printed audiogram reference must resolve in the references table
stopifnot(all(key$audiogram_reference_as_printed %in% refs$ref_key))

## 3. JOIN + CLEAN ---------------------------------------------------
sk <- snap[match(key$figure_id, snap$figure_id), ]
xk <- xwalk[match(key$figure_id, xwalk$figure_id), ]
final.dataframe <- tibble(
  figure_id            = key$figure_id,
  Species_Koay1998     = key$binomial_as_printed,       # verbatim, incl. the printed misprints
  common_name_Koay1998 = key$common_name_as_printed,
  corrected_binomial   = coalesce(xk$corrected_binomial, key$binomial_as_printed),
  high_freq_hearing_limit_60dB_kHz = as.numeric(sk$high_frequency_hearing_limit_kHz_as_read),
  low_freq_hearing_limit_60dB_kHz  = as.numeric(sk$low_frequency_hearing_limit_kHz_as_read),
  medium = key$medium,
  marker = sk$marker_as_printed,
  excluded_from_correlation = ifelse(sk$marker_as_printed %in%
                                       c("filled_triangle_subterranean", "open_triangle_marine"),
                                     "TRUE", "FALSE"),
  audiogram_source = key$audiogram_reference_as_printed,
  value_origin = "digitised_from_figure",
  read_method  = sk$read_method,
  shared_marker_with = sk$shared_marker_with,
  note = paste0(ifelse(nzchar(sk$note), sk$note, ""),
                ifelse(nzchar(key$note), paste0(ifelse(nzchar(sk$note), "; ", ""), key$note), ""))
) %>% mutate(across(where(is.character), ~replace_na(., "")))

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
## None. All checks live in Evo-M1-Trait-Data-restricted per REPO_BOUNDARY.md; the
## comparison against the older Bath digitisation of this figure is reported in the
## README (high-frequency axis agrees to +/-1.4%, low-frequency axis does not).
