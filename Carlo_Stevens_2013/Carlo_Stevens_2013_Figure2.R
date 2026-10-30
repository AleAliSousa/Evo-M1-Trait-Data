## Carlo_Stevens_2013_Figure2.R -- constructed snapshot (digitized figure) -> analysis CSV + public TSV
##
## Carlo, C. N., & Stevens, C. F. (2013). Structural uniformity of neocortex, revisited.
## PNAS 110(4), 1488-1493. doi:10.1073/pnas.1221398110
##
## Figure 2 (p. 1489): cells (A), neurons (B) and glia (C) under 1 mm2 of cortical surface vs
## cortical thickness, mouse/rat/cat/monkey x M1/S1/parietal/temporal. Values exist only as a
## raster scatter plot; the snapshot is a digitization produced by
## Carlo_Stevens_2013_Figure2_extract_snapshot.py (template matching on the embedded image,
## tick-mark calibration; AI assistant, 2026-10-28). Not printed values -- treat as approximate.
## 0. PATHS --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {                       # source() ("ofile") / sys.source() ("file")
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Carlo_Stevens_2013_Figure2"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 2. LOAD (frozen snapshot, read positionally as text) -------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", encoding = "UTF-8", check.names = FALSE)

## 2b. SPECIES KEY (collection-scoped: _keys/General; source_publication = folder name)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder), call. = FALSE)
lk <- stats::setNames(key$accepted_name, key$variant_name)
harmonise <- function(x) {
  out <- unname(lk[x]); miss <- !is.na(x) & nzchar(x) & is.na(out)
  if (any(miss)) stop("Printed name(s) missing from species_key: ",
                      paste(unique(x[miss]), collapse = "; "), call. = FALSE)
  out
}
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))

## 3. CLEAN -----------------------------------------------------------
## Constructed snapshot (digitized figure; see Carlo_Stevens_2013_Figure2_extract_snapshot.py):
## one row per plotted point (24 = specimen x area, Table S1 without frontal); values in
## thousands of cells under 1 mm2 of cortical surface, thickness in mm. Cortical area and
## specimen of each point are NOT identified by the figure (markers code species only).
snap <- utils::read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 24)
final.dataframe <- tibble(
  point_id = snap$point_id,
  species_as_published = snap$legend_marker,                       # legend label as printed
  Species = harmonise(snap$legend_marker),
  cortical_thickness_mm = snap[["cortical thickness (mm)"]],
  cells_per_mm2   = snap[["A: Number of cells under 1 mm2 (thousands of cells)"]] * 1000,   # thousands -> cells
  neurons_per_mm2 = snap[["B: Number of neurons under 1 mm2 (thousands of cells)"]] * 1000,
  glia_per_mm2    = snap[["C: Number of glia under 1 mm2 (thousands of cells)"]] * 1000,
  glia_neuron_ratio = round(glia_per_mm2 / neurons_per_mm2, 3),               # derived, not printed
  occluded_in = na_if(snap$occluded_in, ""),
  digitization_note = na_if(snap$note, ""),
  value_type = "digitized from figure (approx. +/- 0.5 thousand cells, +/- 0.005 mm)",
  data_role = "primary")

## 3b. TABLE CHECKS (HOWTO 7a; figure-internal relations and printed statistics) -----
fitc <- function(y) stats::coef(stats::lm(y ~ final.dataframe$cortical_thickness_mm)) / 1000
fA <- fitc(final.dataframe$cells_per_mm2); fB <- fitc(final.dataframe$neurons_per_mm2); fC <- fitc(final.dataframe$glia_per_mm2)
sumdiff <- (final.dataframe$cells_per_mm2 - final.dataframe$neurons_per_mm2 - final.dataframe$glia_per_mm2) / 1000
table_checks <- tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance, ~note,
  "A_eq_B_plus_C_maxabs", "max |A - (B + C)| over 24 points (thousands)", max(abs(sumdiff)), 0, 1.5, "panel A = neurons + glia; digitization tolerance",
  "slope_A", "regression slope, panel A (thousand cells per mm thickness)", fA[[2]], 18.8, 1.0, "printed in Fig. 2 legend",
  "intercept_A", "regression intercept, panel A (thousand cells)", fA[[1]], 121, 2.0, "printed in Fig. 2 legend",
  "slope_B", "regression slope, panel B", fB[[2]], -2.7, 1.0, "printed in Fig. 2 legend",
  "intercept_B", "regression intercept, panel B", fB[[1]], 94, 2.0, "printed 94 equals the printed mean neuron number; a slope of -2.7 through the data implies ~98",
  "mean_B", "mean neurons under 1 mm2 (thousands)", mean(final.dataframe$neurons_per_mm2) / 1000, 94.0, 0.5, "Results text: 94.0 +/- 10.7 thousand",
  "sd_B", "SD neurons under 1 mm2 (thousands)", stats::sd(final.dataframe$neurons_per_mm2) / 1000, 10.7, 0.5, "Results text",
  "slope_C", "regression slope, panel C", fC[[2]], 21.1, 1.0, "printed in Fig. 2 legend",
  "intercept_C", "regression intercept, panel C", fC[[1]], 23, 2.0, "printed in Fig. 2 legend") %>%
  mutate(difference = observed - printed,
         status = ifelse(check_id == "A_eq_B_plus_C_maxabs", ifelse(observed <= tolerance, "pass", "mismatch"),
                         ifelse(abs(difference) <= tolerance, "pass", "mismatch")))

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write_csv(final.dataframe, final_csv, na = "")                       # readr: always UTF-8
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]

  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
if (exists("table_checks") && any(table_checks$status != "pass"))
  print(as.data.frame(table_checks[table_checks$status != "pass", c("check_id","observed","printed","difference","tolerance","status")]))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
