# Bauernfeind_etal_2013_Table2.R
#
# Preparation step. Turn the journal-faithful snapshot of Bauernfeind et al. (2013)
# Table 2 -- the per-INDIVIDUAL, shrinkage-corrected volumes of the RIGHT insula and
# its subdivisions in humans and great apes -- into a lean, analysis-ready CSV/TSV.
# Output comes from the snapshot only.  This is the right-hemisphere counterpart of
# Table 1 (left); together they give whole-insula (both-hemisphere) volumes downstream
# (see __merging_volumes/volumes_compiled.R, Phase-4 hemisphere reconciliation).
#
# Snapshot layout (Bauernfeind_etal_2013_Table2_snapshot.xlsx, sheet Table2): a single
# header row (Species, Individual, Granular, Dysgranular, Agranular, FI, Total insula)
# then 15 individual rows.  Full binomial on the first individual of each species,
# abbreviated ("H. sapiens") thereafter.  Volumes are cm3, exactly as printed.
#
# THIS script expands the abbreviated species names (carry the genus down) and converts
# cm3 -> mm3 (x1000).  Because the table is the RIGHT insula, the five insula columns
# carry the Barger-style _R side tag.  One row per individual (15).
#
# Input  : Bauernfeind_etal_2013_Table2_snapshot.xlsx   sheet: Table2
# Outputs: Bauernfeind_etal_2013_Table2.csv             one row per individual (15)
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
options(scipen = 999)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Table2"

num <- function(x) parse_number(as.character(x), na = c("", "-", "\u2013", "\u2014", "NA", "n.a."))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_types = "text")
names(raw) <- c("species_disp", "individual", "granular_cm3", "dysgranular_cm3",
                "agranular_cm3", "FI_cm3", "total_insula_cm3")

# expand abbreviated species: carry the most recent full genus down onto "H. sapiens" rows
dat <- raw %>%
  filter(!is.na(individual), str_squish(individual) != "") %>%
  mutate(genus_tok  = word(str_squish(species_disp), 1),
         full_genus = ifelse(str_detect(genus_tok, "\\.$"), NA_character_, genus_tok)) %>%
  fill(full_genus, .direction = "down") %>%
  mutate(Species = ifelse(str_detect(genus_tok, "\\.$"),
            str_squish(paste(full_genus, word(str_squish(species_disp), 2, -1))),
            str_squish(species_disp)))

final.dataframe <- dat %>% transmute(
  Species,
  Individual         = str_squish(individual),
  # Table 2 is the RIGHT insula; tag the five insula measures with _R. cm3 -> mm3.
  granular_R_mm3     = num(granular_cm3)     * 1000,
  dysgranular_R_mm3  = num(dysgranular_cm3)  * 1000,
  agranular_R_mm3    = num(agranular_cm3)    * 1000,
  FI_R_mm3           = num(FI_cm3)           * 1000,
  total_insula_R_mm3 = num(total_insula_cm3) * 1000)

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
