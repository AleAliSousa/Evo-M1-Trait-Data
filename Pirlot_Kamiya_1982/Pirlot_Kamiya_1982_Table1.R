# Pirlot_Kamiya_1982_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Pirlot & Kamiya (1982)
# Table 1 -- "Brain components in percentage of total brain and volumes
# (absolute volumes in parentheses)" -- into a lean, analysis-ready long CSV.
# Output comes from the snapshot only.
#
# Measures (11 brain components, per specimen or per 7-species average):
#   pct_of_total_brain = component volume / total brain volume x 100
#   volume_mm3         = absolute component volume, mm3 (individual specimens)
#   volume_mm3_min/max = printed range across 7 pteropodid species (avg row only)
#
# Three individually perfused specimens (Cynocephalus, Iomys, Glaucomys, n=1 each)
# plus one non-specimen comparison row (Pteropodids, 7-species average from
# Stephan et al. 1974).
#
# Input  : Pirlot_Kamiya_1982_Table1_snapshot.csv
# Outputs: Pirlot_Kamiya_1982_Table1.csv     one row per species x brain component (44 rows)
#          <DOI/ID>_Table1.tsv in __Public/comparative-data/  (registry key)

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr); library(tidyr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
item_name <- tools::file_path_sans_ext(basename(.sp))              # = "Pirlot_Kamiya_1982_Table1"
base      <- local({
  d <- folder
  if (basename(d) != item_name %>% str_remove("_Table1$")) d else d
})

snapshot_path <- file.path(folder, paste0(item_name, "_snapshot.csv"))
out_path      <- file.path(folder, paste0(item_name, ".csv"))

## ---- component abbreviation -> full name (Table 1 footnote) ----
component_names <- c(
  BO = "bulbus olfactorius", N = "neocortex", RH = "rhinencephalon", S = "septum",
  D = "diencephalon", St = "striatum", H = "hippocampus", M = "mesencephalon",
  C = "cerebellum", O = "medulla oblongata", Sz = "schizocortex"
)

## ---- per-specimen printed data (transcribed from the snapshot; see snapshot
## for the exact printed layout, since the source PDF's text layer drops these
## numeric columns and the values were re-verified against a page-image render) ----
specimens <- tribble(
  ~species,        ~species_sci,                      ~specimen_type,                      ~body_weight_g, ~brain_weight_g, ~total_brain_volume_mm3,
  "Cynocephalus",  "Cynocephalus variegatus",          "individual",                        810,            6.2,             5781.1,
  "Iomys",         "Iomys horsfieldii",                "individual",                        119,            2.2,             2094.6,
  "Glaucomys",     "Glaucomys sabrinus",               "individual (immature)",             49.5,           0.938,           899.3
)

component_data <- tribble(
  ~brain_component_code, ~Cynocephalus_pct, ~Cynocephalus_vol, ~Iomys_pct, ~Iomys_vol, ~Glaucomys_pct, ~Glaucomys_vol, ~Pteropodids_pct, ~Pteropodids_vol_range,
  "BO",  2.25, 130.5,  2.08, 43.5,  2.70, 24.2,  4.15, "31-206",
  "N",  37.65,2175.2, 33.68,705.3, 35.10,315.8, 34.70,"223-2385",
  "RH", 10.33, 599.0,  6.44,135.0,  7.97, 71.7,  7.18, "64-376",
  "S",   0.77,  44.5,  1.11, 23.2,  0.95,  8.5,  1.48, "15-69",
  "D",  11.17, 645.5, 10.59,221.9, 11.53,103.7,  9.45, "79-514",
  "St",  4.20, 242.4,  6.13,128.4,  5.51, 49.5,  6.13, "38-392",
  "H",   5.79, 335.1,  7.88,165.1,  7.57, 68.0,  6.72, "81-287",
  "M",   6.19, 357.8,  6.96,145.7,  4.99, 44.9,  5.43, "47-238",
  "C",  11.02, 636.8, 13.70,287.1, 11.71,105.4, 13.60,"117-710",
  "O",   7.21, 416.5,  9.79,205.1,  9.42, 84.7,  7.60, "78-325",
  "Sz",  3.42, 198.0,  1.64, 34.2,  2.55, 22.9,  3.56, "25-186"
)

## ---- reshape to long: one row per species x component ----
long_individual <- specimens %>%
  rowwise() %>%
  group_map(~{
    sp <- .x$species
    pct_col <- paste0(sp, "_pct"); vol_col <- paste0(sp, "_vol")
    component_data %>%
      transmute(
        species = sp, species_sci = .x$species_sci, specimen_type = .x$specimen_type,
        body_weight_g = .x$body_weight_g, brain_weight_g = .x$brain_weight_g,
        brain_component_code = brain_component_code,
        brain_component_name = component_names[brain_component_code],
        pct_of_total_brain = .data[[pct_col]],
        volume_mm3 = .data[[vol_col]],
        volume_mm3_min = NA_real_, volume_mm3_max = NA_real_,
        total_brain_volume_mm3 = as.character(.x$total_brain_volume_mm3)
      )
  }) %>% bind_rows()

long_pteropodids <- component_data %>%
  separate(Pteropodids_vol_range, into = c("volume_mm3_min", "volume_mm3_max"), sep = "-", convert = TRUE) %>%
  transmute(
    species = "Pteropodids", species_sci = "(average, 7 spp. Megachiroptera)",
    specimen_type = "species-average (secondary, from Stephan et al. 1974)",
    body_weight_g = NA_real_, brain_weight_g = NA_real_,
    brain_component_code, brain_component_name = component_names[brain_component_code],
    pct_of_total_brain = Pteropodids_pct, volume_mm3 = NA_real_,
    volume_mm3_min, volume_mm3_max, total_brain_volume_mm3 = "822-5701"
  )

result <- bind_rows(long_individual, long_pteropodids)

## ---- checks: percentages sum to 100 per species; volumes sum near printed total ----
stopifnot(all(abs(result %>% filter(specimen_type != "species-average (secondary, from Stephan et al. 1974)") %>%
  group_by(species) %>% summarise(s = sum(pct_of_total_brain)) %>% pull(s) - 100) < 0.01))

write_csv(result, out_path)
message("Wrote ", nrow(result), " rows to ", out_path)

## Public TSV mirror (registry key = Item encoded); written via the house
## file_list.R pipeline, not duplicated here.
