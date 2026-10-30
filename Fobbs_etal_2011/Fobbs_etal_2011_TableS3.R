# Fobbs_etal_2011_TableS3.R
#
# Complete build pipeline for Fobbs & Johnson (2011), supplementary TableS3:
# legacy journal .doc -> frozen XLSX snapshot -> clean CSV -> registry-coded TSV.
# The source wording and historical nomenclature are preserved; taxonomy is not modernized.
#
# Source  : nyas_6036_sm_table3.doc
# Helper  : Fobbs_etal_2011_build_snapshot.py
# Snapshot: Fobbs_etal_2011_TableS3_snapshot.xlsx, sheet "TableS3"
# Outputs : Fobbs_etal_2011_TableS3.csv
#           <Item encoded>.tsv under __Public/comparative-data/

options(scipen = 999)
suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); setwd(folder)
item_name <- tools::file_path_sans_ext(basename(.sp))
source_doc <- "nyas_6036_sm_table3.doc"
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
helper <- "Fobbs_etal_2011_build_snapshot.py"

# Rebuild the frozen snapshot from the digital supplementary document only when
# absent or explicitly requested. Default FALSE protects the audited snapshot.
rebuild_snapshot <- FALSE
if (rebuild_snapshot || !file.exists(snapshot_xlsx)) {
  if (!file.exists(source_doc)) stop("Missing source document: ", source_doc, call.=FALSE)
  if (!file.exists(helper)) stop("Missing snapshot helper: ", helper, call.=FALSE)
  status <- system2("python3", c(shQuote(helper), shQuote(item_name)))
  if (!identical(status, 0L) || !file.exists(snapshot_xlsx)) stop("Snapshot build failed.", call.=FALSE)
}

raw <- read_excel(snapshot_xlsx, sheet="TableS3", skip=1, col_names=TRUE, col_types="text")
if (ncol(raw) != 6L) stop("Expected 6 columns; found ", ncol(raw), ".", call.=FALSE)
names(raw) <- c("animal_number", "common_name", "scientific_name", "plane_of_section", "total_number_of_sections", "slide_size")
clean_text <- function(x) {
  x <- str_squish(as.character(x)); x[x %in% c("", "NA")] <- NA_character_; x
}
final.dataframe <- raw %>% mutate(across(everything(), clean_text)) %>% filter(if_any(everything(), ~ !is.na(.x)))

final.dataframe <- final.dataframe %>% filter(!is.na(animal_number))

if (!nrow(final.dataframe)) stop("No catalog records remained after cleaning.", call.=FALSE)
final.dataframe <- final.dataframe %>% mutate(source_row = row_number(), .before=1)
write_csv(final.dataframe, paste0(item_name, ".csv"), na="")

base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) {
  warning("Repository root containing __ReadMe.xlsx was not found; public TSV skipped.")
} else {
  registry <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded))
    stop("No 'Item encoded' for ", item_name, " in __ReadMe.xlsx; fix the registry row first.")
  public_tsv_dir <- file.path(base, "__Public", "comparative-data")
  dir.create(public_tsv_dir, recursive=TRUE, showWarnings=FALSE)
  tsv_file <- file.path(public_tsv_dir, paste0(item_encoded, ".tsv"))
  write_tsv(final.dataframe, tsv_file, na="")
  message("Wrote ", tsv_file)
}
message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " catalog records)")
