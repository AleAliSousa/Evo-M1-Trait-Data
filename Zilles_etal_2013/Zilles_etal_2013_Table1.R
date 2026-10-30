# Zilles_etal_2013_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Zilles, Palomero-
# Gallagher & Amunts (2013) Table 1 -- "Brain size and gyrification index (GI)
# in various mammalian orders, families, and species" -- into a lean, analysis-
# ready CSV. Output comes from the snapshot only. doi:10.1016/j.tins.2013.01.006
#
# Layout note: Table 1 is the usual species-as-rows table, BUT (a) it carries a
# taxonomic hierarchy in the first two columns (Order, Family) that the print
# leaves BLANK on continuation rows, and (b) several species report MORE THAN
# ONE GI value, each from a different source reference ([4],[5],[7],[87]); those
# extra values are printed as rows with a blank Order/Family/Species/Common name.
# The snapshot preserves that printed layout verbatim (blanks and all).
#
# THIS script reads past the caption (row 1) + header (row 2), forward-fills the
# repeated Order/Family/Species/Common-name cells, keeps ONE ROW PER GI VALUE
# (so a species with 3 GI values yields 3 rows, each with its own Ref + method),
# harmonises the printed species name to an accepted binomial (species_sci) via
# the _keys resolver, and writes one tidy CSV. NOTE: Table 1 lists no primates
# (primate GI scaling is in the paper's Figure 2, not this table).
#
# Input  : Zilles_etal_2013_Table1_snapshot.xlsx   sheet: Table1
# Outputs: Zilles_etal_2013_Table1.csv             one row per GI value (54)
#          <DOI>_Table1.tsv in __Public/comparative-data/  named from __ReadMe.xlsx

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr); library(tidyr)
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))    # = "Zilles_etal_2013_Table1"
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "Table1"
output_file    <- paste0(item_name, ".csv")

## ---- species resolver (single source of truth = _keys) ----------------------
resolve <- local({
  if (is.na(base)) return(function(x) str_squish(gsub("_", " ", gsub("\\*", "", x))))
  key <- read.csv(file.path(base, "_keys/Stephan/species_key.csv"), stringsAsFactors = FALSE)
  ref <- read.csv(file.path(base, "_keys/species_reference.csv"),   stringsAsFactors = FALSE)$accepted_name
  km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
  clean <- function(x) str_squish(gsub("_", " ", gsub("\\*", "", x)))
  function(x) { c <- clean(x)
    h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
    a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }
})

## ---- GI-method lookup (footnote 'a') ----
method <- c("[4]" = "contour-based (Wisconsin/MSU collections)",
            "[5]" = "stereological (formalin-fixed, histology)",
            "[7]" = "brain-surface coverage with paper (formalin-fixed postmortem)",
            "[87]"= "stereological (formalin-fixed, histology)")

## ---- read faithful snapshot: row1 caption, row2 header, data from row3 -------
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
raw <- raw[-1, ]                                    # drop caption
names(raw) <- c("Order","Family","Species","Common_name","Brain_size","GI","Ref")
raw <- raw[-1, ]                                    # drop header row
raw <- raw %>% filter(!is.na(GI) & !is.na(suppressWarnings(as.numeric(GI))))  # keep GI rows, drop footnote

df <- raw %>%
  mutate(across(c(Order, Family, Species, Common_name), ~ na_if(str_squish(.), ""))) %>%
  fill(Order, Family, Species, Common_name, .direction = "down") %>%   # forward-fill printed repeats
  transmute(
    species_sci = vapply(Species, resolve, character(1)),
    Species, Common_name, Order, Family,
    Brain_size  = suppressWarnings(as.numeric(Brain_size)),  # table's mixed volume/weight figure (cm3 or g)
    GI          = as.numeric(GI),
    Ref, GI_method = unname(method[Ref]))

options(scipen = 999)
write.csv(df, output_file, row.names = FALSE, fileEncoding = "UTF-8")
message("Wrote ", output_file, "  (", nrow(df), " GI rows, ",
        length(unique(df$Species)), " species)")

## ---- DOI-coded TSV to __Public/comparative-data/ (skipped if shared repo absent) ----
tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base)) {
  fc <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$"Item encoded"[match(item_name, fc$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(df, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
