# Kaufman (2004), Washington University doctoral dissertation
#   "Pattern and scaling of regional cerebral glucose metabolism in mammals"
# Appendix per-study table: regional cerebral metabolic rate (rCMR) & blood flow (rCBF).
#
# Snapshot -> clean tidy CSV. Golden rule: the snapshot is frozen/faithful to the
# dissertation PDF; ALL cleaning happens here. One row per published study entry.
#
# Units: CMRgl (glucose) & CMRO2 (oxygen) in umol/100 g/min; CBF (blood flow) in mL/100 g/min.
# Columns documented in Kaufman__2004_definitions.csv.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr); library(readxl)
})
options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- region label follows the dissertation's OWN Appendix numbering ----
##  NOTE: the printed dissertation numbers A12 = Sensorimotor Cortex and
##        A13 = Cingulate Cortex. See Kaufman__2004.ReadMe.md.
region_map <- c(
  Kaufman__2004_TableA1  = "Basal Ganglia",
  Kaufman__2004_TableA2  = "Hippocampus",
  Kaufman__2004_TableA3  = "Thalamus",
  Kaufman__2004_TableA4  = "Cerebellum",
  Kaufman__2004_TableA5  = "White Matter",
  Kaufman__2004_TableA6  = "Neocortex",
  Kaufman__2004_TableA7  = "Frontal Cortex",
  Kaufman__2004_TableA8  = "Parietal Cortex",
  Kaufman__2004_TableA9  = "Temporal Cortex",
  Kaufman__2004_TableA10 = "Auditory Cortex",
  Kaufman__2004_TableA11 = "Occipital Cortex",
  Kaufman__2004_TableA12 = "Sensorimotor Cortex",
  Kaufman__2004_TableA13 = "Cingulate Cortex",
  Kaufman__2004_TableA14 = "Whole Brain (direct measurement)"
)
region <- unname(region_map[item_name])
if (is.na(region)) stop("No region mapping for '", item_name, "'.", call. = FALSE)

## ---- read the frozen snapshot (verbatim capture of the PDF table) ----
raw <- read.csv(paste0(item_name, "_snapshot.csv"),
                check.names = FALSE, colClasses = "character", stringsAsFactors = FALSE)
source(file.path(folder, "Kaufman__2004_source_corrections.R"), local = TRUE)
raw <- apply_kaufman_source_corrections(raw, item_name)

# Parse a printed value to numeric: OCR comma -> decimal point; "nr" (not reported),
# blanks and "NA" -> NA. Nothing else is altered.
num <- function(x) {
  x <- gsub(",", ".", trimws(x))
  x[x %in% c("", "nr", "NA", "na", "-")] <- NA
  suppressWarnings(as.numeric(x))
}

clean <- data.frame(
  Species             = trimws(raw$Species),
  Reference           = trimws(raw$Reference),
  n                   = suppressWarnings(as.integer(num(raw$n))),
  Anesthesia          = trimws(raw$Anesthesia),
  Mode                = trimws(raw$Mode),
  Region              = region,
  CMRgl_umol_100g_min = num(raw$Glucose),
  CMRgl_SD            = num(raw$Glucose_SD),
  CMRO2_umol_100g_min = num(raw$Oxygen),
  CMRO2_SD            = num(raw$Oxygen_SD),
  CBF_ml_100g_min     = num(raw$BloodFlow),
  CBF_SD              = num(raw$BloodFlow_SD),
  source              = "Kaufman__2004",
  stringsAsFactors    = FALSE
)

## ---- local CSV: use this script's filename ----
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, " (", region, "): ", nrow(clean), " rows written to ", paste0(item_name, ".csv"))

## ---- public TSV: look up the DOI/UMI code from __ReadMe.xlsx ----
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
