# EvoM1: hand manipulability from hand proportions (Bardo et al. 2016) -> hand_bardo.xlsx
#
# Secondary compilation for the behaviour merge (hand_morphology axis). Exposes the manipulability /
# dexterous-workspace index derived from hand proportions for 13 anthropoid species. Complements
# Baker 2025 peak_workspace (same Feix-style manipulability construct -> citation-dependent, never
# averaged) and Heffner/Iwaniuk dexterity.
#
# STATUS: scaffold. Frozen source (Bardo SI table) + its DOI-coded public TSV are NOT yet in the repo
# (org network policy blocked the publisher download in the scaffolding session; no R runtime). Drop
# the source in per Bardo_etal_2016/Bardo_etal_2016.README.md, CONFIRM the column name at the
# TODO(curator) marker, then this reads like its sibling readers.

library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Bardo_etal_2016_Data"                      # register in __ReadMe.xlsx (Sheet1)

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
if (is.na(item_encoded)) item_encoded <- "10.1098%2Frspb.2016.1923_Data"   # article DOI, %2F-encoded
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

species_in <- if ("Species" %in% names(d)) d$Species else d[[1]]

# TODO(curator): confirm the manipulability/workspace index column header in the Bardo SI table and
# map it onto Manipulability_index below (there may be several proportion indices — pick the headline
# manipulative-potential / workspace measure, or expose several as separate columns).
out <- data.frame(
  species_sci        = vapply(species_in, resolve, character(1)),
  Species            = trimws(species_in),
  Manipulability_index = d[["Manipulability"]],
  stringsAsFactors = FALSE, check.names = FALSE
)
write_xlsx(out, paste0(folder_path, "hand_bardo.xlsx"))
cat("hand_bardo.xlsx:", nrow(out), "rows\n")
