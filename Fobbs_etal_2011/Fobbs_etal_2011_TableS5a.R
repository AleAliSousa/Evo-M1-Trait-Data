# Fobbs_etal_2011_TableS5a.R
#
# Complete build pipeline for Fobbs & Johnson (2011), supplementary TableS5a:
# legacy journal .doc -> frozen XLSX snapshot -> clean CSV -> registry-coded TSV.
# The source wording and historical nomenclature are preserved; taxonomy is not modernized.
#
# Source  : nyas_6036_sm_table5a.doc
# Helper  : Fobbs_etal_2011_build_snapshot.py
# Snapshot: Fobbs_etal_2011_TableS5a_snapshot.xlsx, sheet "TableS5a"
# Outputs : Fobbs_etal_2011_TableS5a.csv
#           <Item encoded>.tsv under __Public/comparative-data/

options(scipen = 999)
suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr); library(tidyr)
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
source_doc <- "nyas_6036_sm_table5a.doc"
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

raw <- read_excel(snapshot_xlsx, sheet="TableS5a", skip=1, col_names=TRUE, col_types="text")
if (ncol(raw) != 9L) stop("Expected 9 columns; found ", ncol(raw), ".", call.=FALSE)
names(raw) <- c("specimen_number", "species", "common_name", "material", "stain", "plane", "section_thickness_micrometers", "number_of_slides", "number_of_sections")
clean_text <- function(x) {
  x <- str_squish(as.character(x)); x[x %in% c("", "NA")] <- NA_character_; x
}
final.dataframe <- raw %>% mutate(across(everything(), clean_text)) %>% filter(if_any(everything(), ~ !is.na(.x)))

# Printed clade headings and continuation notes are separate source rows. Preserve
# the clade by carrying it forward; append one-cell continuation notes to the prior
# specimen rather than treating them as specimens.
rows <- final.dataframe
is_group <- is.na(rows$specimen_number) & !is.na(rows$species) & rowSums(!is.na(rows)) == 1L & str_detect(rows$species, "^[A-Z][A-Z ]+$")
rows$collection_group <- ifelse(is_group, rows$species, NA_character_)
rows <- tidyr::fill(rows, collection_group)
is_cont <- is.na(rows$specimen_number) & !is.na(rows$species) & !is_group & rowSums(!is.na(rows[names(rows) != "collection_group"])) == 1L
rows$continuation_note <- NA_character_
for (i in which(is_cont)) {
  j <- max(which(seq_len(nrow(rows)) < i & !is.na(rows$specimen_number)))
  rows$continuation_note[j] <- paste(na.omit(c(rows$continuation_note[j], rows$species[i])), collapse="; ")
}
final.dataframe <- rows %>% filter(!is_group, !is_cont, !is.na(specimen_number))

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
