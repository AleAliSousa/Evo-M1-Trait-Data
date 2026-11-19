# Dupont_etal_2026_TableS2.R
#
# Purpose
#   Reformat the frozen supplement of Dupont, Klein, Metais & Toussaint (2026),
#   Proc. R. Soc. B 293: 20262257 (doi:10.1098/rspb.2026.2257), Table S2, into an
#   analysis-ready CSV: 49 fossil / extinct taxa, ONE SPECIMEN each, with four phalangeal
#   indices (PI) measured on that specimen, a body-mass value and the authors' inferred
#   % time arboreal (point estimate, lower and upper bound) for each PI.
#
# Input   Dupont_etal_2026_TableS2_snapshot.xlsx   sheet "Table S2"
#         (untouched copy of the journal download rspb20262257_si_001.xlsx; the
#          other sheets are other tables and are ignored here)
#
# Outputs Dupont_etal_2026_TableS2.csv             one row per printed specimen/taxon
#         <Item encoded>.tsv in __Public/comparative-data/
#
# Units / conversions
#   PI columns        dimensionless indices, kept as printed.
#   BodymassKg        printed in kg (one value uses a decimal comma and a ">" bound:
#                     ">0,03"); converted to g (x 1000) -> Body_Mass.g, with the bound
#                     kept in Body_Mass_bound (">" = at least).  Body mass of fossils is
#                     an estimate cited by the authors, not a measurement.
#   TimeArbo*         the authors' MODEL-DERIVED inference (% of time arboreal) from each PI;
#                     kept as printed, with lwr/upr bounds.  Not an observation.
#   "NA" cells        printed as the text NA -> missing (not zero).
#
# Species: the printed name is preserved verbatim.  Identity comes from the shared
# resolver and paper-scoped rows in _keys/General/species_key.csv.  Fossil taxa are
# mostly absent from the extant species hub; they stay species_unresolved = TRUE until a
# taxonomic authority (GBIF/PBDB/source paper) is recorded.  Do NOT pool these rows with
# extant species values; they enter no merge.

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
snap <- as.data.frame(read_excel(paste0(item_name, "_snapshot.xlsx"), sheet = "Table S2",
                                 col_types = "text", .name_repair = "minimal"),
                      check.names = FALSE)
ta <- c("TimeArboPIH1", "TimeArboPIH1lwr", "TimeArboPIH1upr", "TimeArboPIH34", "TimeArboPIH34lwr",
        "TimeArboPIH34upr", "TimeArboPIF1", "TimeArboPIF1lwr", "TimeArboPIF1upr", "TimeArboPIF34",
        "TimeArboPIF34lwr", "TimeArboPIF34upr")
need <- c("Group", "Species", "Origin", "Specimen identification", "PIForefootDigit1",
          "PIForefootDigits3and4", "PIHindfootDigit1", "PIHindfootDigits3and4",
          "BodymassKg", "Ref Bodymass", ta)
if (!all(need %in% names(snap))) stop("Snapshot headers changed: ", paste(setdiff(need, names(snap)), collapse = ", "))
snap <- snap[!is.na(snap$Species) & nzchar(squish(snap$Species)), ]

## ---- species identity (shared resolver; stop if the paper's key rows are missing) ----
keyrows <- 0L
for (f in Sys.glob(file.path(base, "_keys", "*", "species_key.csv")))
  keyrows <- keyrows + sum(read.csv(f, stringsAsFactors = FALSE)$source_publication == paper, na.rm = TRUE)
if (keyrows == 0L) stop("No species_key rows for source_publication = ", paper)
sp <- resolve_species(snap$Species, source_publication = paper)

## ---- build -----------------------------------------------------------------
bm_printed <- squish(snap$BodymassKg)
bm_num <- to_num(sub(",", ".", sub("^>", "", bm_printed), fixed = TRUE))
final.dataframe <- data.frame(
  Group                    = squish(snap$Group),
  Species                  = snap$Species,                      # verbatim as printed
  species_sci              = sp$accepted_name,
  species_basis            = sp$species_basis,
  species_unresolved       = sp$unresolved,
  Origin                   = squish(snap$Origin),
  Specimen_ID              = squish(snap[["Specimen identification"]]),
  PI_forefoot_digit1       = to_num(snap$PIForefootDigit1),
  PI_forefoot_digits3and4  = to_num(snap$PIForefootDigits3and4),
  PI_hindfoot_digit1       = to_num(snap$PIHindfootDigit1),
  PI_hindfoot_digits3and4  = to_num(snap$PIHindfootDigits3and4),
  Body_Mass.g              = bm_num * 1000,                     # kg x 1000 -> g
  Body_Mass_bound          = ifelse(grepl("^>", bm_printed), ">", ""),
  Ref_Body_Mass            = squish(snap[["Ref Bodymass"]]),
  stringsAsFactors = FALSE, check.names = FALSE
)
nm <- c("TimeArbo_PI_hindfoot_digit1", "TimeArbo_PI_hindfoot_digit1_lwr", "TimeArbo_PI_hindfoot_digit1_upr",
        "TimeArbo_PI_hindfoot_digits3and4", "TimeArbo_PI_hindfoot_digits3and4_lwr", "TimeArbo_PI_hindfoot_digits3and4_upr",
        "TimeArbo_PI_forefoot_digit1", "TimeArbo_PI_forefoot_digit1_lwr", "TimeArbo_PI_forefoot_digit1_upr",
        "TimeArbo_PI_forefoot_digits3and4", "TimeArbo_PI_forefoot_digits3and4_lwr", "TimeArbo_PI_forefoot_digits3and4_upr")
for (k in seq_along(ta)) final.dataframe[[nm[k]]] <- to_num(snap[[ta[k]]])

write.csv(final.dataframe, paste0(item_name, ".csv"), row.names = FALSE,
          na = "", fileEncoding = "UTF-8")

## ---- public TSV, named by the registry's Item encoded ----------------------
filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded)) {
  item_encoded <- "10.1098%2Frspb.2026.2257_TableS2"   # DOI-derived until the registry row is pasted
  warning("Item not yet in __ReadMe.xlsx; using DOI-derived name ", item_encoded)
}
tsv_dir <- file.path(base, "__Public", "comparative-data")
if (dir.exists(tsv_dir))
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t",
              row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")

cat(item_name, ":", nrow(final.dataframe), "rows;",
    sum(final.dataframe$species_unresolved, na.rm = TRUE), "species unresolved\n")
