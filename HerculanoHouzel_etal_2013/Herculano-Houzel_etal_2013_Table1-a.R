## Herculano-Houzel, Watson & Paxinos (2013) Front. Neuroanat. 7:35
## Table 1-a — neuron distribution across 18 functional cortical areas of the MOUSE
## Build: frozen snapshot -> analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
## Printed PDF table -> hand-verified snapshot is the frozen source (§0a invariant 1).
## SINGLE-SPECIES (Mus musculus, n=4). is_M1 flags the Motor (M1,M2) row. Counts are per one
## cortical hemisphere, corrected for sectioning losses (isotropic fractionator).
## NOTE: file uses author hyphen ("Herculano-Houzel_...") to match the registry Item name.

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
folder       <- dirname(.sp)
item_name    <- "HerculanoHouzel_etal_2013_Table1-a"      # registry Item name (no hyphen in author)
dataset_root <- local({ d<-folder
  while (dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d)
  if (file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
snapshot_xlsx  <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

library(readxl)
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet="Table1a", .name_repair="minimal"), check.names=FALSE)
snap <- snap[snap$Area != "Total", ]                       # keep the 18 area rows
num  <- function(x) as.numeric(gsub(",", "", x))
sem_mean <- function(x) num(sub("\\s*±.*", "", x))
sem_sd   <- function(x) num(sub(".*±\\s*", "", x))
out <- data.frame(
  Species="Mus musculus", Species_HerculanoHouzel2013="Mouse",
  Area=snap$Area, Areas_in_atlas=snap$Areas_in_atlas,
  is_M1=as.integer(snap$Area=="Motor"),
  pct_cortical_area=num(snap$pct_cortical_area), pct_cortical_volume=num(snap$pct_cortical_volume),
  Neurons=sem_mean(snap$Neurons_mean_SEM), Neurons_SEM=sem_sd(snap$Neurons_mean_SEM),
  pct_cortical_neurons=num(snap$pct_cortical_neurons),
  N_per_mm2=num(snap$N_per_mm2), N_per_mm3=num(snap$N_per_mm3),
  OtherCells=sem_mean(snap$OtherCells_mean_SEM), OtherCells_SEM=sem_sd(snap$OtherCells_mean_SEM),
  Thickness_mm=num(snap$Thickness_mm), stringsAsFactors=FALSE, check.names=FALSE)

options(scipen=999); write.csv(out, final_csv, row.names=FALSE, na="")
fc <- read_excel(readme_xlsx, sheet="Sheet1")
ie <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
if (is.na(ie)) stop("No Item encoded for ", item_name)
dir.create(public_tsv_dir, recursive=TRUE, showWarnings=FALSE)
write.table(out, file.path(public_tsv_dir, paste0(ie, ".tsv")), sep="\t", row.names=FALSE, na="")
message("Wrote ", nrow(out), " areas -> ", ie, ".tsv")
