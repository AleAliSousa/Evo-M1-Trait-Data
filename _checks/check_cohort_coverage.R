#!/usr/bin/env Rscript
# =============================================================================
# check_cohort_coverage.R -- trait coverage for the cohorts in
# _keys/species_cohorts.csv, outside the Shiny app.
#
# Why it reuses app.R rather than re-deriving coverage: the app already decides
# which labels are measurements, which species names are aliased, and which
# variables exist. Re-implementing any of that here would let the report and
# the interface drift apart and disagree in public. So this script evaluates
# app.R up to (not including) its single shinyApp() call, then calls the app's
# own coverage functions. Same pattern as _checks/check_trait_authority.R.
#
# Usage (from the repo root):
#   Rscript _checks/check_cohort_coverage.R [outdir]
# Writes three CSVs to outdir (default: the current directory):
#   cohort_coverage_by_trait.csv    one row per cohort x trait
#   cohort_coverage_summary.csv     one row per cohort x domain
#   cohort_name_variants.csv        uncounted look-alike labels
#
# Exits non-zero if a cohort member cannot be found in the compiled data at
# all, because that is a key problem (a missing alias or a typo), not a
# finding about the animal.
# =============================================================================

args   <- commandArgs(trailingOnly = TRUE)
outdir <- if (length(args) >= 1) args[[1]] else "."

app_dir <- "__ShinyApp"
if (!file.exists(file.path(app_dir, "app.R")))
  stop("Run this from the repo root: ", file.path(app_dir, "app.R"), " not found.")

old <- setwd(app_dir)
on.exit(setwd(old), add = TRUE)

# Evaluate app.R except its final shinyApp() call, so the app's data prep and
# coverage functions land in this session without starting a server.
E  <- new.env(parent = globalenv())
ex <- parse("app.R")
src <- vapply(ex, function(e) paste(deparse(e), collapse = ""), character(1))
for (e in ex[!grepl("^shinyApp\\(", src)]) eval(e, envir = E)
setwd(old)

if (is.null(E$cohorts) || !nrow(E$cohorts))
  stop("No cohorts loaded from _keys/species_cohorts.csv.")

by_trait <- list(); summ <- list(); vars <- list(); missing <- character(0)

for (ch in E$cohort_levels) {
  k  <- E$cohort_species(ch)
  cm <- E$cohort_domain_matrix(ch)
  tt <- E$cohort_trait_table(ch)
  n  <- nrow(k)

  if (any(!k$in_data))
    missing <- c(missing, sprintf("%s: %s", ch,
                 paste(k$species_sci[!k$in_data], collapse = ", ")))

  tt$cohort <- ch
  by_trait[[ch]] <- tt[, c("cohort", "Variable", "Domain",
                           "Species_with_data", "Pct", "Missing_species")]

  sp_cov <- colSums(cm$mat > 0)
  summ[[ch]] <- data.frame(
    cohort            = ch,
    cohort_label      = unname(E$cohort_label_of[[ch]]),
    cohort_n          = n,
    domain            = names(sp_cov),
    species_with_data = as.integer(sp_cov),
    pct_species       = round(100 * as.integer(sp_cov) / n, 1),
    traits_held       = as.integer(colSums(cm$mat)),
    stringsAsFactors  = FALSE)

  v <- k[k$variant_values > 0, , drop = FALSE]
  if (nrow(v)) vars[[ch]] <- data.frame(
    cohort             = ch,
    species_sci        = v$species_sci,
    counted_as         = v$label_str,
    uncounted_variants = v$variants,
    uncounted_values   = v$variant_values,
    note               = if ("note" %in% names(v)) v$note else "",
    stringsAsFactors   = FALSE)
}

w <- function(d, f) {
  p <- file.path(outdir, f)
  write.csv(d, p, row.names = FALSE, na = "")
  cat(sprintf("  %-34s %5d rows\n", f, nrow(d)))
}
cat("cohort coverage report\n")
w(do.call(rbind, by_trait), "cohort_coverage_by_trait.csv")
w(do.call(rbind, summ),     "cohort_coverage_summary.csv")
w(if (length(vars)) do.call(rbind, vars) else
    data.frame(cohort = character(0), species_sci = character(0),
               counted_as = character(0), uncounted_variants = character(0),
               uncounted_values = integer(0), note = character(0)),
  "cohort_name_variants.csv")

cat("\nper cohort:\n")
for (ch in E$cohort_levels) {
  k <- E$cohort_species(ch); tt <- by_trait[[ch]]; n <- nrow(k)
  any_d <- tt[tt$Species_with_data > 0, ]
  cat(sprintf("  %-6s n=%2d  complete traits=%4d  traits with any data=%4d  fill=%3.0f%%\n",
      ch, n, sum(tt$Species_with_data == n), nrow(any_d),
      if (nrow(any_d)) 100 * sum(any_d$Species_with_data) / (n * nrow(any_d)) else 0))
}

# ---- Concept-boundary guard -------------------------------------------------
# A pooled lookup_name may adopt a label that the taxon-concept registry treats
# as a NON-DECOMPOSABLE pooled concept -- one whose believed composition spans
# more taxa than the cohort species. `Gorilla sp. (indet.)` is the live case:
# the registry reads it as Gorilla gorilla + Gorilla beringei pooled, while
# every row currently carrying that label in volumes_long.csv prints
# `Gorilla gorilla`. The cohort decision rests on that present content, not on
# the label's general meaning, so it stops being safe the moment a
# beringei-printed row enters the merge. This reports the exposure instead of
# leaving it to be noticed later.
reg_path <- "_keys/specimen_crosswalk/taxon_concept_registry.csv"
if (file.exists(reg_path)) {
  reg <- read.csv(reg_path, stringsAsFactors = FALSE, check.names = FALSE)
  reg$bare <- trimws(sub("\\s*\\(.*$", "", reg$taxon_concept))
  nd <- reg[toupper(as.character(reg$decomposable)) == "FALSE", , drop = FALSE]
  warn <- character(0)
  for (ch in E$cohort_levels) {
    k <- E$cohort_species(ch)
    for (i in which(nzchar(k$lookup_name))) {
      hit <- nd[nd$bare %in% k$labels[[i]] | nd$taxon_concept %in% k$labels[[i]], , drop = FALSE]
      for (j in seq_len(nrow(hit))) {
        comp <- trimws(strsplit(hit$superseded_by[j], ";")[[1]])
        comp <- comp[nzchar(comp) & comp != "NA"]
        extra <- setdiff(comp, k$labels[[i]])
        if (length(extra))
          warn <- c(warn, sprintf(
            "%s / %s adopts '%s', a non-decomposable concept whose believed composition also includes: %s",
            ch, k$species_sci[i], hit$taxon_concept[j], paste(extra, collapse = ", ")))
      }
    }
  }
  if (length(warn)) {
    cat("\nconcept-boundary exposure (report, not an error):\n")
    for (w in warn) cat("  - ", w, "\n", sep = "")
    cat("  Each is safe only while no row under that label prints an unadopted member.\n",
        "  Verify with the species_printed column of the relevant __merging_* long file.\n", sep = "")
  }
}

if (length(missing)) {
  cat("\n")
  stop("cohort members absent from the compiled data (add an alias in ",
       "_keys/species_display_aliases.csv or a lookup_name in ",
       "_keys/species_cohorts.csv):\n  ", paste(missing, collapse = "\n  "))
}
cat("\nOK: every cohort member resolves to compiled data.\n")
