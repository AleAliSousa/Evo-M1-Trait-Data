## Froudist-Walsh S, Xu T, Niu M, Rapan L, Zhao L, Margulies DS, Zilles K, Wang X-J, Palomero-Gallagher N (2023)
## Gradients of neurotransmitter receptor expression in the macaque cortex. Nat Neurosci 26:1281-1294.
## doi:10.1038/s41593-023-01351-2
## Supplementary Table 2 -- Standard deviation of receptor density per neuron (fmol/neuron) across the three brains:
## 14 receptors x 109 cortical areas of the Julich Brain Macaque Maps.
## Build: frozen snapshot -> long analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## The source is a PRINTED PDF table (supplementary_downloads/41593_2023_1351_MOESM1_ESM.pdf, pp. 17-20), so the
## frozen source is the snapshot <item_name>_snapshot.csv written by <item_name>_snapshot.py (pdfplumber; values from
## the PDF text layer).  This script only READS it.
## SINGLE-SPECIES (Macaca fascicularis; three adult males, 7.3 +/- 0.6 y, Methods "In vitro receptor autoradiography",
## p. 15 of the article PDF).  Data role = primary.  Values are receptor densities PER NEURON (fmol/neuron): the
## authors' autoradiographic densities (fmol/mg protein) divided by an area-wise neuron density derived from Collins
## et al. 2010 (neurons per gram, isotropic fractionator), using "8% of brain tissue is protein" (Methods, p. 15).
## Printed 'N/A' (areas V4dm, 13l, 13m: "receptor values were only available for one brain ... which prevented
## estimates of standard deviation", footnote p. 20) -> blank; kept verbatim in value_as_printed.

## 0. PATHS -- self-contained ------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  for (i in rev(seq_len(sys.nframe()))) {            # source() / sys.source() (build_dataset_item)
    fn <- as.character(sys.call(i)[[1]])[1]
    if (fn %in% c("source", "sys.source")) {
      f <- get0(if (fn == "source") "ofile" else "file", envir = sys.frame(i), inherits = FALSE)
      if (is.character(f) && length(f) == 1 && file.exists(f)) return(normalizePath(f))
    }
  }
  stop("Run with Rscript file.R, source(file.R), or open in RStudio and click Source (save first).", call. = FALSE)
})
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))          # FroudistWalsh_etal_2023_SupplementaryTable2
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv   <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)
# receptor_as_printed carries Greek alpha; in a non-UTF-8 session write.csv/write.table would emit "<U+03B1>",
# so switch the character locale to UTF-8 (no-op in RStudio / any UTF-8 session)
if (!isTRUE(l10n_info()[["UTF-8"]])) invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 2. READ FROZEN SNAPSHOT (printed layout: page, printed_order, area, 14 receptor columns as printed) -------------
snap <- utils::read.csv(snapshot_csv, header = TRUE, colClasses = "character", check.names = FALSE,
                        encoding = "UTF-8", na.strings = character(0))
stopifnot(nrow(snap) == 109, ncol(snap) == 3 + 14)

## 3. REFORMAT snapshot -> analysis data ------------------------------------
# Printed column labels (subscripts flattened by the snapshot script; Greek alpha kept) -> harmonised receptor
# names as used in Zilles_PalomeroGallagher_2017_SupplementaryTable2.csv.  5HT2A (ketanserin, Supplementary
# Table 4) is harmonised to the Zilles-2017 label '5-HT2'; the printed label is kept in receptor_as_printed.
printed_labels <- c("AMPA", "kainate", "NMDA", "GABAA", "GABAB", "GABAA/BZ", "M1", "M2", "M3",
                    "\u03b11", "\u03b12", "5HT1A", "5HT2A", "D1")
receptor_names <- c("AMPA", "kainate", "NMDA", "GABAA", "GABAB", "GABAA/BZ", "M1", "M2", "M3",
                    "alpha1", "alpha2", "5-HT1A", "5-HT2", "D1")
stopifnot(identical(names(snap)[1:3], c("page", "printed_order", "area")),
          identical(enc2utf8(names(snap)[-(1:3)]), enc2utf8(printed_labels)))

num <- function(x) suppressWarnings(as.numeric(ifelse(x %in% c("N/A", ""), NA, x)))

long <- do.call(rbind, lapply(seq_along(printed_labels), function(k) {
  v <- snap[[3 + k]]
  data.frame(
    Species                   = "Macaca fascicularis",
    Species_FroudistWalsh2023 = "Macaca fascicularis",   # not printed in the table; from Methods (p. 15)
    area                      = snap$area,
    receptor                  = receptor_names[k],
    receptor_as_printed       = printed_labels[k],
    value_fmol_per_neuron     = num(v),
    value_as_printed          = v,
    printed_order             = as.integer(snap$printed_order),
    page                      = as.integer(snap$page),
    stringsAsFactors = FALSE, check.names = FALSE)
}))
long <- long[order(long$printed_order, match(long$receptor_as_printed, printed_labels)), ]
rownames(long) <- NULL
final.dataframe <- long
stopifnot(nrow(final.dataframe) == 109 * 14,
          length(unique(final.dataframe$area)) == 109,
          identical(sort(unique(final.dataframe$area[is.na(final.dataframe$value_fmol_per_neuron)])), c("13l", "13m", "V4dm")),
          sum(final.dataframe$value_as_printed == "N/A") == 3 * 14)

## 4. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
options(scipen = 999)
utils::write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
filecodes    <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
utils::write.table(final.dataframe, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", quote = TRUE)
message("Wrote ", nrow(final.dataframe), " rows -> ", basename(final_csv), " and ", item_encoded, ".tsv")
