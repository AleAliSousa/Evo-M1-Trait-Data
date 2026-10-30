# EvoM1: walking gait (Wimberly et al. 2021) -> gait.xlsx for the trait table.
# Reads the DOI-coded public TSV, keeps the focal gait-mechanics traits.
# Correlatable side-by-side with locomotion.xlsx (Granatosky 2018) on species_sci.
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Wimberly_etal_2021_MammalGait"

filecodes    <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) item_encoded <- "10.1098%2Frspb.2021.0937_MammalGait"
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

out <- d[, c("species_sci", "Species", "Duty_Factor", "Phase", "Gait", "Foot_Posture")]
write_xlsx(out, paste0(folder_path, "gait.xlsx"))
cat("gait.xlsx:", nrow(out), "rows\n")
