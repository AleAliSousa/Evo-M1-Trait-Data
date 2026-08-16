# EvoM1: limb kinematics / locomotor posture (Medina-González 2026) -> gait_excursion_medina.xlsx
#
# Broad-coverage locomotion source for the behaviour merge (locomotion axis). Exposes the
# species-level summaries only (angular utilization index, limb posture, top speed, locomotor habit)
# for 182 terrestrial mammals / 15 orders; the per-joint excursion angles stay in the frozen source.
# Correlatable beside locomotion.xlsx (Granatosky) and gait.xlsx (Wimberly).
#
# STATUS: externally blocked. The published Zenodo record is restricted and exposes no downloadable
# files (verified through the API 2026-08-15). Once the seven source files are supplied or access is
# granted, freeze them per MedinaGonzalez_2026/MedinaGonzalez_2026.README.md, CONFIRM the real column
# names at the TODO(curator) marker, and then run this reader.

library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "MedinaGonzalez_2026_Data"                  # register in __ReadMe.xlsx (Sheet1)

# species resolver (single source of truth = _keys), identical to the sibling readers
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
ref <- read.csv("_keys/species_reference.csv",   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) { c <- clean_sp(x)
  h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }

filecodes    <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) item_encoded <- "10.1002%2Fjez.70069_Data"        # article DOI, %2F-encoded
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

species_in <- if ("Species" %in% names(d)) d$Species else d[[1]]

# TODO(curator): confirm the summary column headers in the Zenodo dataset and map them below.
# Keep the per-joint touchdown/midstance/toe-off angle columns OUT of the trait table (too granular).
out <- data.frame(
  species_sci               = vapply(species_in, resolve, character(1)),
  Species                   = trimws(species_in),
  Angular_utilization_index = d[["AUI"]],            # angular range utilization (%)
  Limb_posture              = d[["Limb_posture"]],   # plantigrade/digitigrade/unguligrade
  Top_speed                 = d[["Top_speed"]],
  Locomotor_habit           = d[["Locomotor_habit"]],
  stringsAsFactors = FALSE, check.names = FALSE
)
write_xlsx(out, paste0(folder_path, "gait_excursion_medina.xlsx"))
cat("gait_excursion_medina.xlsx:", nrow(out), "rows\n")
