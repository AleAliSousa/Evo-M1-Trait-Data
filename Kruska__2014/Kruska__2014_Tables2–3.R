# Kruska__2014_Tables2-3.R
#
# Preparation step. Turn the journal-faithful snapshots of Kruska (2014) Tables
# 2 (wild cavies) and 3 (guinea pigs) -- brain-structure volumes and percentages
# of pure brain tissue -- into one lean, analysis-ready long CSV. Output comes
# from the snapshots only.
#
# 24 structure rows per specimen, fully hierarchical (Telencephalon =
# Neocortex+Striatum+Allocortex, etc. -- all verified exact, see README) plus
# total_brain_weight_g, total_brain_volume_mm3, rest_tissue_mm3, ventricle_mm3,
# pure_brain_tissue_mm3 (= total - rest - ventricle, the 100% reference base).
# 6 wild cavy + 6 guinea pig specimens.
#
# Input  : Kruska__2014_Table2_snapshot.csv, Kruska__2014_Table3_snapshot.csv
# Outputs: Kruska__2014_Tables2-3.csv    one row per specimen x structure (288 rows)
#          <ID>_Tables2-3.tsv in __Public/comparative-data/  (registry key)

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr)
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
item_name <- tools::file_path_sans_ext(basename(.sp))              # = "Kruska__2014_Tables2-3"

component_names <- c(
  medulla_oblongata_mm3 = "Medulla oblongata",
  cerebellum_mm3 = "Cerebellum",
  mesencephalon_mm3 = "Mesencephalon",
  diencephalon_mm3 = "Diencephalon",
  telencephalon_mm3 = "Telencephalon",
  neocortex_total_mm3 = "Neocortex (total)",
  corpus_striatum_mm3 = "Corpus striatum",
  allocortex_total_mm3 = "Allocortex (total)",
  neocortex_grey_mm3 = "Neocortex (grey matter)",
  neocortex_white_mm3 = "Neocortex (white matter)",
  olfactory_allocortex_mm3 = "Olfactory allocortex",
  bulbus_olfactorius_mm3 = "Bulbus olfactorius",
  regio_retrobulbaris_mm3 = "Regio retrobulbaris",
  tuberculum_olfactorium_mm3 = "Tuberculum olfactorium",
  regio_praepiriformis_mm3 = "Regio praepiriformis",
  nucleus_amygaloideus_mm3 = "Nucleus amygaloideus",
  basal_nuclei_mm3 = "Basal nuclei",
  non_olfactory_allocortex_mm3 = "Non-olfactory allocortex",
  septum_telencephali_mm3 = "Septum telencephali",
  hippocampus_mm3 = "Hippocampus",
  schizocortex_mm3 = "Schizocortex",
  tractus_opticus_mm3 = "Tractus opticus",
  corpus_geniculatum_laterale_mm3 = "Corpus geniculatum laterale",
  nucleus_cochlearis_mm3 = "Nucleus cochlearis"
)

