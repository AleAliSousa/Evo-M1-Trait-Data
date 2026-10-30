# Baron_etal_1983_Table1.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of Baron et al. 1983
#   Table 1 into a lean, analysis-ready CSV. Everything in the output comes
#   from the paper via the snapshot only -- no crosswalk, no comparison files.
#   Column meanings, units and legend symbols are documented in the definitions
#   table (reference_tables/Baron_etal_1983_definitions.csv), not in the data.
#
# Input
#   Baron_etal_1983_Table1_snapshot.xlsx           sheet: Table1_snapshot
#
# Outputs
#   Baron_etal_1983_Table1.csv                     one row per species (76 rows)
#   <DOI>.tsv in __Public/comparative-data/        tab-separated copy named by the
#                                                  item's encoded DOI (from __ReadMe.xlsx)
#
# Only obvious in-place fixes are applied: drop Baron's footnote digits,
# complete his abbreviations, parse values to numbers. The superscript footnote
# is TRANSLATED into the former Stephan-1981a name (Species_former_synonym),
# which is information printed in the paper's own Table 1 legend.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
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

snapshot_file  <- "Baron_etal_1983_Table1_snapshot.xlsx"
snapshot_sheet <- "Table1_snapshot"
output_file    <- "Baron_etal_1983_Table1.csv"

# ---- helpers ---------------------------------------------------------------

read_snapshot <- function(path, sheet) {
  raw <- read_excel(path, sheet = sheet, col_names = FALSE, col_types = "text", na = c(""))
  header <- as.character(unlist(raw[2, ], use.names = FALSE))
  dat <- raw[-c(1, 2), , drop = FALSE]
  names(dat) <- header
  dat
}
parse_value    <- function(x) parse_number(x, na = c("", "-", "NA", "n.a.", "__"))
strip_footnote <- function(x) str_squish(str_remove_all(x, "[0-9]+"))   # drop Baron footnote digits
footnote_num   <- function(x) str_match(x, "([0-9]+)\\s*$")[, 2]
has_marker     <- function(x, marker) str_detect(replace_na(x, ""), fixed(marker))

# Obvious completions of Baron's own abbreviations (do not change taxonomy).
abbrev_fixes <- c(
  "Hemicentetes semispin."  = "Hemicentetes semispinosus",
  "Daubentonia madagascar." = "Daubentonia madagascariensis",
  "Avahi l. occidentalis"   = "Avahi laniger occidentalis"
)
complete_name <- function(x) ifelse(x %in% names(abbrev_fixes), abbrev_fixes[x], x)

# Footnote legend, transcribed from the paper's Table 1 footnotes: the
# superscript number is the name used in former papers / Stephan et al. (1981a).
footnote_synonym <- c(
  "1"  = "Aethechinus algirus",  "2"  = "Crocidura occidentalis",
  "3"  = "Nesogale dobsoni",     "4"  = "Nesogale talazaci",
  "5"  = "Chlorotalpa stuhlmanni","6" = "Lemur fulvus",
  "7"  = "Lemur variegatus",     "8"  = "Galago crassicaudatus",
  "9"  = "Galago demidovii",     "10" = "Saguinus tamarin",
  "11" = "Cercopithecus talapoin","12" = "Rhynchocyon stuhlmanni"
)

# ---- snapshot: the 76 four-digit species rows ------------------------------

snap <- read_snapshot(snapshot_file, snapshot_sheet) %>%
  rename(code_raw = `code number of species`, species_raw = `species name`, n_raw = n) %>%
  filter(!is.na(code_raw) & str_detect(code_raw, "^[0-9]{4}$"))

# Locate the two per-mille columns by keyword, so the exact per-mille symbol in
# the snapshot header (%0, 0/00, or the true per-mille sign) doesn't matter.
col_pm_netbrain <- grep("net brain",     names(snap), ignore.case = TRUE, value = TRUE)[1]
col_pm_telen    <- grep("telencephalon", names(snap), ignore.case = TRUE, value = TRUE)[1]
if (is.na(col_pm_netbrain) || is.na(col_pm_telen))
  stop("Could not find the per-mille columns ('net brain' / 'telencephalon') in the snapshot header.")

# ---- assemble the lean table (snapshot only) -------------------------------

final.dataframe <- snap %>%
  transmute(
    code_Baron1983         = code_raw,
    Anatomy_code           = "MOB",
    Species      = complete_name(strip_footnote(species_raw)),     # footnote digits dropped, abbreviations completed
    Species_former_synonym = unname(footnote_synonym[footnote_num(species_raw)]),  # superscript footnote translated
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
        " | footnote synonyms translated: ", sum(!is.na(final.dataframe$Species_former_synonym)))
