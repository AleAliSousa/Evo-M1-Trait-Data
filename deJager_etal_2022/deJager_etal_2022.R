# deJager_etal_2022.R
#
# Purpose
#   Validate and expose the extant-human vertebral-artery calibration of de Jager et al.
#   (2022): per cervical level (C2-C6) and side, the log10-log10 regression predicting
#   vertebral-artery cross-sectional area from transverse-foramen cross-sectional area.
#   C1 (atlas) is excluded -- foramen and artery areas are not correlated there.
#
#   This is a CALIBRATION table, not fossil data. It is the vertebral-artery analogue of
#   Seymour_etal_2015 (carotid) and the missing piece that would let a MEASURED fossil
#   transverse foramen replace the ECV-predicted VA in __merging_fossil_brain_glucose/
#   (the current Boyer_ACA_ecvpred upper bound).
#
#   de Jager E, Prigge L, Amod N, Oettle A, Beaudet A (2022). Exploring the relationship
#   between soft and hard tissues: the example of vertebral arteries and transverse
#   foramina. J. Anat. 241(2), 447-452. doi:10.1111/joa.13681
#
# Inputs
#   deJager_etal_2022_calibration.csv   Table 2 coefficients, C2-C6 x {right,left,both}
#   deJager_etal_2022_Table1.csv        Table 1 descriptive areas, C1-C6
#
# Outputs
#   deJager_etal_2022_calibration_check.csv   per-row internal-consistency report
#   console PASS/FAIL summary
#
# WHY THERE IS NO REFIT
#   House policy for Boyer/Seymour is refit-and-verify from raw values. No per-individual
#   areas are published here, so that is not possible (see the README for exactly what the
#   authors do and do not say about data availability). The coefficients are therefore
#   transcribed, and verified four ways instead:
#     (a) text-vs-table  -- the three C2 equations quoted in the running text on p. 450 must
#         reproduce the C2 rows of Table 2;
#     (b) prediction-at-the-mean -- pushing each level's mean foramen area (Table 1) through
#         its own equation must land near that level's mean artery area (Table 1);
#     (c) schema and range-coherence assertions;
#     (d) published-summary reproduction -- the paper's stated "arteries occupy ~35% of the
#         foramina" must fall out of the transcribed Table 1 unaided.
#   (b) is a weak check by construction: a log10-log10 fit passes through the mean of the LOGS,
#   so back-transforming yields a geometric-mean-like value that sits slightly BELOW the
#   arithmetic mean printed in Table 1. A small negative bias is expected, not an error.
#
# ---------------------------------------------------------------------------

calib <- read.csv("deJager_etal_2022_calibration.csv", comment.char = "#",
                  stringsAsFactors = FALSE)
tab1  <- read.csv("deJager_etal_2022_Table1.csv", comment.char = "#",
                  stringsAsFactors = FALSE)

fail <- character(0)
chk  <- function(cond, msg) if (!isTRUE(cond)) fail <<- c(fail, msg)

## --- 1. Schema / sanity assertions -----------------------------------------

need <- c("level", "response", "predictor", "transform", "slope", "intercept",
          "r2", "r", "p_value", "n", "side", "significant",
          "foramen_area_min_mm2", "foramen_area_max_mm2", "note")
chk(all(need %in% names(calib)), "calibration.csv is missing expected columns")

chk(!"C1" %in% calib$level,
    "C1 must NOT appear in the calibration file (atlas foramen/artery areas are uncorrelated)")
chk(setequal(unique(calib$level), c("C2", "C3", "C4", "C5", "C6")),
    "calibration levels should be exactly C2..C6")
chk(setequal(unique(calib$side), c("right", "left", "both")),
    "calibration sides should be exactly right/left/both")
chk(nrow(calib) == 15L, "expected 15 calibration rows (5 levels x 3 sides)")
chk(all(calib$transform == "log10"), "all rows must be fitted on the log10-log10 scale")
chk(all(calib$response == "VA_area_mm2" & calib$predictor == "TF_area_mm2"),
    "response/predictor columns are not as expected")
chk(all(calib$r > 0 & calib$r <= 1), "Pearson r out of (0,1]")
chk(all(calib$significant == "yes"),
    "only significant (footnote-a) rows belong in this file")
chk(all(is.na(calib$r2)),
    "r2 must stay blank -- Table 2 prints r only; the Table S1 R2 is cross-validated, not r^2")
