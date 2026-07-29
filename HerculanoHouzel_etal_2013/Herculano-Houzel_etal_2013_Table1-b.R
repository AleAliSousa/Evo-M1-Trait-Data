## Herculano-Houzel, Watson & Paxinos (2013) Front. Neuroanat. 7:35
## Table 1-b — neuron distribution across functional GROUPS (mouse); aggregates of Table 1-a.
## Frozen snapshot -> analysis CSV (+ public TSV).  Single-species (Mus musculus, n=4).

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
item_name    <- "HerculanoHouzel_etal_2013_Table1-b"
dataset_root <- local({ d<-folder
  while (dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d)
  if (file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
snapshot_xlsx  <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

library(readxl)
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet="Table1b", .name_repair="minimal"), check.names=FALSE)
num <- function(x) as.numeric(gsub(",", "", x))
out <- data.frame(
  Species="Mus musculus", Species_HerculanoHouzel2013="Mouse",
  FunctionalGroup=snap$FunctionalGroup,
  pct_cortical_area=num(snap$pct_cortical_area), pct_cortical_volume=num(snap$pct_cortical_volume),
  Neurons=num(snap$Neurons), pct_cortical_neurons=num(snap$pct_cortical_neurons),
  stringsAsFactors=FALSE, check.names=FALSE)

options(scipen=999); write.csv(out, final_csv, row.names=FALSE, na="")
fc <- read_excel(readme_xlsx, sheet="Sheet1")
ie <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
if (is.na(ie)) stop("No Item encoded for ", item_name)
dir.create(public_tsv_dir, recursive=TRUE, showWarnings=FALSE)
write.table(out, file.path(public_tsv_dir, paste0(ie, ".tsv")), sep="\t", row.names=FALSE, na="")
message("Wrote ", nrow(out), " groups -> ", ie, ".tsv")
