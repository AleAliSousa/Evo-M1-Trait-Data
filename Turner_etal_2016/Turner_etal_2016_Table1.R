## Turner, Young, Reed, Collins, Flaherty, Gabi & Kaas 2016, Brain Behav Evol 88(1):1-13 — Table 1
## doi:10.1159/000446762 · Team Kaas (Vanderbilt) · flattened neocortex + flow fractionator.
## "Distributions of cells and neurons across the cortical sheet in Old World macaques."
## Table 1 ("Summary of experimental cases") is the SPECIMEN table: case, species, age, sex,
## hemisphere, brain weight (g) and BRAIN SURFACE AREA (cm2) for 4 macaque hemispheres + 2 baboons.
## The surface area is the trait this paper contributes to __merging_cortical_areas
## (`CorticalSurface_Area.mm2`, whole cortex, per hemisphere, manually flattened, ImageJ).
##
## SPECIMEN FLAGS (carried on the rows, see `specimen_overlap` / `dedupe_status`):
##   - case 9-27 (PHX) is the SAME baboon as Collins et al. 2010 Dataset S1 case 09-27
##     (Collins' cortical surface 18577 mm2 vs 18600 mm2 here) -> `exclude_duplicate_Collins2010`,
##     so the merge does not double-count that specimen.
##   - case 11-31 (PHA) also appears in Young et al. 2013b, which is excluded from the merges;
##     Turner is therefore the merged surface source for it -> `include`.
##   - case 10-50 (M. mulatta) is a DIFFERENT specimen from Finlay et al. 2006's macaque; both are
##     kept and the disagreement is flagged downstream, not averaged away silently.
##   - case 12-58 is ONE specimen measured in both hemispheres (LH + RH) -> two rows here; the
##     merge averages them to a single per-hemisphere value (aggregation belongs downstream, §3).
##
## Source is the PRINTED table in the PDF, so the frozen copy is the hand-verified snapshot
## `Turner_etal_2016_Table1_snapshot.xlsx` (sheet "Table1"); all cleaning happens here (golden rule).
## Species names: printed name kept as `Species_Turner2016`; accepted binomial resolved from the
## single source of truth `_keys/Stephan/species_key.csv` (token `Turner2016`) — no inline fixes (§5).

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))            # Turner_etal_2016_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

## ---- read the frozen snapshot POSITIONALLY (row 1 caption, row 2 header, row 10 footnote) ----
pos <- c("case_printed", "species_printed", "age_years", "sex", "hemisphere",
         "brain_weight_g", "brain_surface_area_cm2")
raw <- as.data.frame(read_excel("Turner_etal_2016_Table1_snapshot.xlsx", sheet = "Table1",
                                col_names = FALSE, col_types = "text"))
raw <- raw[-(1:2), seq_along(pos), drop = FALSE]                 # drop caption + header rows
names(raw) <- pos

strip <- function(x) trimws(gsub(" ", " ", as.character(x)))          # kill non-breaking spaces
num   <- function(x) suppressWarnings(as.numeric(gsub(",", "", strip(x)))) # thousands separators
raw <- raw[!is.na(num(raw$brain_surface_area_cm2)), ]             # keeps data rows only: drops the
                                                                  # blank row and the footnote row

## ---- accepted species names from the shared key (printed name is preserved) ----
species_printed <- strip(raw$species_printed)
key_file <- if (!is.na(base)) file.path(base, "_keys", "Stephan", "species_key.csv") else NA_character_
Species  <- NA_character_
if (!is.na(key_file) && file.exists(key_file)) {
  key <- read.csv(key_file, stringsAsFactors = FALSE, check.names = FALSE)
  key <- key[key$source_publication == "Turner2016", ]
  lk  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
  Species <- unname(lk[tolower(species_printed)])
}
if (any(is.na(Species)))
  stop("species_key.csv (token Turner2016) is missing: ",
       paste(unique(species_printed[is.na(Species)]), collapse = ", "))

## ---- printed footnotes -> their own columns (never folded into the values) ----
case_number <- sub(" (LH|RH)$", "", strip(raw$case_printed))      # "12-58 LH" -> "12-58"
taxon_note <- c(
  PHX = "PHX = P. hamadryas anubis/cyncephalus hybrid (printed spelling; = cynocephalus) - table footnote",
  PHA = "PHA = P. hamadryas anubis - table footnote")[species_printed]
case_note <- ifelse(case_number == "12-58",
                    "table footnote: frontal eye field and surrounding areas are missing",
             ifelse(case_number == "10-50",
                    "table footnote: A-P coordinates could not be obtained", NA_character_))
specimen_overlap <- c(
  "9-27"  = paste0("same specimen as Collins_etal_2010_DatasetS1 case 09-27 ",
                   "(Collins cortical surface 18577 mm2 vs 18600 mm2 here)"),
  "11-31" = paste0("also appears in Young_etal_2013_b (excluded from merges); ",
                   "Turner is the merged surface source for this baboon"),
  "10-50" = "different individual from the Finlay_etal_2006_Table6.1 macaque (both kept, flagged)",
  "12-58" = "one specimen, two hemispheres (LH + RH rows); average to one per-hemisphere value"
  )[case_number]
dedupe_status <- ifelse(case_number == "9-27", "exclude_duplicate_Collins2010", "include")

## ---- project units: brain surface cm2 x100 -> mm2; brain weight g x1000 -> mg (§6) ----
clean <- data.frame(
  Species                    = Species,
  Species_Turner2016         = species_printed,
  case                       = strip(raw$case_printed),
  case_number                = case_number,
  hemisphere                 = strip(raw$hemisphere),
  age_years                  = num(raw$age_years),
  sex                        = strip(raw$sex),
  brain_weight_g             = num(raw$brain_weight_g),
  `Brain_Mass.mg`            = num(raw$brain_weight_g) * 1000,
  brain_surface_area_cm2     = num(raw$brain_surface_area_cm2),
  `CorticalSurface_Area.mm2` = num(raw$brain_surface_area_cm2) * 100,
  taxon_note                 = unname(taxon_note),
  case_note                  = case_note,
  specimen_overlap           = unname(specimen_overlap),
  dedupe_status              = dedupe_status,
  source                     = item_name,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(nrow(clean) == 6L, !any(is.na(clean$`CorticalSurface_Area.mm2`)))

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " case rows written")

## ---- public TSV, named by `Item encoded` looked up in __ReadMe.xlsx (invariant 2, §4) ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]     # 10.1159%2F000446762_Table1
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")),
                sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
