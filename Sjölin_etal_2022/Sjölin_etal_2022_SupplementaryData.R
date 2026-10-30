## Sjölin_etal_2022_SupplementaryData.R -- frozen source -> analysis CSV + public TSV
##
## Sjölin, K., Kultima, K., Larsson, A., Freyhult, E., Zjukovskaja, C., Alkass, K., &
## Burman, J. (2022). Distribution of five clinically important neuroglial proteins in
## the human brain. Molecular Brain, 15(1), 52. doi:10.1186/s13041-022-00935-6
##
## ADDITIONAL FILE 2 (journal-supplied .xlsx, "Supplementary Data" in the registry):
## one row per tissue sample -- 10 post-mortem donors x 17 CNS regions, 168 samples
## (hippocampus missing for 2 donors) -- with GFAP, MBP, NFL, tau, UCHL1 and total
## protein measured by ELISA/BCA in the supernatant of the tissue homogenate, plus
## donor age, sex, warm/cold post-mortem interval and cause of death.
##
## Frozen source: Sjölin_etal_2022_SupplementaryData_snapshot.xlsx is a byte-identical
## copy of the download 13041_2022_935_MOESM2_ESM.xlsx (digital-native source, no
## transcription: HOWTO "Digital-native sources skip the transcription, never the
## suffix"). Reader: AI assistant, 2026-10-28; no cell values are typed in this script.
##
## UNIT CONVERSION (the one substantive transformation). The published columns are
## concentrations in the homogenate supernatant (ng/mL; total protein µg/mL). The
## extraction protocol (Additional file 1, "Protein extraction protocol") adds lysing
## buffer "at a ratio of 1 ml/100 mg brain sample", i.e. 10 mL homogenate per g of
## wet CNS tissue, so tissue-referenced concentration = supernatant concentration x 10
## mL/g: ng/mL x 10 / 1000 = µg/g, and µg/mL x 10 / 1000 = mg/g. Those are the units
## the paper reports in its Table 2, and both published and derived columns are kept.
## 0. PATHS --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {                       # source() ("ofile") / sys.source() ("file")
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
## macOS stores this folder's name decomposed (Sjo + combining diaeresis) while the
## registry, the species key and the repo's text files spell it composed (ö). Compare
## and look up in composed form so neither the key filter nor the Item-name match
## depends on which normalisation the file system handed back.
nfc <- function(x) stringi::stri_trans_nfc(enc2utf8(x))
item_name <- nfc(tools::file_path_sans_ext(basename(.sp)))  # "Sjölin_etal_2022_SupplementaryData"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_xlsx <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir       <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
## Package calls are namespace-qualified so the script also runs under
## _tools/dataset_builder/build_dataset_item(), which sys.source()s it into an
## environment whose parent is baseenv() (the attached search path is not visible there).
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 2. LOAD (frozen source, read as text) ----------------------------
snap <- readxl::read_excel(snapshot_xlsx, sheet = 1, col_types = "text", .name_repair = "minimal")
snap <- as.data.frame(snap, stringsAsFactors = FALSE, check.names = FALSE)

published_header <- c("CNS region", "Donor", "Age", "Gender", "Warm time (hours)",
                      "Cold time (hours)", "Total post mortal interval (hours)",
                      "Cause of death", "GFAP (ng/ml)", "MBP (ng/ml)", "NFL (ng/ml)",
                      "TAU (ng/ml)", "UCHL1 (ng/ml)", "Total Protein (\u00b5g/ml)")
if (!identical(names(snap), published_header))
  stop("frozen source header changed -- expected the 14 published columns, got: ",
       paste(names(snap), collapse = " | "), call. = FALSE)

## 2b. SPECIES KEY (collection-scoped: _keys/General; source_publication = folder name)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[nfc(key$source_publication) == nfc(basename(folder)), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", nfc(basename(folder)), call. = FALSE)
lk <- stats::setNames(key$accepted_name, key$variant_name)
harmonise <- function(x) {
  out <- unname(lk[x]); miss <- !is.na(x) & nzchar(x) & is.na(out)
  if (any(miss)) stop("Printed name(s) missing from species_key: ",
                      paste(unique(x[miss]), collapse = "; "), call. = FALSE)
  out
}
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))

