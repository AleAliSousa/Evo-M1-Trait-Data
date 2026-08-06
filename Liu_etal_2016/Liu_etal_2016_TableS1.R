# Liu, Xiong & Hu 2016 - SI Table S1: hand proportions and modelled manipulative potential
# (137 hand specimens, 13 anthropoid species)
#
# PRINTED SOURCE -> the frozen copy is Liu_etal_2016_TableS1_snapshot.xlsx (sheet "TableS1"),
# captured from rspb20161923_si_001.pdf pp. 7-10 by Liu_etal_2016_TableS1_extract_snapshot.py.
# This script reads ONLY that snapshot.
#
# Granularity: ONE ROW PER SPECIMEN, keyed by museum accession (sec 3). Table S2 of the paper
# works from species means, but aggregating here would throw away the accession provenance, so
# the specimen rows are kept and any averaging happens at the merge.
#
# Units: every segment column is a PROPORTION of the combined thumb + forefinger length, and WS
# and GMI are dimensionless model outputs - there is no unit conversion to do (invariant 4 does
# not bite).
#
# DATA ROLE = SECONDARY. Liu et al. did not measure these hands: the SI states the raw
# morphometrics "are taken from the literature [1]" = Feix, Kivell, Pouydebat & Dollar (2015),
# J R Soc Interface. Baker_etal_2025's peak_workspace descends from the SAME Feix data, so
# Liu's WS/GMI and Baker's peak_workspace are citation-dependent -> resolve, never average.
#
# Source: Liu, M.-J., Xiong, C.-H., & Hu, D. (2016). Assessing the manipulative potentials of
#   monkeys, apes and humans from hand proportions: implications for hand evolution.
#   Proc R Soc B 283(1843):20161923. DOI 10.1098/rspb.2016.1923. PMID 27903877.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- "Liu_etal_2016_TableS1"
snapshot_xlsx <- file.path(paper_dir, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) -
TOKEN <- "Liu2016"
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
km <- list()
if (!is.na(dataset_root))
  for (kf in list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
                        recursive = TRUE, full.names = TRUE)) {
    k <- read.csv(kf, stringsAsFactors = FALSE)
    if (!all(c("variant_name", "accepted_name", "source_publication") %in% names(k))) next
    k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
    for (i in seq_len(nrow(k))) {
      v <- tolower(trimws(k$variant_name[i]))
      if (nzchar(v) && is.null(km[[v]])) km[[v]] <- k$accepted_name[i]
    }
  }
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  cx
}

## 3. READ SNAPSHOT ------------------------------------------------
# Positional read: row 1 = caption, row 2 = header, rows 3+ = one specimen each.
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TableS1", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:2), , drop = FALSE]
names(snap) <- c("Species", "Key", "MC1", "PP1", "DP1", "MC2", "PP2", "IP2", "DP2", "WS", "GMI")

to_num <- function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("", "-", "NA", "n.a.")] <- NA
  suppressWarnings(as.numeric(x))
}

## 4. CLEAN --> ANALYSIS TABLE -------------------------------------
out <- data.frame(
  Species_Liu2016 = trimws(snap$Species),   # printed binomial (invariant 3)
  species_sci     = vapply(trimws(snap$Species), resolve, character(1), USE.NAMES = FALSE),
  specimen_key    = trimws(snap$Key),       # museum accession - the specimen's provenance
  museum          = sub(" .*$", "", trimws(snap$Key)),
  # thumb segments, as a proportion of combined thumb + forefinger length
  MC1 = to_num(snap$MC1), PP1 = to_num(snap$PP1), DP1 = to_num(snap$DP1),
  # forefinger segments, same denominator
  MC2 = to_num(snap$MC2), PP2 = to_num(snap$PP2),
  IP2 = to_num(snap$IP2), DP2 = to_num(snap$DP2),
  WS  = to_num(snap$WS),                    # workspace (dimensionless)
  GMI = to_num(snap$GMI),                   # global manipulation index (headline measure)
  stringsAsFactors = FALSE
)
# Derived check, not a stored trait: the seven segment proportions should sum to ~1 by
# construction (they are shares of the combined thumb + forefinger length).
seg_sum <- rowSums(out[, c("MC1", "PP1", "DP1", "MC2", "PP2", "IP2", "DP2")])
out$segment_sum_check <- round(seg_sum, 4)

## 5. SAVE ---------------------------------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' in __ReadMe.xlsx for Item name: ", item_name)
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  }
}
# The paper states "a total of 137 hand samples from 13 anthropoid species".
cat(sprintf("Liu Table S1: %d specimens, %d species; segment sums %.3f-%.3f\n",
            nrow(out), length(unique(out$Species_Liu2016)),
            min(seg_sum, na.rm = TRUE), max(seg_sum, na.rm = TRUE)))
