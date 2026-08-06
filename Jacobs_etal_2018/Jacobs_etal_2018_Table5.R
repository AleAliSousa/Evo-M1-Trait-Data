# Jacobs et al. 2018 - Table 5: Golgi somatodendritic morphology of three M1 neuron types
# (19 species / 7 orders, 617 traced neurons)
#
# PRINTED SOURCE -> the frozen copy is Jacobs_etal_2018_Table5_snapshot.xlsx (sheet "Table5"),
# captured by Jacobs_etal_2018_extract_snapshot.py. This script reads ONLY that snapshot.
#
# Output shape: ONE ROW PER SPECIES x NEURON TYPE (53 rows). The three types - Superficial
# (layer III pyramidal), Deep (layer V pyramidal) and Gigantopyramidal (Betz in primates) - are
# traced in the SAME cortex of the SAME animal; neuron_type must stay explicit and the types
# must never be collapsed into one per-species value.
#
# Units are as printed and are NOT converted: dendritic volume um3, lengths um, soma size um2,
# soma depth um, spine density spines/um. These are Golgi 2-D tracing measures and are NOT
# interchangeable with the unbiased stereology of Table 3 - method is flagged per row.
#
# Source: Jacobs, B., et al. (2018). J Comp Neurol 526(3):496-536. DOI 10.1002/cne.24349.

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
item_name <- "Jacobs_etal_2018_Table5"
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
# Table 5 prints COMMON NAMES ONLY. The Jacobs2018 key rows carry each printed common name to
# its binomial - from Table 3 of the same paper where the species appears there, otherwise the
# standard binomial for that common name. Nothing is mapped inside this script (sec 5).
TOKEN <- "Jacobs2018"
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

## 3. NUMBER PARSING -----------------------------------------------
# Same guarded parse as Table 3: thousands separators are stripped only when every comma group
# after the first is exactly three digits, so a mis-set comma becomes NA + a flag rather than a
# wrong number.
well_formed <- function(tok) {
  tok <- trimws(tok)
  if (!nzchar(tok)) return(FALSE)
  if (!grepl(",", tok, fixed = TRUE)) return(grepl("^[0-9]+(\\.[0-9]+)?$", tok))
  g <- strsplit(tok, ",", fixed = TRUE)[[1]]
  if (!grepl("^[0-9]{1,3}$", g[1])) return(FALSE)
  all(grepl("^[0-9]{3}(\\.[0-9]+)?$", g[-1]))
}
num1 <- function(tok) {
  tok <- trimws(tok)
  if (!well_formed(tok)) return(NA_real_)
  as.numeric(gsub(",", "", tok, fixed = TRUE))
}
# "13,411±1,527" -> c(13411, 1527). The two n = 1 rows print a bare value with no SD; that is
# correct (one cell cannot have a dispersion) and the SD stays NA, never 0.
split_mean_sd <- function(cell) {
  cell <- trimws(gsub("±", "|", as.character(cell)))
  p <- strsplit(cell, "|", fixed = TRUE)[[1]]
  c(num1(p[1]), if (length(p) > 1) num1(p[2]) else NA_real_)
}

## 4. READ SNAPSHOT ------------------------------------------------
# Positional read: row 1 = caption, row 2 = header, then a repeating pattern of
#   [taxonomic-group row: col1 filled, rest empty]
#   [species row:         col2 filled, rest empty]
#   [Superficial / Deep / Gigantopyramidal data rows]
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "Table5", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:2), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])

## 5. RESHAPE ------------------------------------------------------
# Printed footnote letters: a n, b Vol, c TDL, d MSL, e DSC, f DSN, g DSD, h SoSize, i SoDepth
MEAS <- c(dendritic_volume_M1        = 3,   # Vol   um3
          total_dendritic_length_M1  = 4,   # TDL   um
          mean_segment_length_M1     = 5,   # MSL   um
          dendritic_segment_count_M1 = 6,   # DSC   count per neuron
          dendritic_spine_number_M1  = 7,   # DSN   count per neuron
          dendritic_spine_density_M1 = 8,   # DSD   spines per um
          soma_size_M1               = 9,   # SoSize um2
          soma_depth_M1              = 10)  # SoDepth um
# Stated in the paper's text, not in the table: gigantopyramidal neurons were not
# distinguishable in these four species. A real biological zero, not a gap (see definitions).
GIGANTO_ABSENT <- c("Banded mongoose", "Flemish giant rabbit", "Rat", "Bennett’s wallaby")

out <- NULL; clade <- NA_character_; sp <- NA_character_
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)
  if (grepl("^[a-i] ", r[1])) next                                        # footnote row
  if (nzchar(r[1]) && !nzchar(r[2]) && !nzchar(r[3])) { clade <- r[1]; next }  # group row
  if (!nzchar(r[1]) && nzchar(r[2]) && !nzchar(r[3])) { sp <- r[2];   next }   # species row
  if (!nzchar(r[1]) || !nzchar(r[3])) next
  row <- data.frame(
    clade_printed = clade,
    Species       = sp,                    # printed common name (invariant 3)
    species_sci   = resolve(sp),
    neuron_type   = r[1],                  # Superficial / Deep / Gigantopyramidal
    n_cells       = num1(r[2]),
    stringsAsFactors = FALSE)
  flags <- character(0)
  for (nm in names(MEAS)) {
    ms <- split_mean_sd(r[MEAS[[nm]]])
    row[[nm]]              <- ms[1]
    row[[paste0(nm, "_sd")]] <- ms[2]
    if (nzchar(r[MEAS[[nm]]]) && is.na(ms[1]))
      flags <- c(flags, sprintf("%s printed '%s'", nm, r[MEAS[[nm]]]))
  }
  row$gigantopyramidal_absent <- sp %in% GIGANTO_ABSENT
  row$method      <- "Golgi 2-D somatodendritic tracing"
  row$parse_flags <- if (length(flags)) paste(flags, collapse = "; ") else NA_character_
  out <- rbind(out, row)
}
rownames(out) <- NULL

## 5b. Print oddity carried, not corrected -------------------------
# Ring-tailed lemur Gigantopyramidal MSL is printed "69 ± 0.04"; every other MSL SD is an
# integer 1-14, so it is very likely "69 ± 4". Left exactly as printed and flagged here.
odd <- which(out$Species == "Ring-tailed lemur" & out$neuron_type == "Gigantopyramidal")
if (length(odd))
  out$parse_flags[odd] <- paste(na.omit(c(out$parse_flags[odd],
    "MSL printed '69±0.04' - every other MSL SD is an integer 1-14; suspected print error, carried as printed")),
    collapse = "; ")

## 6. SAVE ---------------------------------------------------------
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
# The paper states 617 traced neurons = 233 superficial + 203 deep + 181 gigantopyramidal.
cat(sprintf("Jacobs Table 5: %d rows, %d species, %d cells (%s)\n",
            nrow(out), length(unique(out$Species)), sum(out$n_cells, na.rm = TRUE),
            paste(sprintf("%s=%d", c("Superficial", "Deep", "Gigantopyramidal"),
                          vapply(c("Superficial", "Deep", "Gigantopyramidal"),
                                 function(t) sum(out$n_cells[out$neuron_type == t], na.rm = TRUE),
                                 numeric(1))), collapse = ", ")))
