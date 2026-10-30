# Ernest__2003_Mammallifehistoriesv2.txt.R
#
# Reformat: frozen source (digital-native download) -> analysis CSV -> public TSV
#
# Source: Ernest, S. K. M. (2003). Life history characteristics of placental nonvolant mammals.
# Ecology, 84(12), 3402. Ecological Archives E084-093-D1. https://doi.org/10.1890/02-9002
# Data file Mammal_lifehistories_v2.txt (1,440 records + header; tab-delimited ASCII, CRLF),
# downloaded 2026-10-23 from https://esapubs.org/archive/ecol/E084/093/ .
#
# Frozen sources (both untouched downloads, bytes unchanged):
#   Ernest__2003_Mammallifehistoriesv2.txt_snapshot.tsv  = Mammal_lifehistories_v2.txt, copy-renamed
#     (SHA-256 9b7a4ef7082c7b37ab76b922cfd5c86fd3e49444fa2db180439cfbe051fef6b9)
#   metadata.htm = the data paper's metadata page (variable definitions, authentication sums,
#     numbered reference list 1-29) (SHA-256 e746b54a9cbabd2b23022fc0e8ef4000383ec3b9d13923e607ca7990965a8758)
# This script only reads them.

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

folder    <- basename(item_dir)
item_name <- sub("\\.R$", "", basename(.sp))   # "Ernest__2003_Mammallifehistoriesv2.txt" = __ReadMe.xlsx "Item name"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.tsv"))
metadata  <- file.path(item_dir, "metadata.htm")

# ---- 1. Read the frozen source (header read; already machine-readable) ----
raw <- read.delim(frozen, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE,
                  colClasses = "character", quote = "\"", na.strings = character(0))
## The file ends with 4 rows that are only tabs (Excel export residue); drop them.
raw <- raw[apply(raw, 1, function(r) any(nzchar(trimws(r)))), , drop = FALSE]
if (nrow(raw) != 1440L) stop("expected 1,440 records (metadata Class IV A), got ", nrow(raw), call. = FALSE)

# ---- 2. Table check: metadata Class IV A 'Authentication procedures' column sums ----
## The published sums INCLUDE the -999 missing codes (hence the negative totals), so they
## are checked on the raw values before -999 -> NA.
auth <- data.frame(
  column    = c("mass(g)", "gestation(mo)", "newborn(g)", "weaning(mo)", "wean mass(g)",
                "AFR(mo)", "max. life(mo)", "litter size", "litters/year"),
  published = c(552350473.58, -413634.01, 9652529.75, -615124.25, 23110460.38,
                -587698.17, -705968.00, -80112.72, -687082.61),
  stringsAsFactors = FALSE)
auth$computed   <- vapply(auth$column, function(cl) sum(as.numeric(raw[[cl]])), numeric(1))
auth$difference <- round(auth$computed - auth$published, 2)
auth$status     <- ifelse(abs(auth$difference) <= 0.05, "PASS", "FAIL")
table_checks <- auth
print(table_checks, row.names = FALSE)

# ---- 3. Clean column names -> R-friendly, unit kept in the name ----
name_map <- c(
  "order" = "Order", "family" = "Family", "Genus" = "Genus", "species" = "species",
  "mass(g)" = "Adult_mass_g", "gestation(mo)" = "Gestation_mo", "newborn(g)" = "Newborn_mass_g",
  "weaning(mo)" = "Weaning_age_mo", "wean mass(g)" = "Weaning_mass_g", "AFR(mo)" = "AFR_mo",
  "max. life(mo)" = "Max_lifespan_mo", "litter size" = "Litter_size",
  "litters/year" = "Litters_per_year", "refs" = "refs")
if (!setequal(names(raw), names(name_map))) stop("unexpected header in frozen source", call. = FALSE)
final.dataframe <- raw
names(final.dataframe) <- unname(name_map[names(raw)])

## Printed binomial kept as the paper's own name (Genus + species epithet as in the file).
final.dataframe$Species_Ernest2003 <- paste(final.dataframe$Genus, final.dataframe$species)

