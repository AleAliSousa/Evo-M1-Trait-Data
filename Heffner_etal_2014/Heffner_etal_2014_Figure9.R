## Heffner_etal_2014_Figure9.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna pacos):
## Audiogram, localization acuity, and use of binaural locus cues. J. Acoust. Soc. Am.
## 135, 778-788. doi:10.1121/1.4861344
##
## THE ITEM IS A FIGURE (constructed snapshot). FIG. 9 (p. 785) is a one-dimensional
## logarithmic scale (1-180 deg) of behaviourally determined sound-localization
## thresholds; each printed common name is joined to the scale by a leader line whose
## meeting point is the datum. The figure is a raster image, so the 34 leader lines were
## pixel-digitised from the embedded bitmap by Heffner_etal_2014_Figure9_extract.py,
## which wrote the frozen Heffner_etal_2014_Figure9_snapshot.csv.
##
## SECONDARY. The caption says only "For specific citations, see Heffner and Heffner,
## 2003, and Heffner et al., 2007": no per-species source is keyed, so an individual
## point cannot be traced to its primary study from this figure
## (reference_tables/Heffner_etal_2014_Figure9_references.csv records that).
## Four printed labels name two species each, which therefore SHARE one plotted tick;
## those rows are split here and flagged shares_tick_with.
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
stopifnot(nrow(snap) == 34L, nrow(refs) == 2L)

## 3. CLEAN: one row per species (labels naming two species are split) ----
final.dataframe <- snap %>%
  mutate(sp = strsplit(label_as_printed, ",\\s*")) %>%
  tidyr::unnest_longer(sp) %>%
  group_by(label_as_printed) %>%
  mutate(shares_tick_with = paste(setdiff(sp, sp[1]), collapse = "; ")) %>%
  ungroup() %>%
  mutate(shares_tick_with = ifelse(lengths(strsplit(label_as_printed, ",")) > 1,
                                   vapply(seq_along(sp), function(i)
                                     paste(setdiff(unlist(strsplit(label_as_printed[i], ",\\s*")), sp[i]),
                                           collapse = "; "), character(1)), "")) %>%
  transmute(label_as_printed,
            species_as_published = sp,
            Species = resolve(sp),
            species_basis = resolve_basis(sp),
            scale_side,
            localization_threshold_deg,
            localization_threshold_deg_globalfit,
            calibration_spread_pct = round(100 * (localization_threshold_deg_globalfit /
                                                    localization_threshold_deg - 1), 2),
            shares_tick_with,
            value_origin = "digitised_from_figure",
            value_precision = "+/- 0.5% (calibration spread) + ~0.2% per pixel of leader-line placement",
            figure_source_ref_key = paste(refs$ref_key, collapse = "; "),
            data_role = "secondary") %>%
  arrange(localization_threshold_deg, species_as_published)

## 4. TABLE CHECKS (HOWTO 7a) ------------------------------------------
gv <- function(s) final.dataframe$localization_threshold_deg[final.dataframe$species_as_published == s]
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "alpaca_MAA", "alpaca point (deg); Results III.B of this paper: 23 deg", gv("alpaca"), 23, 1.0,
  "scale_top",  "blind mole rat / gopher at the top of the printed scale (deg)", gv("gopher"), 180, 2.0,
  "n_species",  "species resolved from 34 leader lines", nrow(final.dataframe), 38, 0,
  "max_calib_spread", "largest |calibration spread| (%)",
                 max(abs(final.dataframe$calibration_spread_pct)), 0, 1.0) %>%
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
