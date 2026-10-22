## Reep RL, O'Shea TJ (1990). Regional brain morphometry and lissencephaly in the Sirenia. Brain Behav Evol 35(4):185-194.
## Table 3: cortical data (GI, cortical surface area) from spaced sections in 2 Florida manatee brains (Trichechus manatus).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV (if registered).
##
## Input : Reep_OShea_1990_Table3_snapshot.csv  (transcribed from PDF p.6 = journal p.190; scanned, no text layer)
## Output: <script stem>.csv                 one row per brain (2) + printed Mean (3)
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
  brain                      = snap[[1]],                          # as printed incl. sectioning plane
  taxon_printed              = "Florida manatees",
  species                    = "Trichechus manatus",               # from Abstract/Methods, not printed in the table
  gyrification_index_GI      = num(snap[[2]]),
  cortical_surface_left_cm2  = num(snap[[3]]),
  cortical_surface_right_cm2 = num(snap[[4]]),
  cortical_surface_total_cm2 = num(snap[[5]]),
  source                     = source_name,
  stringsAsFactors = FALSE
)
## ---- table check: left + right = total (rounding), and Mean row = mean of the 2 brains ----
cat("left+right-total:", paste(with(clean, cortical_surface_left_cm2 + cortical_surface_right_cm2 - cortical_surface_total_cm2), collapse = " "), "\n")
cat("mean of brains vs printed Mean row:", paste(round(colMeans(clean[1:2, 4:7]), 2), collapse = " "), "|", paste(unlist(clean[3, 4:7]), collapse = " "), "\n")

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
