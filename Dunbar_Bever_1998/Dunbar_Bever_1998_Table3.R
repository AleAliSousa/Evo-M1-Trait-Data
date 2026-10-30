## Dunbar RIM, Bever J (1998). Neocortex size predicts group size in carnivores and some insectivores.
## Ethology 104(8):695-708. Table 3: Neocortex size and group size of insectivores (GENUS level).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Names are written exactly as published; harmonisation to the project key happens downstream.
## Rows are genera, not species.
##
## Input : Dunbar_Bever_1998_Table3_snapshot.csv  (transcribed from the PDF; 25 rows)
## Output: <script stem>.csv                 one row per genus (25)
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
folder      <- dirname(.sp)
item_name   <- tools::file_path_sans_ext(basename(.sp))
source_name <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")
base        <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character")
num  <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))

## ---- clean (volumes mm3 as printed; footnote markers on names/headers are stripped only in derived columns) ----
clean <- data.frame(
  genus                = trimws(snap$Genus),                   # GENUS-level rows, as published
  cerebral_development = trimws(snap[[2]]),                    # Basal / Advanced / Unknown after Stephan (1972); case as printed
  n_species_sampled    = num(snap[[3]]),
  brain_volume_mm3     = num(snap[[4]]),
  neocortex_volume_mm3 = num(snap[[5]]),
  neocortex_ratio_CR   = num(snap[[6]]),                       # averaged over species sampled in the genus
  group_size_N         = num(snap[[7]]),                       # mean group size (paper's definition)
  source               = source_name,
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
