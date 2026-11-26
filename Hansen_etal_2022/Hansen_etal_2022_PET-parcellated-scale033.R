## Hansen JY, Shafiei G, Markello RD, et al. (2022) Nat Neurosci 25:1569-1581, doi 10.1038/s41593-022-01186-3
## Item: PET-parcellated-scale033 -- 41 group-average PET receptor/transporter maps parcellated to the
## Lausanne scale033 atlas (68 Desikan-Killiany cortical + 15 subcortical regions, per hemisphere).
## Build: frozen snapshot -> long analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## The frozen source is the CONSTRUCTED snapshot Hansen_etal_2022_PET-parcellated-scale033_snapshot.csv
## (region x tracer-file; written by the separate _snapshot.R from the authors' parcellated CSVs,
## values verbatim). This script only READS it. It reshapes to one row per region x tracer file,
## parses the authors' filename convention <receptor>_<tracer>_hc<n>_<source>[_suffix], attaches the
## measure/unit per map from reference_tables/<item>_tracer_units.csv (constructed from the paper's
## Table 1 + Methods) and the Desikan-Killiany spelling used by Johansen_etal_2024_Table2 from
## reference_tables/<item>_dk_region_key.csv. No unit conversion: BPND / SUVR are unitless ratios,
## VT is mL/cm3, Bmax is pmol/mL -- each kept as published (distinct measure classes).
## SINGLE-SPECIES (Homo sapiens, healthy adults). Observation level = group-average map per region
## and hemisphere; same-receptor maps are NOT averaged here (Hansen's make_receptor_matrix.py
## z-scores and n-weights them -- deferred to the consumer).

## 0. PATHS -- self-contained ------------------------------------------------
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
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Hansen_etal_2022_PET-parcellated-scale033
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv   <- file.path(folder, paste0(item_name, "_snapshot.csv"))
tracer_key_csv <- file.path(folder, "reference_tables", paste0(item_name, "_tracer_units.csv"))
dk_key_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_dk_region_key.csv"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. READ FROZEN SNAPSHOT + item-scoped keys --------------------------------
snap <- utils::read.csv(snapshot_csv, colClasses = "character", check.names = FALSE, encoding = "UTF-8")
meta_cols   <- c("row_index", "id", "label", "hemisphere", "structure", "yeo_7", "von_economo")
tracer_cols <- setdiff(names(snap), meta_cols)
if (nrow(snap) != 83L || length(tracer_cols) != 41L)
  stop("Snapshot shape unexpected: ", nrow(snap), " rows x ", length(tracer_cols), " tracer columns", call. = FALSE)

tracer_key <- utils::read.csv(tracer_key_csv, stringsAsFactors = FALSE, encoding = "UTF-8")
dk_key     <- utils::read.csv(dk_key_csv,     stringsAsFactors = FALSE, encoding = "UTF-8")
if (!setequal(tracer_key$tracer_file, tracer_cols))
  stop("tracer_units key does not cover exactly the snapshot's tracer columns", call. = FALSE)
if (!all(unique(snap$label) %in% dk_key$label))
  stop("dk_region_key is missing labels: ", paste(setdiff(unique(snap$label), dk_key$label), collapse = ", "), call. = FALSE)

## 3. RESHAPE wide -> long, parse filenames ---------------------------------
long <- do.call(rbind, lapply(tracer_cols, function(tc) data.frame(
  region_id   = as.integer(snap$id),
  region_label = snap$label,
  hemisphere  = snap$hemisphere,
  structure   = snap$structure,
  yeo_7       = snap$yeo_7,
  von_economo = snap$von_economo,
  tracer_file = tc,
  value       = as.numeric(snap[[tc]]),          # full-precision text -> double; no rounding
  stringsAsFactors = FALSE)))
if (anyNA(long$value)) stop("Non-numeric value token in snapshot", call. = FALSE)

