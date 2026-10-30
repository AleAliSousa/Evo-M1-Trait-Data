## =============================================================================
## de Sousa AA, Sherwood CC, Schleicher A, Amunts K, MacLeod CE, Hof PR, Zilles K
## (2009/2010). Comparative cytoarchitectural analyses of striate and extrastriate
## areas in hominoids. Cereb Cortex 20(4):966-981. Table 1.
## DOI: 10.1093/cercor/bhp158   (Advance Access, 23 September 2009)
## =============================================================================
##
## Input   deSousa_etal_2009_Table1_snapshot.xlsx  (sheet "Table1")
## Output  deSousa_etal_2009_Table1.csv
##         + DOI-coded TSV in __Public/comparative-data/ when run inside the repo
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published, minus the superscript footnote markers
## (those are typography, not name -- they go to footnote_ref); harmonisation via
## _keys/Stephan/species_key.csv (token "deSousa2009": Gorilla gorilla -> Gorilla sp.,
## Pongo pygmaeus -> Pongo sp., as for deSousa2010/deSousa2013 -- same specimens).
##
## Units (__HOWTO_build_a_dataset_file.md section 6): body kg -> g (x1000),
## brain g -> mg (x1000), neocortex cm3 -> mm3 (x1000); left V1 / left LGN are
## printed in mm3 and pass through unchanged; the two area columns stay mm2.
##
## Laterality: V1 and LGN are LEFT-hemisphere volumes printed UNDOUBLED
## ("Included were sections from the left hemispheres of adult specimens").
## Registered in ../__merging_volumes/laterality_known.csv as doubling = none,
## required_suffix = _left.
##
## Nothing printed is corrected here. Two printed oddities are carried verbatim and
## flagged in the README instead: (1) the ppz/Zahlia neocortex 279 cm3 is the value
## de Sousa 2010 Table 1 prints for a different bonobo; (2) brain mass is rounded
## relative to 2010 Table 1 (58 vs 57.6; 360 vs 359.5).
## =============================================================================

options(scipen = 999)
suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
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
folder      <- dirname(.sp)
item_name   <- tools::file_path_sans_ext(basename(.sp))
source_name <- sub("_Table[^_]*$", "", item_name)
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
output_csv  <- paste0(item_name, ".csv")
base        <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot ------------------------------------------------
## Positional read: the printed header is three tiers deep with footnote letters
## glued to the labels, so columns are named by position (section 3).
header_rows <- 5L                    # caption, sub-caption, and the 3 header tiers
cols <- c(
  "species_as_published",
  "code",
  "archive_number",
  "sex",
  "age_yrs",
  "body_mass_kg",
  "brain_mass_g",
  "EQ",
  "neocortex_volume_cm3",
  "left_V1_volume_mm3",
  "left_LGN_volume_mm3",
  "optic_nerve_csa_mm2",
  "eye_half_surface_area_mm2"
)

num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a.", "__"))
chr <- function(x) { x <- str_squish(as.character(x)); x[x %in% c("", "NA")] <- NA_character_; x }

raw <- read_excel(snapshot_xlsx, sheet = "Table1", col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(cols)] <- cols

## ---- printed species cells --------------------------------------------------
## The footnote markers are superscripts in the PDF; that typography is lost in the
## snapshot, so the marker arrives glued to the epithet ("Pan paniscusc"). A
## structural strip would be ambiguous ("Gorilla gorilla" would lose its final "a"),
## so the printed cells are listed explicitly and joined -- an unlisted cell stops
## the build rather than being guessed at.
##
## printed_cell         = the flattened snapshot cell, marker glued on (join key only)
## species_as_published = the name AS PRINTED, marker removed. The superscript is
##                        typography, not part of the name, so it never belongs in
##                        this column; it is carried in footnote_ref instead.
## species              = the harmonised name (same here; harmonisation is downstream)
printed_species <- tibble::tribble(
  ~printed_cell,          ~species_as_published, ~species,              ~footnote_ref,
  "Gorilla gorilla",      "Gorilla gorilla",     "Gorilla gorilla",     NA_character_,
  "Hylobates lar",        "Hylobates lar",       "Hylobates lar",       NA_character_,
  "Homo sapiensa,b",      "Homo sapiens",        "Homo sapiens",        "a,b",
  "Macaca fascicularis",  "Macaca fascicularis", "Macaca fascicularis", NA_character_,
  "Pongo pygmaeus",       "Pongo pygmaeus",      "Pongo pygmaeus",      NA_character_,
  "Pan paniscusc",        "Pan paniscus",        "Pan paniscus",        "c",
  "Pan troglodytes",      "Pan troglodytes",     "Pan troglodytes",     NA_character_,
  "Pan troglodytesd",     "Pan troglodytes",     "Pan troglodytes",     "d"
)

## ---- keep the data rows, type, and convert to project units -----------------
clean <- dat %>%
  filter(!is.na(num(left_V1_volume_mm3))) %>%          # drops caption/footnote/blank rows
  mutate(printed_cell = str_squish(species_as_published)) %>%
  select(-species_as_published) %>%
  left_join(printed_species, by = "printed_cell")

if (any(is.na(clean$species))) {
  stop("Unlisted species cell(s) in the snapshot: ",
       paste(unique(clean$printed_cell[is.na(clean$species)]), collapse = ", "),
       call. = FALSE)
}

clean <- clean %>%
  transmute(
    species,
    species_as_published,
    footnote_ref,
    code           = chr(code),
    archive_number = chr(archive_number),
    sex            = chr(sex),
    age_yrs        = num(age_yrs),
    body_mass_g    = num(body_mass_kg) * 1000,          # kg -> g
    brain_mass_mg  = num(brain_mass_g) * 1000,          # g  -> mg
    EQ             = num(EQ),                           # derived index, not merged
    neocortex_volume_mm3 = num(neocortex_volume_cm3) * 1000,   # cm3 -> mm3
    left_V1_volume_mm3   = num(left_V1_volume_mm3),      # printed mm3
    left_LGN_volume_mm3  = num(left_LGN_volume_mm3),     # printed mm3
    optic_nerve_csa_mm2       = num(optic_nerve_csa_mm2),
    eye_half_surface_area_mm2 = num(eye_half_surface_area_mm2),
    ## footnote-driven substitutions, split out of the species markers (section 3.4)
    body_mass_substituted  = !is.na(footnote_ref) & str_detect(footnote_ref, "a|c|d"),
    brain_mass_substituted = !is.na(footnote_ref) & str_detect(footnote_ref, "d"),
    neocortex_substituted  = !is.na(footnote_ref) & str_detect(footnote_ref, "b"),
    substitution_note = case_when(
      footnote_ref == "a,b" ~ "body weight = same-sex species mean (Zilles 1972); neocortex = combined-sex human mean (n = 8), unpublished data from Carol MacLeod",
      footnote_ref == "c"   ~ "body weight = same-sex species mean (Jungers and Susman 1984)",
      footnote_ref == "d"   ~ "brain and body weight = combined-sex species means (Herndon et al. 1999)",
      TRUE ~ NA_character_
    ),
    source = source_name
  )

stopifnot(nrow(clean) == 9L, dplyr::n_distinct(clean$code) == 9L)

## No footnote marker may survive in species_as_published: every cell must be a
## clean binomial. Guards against a snapshot re-extract silently regluing them.
stopifnot(all(grepl("^[A-Z][a-z]+ [a-z]+$", clean$species_as_published)))
stopifnot(sum(!is.na(clean$footnote_ref)) == 4L)   # 2x "a,b", 1x "c", 1x "d"

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx ----------------
tsv_dir <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
