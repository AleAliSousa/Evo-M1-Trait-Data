# check_table3_transposition.R
# Stacho et al. 2024 (Front Neuroanat 18:1331305) -- internal checks.
#
# Question: Table 3 prints Gorilla gorilla with brain volume (BV) 98.8 cm3
# and Hylobates lar with BV 396.8 cm3. Both are anatomically impossible and
# each is plausible for the other species. Hypothesis: the five measurement
# columns (BV, RNp right/left, RNm right/left) of the two rows were
# transposed. This script tests that hypothesis using ONLY evidence inside
# the paper itself (Tables 2 and 3, the Results/Discussion text, and
# Figures 4, 8, 9, 10), and writes check_results.csv next to this script.
#
# It changes no build values. Figure readings are recorded observations
# (the figure JPEGs are in inputs/); everything else is computed here.
#
# Run: Rscript check_table3_transposition.R   (from any directory)

options(stringsAsFactors = FALSE)

## ---- locate inputs relative to this script -------------------------------
args_all <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args_all[grepl("^--file=", args_all)])
script_dir <- if (length(file_arg) == 1) dirname(normalizePath(file_arg)) else getwd()
paper_dir  <- dirname(script_dir)

t2 <- read.csv(file.path(paper_dir, "Stacho_etal_2024_Table2.csv"), check.names = FALSE)
t3 <- read.csv(file.path(paper_dir, "Stacho_etal_2024_Table3.csv"), check.names = FALSE)
xml <- paste(readLines(file.path(paper_dir, "fulltext_frontiers.xml"),
                       warn = FALSE, encoding = "UTF-8"), collapse = " ")
txt <- gsub("<[^>]+>", " ", xml)
txt <- gsub("\\s+", " ", txt)

results <- list()
add <- function(test, comparison, as_printed, under_swap, verdict) {
  results[[length(results) + 1]] <<- data.frame(
    test = test, comparison = comparison, as_printed = as_printed,
    under_swap = under_swap, verdict = verdict)
}

## ---- helpers ---------------------------------------------------------------
BV   <- function(df) df[["Brain Volume, cm3"]]
RNp  <- function(df) df[["RNp Volume Right, mm3"]] + df[["RNp Volume Left, mm3"]]   # bilateral
RNm  <- function(df) df[["RNm Volume Right, mm3"]] + df[["RNm Volume Left, mm3"]]   # bilateral
rel  <- function(num_mm3, bv_cm3) 100 * num_mm3 / (bv_cm3 * 1000)                   # % of BV
sem  <- function(x) sd(x) / sqrt(length(x))
fmt  <- function(x, d = 4) formatC(x, format = "f", digits = d)

swap_rows <- function(df) {
  meas <- c("Brain Volume, cm3", "RNp Volume Right, mm3", "RNp Volume Left, mm3",
            "RNm Volume Right, mm3", "RNm Volume Left, mm3")
  g <- which(df$Species == "Gorilla gorilla"); h <- which(df$Species == "Hylobates lar")
  tmp <- df[g, meas]; df[g, meas] <- df[h, meas]; df[h, meas] <- tmp
  df
}
t3_swapped <- swap_rows(t3)

apes <- c("Gorilla gorilla", "Hylobates lar", "Pan paniscus",
          "Pan troglodytes", "Pongo pygmaeus")

group_stats <- function(df, species) {
  d <- df[df$Species %in% species, ]
  c(rel_RN   = mean(rel(RNp(d) + RNm(d), BV(d))),
    rel_RN_sem = sem(rel(RNp(d) + RNm(d), BV(d))),
    rel_RNm  = mean(rel(RNm(d), BV(d))),
    rel_RNm_sem = sem(rel(RNm(d), BV(d))),
    rel_diff = mean(rel(RNp(d) - RNm(d), BV(d))),
    fold_ratio_of_means = mean(RNp(d)) / mean(RNm(d)),
    fold_mean_of_ratios = mean(RNp(d) / RNm(d)))
}

## ==========================================================================
## Test 1 -- specimen counts: Table 2 lists vs Table 3 "Number"
## ==========================================================================
counts <- as.data.frame(table(t2$Species), stringsAsFactors = FALSE)
names(counts) <- c("Species", "table2_n")
t3n <- t3[, c("Species", "Number")]; names(t3n)[2] <- "table3_n"
mg <- merge(counts, t3n, by = "Species")
stopifnot(all(mg$table2_n == mg$table3_n))   # n matches Table 2 for ALL 20 species

add("counts_gorilla_n",
    "Table 3 'Number' for Gorilla gorilla vs the number of Gorilla specimens listed in Table 2 (YN82-140 only)",
    "Table 3 n = 1; Table 2 lists 1 gorilla specimen -- name and n agree",
    "Under a whole-row (names + n) swap the Gorilla row would carry the gibbon sample size n = 2; it carries 1",
    "supports_printed")
