# Capellini et al. 2008 - mammalian sleep (sleep-data_Female / _Male / _Mixed)
# House pipeline: frozen source -> resolve species -> analysis CSV + DOI-coded public TSV.
#
# DIGITAL-NATIVE SOURCE (no derived snapshot; __HOWTO_build_a_dataset_file.md sec 0a invariant 1):
#   sleep-data_Female.csv / sleep-data_Male.csv / sleep-data_Mixed.csv are the untouched
#   downloads from the mammalian-sleep database cited by Capellini et al. (2008), pulled with
#   the search term Sex = Female / Male / Mixed (see __ReadMe.xlsx "Note about item").
#   They are the frozen copies - never edit them; all cleaning happens here.
#
# One row per STUDY RECORD (reference x species x sex class), not per species. Several
# references report the same species; aggregate to species means at the MERGE, not here
# (sec 3, "granularity"). Two records may also share a species across the three sex files.
#
# Source: Capellini, I., Barton, R. A., McNamara, P., Preston, B. T., & Nunn, C. L. (2008).
#   Phylogenetic analysis of the ecology and evolution of mammalian sleep: a reappraisal.
#   Evolution 62(7):1764-1776. DOI 10.1111/j.1558-5646.2008.00392.x

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
paper_dir <- dirname(.sp)
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)   # __ReadMe.xlsx Item-encoded lookup only

## 2. SPECIES RESOLVER (single source of truth = _keys) -------------
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
key_files <- if (!is.na(dataset_root))
  list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
             recursive = TRUE, full.names = TRUE) else character(0)
# Variant rows are keyed by (source_publication, variant_name) - _keys/SPECIES_NAMING.md sec 3.
# Scope to THIS paper's token so another paper's specimen-level decisions cannot leak in.
TOKEN <- "Capellini2008"
km <- list()
for (kf in key_files) {
  k <- read.csv(kf, stringsAsFactors = FALSE)
  if (!all(c("variant_name", "accepted_name") %in% names(k))) next
  if (!"source_publication" %in% names(k)) next
  k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
  for (i in seq_len(nrow(k))) {
    v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && is.null(km[[v]])) km[[v]] <- k$accepted_name[i]
  }
}
# The database prints species in Title Case ("Arctocephalus Pusillus"); normalise the
# epithet to lower case before matching, but NEVER overwrite the printed name (invariant 3).
clean_sp <- function(x) {
  x <- trimws(gsub("\\s+", " ", gsub("_", " ", as.character(x))))
  parts <- strsplit(x, " ", fixed = TRUE)[[1]]
  if (length(parts) >= 2) {
    parts[1] <- paste0(toupper(substring(parts[1], 1, 1)), tolower(substring(parts[1], 2)))
    parts[-1] <- tolower(parts[-1])
    x <- paste(parts, collapse = " ")
  }
  x
}
resolve <- function(x) {
  cx <- clean_sp(x)
  # one record prints "N/A" in the species column (common name "Calves") - genuinely
  # unidentified here, so it stays NA rather than becoming a fake species label.
  if (!nzchar(cx) || cx %in% c("N/a", "N/A")) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)   # species_key first (paper token)
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  cx
}

## 3. HELPERS ------------------------------------------------------
# Missing tokens used by this source: "" and "N/A". Strip thousands separators (sec 6).
to_num <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub(",", "", x, fixed = TRUE)
  x[x %in% c("", "-", "NA", "N/A", "n.a.")] <- NA
  suppressWarnings(as.numeric(x))
}
blank_na <- function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("N/A")] <- NA
  x
}

## 4. BUILD EACH SEX FILE ------------------------------------------
sexes <- c(Female = "sleep-data_Female", Male = "sleep-data_Male", Mixed = "sleep-data_Mixed")

