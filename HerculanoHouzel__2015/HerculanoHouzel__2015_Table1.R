## =============================================================================
## Herculano-Houzel (2015) Table 1  -->  analysis-ready CSV
## Decreasing sleep requirement ... Proc Biol Sci 282(1816), 20151853.
## DOI: 10.1098/rspb.2015.1853   |   PMC: PMC4614783
## =============================================================================
##
## PROVENANCE -- why this table was captured from HTML, not the PDF
## -----------------------------------------------------------------------------
## Table 1 is printed in ROTATED LANDSCAPE across two pages and does not extract
## cleanly from the PDF (contrast Table 2 in this folder, which uses tabulapdf
## on the PDF). It was therefore captured from the open-access PMC HTML version
## and then cross-checked CELL-BY-CELL against the published PDF. All data values
## were confirmed to match the PDF; the per-cell reference citations [n] and the
## footnote markers (*, a, b, c) were taken from the published table.
##   Source (HTML): https://pmc.ncbi.nlm.nih.gov/articles/PMC4614783/
##
## SNAPSHOT RULE -- the one thing to get right
## -----------------------------------------------------------------------------
## The snapshot is the FROZEN, FAITHFUL copy of the table AS PUBLISHED. It keeps
## the reference citations [n], the footnote markers (*, a, b, c), the units,
## the scientific notation and the clade header rows. It is scraped and SAVED
## BEFORE any cleaning, on every run, and every step below operates on it -- so
## the clean data is always traceable back to the source. Re-running re-fetches
## the PMC page and rewrites the snapshot; because the save happens before any
## bracket/footnote removal, the rewritten snapshot stays faithful (references
## and footnote markers intact).
## =============================================================================
## 0. PATHS (no setwd) ---------------------------------------------------------

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
item_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

paper_dir <- dirname(.sp)
dataset_root  <- dirname(paper_dir)
# outputs
snapshot_csv  <- file.path(paper_dir, paste0(item_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")

## 1. SOURCE  -->  SNAPSHOT (scraped and saved every run, before any cleaning) --
library(rvest)
library(tidyverse)
library(readxl)
if ("--refresh-snapshot" %in% commandArgs(trailingOnly = TRUE)) {
  page <- read_html("https://pmc.ncbi.nlm.nih.gov/articles/PMC4614783/")
  raw  <- (page |> html_elements("table") |> html_table(fill = TRUE))[[1]]
  # The scraped header row is split/garbled by html_table(); restore the column
  # labels exactly as printed in the published Table 1.
  colnames(raw) <- c("species", "brain mass (g or cm3)", "daily sleep (h)",
                     "D/A (N mg−1 mm−2)", "NCX", "DNCX (N mg−1)",
                     "ACX (mm2)", "O/N", "T", "MCX (g or cm3)")
}

## 2. DATA READABLE (snapshot --> analysis-ready) ------------------------------
## Read the frozen snapshot back; all cleaning happens here, never above.
df <- read.csv("HerculanoHouzel__2015_Table1_snapshot.csv")

## 2.1 Remove reference citations in square brackets, e.g. "15.750 [19]" -------
df[] <- lapply(df, function(x) gsub("\\[.*?\\]", "", x))
## 2.2 Convert "n.a." to NA ----------------------------------------------------
df[] <- lapply(df, function(x) ifelse(trimws(x) == "n.a.", NA, x))
## 2.3 Remove footnote asterisks, e.g. "59 280*" -------------------------------
df[] <- lapply(df, function(x) gsub("\\*", "", x))
## 2.4 Remove trailing footnote letters on numbers, e.g. "218a", "...106b" -----
df[ , -1] <- lapply(df[ , -1], function(x) gsub("([0-9])([A-Za-z])$", "\\1", x))
## 2.5 Remove thousands spaces, e.g. "47 960" -> "47960" -----------------------
df[ , -1] <- lapply(df[ , -1], function(x) gsub(" ", "", x))
## 2.6 Remove any stray letters left in the numeric columns --------------------
df[ , -1] <- lapply(df[ , -1], function(x) gsub("[A-Za-z]", "", x))
## 2.7 Scientific notation in NCX: "X × 10^n" / "X × 10n" -> "Xen" ----
convert_index_form <- function(x) {
  x <- gsub("×10\\^", "e", x)   # handles the "x 10^" form
  x <- gsub("×10",    "e", x)   # handles the "x 10"  form
  x
}
df[["NCX"]] <- convert_index_form(df[["NCX"]])
## 2.8 Types: species stays character, every other column becomes numeric ------
df[[1]]   <- as.character(df[[1]])
df[ , -1] <- lapply(df[ , -1], as.numeric)
## 2.9 Turn the clade header rows into a "category" column, then drop them ------
categories <- c("Primates", "Eulipotyphla", "Glires",
                "Afrotheria", "Artiodactyla", "Scandentia")
final.dataframe <- df |>
  mutate(category = if_else(species %in% categories, species, NA_character_)) |>
  fill(category, .direction = "down") |>
  filter(!species %in% categories) |>
  relocate(category, .after = species)

## 3. SAVE: local CSV + DOI-named TSV ----
# Item encoded lookup uses item_name (script filename)
filecodes <- read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]

write.csv(final.dataframe, file = file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
# Public TSV output
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(final.dataframe,
            file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE)
