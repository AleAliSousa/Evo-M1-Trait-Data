## Reep RL, O'Shea TJ (1990). Regional brain morphometry and lissencephaly in the Sirenia. Brain Behav Evol 35(4):185-194.
## Table 1: percent volume estimates of the major brain regions in 4 Florida manatees (Trichechus manatus).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV (if registered).
## Snapshot is parameters-as-rows (as printed); the CSV is transposed to one row per specimen + the printed mean row.
##
## Input : Reep_OShea_1990_Table1_snapshot.csv  (transcribed from PDF p.5 = journal p.189; scanned, no text layer)
## Output: <script stem>.csv                 one row per specimen (4) + printed Mean (5)
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

g <- function(label) { r <- snap[snap$Parameter == label, , drop = FALSE]; stopifnot(nrow(r) == 1); num(gsub("[()]", "", unlist(r[1, -1]))) }
spec <- names(snap)[-1]                                           # M-412 M-433 M-450 M-387 Mean
clean <- data.frame(
  specimen                 = spec,
  taxon_printed            = "Florida manatees",
  species                  = "Trichechus manatus",                # not printed in the table; from Abstract/Methods (West Indian manatee)
  brain_weight_g           = g("Brain weight, g"),
  sections_n               = g("Sections, n"),
  pct_telencephalon_cortex = g("Telencephalon: Cortex"),
  pct_basal_ganglia_septum = g("Telencephalon: Basal ganglia/septum"),
  pct_amygdala             = g("Telencephalon: Amygdala"),
  pct_telencephalon_total  = g("Telencephalon: Total"),
  cortex_pct_of_telencephalon = g("Telencephalon: (Cerebral cortex as percent telencephalon)"),
  pct_thalamus             = g("Diencephalon: Thalamus"),
  pct_hypothalamus         = g("Diencephalon: Hypothalamus"),
  pct_diencephalon_total   = g("Diencephalon: Total"),
  pct_mesencephalon        = g("Mesencephalon"),
  pct_pons                 = g("Pons"),
  pct_cerebellum           = g("Cerebellum"),
  pct_medulla              = g("Medulla"),
  source                   = source_name,
  stringsAsFactors = FALSE
)
## ---- table check: telencephalon and diencephalon totals; all regions sum to ~100% of brain volume ----
tot <- with(clean, pct_telencephalon_total + pct_diencephalon_total + pct_mesencephalon + pct_pons + pct_cerebellum + pct_medulla)
cat("sum of major divisions (%):", paste(round(tot, 2), collapse = " "), "\n")
cat("cortex+BG+amygdala - telencephalon total:", paste(round(with(clean, pct_telencephalon_cortex + pct_basal_ganglia_septum + pct_amygdala - pct_telencephalon_total), 2), collapse = " "), "\n")

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
