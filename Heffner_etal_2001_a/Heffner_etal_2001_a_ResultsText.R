## Heffner_etal_2001_a_ResultsText.R -- frozen snapshot -> analysis CSV (+ public TSV once registered)
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2001). Sound localization in a new-world
## frugivorous bat, Artibeus jamaicensis: Acuity, use of binaural cues, and relationship to
## vision. Journal of the Acoustical Society of America, 109(1), 412-421.
## doi:10.1121/1.1329620
##
## RESULTS TEXT: the quantities this paper states in prose rather than in a table (the article
## has no numbered tables). Two kinds of row, kept apart by `role`:
##   primary   -- the study's own measurements on Artibeus jamaicensis: per-animal and mean
##                sound-localization thresholds, the width of the field of best vision, peak
##                retinal ganglion-cell density, the acuity calculated from it, the flattened
##                retina diameter, and the upper frequency limit for binaural phase-cue use.
##   secondary -- values the paper quotes for two other bats (big brown bat, Egyptian fruit bat)
##                from R. Heffner, Koay & Heffner (1999) and Koay et al. (1998b). These are
##                quoted comparisons, not measurements made here -- never merge them as primary.
##
## This paper is the source cited by Heffner & Heffner (2016) Figure 5 ("Modified from Heffner
## et al., 2001") and its own FIG. 6 is the primary version of that relationship; see
## Heffner_etal_2001_a_Figure6 for the 24-species roster.
##
## Frozen source: Heffner_etal_2001_a_ResultsText_snapshot.csv -- a CONSTRUCTED snapshot
## (snapshot HOWTO: values described only in prose go in a clearly named constructed source).
## Each row carries the quoted sentence verbatim plus its printed location. Every quote was
## read from the PDF text layer and verified character-by-character against 200-dpi renders of
## printed pp. 412, 416 and 418 (AI assistant, 2026-10-29), because this PDF's text layer
## mis-maps parentheses, "=" and "<" ("~" for "(", "!" for ")", "5" for "=", "," for "<").
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2001_a_ResultsText"
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

## 2. LOAD (frozen constructed snapshot) ----------------------------
snap <- utils::read.csv(snapshot_csv, stringsAsFactors = FALSE, colClasses = "character",
                        encoding = "UTF-8", check.names = FALSE)
stopifnot(identical(names(snap),
                    c("measurement_id", "common_name_as_printed", "binomial_as_printed",
                      "binomial_location", "measurement", "value_as_printed", "unit", "role",
                      "quoted_text_verbatim", "source_location")))

## 2b. SPECIES (shared resolver; the printed binomials all resolve through existing spokes,
## so this paper adds no rows of its own to _keys/General/species_key.csv)
source(file.path(base, "_keys", "resolve_species.R"), local = TRUE)
res <- resolve_species(snap$binomial_as_printed, source_publication = basename(folder))
if (any(res$unresolved))
  stop("Printed binomial(s) not resolvable: ",
       paste(unique(snap$binomial_as_printed[res$unresolved]), collapse = "; "), call. = FALSE)

## 3. CLEAN -----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(trimws(x)))

final.dataframe <- tibble::tibble(
  measurement_id         = snap$measurement_id,
  species_as_published   = snap$binomial_as_printed,
  common_name_as_printed = snap$common_name_as_printed,
  Species                = res$accepted_name,
  species_basis          = res$species_basis,
  measurement            = snap$measurement,
  value_as_printed       = snap$value_as_printed,
  value                  = num(snap$value_as_printed),
  unit                   = snap$unit,
  data_role              = snap$role,
  quoted_text_verbatim   = snap$quoted_text_verbatim,
  source_location        = snap$source_location,
  source_row             = seq_len(nrow(snap)) + 1L)

stopifnot(nrow(final.dataframe) == 14L,
          !any(is.na(final.dataframe$value)),
          all(final.dataframe$data_role %in% c("primary", "secondary")),
          sum(final.dataframe$data_role == "primary")   == 10L,
          sum(final.dataframe$data_role == "secondary") == 4L,
          ## every quoted value must appear in the sentence it was taken from
          all(mapply(grepl, final.dataframe$value_as_printed,
                     final.dataframe$quoted_text_verbatim, MoreArgs = list(fixed = TRUE))))

## 3b. TABLE CHECKS (HOWTO 7a) ----------------------------------------
## The prose states both the three per-animal thresholds and their mean, so the mean can be
## checked against the values it was computed from.
## Restricted to this study's own species: "Sound_localization_threshold_mean" is also the
## measurement name of the two quoted comparison bats, which are not part of this mean.
own  <- final.dataframe$Species == "Artibeus jamaicensis"
ind  <- final.dataframe$value[own & final.dataframe$measurement %in%
          paste0("Sound_localization_threshold_animal_", c("A", "B", "C"))]
mean_printed <- final.dataframe$value[own &
          final.dataframe$measurement == "Sound_localization_threshold_mean"]
stopifnot(length(ind) == 3L, length(mean_printed) == 1L)
table_checks <- data.frame(
  check_id   = "mean_threshold_vs_per_animal",
  basis      = "mean of the printed per-animal thresholds (9.5, 9, 11.5 deg) vs the printed mean",
  observed   = mean(ind),
  printed    = mean_printed,
  difference = mean(ind) - mean_printed,
  ## the per-animal values are printed to the nearest 0.5 deg (stated in the sentence), so the
  ## mean of three such values can differ from a printed whole-degree mean by up to 1/6 deg
  tolerance  = 0.5 / 3,
  stringsAsFactors = FALSE)
table_checks$status <- ifelse(abs(table_checks$difference) <= table_checks$tolerance + 1e-9,
                              "pass", "mismatch")
table_checks$note <- "per-animal thresholds printed to the nearest 0.5 deg; values kept as printed"
if (any(table_checks$status != "pass"))
  warning("Table check mismatch: ", table_checks$check_id, call. = FALSE)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, final_csv, na = "")
## The registry row for this paper did not exist when the item was first built: the TSV step is
## therefore PREPARED, not failed. It writes itself as soon as the owner pastes the row (set
## `sequence` = "a" so the Item-name formula yields Heffner_etal_2001_a_*) and re-runs this script.
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  hit          <- match(item_name, filecodes$`Item name`)
  item_encoded <- if (is.na(hit)) NA_character_ else filecodes$`Item encoded`[hit]
  if (is.na(hit)) {
    warning("No registry row for ", item_name,
            " yet -- public TSV pending the owner's registry paste (Progress stage: PREPARED).",
            call. = FALSE)
  } else if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
    stop("Registry row for ", item_name, " has no usable 'Item encoded' -- refusing to write NA.tsv.",
         call. = FALSE)
  } else {
    readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
  }
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
