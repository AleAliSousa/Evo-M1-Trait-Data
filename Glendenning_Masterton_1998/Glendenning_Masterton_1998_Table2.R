## Glendenning_Masterton_1998_Table2.R -- frozen snapshot -> analysis CSV + public TSV
##
## Glendenning, K. K., & Masterton, R. B. (1998). Comparative morphometry of mammalian central auditory systems: Variation in nuclei and form of the ascending system. Brain, Behavior and Evolution, 51(2), 59-89. doi:10.1159/000006530
##
## Table 2 (p. 70): percentage size of each nucleus relative to the total of
## the 10 nuclei, per animal (53 rows) + printed Average / Standard deviation /
## % variation rows. DERIVED in this paper from Table 1 (each cell = 100 x
## nucleus / Total); not reused from another paper. Frozen source written by
## Glendenning_Masterton_1998_extract_snapshot.py (text-layer coordinates).
## Summary rows stay in the snapshot; the analysis CSV carries the 53 animals.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Glendenning_Masterton_1998_Table2"
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
nuc <- c("AVCN", "PVCN", "DCN", "MTB", "LSO", "MSO", "VLL", "DLL", "IC", "MG")
stopifnot(identical(names(snap), c("No.", "Animal", nuc)), nrow(snap) == 56L)

## species via Table 1 of the same paper (Tables 2-7 print common names only;
## Table 1 prints the binomial for each Animal No.), then the species key.
t1 <- read.csv(file.path(folder, "Glendenning_Masterton_1998_Table1_snapshot.csv"),
               colClasses = "character", encoding = "UTF-8", check.names = FALSE)
stopifnot(nrow(t1) == 53L)

sp <- snap[nzchar(snap$No.), ]; summ <- snap[!nzchar(snap$No.), ]
stopifnot(nrow(sp) == 53L, identical(sp$No., t1$`Animal No.`), identical(sp$Animal, t1$`Common name`),
          identical(summ$Animal, c("Average", "Standard deviation", "% variation")))
num <- function(x) as.numeric(x)

## 3. TABLE CHECKS: "each row sums to 100%" (Table 2 note) ---------------
## Each cell is 100 x nucleus / Total, computed from the ROUNDED Table 1 values,
## so a row can miss 100 by the rounding of Table 1's printed Total and nuclei
## as well as its own cells: tolerance = half a unit of each Table 2 cell
## + 100 x (half a unit of Table 1 Total + summed half units of its 10 nuclei) / Total.
hu <- function(x) { d <- nchar(sub("^[^.]*\\.?", "", x)); 0.5 * 10^(-d) }
obs <- rowSums(sapply(nuc, function(k) num(sp[[k]])))
t1tot <- as.numeric(t1$Total)
tl  <- rowSums(sapply(nuc, function(k) hu(sp[[k]]))) +
       100 * (hu(t1$Total) + rowSums(sapply(nuc, function(k) hu(t1[[k]])))) / t1tot
table_checks <- data.frame(
  check_id = paste0("rowsum100_", sp$No., "_", sp$Animal),
  basis = "sum of the 10 printed percentages vs 100 (Table 2 note: each row sums to 100%)",
  observed = round(obs, 3), printed = 100, difference = round(obs - 100, 3), tolerance = round(tl, 4),
  status = ifelse(abs(obs - 100) <= tl + 1e-9, "pass", "mismatch"),
  note = "tolerance propagates rounding of this row and of Table 1 Total/nuclei; Average/SD rows not re-derived (the printed Average is not reproducible from the printed rows as a geometric mean)",
  stringsAsFactors = FALSE)
bad <- table_checks[table_checks$status == "mismatch", ]
print(bad[, c("check_id", "observed", "difference", "tolerance")], row.names = FALSE)
if (nrow(bad)) warning(nrow(bad), " Table 2 rows do not sum to 100% -- kept as printed (see errata).", call. = FALSE)

## 4. CLEAN ------------------------------------------------------------
final.dataframe <- tibble(
  animal_no = as.integer(sp$No.), common_name_as_printed = sp$Animal,
  species_as_printed = t1$`Genus and species`, species = resolve(t1$`Genus and species`))
for (k in nuc) final.dataframe[[paste0(k, "_pct_of_total10")]] <- num(sp[[k]])
final.dataframe$rowsum100_check <- table_checks$status
final.dataframe$data_role <- "primary"

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
