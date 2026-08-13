# Matano__1986_TableI_compare_to_TableIII_csv.R
#
# QA for the Matano 1986 Table I build.
#
# This source has no curated project CSV and no Adobe export to audit against --
# the PDF is a scan with no text layer, so Table I had to be OCR'd. The paper
# supplies its own independent check instead: Table III prints each nucleus as a
# PERCENTAGE of the vestibular complex, computed by the author from the same
# underlying (unrounded) volumes. Recomputing those percentages from the Table I
# volumes therefore audits the transcription: a single mis-read digit in any
# nucleus or in the complex shifts the percentage well outside rounding noise.
#
# Two checks, over all 46 species:
#   1. nucleus / complex * 100  vs the printed Table III percentage   (tol 0.35 pp)
#   2. superior+lateral+medial+descending  vs the printed complex     (tol 1.2 %)
#
# The tolerances absorb the fact that Table I is printed to 3 significant figures
# while Table III was computed from the unrounded values.
#
# Table III itself is NOT merged data -- percentages are derived and are excluded
# from the build by HOWTO section 7. It is held here, in comparison/, purely as
# the audit anchor.
#
# Inputs : ../Matano__1986_TableI.csv
#          Matano__1986_TableIII_printed_percentages.csv
# Outputs: Matano__1986_TableI_comparison_report_from_R.csv     (230 rows: 46 x 5 checks)
#          Matano__1986_TableI_comparison_mismatches_from_R.csv (required: 0 rows)

suppressPackageStartupMessages({ library(readr); library(dplyr); library(tidyr) })

folder <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(dirname(normalizePath(sub("^--file=", "", a[1]))))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(dirname(normalizePath(rstudioapi::getSourceEditorContext()$path)))
  stop("Run with Rscript, or Source in RStudio.", call. = FALSE)
})
setwd(folder)

tab1 <- read_csv("../Matano__1986_TableI.csv", show_col_types = FALSE)
tab3 <- read_csv("Matano__1986_TableIII_printed_percentages.csv", show_col_types = FALSE)

stopifnot(nrow(tab1) == 46L, nrow(tab3) == 46L,
          setequal(tab1$Species_Matano1986, tab3$Species_Matano1986))

nuc <- c(superior   = "Nucleus_vestibularis_superior_unilateral_mm3",
         lateral    = "Nucleus_vestibularis_lateralis_unilateral_mm3",
         medial     = "Nucleus_vestibularis_medialis_unilateral_mm3",
         descending = "Nucleus_vestibularis_descendens_unilateral_mm3")
cx <- "Complexus_vestibularis_unilateral_mm3"

pct <- lapply(names(nuc), function(k) {
  tibble(Species_Matano1986 = tab1$Species_Matano1986,
         check             = k,
         value_TableI      = tab1[[nuc[[k]]]],
         complex_TableI    = tab1[[cx]],
         recomputed        = round(tab1[[nuc[[k]]]] / tab1[[cx]] * 100, 3),
         printed_TableIII  = tab3[[paste0(k, "_pct")]][match(tab1$Species_Matano1986,
                                                             tab3$Species_Matano1986)]) %>%
    mutate(difference = round(recomputed - printed_TableIII, 3),
           status     = ifelse(abs(difference) <= 0.35, "OK", "MISMATCH"))
}) %>% bind_rows()

sumchk <- tibble(Species_Matano1986 = tab1$Species_Matano1986,
                 check            = "complex_sum_check",
                 value_TableI     = round(rowSums(tab1[, unname(nuc)]), 3),
                 complex_TableI   = tab1[[cx]]) %>%
  mutate(recomputed       = value_TableI,
         printed_TableIII = complex_TableI,
         difference       = round((value_TableI - complex_TableI) / complex_TableI * 100, 3),
         status           = ifelse(abs(difference) <= 1.2, "OK", "MISMATCH"))

report <- bind_rows(pct, sumchk) %>%
  arrange(match(Species_Matano1986, tab1$Species_Matano1986),
          match(check, c(names(nuc), "complex_sum_check")))

write_csv(report, "Matano__1986_TableI_comparison_report_from_R.csv")
mismatches <- report %>% filter(status == "MISMATCH")
write_csv(mismatches, "Matano__1986_TableI_comparison_mismatches_from_R.csv")

message("Checks: ", nrow(report), " | mismatches: ", nrow(mismatches))
if (nrow(mismatches) > 0L) stop("Table I does not reproduce the printed Table III -- fix the snapshot.")
message("PASS: all 46 species reproduce the printed Table III percentages and sum to the printed complex.")
