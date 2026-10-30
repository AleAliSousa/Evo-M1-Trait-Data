#!/usr/bin/env Rscript
# EvoM1: short-term memory (ManyPrimates 2022, delayed-choice task) -> stm_manyprimates.xlsx
# One row per species: proportion of correct choices (mean of individual means), overall and per
# delay condition, aggregated from the trial-level mp1_merged_data by
# ManyPrimates__2022/ManyPrimates__2022_STMperformance.R. Chance level = 1/3 (three cups).
suppressWarnings(suppressMessages({library(readxl); library(writexl)}))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  stop("Run with Rscript file.R, or open the saved script in RStudio.", call. = FALSE)
})
tt_dir <- dirname(.sp)
root <- normalizePath(file.path(tt_dir, ".."))

# species resolver (single source of truth = _keys)
key <- read.csv(file.path(root, "_keys/Stephan/species_key.csv"), stringsAsFactors = FALSE)
ref <- read.csv(file.path(root, "_keys/species_reference.csv"),   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) { c <- clean_sp(x)
  h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }

item_encoded <- "10.26451%2Fabc.09.04.06.2022_STMperformance"
d <- read.table(file.path(root, "__Public/comparative-data", paste0(item_encoded, ".tsv")),
                header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
need <- c("Species","stm_prop_correct","stm_prop_correct_short","stm_prop_correct_medium",
          "stm_prop_correct_long","n_trials","n_individuals")
if (length(setdiff(need, names(d)))) stop("TSV missing: ", paste(setdiff(need, names(d)), collapse = ", "))

out <- data.frame(
  species_sci = vapply(d$Species, resolve, character(1)),
  Species = trimws(d$Species),
  stm_prop_correct = d$stm_prop_correct,
  stm_prop_correct_short = d$stm_prop_correct_short,
  stm_prop_correct_medium = d$stm_prop_correct_medium,
  stm_prop_correct_long = d$stm_prop_correct_long,
  stm_n_trials = d$n_trials,
  stm_n_individuals = d$n_individuals,
  stringsAsFactors = FALSE, check.names = FALSE)
write_xlsx(out, file.path(tt_dir, "stm_manyprimates.xlsx"))
cat("stm_manyprimates.xlsx:", nrow(out), "rows\n")