## 3. CLEAN -----------------------------------------------------------
## The printed "CNS region" cell is a one-letter sampling code plus the region name
## ("A Frontal lobe cortex"); both are kept, the code because Fig. 1 and Additional
## file 1 label the sampling sites by it. The species is not printed in the table --
## it comes from the title/methods (HOWTO sec. 5, single-species papers).
to_g <- 0.01            # supernatant per mL -> per g wet tissue (10 mL/g, /1000)

final.dataframe <- tibble::tibble(
  species_as_published   = "Homo sapiens",
  Species                = harmonise(species_as_published),
  donor                  = num(snap[["Donor"]]),
  age_years              = num(snap[["Age"]]),
  sex_as_published       = trimws(snap[["Gender"]]),
  region_code            = sub("^([A-Z]) .*$", "\\1", trimws(snap[["CNS region"]])),
  region_as_published    = sub("^[A-Z] ", "", trimws(snap[["CNS region"]])),
  warm_time_h            = num(snap[["Warm time (hours)"]]),
  cold_time_h            = num(snap[["Cold time (hours)"]]),
  post_mortem_interval_h = num(snap[["Total post mortal interval (hours)"]]),
  cause_of_death         = trimws(snap[["Cause of death"]]),
  GFAP_ng_per_ml         = num(snap[["GFAP (ng/ml)"]]),
  MBP_ng_per_ml          = num(snap[["MBP (ng/ml)"]]),
  NFL_ng_per_ml          = num(snap[["NFL (ng/ml)"]]),
  TAU_ng_per_ml          = num(snap[["TAU (ng/ml)"]]),
  UCHL1_ng_per_ml        = num(snap[["UCHL1 (ng/ml)"]]),
  total_protein_ug_per_ml = num(snap[["Total Protein (\u00b5g/ml)"]]),
  GFAP_ug_per_g          = GFAP_ng_per_ml  * to_g,
  MBP_ug_per_g           = MBP_ng_per_ml   * to_g,
  NFL_ug_per_g           = NFL_ng_per_ml   * to_g,
  TAU_ug_per_g           = TAU_ng_per_ml   * to_g,
  UCHL1_ug_per_g         = UCHL1_ng_per_ml * to_g,
  total_protein_mg_per_g = total_protein_ug_per_ml * to_g,
  n_specimens            = 1L,
  observation_level      = "sample (one donor x one CNS region)",
  data_role              = "primary")

## Parse fidelity: the frozen source leaves two analyte cells blank (donor 8 cervical
## spinal cord GFAP; donor 9 frontal white matter total protein). A blank is missing,
## never zero -- so the number of NAs after parsing must equal the number of blank
## cells in the source, column by column, or a value failed to parse silently.
meas_cols <- published_header[9:14]
src_blank <- vapply(meas_cols, function(cn)
  sum(is.na(snap[[cn]]) | !nzchar(trimws(tidyr::replace_na(snap[[cn]], "")))), integer(1))
parsed_na <- vapply(c("GFAP_ng_per_ml", "MBP_ng_per_ml", "NFL_ng_per_ml", "TAU_ng_per_ml",
                      "UCHL1_ng_per_ml", "total_protein_ug_per_ml"),
                    function(cn) sum(is.na(final.dataframe[[cn]])), integer(1))
stopifnot(nrow(final.dataframe) == 168L,
          dplyr::n_distinct(final.dataframe$region_code) == 17L,
          dplyr::n_distinct(final.dataframe$donor) == 10L,
          all(nchar(final.dataframe$region_code) == 1L),
          identical(unname(src_blank), unname(parsed_na)),
          sum(src_blank) == 2L)

## 3b. TABLE CHECKS (HOWTO sec. 7a): none. The frozen source prints no totals,
## percentages or other internal relation to check itself against. The external
## agreement with the paper's Table 2 is recorded in the README, not here -- Table 2
## is a separate published table and its values are not hardcoded in this script.

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, final_csv, na = "")                       # readr: always UTF-8
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, nfc(filecodes$`Item name`))]

  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
