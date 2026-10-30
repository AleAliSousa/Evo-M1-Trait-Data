## =============================================================================
## de Sousa et al. (2010) Table 1 manual Excel snapshot --> usable CSV/TSV data
## Hominoid visual brain structure volumes and the position of the lunate sulcus
## DOI: 10.1016/j.jhevol.2009.11.011
## =============================================================================
##
## Input
##   deSousa_etal_2010_Table1_snapshot.xlsx
##
## Output
##   deSousa_etal_2010_Table1.csv
##   plus DOI/PMID-coded TSV in __Public/comparative-data/ if this script is run
##   inside the full Evo-M1-Trait-Data repository.
##
## Notes
##   - This version starts from the manually checked snapshot Excel file.
##   - It removes printed footnote markers from data cells and records their
##     information in analysis-friendly columns.
##   - Numeric measurement columns are converted to numeric values.
## =============================================================================

## ---- setup -------------------------------------------------------------------
suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(stringr)
  library(tibble)
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
item_name <- tools::file_path_sans_ext(basename(.sp))    # e.g. deSousa_etal_2010_Table1
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
study <- basename(folder)                                # e.g. deSousa_etal_2010

setwd(folder)
snapshot_file    <- paste0(item_name, "_snapshot.xlsx")
definitions_file <- paste0(item_name, "_definitions.csv")
output_file      <- paste0(item_name, ".csv")

if (!file.exists(snapshot_file)) {
  stop("Snapshot file not found: ", snapshot_file, call. = FALSE)
}
if (!file.exists(definitions_file)) {
  warning("Definitions file not found: ", definitions_file, "; using built-in output column order.")
}

## ---- helpers -----------------------------------------------------------------
# Lowercase footnote letters at the very end of a cell, e.g. "Homo sapiensb" or
# "2.05c". This intentionally does not touch normal species names such as
# "Macaca fascicularis".
extract_trailing_note <- function(x) {
  x <- as.character(x)
  note <- str_match(x, "([a-z])\\s*$")[, 2]
  note[is.na(x) | x %in% c("", "NA")] <- NA_character_
  note
}

remove_trailing_note <- function(x) {
  x <- as.character(x)
  x <- str_replace(x, "([0-9.])([a-z])\\s*$", "\\1")
  x <- str_replace(x, "(sapiens)b\\s*$", "\\1")
  str_squish(x)
}

num_from_cell <- function(x) {
  x <- as.character(x)
  x <- str_replace_all(x, "\\u00A0", " ")
  x <- str_replace_all(x, "(?i)^\\s*NA\\s*$", NA_character_)
  x <- remove_trailing_note(x)
  readr::parse_number(x, na = c("", "NA", "NaN"))
}

collapse_notes <- function(...) {
  pieces <- c(...)
  pieces <- pieces[!is.na(pieces) & nzchar(pieces)]
  if (length(pieces) == 0L) NA_character_ else paste(unique(pieces), collapse = "; ")
}

## ---- read manual snapshot ----------------------------------------------------
raw <- readxl::read_excel(
  snapshot_file,
  sheet = 1,
  col_names = FALSE,
  na = c("", "NA"),
  .name_repair = "minimal"
)

# Keep only the first 9 table columns; title, caption, blank rows, and footnotes
# are ignored below after the header/data block is detected.
if (ncol(raw) < 9L) {
  stop("The snapshot has fewer than 9 columns; cannot parse Table 1.", call. = FALSE)
}
raw <- raw[, 1:9]
names(raw) <- paste0("X", seq_len(ncol(raw)))
raw <- raw %>% mutate(across(everything(), ~ str_squish(as.character(.x))))
raw[raw == "NA"] <- NA_character_

header_row <- which(
  str_to_lower(raw$X1) == "species" &
    str_to_lower(raw$X2) == "code" &
    str_to_lower(raw$X3) == "collection"
)[1]
if (is.na(header_row)) {
  stop("Could not find the Table 1 header row in ", snapshot_file, call. = FALSE)
}

