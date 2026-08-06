# QA: Kazu et al. 2015 CORRIGENDUM TABLE 1  vs  Kazu et al. 2014 Table 1
#
# The §7 comparison step. Unusually, the "independent curated copy" here is the SUPERSEDED
# printing of the same table, so the expected result is NOT zero mismatches - it is a complete,
# auditable list of everything the corrigendum changed. That list is the reason the 2014 build
# must not be merged.
#
# Both CSVs come from line-for-line parallel reformats (same parser, same label map, same column
# schema), so a column-by-column diff is meaningful.
#
# Writes: Kazu_etal_2015_TABLE1_vs_Kazu_2014_report.csv  (one row per changed cell)

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
here   <- dirname(.sp)                       # .../Kazu_etal_2015/comparison
paper  <- dirname(here)
root   <- dirname(paper)

new <- read.csv(file.path(paper, "Kazu_etal_2015_TABLE1.csv"), stringsAsFactors = FALSE,
                check.names = FALSE)
old <- read.csv(file.path(root, "Kazu_etal_2014", "Kazu_etal_2014_Table1.csv"),
                stringsAsFactors = FALSE, check.names = FALSE)

skip  <- c("Species", "Species_Kazu2015", "Species_Kazu2014", "n",
           "parse_flags", "consistency_flags")
meas  <- setdiff(intersect(names(new), names(old)), skip)
stopifnot(length(meas) > 0, setequal(new$Species, old$Species))

rows <- NULL; same <- 0; both_na <- 0
for (sp in new$Species) {
  i <- match(sp, new$Species); j <- match(sp, old$Species)
  for (m in meas) {
    a <- old[[m]][j]; b <- new[[m]][i]
    if (is.na(a) && is.na(b)) { both_na <- both_na + 1; next }
    if (!is.na(a) && !is.na(b) && isTRUE(all.equal(a, b))) { same <- same + 1; next }
    rows <- rbind(rows, data.frame(
      Species    = sp,
      term       = m,
      value_2014 = a,
      value_2015 = b,
      pct_change = if (!is.na(a) && a != 0 && !is.na(b)) round(100 * (b - a) / a, 3) else NA_real_,
      stringsAsFactors = FALSE))
  }
}
rows <- rows[order(rows$Species, rows$term), ]
write.csv(rows, file.path(here, "Kazu_etal_2015_TABLE1_vs_Kazu_2014_report.csv"),
          row.names = FALSE)

cat(sprintf("cells compared %d | identical %d | CHANGED %d | both n.a. %d\n",
            same + nrow(rows) + both_na, same, nrow(rows), both_na))
cat(sprintf("changed = %.0f%% of the %d cells present in both printings\n",
            100 * nrow(rows) / (same + nrow(rows)), same + nrow(rows)))
cat("changed per species:\n"); print(table(rows$Species))
every <- names(which(table(rows$term) == nrow(new)))
cat("terms changed for EVERY species:\n  ", paste(every, collapse = ", "), "\n")

# The single check the 2014 printing failed and the corrigendum fixes: the whole-brain neuron
# number should equal cortex + cerebellum + rest of brain. In 2014 it was out by -0.4% to -22%;
# here it should close to the rounding of the printed 3-significant-figure values.
cat("\nN_BR vs N_CXT + N_CB + N_RoB (2015):\n")
for (i in seq_len(nrow(new))) {
  s <- new$CerebralCortex_N.n[i] + new$Cerebellum_N.n[i] + new$RoB_N.n[i]
  cat(sprintf("  %-30s %+6.2f%%\n", new$Species[i], 100 * (s - new$WholeBrain_N.n[i]) /
                new$WholeBrain_N.n[i]))
}
