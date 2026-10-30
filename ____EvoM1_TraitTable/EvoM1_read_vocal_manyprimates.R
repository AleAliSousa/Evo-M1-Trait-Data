# EvoM1: vocal repertoire size (ManyPrimates 2022) -> vocal_repertoire_manyprimates.xlsx
# Number of vocalization types per primate species (col
# "vocal_repertoire (# vocalization types)"), one row per species with a value.
# Per-species primary reference preserved in the _Source column.
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"

# species resolver (single source of truth = _keys)
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
ref <- read.csv("_keys/species_reference.csv",   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) { c <- clean_sp(x)
  h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }

# registry Item encoded for this row is path-like; use the DOI-coded TSV name.
item_encoded <- "10.26451%2Fabc.09.04.06.2022_speciespredictors"
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

d <- d[!is.na(d$vocal_repertoire_types) & nzchar(trimws(d$vocal_repertoire_types)), ]

out <- data.frame(
  species_sci                    = vapply(d$Species, resolve, character(1)),
  Species                        = trimws(d$Species),
  vocal_repertoire_types         = d$vocal_repertoire_types,
  vocal_repertoire_types_Source  = d$vocal_repertoire_source,
  stringsAsFactors = FALSE, check.names = FALSE
)
write_xlsx(out, paste0(folder_path, "vocal_repertoire_manyprimates.xlsx"))
cat("vocal_repertoire_manyprimates.xlsx:", nrow(out), "rows\n")
