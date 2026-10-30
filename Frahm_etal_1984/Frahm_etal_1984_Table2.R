## Frahm HD, Stephan H, Baron G (1984). Comparison of brain structure volumes...
## Table 2.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI/PMID-coded public TSV.
## Input : <script stem>_snapshot.xlsx
## Output: <script stem>.csv
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)

options(scipen = 999)
suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))
source_name   <- sub("_Table[^_]*$", "", item_name)
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
output_csv    <- paste0(item_name, ".csv")
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot ----
header_rows <- 2L
cols <- c(
  "species_disp", "ASV_percent_BrW", "ASV_percent_TV", "ASV_percent_NV",
  "ASW_percent_NW", "ASG_percent_NG", "ASG1_percent_NG1",
  "ASG2_6_percent_NG2_6", "ASG_percent_ASV", "ASG1_percent_ASG",
  "ASG_to_CGL_ratio"
)
num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a.", "__"))
raw <- read_excel(snapshot_xlsx, sheet = "Table2", col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(cols)] <- cols

## Table 2 shares the Tables 1-3 species-name footnote.
footnote_file <- file.path("reference_tables", "Frahm_etal_1984_Table1_footnotes.csv")
if (!file.exists(footnote_file)) {
  stop("Missing shared Tables 1-3 footnote file: ", footnote_file, call. = FALSE)
}
footnotes <- read_csv(footnote_file, show_col_types = FALSE)

clean <- dat %>%
  filter(!is.na(num(ASV_percent_BrW))) %>%
  transmute(
    Species = str_squish(species_disp),
    across(all_of(cols[-1]), num),
    source = source_name
  ) %>%
  left_join(
    footnotes %>% select(species_in_table, former_name_stephan1981),
    by = c(Species = "species_in_table")
  )

if (nrow(clean) != 44L) stop("Expected 44 species rows; found ", nrow(clean), ".", call. = FALSE)
if (anyDuplicated(clean$Species)) stop("Duplicate species remained after parsing Table 2.", call. = FALSE)
if (any(clean$ASG_percent_ASV <= 0 | clean$ASG_percent_ASV > 100, na.rm = TRUE)) {
  stop("ASG_percent_ASV contains values outside (0, 100].", call. = FALSE)
}
write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx ----
tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")))
}
message("Wrote ", output_csv, " (", nrow(clean), " species)")
