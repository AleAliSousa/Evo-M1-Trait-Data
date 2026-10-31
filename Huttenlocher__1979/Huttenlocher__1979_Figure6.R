## Huttenlocher__1979_Figure6.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Huttenlocher, P. R. (1979). Synaptic density in human frontal cortex: developmental
## changes and effects of aging. Brain Res. 163, 195-205. doi:10.1016/0006-8993(79)90349-4
##
## THE ITEM IS A FIGURE (constructed snapshot). The paper publishes no data table at all:
## every value lives in a figure.
## FIG. 6 (p. 203) plots the total weight of the brains the study's data came from, against
## age, as open circles with +/- 1 S.D. confidence limits. Printed in GRAMS; converted to
## the project unit for brain mass (mg) in this script.
##
## The page is a grey SCAN; the markers were pixel-digitised from the embedded page bitmap
## by Huttenlocher__1979_Figures3-6_extract.py, which wrote the frozen
## Huttenlocher__1979_Figure6_snapshot.csv. value_origin = digitised_from_figure on every row.
##
## THE ABSCISSA IS BROKEN AND PIECEWISE LINEAR, and two of its columns ('Adult',
## 'Aged (74-90)') are CATEGORICAL, not numeric ages. age_years is NA for those; where a
## marker falls inside an axis-break gap the age is extrapolated from the nearer printed
## segment and age_in_axis_break = yes -- such an age is not an exact reading.
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

## 2. LOAD (frozen snapshot -- the digitisation as captured) -----------------
snap <- read.csv(snapshot_csv, comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 10)

## 3. CLEAN -------------------------------------------------------------
final.dataframe <- snap %>%
  arrange(plot_symbol, px_x) %>%
  transmute(point_id = sprintf("%s_%s_%02d", figure, abbreviate(gsub("[^A-Za-z]", "", plot_symbol), 6),
                               ave(px_x, plot_symbol, FUN = seq_along)),
            species_as_published = "human",
            Species       = resolve("human"),
            species_basis = resolve_basis("human"),
            series_as_printed, plot_symbol,
            age_column,
            age_years = suppressWarnings(as.numeric(age_years_from_abscissa)),
            age_in_axis_break, abscissa_segment,
            Brain_mass.mg = value_in_figure_units * 1000.0,
            value_origin = "digitised_from_figure",
            value_precision = "+/- 10 g (digitisation); age piecewise from a broken abscissa",
            data_role = "primary")

## 4. TABLE CHECKS (HOWTO 7a) -- digitised points vs this paper's own printed statements
O <- final.dataframe
adult <- O$Brain_mass.mg[O$age_column == "Adult"]
at <- function(a) O$Brain_mass.mg[which.min(abs(O$age_years - a))]
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance, ~note,
  "n_points",      "open circles resolved in Fig. 6", nrow(final.dataframe), 10, 0,
                   "no printed count; 10 is what the detector resolves",
  "pct_2y_to_adult","adult brain weight as % above the 2-year value (p. 202: 'Total brain weight increases only by about 20% between ages 2 years and maturity')",
                   round(100 * (adult / at(2) - 1), 1), 20, 5, "reported, not reconciled",
  "adult_weight",  "adult brain weight (g) -- no printed value; checked against the normal adult range",
                   round(adult / 1000), 1350, 250, "range check only, not a printed value",
  "newborn_weight","lowest (newborn) brain weight (g) -- no printed value; checked against the normal term range",
                   round(min(O$Brain_mass.mg) / 1000), 375, 125, "range check only, not a printed value") %>%
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
  bad <- table_checks[table_checks$status != "pass", , drop = FALSE]
  cat("table_checks:", nrow(table_checks), "checks,", nrow(bad), "not pass\n")
  if (nrow(bad)) print(as.data.frame(bad), row.names = FALSE)
}
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
