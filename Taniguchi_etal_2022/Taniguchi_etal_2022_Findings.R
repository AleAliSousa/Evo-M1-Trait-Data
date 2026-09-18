## 0. PATHS --------------------------------------------------------
## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder <- paper_dir <- dirname(.sp)
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))
base <- dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
public_tsv_dir<- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx   <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(stringr)
library(readxl)

## 2. LOAD SNAPSHOT -------------------------------------------------
# Taniguchi, Iwahashi, Oka, Tiong & Sato (2022), PLoS ONE 17(9): e0274170,
# "Fezf2-positive fork cell-like neurons in the mouse insular cortex".
# Not a printed data table -- the paper's own Table 1 is a literature summary
# of other groups' marker reports, which is a roadmap and is NOT ingested.
# The snapshot records the paper's own findings, one row per observation, each
# carrying the figure or section it comes from.
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
# Cleaning steps:
#   (a) column names to snake_case; Present to logical
#   (b) identification_basis derived per row: "morphology" for the two
#       morphological features, "marker" for the expression rows. THIS IS THE
#       COLUMN THE FOLDER EXISTS TO JUSTIFY. Mouse has no bipolar VEN
#       morphology but does have fork cell-like neurons carrying Fezf2, with
#       NMB and GRP in the same region -- so a bare VEN_present boolean would
#       put mouse and chimpanzee in the same bucket, or in opposite buckets,
#       depending entirely on which criterion was used, and neither is right.
#       Banovac et al. 2021 make the same point: identification in non-primates
#       should not rest on morphology alone.
#   (c) region_printed kept verbatim -- the insular subdivisions GI/DI/AI are
#       exactly what this paper distinguishes, so they are not collapsed
#   (d) class and order are NOT carried here. Taxonomy above the species name
#       belongs in _keys/species_reference.csv, not repeated in every item file.
#   (e) data_role = "secondary" for the three Allen Mouse Brain Atlas lookups
#       (ADRA1A, VMAT2, GABRQ). Those are database queries, not measurements
#       made in this study, and must not be read as this paper's own evidence.
morph_features  <- c("VEN_bipolar_morphology", "Fork_cell_like_morphology", "Holding_neuron")
atlas_features  <- c("ADRA1A_expression", "VMAT2_expression", "GABRQ_expression")

final.dataframe <- df_snapshot %>%
  rename(
    species           = Species,
    common_name       = Common_name,
    region_printed    = Region,
    layer             = Layer,
    feature           = Feature,
    present           = Present,
    detail_as_printed = Detail_as_printed,
    method            = Method,
    figure_or_section = Figure_or_section
  ) %>%
  mutate(
    species     = str_squish(species),
    common_name = tolower(str_squish(common_name)),
    present     = as.logical(present),
    identification_basis = case_when(
      feature %in% morph_features ~ "morphology",
      TRUE                        ~ "marker"
    ),
    data_role = ifelse(feature %in% atlas_features, "secondary", "primary"),
    region_sampled = case_when(
      str_detect(region_printed, "insular") ~ "insula_subdivided",
      TRUE                                  ~ "cortex_unspecified"
    ),
    source = sub("_Findings$", "", table_name)
  ) %>%
  select(species, common_name, region_sampled, region_printed, layer,
         feature, present, identification_basis, data_role, detail_as_printed,
         method, figure_or_section, source)

## 3b. CHECKS ------------------------------------------------------
# Every row must be traceable. No value without a source is the house rule.
no_src <- final.dataframe %>% filter(is.na(figure_or_section) | figure_or_section == "")
if (nrow(no_src)) warning(nrow(no_src), " row(s) with no figure or section reference -- ",
                          "these fail the traceability rule and must not be merged.")

# Sanity: the headline negative should be present and FALSE.
ven_row <- final.dataframe %>% filter(feature == "VEN_bipolar_morphology")
if (nrow(ven_row) != 1 || isTRUE(ven_row$present)) {
  warning("VEN_bipolar_morphology row missing or TRUE -- check the transcription. ",
          "The paper reports NO VEN-like bipolar cells in mouse insular cortex.")
}

## 4. SAVE OUTPUTS -------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, final_csv, row.names = FALSE)

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' found in __ReadMe.xlsx for Item name: ", table_name,
            " -- add a row to __ReadMe.xlsx before final submission.")
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(final.dataframe,
                file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
  }
}
