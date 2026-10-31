## Babushina_etal_1991_Figure2.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Babushina, Ye. S., Zaslavskii, G. L., & Yurkevich, L. I. (1991). Air and underwater hearing
## characteristics of the northern fur seal: audiograms, frequency and differential thresholds.
## Biophysics 36(5): 909-913 (no DOI; registry alternate id Biophysics:36:909-913).
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 2 (p. 911): air audiogram, curve 1 (northern fur seal) only; 11 points; both printed level scales kept.
## The snapshot Babushina_etal_1991_Figure2_snapshot.csv (digitised 2026-10-26 from the embedded
## 300-ppi scan; method, calibration ticks and residuals in Babushina_etal_1991_Figure2.README.md) is
## read here as text and never edited. Frequency is plotted as lg f [kHz]; the build
## converts to Hz (f = 1000 * 10^lg f). Levels are kept in the plotted unit
## (dB re 0.0002 dyne/cm² (= dB SPL re 20 µPa)); converted columns are labelled. value_origin =
## digitised_from_figure on every row. Data role: primary (one animal, this study).
## Cross-figure agreement is checked separately by Babushina_etal_1991_Figures1-3_crosscheck.R.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Babushina_etal_1991_Figure2"
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
                 colClasses = "character", fileEncoding = "UTF-8")
stopifnot(nrow(snap) == 11L, !anyDuplicated(snap$Point))

## 3. CLEAN -------------------------------------------------------------
lgf <- as.numeric(snap$`lg f [kHz]`)
lvl <- as.numeric(snap$`P, dB (rel. 0,0002 dyne/cm²)`)
stopifnot(!anyNA(lgf), !anyNA(lvl))
species_as_published <- snap$`Curve legend (caption)`
final.dataframe <- tibble(
    point = snap$Point,
    curve_as_labelled = snap$`Curve (as labelled)`,
    curve_legend_as_printed = snap$`Curve legend (caption)`,
    marker = snap$Marker,
    species_as_published = species_as_published,
    species = resolve(species_as_published),
    medium = "air",
    lg_f_kHz_as_plotted = lgf,
    frequency_Hz = signif(1000 * 10^lgf, 3),
    threshold_as_plotted = lvl,
    threshold_unit_as_plotted = "dB re 0.0002 dyne/cm² (= dB SPL re 20 µPa)",
    threshold_dB_SPL = threshold_as_plotted,   # 0.0002 dyne/cm2 = 20 µPa, the SPL reference
    threshold_dB_re_1ubar_as_plotted = as.numeric(snap$`P, dB (rel. 1 µbar)`),
    n_individuals = 1L,
    value_origin = "digitised_from_figure",
    digitisation_note = snap$`Digitisation note`,
    data_role = "primary")

## frequency must increase along each curve, as drawn
chk <- final.dataframe %>% group_by(curve_as_labelled) %>% summarise(ok = all(diff(lg_f_kHz_as_plotted) > 0))
stopifnot(all(chk$ok))

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
