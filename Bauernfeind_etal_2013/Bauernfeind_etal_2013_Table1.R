# Bauernfeind_etal_2013_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Bauernfeind et al.
# (2013) Table 1 -- the per-INDIVIDUAL, shrinkage-corrected volumes of the LEFT
# insula and its subdivisions -- into a lean, analysis-ready CSV/TSV. Output
# comes from the snapshot only.
#
# Snapshot layout (matches the printed Table 1): row1 caption, row2 the unit
# banner ("Volume estimates of left insular subdivisions (cm3)"), row3 the column
# headers, then 43 individual rows (full species name on the first individual of
# each species, abbreviated -- "H. sapiens" -- thereafter; missing/absent values
# as en-dash), then three footnote rows (a/b/c). Volumes are in cm3, body mass in
# kg, brain mass in g, exactly as printed.
#
# THIS script reads past the 3 header rows, keeps the individual rows (drops the
# footnotes), carries the genus down to expand the abbreviated species names, and
# converts to the project units used in Bauernfeind_2013.csv: body kg -> g, brain
# g -> mg, all volumes cm3 -> mm3 (x1000). Because the table is left-insula
# only, the five insula/subdivision output columns are explicitly marked with
# the Barger-style _L side tag. One row per individual (43).
# Species means (and the two-Pongo-species merge the CSV uses) are a downstream
# aggregation -- see the comparison script -- not done here.
#
# Input  : Bauernfeind_etal_2013_Table1_snapshot.xlsx   sheet: Table1
# Outputs: Bauernfeind_etal_2013_Table1.csv             one row per individual (43)
#          <DOI>.tsv in __Public/comparative-data/        named from __ReadMe.xlsx

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
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
snapshot_file  <- "Bauernfeind_etal_2013_Table1_snapshot.xlsx"
snapshot_sheet <- "Table1"
output_file    <- "Bauernfeind_etal_2013_Table1.csv"
header_rows    <- 3L   # caption + unit banner + column headers; data from row 4

pos <- c("species_disp","individual","collection","section_thickness_mm","age","sex",
         "body_mass_kg","social_group_size","brain_mass_g","brain_volume_cm3",
         "granular_cm3","dysgranular_cm3","agranular_cm3","FI_cm3","total_insula_cm3")
num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a.", "__", "e"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

# keep individual rows only (drop the 3 footnote rows: text in col A, no individual ID)
dat <- dat %>% filter(!is.na(individual), str_squish(individual) != "")

# expand abbreviated species: carry the most recent full genus down onto "H. sapiens" rows
dat <- dat %>%
  mutate(genus_tok = word(str_squish(species_disp), 1),
         full_genus = ifelse(str_detect(genus_tok, "\\.$"), NA_character_, genus_tok)) %>%
  fill(full_genus, .direction = "down") %>%
  mutate(Species = ifelse(str_detect(genus_tok, "\\.$"),
            str_squish(paste(full_genus, word(str_squish(species_disp), 2, -1))),
            str_squish(species_disp)))

final.dataframe <- dat %>% transmute(
  Species,
  Individual           = str_squish(individual),
  Collection           = str_squish(collection),
  section_thickness_mm = num(section_thickness_mm),
  age                  = num(age),
  sex                  = str_squish(sex),
  body_mass_g          = num(body_mass_kg) * 1000,   # kg -> g
  social_group_size    = num(social_group_size),
  brain_mass_mg        = num(brain_mass_g) * 1000,   # g  -> mg
  brain_volume_mm3     = num(brain_volume_cm3) * 1000, # cm3 -> mm3

  # Table 1's unit banner says these are LEFT insular subdivisions. Mark only
  # the insula/subdivision measures with _L; brain_volume_mm3 is whole brain.
  granular_L_mm3       = num(granular_cm3)   * 1000,
  dysgranular_L_mm3    = num(dysgranular_cm3) * 1000,
  agranular_L_mm3      = num(agranular_cm3)  * 1000,
  FI_L_mm3             = num(FI_cm3)         * 1000,
  total_insula_L_mm3   = num(total_insula_cm3) * 1000)

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " individuals, ",
        dplyr::n_distinct(final.dataframe$Species), " species)")

## ---- also write the DOI-coded TSV to __Public/comparative-data/ (skipped if shared repo absent) ----
tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
