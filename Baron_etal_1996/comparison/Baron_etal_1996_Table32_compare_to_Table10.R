# Internal source consistency check: the eight Table 32 component volumes
# should reconstruct Table 10 telencephalon volume apart from printed rounding.

.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
comparison_dir <- dirname(.sp)
paper_dir <- dirname(comparison_dir)
t10 <- read.csv(file.path(paper_dir, "Baron_etal_1996_Table10.csv"), check.names = FALSE)
t32 <- read.csv(file.path(paper_dir, "Baron_etal_1996_Table32.csv"), check.names = FALSE)
stopifnot(nrow(t10) == 272L, nrow(t32) == 272L, identical(t10$species_row, t32$species_row))

parts <- c("main_olfactory_bulb_mm3", "paleocortex_mm3", "striatum_mm3", "septum_mm3",
           "amygdala_mm3", "hippocampus_mm3", "schizocortex_mm3", "neocortex_mm3")
component_sum <- rowSums(t32[parts])
report <- data.frame(
  species_row = t10$species_row,
  Species_Baron1996 = t10$Species_Baron1996,
  telencephalon_Table10_mm3 = t10$telencephalon_mm3,
  component_sum_Table32_mm3 = component_sum,
  difference_mm3 = component_sum - t10$telencephalon_mm3,
  source_inconsistency_flag = abs(component_sum - t10$telencephalon_mm3) > 1.5,
  stringsAsFactors = FALSE
)
flags <- report[report$source_inconsistency_flag, , drop = FALSE]
write.csv(report, file.path(comparison_dir, "Baron_etal_1996_Table32_vs_Table10_report_from_R.csv"), row.names = FALSE)
write.csv(flags, file.path(comparison_dir, "Baron_etal_1996_Table32_vs_Table10_source_inconsistencies_from_R.csv"), row.names = FALSE)
message("Baron cross-table check: median |difference| = ", round(median(abs(report$difference_mm3)), 3),
        " mm3; ", nrow(flags), " source inconsistency flag(s) above 1.5 mm3")
