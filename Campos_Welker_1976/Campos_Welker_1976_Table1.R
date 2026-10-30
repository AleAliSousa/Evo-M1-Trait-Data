## Campos GB, Welker WI (1976). Comparisons between brains of a large
## and a small hystricomorph rodent. Brain Behav Evol 13:243-266. Table 1.
## DOI 10.1159/000123814.
##
## Frozen printed-table snapshot -> datatype-specific CSVs + long analysis CSV
## -> DOI-coded public TSV. Mixed units stay explicit and are never pooled.

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

snap <- read_csv(snapshot_csv, show_col_types = FALSE, na = c("", "NA"))
required <- c(
  "product", "code", "source_label", "unit", "capybara_59_490",
  "guinea_pig_60_1", "printed_multiplication_factor", "factor_direction", "note"
)
stopifnot(identical(names(snap), required))
stopifnot(nrow(snap) == 20L, n_distinct(snap$code) == 20L)
stopifnot(!anyNA(snap[c("capybara_59_490", "guinea_pig_60_1",
                        "printed_multiplication_factor")]))

snap <- snap %>%
  mutate(
    recomputed_multiplication_factor = if_else(
      factor_direction == "capybara_divided_by_guinea_pig",
      capybara_59_490 / guinea_pig_60_1,
      guinea_pig_60_1 / capybara_59_490
    ),
    factor_absolute_difference = abs(
      printed_multiplication_factor - recomputed_multiplication_factor
    )
  )

known_factor_discrepancies <- c(
  "caudate_mean_neurons_per_sample",
  "caudate_neuronal_density_per_mm3"
)
unexpected <- snap %>%
  filter(factor_absolute_difference > 0.02,
         !code %in% known_factor_discrepancies)
if (nrow(unexpected)) {
  stop("Unexpected mismatch between printed and recomputed multiplication factor: ",
       paste(unexpected$code, collapse = ", "), call. = FALSE)
}

specimens <- tibble::tribble(
  ~species_as_published, ~specimen_number, ~source_column,
  "Hydrochoerus hydrochoerus", "59-490", "capybara_59_490",
  "Cavia porcellus",            "60-1",   "guinea_pig_60_1"
)

long <- bind_rows(lapply(seq_len(nrow(specimens)), function(i) {
  value_col <- specimens$source_column[i]
  snap %>%
    transmute(
      species_as_published = specimens$species_as_published[i],
      specimen_number = specimens$specimen_number[i],
      product, code, source_label, value = .data[[value_col]], unit,
      printed_multiplication_factor, factor_direction,
      recomputed_multiplication_factor, factor_absolute_difference,
      note = coalesce(note, ""),
      source = "Campos_Welker_1976"
    )
}))
append_flag <- function(x, flag) ifelse(!nzchar(x), flag, paste(x, flag, sep = "|"))
append_note <- function(x, note) ifelse(!nzchar(x), note, paste(x, note, sep = " "))
long$source_flags <- "one_specimen_per_species"
long$source_issue_note <- "Table 1 reports one specimen per species."

morph <- long$product == "cortical_morphometry"
long$source_flags[morph] <- append_flag(long$source_flags[morph], "no_shrinkage_correction_stated")
long$source_flags[morph] <- append_flag(long$source_flags[morph], "surface_hemisphere_count_unclear")
long$source_issue_note[morph] <- append_note(
  long$source_issue_note[morph],
  "No shrinkage correction is stated, and the laterality or number of hemispheres represented by the cortical surface measurements is not explicit."
)

derived_surface <- long$code %in% c(
  "neocortex_volume_mm3", "cortical_surface_area_mm2", "cortical_thickness_mm"
)
long$source_flags[derived_surface] <- append_flag(long$source_flags[derived_surface], "surface_area_may_be_derived")
derived_note <- ifelse(
  long$species_as_published[derived_surface] == "Hydrochoerus hydrochoerus",
  "Surface area x thickness is 2501 x 1.59 = 3976.59 mm3, essentially the printed 3979 mm3 volume; surface area may have been calculated rather than independently measured.",
  "Surface area x thickness is 218.2 x 0.78 = 170.196 mm3, equal to the printed 170.2 mm3 volume after rounding; surface area may have been calculated rather than independently measured."
)
long$source_issue_note[derived_surface] <- append_note(long$source_issue_note[derived_surface], derived_note)

