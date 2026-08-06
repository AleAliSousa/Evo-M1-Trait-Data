# Gabi et al. 2016 - SI Table S1: prefrontal share of cortical volume, white-matter cells
# and cortical neurons, in 8 primates including human
#
# PRINTED SOURCE -> the frozen copy is Gabi_etal_2016_TableS1_snapshot.xlsx (sheet "TableS1"),
# captured from pnas.201610178si.pdf p.2 by Gabi_etal_2016_TableS1_extract_snapshot.py.
# This script reads ONLY that snapshot.
#
# ---------------------------------------------------------------------------------------------
# WHAT THIS TABLE IS: FOUR PERCENTAGES, NOT COUNTS.
# ---------------------------------------------------------------------------------------------
# Every value is the prefrontal region's SHARE of a whole-cortex total. There are no absolute
# volumes or neuron numbers anywhere in this paper's tables - Fig. 6 plots them, but the SI
# tabulates only shares.
#
# __HOWTO_build_a_dataset_file.md sec 7 says percentages are normally NOT transcribed, because
# they are recomputed downstream from the absolute values. That rule does not apply here: the
# absolute prefrontal values are not published, so the share IS the datum. It is transcribed on
# that basis and flagged `Measure = pct.cortex` so nothing mistakes it for a count.
#
# To get an absolute prefrontal neuron number for a species, multiply pct_neurons/100 by that
# species' whole-cortex neuron count from the cellcount merge. That is a DERIVATION for the merge
# to make explicitly, with both sources named - it is deliberately not baked in here.
#
# ---------------------------------------------------------------------------------------------
# THE HUMAN ROW IS THE SAME HEMISPHERE AS Ribeiro_etal_2013.
# ---------------------------------------------------------------------------------------------
# Gabi's Methods state the human hemisphere was "previously analyzed by Ribeiro et al." - one
# 65-year-old female right hemisphere. Gabi 2016 and Ribeiro_etal_2013_Table1 are NOT two
# independent human samples. A _keys/specimen_crosswalk entry is needed before both are allowed
# to contribute a human value.
#
# Source: Gabi, M., Neves, K., Masseron, C., Ribeiro, P. F. M., Ventura-Antunes, L.,
#   Torres, L., Mota, B., Kaas, J. H., & Herculano-Houzel, S. (2016). No relative expansion of the
#   number of prefrontal neurons in primate and human evolution. PNAS 113(34):9617-9622.
#   DOI 10.1073/pnas.1610178113. Table S1 of the SI Appendix.

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
item_name <- "Gabi_etal_2016_TableS1"
snapshot_xlsx <- file.path(paper_dir, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
base <- dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(base)) file.path(base, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) -
# Table S1 prints abbreviated genus names with no space ("C.apella"). Those printed strings are
# the key's variant_name, so nothing is mapped inside this script (sec 5).
TOKEN <- "Gabi2016"
ref <- if (!is.na(base))
  read.csv(file.path(base, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
km <- list()
if (!is.na(base))
  for (kf in list.files(file.path(base, "_keys"), pattern = "species_key.csv",
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
  NA_character_        # unmapped -> NA, never a fabricated binomial
}

## 3. READ SNAPSHOT ------------------------------------------------
# Positional read: row 1 = caption, rows 2-3 = the two-tier header, rows 4-11 = data,
# row 12 = the footnote.
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TableS1", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- c("Species", "pct_V_GM", "pct_V_WM", "pct_O_WM", "pct_neurons")
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])
snap <- snap[nzchar(snap$Species) & nzchar(snap$pct_V_GM), , drop = FALSE]   # drop the footnote row

to_num <- function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("", "-", "NA", "n.a.")] <- NA
  suppressWarnings(as.numeric(x))
}

## 4. CLEAN --> ANALYSIS TABLE -------------------------------------
out <- data.frame(
  Species_Gabi2016 = snap$Species,     # printed abbreviated name, verbatim (invariant 3)
  species_sci      = vapply(snap$Species, resolve, character(1), USE.NAMES = FALSE),
  n                = 1L,               # one hemisphere per species
  region           = "prefrontal",     # cortex anterior to the corpus callosum (paper's definition)
  # All four are percentages of a WHOLE-CORTEX total - shares, not counts.
  PrefrontalCortex_pct.VGM     = to_num(snap$pct_V_GM),
  PrefrontalCortex_pct.VWM     = to_num(snap$pct_V_WM),
  PrefrontalCortex_pct.OWM     = to_num(snap$pct_O_WM),
  PrefrontalCortex_pct.neurons = to_num(snap$pct_neurons),
  method = "isotropic fractionator + A-P sectioning; prefrontal = anterior to the corpus callosum",
  stringsAsFactors = FALSE
)

## 5. CHECKS -------------------------------------------------------
# Every share must lie in (0, 100].
stopifnot(all(out$PrefrontalCortex_pct.VGM     > 0 & out$PrefrontalCortex_pct.VGM     <= 100),
          all(out$PrefrontalCortex_pct.VWM     > 0 & out$PrefrontalCortex_pct.VWM     <= 100),
          all(out$PrefrontalCortex_pct.OWM     > 0 & out$PrefrontalCortex_pct.OWM     <= 100),
          all(out$PrefrontalCortex_pct.neurons > 0 & out$PrefrontalCortex_pct.neurons <= 100))
# The paper's headline: prefrontal holds about 8% of cortical neurons, and the HUMAN value is not
# an outlier - that is the whole point of the paper. Print both on every run.
mn <- mean(out$PrefrontalCortex_pct.neurons)
hu <- out$PrefrontalCortex_pct.neurons[out$species_sci == "Homo sapiens"]
cat(sprintf("mean %% cortical neurons in prefrontal = %.2f (paper: ~8%%); human = %.1f, rank %d of %d\n",
            mn, hu, rank(-out$PrefrontalCortex_pct.neurons)[out$species_sci == "Homo sapiens"],
            nrow(out)))
if (anyNA(out$species_sci))
  warning("unresolved species: ",
          paste(out$Species_Gabi2016[is.na(out$species_sci)], collapse = ", "))

## 6. SAVE ---------------------------------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.na(base) && file.exists(readme_xlsx)) {
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
cat(sprintf("Gabi Table S1: %d species\n", nrow(out)))