# Authors' filename convention: <receptor>_<tracer>_hc<n>_<source>[_suffix]. Three JuSpace-named
# files (GABAa_FLUMAZENIL_c11, SERT_DASB_HC30, SERT_MADAM_c11) carry no source token; 'c11' is the
# radionuclide (carbon-11), not an n. 'hc'/'HC' is matched case-insensitively.
tok <- strsplit(long$tracer_file, "_", fixed = TRUE)
long$receptor_or_transporter <- vapply(tok, `[`, "", 1L)
long$tracer                  <- vapply(tok, `[`, "", 2L)
hc_tok <- regmatches(long$tracer_file, regexpr("(?i)(^|_)hc[0-9]+", long$tracer_file, perl = TRUE))
long$n_subjects <- NA_integer_
has_hc <- grepl("(?i)(^|_)hc[0-9]+", long$tracer_file, perl = TRUE)
long$n_subjects[has_hc] <- as.integer(sub("(?i)^_?hc", "", hc_tok, perl = TRUE))
long$source_study <- vapply(tok, function(t) {
  i <- grep("^hc[0-9]+$", t)
  if (length(i) == 1L && length(t) > i) t[i + 1L] else NA_character_
}, "")
long$filename_suffix <- vapply(tok, function(t) {
  i <- grep("^hc[0-9]+$", t)
  if (length(i) == 1L && length(t) > i + 1L) paste(t[(i + 2L):length(t)], collapse = "_") else NA_character_
}, "")                                          # 'spect' (DAT FP-CIT is SPECT, not PET) and 'sum' (two VAChT maps)

# Harmonise the receptor token to Hansen's receptor_names_pet vocabulary (data/receptor_names_pet.npy):
# MU -> MOR, NAT -> NET, SERT -> 5HTT, GABAa-bz -> GABAa. The printed token stays in receptor_or_transporter.
harm <- c(MU = "MOR", NAT = "NET", SERT = "5HTT", `GABAa-bz` = "GABAa")
long$receptor_harmonised <- ifelse(long$receptor_or_transporter %in% names(harm),
                                   harm[long$receptor_or_transporter], long$receptor_or_transporter)

## 4. JOIN units (Table 1 / Methods) and the Johansen DK spelling -----------
ki <- match(long$tracer_file, tracer_key$tracer_file)
long$value_unit             <- tracer_key$value_unit[ki]
long$unit_source            <- tracer_key$unit_source[ki]
long$in_hansen_main_matrix  <- as.integer(tracer_key$in_hansen_main_matrix[ki])
long$table1_measure         <- tracer_key$table1_measure[ki]
long$dk_region_johansen     <- dk_key$dk_region_johansen[match(long$region_label, dk_key$label)]
long$dk_region_johansen[!nzchar(long$dk_region_johansen)] <- NA_character_
long$is_M1 <- as.integer(long$region_label == "precentral")

## 5. ASSEMBLE ---------------------------------------------------------------
out <- data.frame(
  Species             = "Homo sapiens",
  Species_Hansen2022  = "Homo sapiens",            # species not printed per row; from title/Methods ("healthy participants")
  region_id           = long$region_id,
  region_label        = long$region_label,
  dk_region_johansen  = long$dk_region_johansen,
  hemisphere          = long$hemisphere,
  structure           = long$structure,
  yeo_7               = long$yeo_7,
  von_economo         = long$von_economo,
  is_M1               = long$is_M1,
  tracer_file         = long$tracer_file,
  receptor_or_transporter = long$receptor_or_transporter,
  receptor_harmonised = long$receptor_harmonised,
  tracer              = long$tracer,
  n_subjects          = long$n_subjects,
  source_study        = long$source_study,
  filename_suffix     = long$filename_suffix,
  in_hansen_main_matrix = long$in_hansen_main_matrix,
  value               = long$value,
  value_unit          = long$value_unit,
  unit_source         = long$unit_source,
  stringsAsFactors = FALSE, check.names = FALSE
)
if (nrow(out) != 83L * 41L) stop("Expected 3403 rows, got ", nrow(out), call. = FALSE)
message("DK join: ", sum(!is.na(out$dk_region_johansen)) / 41L, " of 83 regions carry a Johansen Table 2 spelling; ",
        "units: ", paste(names(table(tracer_key$value_unit)), table(tracer_key$value_unit), sep = " = ", collapse = ", "))

## 6. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
options(scipen = 999)
utils::write.csv(out, final_csv, row.names = FALSE, na = "")
filecodes    <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
utils::write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", qmethod = "double")
message("Wrote ", nrow(out), " rows -> ", basename(final_csv), " and ", item_encoded, ".tsv")