wild <- tribble(
  ~specimen_id, ~sex, ~total_brain_weight_g, ~total_brain_volume_mm3, ~rest_tissue_mm3, ~ventricle_mm3, ~pure_brain_tissue_mm3, ~medulla_oblongata_mm3_vol, ~cerebellum_mm3_vol, ~mesencephalon_mm3_vol, ~diencephalon_mm3_vol, ~telencephalon_mm3_vol, ~neocortex_total_mm3_vol, ~corpus_striatum_mm3_vol, ~allocortex_total_mm3_vol, ~neocortex_grey_mm3_vol, ~neocortex_white_mm3_vol, ~olfactory_allocortex_mm3_vol, ~bulbus_olfactorius_mm3_vol, ~regio_retrobulbaris_mm3_vol, ~tuberculum_olfactorium_mm3_vol, ~regio_praepiriformis_mm3_vol, ~nucleus_amygaloideus_mm3_vol, ~basal_nuclei_mm3_vol, ~non_olfactory_allocortex_mm3_vol, ~septum_telencephali_mm3_vol, ~hippocampus_mm3_vol, ~schizocortex_mm3_vol, ~tractus_opticus_mm3_vol, ~corpus_geniculatum_laterale_mm3_vol, ~nucleus_cochlearis_mm3_vol, ~medulla_oblongata_mm3_pct, ~cerebellum_mm3_pct, ~mesencephalon_mm3_pct, ~diencephalon_mm3_pct, ~telencephalon_mm3_pct, ~neocortex_total_mm3_pct, ~corpus_striatum_mm3_pct, ~allocortex_total_mm3_pct, ~neocortex_grey_mm3_pct, ~neocortex_white_mm3_pct, ~olfactory_allocortex_mm3_pct, ~bulbus_olfactorius_mm3_pct, ~regio_retrobulbaris_mm3_pct, ~tuberculum_olfactorium_mm3_pct, ~regio_praepiriformis_mm3_pct, ~nucleus_amygaloideus_mm3_pct, ~basal_nuclei_mm3_pct, ~non_olfactory_allocortex_mm3_pct, ~septum_telencephali_mm3_pct, ~hippocampus_mm3_pct, ~schizocortex_mm3_pct, ~tractus_opticus_mm3_pct, ~corpus_geniculatum_laterale_mm3_pct, ~nucleus_cochlearis_mm3_pct,
  "19269", "M", 5.08, 4903.475, 107.483, 41.518, 4754.474, 451.855,678.657,448.557,440.215,2735.19,1624.662,192.655,917.873,1335.971,288.691,399.665,100.498,10.477,38.802,114.468,104.572,30.848,518.208,52.19,338.358,127.66,23.864,15.327,17.849, 9.5,14.27,9.44,9.26,57.53,34.17,4.05,19.31,28.1,6.07,8.41,2.11,0.22,0.82,2.41,2.2,0.65,10.9,1.1,7.12,2.68,0.5,0.34,0.38,
  "19263", "M", 4.99, 4816.602, 121.655, 48.533, 4646.414, 439.797,757.298,431.672,403.452,2614.195,1543.886,178.314,891.995,1270.216,273.67,382.07,107.757,13.898,32.927,113.53,86.805,27.153,509.925,51.528,345.295,113.102,26.085,17.746,18.387, 9.47,16.3,9.29,8.68,56.26,33.23,3.83,19.21,27.34,5.89,8.22,2.32,0.3,0.71,2.44,1.87,0.58,10.98,1.12,7.43,2.43,0.56,0.38,0.4,
  "19267", "M", 4.8, 4633.205, 138.197, 32.92, 4462.088, 400.874,546.788,396.245,422.822,2695.359,1577.608,179.004,938.747,1295.555,282.053,394.189,103.562,11.83,36.864,113.68,100.819,27.434,544.558,50.237,357.152,137.169,23.49,14.745,16.632, 8.98,12.25,8.88,9.48,60.41,35.36,4.01,21.04,29.03,6.33,8.84,2.32,0.27,0.83,2.55,2.26,0.61,12.2,1.13,8.0,3.07,0.53,0.33,0.37,
  "19256", "F", 5.12, 4942.085, 138.622, 53.624, 4749.839, 411.301,609.631,406.549,442.676,2879.682,1694.457,183.877,1001.348,1352.751,341.706,407.689,107.247,12.931,39.933,118.655,94.696,34.227,593.659,60.278,398.752,134.629,23.008,16.354,18.255, 8.66,12.83,8.56,9.32,60.63,35.67,3.88,21.08,28.48,7.19,8.58,2.26,0.27,0.84,2.5,1.99,0.72,12.5,1.27,8.4,2.83,0.48,0.34,0.38,
  "19255", "F", 4.98, 4806.95, 172.125, 26.9, 4607.925, 453.304,741.572,406.411,411.318,2595.32,1515.679,187.757,891.884,1250.131,265.548,364.242,101.056,8.725,32.716,107.237,87.062,27.446,527.642,57.98,346.976,122.686,23.992,11.087,21.266, 9.84,16.09,8.82,8.93,56.32,32.89,4.07,19.36,27.13,5.76,7.91,2.19,0.19,0.71,2.33,1.89,0.6,11.45,1.26,7.53,2.66,0.52,0.24,0.46,
  "19257", "F", 4.66, 4498.069, 128.561, 38.823, 4330.685, 418.884,562.94,360.479,399.643,2588.739,1538.464,184.923,865.352,1271.467,266.997,347.706,92.29,11.578,34.907,95.696,87.693,25.542,517.646,49.722,351.965,115.959,20.093,14.985,17.369, 9.67,13.0,8.32,9.23,59.78,35.52,4.27,19.99,29.36,6.16,8.03,2.13,0.27,0.81,2.21,2.02,0.59,11.96,1.15,8.13,2.68,0.46,0.35,0.4,
)

