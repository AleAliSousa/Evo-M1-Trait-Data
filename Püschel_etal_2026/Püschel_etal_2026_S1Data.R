## Püschel_etal_2026_S1Data.R -- born-digital journal CSV -> analysis CSV + public TSV
##
## Püschel, T. A., Hurwitz, R. M., & Venditti, C. (2026). Bipedalism and brain expansion explain
##   human handedness. PLoS Biology, 24(4), e3003771. https://doi.org/10.1371/journal.pbio.3003771
##
## Item: "S1 Data. Dataset analyzed in the present study. (CSV)" (Supporting information, PDF p. 14).
##   The journal file is journal.pbio.3003771.s010.csv: the 10th supporting file in the order the
##   paper lists them (S1-S3 Table, S1-S2 Fig, S1-S2 Section, S1-S2 Code, S1 Data, S2 Data).
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a invariant 1):
##   journal.pbio.3003771.s010.csv is the untouched journal download, kept verbatim in this folder
##   (sha256 0ff81cea1f63ac7a2dc84f77c6bb363a63d0b589632775db51dccab67c541dd2). Quirks handled on
##   read, never repaired in the file:
##     * Mac Roman encoding (0x87 = a-acute, 0x92 = i-acute, 0xD0 = en dash, 0xD5 = right quote);
##     * CRLF line endings;
##     * 1 header row + 71 data rows x 42 columns; six header cells read "reference" (each one is
##       the source column of the variable printed just before it); the last four columns have
##       no header and no value (one cell holds a single space).
##   This script only reads it.
##
## Observation level: one printed row = one source study x species (71 rows, 41 species, 2,025
##   individuals). MHI / MABSHI with their SD, SE and n are study-level; the covariates (body mass
##   ... body-mass dimorphism) are species-level values repeated on every row of the species.
## Data role: secondary. Every value was compiled by Püschel et al. from the source printed in the
##   matching reference column (reference_tables/Püschel_etal_2026_S1Data_references.csv).

## ---- 0. Paths: self-locating, so it runs from any working directory ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
item_dir <- dirname(.sp)
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))

## The folder and item names carry an umlaut: compare them in Unicode NFC so a decomposed file
## name (macOS) still matches the composed spelling in __ReadMe.xlsx and the species key.
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(enc2utf8(x)) else enc2utf8(x)

folder    <- nfc(basename(item_dir))                    # "Püschel_etal_2026" = species_key source_publication
item_name <- nfc(sub("\\.R$", "", basename(.sp)))       # "Püschel_etal_2026_S1Data"
frozen    <- file.path(item_dir, "journal.pbio.3003771.s010.csv")

## ---- 1. Read the frozen download (Mac Roman -> UTF-8; all character; blanks stay blank) ----
con   <- file(frozen, encoding = "macintosh")
lines <- readLines(con, warn = FALSE)                   # LF, CRLF and CR all end a line
close(con)
if (!any(grepl("Gal\u00e1n-Acedo", lines, fixed = TRUE)))
  stop("Mac Roman decoding failed: sentinel 'Galán-Acedo' not found in ", basename(frozen), call. = FALSE)
raw <- utils::read.csv(text = lines, header = FALSE, colClasses = "character",
                       na.strings = character(0), check.names = FALSE, strip.white = FALSE,
                       encoding = "UTF-8")

## ---- 2. Positional read: check the printed header, then keep the 71 data rows ----
printed_header <- c("internal_id", "species", "mean_mhi", "sd_mhi", "st_err_mhi", "mean_mabshi",
                    "sd_mabshi", "st_err_mabshi", "sample_size", "reference_name_in_analyses",
                    "reference", "body_mass", "body_mass_ref", "ecv", "reference", "tool_use",
                    "reference", "substrate", "reference", "fruit", "reference", "diet", "reference",
                    "social_system", "reference", "imi", "imputed_imi", "imi_ref", "cl", "cl_ref",
                    "extractive", "reference", "social.learning", "reference",
                    "imputed_extractive_&_social_learning", "bm_dimo", "imputed_dimo", "reference",
                    "", "", "", "")
if (ncol(raw) != 42L || !identical(unname(unlist(raw[1, ])), printed_header))
  stop("unexpected header in ", basename(frozen), call. = FALSE)
dat <- raw[-1, , drop = FALSE]
if (nrow(dat) != 71L) stop("expected 71 data rows, got ", nrow(dat), call. = FALSE)
if (any(nzchar(trimws(unlist(dat[, 39:42])))))
  stop("the four unnamed trailing columns are expected to be empty", call. = FALSE)
dat <- dat[, 1:38]                                       # drop the unnamed empty columns
## Column positions are the printed ones (1-38); the six "reference" headers are told apart by
## the variable printed just before each of them.

