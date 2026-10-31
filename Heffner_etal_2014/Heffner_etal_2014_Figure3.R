## Heffner_etal_2014_Figure3.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna pacos):
## Audiogram, localization acuity, and use of binaural locus cues. J. Acoust. Soc. Am.
## 135, 778-788. doi:10.1121/1.4861344
##
## THE ITEM IS A FIGURE (constructed snapshot). FIG. 3 (p. 782) plots the auditory
## detection thresholds of three alpacas at 14 frequencies; the plotted symbols ARE the
## letters A, B and C, one per individual, and the solid line is their mean. The figure
## is a raster image, so the 42 letters were pixel-digitised from the embedded bitmap by
## Heffner_etal_2014_Figure3_extract.py (tick calibration + letter template matching),
## which wrote the frozen Heffner_etal_2014_Figure3_snapshot.csv.
## value_origin = digitised_from_figure on every row; data_role = primary (this paper's
## own measurements).
##
## ERRATUM: the abscissa tick printed "20" sits at the log position of 22.5 kHz, which
## the Results text names as a test frequency. Per the errata convention the CSV keeps
## the PRINTED label in frequency_kHz and carries the position-implied value alongside;
## see reference_tables/Heffner_etal_2014_errata.csv (Heffner_etal_2014-E001).
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
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 1b. SPECIES KEY (collection-scoped: _keys/General, source_publication = folder name)
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder), "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ", paste(bad, collapse = "; "), call. = FALSE)
  out
}
resolve_basis <- function(x) key$basis[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]

## 2. LOAD (frozen snapshot) -------------------------------------------
snap <- read.csv(snapshot_csv, comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 42L, length(unique(snap$frequency_index)) == 14L)

## 3. CLEAN -------------------------------------------------------------
final.dataframe <- snap %>%
  arrange(frequency_index, animal_letter) %>%
  group_by(frequency_index) %>%
  mutate(mean_threshold_dB_SPL_3_animals = round(mean(threshold_dB_SPL), 2),
         inter_individual_range_dB = round(max(threshold_dB_SPL) - min(threshold_dB_SPL), 2)) %>%
  ungroup() %>%
  transmute(point_id = sprintf("f%02d%s", frequency_index + 1L, animal_letter),
            species_as_published = "alpaca",
            Species = resolve("alpaca"),
            species_basis = resolve_basis("alpaca"),
            individual = animal_letter,
            frequency_kHz = frequency_kHz_printed_label,
            frequency_kHz_from_tick_position = frequency_kHz_from_tick_position,
            threshold_dB_SPL,
            mean_threshold_dB_SPL_3_animals,
            inter_individual_range_dB,
            marker_glyphs_overlapped = glyph_was_merged,
            value_origin = "digitised_from_figure",
            value_precision = "+/- 0.4 dB (digitisation); frequency as printed",
            data_role = "primary")

## 4. TABLE CHECKS (HOWTO 7a) -- digitised values vs this paper's own printed numbers --
m <- final.dataframe %>% distinct(frequency_kHz, mean_threshold_dB_SPL_3_animals)
getm <- function(f) m$mean_threshold_dB_SPL_3_animals[m$frequency_kHz == f]
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "mean_at_25Hz",   "mean of A,B,C at 0.025 kHz (dB SPL)",  getm(0.025), 70.5, 1.0,
  "best_threshold", "lowest mean threshold (dB SPL)",       min(m$mean_threshold_dB_SPL_3_animals), -0.5, 1.0,
  "best_frequency", "frequency of the lowest mean (kHz)",   m$frequency_kHz[which.min(m$mean_threshold_dB_SPL_3_animals)], 8, 0,
  "mean_at_40kHz",  "mean of A,B,C at 40 kHz (dB SPL)",     getm(40), 79, 1.0,
  "max_range",      "largest inter-individual range (dB)",  max(final.dataframe$inter_individual_range_dB), 9, 1.0,
  "le25dB_at_22.5", "mean at the tick printed '20' (dB SPL); text: 25 dB SPL or better up to 22.5 kHz",
                    getm(20), 25, 2.0) %>%
  mutate(difference = observed - printed,
         status = ifelse(abs(difference) <= tolerance, "pass", "mismatch"))

## WRITE CSV + PUBLIC TSV ---------------------------------------------
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
if (exists("table_checks")) {
  print(as.data.frame(table_checks), row.names = FALSE)
  if (any(table_checks$status != "pass"))
    message("NOTE: ", sum(table_checks$status != "pass"), " table check(s) not 'pass' -- see README.")
}
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
