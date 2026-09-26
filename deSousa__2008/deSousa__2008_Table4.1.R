## =============================================================================
## de Sousa (2008) dissertation Table 4.1 snapshot --> usable CSV/TSV data
## "Samples used in analyses of V1, V2, VP and V5" (printed p. 120)
## UMI:3311323
## =============================================================================
##
## Input
##   deSousa__2008_Table4.1_snapshot.xlsx        (sheet "Table4.1")
##   built by deSousa__2008_Table4.1_extract_snapshot.R from the PDF text layer
##
## Output
##   deSousa__2008_Table4.1.csv                  one row per specimen (9)
##   plus DOI/UMI-coded TSV in __Public/comparative-data/
##
## Data role: SECONDARY. This is the dissertation version of the sample table
## published as deSousa_etal_2009_Table1, and that published item is itself
## SECONDARY (every macroanatomical column is re-used data). Built for
## provenance; NOT added to any merge.
##
## Why it is still worth having, beyond deSousa_etal_2009_Table1:
##   * it prints the UNROUNDED values the journal table rounds -- body mass
##     84.70 vs 85 kg, 6.80 vs 7, 62.53 vs 63, 2.90 vs 3; neocortex 254.31 vs
##     254 cm3; left V1 4043.62 vs 4044 mm3; left LGN 150.06 vs 150 mm3;
##   * its nine specimens are a subset of dissertation Table 5.1, which ties the
##     2009 paper's archive numbers to the dissertation specimen codes;
##   * the dissertation analysed V5 as well as V1/V2/VP (the published title
##     drops V5).
##
## Provenance by column (printed footnotes, carried in the definitions):
##   neocortex for hs5/hs6 = combined-sex human mean (n=8) supplied by Carol
##   MacLeod (b); body mass for Homo = Zilles 1972 (a); for Pan paniscus =
##   Jungers and Susman 1984 (c); ptd brain and body mass = Herndon et al. 1999
##   (d); EQ is derived after Martin 1981 / Ruff et al. 1997 (e); optic nerve
##   cross-sectional area and eye half surface area are Stephan and Frahm 1981
##   species means (f).
##
## Units: neocortex cm3 -> mm3; body mass kg -> g; brain mass g -> mg. Left V1
## and left LGN are printed in mm3 and are left unconverted; the two areas stay
## in mm2. Left V1 / left LGN are LEFT hemisphere, printed UNDOUBLED.
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
item_name <- tools::file_path_sans_ext(basename(.sp))    # deSousa__2008_Table4.1
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
study <- basename(folder)
setwd(folder)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Table4.1"
output_file    <- paste0(item_name, ".csv")
if (!file.exists(snapshot_file)) stop("Snapshot file not found: ", snapshot_file, call. = FALSE)

num <- function(x) {
  x <- as.character(x)
  x <- str_replace_all(x, "(?i)^\\s*NA\\s*$", NA_character_)
  parse_number(x, na = c("", "NA", "NaN", "-", "\u2013", "\u2014"))
}

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", .name_repair = "minimal")
names(raw) <- paste0("X", seq_len(ncol(raw)))
raw <- raw %>% mutate(across(everything(), ~ str_squish(as.character(.x))))

header_row <- which(str_to_lower(raw$X1) == "species" & str_to_lower(raw$X2) == "code")[1]
if (is.na(header_row)) stop("Could not find the Table 4.1 header row in ", snapshot_file, call. = FALSE)

dat0 <- raw[seq(header_row + 1L, nrow(raw)), ] %>%
  filter(!is.na(X1), !is.na(X2), str_detect(X1, "^[A-Z][a-z]+ [a-z]")) %>%
  transmute(
    species_printed       = X1,
    code                  = X2,
    archive_number        = X3,
    sex_as_published      = X4,
    age_yrs               = num(X5),
    body_mass_kg          = num(X6),
    brain_mass_g          = num(X7),
    EQ                    = num(X8),
    neocortex_volume_cm3  = num(X9),
    left_V1_volume_mm3    = num(X10),
    left_LGN_volume_mm3   = num(X11),
    optic_nerve_csa_mm2 = num(X12),
    eye_half_surface_area_mm2            = num(X13)
  )

