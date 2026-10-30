## Heffner_Heffner_2018_Figure3.R -- frozen figure digitisation -> analysis CSV + public TSV
##
## Heffner, H. E., & Heffner, R. S. (2018). The evolution of mammalian hearing.
## AIP Conference Proceedings 1965(1), 130001. doi:10.1063/1.5038516
##
## THE ITEM IS A FIGURE (constructed snapshot). Figure 3 (p. 130001-4) plots
## sound-localization threshold (deg) against width of the field of best
## vision (75% isodensity contour, deg), both log axes, n = 22 species, every
## point labelled. It is a raster image, so values were pixel-digitised from
## the embedded bitmap by Heffner_Heffner_2018_Figure3_extract.py (axis ticks ->
## piecewise log calibration; ring-template marker detection; circle-fit
## centres), which wrote the frozen Heffner_Heffner_2018_Figure3_snapshot.csv.
## Label -> marker assignment is a separate visual step:
## reference_tables/Heffner_Heffner_2018_Figure3_label_assignment.csv.
## value_origin = digitised_from_figure on every row.
##
## SECONDARY: the caption says "From Heffner and Heffner, 2016"; the paper
## gives no per-point sources. Value-confirmed traces to original studies
## (via Heffner_etal_1999) are carried in candidate_original_source and
## documented in reference_tables/Heffner_Heffner_2018_Figure3_references.csv.
## Published table/text values take precedence over these figure readings.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_2018_Figure3"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
assign_csv   <- file.path(folder, "reference_tables", paste0(item_name, "_label_assignment.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## UTF-8 output even under Rscript in a C locale (printed names carry Greek/µ/’)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
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
snap   <- read.csv(snapshot_csv, stringsAsFactors = FALSE)
assign <- read.csv(assign_csv, stringsAsFactors = FALSE, encoding = "UTF-8")
refs   <- read.csv(refs_csv, stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 22L, nrow(assign) == 22L, setequal(snap$marker_id, assign$marker_id),
          !anyDuplicated(assign$label_as_printed))
fig_key <- refs$ref_key[refs$cited_in_column == "Figure 3 caption"]
stopifnot(length(fig_key) == 1L)
tr <- refs[grepl("^candidate_original_source", refs$cited_in_column), ]
tr$label <- sub("^.*traced for: (.*)\\)$", "\\1", tr$cited_in_column)
stopifnot(all(tr$label %in% assign$label_as_printed))

## 3. JOIN + CLEAN ------------------------------------------------------
final.dataframe <- snap %>%
  inner_join(assign, by = "marker_id") %>%
  mutate(species = resolve(label_as_printed),
         calibration_spread_pct_x = round(100 * (width_field_best_vision_deg_globalfit /
                                                  width_field_best_vision_deg - 1), 1),
         calibration_spread_pct_y = round(100 * (sound_localization_threshold_deg_globalfit /
                                                  sound_localization_threshold_deg - 1), 1),
         extrapolated = ifelse(width_field_best_vision_deg < 1, "x below lowest printed tick (1 deg)", ""),
         candidate_original_source = tr$ref_key[match(label_as_printed, tr$label)]) %>%
  transmute(marker_id, label_as_printed, species,
            width_field_best_vision_deg, sound_localization_threshold_deg,
            width_field_best_vision_deg_globalfit, sound_localization_threshold_deg_globalfit,
            calibration_spread_pct_x, calibration_spread_pct_y, extrapolated,
            label_confidence = confidence,
            value_origin = "digitised_from_figure",
            figure_source_ref_key = fig_key,
            candidate_original_source = replace_na(candidate_original_source, ""),
            data_role = "secondary") %>%
  arrange(marker_id)

## 4. CROSS-CHECK vs values printed as numbers (README) -----------------
xc <- tibble::tribble(
  ~label,               ~measure,     ~printed, ~where,
  "Egyptian fruit bat", "threshold",  11.6,     "Heffner et al. 1999 Results (repo item)",
  "Egyptian fruit bat", "fbv",        27,       "Heffner et al. 1999 Results (repo item)",
  "big brown bat",      "threshold",  14,       "Heffner et al. 1999 Discussion, citing Koay, Kearns et al. 1998",
  "big brown bat",      "fbv",        139,      "Heffner et al. 1999 Results, citing Koay, Kearns et al. 1998",
  "Norway rat",         "threshold",  12,       "this paper, text p. 130001-5",
  "chinchilla",         "threshold",  17,       "this paper, text p. 130001-5",
  "gerbil",             "threshold",  27,       "this paper, text p. 130001-5")
xc$digitised <- ifelse(xc$measure == "fbv",
  final.dataframe$width_field_best_vision_deg[match(xc$label, final.dataframe$label_as_printed)],
  final.dataframe$sound_localization_threshold_deg[match(xc$label, final.dataframe$label_as_printed)])
xc$pct_diff <- round(100 * (xc$digitised / xc$printed - 1), 1)
print(as.data.frame(xc), row.names = FALSE)

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
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
