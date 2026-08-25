## Armstrong E (1979). A quantitative comparison of the hominoid thalamus.
## I. Specific sensory relay nuclei. Am J Phys Anthropol 51:365-382.
## DOI 10.1002/ajpa.1330510308. Tables 1-9.
##
## Frozen table transcription -> datatype-specific CSVs + combined public TSV.

options(scipen = 999)
suppressPackageStartupMessages({
  library(readr)
  library(readxl)
  library(dplyr)
  library(tidyr)
})

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source.", call. = FALSE)
})

folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
snapshot_csv <- paste0(item_name, "_snapshot.csv")
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snap <- read_csv(snapshot_csv, show_col_types = FALSE, na = c("", "NA", "-"))
crosswalk <- read_csv("Armstrong__1979_specimen_crosswalk.csv", show_col_types = FALSE,
                      na = c("", "NA"))

required <- c("table", "source_group", "role", "specimen_code",
              "species_as_published", "structure", "measure", "unit", "value",
              "percent_value", "n", "mean", "sd", "se", "minimum", "maximum",
              "median", "note")
stopifnot(identical(names(snap), required))

expected_rows <- c(Table1 = 32L, Table2 = 6L, Table3 = 10L, Table4 = 6L,
                   Table5 = 14L, Table6 = 18L, Table7 = 6L, Table8 = 9L,
                   Table9 = 5L)
actual_rows <- table(factor(snap$table, levels = names(expected_rows)))
stopifnot(identical(as.integer(actual_rows), unname(expected_rows)))

primary_codes <- unique(snap$specimen_code[snap$source_group == "Armstrong_1979"])
missing_crosswalk <- setdiff(primary_codes, crosswalk$specimen_code)
if (length(missing_crosswalk)) {
  stop("Primary specimen code(s) missing from crosswalk: ",
       paste(missing_crosswalk, collapse = ", "), call. = FALSE)
}

## Attach individual identity without overwriting the journal's printed label.
analysis <- snap %>%
  left_join(
    crosswalk %>%
      select(specimen_code, individual_id, interpreted_taxon, sex, age_years,
             body_mass_kg, brain_mass_g, collection, section_plane),
    by = "specimen_code"
  ) %>%
  mutate(source = "Armstrong__1979") %>%
  select(table, source_group, role, specimen_code, individual_id,
         species_as_published, interpreted_taxon, sex, age_years,
         body_mass_kg, brain_mass_g, collection, section_plane,
         structure, measure, unit, value, percent_value, n, mean, sd, se,
         minimum, maximum, median, note, source)

write_csv(analysis, paste0(item_name, ".csv"), na = "NA")
write_csv(filter(analysis, table %in% c("Table1", "Table5")),
          paste0(item_name, "_volumes.csv"), na = "NA")
write_csv(filter(analysis, table %in% c("Table2", "Table3", "Table4", "Table6")),
          paste0(item_name, "_neuronal_density_counts.csv"), na = "NA")
write_csv(filter(analysis, table %in% c("Table7", "Table8", "Table9")),
          paste0(item_name, "_neuronal_perikaryal_volume.csv"), na = "NA")

## Table 5 partitions each Table 1 LGB volume into LGBp + LGBm.
t1_lgb <- snap %>%
  filter(table == "Table1", source_group == "Armstrong_1979", structure == "LGB") %>%
  select(specimen_code, lgb_total = value)
t5_lgb <- snap %>%
  filter(table == "Table5") %>%
  group_by(specimen_code) %>%
  summarise(component_sum = sum(value), percent_sum = sum(percent_value), .groups = "drop")
lgb_check <- inner_join(t1_lgb, t5_lgb, by = "specimen_code")
stopifnot(nrow(lgb_check) == 7L)
exact_lgb <- lgb_check %>% filter(specimen_code != "Homo s.-s")
human_lgb <- lgb_check %>% filter(specimen_code == "Homo s.-s")
stopifnot(all(abs(exact_lgb$lgb_total - exact_lgb$component_sum) < 0.000001))
stopifnot(nrow(human_lgb) == 1L,
          abs(human_lgb$lgb_total - 69.1) < 0.000001,
          abs(human_lgb$component_sum - 69.2) < 0.000001)