## ---- split the printed footnote superscripts off the species name ------------
## The markers are glued to the epithet in the snapshot ("Homo sapiensa,b"),
## exactly as the page prints them. Stripping by a generic trailing-letter rule
## would eat the final "a" of "Gorilla gorilla", so a suffix is removed ONLY when
## the remainder is a name the species key already knows.
key_file <- if (!is.na(base)) file.path(base, "_keys", "Stephan", "species_key.csv") else NA_character_
if (is.na(key_file) || !file.exists(key_file))
  stop("Species key not found: _keys/Stephan/species_key.csv", call. = FALSE)
key <- read_csv(key_file, show_col_types = FALSE) %>% filter(source_publication == "deSousa2008")
lk  <- setNames(key$accepted_name, tolower(key$variant_name))

markers <- c("a,b", "a,c", "a,d", "a", "b", "c", "d", "e", "f")
split_marker <- function(x) {
  if (tolower(x) %in% names(lk)) return(c(x, NA_character_))
  for (m in markers) {
    if (endsWith(x, m)) {
      stem <- substr(x, 1, nchar(x) - nchar(m))
      if (tolower(stem) %in% names(lk)) return(c(stem, m))
    }
  }
  c(x, NA_character_)
}
sp <- t(vapply(dat0$species_printed, split_marker, character(2), USE.NAMES = FALSE))

final.dataframe <- dat0 %>%
  mutate(
    species_as_published = sp[, 1],
    footnote_ref         = sp[, 2],
    species              = unname(lk[tolower(species_as_published)]),
    sex                  = na_if(sex_as_published, "NA"),
    ## project units
    body_mass_g          = body_mass_kg * 1000,
    brain_mass_mg        = brain_mass_g * 1000,
    neocortex_volume_mm3 = neocortex_volume_cm3 * 1000,
    source               = study
  ) %>%
  mutate(across(where(is.numeric), ~ round(.x, 2))) %>%
  select(species, species_as_published, footnote_ref, code, archive_number, sex, age_yrs,
         body_mass_g, brain_mass_mg, EQ, neocortex_volume_mm3,
         left_V1_volume_mm3, left_LGN_volume_mm3,
         optic_nerve_csa_mm2, eye_half_surface_area_mm2, source)

## ---- validation --------------------------------------------------------------
if (nrow(final.dataframe) != 9L)
  stop("Expected 9 specimen rows, parsed ", nrow(final.dataframe), ".", call. = FALSE)
if (any(is.na(final.dataframe$species)))
  stop("Unresolved species: ",
       paste(unique(final.dataframe$species_as_published[is.na(final.dataframe$species)]),
             collapse = ", "), call. = FALSE)
if (!all(grepl("^[A-Z][a-z]+ [a-z]+$", final.dataframe$species_as_published)))
  stop("Footnote marker left glued to species_as_published: ",
       paste(unique(final.dataframe$species_as_published[
         !grepl("^[A-Z][a-z]+ [a-z]+$", final.dataframe$species_as_published)]),
         collapse = ", "), call. = FALSE)
## printed markers: two Homo rows carry "a,b", ppz carries "c", ptd carries "d"
if (!identical(sort(final.dataframe$footnote_ref[!is.na(final.dataframe$footnote_ref)]),
               c("a,b", "a,b", "c", "d")))
  stop("Footnote markers do not match the printed page (expected a,b x2 plus c and d).",
       call. = FALSE)
if (!identical(final.dataframe$code[1], "ggy") ||
    !identical(final.dataframe$code[9], "ptd"))
  stop("Printed row order not preserved (expected ggy first, ptd last).", call. = FALSE)
if (!isTRUE(all.equal(final.dataframe$left_V1_volume_mm3[1], 4043.62)))
  stop("First row left V1 does not match the printed 4043.62 mm3.", call. = FALSE)
if (sum(is.na(final.dataframe$neocortex_volume_mm3)) != 1L)
  stop("Expected exactly one blank neocortex cell (mf2).", call. = FALSE)

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
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    write_tsv(final.dataframe, file.path(tsv_dir, paste0(enc, ".tsv")), na = "")
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
