# EvoM1: locomotion (Granatosky 2018) -> locomotion.xlsx for the trait table.
# Reads the DOI-coded public TSV, keeps the summary locomotor indices.
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Granatosky__2018_TableS1"

filecodes    <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) item_encoded <- "10.1111%2Fjzo.12608_TableS1"
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

out <- d[, c("species_sci", "Species", "Locomotor_diversity_index",
             "Intermembral_index", "Arboreal_terrestrial")]
write_xlsx(out, paste0(folder_path, "locomotion.xlsx"))
cat("locomotion.xlsx:", nrow(out), "rows\n")
