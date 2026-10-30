# EvoM1: hand morphology & dexterity (Baker, Barton & Venditti 2025) -> dexterity_baker.xlsx
# Secondary compilation. Exposes the behavioural / hand-derived columns only:
#   Tool_Use / Tool_Manufacture / True_Tool_Use (0/1 presence), peak_workspace (Feix 2015),
#   relative_size / real_size (derived), and the log10 hand-bone lengths (mm).
# Brain/body/neocortex/cerebellum are NOT exposed here (they flow through the volume/mass
# merges); Binocularity is sensory, not dexterity. Values are left in published log10 units.
# Restricted bone data (Lemelin 1996, bone_data_restricted=TRUE) is already NA in the source.
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Baker_etal_2025_SupplementaryData1"

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
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

# all log10_*_mm hand-bone length columns, in source order (19: thumb has no intermediate phalanx)
bone_cols <- grep("^log10_.*_mm$", names(d), value = TRUE)

out <- data.frame(
  species_sci      = vapply(d$Species, resolve, character(1)),
  Species          = trimws(d$Species),
  Tool_Use         = d$Tool_Use,
  Tool_Manufacture = d$Tool_Manufacture,
  True_Tool_Use    = d$True_Tool_Use,
  peak_workspace   = d$peak_workspace,
  relative_size    = d$relative_size,
  real_size        = d$real_size,
  stringsAsFactors = FALSE, check.names = FALSE
)
out <- cbind(out, d[, bone_cols, drop = FALSE])          # 19 log10 bone-length columns
write_xlsx(out, paste0(folder_path, "dexterity_baker.xlsx"))
cat("dexterity_baker.xlsx:", nrow(out), "rows,", length(bone_cols), "bone cols\n")
