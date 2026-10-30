# Heffner_Masterton_1983_TableI.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of Heffner & Masterton 1983
#   Table I (Brain Behav Evol 23:165-183) into a lean, analysis-ready CSV.
#   Everything in the output comes from the paper via the snapshot only -- no
#   crosswalk, no comparison files. Column meanings, units and legend symbols are
#   documented in the definitions table
#   (reference_tables/Heffner_Masterton_1983_TableI_definitions.csv), not here.
#
# Input
#   Heffner_Masterton_1983_TableI_snapshot.xlsx     sheet: TableI_snapshot
#
# Outputs
#   Heffner_Masterton_1983_TableI.csv               one row per species row (21 rows)
#   <DOI>.tsv in __Public/comparative-data/         tab-separated copy named by the
#                                                   item's encoded DOI (from __ReadMe.xlsx)
#
# Cleaning is limited to what is defensible from the print: each measurement cell
# is split into a numeric value and its bracketed [reference]; numbers are parsed;
# common names are moved to `common_name` and the binomial to `Species`. Two
# obvious transcription typos are corrected in `Species` while the exact printed
# string is preserved verbatim in `Species_as_printed`. Taxonomy is NOT modernised.

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(stringr)
  library(tidyr)      # replace_na()
})

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
setwd(folder)

snapshot_file  <- "Heffner_Masterton_1983_TableI_snapshot.xlsx"
snapshot_sheet <- "TableI_snapshot"

# ---- helpers ---------------------------------------------------------------

# The snapshot carries a title in row 1 and the column names in row 2.
read_snapshot <- function(path, sheet) {
  raw <- read_excel(path, sheet = sheet, col_names = FALSE, col_types = "text", na = c(""))
  header <- as.character(unlist(raw[2, ], use.names = FALSE))
  dat <- raw[-c(1, 2), , drop = FALSE]
  names(dat) <- header
  dat[!is.na(dat$common_name) | !is.na(dat$species), , drop = FALSE]
}

# Split a "value [reference]" cell into its numeric value and its bracketed source.
val_of <- function(x) str_trim(str_replace(replace_na(x, ""), "\\[.*$", ""))
ref_of <- function(x) { m <- str_extract(replace_na(x, ""), "\\[.*\\]"); ifelse(is.na(m), "", m) }
as_num <- function(x) suppressWarnings(as.numeric(str_replace_all(val_of(x), ",", "")))

# Species typos are corrected via the crosswalk file (applied after the table is
# assembled): reference_tables/<item>_species_crosswalk.csv. Taxonomy NOT modernised;
# genus-only entries (Paraechinus, Didelphis, Tarsius) are kept as printed.

# ---- assemble the lean table (snapshot only) -------------------------------

snap <- read_snapshot(snapshot_file, snapshot_sheet)

# Extract the bracketed references before transmute() replaces the source text
# columns with parsed numerics. Otherwise later expressions with the same column
# name see the newly created numeric vector and lose the source reference.
snap <- snap %>%
  mutate(
    area_mm2_ref = ref_of(area_mm2),
    no_fibers_x10_3_ref = ref_of(no_fibers_x10_3),
    avg_fiber_size_um_ref = ref_of(avg_fiber_size_um),
    largest_fiber_size_um_ref = ref_of(largest_fiber_size_um),
    extension_down_cord_rank_ref = ref_of(extension_down_cord_rank),
    ventralmost_lamina_ref = ref_of(ventralmost_lamina),
    densest_lamina_ref = ref_of(densest_lamina)
  )

final.dataframe <- snap %>%
  transmute(
    common_name              = str_squish(common_name),
    Species                  = str_squish(species),         # printed; resolved via crosswalk below
    Species_as_printed       = str_squish(species),
    species_basis            = NA_character_,                # provenance, filled by the crosswalk
    phyletic_level           = as.integer(as_num(phyletic_level)),
    digital_dexterity        = as.integer(as_num(digital_dexterity)),
    body_weight_kg           = as_num(body_weight_kg),
    area_mm2                 = as_num(area_mm2),
    area_mm2_ref             = area_mm2_ref,
    no_fibers_x10_3          = as_num(no_fibers_x10_3),
    no_fibers_x10_3_ref      = no_fibers_x10_3_ref,
    avg_fiber_size_um        = as_num(avg_fiber_size_um),
    avg_fiber_size_um_ref    = avg_fiber_size_um_ref,
    largest_fiber_size_um    = as_num(largest_fiber_size_um),
    largest_fiber_size_um_ref = largest_fiber_size_um_ref,
    extension_down_cord_rank = as_num(extension_down_cord_rank),
    extension_down_cord_rank_ref = extension_down_cord_rank_ref,
    ventralmost_lamina       = as_num(ventralmost_lamina),
    ventralmost_lamina_ref   = ventralmost_lamina_ref,
    densest_lamina           = as_num(densest_lamina),
    densest_lamina_ref       = densest_lamina_ref,
    source                   = "Heffner_Masterton_1983"
  )

options(scipen = 999)

## ---- species crosswalk: correct typos + impute genus-only names (Iwaniuk 1999 + spelling) ----
## Single source of truth: reference_tables/<item>_species_crosswalk.csv. Species_as_printed is
## kept verbatim; Species is overwritten for matches; species_basis records the provenance.
final.dataframe$species_basis <- ifelse(is.na(final.dataframe$Species_as_printed) |
                                          final.dataframe$Species_as_printed == "",
                                        "unspecified_in_source", "as_printed")
xwalk_file <- file.path(folder, "reference_tables", paste0(item_name, "_species_crosswalk.csv"))
if (file.exists(xwalk_file)) {
  xw <- read.csv(xwalk_file, stringsAsFactors = FALSE, check.names = FALSE)
  sp <- xw[xw$match_on == "species", , drop = FALSE]
  h  <- match(final.dataframe$Species_as_printed, sp$key); ok <- !is.na(h)
  final.dataframe$Species[ok]       <- sp$Species[h[ok]]
  final.dataframe$species_basis[ok] <- sp$basis[h[ok]]
  message("Species crosswalk: ", sum(ok), " name(s) resolved")
}

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder --------

write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

message("Rows: ", nrow(final.dataframe),
        " | species typos corrected: ", sum(final.dataframe$Species != final.dataframe$Species_as_printed))
