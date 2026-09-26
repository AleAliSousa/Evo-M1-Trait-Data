## =============================================================================
## de Sousa (2008) dissertation Suppl. Table 5.2 snapshot --> usable CSV/TSV
## "Comparison of adjusted values to published data of Semendeferi et al.
##  (1998, 2002)" (printed p. 198)
## UMI:3311323
## =============================================================================
##
## Input
##   deSousa__2008_Suppl.Table5.2_snapshot.xlsx     (sheet "Suppl.Table5.2")
##   built by deSousa__2008_Suppl.Table5.2_extract_snapshot.R from the PDF text layer
##
## Output
##   deSousa__2008_Suppl.Table5.2.csv               one row per specimen (6)
##   plus DOI/UMI-coded TSV in __Public/comparative-data/ when run inside the
##   full Evo-M1-Trait-Data repository.
##
## Data role: SECONDARY. The table is a two-block comparison and NEITHER block
## is new measurement:
##   * semendeferi_* columns are Semendeferi et al. (1998, 2002) as published --
##     they belong to Semendeferi_etal_1998 / _2002, not to de Sousa;
##   * current_* columns are the dissertation's own re-adjustment of those same
##     specimens to its fresh-weight correction-factor convention.
## The two blocks must never be pooled or averaged. Built for provenance; not
## added to any merge.
##
## Units: brain volume is printed in cm3 and converted to mm3 here; area 13 and
## area 10 are printed in mm3 and are left unconverted. Correction factors are
## dimensionless.
##
## Printed footnotes carried into the data as notes:
##   *  the brain volume differs because Semendeferi calculated it from the
##      fixed weight (1200 g), whereas the dissertation used the fresh weight
##      (1349 g)   -- applies to the human row hs20
##   ** the fresh weight for this specimen is 440 g   -- applies to ouy
## The printed asterisks are not attached to individual cells in the PDF text
## layer, so they are recorded per row in `footnote` rather than invented into
## cell strings.
## =============================================================================

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})

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
item_name <- tools::file_path_sans_ext(basename(.sp))    # deSousa__2008_Suppl.Table5.2
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
study <- basename(folder)
setwd(folder)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Suppl.Table5.2"
output_file    <- paste0(item_name, ".csv")
if (!file.exists(snapshot_file)) stop("Snapshot file not found: ", snapshot_file, call. = FALSE)