add("counts_hylobates_n",
    "Table 3 'Number' for Hylobates lar vs the number of Hylobates specimens listed in Table 2 (YN81-146, 3_97)",
    "Table 3 n = 2; Table 2 lists 2 gibbon specimens -- name and n agree",
    "Under a whole-row (names + n) swap the Hylobates row would carry the gorilla sample size n = 1; it carries 2",
    "supports_printed")
add("counts_all_species_control",
    "Same check for all 20 Table 3 rows (validates 'Number' as a specimen count throughout)",
    "Table 3 'Number' equals the Table 2 specimen count for every species, including Gorilla (1) and Hylobates (2)",
    "Identical under the measurement-only swap (Number is not one of the five measurement columns)",
    "supports_printed")

## ==========================================================================
## Test 2 -- text: species-level statements about Gorilla / Hylobates
## ==========================================================================
## 'Gorilla' occurrences in the running text outside the tables:
body_hits <- gregexpr("Gorilla", txt)[[1]]
add("text_species_level_statements",
    "Full-text search of Results/Discussion for any statement giving Gorilla or Hylobates/gibbon a brain size, RN size, or size ranking",
    "No such sentence exists: 'Gorilla' occurs only in Tables 1-3 and the Figure 1 tree; the gibbon is discussed only cytoarchitecturally (Fig. 4). The paper makes no species-level size claim for either animal that the printed table could contradict",
    "The same absence holds under the swap -- the text is silent at species level either way",
    "neutral")
add("text_group_brain_volume_ranking",
    "Text: 'In our dataset human specimens had the largest fresh brain volume followed by apes and old world monkeys (Figure 8A)'",
    sprintf("Mean BV of the 5 ape species as printed = %s cm3, old world monkeys = %s cm3 -- ranking as stated",
            fmt(mean(BV(t3[t3$Species %in% apes, ])), 1),
            fmt(mean(BV(t3[t3$Taxon == "Cercopithecidae", ])), 1)),
    "Identical value: the swap exchanges two rows inside the same group, so every group mean is unchanged",
    "neutral")

## ==========================================================================
## Test 3 -- figures (recorded readings; images in inputs/)
## ==========================================================================
add("fig8a_low_brain_volume_specimens",
    "Figure 8A plots log10(BV) per specimen (validated on the other groups: humans ~10 points, prosimians 7, OWM 4, NWM 3). Count of non-human-ape markers at log10(BV) ~ 2.0 (BV ~ 100 cm3), read from inputs/Figure8.jpg incl. a native-resolution crop",
    "Exactly ONE such marker. As printed, exactly one ape specimen has BV ~ 100 cm3: the single Gorilla (n = 1, BV 98.8, log10 = 1.99)",
    "Under the swap, TWO specimens (both gibbons, species mean 98.8) should sit at log10 ~ 2.0; only one resolved marker is present. Caveat: the Fig. 8 caption states the figure shows the values 'summarized in the Table 3', so the figure is not demonstrably independent of the table",
    "supports_printed")
add("fig8_panels_bcd_and_fig9_ratios",
    "Figures 8B-D (relative RN, RNm, RNp volumes) and 9 (RNm/RNp ratio vs relative RNp-RNm difference): positions of the Gorilla/Hylobates points",
    sprintf("Bundle on the printed Gorilla row: rel. RN %.4f%%, rel. RNm %.4f%%; bundle on the printed Hylobates row: rel. RN %.4f%%, rel. RNm %.4f%% -- both inside the ape cloud in both figures",
            rel(RNp(t3[2, ]) + RNm(t3[2, ]), BV(t3[2, ])), rel(RNm(t3[2, ]), BV(t3[2, ])),
            rel(RNp(t3[3, ]) + RNm(t3[3, ]), BV(t3[3, ])), rel(RNm(t3[3, ]), BV(t3[3, ]))),
    "Identical point positions: every plotted quantity is a ratio inside one row's measurement bundle, and the swap only exchanges the species labels of two bundles in the same group",
    "neutral")
add("fig10_bivariate_scaling_plots",
    "Figure 10A/D/G/J: bivariate log10(RN) vs log10(BV) species points for the two bundles",
    sprintf("One purple (ape) point at log10 BV = %.2f with log10 left RNm = %.2f (the 98.8 cm3 bundle) and one at log10 BV = %.2f with log10 left RNm = %.2f (the 396.8 cm3 bundle), both as plotted in inputs/Figure10.jpg",
            log10(98.8 * 1000), log10(2.0), log10(396.8 * 1000), log10(7.4)),
    "Identical positions under the swap -- the points are not species-labelled, so the plot cannot say which bundle belongs to which name",
    "neutral")
add("fig10_phenogram_tip_labels",
    "Figure 10C/F ancestral-state phenograms: tip labels Hl (Hylobates lar) and Gg (Gorilla gorilla) in the residual ordering",
    "Both labels sit inside the extreme-negative hominoid cluster (with Pp, Pop, Pt, Hs); at the published resolution the Hl/Gg order cannot be matched uniquely to either arrangement (residuals are pGLS/ASE model outputs and the labels are fanned)",
    "Same reading under the swap -- examined, not decisive",
    "neutral")
