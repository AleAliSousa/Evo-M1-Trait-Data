# BarbeitoAndrés_etal_2019_celldensity.R
# Reads the frozen snapshot BarbeitoAndrés_etal_2019_celldensity_snapshot.csv (written by BarbeitoAndrés_etal_2019_celldensity_snapshot.R) and builds the
# long analysis table BarbeitoAndrés_etal_2019_celldensity.csv (+ local .tsv and the DOI-coded public TSV).

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
source_grid <- readr::read_csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                               col_names = FALSE, col_types = readr::cols(.default = "c"),
                               show_col_types = FALSE)
blk <- source_grid[55:69, 1:16]
names(blk) <- c("group", cell_cols)
barbeito_celldensity <- long_cell(blk, "cell_density", "cells_per_mg (as published; verify against paper)")
write_csv_tsv(barbeito_celldensity, item_name)

## ---- DOI-coded public TSVs (__HOWTO_build_a_dataset_file.md sec 4, invariant 2) ----------
## Added 2026-08-05. write_csv_tsv() above writes LOCAL .tsv copies next to the CSVs; those are
## working files, not the published table. The three registered items still need the DOI-coded
## copy in __Public/comparative-data/, which is what the merges and the Shiny app read.
publish <- function(df, item) {
  if (is.na(base) || !file.exists(file.path(base, "__ReadMe.xlsx"))) {
    warning("Repo root not found; public TSV skipped for ", item); return(invisible(NULL))
  }
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc     <- filecodes$"Item encoded"[match(item, filecodes$"Item name")]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for '", item, "' in __ReadMe.xlsx; public TSV skipped.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
  } else {
    write.table(df, file.path(tsv_dir, paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
publish(barbeito_celldensity, "BarbeitoAndrés_etal_2019_celldensity")
