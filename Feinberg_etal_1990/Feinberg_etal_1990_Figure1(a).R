## Feinberg_etal_1990_Figure1(a).R -- constructed snapshot (digitised figure) -> CSV + TSV
##
## Feinberg, I., Thode, H. C., Jr., Chugani, H. T., & March, J. D. (1990). Gamma distribution
## model describes maturational curves for delta wave amplitude, cortical metabolic rate and
## synaptic density. J. theor. Biol. 142, 149-161. doi:10.1016/S0022-5193(05)80218-8
##
## THE ITEM IS A FIGURE (constructed snapshot) AND THE DATA ARE SECONDARY.
## FIG. 1(a) (p. 152) plots the RAW SYNAPTIC-DENSITY OBSERVATIONS the authors fitted their
## gamma model to. Those observations are not theirs: they are Huttenlocher (1979), N = 12
## (Table 2 of this paper). Every row therefore carries data_role = secondary and the
## primary citation is in reference_tables/Feinberg_etal_1990_Figure1(a)_references.csv.
## The item exists for provenance and for the ages: Feinberg's abscissa is a SINGLE LINEAR
## 0-35 year axis, whereas Huttenlocher's Fig. 3 abscissa is broken and piecewise linear,
## so this panel is the better source of the age of each observation.
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
stopifnot(nrow(snap) == 12L)

## 3. CLEAN -------------------------------------------------------------
final.dataframe <- snap %>%
  arrange(px_x) %>%
  transmute(point_id = sprintf("F1a_%02d", seq_len(dplyr::n())),
            species_as_published = "human",
            Species       = resolve("human"),
            species_basis = resolve_basis("human"),
            structure_as_published = "frontal cortex, layer 3 middle frontal gyrus",
            age_years,
            Synaptic_density.synapses_mm3 = value_in_figure_units * 1e8,
            marker_detection = detection,
            value_origin  = "digitised_from_figure",
            value_precision = "+/- 0.2 x 10^8 synapses/mm3 and +/- 0.2 y (digitisation)",
            primary_source_ref_key = "Huttenlocher (1979)",
            data_role = "secondary")

## 4. TABLE CHECKS (HOWTO 7a) -- the replotted points against the PRIMARY source ----------
## The primary study is built in this repo as Huttenlocher__1979_Figure3. Its Fig. 3 plots
## 22 brains; Feinberg used "only data from birth to 30 years of age" (p. 152), which is 12
## of them -- the N its own Table 2 prints. The two sets are paired by sorted value (no
## common key exists) and compared.
h3 <- read.csv(file.path(base, "Huttenlocher__1979", "Huttenlocher__1979_Figure3_snapshot.csv"),
               comment.char = "#", stringsAsFactors = FALSE)
h3 <- h3[!is.na(h3$age_years_from_abscissa) & h3$age_years_from_abscissa <= 32, ]
hv <- sort(h3$value_in_figure_units); fv <- sort(final.dataframe$Synaptic_density.synapses_mm3 / 1e8)
ha <- h3$age_years_from_abscissa[order(h3$value_in_figure_units)]
fa <- final.dataframe$age_years[order(final.dataframe$Synaptic_density.synapses_mm3)]
nobreak <- h3$age_in_axis_break[order(h3$value_in_figure_units)] == "no"
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance, ~note,
  "n_points",  "points plotted in Fig. 1(a) (Table 2 of this paper: N = 12 for synaptic density)",
               nrow(final.dataframe), 12, 0, "",
  "n_source",  "Huttenlocher Fig. 3 brains aged <= 32 y, the set Feinberg says it used ('birth to 30 years')",
               length(hv), 12, 0, "",
  "value_mean_abs_diff", "mean |Fig1(a) - Huttenlocher Fig. 3| over the 12 sorted values (x 10^8 synapses/mm3)",
               round(mean(abs(fv - hv)), 3), 0, 0.2, "both sides are digitisations; 0.2 is the summed digitisation error",
  "value_max_abs_diff",  "max |Fig1(a) - Huttenlocher Fig. 3| over the 12 sorted values (x 10^8 synapses/mm3)",
               round(max(abs(fv - hv)), 3), 0, 0.3, "",
  "age_max_abs_diff_clean", "max |age difference| for the source points NOT lying in one of Huttenlocher's axis breaks (years)",
               round(max(abs(fa[nobreak] - ha[nobreak])), 2), 0, 1.0,
               "Huttenlocher's abscissa is broken; Feinberg's is linear",
  "age_max_abs_diff_all",   "max |age difference| over all 12 points (years)",
               round(max(abs(fa - ha)), 2), 0, 1.0,
               "the two largest differences are the two Huttenlocher points that fall inside an axis break") %>%
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
