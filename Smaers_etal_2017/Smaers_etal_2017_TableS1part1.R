# Smaers_etal_2017_TableS1part1.R
#
# Smaers JB, Gomez-Robles A, Parks AN, Sherwood CC (2017), Current Biology 27:714-720,
# "Exceptional Evolutionary Expansion of Prefrontal Cortex in Great Apes and Humans."
# DOI 10.1016/j.cub.2017.01.020.  Supplemental Table S1 (file mmc1) reports two
# distinct measure classes that the original build wrongly kept in one sheet; this is
# PART 1 of 2 -- the "Smaers data" VOLUME block only (gray + white matter), 4 cortical
# regions x 2 matters = 8 columns, 19 primate species.  (Part 2 = the Brodmann
# surface-area block; see Smaers_etal_2017_TableS1part2.R.)
#
# Provenance: these volumes are COMPILED, not newly measured -- prefrontal & frontal
# motor from Smaers 2010 PLoS ONE [S1] + Smaers 2011 Brain Behav Evol [S2]; primary
# visual from de Sousa et al. 2010 [S6].  Prefrontal = cumulative volume of the
# anterior 5 of 20 frontal sections; frontal motor = posterior 5 sections (the two
# ENDS of the frontal lobe -- their sum is NOT the whole frontal lobe; see ReadMe).
# UNITS FLAG: the supplement labels volumes mm3, but the values scale as cm3 (they match
# Smaers 2011, which is cm3).  The snapshot keeps the printed label; downstream code
# should treat these as cm3.
#
# Output comes from the snapshot only.
# Input  : Smaers_etal_2017_TableS1part1_snapshot.xlsx   sheet: volumes
# Outputs: Smaers_etal_2017_TableS1part1.csv             one row per species (19)
#          <DOI>_TableS1part1.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

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
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})
## Set working directory to this script folder
setwd(folder)
snapshot_file  <- "Smaers_etal_2017_TableS1part1_snapshot.xlsx"
snapshot_sheet <- "volumes"
output_file    <- "Smaers_etal_2017_TableS1part1.csv"
header_rows    <- 3L

pos <- c("species_disp",
         "primary_visual_gray","prefrontal_gray","other_association_gray","frontal_motor_gray",
         "primary_visual_white","prefrontal_white","other_association_white","frontal_motor_white")
num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

final.dataframe <- dat %>%
  filter(!is.na(species_disp), species_disp != "") %>%
  transmute(
    species                 = str_replace_all(str_squish(species_disp), " ", "_"),
    primary_visual_gray     = num(primary_visual_gray),
    prefrontal_gray         = num(prefrontal_gray),
    other_association_gray  = num(other_association_gray),
    frontal_motor_gray      = num(frontal_motor_gray),
    primary_visual_white    = num(primary_visual_white),
    prefrontal_white        = num(prefrontal_white),
    other_association_white = num(other_association_white),
    frontal_motor_white     = num(frontal_motor_white),
    source                  = "Smaers_etal_2017"
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV (named from __ReadMe.xlsx 'Item encoded') ----
item_name <- tryCatch(gsub("\\.R$", "", basename(.sp)),
                      error = function(e) tools::file_path_sans_ext(output_file))
if (is.null(item_name) || !nzchar(item_name)) item_name <- tools::file_path_sans_ext(output_file)
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

readme_file <- file.path(base, "__ReadMe.xlsx")
tsv_dir     <- paste0(file.path(base, "__Public", "comparative-data"), "/")
filecodes    <- read_excel(readme_file, sheet = "Sheet1")
# __ReadMe 'Item name' is a formula that strips spaces & underscores from the Item
# number (e.g. "Table S1 part1 volumes" -> "...TableS1part1volumes"), so match on a
# separator-insensitive key rather than the literal file stem.
norm_key     <- function(x) tolower(gsub("[ _]", "", as.character(x)))
item_encoded <- filecodes$"Item encoded"[match(norm_key(item_name), norm_key(filecodes$"Item name"))]
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = paste0(tsv_dir, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_dir, item_encoded, ".tsv")
}
