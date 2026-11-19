# Dupont_etal_2026_TableS3.R
#
# Purpose
#   Reformat the frozen supplement of Dupont, Klein, Metais & Toussaint (2026),
#   Proc. R. Soc. B 293: 20262257 (doi:10.1098/rspb.2026.2257), Table S3, into an
#   analysis-ready CSV: 205 extant mammal species x {four phalangeal indices (PI),
#   body mass, % time spent in trees, and the source of each}.
#
# Input   Dupont_etal_2026_TableS3_snapshot.xlsx   sheet "Table S3"
#         (untouched copy of the journal download rspb20262257_si_001.xlsx; the
#          other sheets are other tables and are ignored here)
#
# Outputs Dupont_etal_2026_TableS3.csv             one row per printed species
#         <Item encoded>.tsv in __Public/comparative-data/
#
# Units / conversions
#   PI columns        dimensionless indices, kept as printed.
#   BodymassKg        printed in kg; converted to g here (x 1000) -> Body_Mass.g
#   TimeArbo%         printed as a binned estimate with a tilde ("~25"); the tilde is
#                     dropped into Time_Arboreal_pct (numeric) and the printed string
#                     is kept in Time_Arboreal_printed.  It is an approximate category
#                     taken from Animal Diversity Web / literature, NOT a measurement.
#   "NA" cells        printed as the text NA -> missing (not zero).
#
# Species: the printed name (column "Species") is preserved verbatim, including its
# stray spaces.  Identity comes from the shared resolver and the paper-scoped rows in
# _keys/General/species_key.csv (source_publication = this folder).  The paper's
# "Species used in phylogenetic tree" column is a tree PROXY chosen by the authors
# (e.g. "Manis sp." -> a named species); it is kept as Tree_species and is never used
# as species identity.

suppressPackageStartupMessages({
  library(readxl)
})

options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Needs the full repo: __ReadMe.xlsx and _keys/ not found above ", folder)
paper <- basename(folder)                                # = source_publication in the species keys
setwd(folder)

source(file.path(base, "_keys", "resolve_species.R"))

## ---- helpers ---------------------------------------------------------------
squish <- function(x) trimws(gsub("[[:space:]]+", " ", ifelse(is.na(x), "", as.character(x))))
to_num <- function(x) {
  s <- squish(x)
  s[s %in% c("", "-", "NA", "n.a.")] <- NA_character_
  suppressWarnings(as.numeric(s))
}

## ---- read frozen snapshot --------------------------------------------------
snap <- as.data.frame(read_excel(paste0(item_name, "_snapshot.xlsx"), sheet = "Table S3",
                                 col_types = "text", .name_repair = "minimal"),
                      check.names = FALSE)
need <- c("Group", "Species", "Species used in phylogenetic tree", "PIForefootDigit1",
          "PIForefootDigits3and4", "PIHindfootDigit1", "PIHindfootDigits3and4",
          "BodymassKg", "Ref BodyMass", "TimeArbo%", "Ref TimeArbo")
if (!all(need %in% names(snap))) stop("Snapshot headers changed: ", paste(setdiff(need, names(snap)), collapse = ", "))
snap <- snap[!is.na(snap$Species) & nzchar(squish(snap$Species)), ]

## ---- species identity (shared resolver; stop if the paper's key rows are missing) ----
keyrows <- 0L
for (f in Sys.glob(file.path(base, "_keys", "*", "species_key.csv")))
  keyrows <- keyrows + sum(read.csv(f, stringsAsFactors = FALSE)$source_publication == paper, na.rm = TRUE)
if (keyrows == 0L) stop("No species_key rows for source_publication = ", paper)
sp <- resolve_species(snap$Species, source_publication = paper)

## ---- build -----------------------------------------------------------------
ta_printed <- squish(snap[["TimeArbo%"]])
final.dataframe <- data.frame(
  Group                    = squish(snap$Group),
  Species                  = snap$Species,                      # verbatim as printed
  species_sci              = sp$accepted_name,
  species_basis            = sp$species_basis,
  species_unresolved       = sp$unresolved,
  Tree_species             = squish(snap[["Species used in phylogenetic tree"]]),
  PI_forefoot_digit1       = to_num(snap$PIForefootDigit1),
  PI_forefoot_digits3and4  = to_num(snap$PIForefootDigits3and4),
  PI_hindfoot_digit1       = to_num(snap$PIHindfootDigit1),
  PI_hindfoot_digits3and4  = to_num(snap$PIHindfootDigits3and4),
  Body_Mass.g              = to_num(snap$BodymassKg) * 1000,    # kg x 1000 -> g
  Ref_Body_Mass            = squish(snap[["Ref BodyMass"]]),
  Time_Arboreal_pct        = to_num(sub("^~", "", ta_printed)),
  Time_Arboreal_printed    = ta_printed,
  Ref_Time_Arboreal        = squish(snap[["Ref TimeArbo"]]),
  stringsAsFactors = FALSE, check.names = FALSE
)

write.csv(final.dataframe, paste0(item_name, ".csv"), row.names = FALSE,
          na = "", fileEncoding = "UTF-8")

## ---- public TSV, named by the registry's Item encoded ----------------------
filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) {
  item_encoded <- "10.1098%2Frspb.2026.2257_TableS3"   # DOI-derived until the registry row is pasted
  warning("Item not yet in __ReadMe.xlsx; using DOI-derived name ", item_encoded)
}
tsv_dir <- file.path(base, "__Public", "comparative-data")
if (dir.exists(tsv_dir))
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t",
              row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")

cat(item_name, ":", nrow(final.dataframe), "rows;",
    sum(final.dataframe$species_unresolved, na.rm = TRUE), "species unresolved\n")
