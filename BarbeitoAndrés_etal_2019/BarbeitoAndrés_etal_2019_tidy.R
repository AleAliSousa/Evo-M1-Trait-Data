# BarbeitoAndrés_etal_2019_tidy.R
# Combined tidy long table BarbeitoAndrés_etal_2019_tidy.csv (+ local .tsv): volumes + cell number + cell density, bound row-wise.
# Reads the three per-item frozen snapshots (BarbeitoAndrés_etal_2019_volumes_snapshot.csv, _cellnumber_snapshot.csv, _celldensity_snapshot.csv).

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

suppressPackageStartupMessages({ library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr) })
base <- base
folder <- file.path(base, "BarbeitoAndrés_etal_2019")
numv <- function(x) suppressWarnings(as.numeric(gsub(",", "", as.character(x))))

## ---- output helper: TSVs replicate CSVs ----
write_csv_tsv <- function(x, stem, dir = folder) {
  csv_file <- file.path(dir, paste0(stem, ".csv"))
  tsv_file <- file.path(dir, paste0(stem, ".tsv"))

  readr::write_csv(x, csv_file, na = "")
  readr::write_tsv(x, tsv_file, na = "")

  message("Wrote ", csv_file)
  message("Wrote ", tsv_file)
}

b1 <- readr::read_csv(file.path(folder, "BarbeitoAndrés_etal_2019_volumes_snapshot.csv"), col_types = readr::cols(.default = "character"), show_col_types = FALSE)
vol_regions <- c("Olfactory_bulbs","Cerebellum","Corpus_callosum","Midbrain","Lateral_ventricle",
                 "Striatum","Cortex","Hypothalamus","Third_ventricle","Hippocampus","Thalamus",
                 "Fimbria","Total")              # row 4 cols 3:15, as published (cleaned)
vol_long <- b1 %>%
  pivot_longer(all_of(vol_regions), names_to = "region", values_to = "value") %>%
  transmute(species = "Mus musculus", reference = "BarbeitoAndrés_etal_2019",
            group, specimen, region, cell_type = NA_character_,
            measure = "absolute_volume", value = numv(value), units = "mm3") %>%
  filter(!is.na(value))

cell_regions <- c("Cerebellum","Cortex","Olfactory","Hippocampus","Rest")
cell_cols <- as.vector(t(outer(cell_regions, c("Total","Neurons","Non_neurons"), paste, sep = "__")))
long_cell <- function(blk, measure, units) {
  blk %>% pivot_longer(all_of(cell_cols), names_to = "rc", values_to = "value") %>%
    separate(rc, into = c("region","cell_type"), sep = "__") %>%
    transmute(species = "Mus musculus", reference = "BarbeitoAndrés_etal_2019",
              group, specimen = NA_character_, region,
              cell_type = gsub("Non_neurons","Non-neurons", cell_type),
              measure = measure, value = numv(value), units = units) %>%
    filter(!is.na(value))
}
n2 <- readr::read_csv(file.path(folder, "BarbeitoAndrés_etal_2019_cellnumber_snapshot.csv"), col_types = readr::cols(.default = "character"), show_col_types = FALSE)
n3 <- readr::read_csv(file.path(folder, "BarbeitoAndrés_etal_2019_celldensity_snapshot.csv"), col_types = readr::cols(.default = "character"), show_col_types = FALSE)
barbeito_volumes <- vol_long
barbeito_cellnumber <- long_cell(n2, "cell_number",  "cells")
barbeito_celldensity <- long_cell(n3, "cell_density", "cells_per_mg (as published; verify against paper)")

tidy <- bind_rows(barbeito_volumes, barbeito_cellnumber, barbeito_celldensity)
write_csv_tsv(tidy, item_name)
