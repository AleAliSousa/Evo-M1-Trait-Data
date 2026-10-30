# EvoM1: limb kinematics / locomotor posture (Medina-González 2026) -> gait_excursion_medina.xlsx
#
# Broad-coverage locomotion source for the behaviour merge (locomotion axis). Exposes the
# species-level summaries only (per-limb angular utilization index, limb posture, top speed,
# locomotor habit) for 182 records / 77 terrestrial mammals / 15+ orders; the per-joint excursion
# angles and per-record granularity stay in MedinaGonzález__2026_Data.csv (the frozen/analysis
# source), aggregated to one row per species HERE (§3 of the build HOWTO: aggregate to species
# means in the merge/reader step, not in the reformat).
# Correlatable beside locomotion.xlsx (Granatosky) and gait.xlsx (Wimberly).
#
# UNBLOCKED 2026-09: built from the journal's own online supplement (onlinelibrary.wiley.com/doi/
# 10.1002/jez.70069), not the still-restricted Zenodo deposit (10.5281/zenodo.15425733). See
# MedinaGonzález__2026/MedinaGonzález__2026.README.md.

invisible(suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8")))  # non-ASCII paths need a UTF-8 CTYPE locale
library(readxl); library(writexl)
## self-locate
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  frames <- sys.frames()
  for (i in rev(seq_along(frames))) {
    of <- frames[[i]]$ofile
    if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or source() in RStudio (save first).", call. = FALSE)
})
setwd(dirname(dirname(.sp)))          # repo root (this file lives in ____EvoM1_TraitTable/)
folder_path <- "./____EvoM1_TraitTable/"

item_name   <- "MedinaGonzález__2026_SupplementaryFile3"     # registered in __ReadMe.xlsx (Sheet1)
data_dir    <- list.files(".", pattern = "^MedinaGonz.*lez__2026$", full.names = TRUE)
if (length(data_dir) != 1L)
  stop("MedinaGonzález__2026/ folder not found at repo root.", call. = FALSE)
data_csv <- list.files(data_dir, pattern = "_SupplementaryFile3\\.csv$", full.names = TRUE)
if (length(data_csv) != 1L)
  stop("MedinaGonz\u00e1lez__2026_SupplementaryFile3.csv not built -- run ",
       "MedinaGonz\u00e1lez__2026_SupplementaryFile3.R first.", call. = FALSE)

d <- read.csv(data_csv, stringsAsFactors = FALSE, check.names = FALSE)

first_nonmissing <- function(x) { x <- x[!is.na(x) & nzchar(trimws(x))]; if (length(x)) x[1] else NA }
mean_na <- function(x) { x <- suppressWarnings(as.numeric(x)); if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE) }

agg <- do.call(rbind, lapply(split(d, d$Species), function(g) data.frame(
  species_sci                   = g$species_sci[1],
  Species                       = g$Species[1],
  Angular_utilization_index_FL  = mean_na(g$FL_Angular_Excursion_Efficiency_pct),
  Angular_utilization_index_HL  = mean_na(g$HL_Angular_Excursion_Efficiency_pct),
  Limb_posture                  = first_nonmissing(g$Posture),
  Top_speed                     = first_nonmissing(g$Top_speed_class),
  Locomotor_habit                = first_nonmissing(g$Locomotor_habit),
  n_records                     = nrow(g),
  stringsAsFactors = FALSE
)))
rownames(agg) <- NULL
agg <- agg[order(agg$Species), ]

write_xlsx(agg, paste0(folder_path, "gait_excursion_medina.xlsx"))
cat("gait_excursion_medina.xlsx:", nrow(agg), "species (from", nrow(d), "records)\n")
