## Jacob_etal_2021_TABLE2.R — frozen snapshot -> analysis CSV -> public TSV
##
## Source : Jacob et al. (2021) J. Comp. Neurol. 529(14):3375-3388,
##          doi 10.1002/cne.25197 — TABLE 2 "Cytoarchitecture analysis of
##          sampled regions from the anterior frontoinsular region in raccoons"
##          (PDF p. 9). Thionin-stained layer-V FI cortex; intermediate-solver
##          tissue was unavailable, so only Nonsolver and Solver rows exist.
## Frozen : Jacob_etal_2021_TABLE2_snapshot.csv — extracted from the PDF text layer by
##          Jacob_etal_2021_extract_snapshot.R (extract-then-freeze), printed
##          layout kept (caption, headers incl. footnote markers a/b,
##          "mean ± SEM" cells, table notes). This script READS it; it never
##          writes or regenerates the snapshot.
## Units  : cell-profile counts per 200 x 300 um sampling field (as printed;
##          not cumulative counts) and percentages. No unit conversion applies.

## 0. PATHS (no setwd) --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or source from RStudio (save the file first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Jacob_etal_2021_TABLE2"
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", paper_dir, call. = FALSE)
  d
})
snapshot_csv   <- file.path(paper_dir, paste0(item_name, "_snapshot.csv"))
final_csv      <- file.path(paper_dir, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
if (!file.exists(snapshot_csv)) stop("Frozen snapshot not found: ", snapshot_csv, call. = FALSE)
if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl", call. = FALSE)

## 1. READ THE FROZEN SNAPSHOT ------------------------------------------------
## Layout: row 1 caption, row 2 printed headers, rows 3-4 data, then notes.
raw <- read.csv(snapshot_csv, header = FALSE, skip = 2, nrows = 2,
                stringsAsFactors = FALSE, fileEncoding = "UTF-8")
names(raw) <- c("solver_type_printed", "nonneurons_printed", "neuron_total_printed",
                "vens_printed", "fork_printed", "pct_vens_printed", "pct_all_printed")

## 2. CLEAN --------------------------------------------------------------------
split_pm <- function(x) {
  x    <- trimws(x)
  core <- sub("[a-z*]+$", "", x)
  data.frame(mean = as.numeric(trimws(sub("±.*$", "", core))),
             sem  = as.numeric(trimws(sub("^.*±", "", core))),
             stringsAsFactors = FALSE)
}
solver_type <- sub(" \\(N = \\d+\\)$", "", raw$solver_type_printed)
n_group     <- as.integer(sub("^.*N = (\\d+).*$", "\\1", raw$solver_type_printed))
nn  <- split_pm(raw$nonneurons_printed);  nt <- split_pm(raw$neuron_total_printed)
ven <- split_pm(raw$vens_printed);        fk <- split_pm(raw$fork_printed)
pv  <- split_pm(raw$pct_vens_printed);    pa <- split_pm(raw$pct_all_printed)

final_df <- data.frame(
  species_as_published = "Procyon lotor",
  region               = "anterior frontoinsular cortex (layer V)",
  solver_type          = solver_type,
  n_group              = n_group,
  nonneurons_per_field_mean  = nn$mean,  nonneurons_per_field_sem  = nn$sem,
  neuron_total_per_field_mean = nt$mean, neuron_total_per_field_sem = nt$sem,
  von_economo_neurons_per_field_mean = ven$mean, von_economo_neurons_per_field_sem = ven$sem,
  fork_neurons_per_field_mean = fk$mean, fork_neurons_per_field_sem = fk$sem,
  pct_von_economo_neurons_mean = pv$mean, pct_von_economo_neurons_sem = pv$sem,   # % of neurons (header footnote a)
  pct_all_neurons_mean = pa$mean, pct_all_neurons_sem = pa$sem,                   # % of total cells (header footnote b)
  sampling_field_um    = "200 x 300",
  source = "Jacob_etal_2021 TABLE 2",
  stringsAsFactors = FALSE
)
stopifnot(nrow(final_df) == 2L, !anyNA(final_df$nonneurons_per_field_mean))

## 3. WRITE CSV + PUBLIC TSV ---------------------------------------------------
write.csv(final_df, final_csv, row.names = FALSE, na = "")
filecodes <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")
hit <- which(filecodes[["Item name"]] == item_name)          # by name, never row number
if (length(hit) != 1L) stop("Registry rows matching '", item_name, "': ", length(hit), call. = FALSE)
item_encoded <- filecodes[["Item encoded"]][hit]
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("Bad Item encoded for ", item_name, ": '", item_encoded, "'", call. = FALSE)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(final_df, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", quote = FALSE, row.names = FALSE, na = "")
message("Built ", item_name, ": ", nrow(final_df), " rows -> CSV + ", item_encoded, ".tsv")