# ---- 4. Numeric columns: -999 = missing (metadata Class IV A); units already g / months ----
## Project body-mass unit is g, as printed: no conversion. Durations kept in months as printed
## (x 30.4375 for days if ever needed; not applied here so values stay comparable to the source).
num_cols <- c("Adult_mass_g", "Gestation_mo", "Newborn_mass_g", "Weaning_age_mo", "Weaning_mass_g",
              "AFR_mo", "Max_lifespan_mo", "Litter_size", "Litters_per_year")
for (col in num_cols) {
  v <- suppressWarnings(as.numeric(final.dataframe[[col]]))
  v[v == -999] <- NA
  final.dataframe[[col]] <- v
}

# ---- 5. Reference keys: printed "1,2,6" -> "1; 2; 6" (house multi-citation separator) ----
final.dataframe$refs <- gsub("\\s*,\\s*", "; ", trimws(final.dataframe$refs))

final.dataframe <- final.dataframe[, c("Order", "Family", "Genus", "species", "Species_Ernest2003",
                                       num_cols, "refs")]

# ---- 6. Reference table from metadata.htm (Class V F 'Reference list for data set') ----
html <- paste(readLines(metadata, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
start <- regexpr("Reference list for data set", html, fixed = TRUE)
if (start < 0) stop("reference list heading not found in metadata.htm", call. = FALSE)
seg  <- substring(html, start)
seg  <- substring(seg, 1, regexpr("</table>", seg, fixed = TRUE))
rows <- regmatches(seg, gregexpr("(?s)<tr[^>]*>.*?</tr>", seg, perl = TRUE))[[1]]
cell_text <- function(r) {
  cells <- regmatches(r, gregexpr("(?s)<td[^>]*>.*?</td>", r, perl = TRUE))[[1]]
  x <- gsub("<[^>]+>", "", cells)
  x <- gsub("&nbsp;", " ", x, fixed = TRUE); x <- gsub("&amp;", "&", x, fixed = TRUE)
  x <- gsub("&#150;", "\u2013", x, fixed = TRUE); x <- gsub("&#151;", "\u2014", x, fixed = TRUE)   # cp1252 dashes
  trimws(gsub("\\s+", " ", x))
}
cells <- lapply(rows, cell_text)
cells <- Filter(function(x) length(x) >= 2 && grepl("^[0-9]+$", x[1]), cells)
references <- data.frame(
  ref_key         = vapply(cells, `[`, "", 1),
  cited_in_column = "refs",
  citation        = vapply(cells, function(x) paste(x[-1], collapse = " "), ""),
  note            = "",
  stringsAsFactors = FALSE)
used <- sort(unique(unlist(strsplit(final.dataframe$refs, "; ", fixed = TRUE))))
missing_keys <- setdiff(used, references$ref_key)
if (length(missing_keys)) stop("refs keys with no bibliography entry: ", paste(missing_keys, collapse = ", "), call. = FALSE)
references$note[!references$ref_key %in% used] <- "listed in metadata.htm but not cited in any data row"
references$note[references$ref_key %in% c("16", "18")] <-
  "metadata: used only for body masses, and only when no life-history source gave one"
references$note[grepl("\ufffd", references$citation)] <- trimws(paste(
  references$note[grepl("\ufffd", references$citation)],
  "U+FFFD replacement character present in the source page (lost apostrophe/quote), kept verbatim"))
write.csv(references, file.path(item_dir, "reference_tables", paste0(item_name, "_references.csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

# ---- 7. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, csv_path, row.names = FALSE, na = "")

# ---- 8. Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes    <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- refusing to write NA.tsv", call. = FALSE)
tsv_dir  <- file.path(root, "__Public", "comparative-data")
tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "")

# ---- 9. Validate ----
readme_file <- file.path(item_dir, paste0(item_name, ".README.md"))
checks <- validate_dataset_item(
  csv_file           = csv_path,
  tsv_file           = tsv_path,
  readme_file        = readme_file,
  definitions_file   = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = item_encoded
)
print(checks, row.names = FALSE)
if (any(table_checks$status == "FAIL")) stop("authentication-sum table check failed", call. = FALSE)
if (any(checks$status == "FAIL"))
  stop("validation failed for ", item_name, ": ",
       paste(checks$check[checks$status == "FAIL"], collapse = ", "), call. = FALSE)
message("Built ", item_name, ": ", nrow(final.dataframe), " rows -> CSV + ", basename(tsv_path),
        "; ", nrow(references), " references")