domestic <- tribble(
  ~specimen_id, ~sex, ~total_brain_weight_g, ~total_brain_volume_mm3, ~rest_tissue_mm3, ~ventricle_mm3, ~pure_brain_tissue_mm3, ~medulla_oblongata_mm3_vol, ~cerebellum_mm3_vol, ~mesencephalon_mm3_vol, ~diencephalon_mm3_vol, ~telencephalon_mm3_vol, ~neocortex_total_mm3_vol, ~corpus_striatum_mm3_vol, ~allocortex_total_mm3_vol, ~neocortex_grey_mm3_vol, ~neocortex_white_mm3_vol, ~olfactory_allocortex_mm3_vol, ~bulbus_olfactorius_mm3_vol, ~regio_retrobulbaris_mm3_vol, ~tuberculum_olfactorium_mm3_vol, ~regio_praepiriformis_mm3_vol, ~nucleus_amygaloideus_mm3_vol, ~basal_nuclei_mm3_vol, ~non_olfactory_allocortex_mm3_vol, ~septum_telencephali_mm3_vol, ~hippocampus_mm3_vol, ~schizocortex_mm3_vol, ~tractus_opticus_mm3_vol, ~corpus_geniculatum_laterale_mm3_vol, ~nucleus_cochlearis_mm3_vol, ~medulla_oblongata_mm3_pct, ~cerebellum_mm3_pct, ~mesencephalon_mm3_pct, ~diencephalon_mm3_pct, ~telencephalon_mm3_pct, ~neocortex_total_mm3_pct, ~corpus_striatum_mm3_pct, ~allocortex_total_mm3_pct, ~neocortex_grey_mm3_pct, ~neocortex_white_mm3_pct, ~olfactory_allocortex_mm3_pct, ~bulbus_olfactorius_mm3_pct, ~regio_retrobulbaris_mm3_pct, ~tuberculum_olfactorium_mm3_pct, ~regio_praepiriformis_mm3_pct, ~nucleus_amygaloideus_mm3_pct, ~basal_nuclei_mm3_pct, ~non_olfactory_allocortex_mm3_pct, ~septum_telencephali_mm3_pct, ~hippocampus_mm3_pct, ~schizocortex_mm3_pct, ~tractus_opticus_mm3_pct, ~corpus_geniculatum_laterale_mm3_pct, ~nucleus_cochlearis_mm3_pct,
  "18477", "M", 4.84, 4671.815, 165.471, 50.773, 4455.571, 436.318,649.233,337.434,425.33,2607.256,1579.8,178.622,848.834,1314.779,265.021,388.877,77.576,9.656,38.954,127.85,99.882,34.959,459.957,53.437,283.832,122.688,17.479,13.317,19.644, 9.79,14.57,7.57,9.55,58.52,35.46,4.01,19.05,29.51,5.95,8.73,1.74,0.22,0.87,2.87,2.24,0.79,10.32,1.2,6.37,2.75,0.39,0.3,0.44,
  "18206", "M", 4.82, 4652.251, 143.203, 53.085, 4455.963, 426.523,663.754,370.353,407.183,2588.15,1560.214,207.399,820.537,1302.201,258.013,362.537,64.608,16.872,33.742,121.805,94.029,31.481,458.0,61.313,289.08,107.607,20.987,12.757,17.695, 9.57,14.9,8.31,9.14,58.08,35.01,4.65,18.42,29.22,5.79,8.14,1.45,0.38,0.76,2.73,2.11,0.71,10.28,1.38,6.49,2.41,0.47,0.29,0.4,
  "18205", "M", 4.47, 4314.672, 143.372, 23.896, 4147.404, 381.287,557.211,341.115,403.625,2464.166,1507.137,208.651,748.378,1273.379,233.758,325.362,61.298,11.774,31.515,104.759,90.214,25.802,423.016,48.657,285.358,89.001,14.719,13.679,18.008, 9.19,13.44,8.23,9.73,59.41,36.34,5.03,18.04,30.7,5.64,7.84,1.48,0.28,0.76,2.53,2.17,0.62,10.2,1.17,6.88,2.15,0.35,0.33,0.43,
  "18719", "M", 4.09, 3947.876, 91.767, 36.781, 3819.328, 347.566,553.579,326.018,364.844,2227.321,1352.926,182.793,691.602,1154.157,198.769,307.998,60.373,10.774,33.438,102.727,78.95,21.736,383.604,42.354,255.984,85.266,14.49,12.447,15.605, 9.1,14.49,8.54,9.55,58.32,35.42,4.79,18.11,30.22,5.2,8.07,1.58,0.28,0.88,2.69,2.07,0.57,10.04,1.11,6.7,2.23,0.38,0.33,0.41,
  "18731", "F", 4.84, 4671.815, 90.727, 31.801, 4549.287, 412.67,604.602,398.265,418.844,2714.906,1688.282,223.733,802.891,1426.762,261.52,348.318,57.99,13.282,34.795,118.413,93.534,30.304,454.573,47.515,301.178,105.88,15.714,13.469,17.584, 9.07,13.29,8.75,9.21,59.68,37.11,4.92,17.65,31.36,5.75,7.66,1.27,0.29,0.77,2.6,2.06,0.67,9.99,1.04,6.62,2.33,0.35,0.3,0.39,
  "18733", "F", 4.77, 4604.247, 82.183, 36.686, 4485.378, 436.452,618.083,358.948,452.818,2619.077,1613.815,198.175,807.087,1340.83,272.985,353.01,68.695,7.373,34.528,120.487,87.398,34.529,454.077,51.433,294.026,108.618,17.444,14.387,16.365, 9.73,13.78,8.0,10.1,58.39,35.98,4.42,17.99,29.89,6.09,7.87,1.53,0.16,0.77,2.69,1.95,0.77,10.12,1.15,6.55,2.42,0.39,0.32,0.36,
)
structure_keys <- names(component_names)

