# EvoM1: diet & foraging (Wilman et al. 2014, EltonTraits) -> diet_foraging.xlsx.
# Reads the DOI-coded public TSV, subsets to project species (the ~200 in the
# species reference), keeps the focal diet / foraging-stratum / activity traits.
# Body mass is NOT carried here (secondary; compiled in the volume/cell-count merges).
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Wilman_etal_2014_MamFuncDat"

filecodes    <- tryCatch(read_excel("./__ReadMe.xlsx", sheet = "Sheet1"), error = function(e) NULL)
item_encoded <- if (!is.null(filecodes))
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")] else NA
if (is.na(item_encoded)) item_encoded <- "10.1890%2F13-1917.1_MamFuncDat"

d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

# subset to the project's accepted species so the trait table stays correlatable
ref <- read.csv("./_keys/species_reference.csv", stringsAsFactors = FALSE)$accepted_name
d   <- d[d$species_sci %in% ref, ]

keep <- c("species_sci", "Species",
          "Diet_Inv","Diet_Vend","Diet_Vect","Diet_Vfish","Diet_Vunk",
          "Diet_Scav","Diet_Fruit","Diet_Nect","Diet_Seed","Diet_PlantO",
          "Diet_dominant","Diet_breadth","Trophic_guild",
          "ForStrat_stratum","Activity_pattern")
out <- d[, keep]
write_xlsx(out, paste0(folder_path, "diet_foraging.xlsx"))
cat("diet_foraging.xlsx:", nrow(out), "rows\n")
