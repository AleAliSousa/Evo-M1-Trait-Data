# Pirlot_Kamiya_1985_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Pirlot & Kamiya (1985)
# Table 1 -- "Percentage composition of the Dugong brain" -- into a lean,
# analysis-ready long CSV. Output comes from the snapshot only.
#
# Single specimen (Dugong dugong, n=1). Measures per brain component:
#   volume_mm3            = absolute volume, mm3
#   pct_of_total_brain     = component / total brain volume x 100
#   pct_of_telencephalon   = component / telencephalon volume x 100 (5 telencephalic
#                            components only: N, RH, S, St, H; blank for D, M, C, O)
#
# Input  : Pirlot_Kamiya_1985_Table1_snapshot.csv
# Outputs: Pirlot_Kamiya_1985_Table1.csv      one row per brain component (9 rows)
#          <DOI/ID>_Table1.tsv in __Public/comparative-data/  (registry key)

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
item_name <- tools::file_path_sans_ext(basename(.sp))              # = "Pirlot_Kamiya_1985_Table1"

component_names <- c(
  N = "neocortex", RH = "rhinencephalon", S = "septum", D = "diencephalon",
  St = "striatum", H = "hippocampus", M = "mesencephalon", C = "cerebellum",
  O = "medulla oblongata"
)

result <- tribble(
  ~brain_component_code, ~volume_mm3, ~pct_of_total_brain, ~pct_of_telencephalon,
  "N",   127460.42, 57.17, 78.16,
  "RH",   22549.38, 10.11, 13.82,
  "S",     1629.19,  0.73,  1.00,
  "D",    15643.63,  7.01,  NA,
  "St",    9386.18,  4.21,  5.75,
  "H",     2074.54,  0.93,  1.27,
  "M",     2863.77,  1.28,  NA,
  "C",    32651.51, 14.64,  NA,
  "O",     8743.52,  3.92,  NA
) %>%
  mutate(
    species = "Dugong", species_sci = "Dugong dugong", specimen_type = "individual",
    brain_component_name = component_names[brain_component_code],
    total_brain_volume_mm3 = 223002.14
  ) %>%
  select(species, species_sci, specimen_type, brain_component_code, brain_component_name,
         volume_mm3, pct_of_total_brain, pct_of_telencephalon, total_brain_volume_mm3)

## ---- checks ----
stopifnot(abs(sum(result$volume_mm3) - 223002.14) < 0.01)
stopifnot(abs(sum(result$pct_of_total_brain) - 100) < 0.01)
stopifnot(abs(sum(result$pct_of_telencephalon, na.rm = TRUE) - 100) < 0.01)

out_path <- file.path(folder, paste0(item_name, ".csv"))
write_csv(result, out_path)
message("Wrote ", nrow(result), " rows to ", out_path)

## Public TSV mirror (registry key = Item encoded); written via the house
## file_list.R pipeline, not duplicated here.
