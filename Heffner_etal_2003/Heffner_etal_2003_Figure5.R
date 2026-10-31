## Heffner_etal_2003_Figure5.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2003). Hearing in American leaf-nosed bats.
## III: Artibeus jamaicensis. Hearing Research 184, 113-122. doi:10.1016/s0378-5955(03)00233-8
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 5 (p. 119) is a log-log scatter of
## highest audible frequency at 60 dB SPL against functional interaural distance for
## mammals (printed r = -0.792, p <= .0001, n = 67, plus three subterranean species drawn
## as open triangles and excluded from the correlation = 70 plotted points). The figure is
## a raster image, so markers were pixel-digitised from the embedded bitmap by
## Heffner_etal_2003_Figure5_extract.py (tick calibration; ring / disc / triangle template
## matching), which wrote the frozen Heffner_etal_2003_Figure5_snapshot.csv.
##
## 62 of the 70 plotted points were individually resolved (51 open circles + 8 filled
## circles + 3 triangles); 8 circles overlap a neighbour too closely to separate and are
## absent from this item. Only 21 of the resolved markers carry a printed label
## (reference_tables/Heffner_etal_2003_Figure5_label_assignment.csv); the rest are
## unidentified comparison points and keep species = NA.
##
## SECONDARY (the only point this paper measured itself is Aj, which the ResultsText item
## already carries as primary). Per-point sources, where the caption keys them, are in
## reference_tables/Heffner_etal_2003_Figure5_references.csv.
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
snap   <- read.csv(snapshot_csv, comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
assign <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_label_assignment.csv")),
                   stringsAsFactors = FALSE, encoding = "UTF-8")
refs   <- read.csv(file.path(folder, "reference_tables", paste0(item_name, "_references.csv")),
                   stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 62L, nrow(assign) == 21L, all(assign$marker_id %in% snap$marker_id),
          all(assign$label_as_printed %in% refs$ref_key))

## 3. CLEAN -------------------------------------------------------------
final.dataframe <- snap %>%
  left_join(assign, by = "marker_id") %>%
  mutate(has_ref = !is.na(label_as_printed) &
           label_as_printed %in% refs$ref_key[nzchar(refs$citation)]) %>%
  transmute(marker_id, marker_type,
            label_as_printed = ifelse(is.na(label_as_printed), "", label_as_printed),
            species_as_published = label_as_printed,
            Species = ifelse(nzchar(label_as_printed), resolve(label_as_printed), NA_character_),
            species_basis = ifelse(nzchar(label_as_printed), resolve_basis(label_as_printed), NA_character_),
            label_confidence = ifelse(is.na(confidence), "", confidence),
            functional_interaural_distance_us,
            highest_audible_frequency_60dB_kHz,
            in_printed_correlation = ifelse(marker_type == "open triangle", "no (subterranean)", "yes"),
            source_ref_key = ifelse(has_ref, label_as_printed, ""),
            value_origin = "digitised_from_figure",
            value_precision = "+/- 0.9% (calibration residual) + ~0.3% per pixel of marker centring",
            data_role = "secondary") %>%
  arrange(functional_interaural_distance_us)

## 4. TABLE CHECKS (HOWTO 7a) -----------------------------------------
gv <- function(lb, col) final.dataframe[[col]][final.dataframe$label_as_printed == lb]
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "gopher_kHz",   "pocket gopher 60-dB limit (kHz); Section 4.2.3: 8.7 kHz", gv("gopher", "highest_audible_frequency_60dB_kHz"), 8.7, 0.5,
  "nmr_kHz",      "naked mole rat 60-dB limit (kHz); Section 4.2.3: 11.5 kHz", gv("naked mole rat", "highest_audible_frequency_60dB_kHz"), 11.5, 0.6,
  "bmr_kHz",      "blind mole rat 60-dB limit (kHz); Section 4.2.3: 5.9 kHz", gv("blind mole rat", "highest_audible_frequency_60dB_kHz"), 5.9, 0.4,
  "Aj_kHz",       "A. jamaicensis 60-dB limit (kHz); Results p.116: 131 kHz", gv("Aj", "highest_audible_frequency_60dB_kHz"), 131, 8,
  "Aj_us",        "A. jamaicensis functional interaural distance (us); Fig. 4 label: 96 us", gv("Aj", "functional_interaural_distance_us"), 96, 6,
  "Cp_us",        "C. perspicillata functional interaural distance (us); Fig. 4 label: 47 us", gv("Cp", "functional_interaural_distance_us"), 47, 3,
  "Ph_us",        "P. hastatus functional interaural distance (us); Fig. 4 label: 108 us", gv("Ph", "functional_interaural_distance_us"), 108, 6,
  "n_resolved",   "markers resolved of the 70 plotted", nrow(final.dataframe), 62, 0,
  "n_labelled",   "resolved markers carrying a printed label", sum(nzchar(final.dataframe$label_as_printed)), 21, 0) %>%
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
