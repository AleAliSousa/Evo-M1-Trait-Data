## Babushina_etal_1991_Text.R -- constructed data-from-text snapshot -> analysis CSV + public TSV
##
## Babushina, Ye. S., Zaslavskii, G. L., & Yurkevich, L. I. (1991). Air and underwater hearing
## characteristics of the northern fur seal: audiograms, frequency and differential thresholds.
## Biophysics 36(5): 909-913 (no DOI; registry alternate id Biophysics:36:909-913).
##
## THE ITEM IS RUNNING TEXT (constructed snapshot Babushina_etal_1991_Text_snapshot.csv, 28 records
## T01-T28, transcribed 2026-10-26 from page images; see Babushina_etal_1991_Text_snapshot_notes.txt).
## Values are printed as ranges with raised decimal points (0·1), en dashes, ' . . '
## and 'to'/'and'. This build parses each printed value into value_from / value_to (first / second number as printed)
## WITHOUT correcting anything; the Abstract's '05–40' (T01; Results T11 prints
## '0·5–40') is left unparsed (NA) and flagged rather than read as 5 kHz.
## Units are kept as printed (dB references differ by medium; not converted here).
## Secondary records T08-T10 cite numbered references; their printed keys stay in
## citation_key_as_printed and are expanded to one number per '; ' in ref_numbers,
## joinable to reference_tables/Babushina_etal_1991_Text_references.csv (ref_key).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Babushina_etal_1991_Text"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## UTF-8 output even under Rscript in a C locale (printed labels carry µ, °, −)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
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
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", fileEncoding = "UTF-8", na.strings = NULL)
stopifnot(nrow(snap) == 28L, !anyDuplicated(snap$Record))
refs <- read.csv(refs_csv, stringsAsFactors = FALSE, colClasses = "character", fileEncoding = "UTF-8")

## 3. PARSE printed values (no correction) ------------------------------
norm <- function(x) {
  x <- gsub("\u00b7", ".", x)            # raised decimal point
  x <- gsub("\u2212", "-", x)            # minus sign
  trimws(x)
}
split_range <- function(x) {
  x <- norm(x)
  parts <- strsplit(x, "\\s*(\u2013| \\. \\. | to | and )\\s*")
  t(vapply(parts, function(p) {
    p <- suppressWarnings(as.numeric(p))
    if (length(p) == 1) c(p, p) else if (length(p) == 2) p else c(NA_real_, NA_real_)
  }, numeric(2)))
}
v  <- split_range(snap$`Value as printed`)
fq <- split_range(ifelse(nzchar(snap$`Frequency as printed`), snap$`Frequency as printed`, NA))
parse_flag <- rep("", nrow(snap))
## T01: Abstract prints "05–40" (no decimal mark). Kept as printed, not parsed.
i01 <- snap$`Value as printed` == "05\u201340"
v[i01, ] <- NA_real_
parse_flag[i01] <- "value not parsed: printed '05' (Results T11 prints '0\u00b75'); kept as printed"
## T23: "over 16%" is a lower bound
parse_flag[snap$`Qualifier as printed` == "over"] <- "lower bound ('over' as printed)"
ref_numbers <- vapply(snap$`Citation key as printed`, function(k) {
  if (!nzchar(k)) return("")
  k <- gsub("[][]", "", k)
  nums <- unlist(lapply(strsplit(k, ",\\s*")[[1]], function(p) {
    r <- as.integer(strsplit(p, "\u2013")[[1]]); if (length(r) == 2) seq(r[1], r[2]) else r }))
  paste(nums, collapse = "; ")
}, character(1), USE.NAMES = FALSE)
cited <- unique(unlist(strsplit(ref_numbers[nzchar(ref_numbers)], "; ")))
stopifnot(all(cited %in% refs$ref_key))

sp_print <- snap$`Species as printed`
sp_harm  <- ifelse(sp_print %in% c("seals", "true seals"), "", NA)   # group names, not species
sp_harm[is.na(sp_harm)] <- resolve(sp_print[is.na(sp_harm)])

final.dataframe <- tibble(
  record = snap$Record,
  species_as_published = sp_print,
  scientific_name_as_printed = snap$`Scientific name as printed (p. 910)`,
  species = sp_harm,
  medium = snap$Medium,
  measure_as_printed = snap$`Measure (paper's wording)`,
  value_as_printed = snap$`Value as printed`,
  value_from = v[, 1], value_to = v[, 2],
  unit_as_printed = snap$`Unit as printed`,
  frequency_as_printed = snap$`Frequency as printed`,
  frequency_from_kHz = fq[, 1], frequency_to_kHz = fq[, 2],
  qualifier_as_printed = snap$`Qualifier as printed`,
  parse_flag = parse_flag,
  data_role = snap$`Data role`,
  citation_key_as_printed = snap$`Citation key as printed`,
  ref_numbers = ref_numbers,
  printed_page = snap$`Printed page`,
  section = snap$Section,
  value_origin = "printed_in_text")

## Abstract and Results restatements must agree (as parsed)
pairs <- list(c("T03","T12"), c("T04","T14"), c("T05","T17"), c("T06","T20"), c("T07","T21"))
for (p in pairs) {
  a <- final.dataframe[final.dataframe$record == p[1], ]; b <- final.dataframe[final.dataframe$record == p[2], ]
  stopifnot(identical(c(a$value_from, a$value_to), c(b$value_from, b$value_to)))
}

## WRITE CSV + PUBLIC TSV ---------------------------------------------
final.dataframe <- final.dataframe %>% mutate(across(where(is.character), ~replace_na(., "")))
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