reshape_long <- function(df, population_label) {
  df %>%
    mutate(population = population_label) %>%
    pivot_longer(
      cols = ends_with("_vol"),
      names_to = "structure_var", values_to = "volume_mm3",
      names_pattern = "(.*)_vol"
    ) %>%
    rowwise() %>%
    mutate(pct_of_pure_brain = get(paste0(structure_var, "_pct"))) %>%
    ungroup() %>%
    mutate(structure_label = component_names[structure_var]) %>%
    select(population, specimen_id, sex, structure_var, structure_label, volume_mm3,
           pct_of_pure_brain, total_brain_weight_g, total_brain_volume_mm3,
           rest_tissue_mm3, ventricle_mm3, pure_brain_tissue_mm3)
}

result <- bind_rows(
  reshape_long(wild %>% select(-ends_with("_pct"), everything()), "wild cavy (Cavia aperea)"),
  reshape_long(domestic %>% select(-ends_with("_pct"), everything()), "guinea pig (Cavia aperea f. porcellus)")
)

## ---- checks: full hierarchy reconciles exactly (see README) ----
wide_check <- bind_rows(wild, domestic)
stopifnot(
  all(abs(wide_check$neocortex_total_mm3_vol + wide_check$corpus_striatum_mm3_vol + wide_check$allocortex_total_mm3_vol - wide_check$telencephalon_mm3_vol) < 0.01),
  all(abs(wide_check$neocortex_grey_mm3_vol + wide_check$neocortex_white_mm3_vol - wide_check$neocortex_total_mm3_vol) < 0.01),
  all(abs(wide_check$olfactory_allocortex_mm3_vol + wide_check$non_olfactory_allocortex_mm3_vol - wide_check$allocortex_total_mm3_vol) < 0.01),
  all(abs(wide_check$septum_telencephali_mm3_vol + wide_check$hippocampus_mm3_vol + wide_check$schizocortex_mm3_vol - wide_check$non_olfactory_allocortex_mm3_vol) < 0.01),
  all(abs(wide_check$medulla_oblongata_mm3_vol + wide_check$cerebellum_mm3_vol + wide_check$mesencephalon_mm3_vol + wide_check$diencephalon_mm3_vol + wide_check$telencephalon_mm3_vol - wide_check$pure_brain_tissue_mm3) < 0.01),
  all(abs(wide_check$total_brain_volume_mm3 - wide_check$rest_tissue_mm3 - wide_check$ventricle_mm3 - wide_check$pure_brain_tissue_mm3) < 0.01)
)

out_path <- file.path(folder, paste0(item_name, ".csv"))
write_csv(result, out_path)
message("Wrote ", nrow(result), " rows to ", out_path)

## Public TSV mirror (registry key = Item encoded); written via the house
## file_list.R pipeline, not duplicated here.