for (sx in names(sexes)) {

  src       <- file.path(paper_dir, paste0(sexes[[sx]], ".csv"))
  item_name <- paste0("Capellini_etal_2008_sleep-data", sx)
  final_csv <- file.path(paper_dir, paste0(item_name, ".csv"))

  raw <- read.csv(src, check.names = FALSE, stringsAsFactors = FALSE,
                  colClasses = "character", encoding = "UTF-8")

  out <- data.frame(
    # ---- record identity ----
    search_id          = to_num(raw$search_id),
    sex_file           = sx,
    Sex_reported       = blank_na(raw$Sex),
    habitat_type       = blank_na(raw$type),                  # Land / Marine
    Reference          = trimws(raw$Reference),
    Full_Reference     = trimws(raw$Full_Reference),
    # ---- species (printed name preserved verbatim; invariant 3) ----
    SpeciesName_Reported = raw$SpeciesName_Reported,
    CommonName_Reported  = blank_na(raw$CommonName_Reported),
    species_sci          = vapply(raw$SpeciesName_Reported, resolve, character(1),
                                  USE.NAMES = FALSE),
    # ---- sleep measures, hours per day exactly as reported (no unit conversion) ----
    Sleep_h_day        = to_num(raw$Total_daily_sleep),
    Sleep_h_day_drowsy_adj = to_num(raw$Sleep_time_adjusted_for_drowsiness),
    REM_h              = to_num(raw$Daily_PS_time),           # PS = paradoxical = REM
    NREM_h             = to_num(raw$Quiet_sleep_time),        # quiet sleep = NREM / SWS
    Sleep_cycle_min    = to_num(raw$Sleep_cycle_length),
    # ---- derived (invariant 4: conversion shown) ----
    # REM_sleep_pct = 100 * REM hours / total sleep hours
    REM_sleep_pct      = 100 * to_num(raw$Daily_PS_time) / to_num(raw$Total_daily_sleep),
    # ---- marine-specific split (only a handful of records; Lyamin-style USWS traits) ----
    Sleep_h_day_in_water   = to_num(raw$Total_daily_sleep_time_in_water),
    Sleep_h_day_on_land    = to_num(raw$Total_daily_sleep_time_on_land),
    REM_h_in_water         = to_num(raw$Daily_PS_time_in_water),
    REM_h_on_land          = to_num(raw$Daily_PS_time_on_land),
    NREM_h_in_water        = to_num(raw$Quiet_sleep_time_in_water),
    NREM_h_on_land         = to_num(raw$Quiet_sleep_time_on_land),
    USWS                   = blank_na(raw$USWS),
    BSWS                   = blank_na(raw$BSWS),
    ASWS                   = blank_na(raw$ASWS),
    # ---- sample & method quality ----
    N_reported         = to_num(raw$N),
    N_in_mean          = to_num(raw$Number_of_animals_in_calculated_mean),
    Animals_sampled    = to_num(raw$Animals_sampled),
    EEG                = blank_na(raw$EEG),
    Telemetry          = blank_na(raw$Telemetry),
    Twenty_four_hour   = blank_na(raw$Twenty_four_hour),
    Light              = blank_na(raw$Light),
    Adaptation         = blank_na(raw$Adaptation),
    Diet_condition     = blank_na(raw$Diet),
    Temperature        = blank_na(raw$Temperature),
    Restraint          = blank_na(raw$Restraint),
    Behavioural        = blank_na(raw$Behavioural),
    Lab_condition_score = to_num(raw$Total_lab_condition_score),
    Summary_age_class  = blank_na(raw$Summary_age_class),
    Monophasic_polyphasic = blank_na(raw$Monophasic_polyphasic),
    # ---- flags carried from the source ----
    Error              = blank_na(raw$Error),
    Error_Note         = blank_na(raw$Error_Note),
    Notes_Misc         = blank_na(raw$Notes_Misc),
    Data_came_from     = blank_na(raw$Data_came_from),
    Post1988           = blank_na(raw$Post1988),
    stringsAsFactors   = FALSE
  )

  ## 5. SAVE -------------------------------------------------------
  options(scipen = 999)
  write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

  if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
    filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
    item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
    if (is.na(item_encoded)) {
      warning("No 'Item encoded' in __ReadMe.xlsx for Item name: ", item_name)
    } else {
      dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
      write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                  sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
    }
  }
  cat(sprintf("Capellini %s: %d records, %d species\n",
              sx, nrow(out), length(unique(out$species_sci))))
}
