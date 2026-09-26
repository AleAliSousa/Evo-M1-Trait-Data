## =============================================================================
## de Sousa (2008) dissertation Table 5.1 snapshot --> usable CSV/TSV data
## Hominoid brain organization: histometric and morphometric comparisons of
## visual brain structures [Ph.D., The George Washington University]
## UMI:3311323
## =============================================================================
##
## Input
##   deSousa__2008_Table5.1_snapshot.xlsx        (sheet "Table5.1")
##   built by deSousa__2008_Table5.1_extract_snapshot.R from the PDF text layer
##
## Output
##   deSousa__2008_Table5.1.csv                  one row per specimen (29)
##   plus DOI/UMI-coded TSV in __Public/comparative-data/ when run inside the
##   full Evo-M1-Trait-Data repository.
##
## Data role: SECONDARY for merge purposes. These are the same 29 specimens and
## the same V1 / LGN / brain / neocortex measurements later published as
## deSousa_etal_2010_Table1, which is the item already carried in
## __merging_volumes (Tier 2). This item is built for provenance -- it is the
## public, citable origin of the dissertation specimen codes used throughout
## _keys/specimen_crosswalk -- and is deliberately NOT added to any merge.
##
## Provenance is split by measure and is NOT uniform across the table:
##   * left V1 and left LGN are de Sousa's own measurements;
##   * neocortex volumes were supplied by Carol MacLeod (unpublished);
##   * brain mass / correction factor follow the Zilles-collection convention.
## See deSousa__2008_Table5.1.README.md and
## _keys/specimen_crosswalk/via_data_source_registry.csv (PUB_DESOUSA_DISSERTATION_2008).
##
## Notes
##   - Volumes are printed in cm3 and converted to project units (mm3) here;
##     body mass kg -> g, brain mass g -> mg. The snapshot keeps the printed units.
##   - left V1 and left LGN are LEFT hemisphere, printed UNDOUBLED. The "left_"
##     prefix is load-bearing: never average these against a bilateral volume.
##   - The siamang is printed "Syndactylus symphalangus" (genus/species
##     reversed); the accepted binomial is resolved through the species key.
## =============================================================================

## ---- setup -------------------------------------------------------------------
suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))    # deSousa__2008_Table5.1
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
study <- basename(folder)                                # deSousa__2008
setwd(folder)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Table5.1"
output_file    <- paste0(item_name, ".csv")
if (!file.exists(snapshot_file)) stop("Snapshot file not found: ", snapshot_file, call. = FALSE)

num <- function(x) {
  x <- as.character(x)
  x <- str_replace_all(x, "(?i)^\\s*NA\\s*$", NA_character_)
  parse_number(x, na = c("", "NA", "NaN", "-", "\u2013", "\u2014"))
}

## ---- read the frozen snapshot ------------------------------------------------
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", .name_repair = "minimal")
names(raw) <- paste0("X", seq_len(ncol(raw)))
raw <- raw %>% mutate(across(everything(), ~ str_squish(as.character(.x))))

header_row <- which(str_to_lower(raw$X1) == "species" & str_to_lower(raw$X2) == "code")[1]
if (is.na(header_row)) stop("Could not find the Table 5.1 header row in ", snapshot_file, call. = FALSE)

dat0 <- raw[seq(header_row + 1L, nrow(raw)), ] %>%
  filter(!is.na(X1), !is.na(X2), str_detect(X1, "^[A-Z][a-z]+ [a-z]+$")) %>%
  transmute(
    species_as_published = X1,
    code                 = X2,
    sex_as_published     = X3,
    age_as_published     = X4,
    collection           = X5,
    plane_of_section     = X6,
    body_mass_kg         = num(X7),
    brain_mass_g         = num(X8),
    correction_factor    = num(X9),
    brain_volume_cm3     = num(X10),
    left_V1_volume_cm3   = num(X11),
    left_LGN_volume_cm3  = num(X12),
    neocortex_volume_cm3 = num(X13)
  )