stopifnot(all(abs(lgb_check$percent_sum - 100) <= 0.1))

## Tables 6 counts must reproduce from the volume and density tables to within
## published rounding. Validate specimens whose volume and density share a code.
count_check <- snap %>%
  filter(table == "Table6", structure %in% c("MGBp", "VB"), !is.na(value),
         specimen_code != "Homo s.") %>%
  select(specimen_code, structure, reported_count = value) %>%
  left_join(
    snap %>% filter(table == "Table1", source_group == "Armstrong_1979") %>%
      select(specimen_code, structure, volume_mm3 = value),
    by = c("specimen_code", "structure")
  ) %>%
  left_join(
    snap %>% filter(table %in% c("Table2", "Table4")) %>%
      select(specimen_code, structure, density_per_001_mm3 = mean),
    by = c("specimen_code", "structure")
  ) %>%
  mutate(implied_count = volume_mm3 * density_per_001_mm3 * 100,
         relative_difference = abs(reported_count - implied_count) / reported_count)
known_count_discrepancy <- count_check %>%
  filter(specimen_code == "Hylo.-h", structure == "MGBp")
regular_count_checks <- count_check %>%
  filter(!(specimen_code == "Hylo.-h" & structure == "MGBp"))
stopifnot(nrow(count_check) == 10L,
          nrow(known_count_discrepancy) == 1L,
          known_count_discrepancy$reported_count == 413000,
          abs(known_count_discrepancy$implied_count - 397570) < 0.000001,
          all(regular_count_checks$relative_difference < 0.005))

## The human count is deliberately a cross-specimen estimate: mean of the two
## volume brains combined with density from the third brain.
human_check <- lapply(c("MGBp", "VB"), function(s) {
  mean_vol <- mean(snap$value[snap$table == "Table1" &
                              snap$specimen_code %in% c("Homo s.-s", "Homo s.-t") &
                              snap$structure == s])
  density <- snap$mean[snap$specimen_code == "Homo s.-c" & snap$structure == s &
                         snap$table %in% c("Table2", "Table4")]
  reported <- snap$value[snap$table == "Table6" & snap$specimen_code == "Homo s." &
                           snap$structure == s]
  abs(reported - mean_vol * density * 100) / reported
})
stopifnot(all(unlist(human_check) < 0.005))

## All density and perikaryal summary rows are complete and internally ordered.
summary_rows <- snap %>% filter(measure %in% c("neuronal_density", "perikaryal_volume"))
stopifnot(!anyNA(summary_rows[c("n", "mean", "sd", "se", "minimum", "maximum", "median")]))
stopifnot(all(summary_rows$minimum <= summary_rows$median),
          all(summary_rows$median <= summary_rows$maximum))
stopifnot(sum(is.na(snap$value[snap$table == "Table6"])) == 1L)

if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  expected <- "10.1002%2Fajpa.1330510308_Tables1-9"
  if (length(item_encoded) != 1L || is.na(item_encoded) || !identical(item_encoded, expected)) {
    stop("Unexpected or uncached registry encoding for ", item_name,
         ": ", paste(item_encoded, collapse = ", "), call. = FALSE)
  }
  public_dir <- file.path(base, "__Public", "comparative-data")
  dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(analysis, file.path(public_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "NA")
}

message("Armstrong Tables 1-9: 106 source rows; volume, density/count and perikaryal products written.")
message("Hylo.-s and Hylo.-h remain linked as two hemispheres of one gibbon individual.")
message("Preserved source discrepancy: Homo s.-s Table 5 components sum to 69.2 mm3 versus 69.1 mm3 in Table 1.")
message("Preserved source discrepancy: Hylo.-h MGBp volume x density implies 397,570 neurons versus 413,000 in Table 6.")
