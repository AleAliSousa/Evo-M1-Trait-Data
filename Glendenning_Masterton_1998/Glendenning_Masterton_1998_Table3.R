## Glendenning_Masterton_1998_Table3.R -- frozen snapshot -> analysis CSV + public TSV
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. Brain, Behavior and Evolution, 51(2), 59-89. doi:10.1159/000006530
##
## Table 3 (p. 71): "Normalized logarithmic values of entries in table 2" for
## 10 nuclei plus the clusters CN (AVCN + PVCN + DCN) and SO (MTB + LSO + MSO),
## 53 animals. DERIVED in this paper (Methods: log V, then V' = (V - mu)/sigma).
## Minus signs are printed as en dashes. Frozen source written by
## Glendenning_Masterton_1998_extract_snapshot.py.

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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Glendenning_Masterton_1998_Table3"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## UTF-8 output even under Rscript in a C locale (printed names carry Greek/µ/’)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv, rows with
## source_publication == this folder's name). No mapping is hand-coded here.
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder),
       "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ",
                        paste(bad, collapse = "; "), call. = FALSE)
  out
}

## 2. LOAD -------------------------------------------------------------
snap <- read.csv(snapshot_csv, colClasses = "character", encoding = "UTF-8", check.names = FALSE)
cols <- c("AVCN", "PVCN", "DCN", "CN", "MTB", "LSO", "MSO", "SO", "VLL", "DLL", "IC", "MG")
stopifnot(identical(names(snap), c("No.", "Animal", cols)), nrow(snap) == 53L)

## species via Table 1 of the same paper (Tables 2-7 print common names only;
## Table 1 prints the binomial for each Animal No.), then the species key.
t1 <- read.csv(file.path(folder, "Glendenning_Masterton_1998_Table1_snapshot.csv"),
               colClasses = "character", encoding = "UTF-8", check.names = FALSE)
stopifnot(nrow(t1) == 53L)

stopifnot(identical(snap$No., t1$`Animal No.`), identical(snap$Animal, t1$`Common name`))
num <- function(x) as.numeric(gsub("\u2013", "-", x))      # printed en-dash minus

## 3. TABLE CHECKS: "In each column, mean is 0, standard deviation is 1" --
z <- sapply(cols, function(k) num(snap[[k]]))
table_checks <- rbind(
  data.frame(check_id = paste0("colmean0_", cols), basis = "column mean of printed values vs 0 (Table 3 note)",
             observed = round(colMeans(z), 4), printed = 0, difference = round(colMeans(z), 4), tolerance = 0.03,
             stringsAsFactors = FALSE),
  data.frame(check_id = paste0("colsd1_", cols), basis = "column SD of printed values vs 1 (Table 3 note)",
             observed = round(apply(z, 2, sd), 4), printed = 1, difference = round(apply(z, 2, sd) - 1, 4), tolerance = 0.03,
             stringsAsFactors = FALSE))
table_checks$status <- ifelse(abs(table_checks$difference) <= table_checks$tolerance, "pass", "mismatch")
table_checks$note <- "tolerance 0.03 allows 3-significant-figure rounding of 53 cells; values were NOT re-derived from Table 2 (a plain z-score of log Table 2 percentages does not reproduce the printed values -- the exact normalisation is not stated)"
print(table_checks[, c("check_id", "observed", "status")], row.names = FALSE)
if (any(table_checks$status != "pass")) warning("Table 3 column checks not passed", call. = FALSE)

## 4. CLEAN ------------------------------------------------------------
final.dataframe <- tibble(
  animal_no = as.integer(snap$No.), common_name_as_printed = snap$Animal,
  species_as_printed = t1$`Genus and species`, species = resolve(t1$`Genus and species`))
for (k in cols) final.dataframe[[paste0(k, "_normalized_log_pct")]] <- num(snap[[k]])
final.dataframe$data_role <- "primary"
stopifnot(!anyNA(final.dataframe))

## WRITE CSV + PUBLIC TSV ---------------------------------------------
## No __ReadMe.xlsx row yet: Item encoded is derived by the house convention
## (url-encoded DOI + "_" + compacted Item number) and, once the owner pastes
## the registry row, must equal the registry value (checked below).
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
doi <- "10.1159/000006530"
expected_encoded <- paste0(utils::URLencode(doi, reserved = TRUE), "_", sub("^.*_", "", item_name))
item_encoded <- expected_encoded
if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  ix <- match(item_name, filecodes$`Item name`)
  if (!is.na(ix)) {
    item_encoded <- filecodes$`Item encoded`[ix]
    if (!identical(item_encoded, expected_encoded))
      stop("Registry Item encoded '", item_encoded, "' != derived '", expected_encoded,
           "' -- the registry is the authority; rename the TSV.", call. = FALSE)
  } else warning("Item not yet in __ReadMe.xlsx; using derived Item encoded ", expected_encoded)
}
if (grepl("_$", item_encoded)) stop("Item encoded ends with '_'", call. = FALSE)
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
