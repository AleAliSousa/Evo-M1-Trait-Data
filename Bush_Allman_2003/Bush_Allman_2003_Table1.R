## Bush EC, Allman JM (2003). The scaling of white matter to gray matter in cerebellum
## and neocortex. Brain Behav Evol 61(1):1-5. Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published; harmonisation to the project key happens downstream (__merging_volumes).
## QA against the compiled/digitised copies lives in the private companion repo (run those
## scripts on their own; this build does not perform the comparison).
##
## Input : Bush_Allman_2003_Table1_snapshot.csv   (Group, Species, + 4 cm3 volume cols)
## Output: <script stem>.csv                  one row per species (45)
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
source_name <- sub("_Table[^_]*$", "", item_name)         # e.g., Bush_Allman_2003_Table1 -> Bush_Allman_2003
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
                 check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("", "NA", "n.a.", "-", "--"))

## ---- build writes the PUBLISHED species name only ----
## Species-key harmonisation (against _keys/Allman/species_key.csv) is NOT done here;
## it is applied downstream in __merging_volumes/volumes_compiled.R (token source_name).
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

## ---- clean (volumes kept in cm3, per the definitions; merge converts downstream) ----
clean <- data.frame(
  species              = trimws(snap$Species),   # name exactly as published
  group                = trimws(snap$Group),
  cer_white_cm3        = num(snap[["Cer White"]]),
  cer_gray_cm3         = num(snap[["Cer Gray"]]),
  neo_white_cm3        = num(snap[["Neo White"]]),
  neo_gray_cm3         = num(snap[["Neo Gray"]]),
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
