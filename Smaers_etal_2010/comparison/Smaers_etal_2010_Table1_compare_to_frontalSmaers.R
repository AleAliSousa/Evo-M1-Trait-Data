# Smaers_etal_2010_Table1_compare_to_frontalSmaers.R
#
# Checking step (self-contained in comparison/). Audit the cleaned Table 1 data
# produced by ../Smaers_etal_2010_Table1.R against frontalSmaers.xls.
#
# frontalSmaers.xls contains the same 18 species and seven shared volumetric
# measures: neopallium, neopallium white/grey, frontal lobe, frontal white/grey,
# and total brain volume. It does not contain specimen number, Fr/Neo ratios,
# Stephan unpublished N, basal ganglia, or the derived non-frontal measures.
#
# Match is by the journal-faithful abbreviated species label (species_printed),
# which is also the species label used in frontalSmaers.xls.
#
# Put this script and frontalSmaers.xls in:
#   Smaers_etal_2010/comparison/
#
# Inputs:
#   ../Smaers_etal_2010_Table1.csv
#   frontalSmaers.xls
#
# Outputs:
#   Smaers_etal_2010_Table1_comparison_report_from_R.csv
#   Smaers_etal_2010_Table1_comparison_mismatches_from_R.csv

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

## ---- paths ------------------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).",
       call. = FALSE)
})

folder <- dirname(.sp)
setwd(folder)

table_file        <- "../Smaers_etal_2010_Table1.csv"
comparison_file   <- "frontalSmaers.xls"
output_detail     <- "Smaers_etal_2010_Table1_comparison_report_from_R.csv"
output_mismatches <- "Smaers_etal_2010_Table1_comparison_mismatches_from_R.csv"

## ---- helpers ----------------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(as.character(x)))

## Whitespace is removed outright rather than squished: frontalSmaers.xls prints
## "Lagothr. lagotr." where Table 1 prints "Lagothr.lagotr.", and str_squish()
## would leave that species as two unmatched rows (one Smaers_2010_only, one
## frontalSmaers_only) rather than one matched pair. Abbreviation dots are kept.
norm_label <- function(x) {
  x %>%
    as.character() %>%
    str_remove_all("\\s+") %>%
    str_to_lower()
}

num_match <- function(a, b, tol = 1e-6) {
  (is.na(a) & is.na(b)) |
    (!is.na(a) & !is.na(b) & abs(a - b) <= tol)
}

## ---- Smaers 2010 Table 1 side ----------------------------------------------
smaers <- read_csv(
  table_file,
  col_types = cols(.default = col_character()),
  na = c("", "NA")
) %>%
  transmute(
    species_key = norm_label(species_printed),
    species_smaers = species,
    species_printed_smaers = species_printed,

    neopallium_smaers       = num(neopallium_volume_mm3),
    neopallium_white_smaers = num(neopallium_white_matter_volume_mm3),
    neopallium_grey_smaers  = num(neopallium_grey_matter_volume_mm3),
    frontal_lobe_smaers     = num(frontal_lobe_volume_mm3),
    frontal_white_smaers    = num(frontal_white_matter_volume_mm3),
    frontal_grey_smaers     = num(frontal_grey_matter_volume_mm3),
    brain_smaers            = num(total_brain_volume_mm3)
  )

## ---- frontalSmaers.xls side -------------------------------------------------
## The workbook has a header row, followed by one blank row, then the 18 species.
frontal <- read_excel(
  comparison_file,
  col_types = "text"
) %>%
  rename(
    species_frontal       = species,
    neopallium_frontal    = neopallium,
    neopallium_white_frontal = `neopallium white`,
    neopallium_grey_frontal  = `neopallium grey`,
    frontal_lobe_frontal     = `frontal neopallial lobe`,
    frontal_white_frontal    = `frontal white`,
    frontal_grey_frontal     = `frontal grey`,
    brain_frontal            = brain
  ) %>%
  filter(!is.na(species_frontal), str_squish(species_frontal) != "") %>%
  transmute(
    species_key = norm_label(species_frontal),
    species_frontal = str_squish(species_frontal),

    neopallium_frontal       = num(neopallium_frontal),
    neopallium_white_frontal = num(neopallium_white_frontal),
    neopallium_grey_frontal  = num(neopallium_grey_frontal),
    frontal_lobe_frontal     = num(frontal_lobe_frontal),
    frontal_white_frontal    = num(frontal_white_frontal),
    frontal_grey_frontal     = num(frontal_grey_frontal),
    brain_frontal            = num(brain_frontal)
  )

## ---- compare ----------------------------------------------------------------
measures <- c(
  "neopallium",
  "neopallium_white",
  "neopallium_grey",
  "frontal_lobe",
  "frontal_white",
  "frontal_grey",
  "brain"
)

report <- full_join(smaers, frontal, by = "species_key") %>%
  mutate(
    status = case_when(
      is.na(species_printed_smaers) ~ "frontalSmaers_only",
      is.na(species_frontal)        ~ "Smaers_2010_only",
      TRUE                          ~ "matched_by_species"
    )
  )

for (m in measures) {
  report[[paste0(m, "_match")]] <- num_match(
    report[[paste0(m, "_smaers")]],
    report[[paste0(m, "_frontal")]]
  )
}

report$n_measure_mismatch <- rowSums(
  !as.matrix(report[paste0(measures, "_match")])
)

report <- report %>%
  arrange(species_key) %>%
  relocate(
    status,
    species_key,
    species_smaers,
    species_printed_smaers,
    species_frontal,
    n_measure_mismatch
  )

mismatches <- report %>%
  filter(status != "matched_by_species" | n_measure_mismatch > 0)

## ---- save -------------------------------------------------------------------
write_csv(report, output_detail)
write_csv(mismatches, output_mismatches)

message(
  "matched species: ", sum(report$status == "matched_by_species"),
  " | species with value mismatches: ",
  sum(report$status == "matched_by_species" & report$n_measure_mismatch > 0),
  " | Smaers 2010 only: ", sum(report$status == "Smaers_2010_only"),
  " | frontalSmaers only: ", sum(report$status == "frontalSmaers_only"),
  " | mismatch rows written: ", nrow(mismatches)
)
