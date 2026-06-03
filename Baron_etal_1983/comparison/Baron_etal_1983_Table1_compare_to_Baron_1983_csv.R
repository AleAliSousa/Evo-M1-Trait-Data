# Baron_etal_1983_Table1_compare_to_Baron_1983_csv.R
#
# Purpose
#   Audit the formatted CSV (Baron_1983.csv) against the faithful snapshot of
#   Baron et al. 1983 Table 1, AND against the current taxonomy crosswalk.
#   Rows are matched by Baron code, then three things are checked separately:
#     1. measured values  - n and MOB volume (numeric)
#     2. faithful name     - snapshot original vs CSV's Species_Baron1983
#                            (a difference here is a TRANSCRIPTION TYPO)
#     3. taxonomy currency - CSV's updated Species vs the MDD-accepted name in
#                            the crosswalk (a difference here is an OUT-OF-DATE
#                            or non-standard NAME, i.e. a legitimate taxonomic
#                            update, not a transcription error)
#   Separating (2) and (3) is the point of this revision: a name that changed
#   because of a genus reassignment is reported as a taxonomy update, not lumped
#   in with data-entry mistakes.
#
# Inputs
#   Baron_etal_1983_Table1_snapshot.xlsx     sheet: Table1_snapshot
#   Baron_1983.csv                           formatted comparison table
#   Baron_etal_1983_species_crosswalk.csv    current taxonomy (MDD v2.4)
#
# Outputs
#   Baron_etal_1983_Table1_comparison_report_from_R.csv      every row, all checks
#   Baron_etal_1983_Table1_comparison_mismatches_from_R.csv  rows needing attention
#
# Encoding fix retained: Baron_1983.csv is read with latin1 so the stray 0xCA
# byte in "Scutisorex somereni" cannot silently truncate the read.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(tibble)
})

snapshot_file     <- "../Baron_etal_1983_Table1_snapshot.xlsx"
snapshot_sheet    <- "Table1_snapshot"
comparison_file   <- "Baron_1983.csv"
# Taxonomy reference table (per-paper, staged for the next compilation step).
crosswalk_file    <- file.path("reference_tables", "Baron_etal_1983_species_crosswalk.csv")
output_detail     <- "Baron_etal_1983_Table1_comparison_report_from_R.csv"
output_mismatches <- "Baron_etal_1983_Table1_comparison_mismatches_from_R.csv"

# ---- helpers ---------------------------------------------------------------

read_snapshot <- function(path, sheet) {
  raw <- read_excel(path, sheet = sheet, col_names = FALSE,
                    col_types = "text", na = c(""))
  header <- as.character(unlist(raw[2, ], use.names = FALSE))
  dat <- raw[-c(1, 2), , drop = FALSE]
  names(dat) <- header
  dat
}

# Baron_1983.csv: latin1 so every byte is read (avoids 0xCA truncation).
read_baron_csv <- function(path) {
  read_csv(path, locale = locale(encoding = "latin1"),
           col_types = cols(.default = col_character()), na = c(""))
}
# Crosswalk: plain UTF-8.
read_text_csv <- function(path) {
  read_csv(path, col_types = cols(.default = col_character()), na = c(""))
}

norm_code   <- function(x) suppressWarnings(as.integer(str_remove_all(as.character(x), "\\D")))
parse_value <- function(x) parse_number(x, na = c("", "-", "NA", "n.a.", "__"))
norm_label  <- function(x) {
  x <- str_remove_all(x, "[0-9]+")
  x <- str_remove_all(x, "\\.")
  str_squish(tolower(x))
}
num_match <- function(a, b, tol = 1e-8) {
  (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) <= tol)
}

# ---- read the three sources ------------------------------------------------

snap_species <- read_snapshot(snapshot_file, snapshot_sheet) %>%
  rename(code_raw = `code number of species`, species_raw = `species name`) %>%
  filter(!is.na(code_raw) & str_detect(code_raw, "^[0-9]{4}$")) %>%
  transmute(
    code_join           = norm_code(code_raw),
    code_snapshot       = code_raw,
    species_snapshot    = species_raw,
    n_snapshot          = n,
    n_snapshot_num      = as.integer(parse_value(n)),
    volume_snapshot     = `volume in mm3`,
    volume_snapshot_num = parse_value(`volume in mm3`),
    sp_snapshot_norm    = norm_label(species_raw)
  )

