## Heffner_etal_2003_Figure4.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2003). Hearing in American leaf-nosed bats.
## III: Artibeus jamaicensis. Hearing Research 184, 113-122. doi:10.1016/s0378-5955(03)00233-8
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 4 (p. 117) overlays the audiograms of
## three phyllostomid bats, drawn as three line styles whose identity is fixed by the three
## printed arrows: thick grey = C. perspicillata (47 us), thin black = A. jamaicensis
## (96 us), dotted = P. hastatus (108 us). The figure is a raster image, so the polylines
## were pixel-digitised from the embedded bitmap by Heffner_etal_2003_Figure4_extract.py
## (tick calibration; grey-level and connectivity curve separation; Douglas-Peucker vertex
## detection), which wrote the frozen Heffner_etal_2003_Figure4_snapshot.csv.
##
## DATA ROLE both: A. jamaicensis is this paper's own audiogram (primary); the other two
## curves are reproduced from Koay et al. (2002, 2003) (secondary) --
## reference_tables/Heffner_etal_2003_Figure4_references.csv.
##
## The paper does not print the tested frequencies, so vertex frequencies are AS EXTRACTED
## and are not snapped to a nominal test series.
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

## 2. LOAD -------------------------------------------------------------
snap <- read.csv(snapshot_csv, comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
refs <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_references.csv")),
                 stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 49L, length(unique(snap$species_as_printed)) == 3L,
          setequal(snap$species_as_printed, refs$ref_key))

## 3. CLEAN -------------------------------------------------------------
final.dataframe <- snap %>%
  transmute(point_id = sprintf("%s_v%02d", abbreviate(species_as_printed, 4), vertex_index),
            species_as_published = species_as_printed,
            Species = resolve(species_as_printed),
            species_basis = resolve_basis(species_as_printed),
            line_style_as_printed = line_style,
            vertex_index,
            frequency_kHz = frequency_kHz,
            threshold_dB_SPL = threshold_dB_SPL,
            functional_interaural_distance_us =
              c("Carollia perspicillata" = 47, "Artibeus jamaicensis" = 96,
                "Phyllostomus hastatus" = 108)[species_as_printed],
            value_origin = "digitised_from_figure",
            value_precision = paste0("polyline fit rms ", trace_rms_px,
                                     " px (~", round(trace_rms_px * 0.178, 2), " dB); ",
                                     "frequency as extracted, not snapped to nominal test frequencies"),
            source_ref_key = species_as_printed,
            data_role = ifelse(species_as_printed == "Artibeus jamaicensis", "primary", "secondary")) %>%
  arrange(species_as_published, vertex_index)

## 4. TABLE CHECKS (HOWTO 7a) -- against this paper's own printed Results values --------
cross60 <- function(sp, side) {
  d <- final.dataframe[final.dataframe$species_as_published == sp, ]
  lf <- log10(d$frequency_kHz); th <- d$threshold_dB_SPL
  i <- if (side == "low") max(which(th >= 60 & seq_along(th) <= which.min(th))) else
                          min(which(th >= 60 & seq_along(th) >= which.min(th)))
  j <- if (side == "low") i + 1L else i - 1L
  10 ^ approx(c(th[i], th[j]), c(lf[i], lf[j]), 60)$y
}
aj <- final.dataframe[final.dataframe$species_as_published == "Artibeus jamaicensis", ]
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "Aj_60dB_low",  "A. jamaicensis low 60-dB limit (kHz); Results p.116: 2.8 kHz",
                  cross60("Artibeus jamaicensis", "low"), 2.8, 0.3,
  "Aj_60dB_high", "A. jamaicensis high 60-dB limit (kHz); Results p.116: 131 kHz",
                  cross60("Artibeus jamaicensis", "high"), 131, 8,
  "Aj_best_dB",   "A. jamaicensis lowest threshold (dB SPL); Results p.116: 8.5 dB",
                  min(aj$threshold_dB_SPL), 8.5, 2,
  "Aj_best_kHz",  "A. jamaicensis frequency of best hearing (kHz); Results p.116: 16 kHz",
                  aj$frequency_kHz[which.min(aj$threshold_dB_SPL)], 16, 1.5,
  "n_curves",     "curves digitised", length(unique(final.dataframe$species_as_published)), 3, 0) %>%
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