## ---- species harmonisation via the collection key ----------------------------
## House rule: no inline name fixes. The printed "Syndactylus symphalangus"
## (and every other printed variant) resolves through _keys/Stephan/species_key.csv
## under the token deSousa2008; the printed name is kept in species_as_published.
key_file <- if (!is.na(base)) file.path(base, "_keys", "Stephan", "species_key.csv") else NA_character_
if (is.na(key_file) || !file.exists(key_file)) {
  stop("Species key not found: _keys/Stephan/species_key.csv", call. = FALSE)
}
key <- read_csv(key_file, show_col_types = FALSE) %>% filter(source_publication == "deSousa2008")
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
missing_variants <- setdiff(tolower(dat0$species_as_published), names(lk))
if (length(missing_variants)) {
  stop("Species missing from species_key.csv (token deSousa2008): ",
       paste(missing_variants, collapse = ", "), call. = FALSE)
}

## ---- clean, convert to project units, assemble -------------------------------
final.dataframe <- dat0 %>%
  mutate(
    species = unname(lk[tolower(species_as_published)]),
    ## printed ages are a mix of years, "A" (adult), "JUV" and "6 or 7";
    ## the printed string is authoritative, the numeric column is best-effort.
    age_yrs = suppressWarnings(as.numeric(str_extract(age_as_published, "^\\d+\\.?\\d*$"))),
    sex     = na_if(sex_as_published, "NA"),
    ## project units: volume mm3 (cm3 x 1000), body g (kg x 1000), brain mg (g x 1000)
    body_mass_g          = body_mass_kg * 1000,
    brain_mass_mg        = brain_mass_g * 1000,
    brain_volume_mm3     = brain_volume_cm3     * 1000,
    left_V1_volume_mm3   = left_V1_volume_cm3   * 1000,
    left_LGN_volume_mm3  = left_LGN_volume_cm3  * 1000,
    neocortex_volume_mm3 = neocortex_volume_cm3 * 1000,
    source = study
  ) %>%
  ## the x1000 unit conversions introduce binary floating-point noise
  ## (264.99 cm3 -> 264989.99999999994); the printed values carry at most two
  ## decimals, so round back to printed precision.
  mutate(across(where(is.numeric), ~ round(.x, 2))) %>%
  select(species, species_as_published, code, sex, age_as_published, age_yrs,
         collection, plane_of_section, body_mass_g, brain_mass_mg, correction_factor,
         brain_volume_mm3, left_V1_volume_mm3, left_LGN_volume_mm3,
         neocortex_volume_mm3, source)

## ---- validation --------------------------------------------------------------
if (nrow(final.dataframe) != 29L)
  stop("Expected 29 specimen rows, parsed ", nrow(final.dataframe), ".", call. = FALSE)
if (length(unique(final.dataframe$code)) != 29L)
  stop("Specimen codes are not unique.", call. = FALSE)
## printed row order: the table opens on hs14 and closes on mf2
if (!identical(final.dataframe$code[1], "hs14") ||
    !identical(final.dataframe$code[nrow(final.dataframe)], "mf2"))
  stop("Printed row order not preserved (expected hs14 first, mf2 last).", call. = FALSE)
if (!isTRUE(all.equal(final.dataframe$brain_volume_mm3[1], 1387070)))
  stop("First row brain volume does not match the printed 1387.07 cm3.", call. = FALSE)
if (any(final.dataframe$species_as_published == "Syndactylus symphalangus" &
        final.dataframe$species != "Symphalangus syndactylus"))
  stop("Siamang name did not resolve through the species key.", call. = FALSE)
num_cols <- c("body_mass_g", "brain_mass_mg", "correction_factor", "brain_volume_mm3",
              "left_V1_volume_mm3", "left_LGN_volume_mm3", "neocortex_volume_mm3")
bad <- num_cols[!vapply(final.dataframe[num_cols], is.numeric, logical(1))]
if (length(bad)) stop("These columns are not numeric: ", paste(bad, collapse = ", "), call. = FALSE)

options(scipen = 999)

## ---- write csv ---------------------------------------------------------------
write_csv(final.dataframe, output_file, na = "")
message("Wrote ", file.path(folder, output_file), "  (", nrow(final.dataframe), " rows)")

## ---- also write the DOI/UMI-coded TSV to __Public/comparative-data/ ----------
if (is.na(base) || !file.exists(file.path(base, "__ReadMe.xlsx"))) {
  warning("No repository root with __ReadMe.xlsx found; TSV skipped.")
} else {
  tsv_dir   <- file.path(base, "__Public/comparative-data")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped. ",
            "Paste deSousa__2008_Table5.1_registry_row.xlsx into Sheet1 and re-run _tools/file_list.R first.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    write_tsv(final.dataframe, file.path(tsv_dir, paste0(enc, ".tsv")), na = "")
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
