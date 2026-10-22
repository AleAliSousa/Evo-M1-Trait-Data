## Walker R, Burger O, Wagner J, Von Rueden CR (2006). Evolution of brain size and juvenile periods in primates.
## J Hum Evol 51(5):480-489. Table 8 (journal p. 486): observed brain ratios in humans vs. those predicted from the
## authors' primate regressions (Tables 3-7), with chimpanzee brain ratios for comparison.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Input : Walker_etal_2006_Table8_snapshot.csv  (transcribed from PDF p.7; 5 brain ratios)
## Output: <script stem>.csv   LONG: one row per brain ratio x (chimp, human predicted, human observed) = 15
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
source_name <- sub("_Table[^_]*$", "", item_name)         # Walker_etal_2006_Table8 -> Walker_etal_2006
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character",
                 na.strings = c("", "NA"), fileEncoding = "UTF-8")
stopifnot(nrow(snap) == 5, ncol(snap) == 4)
num <- function(x) suppressWarnings(as.numeric(trimws(x)))

## each cell is a point value ("3.1") or an en-dash range ("2.4\u20133.2")
split_cell <- function(x) {
  p <- strsplit(x, "\u2013", fixed = TRUE)[[1]]
  if (length(p) == 1) c(num(p), num(p)) else c(num(p[1]), num(p[2]))
}
spec <- data.frame(col = 2:4,
  species    = c("Pan troglodytes", "Homo sapiens", "Homo sapiens"),
  value_type = c("observed (not labelled in table)", "predicted from primate regressions", "observed"),
  stringsAsFactors = FALSE)
out <- list()
for (k in seq_len(nrow(spec))) {
  mm <- t(sapply(snap[[spec$col[k]]], split_cell))
  out[[k]] <- data.frame(
    brain_ratio    = trimws(snap[[1]]),
    species        = spec$species[k],
    value_type     = spec$value_type[k],
    value_as_printed = snap[[spec$col[k]]],
    value_min      = unname(mm[, 1]),
    value_max      = unname(mm[, 2]),
    is_range       = unname(mm[, 1] != mm[, 2]),
    stringsAsFactors = FALSE)
}
clean <- do.call(rbind, out)
clean$source <- source_name
stopifnot(nrow(clean) == 15)
write.csv(clean, output_csv, row.names = FALSE, fileEncoding = "UTF-8")

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
