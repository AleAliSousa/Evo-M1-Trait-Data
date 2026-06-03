# Baron_etal_1987_Table1_compare_to_baron_etal_1987_csv.R
#
# Purpose
#   Checking step. Audit the faithful snapshot of Baron et al. 1987 Table 1
#   against comparison/baron_etal_1987.csv -- the file the snapshot was built
#   from. Rows are matched by species, then all seven paleocortical structure
#   volumes (BOL, RB, PRPI, TOL, TRL, COA, SIN) are compared numerically.
#   Because the snapshot was derived from this CSV, a clean run shows every
#   species and value matching; any difference flags a transcription error.
#
# Inputs
#   Baron_etal_1987_Table1_snapshot.xlsx     sheet: Table1_snapshot
#   comparison/baron_etal_1987.csv           the source CSV (row 2 is the header)
#
# Outputs
#   Baron_etal_1987_Table1_comparison_report_from_R.csv       every species, all 7 structures
#   Baron_etal_1987_Table1_comparison_mismatches_from_R.csv   rows needing attention

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

snapshot_file     <- "Baron_etal_1987_Table1_snapshot.xlsx"
snapshot_sheet    <- "Table1_snapshot"
comparison_file   <- file.path("comparison", "baron_etal_1987.csv")
output_detail     <- "Baron_etal_1987_Table1_comparison_report_from_R.csv"
output_mismatches <- "Baron_etal_1987_Table1_comparison_mismatches_from_R.csv"

structures <- c("BOL", "RB", "PRPI", "TOL", "TRL", "COA", "SIN")

# ---- helpers ---------------------------------------------------------------

parse_value <- function(x) parse_number(x, na = c("", "-", "NA", "n.a.", "__"))
norm_label  <- function(x) str_squish(tolower(str_remove_all(x, "\\.")))
num_match   <- function(a, b, tol = 1e-6) {
  (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) <= tol)
}

# Snapshot: caption in row 1, header in row 2, data from row 3. Blank header
# cells (the group column) are named blank_*.
read_snapshot <- function(path, sheet) {
  raw <- read_excel(path, sheet = sheet, col_names = FALSE, col_types = "text", na = c(""))
  header <- as.character(unlist(raw[2, ], use.names = FALSE))
  blank <- is.na(header) | header == ""
  header[blank] <- paste0("blank_", which(blank))
  dat <- raw[-c(1, 2), , drop = FALSE]
  names(dat) <- header
  dat
}

# comparison CSV: row 1 holds the long structure names, row 2 is the real header.
read_comparison <- function(path) {
  raw <- read_csv(path, col_names = FALSE, col_types = cols(.default = col_character()), na = c(""))
  header <- as.character(unlist(raw[2, ], use.names = FALSE))
  dat <- raw[-c(1, 2), , drop = FALSE]
  names(dat) <- header
  dat
}

# ---- read both sides, keep species rows, make values numeric ---------------

snap <- read_snapshot(snapshot_file, snapshot_sheet) %>%
  rename(species_snapshot = `species name`) %>%
  filter(!is.na(species_snapshot)) %>%                 # drops group + footnote rows
  transmute(species_key = norm_label(species_snapshot),
            species_snapshot,
            across(all_of(structures), parse_value, .names = "{.col}_snap"))

comp <- read_comparison(comparison_file) %>%
  filter(!is.na(Species)) %>%
  transmute(species_key = norm_label(Species),
            species_csv = Species,
            species_csv_baron1987 = Species_Baron1987,
            across(all_of(structures), parse_value, .names = "{.col}_csv"))

# ---- match by species and compare every structure --------------------------

report <- full_join(snap, comp, by = "species_key") %>%
  mutate(status = case_when(
    is.na(species_snapshot) ~ "csv_only_not_in_snapshot",
    is.na(species_csv)      ~ "snapshot_only_not_in_csv",
    TRUE                    ~ "matched_by_species"
  ))

for (s in structures) {
  report[[paste0(s, "_match")]] <- num_match(report[[paste0(s, "_snap")]],
                                             report[[paste0(s, "_csv")]])
}
match_mat <- as.matrix(report[paste0(structures, "_match")])
report$n_structure_mismatch <- rowSums(!match_mat)

report <- report %>%
  arrange(species_key) %>%
  relocate(status, species_key, species_snapshot, species_csv, species_csv_baron1987,
           n_structure_mismatch)

write_csv(report, output_detail)

mismatches <- report %>%
  filter(status != "matched_by_species" | n_structure_mismatch > 0)
write_csv(mismatches, output_mismatches)

# ---- console summary -------------------------------------------------------

message("Wrote ", output_detail)
message("Wrote ", output_mismatches)
message("Snapshot species:            ", sum(!is.na(report$species_snapshot)))
message("CSV species:                 ", sum(!is.na(report$species_csv)))
message("Matched by species:          ", sum(report$status == "matched_by_species"))
message("Snapshot-only species:       ", sum(report$status == "snapshot_only_not_in_csv"))
message("CSV-only species:            ", sum(report$status == "csv_only_not_in_snapshot"))
message("Species with value mismatch: ", sum(report$n_structure_mismatch > 0, na.rm = TRUE))
message("Rows flagged for attention:  ", nrow(mismatches))