num <- function(x) parse_number(as.character(x), na = c("", "NA", "NaN", "-", "\u2013", "\u2014"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", .name_repair = "minimal")
names(raw) <- paste0("X", seq_len(ncol(raw)))
raw <- raw %>% mutate(across(everything(), ~ str_squish(as.character(.x))))

## the second header tier carries the repeated "CF" labels; data starts after it
header_row <- which(raw$X4 == "CF" & raw$X8 == "CF")[1]
if (is.na(header_row)) stop("Could not find the Suppl. Table 5.2 header tier in ", snapshot_file, call. = FALSE)

dat0 <- raw[seq(header_row + 1L, nrow(raw)), ] %>%
  filter(!is.na(X1), !is.na(X2)) %>%
  transmute(
    species_as_published          = X1,      # printed common name
    code                          = X2,      # dissertation specimen code
    archive_code_as_published     = X3,      # archive label printed by Semendeferi
    semendeferi_correction_factor = num(X4),
    semendeferi_brain_volume_cm3  = num(X5),
    semendeferi_area_13_volume_mm3 = num(X6),
    semendeferi_area_10_volume_mm3 = num(X7),
    current_correction_factor     = num(X8),
    current_brain_volume_cm3      = num(X9),
    current_area_13_volume_mm3    = num(X10),
    current_area_10_volume_mm3    = num(X11)
  )

## ---- species harmonisation via the collection key ----------------------------
## The table prints common names only ("human", "chimp", ...); those printed
## variants are registered in _keys/Stephan/species_key.csv under deSousa2008.
key_file <- if (!is.na(base)) file.path(base, "_keys", "Stephan", "species_key.csv") else NA_character_
if (is.na(key_file) || !file.exists(key_file))
  stop("Species key not found: _keys/Stephan/species_key.csv", call. = FALSE)
key <- read_csv(key_file, show_col_types = FALSE) %>% filter(source_publication == "deSousa2008")
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
missing_variants <- setdiff(tolower(dat0$species_as_published), names(lk))
if (length(missing_variants))
  stop("Species missing from species_key.csv (token deSousa2008): ",
       paste(missing_variants, collapse = ", "), call. = FALSE)

final.dataframe <- dat0 %>%
  mutate(
    species = unname(lk[tolower(species_as_published)]),
    ## project units: brain volume cm3 -> mm3; area 13 / area 10 already mm3
    semendeferi_brain_volume_mm3 = semendeferi_brain_volume_cm3 * 1000,
    current_brain_volume_mm3     = current_brain_volume_cm3     * 1000,
    footnote = case_when(
      code == "hs20" ~ "* brain volume differs because Semendeferi calculated it from the fixed weight (1200g), whereas the dissertation used the fresh weight (1349g)",
      code == "ouy"  ~ "** the fresh weight for this specimen is 440g",
      TRUE           ~ NA_character_),
    source = study
  ) %>%
  ## round away any binary floating-point noise from the cm3 -> mm3 conversion;
  ## printed precision is at most one decimal.
  mutate(across(where(is.numeric), ~ round(.x, 2))) %>%
  select(species, species_as_published, code, archive_code_as_published,
         semendeferi_correction_factor, semendeferi_brain_volume_mm3,
         semendeferi_area_13_volume_mm3, semendeferi_area_10_volume_mm3,
         current_correction_factor, current_brain_volume_mm3,
         current_area_13_volume_mm3, current_area_10_volume_mm3,
         footnote, source)

## ---- validation --------------------------------------------------------------
if (nrow(final.dataframe) != 6L)
  stop("Expected 6 specimen rows, parsed ", nrow(final.dataframe), ".", call. = FALSE)
if (!identical(final.dataframe$code[1], "hs20") ||
    !identical(final.dataframe$code[6], "hly"))
  stop("Printed row order not preserved (expected hs20 first, hly last).", call. = FALSE)
if (!isTRUE(all.equal(final.dataframe$semendeferi_area_10_volume_mm3[1], 14217.7)))
  stop("First row Semendeferi area 10 does not match the printed 14217.7 mm3.", call. = FALSE)
if (!isTRUE(all.equal(final.dataframe$current_brain_volume_mm3[1], 1302100)))
  stop("First row current brain volume does not match the printed 1302.1 cm3.", call. = FALSE)
num_cols <- grep("_(factor|mm3)$", names(final.dataframe), value = TRUE)
bad <- num_cols[!vapply(final.dataframe[num_cols], is.numeric, logical(1))]
if (length(bad)) stop("These columns are not numeric: ", paste(bad, collapse = ", "), call. = FALSE)
if (any(is.na(final.dataframe[num_cols])))
  stop("Suppl. Table 5.2 prints a complete grid; an NA means the extraction dropped a cell.", call. = FALSE)

options(scipen = 999)

write_csv(final.dataframe, output_file, na = "")
message("Wrote ", file.path(folder, output_file), "  (", nrow(final.dataframe), " rows)")

if (is.na(base) || !file.exists(file.path(base, "__ReadMe.xlsx"))) {
  warning("No repository root with __ReadMe.xlsx found; TSV skipped.")
} else {
  tsv_dir   <- file.path(base, "__Public/comparative-data")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped. ",
            "Paste deSousa__2008_Suppl.Table5.2_registry_row.xlsx into Sheet1 and re-run _tools/file_list.R first.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    write_tsv(final.dataframe, file.path(tsv_dir, paste0(enc, ".tsv")), na = "")
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
