## Collins, Turner, Sawyer, Reed, Young, Flaherty & Kaas 2016, PNAS 113(3):740-745 — Table 1
## doi:10.1073/pnas.1524208113 · Team Kaas (Vanderbilt) · isotropic/flow fractionator.
## "Cortical cell and neuron density estimates in ONE chimpanzee hemisphere" (Pan troglodytes,
## female, 53 y, Texas Biomedical Research Institute). Per-region: whole cerebral cortex + V1, V2,
## somatosensory block, M1, premotor block, prefrontal cortex.
## SPECIMEN FLAG: this chimp is very likely the SAME animal as Young et al. 2013 (M1) — both are the
## Kaas lab's single Texas Biomedical chimpanzee (M1 area 2497 mm2 here vs 2700 mm2 in Young 2013,
## differing by dissection boundary). `specimen_overlap` records this on every row.
## Snapshot frozen from the curator's text/figure transcription; all cleaning here (golden rule).

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))            # Collins_etal_2016_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel("Collins_etal_2016_Table1_snapshot.xlsx", sheet = "Sheet1"))
raw <- raw[!is.na(raw$Species), ]
strip <- function(x) trimws(gsub(" ", " ", as.character(x)))      # kill non-breaking spaces
num   <- function(x) {                                                  # "9.51 billion" -> 9.51e9
  s <- tolower(strip(x)); mult <- ifelse(grepl("billion", s), 1e9, ifelse(grepl("million", s), 1e6, 1))
  suppressWarnings(as.numeric(sub("^[^0-9.+-]*([-+]?[0-9]*\\.?[0-9]+).*$", "\\1", s)) * mult)
}
overlap_note <- paste0("Young_etal_2013 (same Texas Biomedical chimp; likely same individual - ",
                       "M1 area 2497 mm2 here vs 2700 mm2 in Young 2013 M1, differ by dissection boundary)")

clean <- data.frame(
  Species     = strip(raw$Species),
  common_name = strip(raw$`Common name`),
  specimen    = strip(raw$Specimen),
  structure   = strip(raw$Structure),
  hemisphere  = strip(raw$Hemisphere),
  method      = strip(raw$Method),
  note        = strip(raw$Note),
  brain_mass_g       = num(raw$`Brain mass (g)`),
  body_weight_kg     = num(raw$`Body weight (kg)`),
  volume_cm3         = num(raw$`Volume (cm3)`),
  area_cm2           = num(raw$`Area (cm2)`),
  pct_neocortical_area = num(raw$`Percent neocortical area`),
  n_cells            = num(raw$`Number of cells`),
  n_neurons          = num(raw$`Number of neurons`),
  pct_neurons        = num(raw$`Percent neurons`),
  cells_per_cm2      = num(raw$`Cells per cm2 surface`),
  cells_per_g        = num(raw$`Cells per g tissue`),
  neurons_per_cm2    = num(raw$`Neurons per cm2 surface`),
  neurons_per_g      = num(raw$`Neurons per g tissue`),
  specimen_overlap   = overlap_note,
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " region rows written")

## ---- public TSV ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
