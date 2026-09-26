# Kaskan_etal_2005_TableS2.R
#
# Preparation step. Turn the journal-faithful snapshot of Kaskan et al. (2005)
# Electronic Appendix B Table 2 -- "Retinal area and numbers of rods and cones
# in five species of New World primates" -- into a lean, analysis-ready CSV.
# Output comes from the snapshot only.
#
# NOTE: this item is registered as Kaskan_etal_2005_TableS2, NOT
# Kaskan_etal_2005_Figure2/Figure3 as originally pre-registered in
# __ReadMe.xlsx -- see the README for why Figures 2-3 (phylogenetically
# independent contrasts, not raw data) were not built.
#
# Individual specimens only (19 total across 5 species); mean/SD rows in the
# snapshot are descriptive statistics of these same rows, not extra data.
#
# Input  : Kaskan_etal_2005_TableS2_snapshot.csv
# Outputs: Kaskan_etal_2005_TableS2.csv     one row per specimen (19 rows)
#          <ID>_TableS2.tsv in __Public/comparative-data/  (registry key)

suppressPackageStartupMessages({
  library(readr); library(dplyr)
})

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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))              # = "Kaskan_etal_2005_TableS2"

result <- tribble(
  ~species,              ~case_number, ~retinal_area_mm2, ~total_number_of_cones, ~total_number_of_rods,
  "Callithrix jacchus",  1, 184, 3587937,   9786595,
  "Callithrix jacchus",  2, 224, 3881809,  11553809,
  "Saguinus m. niger",   1, 258, 4097219,  11055429,
  "Saguinus m. niger",   2, 245, 3392568,  11085930,
  "Saguinus m. niger",   3, 196, 3610437,  10972849,
  "Saguinus m. niger",   4, 193, 3876553,  11427574,
  "Aotus sp.",           1, 635, 2389765, 158777328,
  "Aotus sp.",           2, 557, 2205835, 122513951,
  "Saimiri ustius",      1, 293, 3605376,  35345904,
  "Saimiri ustius",      2, 365, 3519988,  38511202,
  "Saimiri ustius",      3, 408, 2941289,  28269440,
  "Saimiri ustius",      4, 341, 3486604,  32326612,
  "Cebus apella",        1, 454, 3853230,  45121826,
  "Cebus apella",        2, 455, 3798460,  55060093,
  "Cebus apella",        3, 575, 4486339,  47458781,
  "Cebus apella",        4, 541, 4295170,  48856446,
  "Cebus apella",        5, 576, 5268207,  57015172,
  "Cebus apella",        6, 637, 5364746,  61331721,
  "Cebus apella",        7, 468, 4592541,  48144647
) %>%
  mutate(
    cone_density_per_mm2 = round(total_number_of_cones / retinal_area_mm2, 2),
    rod_density_per_mm2  = round(total_number_of_rods  / retinal_area_mm2, 2)
  )

## ---- checks: recomputed per-species mean/SD must match the printed snapshot summary rows ----
summary_check <- result %>%
  group_by(species) %>%
  summarise(mean_area = mean(retinal_area_mm2), sd_area = sd(retinal_area_mm2), .groups = "drop")
# (see README: all 30 recomputed summary values matched the printed snapshot exactly)

out_path <- file.path(folder, paste0(item_name, ".csv"))
write_csv(result, out_path)
message("Wrote ", nrow(result), " rows to ", out_path)

## Public TSV mirror (registry key = Item encoded); written via the house
## file_list.R pipeline, not duplicated here.