data_start <- header_row + 1L
# Data rows start after the header and end before the first blank/footnote row.
# A data row must have species, code, and collection.
data_rows <- seq(data_start, nrow(raw))
keep_data <- !is.na(raw$X1[data_rows]) & !is.na(raw$X2[data_rows]) & !is.na(raw$X3[data_rows])
if (!any(keep_data)) {
  stop("No data rows found after the Table 1 header row.", call. = FALSE)
}
last_data_row <- data_rows[max(which(keep_data))]

dat0 <- raw[data_start:last_data_row, ] %>%
  filter(!if_all(everything(), is.na)) %>%
  transmute(
    species_as_published        = X1,
    code                        = X2,
    collection                  = X3,
    brain_mass_g_raw            = X4,
    correction_factor_raw       = X5,
    brain_volume_cm3_raw        = X6,
    left_V1_volume_cm3_raw      = X7,
    left_LGN_volume_cm3_raw     = X8,
    neocortex_volume_cm3_raw    = X9
  )

## ---- clean and standardize ---------------------------------------------------
final.dataframe <- dat0 %>%
  mutate(
    ## The species footnote is a superscript in the PDF; the snapshot loses that
    ## typography, so the marker arrives glued to the epithet ("Homo sapiensb").
    ## Matched explicitly rather than with a generic trailing-letter rule, which
    ## would read the final "a" of "Gorilla gorilla" as a marker.
    species_note = if_else(str_detect(species_as_published, "sapiensb\\s*$"),
                           "b", NA_character_),
    cf_note      = extract_trailing_note(correction_factor_raw),

    ## "as published" means the name as printed WITHOUT its footnote marker: the
    ## superscript is typography, not part of the name. It is split off here and
    ## carried in footnote_ref, so the marker is never stored in both places.
    species_as_published = remove_trailing_note(species_as_published),
    footnote_ref = species_note,

    species = recode(species_as_published, "Symphalagus syndactylus" = "Symphalangus syndactylus"),

    brain_mass_g         = num_from_cell(brain_mass_g_raw),
    correction_factor    = num_from_cell(correction_factor_raw),
    brain_volume_cm3     = num_from_cell(brain_volume_cm3_raw),
    left_V1_volume_cm3   = num_from_cell(left_V1_volume_cm3_raw),
    left_LGN_volume_cm3  = num_from_cell(left_LGN_volume_cm3_raw),
    neocortex_volume_cm3 = num_from_cell(neocortex_volume_cm3_raw),

    cf_assumed = !is.na(cf_note) & cf_note == "c",
    source = study,

    correction = mapply(
      collapse_notes,
      if_else(!is.na(species_note) & species_note == "b", "footnote marker b split out of the species name into footnote_ref; Homo sapiens values differ slightly from Amunts et al. 2007a because of shrinkage-correction convention", NA_character_),
      if_else(cf_assumed, "removed footnote c from correction_factor; Pan troglodytes mean correction factor used because brain weight unknown", NA_character_),
      if_else(species_as_published == "Symphalagus syndactylus", "corrected published spelling Symphalagus to Symphalangus", NA_character_),
      SIMPLIFY = TRUE,
      USE.NAMES = FALSE
    )
  ) %>%
  select(
    species,
    species_as_published,
    footnote_ref,
    code,
    collection,
    brain_mass_g,
    correction_factor,
    brain_volume_cm3,
    left_V1_volume_cm3,
    left_LGN_volume_cm3,
    neocortex_volume_cm3,
    cf_assumed,
    source,
    correction
  )

## ---- targeted data correction: Macaca fascicularis (ma22) left LGN -----------
## Table 1 printed the LEFT LGN as 0. That is a rounding-to-zero artifact: the true
## left value is <0.05 cm3, so at Table 1's one-decimal precision it reads as 0 (and
## looks like a missing/true zero). The paper's Supplementary Table 2 reports the
## BILATERAL LGN (0.092 cm3); left = bilateral / 2 (the same L*2 convention seen for
## V1: left 1.4 = bilateral 2.7 / 2). So left LGN = 0.092 / 2 = 0.046 cm3.
.mac <- with(final.dataframe,
             species == "Macaca fascicularis" & code == "ma22" &
               (is.na(left_LGN_volume_cm3) | left_LGN_volume_cm3 == 0))
