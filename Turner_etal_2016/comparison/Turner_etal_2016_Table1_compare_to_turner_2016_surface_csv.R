# Turner_etal_2016_Table1_compare_to_turner_2016_surface_csv.R
#
# Checking step (self-contained in comparison/). Audit the journal-faithful
# snapshot of Turner et al. (2016) Table 1 against turner_2016_surface.csv --
# the curated per-case surface extract that __merging_cortical_areas has been
# reading while this folder was unbuilt. Matched by CASE, comparing the printed
# brain surface area (cm2) and the project-unit conversion (mm2). This audit is
# what lets the merge switch from the curated extract to the built TSV without
# any value changing. Run from comparison/.
#
# Case-id note: the curated CSV zero-pads case numbers ("09-27"); the paper
# prints "9-27". Both sides are normalised (strip a leading zero, drop the
# LH/RH suffix, add the hemisphere as its own key part) so the join is on
# case + hemisphere, which is one row per measured hemisphere on both sides.
#
# Inputs : ../Turner_etal_2016_Table1_snapshot.xlsx (sheet Table1) ; turner_2016_surface.csv
# Outputs: Turner_etal_2016_Table1_comparison_report_from_R.csv
#          Turner_etal_2016_Table1_comparison_mismatches_from_R.csv

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
})
## Set working directory to this script folder
.here <- tryCatch(dirname(normalizePath(sub("^--file=", "",
          grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))), error = function(e) getwd())
if (!is.na(.here) && dir.exists(.here)) setwd(.here)
snapshot_file     <- "../Turner_etal_2016_Table1_snapshot.xlsx"
snapshot_sheet    <- "Table1"
comparison_file   <- "turner_2016_surface.csv"
output_detail     <- "Turner_etal_2016_Table1_comparison_report_from_R.csv"
output_mismatches <- "Turner_etal_2016_Table1_comparison_mismatches_from_R.csv"
header_rows       <- 2L
measures <- c("brain_surface_cm2", "surface_mm2")

parse_value <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))
norm_case   <- function(x) str_replace(str_squish(as.character(x)), "^0+", "")

pos <- c("case_printed", "species_printed", "age_years", "sex", "hemisphere",
         "brain_weight_g", "brain_surface_area_cm2")
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
sdat <- raw %>% slice(-(seq_len(header_rows)))
names(sdat)[seq_along(pos)] <- pos

snap <- sdat %>%
  filter(!is.na(parse_value(brain_surface_area_cm2))) %>%
  transmute(case_snapshot = str_squish(case_printed),
            hemisphere    = str_squish(hemisphere),
            join_key      = paste(norm_case(str_remove(case_printed, "\\s+(LH|RH)$")), hemisphere),
            species_snapshot     = str_squish(species_printed),
            brain_surface_cm2_snap = parse_value(brain_surface_area_cm2),
            surface_mm2_snap       = parse_value(brain_surface_area_cm2) * 100)

# One row per measured hemisphere in the curated extract; dedupe_status is carried
# through so the audit also confirms the merge's case-level exclusion is unchanged.
comp <- read_csv(comparison_file, col_types = cols(.default = col_character()), na = c("")) %>%
  transmute(join_key = paste(norm_case(case), str_squish(hemisphere)),
            case_csv = str_squish(case),
            species_csv = str_squish(Species),
            dedupe_status_csv = str_squish(dedupe_status),
            brain_surface_cm2_csv = parse_value(brain_surface_cm2),
            surface_mm2_csv       = parse_value(`CorticalSurface_Area.mm2`))

num_match <- function(a, b, tol = 1e-6) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) <= tol)
report <- full_join(snap, comp, by = "join_key") %>%
  mutate(status = case_when(is.na(case_snapshot) ~ "csv_only_not_in_snapshot",
                            is.na(case_csv)      ~ "snapshot_only_not_in_csv",
                            TRUE                 ~ "matched_by_case"))
for (m in measures)
  report[[paste0(m, "_match")]] <- num_match(report[[paste0(m, "_snap")]], report[[paste0(m, "_csv")]])
report$n_measure_mismatch <- rowSums(!as.matrix(report[paste0(measures, "_match")]))
report <- report %>% arrange(dplyr::coalesce(case_snapshot, case_csv)) %>%
  relocate(status, case_snapshot, case_csv, species_snapshot, species_csv, n_measure_mismatch)

write_csv(report, output_detail)
write_csv(filter(report, status != "matched_by_case" | n_measure_mismatch > 0), output_mismatches)
message("matched: ", sum(report$status == "matched_by_case"),
        " | value mismatches: ", sum(report$n_measure_mismatch > 0, na.rm = TRUE),
        " | snapshot-only: ", sum(report$status == "snapshot_only_not_in_csv"),
        " | csv-only: ", sum(report$status == "csv_only_not_in_snapshot"))
stopifnot(all(report$n_measure_mismatch == 0), nrow(report) == 6L)
