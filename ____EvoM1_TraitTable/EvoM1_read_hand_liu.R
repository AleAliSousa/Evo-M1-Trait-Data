# EvoM1: hand manipulability from hand proportions (Liu et al. 2016) -> hand_liu.xlsx
#
# CORRECTED 2026-08-04: this reader was scaffolded as EvoM1_read_hand_bardo.R against a fabricated
# citation ("Bardo et al. 2016"). The paper is Liu, M.-J., Xiong, C.-H., & Hu, D. (2016), Proc Biol
# Sci 283(1843):20161923, DOI 10.1098/rspb.2016.1923, PMID 27903877, EndNote [9631]. Ameline Bardo is
# a real hand-evolution researcher but is not an author on it.
# See Liu_etal_2016/Liu_etal_2016_TableS1.README.md
#
# FIXED 2026-08-05 — specimen provenance was being dropped silently. Three defects:
#   (1) the reader looked for a column called "Key". That is the header PRINTED in SI Table S1; the
#       build script (Liu_etal_2016_TableS1.R) already renames it to "specimen_key". The lookup fell
#       through to NA_character_, so all 137 rows lost their museum accession without any warning.
#   (2) "museum" (parsed by the build) was not carried through at all.
#   (3) species_sci was being RE-resolved here with the generic key. The build already resolved it
#       paper-scoped (source_publication = Liu2016, remapping only Presbytis cristata ->
#       Trachypithecus cristatus). Re-resolving risks a different answer for the same row, so this
#       reader now PREFERS the resolved column the build wrote and only falls back to resolving.
# A hard stop() now guards the provenance column, so this class of failure cannot recur quietly.
#
# Secondary compilation for the behaviour merge (hand_morphology axis). SI Table S1 is SPECIMEN-level:
# 137 hand specimens across 13 anthropoid species. This reader keeps specimen rows so the museum
# accession survives; aggregation to one value per species is the merge's job, not the reader's.
#
# CITATION-DEPENDENCY (hard): Liu's raw hand morphometrics are taken from Feix, Kivell, Pouydebat &
# Dollar (2015), J R Soc Interface -- the same source Baker 2025 peak_workspace descends from. Liu and
# Baker therefore share their raw input, not just a construct family: citation-dependent, NEVER
# averaged. Resolve to one source in behaviour_compiled.R. Note also that all 13 Liu species already
# have Baker peak_workspace, so Liu adds no new species to the merge.

library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"
item_name   <- "Liu_etal_2016_TableS1"                     # registered in __ReadMe.xlsx (Sheet1)

# species resolver (single source of truth = _keys), identical to the sibling readers.
# Only used as a FALLBACK -- see note (3) above.
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

# ---- column resolution -------------------------------------------------------------------------
# Public TSV columns (confirmed 2026-08-05):
#   Species_Liu2016 | species_sci | specimen_key | museum | MC1 PP1 DP1 | MC2 PP2 IP2 DP2 | WS | GMI
#   | segment_sum_check
# Pick a column by trying the build's name first, then the printed SI header, so the reader works
# whether it is handed the analysis table or a re-export that kept the printed headers.
pick <- function(d, ...) { for (nm in c(...)) if (nm %in% names(d)) return(d[[nm]]); NULL }

printed_sp <- pick(d, "Species_Liu2016", "Species")            # printed name (invariant 3)
resolved   <- pick(d, "species_sci")                           # paper-scoped, written by the build
spec_key   <- pick(d, "specimen_key", "Key")                   # museum accession -- was the bug
museum_in  <- pick(d, "museum")
gmi        <- pick(d, "GMI")
ws         <- pick(d, "WS")

if (is.null(printed_sp)) stop("Liu reader: no printed-species column (Species_Liu2016 / Species)")
if (is.null(gmi) || is.null(ws)) stop("Liu reader: GMI and/or WS column missing from the TSV")

# species_sci: prefer the build's paper-scoped resolution; resolve only what is missing
species_sci <- if (!is.null(resolved)) trimws(resolved) else rep(NA_character_, nrow(d))
need <- is.na(species_sci) | !nzchar(species_sci)
if (any(need)) species_sci[need] <- vapply(printed_sp[need], resolve, character(1))

# museum: use the build's column, else parse the first token of the accession
if (is.null(museum_in) && !is.null(spec_key))
  museum_in <- sub("\\s.*$", "", trimws(spec_key))

# ---- guard: provenance must survive (this is the 2026-08-05 fix) -------------------------------
if (is.null(spec_key) || all(is.na(spec_key) | !nzchar(trimws(spec_key))))
  stop("Liu reader: specimen_key is empty for every row. SI Table S1 is specimen-level and the ",
       "museum accession is the provenance -- refusing to write a table without it. Check the ",
       "column name in the public TSV (build writes 'specimen_key'; the SI prints 'Key').")

out <- data.frame(
  species_sci          = species_sci,
  Species              = trimws(printed_sp),
  specimen_key         = trimws(spec_key),
  museum               = trimws(museum_in),
  Manipulability_index = gmi,          # GMI, the headline manipulative-potential measure
  Workspace            = ws,           # WS
  stringsAsFactors = FALSE, check.names = FALSE
)

# Fossil hands (SI Figure S6: Homo neanderthalensis, Ohalo II H2, Homo naledi) are NOT in Table S1 and
# are not read here. If they are ever added, keep them decomposable -- fossil Homo is a temporal grade,
# never pooled into an extant Homo sapiens mean.

write_xlsx(out, paste0(folder_path, "hand_liu.xlsx"))
cat("hand_liu.xlsx:", nrow(out), "specimen rows,",
    length(unique(out$species_sci)), "species,",
    sum(nzchar(out$specimen_key)), "with an accession;",
    length(unique(out$museum)), "museums\n")
