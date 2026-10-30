## Morelli_etal_2025_Figure5.R -- constructed snapshot -> analysis CSV + public TSV
##
## Morelli, A. M., Saada, A., & Scholkmann, F. (2025). Myelin: A possible
## proton capacitor for energy storage during sleep and energy supply during
## wakefulness. Progress in Biophysics and Molecular Biology, 196, 91-101.
## doi:10.1016/j.pbiomolbio.2025.03.001
##
## Fig. 5 (printed p. 97) plots ln(sleep time, % of 24 h) against ln(white
## matter volume, mm3) for 23 mammals. Only 9 animals are labelled, each with
## a printed text annotation "WMV: ~<value> mm3 / ST: <value>%". The
## constructed snapshot transcribes those 9 annotations verbatim from a
## 400-dpi render of the figure; the 14 unlabelled points were NOT digitised
## (no species identity is printed for them). SECONDARY data: the legend
## attributes sleep time to Chudler's tabulated values and six papers, WMV to
## Zhang & Sejnowski (2000) and Mota et al. (2019), without per-animal
## attribution (reference_tables/Morelli_etal_2025_Figure5_references.csv).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Morelli_etal_2025_Figure5"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
tsv_dir <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- readr::read_csv(paste0(item_name, "_snapshot.csv"), show_col_types = FALSE,
                        col_types = readr::cols(.default = "c"))
stopifnot(nrow(snap) == 9)

## 3. SPECIES (General key, scoped to this paper folder) --------------
publication <- basename(folder)                       # "Morelli_etal_2025"
key   <- readr::read_csv(file.path(base, "_keys", "General", "species_key.csv"), show_col_types = FALSE,
                         col_types = readr::cols(.default = "c"))
key_p <- key[key$source_publication == publication, ]
if (nrow(key_p) == 0L)
  stop("No species_key.csv rows for source_publication == \"", publication, "\"", call. = FALSE)
Species <- key_p$accepted_name[match(tolower(snap$label_as_printed), tolower(key_p$variant_name))]
if (anyNA(Species)) stop("No species_key row for: ",
                         paste(snap$label_as_printed[is.na(Species)], collapse = "; "), call. = FALSE)

## 4. CLEAN ------------------------------------------------------------
## "WMV: ~43 mm3" -> 43 (mm3, already the project volume unit); "~" = approximate, kept as a flag
wmv_num <- as.numeric(sub("^WMV:\\s*~?\\s*([0-9.]+).*$", "\\1", snap$WMV_annotation_as_printed))
wmv_apx <- grepl("~", snap$WMV_annotation_as_printed, fixed = TRUE)
## "ST: 82.9%" -> 82.9 (% of 24 h); hours derived as pct * 24 / 100 (not printed)
st_pct  <- as.numeric(sub("^ST:\\s*([0-9.]+)%.*$", "\\1", snap$ST_annotation_as_printed))
if (anyNA(wmv_num) || anyNA(st_pct)) stop("Unparsed annotation in snapshot", call. = FALSE)

final.dataframe <- data.frame(
  Species                  = Species,
  species_as_published     = snap$label_as_printed,
  WhiteMatter_Vol.mm3      = wmv_num,
  WhiteMatter_Vol_approximate = wmv_apx,
  SleepTime.pct24h         = st_pct,
  SleepTime.h_derived      = round(st_pct * 24 / 100, 2),
  WMV_annotation_as_printed = snap$WMV_annotation_as_printed,
  ST_annotation_as_printed  = snap$ST_annotation_as_printed,
  WMV_source_keys          = "Zhang and Sejnowski, 2000; Mota et al., 2019",
  ST_source_keys           = "Eric H. Chudler; Aserinsky, 1999; Campbell and Tobler, 1984; Gravett et al., 2017; Kryger et al., 1989; Siegel, 2022; Tobler, 1989",
  source_attribution_level = "figure legend lists candidate sources for all 23 points; no per-animal attribution printed",
  source_location          = paste0("Fig. 5 annotation (", snap$annotation_panel, " panel, position ",
                                    snap$position_top_to_bottom, "), printed p. 97"),
  data_role                = "secondary",
  stringsAsFactors = FALSE, check.names = FALSE)

## 5. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, paste0(item_name, ".csv"), na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows written")
