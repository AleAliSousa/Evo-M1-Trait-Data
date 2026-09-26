## =============================================================================
## de Sousa (2008) dissertation Table 5.6 snapshot --> usable CSV/TSV data
## "Species mean volumes of cortical areas and brain nuclei" (printed p. 195)
## UMI:3311323
## =============================================================================
##
## Input
##   deSousa__2008_Table5.6_snapshot.xlsx        (sheet "Table5.6")
##   built by deSousa__2008_Table5.6_extract_snapshot.R from the PDF text layer
##
## Output
##   deSousa__2008_Table5.6.csv                  one row per species (6)
##   plus DOI/UMI-coded TSV in __Public/comparative-data/ when run inside the
##   full Evo-M1-Trait-Data repository.
##
## Data role: SECONDARY (compilation). Printed footnote a: "The data are derived
## from previous studies which have included hominoid brain specimens from the
## Zilles collection." Per-structure attribution is recorded in the README; the
## item is built for provenance and is NOT added to any merge. Re-ingesting it
## would double-count Sherwood, Semendeferi, Barger and Frahm values that the
## repo already carries (or will carry) from their own primary tables.
##
## Units: printed footnote b states "All volumes are in mm3", so the printed
## values are already in project units and NO conversion is applied here.
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
item_name <- tools::file_path_sans_ext(basename(.sp))    # deSousa__2008_Table5.6
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
study <- basename(folder)
setwd(folder)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Table5.6"
output_file    <- paste0(item_name, ".csv")
if (!file.exists(snapshot_file)) stop("Snapshot file not found: ", snapshot_file, call. = FALSE)

num <- function(x) parse_number(as.character(x), na = c("", "NA", "NaN", "-", "\u2013", "\u2014"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", .name_repair = "minimal")
names(raw) <- paste0("X", seq_len(ncol(raw)))
raw <- raw %>% mutate(across(everything(), ~ str_squish(as.character(.x))))

header_row <- which(str_to_lower(raw$X1) == "species")[1]
if (is.na(header_row)) stop("Could not find the Table 5.6 header row in ", snapshot_file, call. = FALSE)

dat0 <- raw[seq(header_row + 1L, nrow(raw)), ] %>%
  filter(!is.na(X1), str_detect(X1, "^[A-Z][a-z]+ [a-z]+$")) %>%
  transmute(
    species_as_published                = X1,
    brain_volume_mm3                    = num(X2),
    Vmo_volume_mm3                      = num(X3),
    VII_volume_mm3                      = num(X4),
    XII_volume_mm3                      = num(X5),
    area_13_volume_mm3                  = num(X6),
    area_10_volume_mm3                  = num(X7),
    amygdala_lateral_volume_mm3         = num(X8),
    amygdala_basal_volume_mm3           = num(X9),
    amygdala_accessory_basal_volume_mm3 = num(X10),
    area_44_volume_mm3                  = num(X11),
    area_45_volume_mm3                  = num(X12)
  )

## ---- species harmonisation via the collection key ----------------------------
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
  mutate(species = unname(lk[tolower(species_as_published)]), source = study) %>%
  ## printed precision is two decimals throughout; round away binary
  ## floating-point noise introduced by parsing (25.90 -> 25.900000000000002).
  mutate(across(where(is.numeric), ~ round(.x, 2))) %>%
  select(species, species_as_published, brain_volume_mm3, Vmo_volume_mm3, VII_volume_mm3,
         XII_volume_mm3, area_13_volume_mm3, area_10_volume_mm3,
         amygdala_lateral_volume_mm3, amygdala_basal_volume_mm3,
         amygdala_accessory_basal_volume_mm3, area_44_volume_mm3, area_45_volume_mm3,
         source)

## ---- validation --------------------------------------------------------------
if (nrow(final.dataframe) != 6L)
  stop("Expected 6 species rows, parsed ", nrow(final.dataframe), ".", call. = FALSE)
if (!identical(final.dataframe$species_as_published[1], "Homo sapiens") ||
    !identical(final.dataframe$species_as_published[6], "Hylobates lar"))
  stop("Printed row order not preserved (expected Homo sapiens first, Hylobates lar last).", call. = FALSE)
if (!isTRUE(all.equal(final.dataframe$brain_volume_mm3[1], 1264586.01)))
  stop("First row brain volume does not match the printed 1264586.01 mm3.", call. = FALSE)
num_cols <- setdiff(names(final.dataframe), c("species", "species_as_published", "source"))
bad <- num_cols[!vapply(final.dataframe[num_cols], is.numeric, logical(1))]
if (length(bad)) stop("These columns are not numeric: ", paste(bad, collapse = ", "), call. = FALSE)
if (any(is.na(final.dataframe[num_cols])))
  stop("Table 5.6 prints a complete 6 x 11 grid; an NA means the extraction dropped a cell.", call. = FALSE)

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
            "Paste deSousa__2008_Table5.6_registry_row.xlsx into Sheet1 and re-run _tools/file_list.R first.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    write_tsv(final.dataframe, file.path(tsv_dir, paste0(enc, ".tsv")), na = "")
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
