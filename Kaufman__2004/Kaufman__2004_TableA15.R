# Kaufman (2004) dissertation — Table A15 "Species Means in Conscious Subjects".
# Computed species-level summary (N, Mean, SD, CV, CV* = unbiased CV) for each
# genus x weighting x brain region x energetic measure.
#
# Snapshot -> clean tidy CSV. The snapshot is the faithful capture of the printed
# Table A15 statistics; this script only adds units and orders rows.
#
# Weightings: unweighted (each study counts equally) / weighted (each individual counts).
# Measures/units: CMRgl (glucose) & CMRO2 (oxygen) umol/100 g/min; CBF (blood flow) mL/100 g/min.

suppressPackageStartupMessages({ library(readr); library(dplyr); library(readxl) })
options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

raw <- read.csv(paste0(item_name, "_snapshot.csv"),
                check.names = FALSE, colClasses = "character", stringsAsFactors = FALSE)
num <- function(x) { x <- gsub(",", ".", trimws(x)); x[x %in% c("", "nr", "NA")] <- NA; suppressWarnings(as.numeric(x)) }

clean <- data.frame(
  species   = trimws(raw$Species),
  weighting = trimws(raw$weighting),
  region    = trimws(raw$region),
  measure   = trimws(raw$measure),
  units     = ifelse(trimws(raw$measure) == "CBF", "mL/100g/min", "umol/100g/min"),
  N         = suppressWarnings(as.integer(num(raw$N))),
  Mean      = num(raw$Mean),
  SD        = num(raw$SD),
  CV        = num(raw$CV),
  CVstar    = num(raw$CVstar),
  note      = ifelse(is.na(raw$note) | trimws(raw$note)=="", NA_character_, trimws(raw$note)),
  stringsAsFactors = FALSE
)

write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", paste0(item_name, ".csv"))

## ---- public TSV via __ReadMe.xlsx Item encoded ----
tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
