# Faurby_etal_2018_Traitdata.R
#
# Faurby, S., Davis, M., Pedersen, R. Ø., Schowanek, S. D., Antonelli, A., & Svenning, J.-C. (2018). PHYLACINE 1.2: The Phylogenetic Atlas of Mammal Macroecology. Ecology, 99(11), 2626. https://doi.org/10.1002/ecy.2443
# (__ReadMe item: Faurby_etal_2018 / "Trait data").
#
# PHYLACINE 1.2 Trait_data.csv (Zenodo record 4954990): trait data for 5,831 mammal species (last ~130,000 years, extant and extinct).
# Digital-native download; snapshot is a byte-identical copy of the source file.
#
# Input  : Faurby_etal_2018_Traitdata_snapshot.csv
# Outputs: Faurby_etal_2018_Traitdata.csv
#          <DOI>_Traitdata.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

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

snapshot_file <- paste0(item_name, "_snapshot.csv")
output_file   <- paste0(item_name, ".csv")

raw <- read_csv(snapshot_file, show_col_types = FALSE, progress = FALSE)
stopifnot(ncol(raw) == 24L, nrow(raw) == 5831L, !anyDuplicated(raw$Binomial.1.2))

# column names -> snake_case (drop ".1.2" version tag); binomial underscore -> space for species
nm <- tolower(gsub("\\.", "_", sub("\\.1\\.2$", "", names(raw))))
names(raw) <- nm
final.dataframe <- raw %>%
  rename(species_epithet = species) %>%
  mutate(species = str_replace_all(binomial, "_", " "), .before = 1) %>%
  mutate(source = "Faurby_etal_2018")
stopifnot(!anyDuplicated(final.dataframe$species))

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
