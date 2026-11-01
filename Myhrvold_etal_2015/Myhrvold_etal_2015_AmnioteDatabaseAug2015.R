## =============================================================================
## Myhrvold et al. (2015), Amniote Life-History Database (Aug 2015 release)
## Item: Amniote_Database_Aug_2015.csv -> long analysis table with per-value references
## =============================================================================
##
## Source: Myhrvold, N. P., Baldridge, E., Chan, B., Sivam, D., Freeman, D. L., & Ernest, S. K. M.
##   (2015). An amniote life-history database to perform comparative analyses with birds, mammals,
##   and reptiles. Ecology 96:3109. https://doi.org/10.1890/15-0846R.1
##
## Frozen sources (byte-identical copies of the two Data_Files, never edited):
##   Myhrvold_etal_2015_AmnioteDatabaseAug2015_snapshot.csv            values, -999 = missing
##   Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv  same shape and row order,
##                                                                     per-cell reference string
## Units come from Supplemental_Materials/Supplemental_Table_9_Dataset_Field_Information.csv.
##
## This is the R port of Myhrvold_etal_2015_AmnioteDatabaseAug2015.py (added 2026-10-31 so the
## item builds in R like its three siblings); it writes the same CSV and TSV byte for byte, so the
## published table does not churn. The .py is kept as the record of the original build.
##
## DATA ROLE = SECONDARY throughout: the database is itself a compilation, and each cell's
## reference names the work the value was actually reported in (or the derivation, e.g.
## "mean of X and Y"). -999 is the paper's own missing sentinel and those cells are dropped;
## subspecies -999 means "no subspecies recorded" and becomes an empty cell.
## =============================================================================

options(stringsAsFactors = FALSE, scipen = 0)
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
folder    <- dirname(.sp)
item_name <- sub("\\.R$", "", basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
invisible(Sys.setlocale("LC_COLLATE", "C"))   # byte-order sort, locale-independent

TAX_COLS <- c("class", "order", "family", "genus", "species", "subspecies", "common_name")

rd <- function(f) utils::read.csv(file.path(folder, f), colClasses = "character",
                                  check.names = FALSE, na.strings = character(0), encoding = "UTF-8")
db   <- rd(paste0(item_name, "_snapshot.csv"))
refs <- rd("Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv")
if (!identical(names(db), names(refs)))
  stop("Database and References snapshots have different columns", call. = FALSE)
if (!identical(db[TAX_COLS], refs[TAX_COLS]))
  stop("Database and References files must be row-for-row, taxon-for-taxon aligned.", call. = FALSE)
TRAIT_COLS <- setdiff(names(db), TAX_COLS)

## ---- units from Supplemental Table 9 (its first line is a title row) --------
fi <- utils::read.csv(file.path(folder, "Supplemental_Materials",
                                "Supplemental_Table_9_Dataset_Field_Information.csv"),
                      skip = 1, colClasses = "character", check.names = FALSE,
                      na.strings = character(0), encoding = "UTF-8")
names(fi)[1:5] <- c("field_number", "field_name", "units", "taxon_group", "description")
fi <- fi[nzchar(trimws(fi$field_name)), , drop = FALSE]
unit_map <- setNames(fi$units, fi$field_name)[!duplicated(fi$field_name)]

## ---- melt both files the same way, then pair value with reference -----------
n <- nrow(db)
long <- data.frame(
  idx       = rep(seq_len(n), times = length(TRAIT_COLS)),
  trait     = rep(TRAIT_COLS, each = n),
  value_chr = unlist(db[TRAIT_COLS], use.names = FALSE),
  reference = unlist(refs[TRAIT_COLS], use.names = FALSE),
  stringsAsFactors = FALSE)
long$value <- suppressWarnings(as.numeric(long$value_chr))
long <- long[!is.na(long$value) & long$value != -999, , drop = FALSE]
long$reference[long$reference == "-999"] <- ""

out <- data.frame(db[long$idx, TAX_COLS], trait = long$trait,
                  unit = unname(unit_map[long$trait]),
                  value = long$value, reference = long$reference,
                  data_role = "secondary",
                  source_location = paste("Amniote_Database_Aug_2015.csv +",
                                          "Amniote_Database_References_Aug_2015.csv (per-cell reference)"),
                  stringsAsFactors = FALSE, check.names = FALSE)
out$subspecies[out$subspecies == "-999"] <- ""   # "no subspecies recorded", not a missing value
out$unit[is.na(out$unit)] <- ""
out <- out[order(out$class, out$order, out$family, out$genus, out$species, out$trait,
                 method = "radix"), , drop = FALSE]
rownames(out) <- NULL

## ---- write CSV and TSV ------------------------------------------------------
## The values are read as doubles and printed the way the source file prints them plus a ".0" on
## whole numbers, and fields are quoted only when the separator, a quote or a newline is in them:
## that is what the .py produced, so the published files stay byte-identical across the two builds.
num_fmt <- function(x) {
  ## plain decimal unless the magnitude is outside the range Python prints plainly (<1e-4, >=1e16),
  ## then a trailing ".0" on whole numbers -- i.e. the float repr the .py wrote
  a <- abs(x)
  sci <- a != 0 & (a < 1e-4 | a >= 1e16)
  s <- vapply(seq_along(x), function(i)
    format(x[i], digits = 15, trim = TRUE, scientific = sci[i]), character(1))
  ifelse(grepl("[.eE]", s), s, paste0(s, ".0"))
}
write_sep <- function(df, path, sep) {
  cols <- lapply(df, function(cl) if (is.numeric(cl)) num_fmt(cl) else as.character(cl))
  qt <- function(x) {
    needs <- grepl(paste0("[", if (sep == ",") "," else "\t", "\"\n\r]"), x)
    ifelse(needs, paste0("\"", gsub("\"", "\"\"", x), "\""), x)
  }
  body <- do.call(paste, c(lapply(cols, qt), sep = sep))
  con <- file(path, open = "wb")
  on.exit(close(con))
  writeLines(c(paste(qt(names(df)), collapse = sep), body), con, sep = "\n", useBytes = TRUE)
}
csv_path <- file.path(folder, paste0(item_name, ".csv"))
write_sep(out, csv_path, ",")

if (!is.na(base)) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
  item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
    message("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- CSV written, public TSV skipped.")
  } else if (!dir.exists(tsv_dir)) {
    message("__Public/comparative-data not mounted; TSV skipped.")
  } else {
    write_sep(out, file.path(tsv_dir, paste0(item_encoded, ".tsv")), "\t")
    message("Wrote TSV: ", item_encoded)
  }
}
message(item_name, ".csv: ", nrow(out), " rows written")
