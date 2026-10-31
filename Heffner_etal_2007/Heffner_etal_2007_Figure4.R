## Heffner_etal_2007_Figure4.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2007). Sound-localization acuity and its
## relation to vision in large and small fruit-eating bats: I. Echolocating species,
## Phyllostomus hastatus and Carollia perspicillata. Hearing Research 234, 1-9.
## doi:10.1016/j.heares.2007.06.001
##
## THE ITEM IS A FIGURE (constructed snapshot). Fig. 4 (p. 6) draws retinal ganglion-cell
## isodensity contours (>=25%, >=50%, >=75% of maximum density) for the two species, each
## with a 1 mm scale bar and NO axes. The quantitative content is therefore areal, and the
## snapshot is a SCALE-BAR PLANIMETRY produced by Heffner_etal_2007_Figure4_extract.py,
## which wrote the frozen Heffner_etal_2007_Figure4_snapshot.csv.
##
## PRIMARY: these are this paper's own retinae. The angular width of the field of best
## vision is NOT measured here -- the paper states it in the text (51 deg / 110 deg) and
## the sibling item Heffner_etal_2007_Figure6 already carries those values; they enter
## this item only as the constants that convert the digitised >=75% extent to deg/mm.
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
stopifnot(nrow(snap) == 2L)

## 3. CLEAN -------------------------------------------------------------
## Printed in this paper's Section 3.2 (not measured from the figure), used only to
## express the digitised >=75% extent in degrees:
fbv_deg   <- c("Phyllostomus hastatus" = 51, "Carollia perspicillata" = 110)
diam_text <- c("Phyllostomus hastatus" = 4.6, "Carollia perspicillata" = 2.6)

final.dataframe <- snap %>%
  transmute(species_as_published = species_as_printed,
            Species = resolve(species_as_printed),
            species_basis = resolve_basis(species_as_printed),
            common_name_as_published = common_name_as_printed,
            retina_flatmount_area_mm2 = retina_outline_area_mm2,
            retina_nasotemporal_extent_mm = nasotemporal_extent_mm,
            retina_superoinferior_extent_mm = superoinferior_extent_mm,
            area_ge25pct_maxdensity_mm2 = area_ge25pct_mm2,
            area_ge50pct_maxdensity_mm2 = area_ge50pct_mm2,
            area_ge75pct_maxdensity_mm2 = area_ge75pct_mm2,
            pct_retina_ge50 = pct_retina_ge50,
            pct_retina_ge75 = pct_retina_ge75,
            fbv75_nasotemporal_extent_mm = fbv75_nasotemporal_extent_mm,
            fbv75_superoinferior_extent_mm = fbv75_superoinferior_extent_mm,
            fbv75_width_deg_from_text = unname(fbv_deg[species_as_printed]),
            implied_deg_per_mm_retina = round(unname(fbv_deg[species_as_printed]) /
                                                fbv75_nasotemporal_extent_mm, 2),
            scale_bar_px, mm_per_px,
            value_origin = "digitised_from_figure (scale-bar planimetry)",
            value_precision = paste0("areas +/- ~3% (1 px of contour edge over the outline); ",
                                     "linear extents +/- ", round(2 * mm_per_px, 3), " mm"),
            data_role = "primary")

## 4. TABLE CHECKS (HOWTO 7a) -- against this paper's own printed Section 3.2 numbers ---
gv <- function(sp, col) final.dataframe[[col]][final.dataframe$species_as_published == sp]
ratio_extent <- gv("Phyllostomus hastatus", "retina_nasotemporal_extent_mm") /
                gv("Carollia perspicillata", "retina_nasotemporal_extent_mm")
ratio_degmm  <- gv("Carollia perspicillata", "implied_deg_per_mm_retina") /
                gv("Phyllostomus hastatus", "implied_deg_per_mm_retina")
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "Ph_diameter_mm", "P. hastatus nasotemporal extent (mm); Section 3.2: 'was 4.6 mm in diameter'",
                    gv("Phyllostomus hastatus", "retina_nasotemporal_extent_mm"), 4.6, 0.3,
  "Cp_diameter_mm", "C. perspicillata nasotemporal extent (mm); Section 3.2: 'approximately 2.6 mm in diameter'",
                    gv("Carollia perspicillata", "retina_nasotemporal_extent_mm"), 2.6, 0.3,
  "Ph_degpermm",    "P. hastatus deg/mm implied by 51 deg over the digitised >=75% extent, vs 180 deg over the 4.6 mm retina (39.1 deg/mm)",
                    gv("Phyllostomus hastatus", "implied_deg_per_mm_retina"), 39.1, 6,
  "degpermm_ratio", "deg/mm ratio (Cp / Ph) vs the inverse ratio of retinal extents -- an internal consistency test of the planimetry",
                    ratio_degmm, ratio_extent, 0.1) %>%
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