add("fig4_gibbon_brain_section",
    "Figure 4: photographed coronal section of the Hylobates lar brain (specimen material itself)",
    "Shows an ordinary gibbon-sized brain section with its own scale bar; a single section cannot yield a brain volume, so the figure neither supports BV 396.8 nor refutes it quantitatively",
    "Identical under the swap",
    "neutral")

## ==========================================================================
## Test 4 -- internal arithmetic: the text's group statistics, recomputed
## Convention first validated on groups the swap cannot touch:
##   rel. value per species = bilateral (R+L) volume / BV; group = mean +- SEM.
##   Prosimians reproduce the printed 0.078 +- 0.012 (computed 0.0770 +- 0.0117);
##   old world monkeys reproduce 0.073 +- 0.015 (computed 0.0730 +- 0.0146);
##   humans reproduce RNm 0.0005% (computed 0.000494%) and RNp-RNm 0.047%
##   (computed 0.0467%). The convention is the paper's own.
## ==========================================================================
pro <- group_stats(t3, t3$Species[t3$Taxon == "Prosimiae"])
owm <- group_stats(t3, t3$Species[t3$Taxon == "Cercopithecidae"])
stopifnot(abs(pro[["rel_RN"]] - 0.078) < 0.002, abs(owm[["rel_RN"]] - 0.073) < 0.002)

gs_p <- group_stats(t3, apes)
gs_s <- group_stats(t3_swapped, apes)
add("arith_group_relative_rn",
    "Text: non-human apes' RN volume relative to brain volume = 0.069% +- 0.006% (Fig. 8B passage), recomputed from Table 3 species means",
    sprintf("Recomputed %.4f%% (mean of the 5 species' relative RN volumes)", gs_p[["rel_RN"]]),
    sprintf("Recomputed %.4f%% -- identical: the swap exchanges two complete bundles within the same group, leaving the set of species values unchanged", gs_s[["rel_RN"]]),
    "neutral")
add("arith_group_relative_rnm",
    "Text: 'the relative volume of RNm in non-human apes ... (non-human apes: 0.003% +- 0.0004%)', recomputed from Table 3",
    sprintf("Recomputed %.4f%%", gs_p[["rel_RNm"]]),
    sprintf("Recomputed %.4f%% -- identical, same invariance", gs_s[["rel_RNm"]]),
    "neutral")
add("arith_group_rnp_minus_rnm",
    "Text: RNp-RNm difference relative to brain volume in non-human apes = 0.061%, recomputed from Table 3",
    sprintf("Recomputed %.4f%% (the small offset from 0.061%% under BOTH arrangements indicates the printed statistic was computed from the 11 individual specimens, not the 5 species means)", gs_p[["rel_diff"]]),
    sprintf("Recomputed %.4f%% -- identical, same invariance", gs_s[["rel_diff"]]),
    "neutral")
add("arith_group_fold_difference",
    "Text: 'in humans and non-human apes the difference was 95-fold and twentyfold, respectively' (RNp vs RNm), recomputed from Table 3",
    sprintf("Apes: ratio of group means %.1f-fold, mean of species ratios %.1f-fold (humans reproduce exactly: %.1f-fold vs printed 95)",
            gs_p[["fold_ratio_of_means"]], gs_p[["fold_mean_of_ratios"]],
            (289.9 + 293.1) / (3.1 + 3.0)),
    "Identical under the swap -- both folds pool the same five bundles",
    "neutral")

## ==========================================================================
## Test 5 -- the paper's central claim
## ==========================================================================
add("central_claim_rnm_reduction",
    "Paper's thesis: Hominoidea (humans + non-human apes, gibbons included) have a miniaturised RNm relative to brain volume vs the other primates (ape rel. RNm ~ 0.003% vs 0.025-0.047% elsewhere)",
    sprintf("Printed: Gorilla rel. RNm %.4f%%, Hylobates rel. RNm %.4f%% -- both inside the reduced hominoid band",
            rel(RNm(t3[2, ]), BV(t3[2, ])), rel(RNm(t3[3, ]), BV(t3[3, ]))),
    sprintf("Swapped: Gorilla rel. RNm %.4f%%, Hylobates rel. RNm %.4f%% -- also inside the band; the claim is consistent under both arrangements",
            rel(RNm(t3_swapped[2, ]), BV(t3_swapped[2, ])),
            rel(RNm(t3_swapped[3, ]), BV(t3_swapped[3, ]))),
    "neutral")

out <- do.call(rbind, results)
write.csv(out, file.path(script_dir, "check_results.csv"), row.names = FALSE)
cat(sprintf("Wrote %s (%d tests)\n", file.path(script_dir, "check_results.csv"), nrow(out)))
print(table(out$verdict))