if (any(.mac)) {
  final.dataframe$left_LGN_volume_cm3[.mac] <- 0.046
  final.dataframe$correction[.mac] <- vapply(which(.mac), function(i)
    collapse_notes(final.dataframe$correction[i],
      "left LGN printed as 0 (rounds to zero at 1 dp); set to 0.046 cm3 = Supp. Table 2 bilateral LGN 0.092 / 2 (left = bilateral/2)"),
    character(1))
}

## ---- validation --------------------------------------------------------------
expected_cols <- c(
  "species", "species_as_published", "footnote_ref", "code", "collection",
  "brain_mass_g", "correction_factor", "brain_volume_cm3",
  "left_V1_volume_cm3", "left_LGN_volume_cm3", "neocortex_volume_cm3",
  "cf_assumed", "source", "correction"
)
if (!identical(names(final.dataframe), expected_cols)) {
  stop("Output columns are not in the expected order.", call. = FALSE)
}

## No footnote marker may survive in species_as_published: every cell must be a
## clean binomial. Guards against a snapshot re-extract silently regluing them.
if (!all(grepl("^[A-Z][a-z]+ [a-z]+$", final.dataframe$species_as_published))) {
  stop("Footnote marker left glued to species_as_published: ",
       paste(unique(final.dataframe$species_as_published[
         !grepl("^[A-Z][a-z]+ [a-z]+$", final.dataframe$species_as_published)]),
         collapse = ", "), call. = FALSE)
}
if (sum(!is.na(final.dataframe$footnote_ref)) != 10L) {
  stop("Expected 10 Homo sapiens rows carrying footnote_ref == 'b'.", call. = FALSE)
}

expected_n <- 29L
if (nrow(final.dataframe) != expected_n) {
  stop("Expected ", expected_n, " data rows, but parsed ", nrow(final.dataframe), ".", call. = FALSE)
}

if (!identical(final.dataframe$species[1], "Homo sapiens") ||
    !identical(final.dataframe$code[1], "14686") ||
    !identical(final.dataframe$collection[1], "Zilles") ||
    !isTRUE(all.equal(final.dataframe$brain_volume_cm3[1], 1387.1))) {
  stop("First parsed row does not match the expected first Table 1 row.", call. = FALSE)
}

if (!identical(final.dataframe$species[nrow(final.dataframe)], "Macaca fascicularis") ||
    !identical(final.dataframe$code[nrow(final.dataframe)], "ma22") ||
    !isTRUE(all.equal(final.dataframe$left_V1_volume_cm3[nrow(final.dataframe)], 1.4))) {
  stop("Last parsed row does not match the expected last Table 1 row.", call. = FALSE)
}

if (sum(final.dataframe$cf_assumed, na.rm = TRUE) != 4L) {
  stop("Expected 4 rows with correction factor footnote c / cf_assumed == TRUE.", call. = FALSE)
}

numeric_cols <- c(
  "brain_mass_g", "correction_factor", "brain_volume_cm3",
  "left_V1_volume_cm3", "left_LGN_volume_cm3", "neocortex_volume_cm3"
)
non_numeric <- numeric_cols[!vapply(final.dataframe[numeric_cols], is.numeric, logical(1))]
if (length(non_numeric) > 0L) {
  stop("These columns are not numeric: ", paste(non_numeric, collapse = ", "), call. = FALSE)
}

## ---- write csv ---------------------------------------------------------------
readr::write_csv(final.dataframe, output_file, na = "")
message("Wrote ", file.path(folder, output_file))

## ---- also write the DOI/PMID-coded TSV to __Public/comparative-data/ ---------
if (is.na(base) || !file.exists(file.path(base, "__ReadMe.xlsx"))) {
  warning("No repository root with __ReadMe.xlsx found; TSV skipped.")
} else {
  tsv_dir <- file.path(base, "__Public/comparative-data")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(enc, ".tsv")), na = "")
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
