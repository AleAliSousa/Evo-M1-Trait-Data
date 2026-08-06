# Barbeito-Andres et al. 2019 - developmental / experimental mouse dataset.
# "Region-specific changes in Mus musculus brain size and cell composition under
#  chronic nutrient restriction." J Exp Biol.
#
# Source: data_figshare.xlsx, sheet Hoja1 (sheets Hoja2/Hoja3 are EMPTY). Hoja1
# stacks THREE sub-tables:
#   (1) Absolute volumes (mm3)  - per specimen, 13 regions (rows 5-30)
#   (2) Cell number             - per specimen, 5 region groups x {Total,Neurons,
#                                 Non-neurons} (rows 34-48)
#   (3) Cell density            - same layout (rows 55-69)
# Groups (chronic nutrient restriction): C = control, LP = low protein,
#   LCP = low calorie + protein (labels as published).
#
# This is a SEPARATE comparison set (single species, experimental groups); it is
# NOT part of the phylogenetic volume merge.
#
# Output: 3 faithful snapshots plus split analysis-ready tables, all as CSV+TSV.
# Also keeps one combined tidy long table aligned to a generic schema
#   (species, reference, group, specimen, region, cell_type, measure, value, units).

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
folder <- file.path(base, "BarbeitoAndres_etal_2019")
xls <- file.path(folder, "data_figshare.xlsx")
numv <- function(x) suppressWarnings(as.numeric(gsub(",", "", as.character(x))))
raw <- read_excel(xls, sheet = "Hoja1", col_names = FALSE)

## ---- output helper: TSVs replicate CSVs ----
write_csv_tsv <- function(x, stem, dir = folder) {
  csv_file <- file.path(dir, paste0(stem, ".csv"))
  tsv_file <- file.path(dir, paste0(stem, ".tsv"))

  readr::write_csv(x, csv_file, na = "")
  readr::write_tsv(x, tsv_file, na = "")

  message("Wrote ", csv_file)
  message("Wrote ", tsv_file)
}

## ---- Block 1: absolute volumes (mm3) ----
vol_regions <- c("Olfactory_bulbs","Cerebellum","Corpus_callosum","Midbrain","Lateral_ventricle",
                 "Striatum","Cortex","Hypothalamus","Third_ventricle","Hippocampus","Thalamus",
                 "Fimbria","Total")              # row 4 cols 3:15, as published (cleaned)
b1 <- raw[5:30, ]
names(b1)[1:15] <- c("specimen","group", vol_regions)
b1 <- b1 %>% filter(!is.na(group)) %>%
  mutate(specimen = as.character(specimen), group = as.character(group))
write_csv_tsv(b1, "BarbeitoAndres_etal_2019_volumes_snapshot")
vol_long <- b1 %>%
  pivot_longer(all_of(vol_regions), names_to = "region", values_to = "value") %>%
  transmute(species = "Mus musculus", reference = "BarbeitoAndres_etal_2019",
            group, specimen, region, cell_type = NA_character_,
            measure = "absolute_volume", value = numv(value), units = "mm3") %>%
  filter(!is.na(value))

## ---- Blocks 2 & 3: cell number / cell density ----
cell_regions <- c("Cerebellum","Cortex","Olfactory","Hippocampus","Rest")
cell_cols <- as.vector(t(outer(cell_regions, c("Total","Neurons","Non_neurons"), paste, sep = "__")))
parse_cell <- function(rows, measure, units) {
  blk <- raw[rows, ]
  names(blk)[1] <- "group"; names(blk)[2:16] <- cell_cols
  blk <- blk %>% filter(!is.na(group), group %in% c("C","LP","LCP")) %>%
    mutate(group = as.character(group))
  list(snapshot = blk,
       long = blk %>% pivot_longer(all_of(cell_cols), names_to = "rc", values_to = "value") %>%
         separate(rc, into = c("region","cell_type"), sep = "__") %>%
         transmute(species = "Mus musculus", reference = "BarbeitoAndres_etal_2019",
                   group, specimen = NA_character_, region,
                   cell_type = gsub("Non_neurons","Non-neurons", cell_type),
                   measure = measure, value = numv(value), units = units) %>%
         filter(!is.na(value)))
}
n2 <- parse_cell(34:48, "cell_number",  "cells")
n3 <- parse_cell(55:69, "cell_density", "cells_per_mg (as published; verify against paper)")
write_csv_tsv(n2$snapshot, "BarbeitoAndres_etal_2019_cellnumber_snapshot")
write_csv_tsv(n3$snapshot, "BarbeitoAndres_etal_2019_celldensity_snapshot")

## ---- data-readable outputs: split tables + combined tidy; TSVs replicate CSVs ----
## Split outputs are the analysis-ready counterparts to the faithful snapshots above.
## Keep the combined tidy table too for backward compatibility.
barbeito_volumes <- vol_long
barbeito_cellnumber <- n2$long
barbeito_celldensity <- n3$long

tidy <- bind_rows(barbeito_volumes, barbeito_cellnumber, barbeito_celldensity)

write_csv_tsv(barbeito_volumes,     "BarbeitoAndres_etal_2019_volumes")
write_csv_tsv(barbeito_cellnumber,  "BarbeitoAndres_etal_2019_cellnumber")
write_csv_tsv(barbeito_celldensity, "BarbeitoAndres_etal_2019_celldensity")
write_csv_tsv(tidy,                 "BarbeitoAndres_etal_2019_tidy")

message("Barbeito 2019: volumes ", nrow(barbeito_volumes),
        " | cell_number ", nrow(barbeito_cellnumber),
        " | cell_density ", nrow(barbeito_celldensity),
        " -> tidy ", nrow(tidy), " rows.")

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
publish(barbeito_volumes,     "BarbeitoAndres_etal_2019_volumes")
publish(barbeito_cellnumber,  "BarbeitoAndres_etal_2019_cellnumber")
publish(barbeito_celldensity, "BarbeitoAndres_etal_2019_celldensity")
