## Zilles K & Palomero-Gallagher N (2017) Front. Neuroanat. 11:78. doi:10.3389/fnana.2017.00078
## Supplementary Table 2 — Receptor densities (fmol/mg protein; mean, SD, CV) of 15 receptors in the
## supragranular, granular and infragranular strata and averaged over all layers, 44 human cortical areas.
## Build: frozen snapshot -> long analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## The source is a PRINTED PDF table (supplementary_downloads/Table_2.pdf), so the frozen source is the
## snapshot <item_name>_snapshot.csv written by <item_name>_snapshot.py (pdfplumber; values from the
## PDF text layer, row highlighting from the page fill rectangles).  This script only READS it.
## SINGLE-SPECIES (Homo sapiens; 3 post-mortem brains, Materials and Methods of the paper). Data role =
## primary.  Flags: is_primary_sensory = row highlighted yellow in the PDF (areas 3b, V1, 41);
## is_M1 = row highlighted grey (area 4) — both read from the snapshot `highlight` column, as the
## caption describes ("Primary sensory areas are highlighted in yellow, the primary motor cortex in grey").

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
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Zilles_PalomeroGallagher_2017_SupplementaryTable2
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

## 2. READ FROZEN SNAPSHOT (positional; duplicate "(SD)"/"CV" headers as printed) ----------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, skip = 1, colClasses = "character",
                 check.names = FALSE, encoding = "UTF-8", na.strings = character(0))
names(snap) <- c("page", "receptor_block", "receptor_as_printed", "Region",
                 "supra_mean", "supra_sd", "supra_cv",
                 "gran_mean",  "gran_sd",  "gran_cv",
                 "infra_mean", "infra_sd", "infra_cv",
                 "all_mean",   "all_sd",   "all_cv",
                 "highlight")
stopifnot(nrow(snap) == 15 * 44)

## 3. REFORMAT snapshot -> analysis data ------------------------------------
# Receptor labels are printed with subscript/small-capital glyphs that the text layer renders
# inconsistently ("kaina te", "GABA ᴀ", "α₄β ₂" ...). Map them, in printed block order, to plain names.
receptor_names <- c("AMPA", "NMDA", "kainate", "GABAA", "GABAA/BZ", "GABAB", "M1", "M2", "M3",
                    "alpha4beta2", "alpha1", "alpha2", "5-HT1A", "5-HT2", "D1")
blk <- as.integer(snap$receptor_block)
stopifnot(identical(sort(unique(blk)), 1:15), all(table(blk) == 44))
# guard: the printed label of each block must equal the expected name once the subscript / small-capital
# glyphs are mapped to plain characters (done on Unicode code points so it works in any locale)
deglyph <- function(x) {
  from <- c(0x1D00, 0x1D03, 0x2081, 0x2082, 0x2083, 0x2084, 0x03B1, 0x03B2)  # ᴀ ᴃ ₁ ₂ ₃ ₄ α β
  to   <- utf8ToInt("AB1234ab")
  vapply(x, function(s) {
    cp <- utf8ToInt(enc2utf8(s)); m <- match(cp, from); cp[!is.na(m)] <- to[m[!is.na(m)]]
    gsub("[^A-Za-z0-9/-]", "", intToUtf8(cp))
  }, character(1), USE.NAMES = FALSE)
}
printed_key <- tolower(deglyph(snap$receptor_as_printed))
expect_key  <- tolower(c("AMPA","NMDA","kainate","GABAA","GABAA/BZ","GABAB","M1","M2","M3",
                         "a4b2","a1","a2","5-HT1A","5-HT2","D1"))
stopifnot(all(printed_key == expect_key[blk]))

num <- function(x) suppressWarnings(as.numeric(gsub("[()]", "", ifelse(x %in% c("--", ""), NA, x))))

strata <- list(
  supragranular = c("supra_mean", "supra_sd", "supra_cv"),
  granular      = c("gran_mean",  "gran_sd",  "gran_cv"),
  infragranular = c("infra_mean", "infra_sd", "infra_cv"),
  all_layers    = c("all_mean",   "all_sd",   "all_cv")
)
long <- do.call(rbind, lapply(names(strata), function(s) {
  cc <- strata[[s]]
  data.frame(
    Species                  = "Homo sapiens",
    Species_Zilles2017       = "Homo sapiens",   # not printed in the table; from title/methods
    area                     = snap$Region,
    receptor                 = receptor_names[blk],
    receptor_as_printed      = snap$receptor_as_printed,
    stratum                  = s,
    density_fmol_mg_protein  = num(snap[[cc[1]]]),
    sd                       = num(snap[[cc[2]]]),
    cv                       = num(snap[[cc[3]]]),
    is_primary_sensory       = as.integer(snap$highlight == "yellow"),
    is_M1                    = as.integer(snap$highlight == "grey"),
    highlight_as_printed     = snap$highlight,
    printed_order            = seq_len(nrow(snap)),
    page                     = as.integer(snap$page),
    stringsAsFactors = FALSE, check.names = FALSE)
}))
long$stratum <- factor(long$stratum, levels = names(strata))
long <- long[order(long$printed_order, long$stratum), ]
long$stratum <- as.character(long$stratum)
rownames(long) <- NULL
final.dataframe <- long
stopifnot(nrow(final.dataframe) == 15 * 44 * 4,
          sum(final.dataframe$is_primary_sensory) == 3 * 15 * 4,
          sum(final.dataframe$is_M1) == 1 * 15 * 4)

## 3a. TABLE CHECK (HOWTO section 7a): is the printed CV the printed SD / printed mean? ------------
# The caption prints "standard deviation (SD) and variation coefficients (VC)" side by side, so the
# implied relation CV = SD/mean is checked to the last printed decimal (3 d.p.; tolerance 0.001 plus
# what rounding of the printed integer mean and SD can explain). Mismatches are reported, never changed.
ok <- !is.na(final.dataframe$density_fmol_mg_protein) & !is.na(final.dataframe$sd) & !is.na(final.dataframe$cv)
obs <- round(final.dataframe$sd / final.dataframe$density_fmol_mg_protein, 3)
tol <- pmax(0.001, (final.dataframe$sd + 0.5) / pmax(final.dataframe$density_fmol_mg_protein - 0.5, 1) -
                    (final.dataframe$sd - 0.5) / (final.dataframe$density_fmol_mg_protein + 0.5))
table_checks <- data.frame(
  check_id   = paste0("cv_", final.dataframe$receptor, "_", final.dataframe$area, "_", final.dataframe$stratum),
  basis      = "printed CV vs printed SD / printed mean (same row, same stratum)",
  observed   = obs,
  printed    = final.dataframe$cv,
  difference = obs - final.dataframe$cv,
  tolerance  = round(tol, 3),
  status     = ifelse(!ok, "not_evaluable", ifelse(abs(obs - final.dataframe$cv) <= tol, "pass", "mismatch")),
  note       = ifelse(!ok, "stratum absent in print (--)", ""),
  stringsAsFactors = FALSE)
if (any(table_checks$status == "mismatch"))
  warning(sum(table_checks$status == "mismatch"), " of ", sum(ok),
          " printed CV values are not SD/mean of the printed row (kept as printed; see README 'Table checks').")

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