chk(all(calib$foramen_area_min_mm2 < calib$foramen_area_max_mm2),
    "foramen-area range is inverted somewhere")

## --- 2. Verification (a): text-vs-table for C2 ------------------------------
# p. 450 quotes, with x = artery area and y = foramen area:
#   right      log(x) = 1.098  * log(y) - 0.6844
#   left       log(x) = 1.0081 * log(y) - 0.4974
#   both sides log(x) = 0.8718 * log(y) - 0.3
quoted <- data.frame(
  side      = c("right", "left", "both"),
  slope     = c(1.0980, 1.0081, 0.8718),
  intercept = c(-0.6844, -0.4974, -0.3000),
  stringsAsFactors = FALSE
)
c2 <- merge(quoted, subset(calib, level == "C2"), by = "side", suffixes = c(".txt", ".tab"))
chk(nrow(c2) == 3L, "could not match all three quoted C2 equations")
chk(isTRUE(all.equal(c2$slope.txt, c2$slope.tab, tolerance = 1e-9)),
    "C2 slopes in the running text disagree with Table 2 as transcribed")
chk(isTRUE(all.equal(c2$intercept.txt, c2$intercept.tab, tolerance = 1e-9)),
    "C2 intercepts in the running text disagree with Table 2 as transcribed")

## --- 3. Verification (b): prediction at the mean foramen area ---------------

predict_VA <- function(TF_area_mm2, slope, intercept) {
  10^(slope * log10(TF_area_mm2) + intercept)
}

foramen <- subset(tab1, structure == "transverse_foramen" & level != "all")
artery  <- subset(tab1, structure == "vertebral_artery"   & level != "all")

# per-level mean of the two sides, to compare against side = "both"
mean_by_level <- function(d) {
  a <- aggregate(mean_mm2 ~ level, data = d, FUN = mean)
  a$side <- "both"
  a[, c("level", "side", "mean_mm2")]
}
f_all <- rbind(foramen[, c("level", "side", "mean_mm2")], mean_by_level(foramen))
a_all <- rbind(artery [, c("level", "side", "mean_mm2")], mean_by_level(artery))
names(f_all)[3] <- "TF_mean_mm2"
names(a_all)[3] <- "VA_mean_mm2"

chkdf <- merge(merge(calib[, c("level", "side", "slope", "intercept", "r")],
                     f_all, by = c("level", "side")),
               a_all, by = c("level", "side"))
chkdf$VA_predicted_mm2 <- predict_VA(chkdf$TF_mean_mm2, chkdf$slope, chkdf$intercept)
chkdf$pct_diff <- 100 * (chkdf$VA_predicted_mm2 - chkdf$VA_mean_mm2) / chkdf$VA_mean_mm2
chkdf <- chkdf[order(chkdf$level, chkdf$side), ]

# Tolerance 15%: back-transformed log-log predictions sit below the arithmetic mean by
# construction, so this bounds the retransformation bias rather than testing exactness.
chk(all(abs(chkdf$pct_diff) < 15),
    sprintf("prediction-at-the-mean off by >15%% for: %s",
            paste(with(subset(chkdf, abs(pct_diff) >= 15), paste0(level, "-", side)),
                  collapse = ", ")))

## --- 4. Range coherence between the two files -------------------------------

f_lvl <- subset(tab1, structure == "transverse_foramen" & level != "all")
env   <- merge(aggregate(min_mm2 ~ level, f_lvl, min),
               aggregate(max_mm2 ~ level, f_lvl, max), by = "level")
both  <- merge(subset(calib, side == "both",
                      c("level", "foramen_area_min_mm2", "foramen_area_max_mm2")),
               env, by = "level")
chk(isTRUE(all.equal(both$foramen_area_min_mm2, both$min_mm2)) &&
      isTRUE(all.equal(both$foramen_area_max_mm2, both$max_mm2)),
    "side='both' foramen ranges are not the outer envelope of the Table 1 ranges")

## --- 4b. Verification (d): reproduce the paper's published ~35% -------------
# Results and Discussion both state that the arteries occupy approximately 35% of the
# foramina. Recomputing that unaided from the transcribed Table 1 is an independent test
# that Table 1 was read correctly. NOTE: the Discussion says the figure was "computed
# using the measurements for C1-C2", but C1-C2 alone gives ~29.8%; C1-C6 gives ~35.2%.
# The printed level range is almost certainly a typo -- recorded, not corrected.

