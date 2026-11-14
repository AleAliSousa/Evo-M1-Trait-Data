# Pagel_etal_2026_SupplementaryData2.R
#
# Pagel, M., O'Donovan, C., & Meade, A. (2026). Convergence in the size and frequency of
# macroevolutionary peak-shifts on the adaptive landscape in vertebrates. Nature Communications,
# 17, 11208. https://doi.org/10.1038/s41467-026-78289-z
# (__ReadMe item: Pagel_etal_2026 / "Supplementary Data 2").
#
# Supplementary Data 2 = "Ecology and Thermoregulation": one row per species (21,374 species,
# five vertebrate Classes) giving dominant ecology (Aquatic / Semi-aquatic / Terrestrial / Volant),
# metabolism (Ectothermic / Endothermic) and the reference number(s) for the ecology assignment.
# 'Base ecology for Class' in the Reference column = the Class default was applied (no
# species-specific source); numbers point to the sheet 'References' (35 works).
#
# The Ecology column in the supplied xlsx is stored as VLOOKUP formulas into an external
# workbook ([1]All!); readxl reads the cached values, which are what is printed in the file.
#
# Input  : Pagel_etal_2026_SupplementaryData2_snapshot.xlsx   sheet: Data (title row, then header)
#          (byte-identical copy of the journal download 41467_2026_78289_MOESM6_ESM.xlsx)
# Outputs: Pagel_etal_2026_SupplementaryData2.csv             one row per species (21,374)
#          reference_tables/Pagel_etal_2026_SupplementaryData2_references.csv  (35 cited works)
#          <DOI>_SupplementaryData2.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})
## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
## NOTE: the previous `if (rstudioapi::isAvailable()) setwd(...)` guard silently did nothing
## when run non-interactively via Rscript (as in run_all_scripts_v2.R), leaving the working
## directory at the repo root and breaking every relative path below.
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

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Data"
output_file    <- paste0(item_name, ".csv")
refs_file      <- file.path("reference_tables", paste0(item_name, "_references.csv"))
header_rows    <- 1L   # one title row above the header row

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = TRUE,
                  skip = header_rows, col_types = "text")
stopifnot(identical(trimws(names(raw)),
                    c("Data row", "Class", "Species", "Ecology", "Metabolism", "Reference")))
names(raw) <- c("data_row", "class", "species", "ecology", "metabolism", "reference")

# whitespace: header 'Species ' and 47 amphibian cells 'Aquatic ' carry a trailing space
clean <- raw %>% mutate(across(everything(), str_squish)) %>% filter(!is.na(species), species != "")

# multi-citations printed "19, 20" -> house separator "; "; 'Base ecology for Class' kept verbatim
ref_clean <- str_replace_all(clean$reference, "\\s*,\\s*", "; ")

final.dataframe <- tibble(
  data_row      = as.integer(clean$data_row),
  class         = clean$class,
  species       = clean$species,
  ecology       = clean$ecology,
  metabolism    = clean$metabolism,
  reference     = ref_clean,
  ecology_basis = ifelse(clean$reference == "Base ecology for Class", "class_default", "species_specific"),
  source        = "Pagel_etal_2026"
)
stopifnot(nrow(final.dataframe) == 21374L, !anyDuplicated(final.dataframe$species))

## ---- reference lookup: only the works actually cited (join on ref_key after splitting "; ") ----
refs_raw <- read_excel(snapshot_file, sheet = "References", col_types = "text")
names(refs_raw) <- c("ref_key", "citation")
cited <- unique(unlist(strsplit(final.dataframe$reference[final.dataframe$ecology_basis == "species_specific"], "; ")))
refs <- refs_raw %>% mutate(ref_key = str_squish(ref_key), citation = str_squish(citation)) %>%
  filter(ref_key %in% cited) %>%
  mutate(cited_in_column = "Reference", note = "", .before = citation) %>%
  select(ref_key, cited_in_column, citation, note)
stopifnot(setequal(refs$ref_key, cited))
dir.create("reference_tables", showWarnings = FALSE)
write.csv(refs, file = refs_file, row.names = FALSE)

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV (named from __ReadMe.xlsx 'Item encoded') ----
## item_name already resolved above (self-contained path block) -- matches this file's name.
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

readme_file <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx"
tsv_dir     <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/"
filecodes    <- read_excel(readme_file, sheet = "Sheet1")
norm_key     <- function(x) tolower(gsub("[ _]", "", as.character(x)))
item_encoded <- filecodes$"Item encoded"[match(norm_key(item_name), norm_key(filecodes$"Item name"))]
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = paste0(tsv_dir, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_dir, item_encoded, ".tsv")
}
