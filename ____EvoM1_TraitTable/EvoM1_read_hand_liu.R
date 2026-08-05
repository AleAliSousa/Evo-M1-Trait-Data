# EvoM1: hand manipulability from hand proportions (Liu et al. 2016) -> hand_liu.xlsx
#
# CORRECTED 2026-08-04: this reader was scaffolded as EvoM1_read_hand_bardo.R against a fabricated
# citation ("Bardo et al. 2016"). The paper is Liu, M.-J., Xiong, C.-H., & Hu, D. (2016), Proc Biol
# Sci 283(1843):20161923, DOI 10.1098/rspb.2016.1923, PMID 27903877, EndNote [9631]. Ameline Bardo is
# a real hand-evolution researcher but is not an author on it. See Liu_etal_2016/Liu_etal_2016_TableS1.README.md
#
# Secondary compilation for the behaviour merge (hand_morphology axis). Exposes the modelled
# manipulative potential of the hand for 13 anthropoid species, from SI Table S1.
#
# CITATION-DEPENDENCY (hard): Liu's raw hand morphometrics are taken from Feix, Kivell, Pouydebat &
# Dollar (2015), J R Soc Interface -- the same source Baker 2025 peak_workspace descends from. Liu and
# Baker therefore share their raw input, not just a construct family: citation-dependent, NEVER
# averaged. Resolve to one source in behaviour_compiled.R.
#
# STATUS: scaffold. The frozen source (rspb20161923_si_001.pdf) IS now in Liu_etal_2016/, but it is a
# PDF of the tables -> a hand-verified snapshot + its DOI-coded public TSV must be built first
# (see the README). Once __Public/comparative-data/<code>.tsv exists this reads like its siblings.

library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Liu_etal_2016_TableS1"                     # register in __ReadMe.xlsx (Sheet1)

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
if (is.na(item_encoded)) item_encoded <- "10.1098%2Frspb.2016.1923_TableS1"  # article DOI, %2F-encoded
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

species_in <- if ("Species" %in% names(d)) d$Species else d[[1]]

# Column names are CONFIRMED from the SI (the old TODO(curator) marker is resolved):
#   Species | Key | MC1 PP1 DP1 | MC2 PP2 IP2 DP2 | WS | GMI
#   GMI = global manipulation index (headline manipulative-potential measure)
#   WS  = workspace
#   Key = museum accession number -- Table S1 is ONE ROW PER SPECIMEN, not per species.
# Specimen rows are kept here so the museum provenance survives; aggregate to species only in the
# merge, so that behaviour_compiled.R controls how individuals are pooled.
out <- data.frame(
  species_sci          = vapply(species_in, resolve, character(1)),
  Species              = trimws(species_in),
  specimen_key         = if ("Key" %in% names(d)) trimws(d$Key) else NA_character_,
  Manipulability_index = d[["GMI"]],
  Workspace            = d[["WS"]],
  stringsAsFactors = FALSE, check.names = FALSE
)

# Fossil hands (SI Figure S6: Homo neanderthalensis, Ohalo II H2, Homo naledi) are NOT in Table S1 and
# are not read here. If they are ever added, keep them decomposable -- fossil Homo is a temporal grade,
# never pooled into an extant Homo sapiens mean.

write_xlsx(out, paste0(folder_path, "hand_liu.xlsx"))
cat("hand_liu.xlsx:", nrow(out), "rows,",
    length(unique(out$species_sci)), "species\n")
