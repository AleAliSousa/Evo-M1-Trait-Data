# Jacobs et al. 2018 - Table 3: layer V pyramidal and gigantopyramidal soma size in M1
# (unbiased stereology, 20 species: 11 carnivores + 9 primates, one animal per species)
#
# PRINTED SOURCE -> the frozen copy is Jacobs_etal_2018_Table3_snapshot.xlsx (sheet "Table3"),
# captured by Jacobs_etal_2018_extract_snapshot.py. This script reads ONLY that snapshot.
#
# Output shape: ONE ROW PER SPECIES x NEURON CLASS (20 x 2 = 40). The printed table is wide -
# six measure blocks (pyramidal / gigantopyramidal x length / area / volume), each with its own
# n, "Mean±SD" and "Range". neuron_class must stay explicit: a gigantopyramidal (Betz) cell and
# an ordinary layer V pyramid are measured in the SAME animal and must never be collapsed.
#
# Units: soma length um, area um2, volume um3 - these are NOT the mm3 structure-volume lineage,
# so they are NOT converted. Body mass kg -> g (x1000) and brain mass g -> mg (x1000) ARE
# converted to project units (sec 6).
#
# Source: Jacobs, B., Garcia, M. E., Shea-Shumsky, N. B., ... Manger, P. R. (2018). Comparative
#   morphology of gigantopyramidal neurons in primary motor cortex across mammals.
#   J Comp Neurol 526(3):496-536. DOI 10.1002/cne.24349. PMID 29088505.

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
item_name <- "Jacobs_etal_2018_Table3"
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
# Table 3 prints thousands separators ("1,416.2"). Stripping them is the house default (sec 6),
# BUT this table also contains printer's errors where a comma stands where a decimal point
# belongs - e.g. "55,734,1", "40,16.1", "14,71.9". Blind stripping would turn 55,734.1 into
# 557341. So: a token is accepted only if every comma group after the first is exactly three
# digits. Anything else parses to NA and is named in parse_flags - never silently "corrected"
# (sec 7: record provenance problems, don't fix the snapshot).
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
# "8.9±1.5" -> c(mean, sd);  "1,416.2±644.4" -> c(1416.2, 644.4)
split_mean_sd <- function(cell) {
  cell <- trimws(gsub("±", "|", as.character(cell)))
  p <- strsplit(cell, "|", fixed = TRUE)[[1]]
  c(num1(p[1]), if (length(p) > 1) num1(p[2]) else NA_real_)
}
# "5.7-14.8" (en dash in the print) -> c(min, max)
split_range <- function(cell) {
  cell <- trimws(gsub("–", "-", as.character(cell)))
  p <- strsplit(cell, "-", fixed = TRUE)[[1]]
  c(num1(p[1]), if (length(p) > 1) num1(p[2]) else NA_real_)
}

## 4. READ SNAPSHOT ------------------------------------------------
# Positional read (sec 3): row 1 = caption, rows 2-3 = the two-tier header, row 4 onward = data,
# with "Carnivores"/"Primates" grade rows and a trailing footnote row.
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "Table3", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])

## 5. RESHAPE ------------------------------------------------------
# Column layout, from the printed two-tier header:
#   V1 Species (common)  V2 Species_binomial  V3 body mass kg  V4 brain mass g
#   V5-7   pyramidal length  n / Mean+-SD / Range     V8-10  gigantopyramidal length
#   V11-13 pyramidal area    n / Mean+-SD / Range     V14-16 gigantopyramidal area
#   V17-19 pyramidal volume  n / Mean+-SD / Range     V20-22 gigantopyramidal volume
BLOCK <- list(
  pyramidal        = list(length = 5,  area = 11, volume = 17),
  gigantopyramidal = list(length = 8,  area = 14, volume = 20)
)
out <- NULL; clade <- NA_character_
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)
  if (grepl("^a ", r[1])) next                                   # footnote row
  if (nzchar(r[1]) && !nzchar(r[2]) && !nzchar(r[3])) { clade <- r[1]; next }  # grade row
  if (!nzchar(r[1]) || !nzchar(r[3])) next                       # blank/spacer
  for (ncl in names(BLOCK)) {
    row <- data.frame(
      Species          = r[1],                 # printed common name (invariant 3)
      Species_binomial = r[2],                 # printed binomial   (invariant 3)
      species_sci      = resolve(r[2]),
      clade_printed    = clade,
      neuron_class     = ncl,
      body_mass_g      = num1(r[3]) * 1000,    # printed kg -> project g
      brain_mass_mg    = num1(r[4]) * 1000,    # printed g  -> project mg
      stringsAsFactors = FALSE)
    flags <- character(0)
    for (m in c("length", "area", "volume")) {
      k  <- BLOCK[[ncl]][[m]]
      ms <- split_mean_sd(r[k + 1]); rg <- split_range(r[k + 2])
      row[[paste0("n_", m)]]                    <- num1(r[k])
      row[[paste0("soma_", m, "_M1")]]          <- ms[1]
      row[[paste0("soma_", m, "_M1_sd")]]       <- ms[2]
      row[[paste0("soma_", m, "_M1_min")]]      <- rg[1]
      row[[paste0("soma_", m, "_M1_max")]]      <- rg[2]
      # provenance checks - printed cells that cannot be trusted as numbers
      if (nzchar(r[k + 1]) && (is.na(ms[1]) || is.na(ms[2])))
        flags <- c(flags, sprintf("%s mean+-sd printed '%s'", m, r[k + 1]))
      if (nzchar(r[k + 2]) && (is.na(rg[1]) || is.na(rg[2])))
        flags <- c(flags, sprintf("%s range printed '%s'", m, r[k + 2]))
      if (!is.na(ms[1]) && !is.na(rg[1]) && !is.na(rg[2]) &&
          (ms[1] < rg[1] || ms[1] > rg[2]))
        flags <- c(flags, sprintf("%s mean outside printed range", m))
    }
    row$method      <- "unbiased stereology (nucleator probe, StereoInvestigator)"
    row$parse_flags <- if (length(flags)) paste(flags, collapse = "; ") else NA_character_
    out <- rbind(out, row)
  }
}
out <- out[order(out$clade_printed != "Carnivores", out$Species, out$neuron_class), ]
rownames(out) <- NULL

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
cat(sprintf("Jacobs Table 3: %d rows (%d species x 2 neuron classes), %d rows flagged\n",
            nrow(out), length(unique(out$Species)), sum(!is.na(out$parse_flags))))
