# deJager_etal_2022.R  --  SKELETON, waits on staged data (see this folder's README)
#
# Purpose
#   Build the extant-human vertebral-artery calibration of de Jager et al. (2022)
#   into a lean, analysis-ready CSV: per cervical level (C2-C6), the regression
#   predicting vertebral-artery cross-sectional area from transverse-foramen
#   cross-sectional area. C1 (atlas) is excluded -- foramen and artery areas are
#   not correlated there. This is a CALIBRATION table, not fossil data; it is the
#   vertebral-artery analogue of Seymour_etal_2015 (carotid) and the missing piece
#   that lets a measured fossil transverse foramen replace the ECV-predicted VA in
#   __merging_fossil_brain_glucose/ (the current Boyer_ACA_ecvpred upper bound).
#
#   de Jager E, Prigge L, Amod N, Oettle A, Beaudet A (2022). Exploring the
#   relationship between soft and hard tissues: the example of vertebral arteries
#   and transverse foramina. J. Anat. 241(4). doi:10.1111/joa.13681
#
# Inputs (TO BE ADDED -- see deJager_etal_2022.README.md "WHERE TO ADD FILES")
#   deJager_etal_2022_calibration.csv   per-level regression coefficients (min. needed)
#   deJager_etal_2022_raw_areas.csv     per-individual raw areas (optional; enables refit)
#
# Outputs (once inputs exist)
#   deJager_etal_2022_calibration.csv   validated, one row per usable level (C2-C6)
#   (later) a staged copy under __merging_fossil_brain_glucose/inputs/ when wired in
#
# ---------------------------------------------------------------------------
# NOTE: Do not run until the templates are filled and renamed (drop .TEMPLATE).
#       Everything below is stubbed with stop()/TODO so it fails loudly rather
#       than silently emitting placeholder numbers.
# ---------------------------------------------------------------------------

stop("deJager_etal_2022.R is a scaffold: add the paper's tables first (see README).")

## --- 1. Load ---------------------------------------------------------------
# calib <- read.csv("deJager_etal_2022_calibration.csv", comment.char = "#",
#                   stringsAsFactors = FALSE)

## --- 2. (Optional) refit from raw areas in house style ---------------------
# If deJager_etal_2022_raw_areas.csv is present, refit VA_area ~ TF_area per level
# and cross-check the fitted slope/intercept/r2 against the transcribed `calib`
# values (same refit-and-verify policy as the Boyer/Seymour builds). Respect the
# `transform` column (none/log10/ln) recorded from the paper.
#
# raw <- read.csv("deJager_etal_2022_raw_areas.csv", comment.char = "#")
# TODO: fit per level in {C2,C3,C4,C5,C6}; compare to calib; warn on mismatch.

## --- 3. Validate -----------------------------------------------------------
# TODO: assert C1 absent; assert areas in mm^2; assert 0 < r2 <= 1;
#       record calibrated foramen-area range for downstream extrapolation warnings.

## --- 4. Emit ---------------------------------------------------------------
# write.csv(calib, "deJager_etal_2022_calibration.csv", row.names = FALSE)
