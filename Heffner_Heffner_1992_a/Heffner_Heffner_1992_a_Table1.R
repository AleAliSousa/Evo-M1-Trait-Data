## Heffner_Heffner_1992_a_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1992). Visual factors in sound localization
## in mammals. J Comp Neurol 317(3):219-232. doi:10.1002/cne.903170302
## ("1992a" in the Bath sensory compilation's short codes; the "_a" suffix
## distinguishes it from other Heffner & Heffner 1992 papers.)
##
## Source is a SCANNED PDF: its OCR text layer fuses the superscript footnote
## markers into the values (e.g. "1.1^2" reads as "1.12"), so the snapshot was
## hand-verified against the rendered page image (400 dpi) cell by cell, and
## independently agrees 77/77 with the Bath student extraction and 81/81 on
## values with the compiled sensory check fixture (see comparison/).
##
## Outputs verified 2026-08-31: this script, run in RStudio, reproduced the
## offline-built CSV and public TSV byte-for-byte (mirror since deleted).

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
item_name <- tools::file_path_sans_ext(basename(.sp))    # "Heffner_Heffner_1992_a_Table1"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
foot_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_footnotes.csv"))
xwalk_csv    <- file.path(folder, "reference_tables", paste0(item_name, "_species_crosswalk.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap  <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                  colClasses = "character", encoding = "UTF-8")
foot  <- read.csv(foot_csv,  stringsAsFactors = FALSE)
xwalk <- read.csv(xwalk_csv, stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 24)
footkey <- setNames(foot$text_as_printed, as.character(foot$footnote))

## 3. CLEAN ---------------------------------------------------------
## em-dash = missing (as printed); values otherwise numeric as printed
num <- function(x) suppressWarnings(as.numeric(ifelse(x %in% c("", "—", "-", "--"), NA, x)))
xk  <- xwalk[match(snap$Species, xwalk$species_as_published), ]

final.dataframe <- tibble(
  Species_HH1992a = snap$Species,                       # printed common name, verbatim (invariant 3)
  symbol          = snap$Symbol,
  binomial        = xk$binomial_assigned,               # interpretive: see crosswalk basis column
  binomial_basis  = xk$basis,
  sound_localization_threshold_deg = num(snap$`Sound localization threshold in deg`),
  threshold_footnote = snap$threshold_footnote,
  threshold_source   = unname(footkey[snap$threshold_footnote]),
  delta_t_us      = num(snap$`Delta t in usec`),
  field_of_best_vision_deg = num(snap$`Field of best vision in deg`),
  visual_acuity_cdeg = num(snap$`Visual acuity in c/deg`),
  acuity_footnote = snap$acuity_footnote,
  ## unfootnoted acuities are this paper's own ganglion-cell estimates (header footnote 23)
  acuity_source   = ifelse(nzchar(snap$acuity_footnote), unname(footkey[snap$acuity_footnote]),
                    ifelse(is.na(num(snap$`Visual acuity in c/deg`)), "", footkey["23"])),
  binocular_field_deg = num(snap$`Binocular field in deg`),
  trophic_level   = num(snap$`Trophic level`)
) %>% mutate(across(where(is.character), ~replace_na(., "")))

## 4. WRITE CSV + PUBLIC TSV ---------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")

## 5. COMPARISONS -- comparison/..._compare_to_SensoryData_compiled_csv.R ----
## comparison/ holds audits vs (a) ____Sensory_audiovisual/SensoryData_compiled_check
## (rows citing "Heffner and Heffner 1992a": 81 agree, 0 mismatches, 6 rows the
## compilation assigned to species NOT in Table 1 -- see README) and (b) the Bath
## student extraction sheet in hearing data.xlsx (77 agree, 0 mismatches).