lvl   <- subset(tab1, level != "all")
ratio <- function(levels) {
  d <- subset(lvl, level %in% levels)
  100 * sum(d$mean_mm2[d$structure == "vertebral_artery"]) /
        sum(d$mean_mm2[d$structure == "transverse_foramen"])
}
pct_C1C6 <- ratio(c("C1", "C2", "C3", "C4", "C5", "C6"))
pct_C1C2 <- ratio(c("C1", "C2"))
chk(abs(pct_C1C6 - 35) < 1,
    sprintf("VA/TF area ratio over C1-C6 is %.1f%%, not the paper's ~35%%", pct_C1C6))

# Paper-internal inconsistency, correctly transcribed and flagged here rather than fixed:
# the printed overall LF mean (32.24) is not the mean of the six printed LF level means
# (32.40). RA and LA reconcile exactly; RF differs only by rounding. The "all" row is the
# paper's own summary line, so it is preserved as printed.
lf_recomputed <- mean(subset(lvl, variable == "LF")$mean_mm2)
lf_printed    <- subset(tab1, level == "all" & variable == "LF")$mean_mm2

## --- 5. Report --------------------------------------------------------------

write.csv(chkdf, "deJager_etal_2022_calibration_check.csv", row.names = FALSE)

cat("\nde Jager et al. 2022 calibration -- internal consistency\n")
cat("-------------------------------------------------------\n")
print(within(chkdf, {
  TF_mean_mm2      <- round(TF_mean_mm2, 2)
  VA_mean_mm2      <- round(VA_mean_mm2, 2)
  VA_predicted_mm2 <- round(VA_predicted_mm2, 2)
  pct_diff         <- round(pct_diff, 1)
}), row.names = FALSE)

cat(sprintf("\nVA area as %% of TF area: C1-C6 = %.1f%% (paper: ~35%%); C1-C2 = %.1f%%\n",
            pct_C1C6, pct_C1C2))
cat(sprintf("Paper-internal note: printed overall LF mean %.2f vs mean of level means %.2f\n",
            lf_printed, lf_recomputed))

if (length(fail)) {
  cat("\nFAIL:\n"); cat(paste0("  - ", fail, collapse = "\n"), "\n")
  stop("deJager_etal_2022.R: validation failed")
} else {
  cat("\nPASS: schema, C2 text-vs-table, prediction-at-the-mean, and range coherence all OK.\n")
}

## --- 6. Convenience accessor for downstream use -----------------------------
# Not written to disk; source() this file and call estimate_VA_area() when wiring a merge.
#
#   estimate_VA_area(TF_area_mm2 = 32.7, level = "C4", side = "both")
#
# warn_outside_range = TRUE flags extrapolation beyond the extant-human calibration span.
# SCOPE LIMIT: the authors explicitly recommend applying these equations to FOSSIL HUMANS
# ONLY (calibrated on 16 modern humans; no non-human sample). Using them on an australopith
# is an extrapolation the paper does not endorse -- see the README caveats.

estimate_VA_area <- function(TF_area_mm2, level, side = "both", warn_outside_range = TRUE) {
  row <- calib[calib$level == level & calib$side == side, ]
  if (nrow(row) != 1L) stop("no calibration row for level=", level, " side=", side)
  if (warn_outside_range &&
      (TF_area_mm2 < row$foramen_area_min_mm2 || TF_area_mm2 > row$foramen_area_max_mm2)) {
    warning(sprintf("TF area %.2f mm2 is outside the calibrated range %.2f-%.2f mm2 for %s/%s",
                    TF_area_mm2, row$foramen_area_min_mm2,
                    row$foramen_area_max_mm2, level, side))
  }
  10^(row$slope * log10(TF_area_mm2) + row$intercept)
}

## ---- DOI-coded public TSV for Table 1 (sec 4, invariant 2) -------------------------------
## Added 2026-08-05. deJager_etal_2022_Table1.csv is BOTH the frozen source and the data: a
## hand transcription of the printed Table 1 carrying its provenance in leading "#" comment
## lines. The published table is that file with the comment header stripped - same rows, same
## columns, nothing recomputed.
local({
  base <- local({
    d <- getwd()
    while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
    if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
  })
  if (is.na(base)) { warning("Repo root not found; public TSV skipped."); return(invisible(NULL)) }
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc     <- filecodes$"Item encoded"[match("deJager_etal_2022_Table1", filecodes$"Item name")]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for deJager_etal_2022_Table1; public TSV skipped.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
  } else {
    write.table(tab1, file.path(tsv_dir, paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
})
