# Baron_etal_1983_Table1.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of Baron et al. 1983
#   Table 1 into a lean, analysis-ready CSV: species codes, anatomy code, old
#   and current species names, the sample size with its marker, and the values.
#   Column meanings, units and legend symbols live in the definitions table
#   (reference_tables/Baron_etal_1983_definitions.csv), not in this data table.
#
# Inputs
#   Baron_etal_1983_Table1_snapshot.xlsx           sheet: Table1_snapshot (values)
#   reference_tables/Baron_etal_1983_species_crosswalk.csv   current names by code
#
# Outputs
#   Baron_etal_1983_Table1.csv                     one row per species (76 rows)
#   <DOI>.tsv in __Public/comparative-data/        tab-separated copy named by the
#                                                  item's encoded DOI (from __ReadMe.xlsx)
#
# Fixes applied here are only the obvious ones: drop Baron's footnote digits,
# complete his abbreviations, parse values to numbers. Superscript footnotes are
# TRANSLATED into the former Stephan-1981a name (Species_former_synonym) rather
# than kept as bare digits. Current names come from the species crosswalk.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(tibble)
})

snapshot_file  <- "Baron_etal_1983_Table1_snapshot.xlsx"
snapshot_sheet <- "Table1_snapshot"
crosswalk_file <- file.path("reference_tables", "Baron_etal_1983_species_crosswalk.csv")
output_file    <- "Baron_etal_1983_Table1.csv"

# ---- helpers ---------------------------------------------------------------

read_snapshot <- function(path, sheet) {
  raw <- read_excel(path, sheet = sheet, col_names = FALSE,
                    col_types = "text", na = c(""))
  header <- as.character(unlist(raw[2, ], use.names = FALSE))
  dat <- raw[-c(1, 2), , drop = FALSE]
  names(dat) <- header
  dat
}
read_text_csv <- function(path) read_csv(path, col_types = cols(.default = col_character()), na = c(""))

norm_code     <- function(x) suppressWarnings(as.integer(str_remove_all(as.character(x), "\\D")))
parse_value   <- function(x) parse_number(x, na = c("", "-", "NA", "n.a.", "__"))
strip_footnote <- function(x) str_squish(str_remove_all(x, "[0-9]+"))   # drop Baron footnote digits
footnote_num  <- function(x) str_match(x, "([0-9]+)\\s*$")[, 2]
has_marker    <- function(x, marker) str_detect(replace_na(x, ""), fixed(marker))

# Obvious completions of Baron's own abbreviations (do not change taxonomy).
abbrev_fixes <- c(
  "Hemicentetes semispin."  = "Hemicentetes semispinosus",
  "Daubentonia madagascar." = "Daubentonia madagascariensis",
  "Avahi l. occidentalis"   = "Avahi laniger occidentalis"
)
complete_name <- function(x) ifelse(x %in% names(abbrev_fixes), abbrev_fixes[x], x)

# Footnote legend, transcribed from the Table 1 footnotes: the superscript
# number is the name used in former papers and in Stephan et al. (1981a).
footnote_synonym <- c(
  "1"  = "Aethechinus algirus",
  "2"  = "Crocidura occidentalis",
  "3"  = "Nesogale dobsoni",
  "4"  = "Nesogale talazaci",
  "5"  = "Chlorotalpa stuhlmanni",
  "6"  = "Lemur fulvus",
  "7"  = "Lemur variegatus",
  "8"  = "Galago crassicaudatus",
  "9"  = "Galago demidovii",
  "10" = "Saguinus tamarin",
  "11" = "Cercopithecus talapoin",
  "12" = "Rhynchocyon stuhlmanni"
)

# ---- snapshot: the 76 four-digit species rows ------------------------------

snap <- read_snapshot(snapshot_file, snapshot_sheet) %>%
  rename(code_raw = `code number of species`, species_raw = `species name`, n_raw = n) %>%
  filter(!is.na(code_raw) & str_detect(code_raw, "^[0-9]{4}$")) %>%
  mutate(code_join = norm_code(code_raw))

# ---- current names from the species crosswalk (by code) --------------------

if (file.exists(crosswalk_file)) {
  new_names <- read_text_csv(crosswalk_file) %>%
    transmute(code_join = norm_code(code_Baron1983), Species = Species_MDD_v2_4)
  snap <- left_join(snap, new_names, by = "code_join")
} else {
  warning("Crosswalk not found at '", crosswalk_file,
          "'; 'Species' (current name) will fall back to the Baron name.")
  snap$Species <- NA_character_
}

# ---- assemble the lean table -----------------------------------------------

# Locate the two per-mille columns by keyword, so the exact per-mille symbol in
# the snapshot header (%0, 0/00, or the true per-mille sign) doesn't matter.
col_pm_netbrain <- grep("net brain",     names(snap), ignore.case = TRUE, value = TRUE)[1]
col_pm_telen    <- grep("telencephalon", names(snap), ignore.case = TRUE, value = TRUE)[1]
if (is.na(col_pm_netbrain) || is.na(col_pm_telen))
  stop("Could not find the per-mille columns ('net brain' / 'telencephalon') in the snapshot header.")

final.dataframe <- snap %>%
  transmute(
    code_Baron1983         = code_raw,
    Anatomy_code           = "MOB",
    Species_Baron1983      = complete_name(strip_footnote(species_raw)),     # old name, no superscript
    Species                = coalesce(Species, complete_name(strip_footnote(species_raw))),  # current name
    Species_former_synonym = unname(footnote_synonym[footnote_num(species_raw)]),  # superscript translated
    n                      = as.integer(parse_value(n_raw)),
    n_note                 = if_else(has_marker(n_raw, "*"), "*", NA_character_),
    volume_mm3             = parse_value(`volume in mm3`),
    volume_note            = if_else(has_marker(`volume in mm3`, "+"), "+", NA_character_),
    SEM_pct                = parse_value(`SEM in %`),
    size_index             = parse_value(`size index`),
    permille_net_brain     = parse_value(.data[[col_pm_netbrain]]),
    permille_telencephalon = parse_value(.data[[col_pm_telen]])
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder --------
# Mirrors the save step used across this dataset (see JardimMesseder_etal_2017):
# write the analysis CSV next to the script, and a tab-separated copy named by
# the item's encoded DOI (looked up in the master __ReadMe.xlsx) into the shared
# comparative-data folder.

# Item name = this script's file name without ".R" (when run from RStudio);
# falls back to the output_file stem if rstudioapi is unavailable.
item_name <- tryCatch(
  gsub("\\.R$", "", basename(rstudioapi::getActiveDocumentContext()$path)),
  error = function(e) tools::file_path_sans_ext(output_file)
)
if (is.null(item_name) || !nzchar(item_name)) item_name <- tools::file_path_sans_ext(output_file)

# 1) Local CSV (the final analysis table).
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

# 2) DOI-named TSV copy in the shared comparative-data folder.
readme_file <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx"
tsv_dir     <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/"
filecodes    <- read_excel(readme_file, sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_dir, item_encoded, ".tsv")
}

message("Footnote synonyms translated: ", sum(!is.na(final.dataframe$Species_former_synonym)),
        " | current names filled: ", sum(!is.na(final.dataframe$Species)))