comparison <- read_baron_csv(comparison_file) %>%
  filter(!str_detect(replace_na(Species, ""), "^AAAA_")) %>%
  filter(!is.na(Bulbus_olfactorius_1983)) %>%
  transmute(
    code_join             = norm_code(code_Baron1983),
    code_csv              = code_Baron1983,
    species_csv_baron1983 = Species_Baron1983,
    species_csv_updated   = Species,
    n_csv                 = Number_of_individuals_Bulbus_olfactorius,
    n_csv_num             = as.integer(parse_value(Number_of_individuals_Bulbus_olfactorius)),
    volume_csv            = Bulbus_olfactorius_1983,
    volume_csv_num        = parse_value(Bulbus_olfactorius_1983),
    sp_csv_baron_norm     = norm_label(Species_Baron1983)
  )

# Taxonomy reference table is optional: if it is absent, the snapshot-vs-CSV
# value and faithful-name checks still run; only the MDD-currency check is skipped.
if (file.exists(crosswalk_file)) {
  crosswalk <- read_text_csv(crosswalk_file) %>%
    transmute(
      code_join     = norm_code(code_Baron1983),
      species_mdd   = Species_MDD_v2_4,
      name_change   = name_change,
      sp_mdd_norm   = norm_label(Species_MDD_v2_4)
    )
} else {
  message("Reference table not found at '", crosswalk_file,
          "'; skipping the taxonomy-currency (MDD) check.")
  crosswalk <- tibble(code_join = integer(0), species_mdd = character(0),
                      name_change = character(0), sp_mdd_norm = character(0))
}

# ---- match by code and run the three checks --------------------------------

report <- snap_species %>%
  full_join(comparison, by = "code_join") %>%
  left_join(crosswalk, by = "code_join") %>%
  mutate(
    status = case_when(
      is.na(code_snapshot) ~ "csv_value_row_missing_from_snapshot",
      is.na(code_csv)      ~ "snapshot_row_missing_from_csv",
      TRUE                 ~ "matched_by_code"
    ),
    n_match      = num_match(n_snapshot_num, n_csv_num),
    volume_match = num_match(volume_snapshot_num, volume_csv_num),
    # (2) faithful-name agreement: snapshot original vs CSV Species_Baron1983
    faithful_name_match = if_else(status == "matched_by_code",
                                  sp_snapshot_norm == sp_csv_baron_norm, NA),
    # (3) taxonomy currency: CSV updated name vs MDD-accepted name
    csv_updated_matches_mdd = if_else(!is.na(sp_csv_baron_norm) & !is.na(sp_mdd_norm),
                                      norm_label(species_csv_updated) == sp_mdd_norm, NA)
  ) %>%
  rowwise() %>%
  mutate(
    flag_reason = {
      r <- character(0)
      if (status != "matched_by_code") r <- c(r, status)
      if (isFALSE(n_match))      r <- c(r, "n differs")
      if (isFALSE(volume_match)) r <- c(r, "volume differs")
      if (isFALSE(faithful_name_match))     r <- c(r, "faithful-name transcription typo in CSV")
      if (isFALSE(csv_updated_matches_mdd)) r <- c(r, "CSV updated name not current per MDD")
      paste(r, collapse = "; ")
    }
  ) %>%
  ungroup() %>%
  arrange(code_join) %>%
  select(
    status, flag_reason, code_join, code_snapshot, code_csv,
    species_snapshot, species_csv_baron1983, species_csv_updated, species_mdd, name_change,
    n_snapshot, n_snapshot_num, n_csv, n_csv_num,
    volume_snapshot, volume_snapshot_num, volume_csv, volume_csv_num,
    n_match, volume_match, faithful_name_match, csv_updated_matches_mdd
  )

write_csv(report, output_detail)

mismatches <- report %>% filter(flag_reason != "")
write_csv(mismatches, output_mismatches)

# ---- console summary -------------------------------------------------------

message("Wrote ", output_detail)
message("Wrote ", output_mismatches)
message("Snapshot species rows:        ", nrow(snap_species))
message("CSV rows with a MOB volume:   ", nrow(comparison))
message("Matched by code:              ", sum(report$status == "matched_by_code"))
message("n mismatches:                 ", sum(!report$n_match, na.rm = TRUE))
message("Volume mismatches:            ", sum(!report$volume_match, na.rm = TRUE))
message("Faithful-name typos:          ", sum(report$faithful_name_match == FALSE, na.rm = TRUE))
message("CSV names out of date (MDD):  ", sum(report$csv_updated_matches_mdd == FALSE, na.rm = TRUE))
message("Rows flagged for attention:   ", nrow(mismatches))
