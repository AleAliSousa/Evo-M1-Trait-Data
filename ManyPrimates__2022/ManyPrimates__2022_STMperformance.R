# ManyPrimates__2022_STMperformance.R
#
# Purpose
#   Aggregate the ManyPrimates 1 (2022) trial-level short-term-memory data
#   (ManyPrimates et al. 2022, Animal Behavior and Cognition 9(4)) to one row per
#   species: proportion of correct choices in the delayed-choice (three-cup) task,
#   overall and per delay condition (short / medium / long).
#   Column meanings: reference_tables/ManyPrimates__2022_STMperformance_definitions.csv
#
# Input
#   ManyPrimates__2022_STMperformance_snapshot.csv   untouched copy of the journal/GitHub
#                                                      file mp1_merged_data.csv (12,375 trials)
#   ManyPrimates__2022_speciespredictors.csv           common_name -> Latin binomial lookup (same paper)
#
# Outputs
#   ManyPrimates__2022_STMperformance.csv             one row per species (41 rows)
#   <DOI>_STMperformance.tsv in __Public/comparative-data/

suppressPackageStartupMessages({
  library(dplyr)
})

## ---- paths: self-contained ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))          # = ManyPrimates__2022_STMperformance
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file <- paste0(item_name, "_snapshot.csv")
lookup_file   <- "ManyPrimates__2022_speciespredictors.csv"

trials <- read.csv(snapshot_file, stringsAsFactors = FALSE)
lk     <- read.csv(lookup_file,   stringsAsFactors = FALSE)

## ---- species: common-name token -> binomial (printed names kept in common_name) ----
tok <- function(x) gsub(" ", "_", gsub("'", "", tolower(trimws(x))))
lk$species_token <- tok(lk$common_name)
map <- setNames(lk$Species, lk$species_token)
trials$Species <- unname(map[tok(trials$species)])
if (anyNA(trials$Species))
  stop("Unmapped species tokens: ", paste(unique(trials$species[is.na(trials$Species)]), collapse = ", "))
if (!all(trials$correct %in% c(0, 1))) stop("`correct` must be 0/1")

## ---- per-individual means first, then species mean of individuals ----
ind <- trials %>%
  group_by(Species, subject_site) %>%
  summarise(p_all = mean(correct),
            p_short  = mean(correct[condition == "short"]),
            p_medium = mean(correct[condition == "medium"]),
            p_long   = mean(correct[condition == "long"]),
            .groups = "drop")

sp_tot <- trials %>%
  group_by(Species) %>%
  summarise(common_name = first(species),
            n_trials = n(),
            n_individuals = n_distinct(subject_site),
            n_sites = n_distinct(site),
            stm_prop_correct_pooled = mean(correct),
            .groups = "drop")

sp_ind <- ind %>%
  group_by(Species) %>%
  summarise(stm_prop_correct        = mean(p_all),
            stm_prop_correct_short  = mean(p_short,  na.rm = TRUE),
            stm_prop_correct_medium = mean(p_medium, na.rm = TRUE),
            stm_prop_correct_long   = mean(p_long,   na.rm = TRUE),
            .groups = "drop")

final.dataframe <- sp_tot %>%
  left_join(sp_ind, by = "Species") %>%
  transmute(Species, common_name, n_trials, n_individuals, n_sites,
            stm_prop_correct, stm_prop_correct_pooled,
            stm_prop_correct_short, stm_prop_correct_medium, stm_prop_correct_long,
            source = "ManyPrimates__2022") %>%
  mutate(across(starts_with("stm_"), ~ round(.x, 6))) %>%
  arrange(Species)

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
# Same DOI-coded stem as the sibling speciespredictors item (registry Item encoded
# is resolved by the registry owner; keep this equal to it).
item_encoded <- "10.26451%2Fabc.09.04.06.2022_STMperformance"

if (!is.na(base) && dir.exists(path.expand(tsv_dir))) {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
} else {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
}
message("Rows: ", nrow(final.dataframe))
