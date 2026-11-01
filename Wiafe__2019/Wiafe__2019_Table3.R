## Wiafe (2019) Table 3 -- frozen printed grid -> long analysis CSV (-> public TSV once registered)
##
## Source: Wiafe, E. D. (2019). Encounter rates and group sizes of diurnal primate species of
##   Mole National Park, Ghana. Journal of Threatened Taxa 11(5):13523-13530.
##   https://doi.org/10.11609/jott.4026.11.5.13523-13530
## Frozen source: Wiafe__2019_Table3_snapshot.csv = Table 3 (printed p. 13528, PDF p. 8) in its
##   printed grid -- row 1 the sector band, row 2 the Mean/SE/Range sub-header (printed casing
##   preserved), one row per species in printed order, 12 value columns left to right.
## This script reads ONLY that snapshot; it replaces the CSV-writing half of build_group_sizes.py,
## which now writes the two constructed snapshots only.
##
## The analysis layer unpivots the grid to one row per species x sector. Printed zeros are kept as
## printed: for White-thighed Colobus they mark sectors with no observed group, NOT zero-sized
## social groups (see README). Range strings stay as printed (en dash), unparsed.
## The abstract's overall means are a separate item (Wiafe__2019_GroupSizes) and are never pooled
## with, or reconstructed from, these sector rows.

options(scipen = 999)

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
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_keys", "resolve_species.R"))

folder    <- basename(item_dir)                   # "Wiafe__2019" = species_key source_publication
item_name <- sub("\\.R$", "", basename(.sp))      # "Wiafe__2019_Table3"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
csv_path  <- file.path(item_dir, paste0(item_name, ".csv"))

invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## ---- 1. Read the frozen printed grid ----
grid <- utils::read.csv(frozen, header = FALSE, colClasses = "character", check.names = FALSE,
                        na.strings = character(0), encoding = "UTF-8")
if (ncol(grid) != 13L || nrow(grid) != 6L)
  stop("expected the 6 x 13 printed grid, got ", nrow(grid), " x ", ncol(grid), call. = FALSE)
sectors <- grid[1, seq(2, 13, by = 3)]            # band header: one sector per 3-column block
sectors <- trimws(as.character(sectors))
if (!identical(sectors, c("Eastern", "Southern", "Western", "Northern")))
  stop("unexpected sector band in the snapshot: ", paste(sectors, collapse = ", "), call. = FALSE)
if (!identical(tolower(trimws(as.character(grid[2, -1]))), rep(c("mean", "se", "range"), 4L)))
  stop("unexpected Mean/SE/Range sub-header in the snapshot", call. = FALSE)
body <- grid[-(1:2), , drop = FALSE]              # one row per species, printed order

## ---- 2. Species harmonisation (_keys/General, source_publication = folder) ----
## Table 3 prints common names only; the key carries the common name -> binomial rows for this paper.
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), stringsAsFactors = FALSE,
                       check.names = FALSE, encoding = "UTF-8")
if (sum(trimws(key$source_publication) == folder) == 0L)
  stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
printed  <- trimws(body[[1]])
rs       <- resolve_species(printed, source_publication = folder)
if (any(rs$unresolved))
  stop("unresolved printed names: ", paste(printed[rs$unresolved], collapse = ", "), call. = FALSE)

## ---- 3. Unpivot the grid: one row per species x sector ----
num <- function(x) suppressWarnings(as.numeric(trimws(x)))
final.dataframe <- do.call(rbind, lapply(seq_along(sectors), function(k) {
  j <- 2L + (k - 1L) * 3L                          # Mean / SE / Range block for this sector
  data.frame(common_name_printed = printed,
             Species             = rs$accepted_name,
             sector              = sectors[k],
             group_size_mean     = num(body[[j]]),
             group_size_SE       = num(body[[j + 1L]]),
             range_printed       = trimws(body[[j + 2L]]),
             source_location     = "Table 3; printed p.13528; PDF page 8",
             stringsAsFactors = FALSE)
}))
## printed order: species within sector in the published row order, sectors left to right
final.dataframe <- final.dataframe[order(match(final.dataframe$common_name_printed, printed),
                                         match(final.dataframe$sector, sectors)), ]
rownames(final.dataframe) <- NULL
if (nrow(final.dataframe) != nrow(body) * length(sectors))
  stop("row count does not match species x sector", call. = FALSE)

## ---- 4. Write the analysis CSV ----
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- 5. Public TSV: Item encoded from the live __ReadMe.xlsx by Item name ----
## This item is not registered yet; the CSV is built regardless and the TSV is skipped until a
## registry row exists (writing an "NA.tsv" would be worse than writing none).
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  message("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- CSV written, public TSV skipped.")
} else {
  tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message(item_name, " -> ", tsv_path)
}
message(item_name, ": ", nrow(final.dataframe), " species x sector rows from ", nrow(body),
        " printed species rows; species resolved via ", paste(unique(rs$match_level), collapse = "/"))
