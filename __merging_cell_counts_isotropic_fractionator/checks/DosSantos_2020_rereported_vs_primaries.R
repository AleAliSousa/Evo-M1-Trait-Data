# DosSantos_2020_rereported_vs_primaries.R ---------------------------------------
#
# Evidence for the "Dos Santos 2020 demotion" in cell_counts_isotropic_fractionator_compiled.R
# (sec 8.2.H). Dos Santos et al. (2020) Table 1 re-reports structure mass, C, N and N/mg from
# earlier papers (its footnote a). This check asks how closely those re-reports match the value
# the merge keeps from the primary Herculano-Houzel-team tables for the same species and
# structure -- i.e. what would change if Table 1 were allowed to win those cells by date.
#
# All inputs are public merge outputs, so the check is public (it sits beside the merge that
# consumes the answer):
#   ../cell_counts_isotropic_fractionator_unfiltered.csv   every source's value per species x variable,
#                                                          after step 3 (so with the sec 3.4e corrections)
#   ../cell_counts_isotropic_fractionator_long.csv         the value and source the merge keeps
# Output: DosSantos_2020_rereported_vs_primaries.csv (one row per shared cell), next to this script.
# Read-only otherwise. Re-run after the merge:  Rscript checks/DosSantos_2020_rereported_vs_primaries.R

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
here <- dirname(.sp); merge_dir <- dirname(here)
item <- "DosSantos_etal_2020_Table1"
measures <- c("Mass.g", "C.n", "N.n", "N.p.mg")

unf  <- read.csv(file.path(merge_dir, "cell_counts_isotropic_fractionator_unfiltered.csv"), stringsAsFactors = FALSE)
long <- read.csv(file.path(merge_dir, "cell_counts_isotropic_fractionator_long.csv"), stringsAsFactors = FALSE)
measure_of <- function(v) sub("^[^_]*_", "", v)

t1 <- unf[unf$Source == item & measure_of(unf$Variable) %in% measures, c("Species", "Variable", "Value")]
t1$table1_value <- suppressWarnings(as.numeric(t1$Value)); t1 <- t1[!is.na(t1$table1_value), ]
kept <- long[measure_of(long$Variable) %in% measures, c("Species", "Variable", "Value", "Source")]
names(kept) <- c("Species", "Variable", "merged_value", "merged_source")
kept$merged_value <- suppressWarnings(as.numeric(kept$merged_value))

x <- merge(t1[, c("Species", "Variable", "table1_value")], kept, by = c("Species", "Variable"))
x$structure <- sub("_.*$", "", x$Variable); x$measure <- measure_of(x$Variable)
x$role <- ifelse(x$merged_source == item, "fallback: no primary has the cell, Table 1 supplies it",
                 "shared: a primary table supplies the merged value")
x$pct_table1_vs_merged <- ifelse(x$merged_source == item, NA_real_,
                                 100 * (x$table1_value - x$merged_value) / abs(x$merged_value))
x <- x[order(x$role, -abs(x$pct_table1_vs_merged), x$Species, x$Variable),
       c("Species", "structure", "measure", "Variable", "table1_value", "merged_value", "merged_source",
         "pct_table1_vs_merged", "role")]
write.csv(x, file.path(here, "DosSantos_2020_rereported_vs_primaries.csv"), row.names = FALSE)

sh <- x[!is.na(x$pct_table1_vs_merged), ]
cat("Table 1 re-reported cells (mass, C, N, N/mg):", nrow(x), "\n")
cat("  fallback (Table 1 supplies the merged value):", sum(is.na(x$pct_table1_vs_merged)), "\n")
cat("  shared with a primary table:", nrow(sh), "\n")
cat("    within 0.1%:", sum(abs(sh$pct_table1_vs_merged) <= 0.1),
    "| 0.1-2%:", sum(abs(sh$pct_table1_vs_merged) > 0.1 & abs(sh$pct_table1_vs_merged) <= 2),
    "| over 2%:", sum(abs(sh$pct_table1_vs_merged) > 2),
    "| over 10%:", sum(abs(sh$pct_table1_vs_merged) > 10), "\n")
big <- sh[abs(sh$pct_table1_vs_merged) > 2, ]
cat("  over 2%, by measure:\n"); print(table(big$measure))
cat("  over 2%, by structure:\n"); print(table(big$structure))
cat("  over 2%, by species:\n"); print(sort(table(big$Species), decreasing = TRUE))
