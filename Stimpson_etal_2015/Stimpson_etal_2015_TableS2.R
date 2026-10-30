## 0. PATHS ---------------------------------------------------------------

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

library(tidyverse)
library(readxl)

script_path  <- .sp
paper_dir    <- dirname(script_path)
dataset_root <- dirname(paper_dir)                   # Evo-M1-Trait-Data
table_name   <- tools::file_path_sans_ext(basename(script_path))

# Outputs
snapshot_xlsx <- file.path(paper_dir, paste0(table_name, "_snapshot.xlsx"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. LOAD SNAPSHOT -------------------------------------------------------

# Stimpson CD et al. 2015/2016, Supplementary Table S2.
# Per-individual amygdala and amygdala subnucleus volumes (cm3, one hemisphere)
# for bonobos and chimpanzees.
# This script follows the Sherwood_etal_2004_TABLEI.R model script.
# Both Stimpson table scripts belong in the same paper folder. Each table has
# its own R script, snapshot XLSX, local CSV, and public TSV, all named from
# table_name.
#
# Expected local input/output files in paper_dir:
#   Stimpson_etal_2015_TableS2.R
#   Stimpson_etal_2015_TableS2_snapshot.xlsx
#   Stimpson_etal_2015_TableS2.csv
#
# Expected public TSV output:
#   dataset_root/__Public/comparative-data/<Item encoded>.tsv
# where <Item encoded> is looked up from __ReadMe.xlsx using Item name ==
# Stimpson_etal_2015_TableS2.

numv <- function(x) {
  suppressWarnings(as.numeric(gsub(",", "", as.character(x))))
}

raw_all <- read_excel(
  snapshot_xlsx,
  sheet = 1,
  col_names = FALSE,
  col_types = "text",
  .name_repair = "minimal"
)

## 2. CLEAN VALUES --------------------------------------------------------

# The snapshot holds THREE stacked sub-tables, each with a title row, a structure
# row (structure names sit only over the Bonobo columns), a "Subject no." column-
# header row, per-subject data rows, then a "Mean ± SD" row. Data columns are
# (structure x species) pairs: col2 = struct1/Bonobo, col3 = struct1/Chimpanzee,
# col4 = struct2/Bonobo, col5 = struct2/Chimpanzee, ...
#   Block 1  "Volumes of regions (µm3)"    : 5 amygdala structures, one hemisphere.
#            The header reads µm3 but the VALUES are cm3 (whole amygdala ~0.7 cm3
#            per side; ~1.7 cm3 bilateral in chimp -> a µm3 amygdala is impossible),
#            so the column is kept as volume_cm3 to match the source magnitudes.
#   Block 2  "SERT axon density (µm/µm3)"   : the same 5 amygdala structures.
#   Block 3  "SERT axon density (µm/µm3)"   : control regions Middle temporal gyrus
#            and Caudate nucleus (SERT only; no volume reported).
# The earlier build did read_excel(skip = 3) and then treated EVERY numeric-subject
# row as volume_cm3, so the SERT rows (blocks 2 & 3) were silently ingested as
# amygdala "volumes" (e.g. the block-3 MTG/caudate SERT landed in the whole-amygdala
# and lateral-nucleus columns). This version parses each block by its own header and
# keeps volume and SERT as separate, correctly named and correctly united measures.

m <- as.matrix(raw_all)
species2 <- c("Pan paniscus", "Pan troglodytes")   # Bonobo, Chimpanzee (column order within a structure)

# Parse one block given its "Subject no." header-row index h. Returns long rows
# (subject_no, species, structure, value); structure names come from row h-1 and
# data rows run from h+1 down while the subject_no cell is a plain integer.
extract_block <- function(h) {
  struct_row  <- m[h - 1, ]
  struct_cols <- which(!is.na(struct_row))
  struct_cols <- struct_cols[struct_cols >= 2]           # Bonobo columns carry the structure label
  r <- h + 1L; data_rows <- integer(0)
  while (r <= nrow(m) && !is.na(m[r, 1]) && grepl("^[0-9]+$", trimws(m[r, 1]))) {
    data_rows <- c(data_rows, r); r <- r + 1L
  }
  bind_rows(lapply(struct_cols, function(cB) {
    st   <- gsub("\\s+", "_", trimws(struct_row[cB]))    # "Whole amygdala" -> "Whole_amygdala"
    subj <- as.integer(trimws(m[data_rows, 1]))
    bind_rows(
      tibble(subject_no = subj, species = species2[1], structure = st, value = numv(m[data_rows, cB])),
      tibble(subject_no = subj, species = species2[2], structure = st, value = numv(m[data_rows, cB + 1L]))
    )
  }))
}

hdr_rows <- which(tolower(trimws(m[, 1])) == "subject no.")   # one per sub-table
titles   <- vapply(hdr_rows, function(h) trimws(m[h - 2L, 1]), character(1))
blocks   <- lapply(hdr_rows, extract_block)

vol  <- bind_rows(blocks[grepl("volume", titles, ignore.case = TRUE)]) %>%
  filter(!is.na(value)) %>%
  transmute(subject_no, species, structure, volume_cm3 = value)
sert <- bind_rows(blocks[grepl("SERT",   titles, ignore.case = TRUE)]) %>%
  filter(!is.na(value)) %>%
  transmute(subject_no, species, structure, SERT_axon_density_um_per_um3 = value)

result_df <- full_join(vol, sert, by = c("subject_no", "species", "structure")) %>%
  mutate(hemisphere = "one side", source = "Stimpson_etal_2015") %>%
  arrange(species, structure, subject_no)

# Set the scipen option to a high value to turn off scientific notation.
options(scipen = 999)

## 3. SAVE ---------------------------------------------------------------

final.dataframe <- result_df

filecodes <- read_excel(readme_xlsx, sheet = "Sheet1")

item_encoded <- filecodes$`Item encoded`[
  match(table_name, filecodes$`Item name`)
]

if (is.na(item_encoded) || item_encoded == "") {
  stop("No 'Item encoded' entry found in __ReadMe.xlsx for Item name: ", table_name)
}

# Local CSV (paper folder)
write.csv(final.dataframe, final_csv, row.names = FALSE)

# Public TSV
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(
  final.dataframe,
  file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
  sep = "\t",
  row.names = FALSE
)