factor_mismatch <- long$code %in% known_factor_discrepancies
long$source_flags[factor_mismatch] <- append_flag(long$source_flags[factor_mismatch], "printed_factor_mismatch")
long$source_issue_note[factor_mismatch] <- append_note(
  long$source_issue_note[factor_mismatch],
  "The printed multiplication factor is 3.0, while the printed values imply approximately 3.20."
)
ratio_mismatch <- long$species_as_published == "Cavia porcellus" & long$code == "corticothalamic_ratio"
long$source_flags[ratio_mismatch] <- append_flag(long$source_flags[ratio_mismatch], "printed_ratio_mismatch")
long$source_issue_note[ratio_mismatch] <- append_note(
  long$source_issue_note[ratio_mismatch],
  "The printed ratio is 5.15, while 170.2/36.6 = 4.65."
)
stopifnot(nrow(long) == 40L, !anyNA(long$value), all(long$value > 0))

write_csv(long, paste0(item_name, ".csv"), na = "NA")

for (product_name in unique(snap$product)) {
  product_long <- long %>% filter(product == product_name)
  quality <- product_long %>%
    group_by(species_as_published, specimen_number) %>%
    summarise(
      source_flags = paste(unique(unlist(strsplit(source_flags, "\\|", fixed = FALSE))), collapse = "|"),
      source_issue_note = paste(unique(source_issue_note), collapse = " "),
      .groups = "drop"
    )
  product_wide <- product_long %>%
    select(species_as_published, specimen_number, code, value) %>%
    pivot_wider(names_from = code, values_from = value) %>%
    left_join(quality, by = c("species_as_published", "specimen_number")) %>%
    mutate(source = "Campos_Welker_1976")
  write_csv(product_wide, paste0(item_name, "_", product_name, ".csv"), na = "NA")
}

## Arithmetic checks printed or implied by Table 1.
value_of <- function(species, code) {
  long$value[match(paste(species, code), paste(long$species_as_published, long$code))]
}
for (sp in specimens$species_as_published) {
  neo_total <- value_of(sp, "neocortex_total_neuron_number")
  neo_implied <- value_of(sp, "neocortex_volume_mm3") *
    value_of(sp, "neocortex_neuronal_density_per_mm3")
  cau_total <- value_of(sp, "caudate_total_neuron_number")
  cau_implied <- value_of(sp, "caudate_putamen_accumbens_volume_mm3") *
    value_of(sp, "caudate_neuronal_density_per_mm3")
  stopifnot(abs(neo_total - neo_implied) <= 1, abs(cau_total - cau_implied) <= 1)
}

## The capybara ratio reproduces neocortex/thalamus; the guinea-pig printed ratio
## does not. This is a source-level discrepancy and is preserved, not corrected.
cap_ratio <- value_of("Hydrochoerus hydrochoerus", "neocortex_volume_mm3") /
  value_of("Hydrochoerus hydrochoerus", "thalamus_volume_mm3")
gp_ratio <- value_of("Cavia porcellus", "neocortex_volume_mm3") /
  value_of("Cavia porcellus", "thalamus_volume_mm3")
stopifnot(abs(cap_ratio - value_of("Hydrochoerus hydrochoerus", "corticothalamic_ratio")) < 0.01)
stopifnot(abs(gp_ratio - value_of("Cavia porcellus", "corticothalamic_ratio")) > 0.4)
for (sp in specimens$species_as_published) {
  surface <- value_of(sp, "cortical_surface_area_mm2")
  thickness <- value_of(sp, "cortical_thickness_mm")
  volume <- value_of(sp, "neocortex_volume_mm3")
  stopifnot(abs(surface * thickness - volume) / volume < 0.001)
}

if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  expected <- "10.1159%2F000123814_Table1"
  if (length(item_encoded) != 1L || is.na(item_encoded) || !identical(item_encoded, expected)) {
    stop("Unexpected or uncached registry encoding for ", item_name,
         ": ", paste(item_encoded, collapse = ", "), call. = FALSE)
  }
  public_dir <- file.path(base, "__Public", "comparative-data")
  dir.create(public_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(long, file.path(public_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "NA")
}

message("Campos & Welker Table 1: 2 specimens x 20 measures; three datatype-specific CSVs and public TSV written.")
message("Preserved and flagged source discrepancies: derived-surface concern, unclear shrinkage/laterality, guinea-pig cortico-thalamic ratio, and two printed caudate density factors.")
