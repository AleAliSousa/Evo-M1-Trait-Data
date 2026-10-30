## Reep RL, O'Shea TJ (1990). Regional brain morphometry and lissencephaly in the Sirenia. Brain Behav Evol 35(4):185-194.
## Table 4: cortical gray matter thickness measured directly from slices of brains from 3 Florida manatees (Trichechus manatus).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV (if registered).
##
## Input : Reep_OShea_1990_Table4_snapshot.csv  (transcribed from PDF p.6 = journal p.190; scanned, no text layer)
## Output: <script stem>.csv                 one row per brain (3) + printed Mean (4)
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
source_name <- sub("_Table[^_]*$", "", item_name)         # <Folder>_Table<N> -> <Folder>
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers; blanks stay blank) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, na.strings = character(0), colClasses = "character")
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

clean <- data.frame(
  brain                  = snap[[1]],                              # as printed incl. (n = ...)
  taxon_printed          = "Florida manatees",
  species                = "Trichechus manatus",                   # from Abstract/Methods, not printed in the table
  n_measurements         = num(sub(".*n = *([0-9]+).*", "\\1", ifelse(grepl("n =", snap[[1]]), snap[[1]], NA))),
  cortical_thickness_mean_mm = num(snap[[2]]),
  cortical_thickness_SD_mm   = num(snap[[3]]),
  source                 = source_name,
  stringsAsFactors = FALSE
)
## ---- table check: printed Mean vs n-weighted and simple mean of the 3 brains ----
b <- clean[1:3, ]
cat("simple mean:", round(mean(b$cortical_thickness_mean_mm), 3), " n-weighted mean:", round(weighted.mean(b$cortical_thickness_mean_mm, b$n_measurements), 3), " printed Mean:", clean$cortical_thickness_mean_mm[4], "\n")
cat("mean SD:", round(mean(b$cortical_thickness_SD_mm), 3), " printed:", clean$cortical_thickness_SD_mm[4], "\n")

write.csv(clean, output_csv, row.names = FALSE)
cat(nrow(clean), "rows written to", output_csv, "\n")

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
