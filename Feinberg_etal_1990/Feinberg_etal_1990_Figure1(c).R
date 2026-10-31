## Feinberg_etal_1990_Figure1(c).R -- constructed snapshot (digitised figure) -> CSV + TSV
##
## Feinberg, I., Thode, H. C., Jr., Chugani, H. T., & March, J. D. (1990). Gamma distribution
## model describes maturational curves for delta wave amplitude, cortical metabolic rate and
## synaptic density. J. theor. Biol. 142, 149-161. doi:10.1016/S0022-5193(05)80218-8
##
## THE ITEM IS A FIGURE (constructed snapshot) AND THE DATA ARE SECONDARY.
## FIG. 1(c) (p. 152) plots the RAW CEREBRAL METABOLIC RATE observations the authors fitted
## their gamma model to. Those observations are not theirs: they are the FRONTAL CORTEX
## lCMRGlc values of Chugani, Phelps & Mazziotta (1987), N = 29 (Table 2 of this paper and
## the 29 patients of Chugani's Table 1). Every row carries data_role = secondary and the
## primary citation is in reference_tables/Feinberg_etal_1990_Figure1(c)_references.csv.
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
stopifnot(nrow(snap) == 28L)

## 3. CLEAN -------------------------------------------------------------
final.dataframe <- snap %>%
  arrange(px_x) %>%
  transmute(point_id = sprintf("F1c_%02d", seq_len(dplyr::n())),
            species_as_published = "human",
            Species       = resolve("human"),
            species_basis = resolve_basis("human"),
            structure_as_published = "frontal cortex",
            age_years,
            lCMRGlc.umol_min_100g = value_in_figure_units,
            marker_detection = detection,
            value_origin  = "digitised_from_figure",
            value_precision = "+/- 0.5 umol/min/100 g and +/- 0.2 y (digitisation)",
            primary_source_ref_key = "Chugani et al. (1987)",
            data_role = "secondary")

## 4. TABLE CHECKS (HOWTO 7a) -- the replotted points against the PRIMARY source ----------
## Chugani's Table 2 prints the FRONTAL CORTEX mean lCMRGlc of the very same 29 patients in
## four age bins of n = 7 / 4 / 12 / 6. Bin membership is fixed by the patients' printed
## ages (Chugani Table 1), so the resolved points are assigned to bins by age RANK, not by
## Feinberg's own abscissa reading (which places Chugani's 1.0-year patient just below 1 y).
## One of the 29 points could not be resolved; the shortfall is taken in the 3-8 y bin,
## which is where the unresolved point lies on Feinberg's abscissa.
nrank <- c(7, 4, 11, 6)
bin <- rep(c("Birth-1 year", "1-2 years", "3-8 years", "9-15 years"), nrank)
stopifnot(length(bin) == nrow(final.dataframe))
F <- final.dataframe %>% arrange(age_years) %>% mutate(bin = bin)
T2 <- c("Birth-1 year" = 19.68, "1-2 years" = 29.65, "3-8 years" = 54.01, "9-15 years" = 44.59)
obs <- F %>% group_by(bin) %>% summarise(m = round(mean(lCMRGlc.umol_min_100g), 2), .groups = "drop")
g <- function(b) obs$m[obs$bin == b]
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance, ~note,
  "n_points", "points resolved in Fig. 1(c); Table 2 of this paper prints N = 29 for CMR",
              nrow(final.dataframe), 29, 0, "28 of 29 resolved; one circle could not be separated",
  "bin_Birth1y", "mean of the Birth-1 year points vs Chugani Table 2 frontal cortex",
              g("Birth-1 year"), T2[["Birth-1 year"]], 1.0, "",
  "bin_1to2y",   "mean of the 1-2 years points vs Chugani Table 2 frontal cortex",
              g("1-2 years"), T2[["1-2 years"]], 1.0, "",
  "bin_3to8y",   "mean of the 3-8 years points vs Chugani Table 2 frontal cortex",
              g("3-8 years"), T2[["3-8 years"]], 1.0, "11 of 12 points resolved",
  "bin_9to15y",  "mean of the 9-15 years points vs Chugani Table 2 frontal cortex",
              g("9-15 years"), T2[["9-15 years"]], 1.0, "",
  "range_min",   "lowest plotted value vs the lowest frontal-cortex point digitised from Chugani Fig. 2A",
              round(min(F$lCMRGlc.umol_min_100g), 1), 14.8, 2.0, "",
  "range_max",   "highest plotted value vs the highest frontal-cortex point digitised from Chugani Fig. 2A",
              round(max(F$lCMRGlc.umol_min_100g), 1), 59.7, 2.0, "") %>%
  mutate(difference = round(observed - printed, 2),
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
