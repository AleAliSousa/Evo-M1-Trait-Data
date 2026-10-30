## Sherwood CC, Stimpson CD, Butti C, Bonar CJ, Newton AL, Allm
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published; harmonisation to the project key happens downstream.
##
## Input : Sherwood_etal_2009_Table1_snapshot.csv  (transcribed from the PDF render; 7 rows)
## Output: <script stem>.csv                 one row per snapshot row (7)
##         <Item encoded>.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

options(scipen = 999)
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
folder      <- dirname(.sp)                              # this paper's folder
item_name   <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name <- sub("_Table[^_]*$", "", item_name)         # Barrickman_Lin_2010_Table1 -> Barrickman_Lin_2010
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv,
                 check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character",
                 na.strings = c("", "NA"))

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))
## "mean +/- error" cells -> value and error (error is blank when the cell has no +/-)
pm_val <- function(x) num(sub("\\s*\u00b1.*$", "", x))
pm_err <- function(x) ifelse(grepl("\u00b1", x), num(sub("^.*\u00b1\\s*", "", x)), NA_real_)

## ---- clean ----
clean <- data.frame(
  species          = trimws(snap$Species),   # name exactly as published
  specimen_row     = seq_len(nrow(snap)),    # printed row order (the table has no specimen IDs; Table 3 labels them TS1, TS2, ...)
  common_name      = trimws(snap[["Common name"]]),
  sex              = trimws(snap$Sex),
  age_as_printed   = trimws(snap$Age),
  brain_mass_g     = num(sub("a$", "", snap[["Brain mass (g)"]])),
  brain_mass_footnote_a = grepl("a$", snap[["Brain mass (g)"]]),   # TRUE = value not measured (see definitions)
  body_mass_kg     = num(snap[["Body mass (kg)"]]),
  fixation_days    = num(snap[["Length of fixation (days)"]]),
  source           = source_name,
  stringsAsFactors = FALSE
)

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
