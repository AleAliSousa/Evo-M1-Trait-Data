# Boyer_Harrington_2019_SOMTableS6.R
#
# Purpose
#   Build Boyer & Harrington (2019) SOM Table S6 into a lean, analysis-ready CSV.
#   One row per species: endocranial volume, body mass, the internal-carotid and
#   vertebral artery radii, their wall shear stresses, and the resulting blood
#   flow rates (QICA, QVA, QTOT). Everything comes from the paper's own
#   supplementary material -- no crosswalk, no comparison files.
#
#   Boyer DM, Harrington AR (2019). New estimates of blood flow rates in the
#   vertebral artery of euarchontans and their implications for encephalic
#   blood flow scaling. J. Hum. Evol.
#
# Input
#   Boyer_Harrington_2019_SOMTableS6_snapshot.xlsx sheet: TableS6
#     Frozen, journal-faithful copy of SOM Table S6 as printed in the supplement
#     (mmc1.docx). All cleaning happens here in R, never in the snapshot. Row 1
#     is the header; each following row is one species. The genus abbreviations
#     the paper uses in this table (D. = Daubentonia, M. = Mandrillus,
#     O. = Otolemur) are expanded here into full binomials.
#
# Outputs
#   Boyer_Harrington_2019_SOMTableS6.csv           one row per species (53 rows)
#   <DOI>.tsv in __Public/comparative-data/        tab-separated copy named by the
#                                                  item's encoded DOI (from __ReadMe.xlsx)
#
# Column definitions (from the SOM Table S6 caption):
#   ECV   = endocranial volume (mL);
#   BM    = body mass (g);
#   RICA  = internal carotid artery radius (mm) = carotid canal radius / 1.4;
#   RVA   = vertebral artery radius (mm)        = transverse foramen radius / 1.4;
#   tau_ICA = ICA wall shear stress, predicted from 167 * BM^-0.20;
#   tau_VA  = VA  wall shear stress, predicted from 285 * BM^-0.22;
#           (the caption gives no units for the shear-stress columns);
#   QICA  = blood flow through the bilateral internal carotid arteries (mL/s);
#   QVA   = blood flow through the bilateral vertebral arteries (mL/s);
#   QTOT  = total encephalic blood flow = QICA + QVA (mL/s).
#
# "NA" cells are preserved as missing (Sciurus carolinensis has no RICA/QICA:
# its cranial-foramen specimen is of unknown species -- see the paper's notes).
# Values are transcribed faithfully; the spaced binomial is emitted as the
# canonical `Species` column.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

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

source_file  <- "Boyer_Harrington_2019_SOMTableS6_snapshot.xlsx"   # frozen, journal-faithful copy
source_sheet <- "TableS6"
output_file  <- paste0(item_name, ".csv")

# ---- helpers ---------------------------------------------------------------

parse_value <- function(x) parse_number(x, na = c("", "-", "NA", "n.a."))

# Complete the paper's own genus abbreviations in this table (do not change
# taxonomy); expansions are printed in the SOM Table S6 caption.
abbrev_fixes <- c(
  "D. madagascariensis" = "Daubentonia madagascariensis",
  "M. leucophaeus"      = "Mandrillus leucophaeus",
  "O. crassicaudatus"   = "Otolemur crassicaudatus"
)
complete_name <- function(x) ifelse(x %in% names(abbrev_fixes), abbrev_fixes[x], x)

# ---- read the raw sheet (all text; we control parsing) ---------------------

raw <- read_excel(source_file, sheet = source_sheet,
                  col_names = FALSE, col_types = "text", na = c(""))
# Fixed 10-column layout: Species, ECV, BM, RICA, RVA, tauICA, tauVA, QICA, QVA, QTOT.
names(raw) <- paste0("V", seq_len(ncol(raw)))

# ---- species data rows: drop the header row, keep named species ------------

data_rows <- raw %>%
  mutate(V1 = str_squish(V1)) %>%
  filter(!is.na(V1), V1 != "Species")

final.dataframe <- data_rows %>%
  transmute(
    Species    = unname(complete_name(V1)),   # canonical spaced binomial (abbrevs expanded)
    ECV_ml     = parse_value(V2),
    BM_g       = parse_value(V3),
    RICA_mm    = parse_value(V4),
    RVA_mm     = parse_value(V5),
    tau_ICA    = parse_value(V6),
    tau_VA     = parse_value(V7),
    QICA_ml_s  = parse_value(V8),
    QVA_ml_s   = parse_value(V9),
    QTOT_ml_s  = parse_value(V10)
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder --------

write.csv(final.dataframe, file = output_file, row.names = FALSE)
message("Wrote ", output_file, "  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

# ---- run summary -----------------------------------------------------------

message("Rows: ", nrow(final.dataframe),
        " | abbreviations expanded: ", sum(final.dataframe$Species %in% abbrev_fixes),
        " | NA cells: ", sum(is.na(final.dataframe)))
