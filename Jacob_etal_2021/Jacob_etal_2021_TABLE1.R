## Jacob_etal_2021_TABLE1.R — frozen snapshot -> analysis CSV -> public TSV
##
## Source : Jacob et al. (2021) J. Comp. Neurol. 529(14):3375-3388,
##          doi 10.1002/cne.25197 — TABLE 1 "Hemisphere and brain area weights"
##          (PDF p. 5). Raccoon (Procyon lotor), three problem-solving groups.
## Frozen : Jacob_etal_2021_TABLE1_snapshot.csv — extracted from the PDF text layer by
##          Jacob_etal_2021_extract_snapshot.R (extract-then-freeze), printed
##          layout kept (caption row, printed headers, "mean ± SEM" cells,
##          footnote marker "a", table notes). This script READS it; it never
##          writes or regenerates the snapshot.
## Units  : hemisphere & somatosensory cortex printed in g -> converted to mg
##          (x 1000; project brain-mass unit); hippocampus printed in mg, kept.
## Footnote a = "N - 1, value missing for one animal" -> per-measure n columns.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Jacob_etal_2021_TABLE1"
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
names(raw) <- c("solver_type_printed", "hemisphere_printed",
                "hippocampus_printed", "somatosensory_printed")

## 2. CLEAN --------------------------------------------------------------------
## split "18.52 ± 0.82a" -> mean / sem / trailing footnote marker
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
hemi <- split_pm(raw$hemisphere_printed)
hipp <- split_pm(raw$hippocampus_printed)
ssc  <- split_pm(raw$somatosensory_printed)
n_eff <- function(fn) ifelse(fn == "a", n_group - 1L, n_group)  # footnote a: N - 1

final_df <- data.frame(
  species_as_published = "Procyon lotor",   # paper subject; the table itself prints groups only
  solver_type          = solver_type,
  n_group              = n_group,
  hemisphere_weight_mg_mean = hemi$mean * 1000,   # printed g -> mg
  hemisphere_weight_mg_sem  = hemi$sem  * 1000,   # printed g -> mg
  hemisphere_n              = n_eff(hemi$footnote),
  hemisphere_footnote_ref   = hemi$footnote,
  hippocampus_mg_mean       = hipp$mean,          # printed mg, kept
  hippocampus_mg_sem        = hipp$sem,
  hippocampus_n             = n_eff(hipp$footnote),
  somatosensory_cortex_mg_mean = ssc$mean * 1000, # printed g -> mg
  somatosensory_cortex_mg_sem  = ssc$sem  * 1000, # printed g -> mg
  somatosensory_cortex_n       = n_eff(ssc$footnote),
  somatosensory_cortex_footnote_ref = ssc$footnote,
  source = "Jacob_etal_2021 TABLE 1",
  stringsAsFactors = FALSE
)
stopifnot(nrow(final_df) == 3L, !anyNA(final_df$hemisphere_weight_mg_mean))

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
