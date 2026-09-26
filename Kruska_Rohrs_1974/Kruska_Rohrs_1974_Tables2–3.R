# Kruska_Rohrs_1974_Tables2-3.R
#
# Preparation step. Turn the journal-faithful snapshots of Kruska & Rohrs (1974)
# Tables 2 (feral Galapagos pigs) and 3 (domestic pigs) -- brain-section volumes,
# mm3 -- into one lean, analysis-ready long CSV. Output comes from the snapshots only.
#
# 21 structure rows per specimen (5 fundamental sections + allocortical/limbic
# subdivisions), plus brain_weight_g and total_brain_volume_mm3.
# 4 feral (A23, A21, A26, A22) + 6 domestic (Sd5, Sd9, Sd31, Sd19, Sd17, Sd12) specimens.
#
# Input  : Kruska_Rohrs_1974_Table2_snapshot.csv, Kruska_Rohrs_1974_Table3_snapshot.csv
# Outputs: Kruska_Rohrs_1974_Tables2-3.csv    one row per specimen x structure (210 rows)
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
item_name <- tools::file_path_sans_ext(basename(.sp))              # = "Kruska_Rohrs_1974_Tables2-3"

structures <- c(
  medulla_oblongata_mm3 = "Medulla oblongata",
  cerebellum_mm3 = "Cerebellum",
  mesencephalon_mm3 = "Mesencephalon",
  diencephalon_mm3 = "Diencephalon",
  telencephalon_mm3 = "Telencephalon",
  neocortex_mm3 = "Neocortex",
  corpus_striatum_mm3 = "Corpus striatum",
  allocortex_mm3 = "Allocortex",
  bulbus_olfactorius_mm3 = "Bulbus olfactorius",
  regio_retrobulbaris_mm3 = "Regio retrobulbaris",
  regio_praepiriformis_mm3 = "Regio praepiriformis",
  amygdaloid_complex_mm3 = "Amygdaloid complex",
  amygdaloid_centromedial_mm3 = "Amygdaloid complex a) centromedial group",
  amygdaloid_basolateral_mm3 = "Amygdaloid complex b) basolateral group",
  tuberculum_olfactorium_mm3 = "Tuberculum olfactorium",
  nuclei_basalis_mm3 = "Nuclei basalis",
  palaeocortex_amygdaloid_mm3 = "Palaeocortex + Amygdaloid complex",
  septum_mm3 = "Septum",
  hippocampus_mm3 = "Hippocampus",
  schizocortex_mm3 = "Schizocortex",
  limbic_structures_mm3 = "limbic structures"
)

feral <- tribble(
  ~specimen_id, ~medulla_oblongata_mm3, ~cerebellum_mm3, ~mesencephalon_mm3, ~diencephalon_mm3, ~telencephalon_mm3,
  ~neocortex_mm3, ~corpus_striatum_mm3, ~allocortex_mm3, ~bulbus_olfactorius_mm3, ~regio_retrobulbaris_mm3,
  ~regio_praepiriformis_mm3, ~amygdaloid_complex_mm3, ~amygdaloid_centromedial_mm3, ~amygdaloid_basolateral_mm3,
  ~tuberculum_olfactorium_mm3, ~nuclei_basalis_mm3, ~palaeocortex_amygdaloid_mm3, ~septum_mm3, ~hippocampus_mm3,
  ~schizocortex_mm3, ~limbic_structures_mm3, ~brain_weight_g, ~total_brain_volume_mm3, ~note,
  "A23", 6395,11532,4010,6939,62946, 47192,3335,12419,887,406, 2933,1061,414,647, 721,753,5874,674,3852, 1131,5657, 98.5, 95077, "damaged olfactory bulb",
  "A21", 6678,10419,4193,6528,63989, 48477,3423,12089,1147,356, 2766,1113,410,703, 686,829,5750,695,3456, 1042,5193, 99.6, 96139, "damaged olfactory bulb",
  "A26", 6717,11408,4473,7104,69174, 52320,3671,13184,1542,432, 3054,1192,440,752, 707,773,6158,728,3675, 1081,5484, 106.2,102510, "",
  "A22", 7240,11153,4615,7607,71931, 53229,3779,14923,1650,447, 3305,1248,478,769, 836,939,6775,787,4508, 1203,6498, 110.5,106660, ""
) %>% mutate(population = "feral (Galapagos)")

