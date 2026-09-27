#!/usr/bin/env Rscript
# check_trait_authority.R
# -----------------------------------------------------------------------------
# Does _keys/trait_authority.csv still describe the data?
#
# The registry names, for every app-facing label, WHICH REPO FOLDER holds the
# authoritative value. It exists because authority used to be implicit: app.R's
# label_for() picks whichever spelling happens to exist among the loaded labels,
# so which merge won was a side effect of how that merge spelled its output.
#
# This script is the reason the registry will not rot. Two earlier mechanisms
# did, and both failed the same way -- quietly:
#   * variable_domain.csv drifted 38 labels behind the data; the only signal was
#     an "Unclassified" bucket in the app, which reads as a data property rather
#     than a build problem.
#   * variable_canonical.csv's `superseded_by` column reads like a declaration of
#     authority but no code consults it, so it can name a folder that does not
#     produce the label and nothing notices.
#
# Guards
#   1. COMPLETENESS  every label the app serves has a row, and every row
#                    corresponds to a label the app serves.
#   2. VALIDITY      every `authority` is a real repo folder AND is among that
#                    label's actual producers. This is the guard `superseded_by`
#                    lacks: a pointer nothing validates is a pointer that drifts.
#   3. DECIDED       no row is left at basis = NEEDS_DECISION or blank authority.
#
# Exit non-zero on failure. Run after _keys/build_trait_authority.R.
# -----------------------------------------------------------------------------

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
checks_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg[1]))) else getwd()
repo <- normalizePath(file.path(checks_dir, ".."))
reg_path <- file.path(repo, "_keys", "trait_authority.csv")
if (!file.exists(reg_path))
  stop("FAIL: _keys/trait_authority.csv is missing. Run _keys/build_trait_authority.R.")

reg <- read.csv(reg_path, stringsAsFactors = FALSE, check.names = FALSE,
                colClasses = "character", encoding = "UTF-8")

# Rebuild the label -> producer map from the app's own loader, so the check can
# never pass against a stale idea of what the app serves.
app_file <- file.path(repo, "__ShinyApp", "app.R")
src <- readLines(app_file, warn = FALSE)
cut <- grep("^shinyApp\\(", src)
if (length(cut) != 1) stop("FAIL: expected one top-level shinyApp( call in app.R.")
suppressPackageStartupMessages({library(shiny); library(bslib); library(DT); library(ggplot2)})
app_env <- new.env(parent = globalenv())
owd <- setwd(file.path(repo, "__ShinyApp")); on.exit(setwd(owd), add = TRUE)
if (!nzchar(Sys.getenv("EVOM1_SOURCE"))) Sys.setenv(EVOM1_SOURCE = "local")
eval(parse(text = paste(src[seq_len(cut - 1)], collapse = "\n")), envir = app_env)
setwd(owd)
compiled <- get("compiled", envir = app_env)

DS <- c("Brain-structure volumes"="__merging_volumes","Cell counts"="__merging_cellcounts",
        "EvoM1 traits"="____EvoM1_TraitTable (melted)","Body & ecology"="__merging_body_ecology",
        "Brain mass"="__merging_brain_mass","Behaviour"="__merging_behaviour",
        "Brain-part weights"="__merging_weights","Endocranial volume"="__merging_endocranial_volume",
        "Cerebellar folding"="__merging_cerebellar_folding",
        "Cerebral metabolic rate"="__merging_cerebral_metabolic_rate","Grey-level index"="__merging_GLI",
        "Cortical areas & surfaces"="__merging_cortical_areas",
        "Cortical layer thickness"="__merging_cortical_layers",
        "Fossil brain glucose"="__merging_fossil_brain_glucose","Gyrification (GI)"="__merging_gyrification",
        "Sensory performance"="__merging_sensory")
pairs <- unique(compiled[, c("Variable", "Dataset")])
pairs$folder <- unname(DS[pairs$Dataset])
producers <- split(pairs$folder, pairs$Variable)
app_labels <- names(producers)

fails <- character(0)
add <- function(...) fails <<- c(fails, paste0(...))

## 1. COMPLETENESS
missing <- setdiff(app_labels, reg$label)
if (length(missing))
  add("COMPLETENESS: ", length(missing), " label(s) the app serves have no authority row:\n    ",
      paste(head(missing, 20), collapse = "\n    "),
      if (length(missing) > 20) paste0("\n    ... and ", length(missing) - 20, " more") else "")
orphan <- setdiff(reg$label, app_labels)
if (length(orphan))
  add("COMPLETENESS: ", length(orphan), " registry row(s) name a label the app no longer serves:\n    ",
      paste(head(orphan, 20), collapse = "\n    "),
      "\n  (a vetoed or renamed label -- regenerate, or remove the row deliberately)")

## 2. VALIDITY
known_folders <- c(unname(DS))
bad_folder <- reg[nzchar(reg$authority) & !(reg$authority %in% known_folders), ]
if (nrow(bad_folder))
  add("VALIDITY: ", nrow(bad_folder), " row(s) name an authority that is not a known producer folder:\n    ",
      paste(unique(paste0(bad_folder$label, " -> ", bad_folder$authority)), collapse = "\n    "))
not_producer <- character(0)
for (i in seq_len(nrow(reg))) {
  lab <- reg$label[i]; auth <- reg$authority[i]
  if (!nzchar(auth) || !(lab %in% app_labels)) next
  if (!(auth %in% producers[[lab]]))
    not_producer <- c(not_producer, paste0(lab, " -> ", auth,
                      "  (actual producers: ", paste(sort(unique(producers[[lab]])), collapse = ", "), ")"))
}
if (length(not_producer))
  add("VALIDITY: ", length(not_producer), " row(s) name an authority that does not produce that label:\n    ",
      paste(not_producer, collapse = "\n    "))

## 3. DECIDED
undecided <- reg[!nzchar(reg$authority) | reg$basis == "NEEDS_DECISION", ]
if (nrow(undecided))
  add("DECIDED: ", nrow(undecided), " row(s) still need a decision:\n    ",
      paste(undecided$label, collapse = "\n    "))
bad_basis <- setdiff(unique(reg$basis),
                     c("auto_single_producer", "adopted_from_variable_canonical",
                       "adjudicated", "NEEDS_DECISION"))
if (length(bad_basis))
  add("DECIDED: unknown basis value(s): ", paste(bad_basis, collapse = ", "))

cat("trait_authority.csv: ", nrow(reg), " rows | app labels: ", length(app_labels), "\n", sep = "")
print(table(reg$basis))
if (length(fails)) {
  cat("\n", strrep("-", 70), "\n", sep = "")
  for (f in fails) cat("FAIL  ", f, "\n\n", sep = "")
  stop("check_trait_authority.R: ", length(fails), " guard(s) failed.")
}
cat("\nPASS: every app label has a valid, decided authority.\n")