## Text: trim, and collapse runs of white space to one space (the diet citation for Nomascus siki
## prints ");  Geissmann"; five citations start with a space). No other character is changed.
txt <- function(x) { x <- trimws(gsub("[[:space:]]+", " ", x)); ifelse(nzchar(x), x, NA_character_) }
## Numbers: every numeric cell is filled; a cell that does not parse stops the build.
num <- function(x, col) {
  x <- trimws(x); v <- suppressWarnings(as.numeric(x))
  if (any(is.na(v) & nzchar(x))) stop("non-numeric cell in ", col, ": ",
                                      paste(unique(x[is.na(v) & nzchar(x)]), collapse = ", "), call. = FALSE)
  v
}
P <- function(i) dat[[i]]                                # printed column i

## ---- 3. Species: printed name kept; accepted name via the General collection key ----
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[nfc(trimws(key$source_publication)) == folder, , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
species_as_published <- txt(P(2))
Species <- unname(lk[tolower(species_as_published)])
if (anyNA(Species))
  stop("Unkeyed printed name: ", paste(unique(species_as_published[is.na(Species)]), collapse = ", "), call. = FALSE)

## ---- 4. Analysis table: one row per printed row, printed column order ----
## Units (paper Fig 2 legend, PDF p. 4, and Methods, PDF p. 11): body mass in kg, ECV in cm3, fruit and diet in %.
## Project units added beside the printed ones: body mass kg x 1000 -> g; ECV cm3 x 1000 -> mm3.
## Codes are kept as printed: tool_use Yes/No; substrate AR/BOTH/T (paper: arboreal/both/terrestrial);
## social_system Group/Pair/Solitary; extractive and social_learning 0/1; cl 1-4; imputed_* Yes/No.
body_mass_kg <- num(P(12), "body_mass")
ecv_cm3      <- num(P(14), "ecv")
final.dataframe <- data.frame(
  internal_id                        = as.integer(num(P(1), "internal_id")),
  species_as_published               = species_as_published,
  Species                            = Species,
  mean_mhi                           = num(P(3), "mean_mhi"),
  sd_mhi                             = num(P(4), "sd_mhi"),
  st_err_mhi                         = num(P(5), "st_err_mhi"),
  mean_mabshi                        = num(P(6), "mean_mabshi"),
  sd_mabshi                          = num(P(7), "sd_mabshi"),
  st_err_mabshi                      = num(P(8), "st_err_mabshi"),
  sample_size                        = as.integer(num(P(9), "sample_size")),
  reference_name_in_analyses         = txt(P(10)),
  handedness_reference               = txt(P(11)),
  body_mass_kg                       = body_mass_kg,
  body_mass_g                        = body_mass_kg * 1000,
  body_mass_ref                      = txt(P(13)),
  ecv_cm3                            = ecv_cm3,
  ecv_mm3                            = ecv_cm3 * 1000,
  ecv_reference                      = txt(P(15)),
  tool_use                           = txt(P(16)),
  tool_use_reference                 = txt(P(17)),
  substrate                          = txt(P(18)),
  substrate_reference                = txt(P(19)),
  fruit_pct                          = num(P(20), "fruit"),
  fruit_reference                    = txt(P(21)),
  diet_pct                           = num(P(22), "diet"),
  diet_reference                     = txt(P(23)),
  social_system                      = txt(P(24)),
  social_system_reference            = txt(P(25)),
  imi                                = num(P(26), "imi"),
  imputed_imi                        = txt(P(27)),
  imi_ref                            = txt(P(28)),
  cl                                 = as.integer(num(P(29), "cl")),
  cl_ref                             = txt(P(30)),
  extractive                         = as.integer(num(P(31), "extractive")),
  extractive_reference               = txt(P(32)),
  social_learning                    = as.integer(num(P(33), "social.learning")),
  social_learning_reference          = txt(P(34)),
  imputed_extractive_social_learning = txt(P(35)),
  bm_dimo                            = num(P(36), "bm_dimo"),
  imputed_dimo                       = txt(P(37)),
  bm_dimo_reference                  = txt(P(38)),
  observation_level                  = "study x species (MHI/MABSHI per source study; covariates are species-level values repeated per row)",
  source_locator                     = paste0("S1 Data (journal.pbio.3003771.s010.csv), data row ", trimws(P(1))),
  data_role                          = "secondary",
  stringsAsFactors = FALSE, check.names = FALSE)

## ---- 5. Table checks (build HOWTO sec. 7a): relations the table can check itself ----
## Results stay in `table_checks` (QA metadata; never written to the CSV/TSV). Values are never changed.
tc <- list()
add_check <- function(check_id, basis, observed, printed, tolerance, ok, note = "")
  tc[[length(tc) + 1L]] <<- data.frame(check_id = check_id, basis = basis, observed = observed,
    printed = printed, difference = observed - printed, tolerance = tolerance,
    status = ifelse(is.na(ok), "not_evaluable", ifelse(ok, "pass", "mismatch")), note = note,
    stringsAsFactors = FALSE)
fd  <- final.dataframe
rid <- fd$internal_id

## 5a. Totals stated in the text (Methods, PDF p. 11: "The final dataset included information from
##     2,025 individuals across 41 species of anthropoid primates").
add_check("text_total_individuals", "sum(sample_size) vs Methods p. 11 '2,025 individuals'",
          sum(fd$sample_size), 2025, 0, sum(fd$sample_size) == 2025)
add_check("text_total_species", "distinct printed species vs Methods p. 11 '41 species'",
          length(unique(fd$species_as_published)), 41, 0, length(unique(fd$species_as_published)) == 41)

## 5b. SE = SD / sqrt(n), per row. Compared in units of the last printed decimal (0.01): half a unit
##     for the printed SE plus the half unit of the printed SD carried through 1/sqrt(n).
for (v in c("mhi", "mabshi")) {
  sd <- fd[[paste0("sd_", v)]]; se <- fd[[paste0("st_err_", v)]]; n <- fd$sample_size
  obs_u <- sd * 100 / sqrt(n); prn_u <- round(se * 100); tol_u <- 0.5 + 0.5 / sqrt(n)
  for (i in seq_len(nrow(fd)))
    add_check(sprintf("se_%s_row%02d", v, rid[i]),
              sprintf("st_err_%s vs sd_%s / sqrt(sample_size), row %d", v, v, rid[i]),
              round(obs_u[i] / 100, 4), prn_u[i] / 100, round(tol_u[i] / 100, 4),
              abs(obs_u[i] - prn_u[i]) <= tol_u[i] + 1e-9, "two printed decimals; rounding of SD and SE allowed")
}

## 5c. mean |HI| >= |mean HI| (true for any sample), per row; tolerance one unit (two half units).
for (i in seq_len(nrow(fd)))
  add_check(sprintf("mabshi_ge_abs_mhi_row%02d", rid[i]),
            sprintf("mean_mabshi >= |mean_mhi|, row %d (difference must be >= -tolerance)", rid[i]),
            fd$mean_mabshi[i], abs(fd$mean_mhi[i]), 0.01,
            round(fd$mean_mabshi[i] * 100) >= round(abs(fd$mean_mhi[i]) * 100) - 1)

## 5d. Species-level covariates must print the same value on every row of a species.
cov_cols <- c("body_mass_kg", "ecv_cm3", "tool_use", "substrate", "fruit_pct", "diet_pct", "social_system",
              "imi", "imputed_imi", "cl", "extractive", "social_learning",
              "imputed_extractive_social_learning", "bm_dimo", "imputed_dimo")
for (sp in unique(fd$species_as_published[duplicated(fd$species_as_published)])) {
  r <- which(fd$species_as_published == sp)
  for (cc in cov_cols) {
    vals <- as.character(fd[[cc]][r]); k <- length(unique(vals))
    add_check(sprintf("species_constant_%s_%s", cc, sp),
              sprintf("%s identical on the %d rows of %s", cc, length(r), sp), k, 1, 0, k == 1L,
              if (k > 1L) paste0("printed: ", paste(paste0("row ", rid[r], " = ", vals), collapse = "; ")) else "")
  }
}

## 5e. An imputed value has no source: imputed_* == "Yes" exactly when the reference cell is blank.
imp <- list(c("imputed_imi", "imi_ref"), c("imputed_dimo", "bm_dimo_reference"),
            c("imputed_extractive_social_learning", "extractive_reference"),
            c("imputed_extractive_social_learning", "social_learning_reference"))
for (p in imp) for (i in seq_len(nrow(fd))) {
  blank <- as.numeric(is.na(fd[[p[2]]][i])); yes <- as.numeric(identical(fd[[p[1]]][i], "Yes"))
  add_check(sprintf("imputed_vs_blank_%s_row%02d", p[2], rid[i]),
            sprintf("%s blank (1/0) vs %s == 'Yes' (1/0), row %d", p[2], p[1], rid[i]), blank, yes, 0,
            blank == yes, if (blank != yes) paste0(fd$species_as_published[i], ": ", p[1], " = ", fd[[p[1]]][i],
                                                   ", ", p[2], if (blank == 1) " blank" else " filled") else "")
}
table_checks <- do.call(rbind, tc)
if (any(table_checks$status == "mismatch"))
  warning(sum(table_checks$status == "mismatch"), " table check(s) did not pass -- values kept as printed; ",
          "see the ReadMe '## Table checks'", call. = FALSE)

## ---- 6. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- 7. Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
filecodes$`Item name` <- nfc(as.character(filecodes$`Item name`))
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_dir  <- file.path(root, "__Public", "comparative-data")
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.1371%2Fjournal.pbio.3003771_S1Data
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name,
          " -- public TSV NOT written; check the registry row (citation must start 'P\u00fcschel').", call. = FALSE)
} else {
  tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}

## ---- 8. Validate ----
checks <- validate_dataset_item(
  csv_file           = csv_path,
  tsv_file           = tsv_path,
  readme_file        = file.path(item_dir, paste0(item_name, ".README.md")),
  definitions_file   = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = if (is.na(tsv_path)) NULL else item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " rows; ", length(unique(final.dataframe$Species)),
        " species; table checks: ", paste(names(table(table_checks$status)), table(table_checks$status),
                                         sep = " = ", collapse = ", "))
