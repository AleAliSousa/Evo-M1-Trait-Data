## Jacob_etal_2021_TABLE3.R — frozen snapshot -> analysis CSV -> public TSV
##
## Source : Jacob et al. (2021) J. Comp. Neurol. 529(14):3375-3388,
##          doi 10.1002/cne.25197 — TABLE 3 "Cytoarchitecture analysis of the
##          hilus of the dentate gyrus region in raccoons" (PDF p. 11).
## Frozen : Jacob_etal_2021_TABLE3_snapshot.csv — extracted from the PDF text layer by
##          Jacob_etal_2021_extract_snapshot.R (extract-then-freeze), printed
##          layout kept, incl. the "*" on the Solver fusiform cell
##          ("1.42 ± 0.15*"; Figure 7 caption: *p = .0495 vs intermediates;
##          ANOVA F(2,11) = 4.640, p = .035). This script READS the snapshot;
##          it never writes or regenerates it.
## Units  : cell-profile counts per 200 x 300 um sampling field (as printed;
##          not cumulative counts) and percentages. No unit conversion applies.
## Note   : Results text prints nonsolver fusiform mean xc = 0.79; the table
##          prints 0.71 ± 0.27. Kept as printed in the table; see ReadMe.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Jacob_etal_2021_TABLE3"
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
## Layout: row 1 caption, row 2 printed headers, rows 3-5 data, then notes.
raw <- read.csv(snapshot_csv, header = FALSE, skip = 2, nrows = 3,
                stringsAsFactors = FALSE, fileEncoding = "UTF-8")
names(raw) <- c("solver_type_printed", "nonneurons_printed", "neuron_total_printed",
                "fusiform_printed", "pct_fusiform_printed", "pct_all_printed")

## 2. CLEAN --------------------------------------------------------------------
split_pm <- function(x) {
  x      <- trimws(x)
  marker <- ifelse(grepl("[a-z*]+$", x), sub("^.*?([a-z*]+)$", "\\1", x, perl = TRUE), "")
  core   <- sub("[a-z*]+$", "", x)
  data.frame(mean     = as.numeric(trimws(sub("±.*$", "", core))),
             sem      = as.numeric(trimws(sub("^.*±", "", core))),
             footnote = marker, stringsAsFactors = FALSE)
}
solver_type <- sub(" \\(N = \\d+\\)$", "", raw$solver_type_printed)
n_group     <- as.integer(sub("^.*N = (\\d+).*$", "\\1", raw$solver_type_printed))
nn <- split_pm(raw$nonneurons_printed);   nt <- split_pm(raw$neuron_total_printed)
fu <- split_pm(raw$fusiform_printed)
pf <- split_pm(raw$pct_fusiform_printed); pa <- split_pm(raw$pct_all_printed)

final_df <- data.frame(
  species_as_published = "Procyon lotor",
  region               = "hilus of the dentate gyrus",
  solver_type          = solver_type,
  n_group              = n_group,
  nonneurons_per_field_mean  = nn$mean,  nonneurons_per_field_sem  = nn$sem,
  neuron_total_per_field_mean = nt$mean, neuron_total_per_field_sem = nt$sem,
  fusiform_neurons_per_field_mean = fu$mean, fusiform_neurons_per_field_sem = fu$sem,
  fusiform_footnote_ref = fu$footnote,   # "*" = p .0495 vs intermediates (Figure 7 caption)
  pct_fusiform_neurons_mean = pf$mean, pct_fusiform_neurons_sem = pf$sem,  # % of neurons (header footnote a)
  pct_all_neurons_mean = pa$mean, pct_all_neurons_sem = pa$sem,            # % of total cells (header footnote b)
  sampling_field_um    = "200 x 300",
  source = "Jacob_etal_2021 TABLE 3",
  stringsAsFactors = FALSE
)
stopifnot(nrow(final_df) == 3L, identical(final_df$fusiform_footnote_ref, c("", "", "*")))

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
