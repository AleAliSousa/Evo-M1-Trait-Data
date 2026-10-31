## Chugani_etal_1987_Figure2A.R -- constructed snapshot (digitised figure) -> analysis CSV + public TSV
##
## Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). Positron emission tomography
## study of human brain functional development. Ann. Neurol. 22, 487-497.
## doi:10.1002/ana.410220408
##
## THE ITEM IS A FIGURE (constructed snapshot). FIG 2 plots absolute lCMRGlc against
## age. PANEL A (p. 492): absolute lCMRGlc for four regions of cerebral cortex --
## filled square = Frontal cortex, filled circle = Parietal cortex, open circle =
## Temporal cortex, filled triangle = Occipital cortex.
## Caption: in infants and children each point is ONE patient of Table 1 (29 of them);
## the rightmost point of each series is the mean of 7 normal adults aged 19-30 years,
## plotted with the symbol size equal to its SEM. So each series carries 30 points.
##
## The pages are grey SCANS; the points were pixel-digitised from the embedded page
## bitmaps by Chugani_etal_1987_Figure2_extract.py (axis calibration + glyph template
## matching, constrained to the 29 printed patient ages), which wrote the frozen
## Chugani_etal_1987_Figure2A_snapshot.csv. 101 of the 120 plotted points were
## individually resolved; the rest overprint one another and are ABSENT from both the
## snapshot and this CSV -- nothing is interpolated. See the README.
## value_origin = digitised_from_figure on every row; data_role = primary.
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
stopifnot(nrow(snap) == 101, all(c("panel","series_as_printed","plot_symbol",
          "subject_slot","age_as_printed_Table1","lCMRGlc_umol_min_100g") %in% names(snap)))

## 3. CLEAN -------------------------------------------------------------
## printed age strings -> decimal years (the snapshot keeps the printed string)
age_to_years <- function(x) {
  n <- suppressWarnings(as.numeric(sub("^([0-9.]+)\\s+.*$", "\\1", x)))
  ifelse(grepl("^adult", x), NA_real_,
  ifelse(grepl("day",   x), n / 365.25,
  ifelse(grepl("week",  x), n * 7 / 365.25,
  ifelse(grepl("month", x), n / 12,
  ifelse(grepl("year",  x), n, NA_real_)))))
}
final.dataframe <- snap %>%
  arrange(panel, px_x, px_y) %>%
  transmute(point_id   = sprintf("%s_%s_%s", panel, subject_slot,
                                 abbreviate(gsub("[^A-Za-z]", "", series_as_printed), 6)),
            panel,
            species_as_published = "human",
            Species       = resolve("human"),
            species_basis = resolve_basis("human"),
            structure_as_printed = series_as_printed,
            plot_symbol,
            subject_slot,
            observation_level = ifelse(subject_slot == "Adult",
                                       "group mean of 7 normal adults aged 19-30 y",
                                       "individual patient (Table 1)"),
            age_as_printed = age_as_printed_Table1,
            age_years      = round(age_to_years(age_as_printed_Table1), 4),
            age_years_from_abscissa,
            lCMRGlc.umol_min_100g = lCMRGlc_umol_min_100g,
            ncc_score = ncc,
            value_origin   = "digitised_from_figure",
            value_precision = "+/- 0.3 umol/min/100 g (digitisation; see README)",
            data_role = "primary")

## 4. TABLE CHECKS (HOWTO 7a) -- digitised points vs this paper's own Table 2 --------
## Table 2 prints the mean lCMRGlc of the same patients, by the same four age bins
## (n = 7 / 4 / 12 / 6) plus the adult group, for every series plotted here. The bin
## means are recomputed from the resolved points and compared.
T2 <- tibble::tribble(
  ~structure_as_printed, ~bin, ~printed,
  "Frontal cortex", "Birth-1 year", 19.68,
  "Frontal cortex", "1-2 years", 29.65,
  "Frontal cortex", "3-8 years", 54.01,
  "Frontal cortex", "9-15 years", 44.59,
  "Frontal cortex", "Adult", 27.11,
  "Parietal cortex", "Birth-1 year", 20.23,
  "Parietal cortex", "1-2 years", 28.76,
  "Parietal cortex", "3-8 years", 53.98,
  "Parietal cortex", "9-15 years", 43.1,
  "Parietal cortex", "Adult", 24.15,
  "Temporal cortex", "Birth-1 year", 20.0,
  "Temporal cortex", "1-2 years", 28.64,
  "Temporal cortex", "3-8 years", 48.94,
  "Temporal cortex", "9-15 years", 40.05,
  "Temporal cortex", "Adult", 23.98,
  "Occipital cortex", "Birth-1 year", 20.54,
  "Occipital cortex", "1-2 years", 30.39,
  "Occipital cortex", "3-8 years", 56.35,
  "Occipital cortex", "9-15 years", 45.66,
  "Occipital cortex", "Adult", 26.85

)
bin_of <- function(a, slot) ifelse(slot == "Adult", "Adult",
                            ifelse(a <= 0.99, "Birth-1 year",
                            ifelse(a <= 2.5, "1-2 years",
                            ifelse(a <= 8.99, "3-8 years", "9-15 years"))))
obs <- final.dataframe %>%
  mutate(bin = bin_of(age_years, subject_slot)) %>%
  group_by(structure_as_printed, bin) %>%
  summarise(observed = round(mean(lCMRGlc.umol_min_100g), 2), n_resolved = dplyr::n(),
            .groups = "drop")
n_expected <- c("Birth-1 year" = 7, "1-2 years" = 4, "3-8 years" = 12, "9-15 years" = 6, "Adult" = 1)
table_checks <- T2 %>%
  left_join(obs, by = c("structure_as_printed", "bin")) %>%
  transmute(check_id = paste0("fig_vs_Table2_", gsub("[^A-Za-z0-9]+", "", structure_as_printed),
                              "_", gsub("[^A-Za-z0-9]+", "", bin)),
            basis = paste0("mean of the resolved Fig. 2 points vs the Table 2 mean: ",
                           structure_as_printed, ", ", bin),
            observed, printed,
            difference = round(observed - printed, 2),
            ## isolated markers reproduce Table 2 to +/- 0.3 (the 13 adult points);
            ## a bin mean computed from an incomplete set of resolved points can
            ## legitimately differ further, so the tolerance scales with the fraction
            ## of that bin's points that could be resolved.
            tolerance = round(0.3 + 3.0 * (1 - n_resolved / n_expected[bin]), 2),
            note = paste0(n_resolved, " of ", n_expected[bin], " plotted points resolved")) %>%
  mutate(status = ifelse(is.na(observed), "not_evaluable",
                  ifelse(abs(difference) <= tolerance, "pass", "mismatch")))

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
