# Nguyen et al. 2019 Table 2: felid cortical-neuron morphology summary statistics.

suppressPackageStartupMessages(library(readxl))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
root_dir <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

snapshot <- read.csv(file.path(paper_dir, paste0(item_name, "_snapshot.csv")),
                     check.names = FALSE, stringsAsFactors = FALSE, na.strings = "")
stopifnot(nrow(snapshot) == 49L)

scientific_printed <- c(
  "African lion" = "Panthera leo leo",
  "African leopard" = "Panthera pardus pardus",
  "Cheetah" = "Acinonyx jubatus jubatus"
)
accepted <- c(
  "African lion" = "Panthera leo",
  "African leopard" = "Panthera pardus",
  "Cheetah" = "Acinonyx jubatus"
)
region_code <- c("Frontal" = "Frontal", "Motor" = "M1", "Visual" = "V1")
region_name <- c("Frontal" = "frontal cortex", "Motor" = "primary motor cortex",
                 "Visual" = "primary visual cortex")

final.dataframe <- data.frame(
  Species_Nguyen2019 = snapshot$species_printed,
  Species_scientific_printed = unname(scientific_printed[snapshot$species_printed]),
  Species = unname(accepted[snapshot$species_printed]),
  region_printed = snapshot$region_printed,
  region_code = unname(region_code[snapshot$region_printed]),
  region = unname(region_name[snapshot$region_printed]),
  neuron_type = snapshot$neuron_type_printed,
  n = as.integer(snapshot$n),
  dendritic_volume_um3_mean = snapshot$Vol_mean,
  dendritic_volume_um3_sem = snapshot$Vol_SEM,
  total_dendritic_length_um_mean = snapshot$TDL_mean,
  total_dendritic_length_um_sem = snapshot$TDL_SEM,
  mean_segment_length_um_mean = snapshot$MSL_mean,
  mean_segment_length_um_sem = snapshot$MSL_SEM,
  dendritic_segment_count_mean = snapshot$DSC_mean,
  dendritic_segment_count_sem = snapshot$DSC_SEM,
  dendritic_spine_count_mean = snapshot$DSN_mean,
  dendritic_spine_count_sem = snapshot$DSN_SEM,
  dendritic_spine_density_per_um_mean = snapshot$DSD_mean,
  dendritic_spine_density_per_um_sem = snapshot$DSD_SEM,
  soma_area_um2_mean = snapshot$Soma_size_mean,
  soma_area_um2_sem = snapshot$Soma_size_SEM,
  soma_depth_um_mean = snapshot$Soma_depth_mean,
  soma_depth_um_sem = snapshot$Soma_depth_SEM,
  source_note = ifelse(snapshot$species_printed == "African lion",
    "Source footnote: quantitative measures are underestimates, especially DSN/DSD, due to relatively incomplete Golgi impregnation.", ""),
  stringsAsFactors = FALSE
)

if (any(is.na(final.dataframe[c("Species_Nguyen2019", "Species", "region_code", "neuron_type", "n")]))) {
  stop("Failed to map a Nguyen Table 2 row identity")
}
local_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, local_csv, row.names = FALSE, na = "")

registry <- read_excel(file.path(root_dir, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  stop("No cached Item encoded value for ", item_name, " in __ReadMe.xlsx")
}
public_tsv <- file.path(root_dir, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
write.table(final.dataframe, public_tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "")
message("Wrote ", local_csv, " and ", public_tsv, " (", nrow(final.dataframe), " rows)")
