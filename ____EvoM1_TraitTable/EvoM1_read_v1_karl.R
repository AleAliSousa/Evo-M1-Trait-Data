# EvoM1: V1 synapse / mitochondria / neuron density (Karl et al. 2024)
# -> v1_synapses_karl.xlsx for the trait table.
# NB: these are PRIMARY VISUAL CORTEX (V1) measures, not M1. Per-specimen rows
# (Table 1) are averaged to species means. doi:10.1002/cne.25669
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Karl_etal_2024_TABLE1"

# species resolver (single source of truth = _keys)
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
ref <- read.csv("_keys/species_reference.csv",   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) { c <- clean_sp(x)
  h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }

filecodes    <- read_excel("./__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) item_encoded <- "10.1002%2Fcne.25669_TABLE1"
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

meas <- c("Neuron density (mm2)"       = "V1_neuron_density_per_mm2",
          "Mitochondria density (mm2)" = "V1_mitochondria_density_per_mm2",
          "Synapse density (mm2)"      = "V1_synapse_density_per_mm2",
          "PSD length (nm)"            = "V1_PSD_length_nm")
d$sp <- vapply(d$Species, resolve, character(1))
agg <- aggregate(d[names(meas)],
                 by = list(species_sci = d$sp, Species = trimws(d$Species)),
                 FUN = function(x) mean(suppressWarnings(as.numeric(x)), na.rm = TRUE))
names(agg)[match(names(meas), names(agg))] <- unname(meas)
# blank out NaN (species with no value for a measure)
for (v in unname(meas)) agg[[v]][is.nan(agg[[v]])] <- NA

write_xlsx(agg, paste0(folder_path, "v1_synapses_karl.xlsx"))
cat("v1_synapses_karl.xlsx:", nrow(agg), "species\n")
