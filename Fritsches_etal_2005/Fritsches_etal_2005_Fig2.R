## 0. PATHS --------------------------------------------------------
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
folder <- paper_dir <- dirname(.sp)
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))
base <- dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
public_tsv_dir<- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx   <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(stringr)
library(readxl)

## 2. LOAD SNAPSHOT -------------------------------------------------
# Fritsches et al. (2005) do not publish a formal Table 1. The
# comparative data (three species, retinal Q10, flicker-fusion
# frequencies) are reported in Figure 2 and in the text on p. 55.
# The snapshot digitises those values.
df_snapshot <- read.csv(snapshot_csv, stringsAsFactors = FALSE,
                        check.names = FALSE, encoding = "UTF-8")

## 3. STANDARDISE --> FINAL TABLE ----------------------------------
# em-dash "—" is used in the snapshot to mark values not reported for
# a given species. Convert to NA on the numeric side.
to_num <- function(x) {
  x <- gsub("—|-", NA, trimws(x))
  suppressWarnings(as.numeric(x))
}

final.dataframe <- df_snapshot %>%
  rename(
    species                       = Species,
    common_name                   = `Common name`,
    habitat_depth                 = `Habitat depth`,
    retinal_q10_light_adapted     = `Retinal Q10 (light-adapted)`,
    fff_at_10c_hz                 = `FFF at 10°C (Hz)`,
    fff_at_20c_hz                 = `FFF at 20°C (Hz)`,
    n                             = n,
    r_squared                     = `r-squared`,
    source                        = Source
  ) %>%
  mutate(
    common_name               = tolower(trimws(common_name)),
    species                   = trimws(species),
    retinal_q10_light_adapted = to_num(retinal_q10_light_adapted),
    fff_at_10c_hz             = to_num(fff_at_10c_hz),
    fff_at_20c_hz             = to_num(fff_at_20c_hz),
    n                         = to_num(n),
    r_squared                 = to_num(r_squared)
  )

## 4. SAVE OUTPUTS -------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, final_csv, row.names = FALSE)

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' found in __ReadMe.xlsx for Item name: ", table_name,
            " -- add a row to __ReadMe.xlsx before final submission.")
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(
      final.dataframe,
      file      = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
      sep       = "\t",
      row.names = FALSE
    )
  }
}