domestic <- tribble(
  ~specimen_id, ~medulla_oblongata_mm3, ~cerebellum_mm3, ~mesencephalon_mm3, ~diencephalon_mm3, ~telencephalon_mm3,
  ~neocortex_mm3, ~corpus_striatum_mm3, ~allocortex_mm3, ~bulbus_olfactorius_mm3, ~regio_retrobulbaris_mm3,
  ~regio_praepiriformis_mm3, ~amygdaloid_complex_mm3, ~amygdaloid_centromedial_mm3, ~amygdaloid_basolateral_mm3,
  ~tuberculum_olfactorium_mm3, ~nuclei_basalis_mm3, ~palaeocortex_amygdaloid_mm3, ~septum_mm3, ~hippocampus_mm3,
  ~schizocortex_mm3, ~limbic_structures_mm3, ~brain_weight_g, ~total_brain_volume_mm3, ~note,
  "Sd5",  5207,11477,3627,6319,58703, 44826,3386,10490,835,342, 2420,1056,395,661, 775,589,5182,628,2943, 900,4473, 92.0, 88803, "damaged olfactory bulb",
  "Sd9",  6431,13953,4137,6628,66335, 50018,3975,12342,1263,423, 2799,1101,451,650, 863,655,5840,753,3366, 1118,5237, 105.0,101351, "",
  "Sd31", 6656,12299,4390,7151,69415, 53362,3706,12346,929,418, 3085,1216,457,759, 903,626,6248,772,3314, 1080,5168, 110.0,106178, "damaged olfactory bulb",
  "Sd19", 6755,14614,4458,7153,71071, 53488,3815,13767,1302,444, 3451,1217,463,754, 1103,836,7051,864,3372, 1177,5413, 112.0,108108, "",
  "Sd17", 6927,13322,4733,7187,77356, 60449,3930,12977,1408,430, 2935,1154,441,713, 961,763,6242,808,3353, 1164,5326, 119.0,114865, "",
  "Sd12", 7158,14203,5175,7694,82386, 64205,4573,13608,1214,405, 3252,1322,552,770, 1280,750,7009,952,3257, 1173,5383, 125.0,120656, "damaged olfactory bulb"
) %>% mutate(population = "domestic")

wide <- bind_rows(feral, domestic)

result <- wide %>%
  pivot_longer(cols = names(structures), names_to = "structure_var", values_to = "volume_mm3") %>%
  mutate(structure_label = structures[structure_var],
         note = ifelse(structure_var == "bulbus_olfactorius_mm3", note, "")) %>%
  select(population, specimen_id, structure_var, structure_label, volume_mm3,
         brain_weight_g, total_brain_volume_mm3, note)

## ---- checks (see README for the systematic total-volume non-reconciliation) ----
## Every printed value is rounded to the nearest mm3, so a printed total can differ
## from the sum of its k printed parts by up to (k + 1) / 2 mm3 through rounding
## alone: 1 for a 2-part sum, 2 for a 3-part sum. The old fixed tolerance of 1 was
## too tight for the 3-part sums: the paper itself prints limbic structures 2 mm3
## above Septum + Hippocampus + Schizocortex for Sd5 (628 + 2943 + 900 = 4471 vs
## 4473) and Sd31 (772 + 3314 + 1080 = 5166 vs 5168) -- checked against the PDF,
## Table 3, p. 66. These are the paper's own rounding, not transcription errors,
## and are kept as printed.
round_tol <- function(k) (k + 1) / 2
chk <- wide %>% mutate(
  telenc_diff = neocortex_mm3 + corpus_striatum_mm3 + allocortex_mm3 - telencephalon_mm3,
  limbic_diff = septum_mm3 + hippocampus_mm3 + schizocortex_mm3 - limbic_structures_mm3,
  amyg_diff   = amygdaloid_centromedial_mm3 + amygdaloid_basolateral_mm3 - amygdaloid_complex_mm3,
  telenc_check = abs(telenc_diff) <= round_tol(3),
  limbic_check = abs(limbic_diff) <= round_tol(3),
  amyg_check   = abs(amyg_diff)   <= round_tol(2)
)
off <- chk %>% filter(telenc_diff != 0 | limbic_diff != 0 | amyg_diff != 0) %>%
  select(specimen_id, telenc_diff, limbic_diff, amyg_diff)
if (nrow(off)) {
  message("Printed sums that differ from their parts by rounding (mm3):")
  print(as.data.frame(off), row.names = FALSE)
}
if (!all(chk$telenc_check, chk$limbic_check, chk$amyg_check)) {
  print(as.data.frame(chk %>% filter(!(telenc_check & limbic_check & amyg_check)) %>%
                        select(specimen_id, telenc_diff, limbic_diff, amyg_diff)), row.names = FALSE)
  stop("a printed sum differs from its parts by more than rounding can explain -- ",
       "check the transcription against the PDF", call. = FALSE)
}

out_path <- file.path(folder, paste0(item_name, ".csv"))
write_csv(result, out_path)
message("Wrote ", nrow(result), " rows to ", out_path)

## Public TSV mirror (registry key = Item encoded); written via the house
## file_list.R pipeline, not duplicated here.
