# EvoM1: behavioural innovation & technical intelligence (Reader lineage) -> innovation_reader.xlsx
#
# Seeds a technical-innovation compilation for the behaviour merge, starting from Simon Reader's
# classic primate cognition dataset:
#   - Reader & Laland 2002 (PNAS)         the ORIGINAL "big dataset": innovation / social learning /
#                                          tool-use report frequencies across 116 primate species.
#   - Reader, Hager & Laland 2011 (PhilTrans)  the machine-readable multi-domain extension used here:
#                                          innovation, social learning, tool use, EXTRACTIVE FORAGING,
#                                          tactical deception for 62 primate species, all corrected
#                                          for research effort. Archived on Dryad (doi:10.5061/dryad.t0q94,
#                                          file Data_ReaderHagerLalandPhilTrans2011.csv).
#
# Deliberately NOT Navarrete et al. 2016 (per curator: use Reader's own data as the source of record;
# Navarrete descends from the same lineage and would be citation-dependent, never averaged).
#
# Focus columns for the M1/technical axis: behavioural Innovation (the classic measure),
# Extractive foraging, and Tool use report frequencies. Social learning / tactical deception are
# carried too (social axis) but are not the technical-intelligence focus.
#
# STATUS: scaffold. The frozen source (the Dryad CSV) and its DOI-coded public TSV are NOT yet in the
# repo — the org network policy blocked the Dryad download in the session that wrote this. Drop the
# file in per Reader_etal_2011/Reader_etal_2011.README.md, CONFIRM the exact source column names at
# the two TODO markers below, then this reads exactly like its sibling readers.

library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Reader_etal_2011_Data"                     # register this in __ReadMe.xlsx (Sheet1)

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
if (is.na(item_encoded)) item_encoded <- "10.1098%2Frstb.2010.0342_Data"   # article DOI, %2F-encoded
d <- read.table(paste0("./__Public/comparative-data/", item_encoded, ".tsv"),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)

# TODO(curator): confirm the species column name in the Dryad CSV (below assumes "Species";
# it may be a binomial column such as "Genus_species"). Preserve the journal's own name verbatim.
species_in <- if ("Species" %in% names(d)) d$Species else d[[1]]

# TODO(curator): confirm the exact measure column headers in the Dryad CSV. The 2011 data ship both
# raw report counts and research-effort-corrected values — expose the RAW counts here (the merge
# stores raw; effort correction is an analysis step). Map the real headers onto the names on the LHS.
out <- data.frame(
  species_sci         = vapply(species_in, resolve, character(1)),
  Species             = trimws(species_in),
  Innovation          = d[["Innovation"]],           # behavioural innovation report frequency
  Extractive_foraging = d[["ExtractiveForaging"]],   # technical / ecological
  Tool_use            = d[["ToolUse"]],
  Social_learning     = d[["SocialLearning"]],
  Tactical_deception  = d[["TacticalDeception"]],
  stringsAsFactors = FALSE, check.names = FALSE
)
write_xlsx(out, paste0(folder_path, "innovation_reader.xlsx"))
cat("innovation_reader.xlsx:", nrow(out), "rows\n")
