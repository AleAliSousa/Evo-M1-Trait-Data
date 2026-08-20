# Bauernfeind_etal_2013_reconcile_to_Table3.R
#
# QA, not data. Two questions the merge needs answered before it can pool Bauernfeind's
# insula volumes properly, and both are answerable entirely from the published tables:
#
# 1. Is Table 3 (the paper's species means, with n and SD, per hemisphere per subdivision)
#    reproducible from the per-individual rows of Tables 1 and 2? If yes, the individual
#    rows ARE the sample behind the published value, so N is known exactly and pooling can
#    move out of the extraction step and into ../__merging_volumes where it belongs.
#      -> Bauernfeind_etal_2013_Table3_reconciliation.csv   (60 comparisons)
#
# 2. Which individuals have BOTH hemispheres measured? Only for those can a whole-insula
#    (left + right) volume be built from measurement rather than estimated as 2 x left.
#    This is only answerable now that the footnote markers have been split off the specimen
#    IDs in Bauernfeind_etal_2013_Table1.R -- before that, Table 1's "Nambob" and Table 2's
#    "Nambo" were different strings for the same brain.
#      -> Bauernfeind_etal_2013_bilateral_individuals.csv
#
# Inputs : Bauernfeind_etal_2013_Table1.csv  (43 individuals, LEFT)
#          Bauernfeind_etal_2013_Table2.csv  (15 individuals, RIGHT)
#          Bauernfeind_etal_2013_Table3.csv  (60 published species x hemisphere x subdivision)

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr); library(stringr)
})
## ---- paths: self-contained (Rscript or RStudio) ----
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
setwd(dirname(.sp))
options(scipen = 999)

t1 <- read_csv("Bauernfeind_etal_2013_Table1.csv", show_col_types = FALSE)
t2 <- read_csv("Bauernfeind_etal_2013_Table2.csv", show_col_types = FALSE)
t3 <- read_csv("Bauernfeind_etal_2013_Table3.csv", show_col_types = FALSE)

SUBDIV <- c(Granular = "granular", Dysgranular = "dysgranular", Agranular = "agranular",
            FI = "FI", Total = "total_insula")

## ---- 1. Table 3 reconciliation --------------------------------------------------------------
long_side <- function(d, side) {
  cols <- paste0(unname(SUBDIV), "_", side, "_mm3")
  d %>% select(Species, Individual, all_of(cols)) %>%
    pivot_longer(all_of(cols), names_to = "col", values_to = "value") %>%
    mutate(subdivision = names(SUBDIV)[match(str_remove(col, paste0("_", side, "_mm3")),
                                             unname(SUBDIV))],
           hemisphere  = if (side == "L") "left" else "right") %>%
    filter(!is.na(value)) %>% select(-col)
}
individuals <- bind_rows(long_side(t1, "L"), long_side(t2, "R"))

recomputed <- individuals %>%
  group_by(Species, hemisphere, subdivision) %>%
  summarise(n_individuals = dplyr::n(),
            mean_recomputed = mean(value),
            sd_recomputed   = if (dplyr::n() > 1) sd(value) else NA_real_,
            individuals_used = paste(sort(Individual), collapse = "; "),
            .groups = "drop")

reconciliation <- t3 %>%
  rename(published_n = n, published_mean = mean_mm3, published_sd = sd_mm3) %>%
  full_join(recomputed, by = c("Species", "hemisphere", "subdivision")) %>%
  mutate(n_agrees      = published_n == n_individuals,
         mean_pct_diff = 100 * (published_mean - mean_recomputed) / mean_recomputed,
         sd_pct_diff   = 100 * (published_sd - sd_recomputed) / sd_recomputed) %>%
  select(Species, hemisphere, subdivision, published_n, n_individuals, n_agrees,
         published_mean, mean_recomputed, mean_pct_diff,
         published_sd, sd_recomputed, sd_pct_diff, individuals_used) %>%
  arrange(Species, hemisphere, match(subdivision, names(SUBDIV)))
write_csv(reconciliation, "Bauernfeind_etal_2013_Table3_reconciliation.csv")

# The whole point: if every published n is reproduced, N is known and the merge may pool.
stopifnot(all(reconciliation$n_agrees))
message("Table 3 reconciliation: ", nrow(reconciliation), " comparisons, ",
        sum(reconciliation$n_agrees), " with matching n, max |mean diff| = ",
        sprintf("%.2f%%", max(abs(reconciliation$mean_pct_diff), na.rm = TRUE)))

## ---- 2. which brains have both hemispheres --------------------------------------------------
## A both-sides insula volume is a MEASUREMENT only where one animal was measured on both
## sides. Everywhere else the merge's step-7 2x-left figure is an estimate and stays flagged
## `estimated_bilateral_from_unilateral`. Note Pongo pygmaeus "Sabtu" (footnote c) has a right
## hemisphere but no left, so it is right-only despite appearing in Table 1.
lr <- t1 %>%
  select(Species, Individual, Collection, measurement_software,
         left_hemisphere_unavailable, ends_with("_L_mm3")) %>%
  full_join(t2 %>% select(Species, Individual, ends_with("_R_mm3")),
            by = c("Species", "Individual"))

bilateral <- lr %>%
  mutate(has_left  = !is.na(total_insula_L_mm3),
         has_right = !is.na(total_insula_R_mm3),
         sides_measured = case_when(has_left & has_right ~ "both",
                                    has_left            ~ "left only",
                                    has_right           ~ "right only",
                                    TRUE                ~ "neither"),
         total_insula_LR_mm3 = ifelse(has_left & has_right,
                                      total_insula_L_mm3 + total_insula_R_mm3, NA_real_),
         granular_LR_mm3     = granular_L_mm3    + granular_R_mm3,
         dysgranular_LR_mm3  = dysgranular_L_mm3 + dysgranular_R_mm3,
         agranular_LR_mm3    = agranular_L_mm3   + agranular_R_mm3,
         FI_LR_mm3           = FI_L_mm3          + FI_R_mm3,
         asymmetry_pct_total = 100 * (total_insula_L_mm3 - total_insula_R_mm3) /
                                     total_insula_LR_mm3) %>%
  select(Species, Individual, Collection, measurement_software, sides_measured,
         total_insula_L_mm3, total_insula_R_mm3, total_insula_LR_mm3, asymmetry_pct_total,
         granular_LR_mm3, dysgranular_LR_mm3, agranular_LR_mm3, FI_LR_mm3) %>%
  arrange(Species, Individual)
write_csv(bilateral, "Bauernfeind_etal_2013_bilateral_individuals.csv")

message("Bilateral: ", sum(bilateral$sides_measured == "both"), " of ", nrow(bilateral),
        " individuals measured on both sides (", sum(bilateral$sides_measured == "left only"),
        " left only, ", sum(bilateral$sides_measured == "right only"), " right only) across ",
        dplyr::n_distinct(bilateral$Species[bilateral$sides_measured == "both"]), " species")
