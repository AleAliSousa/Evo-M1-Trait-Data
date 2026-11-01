## Wiafe (2019) abstract group sizes -- constructed snapshot -> analysis CSV (-> public TSV once registered)
##
## Source: Wiafe, E. D. (2019). Encounter rates and group sizes of diurnal primate species of
##   Mole National Park, Ghana. Journal of Threatened Taxa 11(5):13523-13530.
##   https://doi.org/10.11609/jott.4026.11.5.13523-13530
## Frozen source: Wiafe__2019_GroupSizes_snapshot.csv -- a CONSTRUCTED snapshot, because these
##   overall means are printed in prose (Abstract, printed p. 13523), not tabulated. One row per
##   reported value, each carrying the verbatim sentence, and the colobus value kept as the
##   printed word "six". This script reads ONLY that snapshot; it replaces the CSV-writing half
##   of build_group_sizes.py, which now writes the two constructed snapshots only.
##
## The reported overall means are NOT reproducible from Table 3's rounded sector means weighted by
## Table 1's group counts, so they are retained as the author reported them and flagged; the sector
## rows (Wiafe__2019_Table3) are never pooled to replace them. Table 1 counts GROUPS per sector and
## its means (14.5/9.8/6.8) are not social group sizes.

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
item_name <- sub("\\.R$", "", basename(.sp))      # "Wiafe__2019_GroupSizes"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
csv_path  <- file.path(item_dir, paste0(item_name, ".csv"))

invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## ---- 1. Read the constructed snapshot ----
snap <- utils::read.csv(frozen, colClasses = "character", check.names = FALSE,
                        na.strings = character(0), encoding = "UTF-8")
need <- c("source_location", "common_name_as_printed", "scientific_name_as_printed",
          "mean_group_size_as_printed", "SE_as_printed", "range_as_printed", "verbatim_passage")
if (!identical(names(snap), need))
  stop("unexpected snapshot header: ", paste(names(snap), collapse = ", "), call. = FALSE)
if (nrow(snap) != 4L) stop("expected the 4 reported values, got ", nrow(snap), call. = FALSE)

## ---- 2. Species harmonisation (_keys/General, source_publication = folder) ----
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), stringsAsFactors = FALSE,
                       check.names = FALSE, encoding = "UTF-8")
if (sum(trimws(key$source_publication) == folder) == 0L)
  stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
rs <- resolve_species(trimws(snap$scientific_name_as_printed), source_publication = folder)
if (any(rs$unresolved))
  stop("unresolved printed names: ",
       paste(snap$scientific_name_as_printed[rs$unresolved], collapse = ", "), call. = FALSE)

## ---- 3. Printed prose -> analysis values ----
## "six" is the only spelled-out number in the snapshot; the ranges print as "1-38" (hyphen).
spelled <- c(six = 6)
to_num <- function(x) {
  x <- trimws(x)
  out <- suppressWarnings(as.numeric(x))
  hit <- is.na(out) & tolower(x) %in% names(spelled)
  out[hit] <- unname(spelled[tolower(x[hit])])
  if (any(is.na(out) & nzchar(x))) stop("unparsed printed number: ", paste(x[is.na(out) & nzchar(x)], collapse = ", "), call. = FALSE)
  out
}
range_part <- function(x, i) {
  p <- strsplit(trimws(x), "\\s*[-\u2013]\\s*")
  vapply(p, function(v) if (length(v) == 2L) as.numeric(v[i]) else NA_real_, numeric(1))
}
value   <- to_num(snap$mean_group_size_as_printed)
rng_min <- range_part(snap$range_as_printed, 1L)
rng_max <- range_part(snap$range_as_printed, 2L)
## the colobus row prints no range: the single observed group of six is its own min and max
single  <- !nzchar(trimws(snap$range_as_printed))
rng_min[single] <- value[single]
rng_max[single] <- value[single]

final.dataframe <- data.frame(
  Species             = rs$accepted_name,
  group_size_reported = value,
  group_size_SE       = suppressWarnings(as.numeric(trimws(snap$SE_as_printed))),
  range_min           = rng_min,
  range_max           = rng_max,
  statistic           = ifelse(single, "single observed group", "reported overall mean"),
  population          = "Mole National Park, Ghana",
  setting             = "wild",
  age_scope           = "Individuals observed; no adult-only restriction stated",
  source_location     = "Abstract; printed p.13523; PDF page 3",
  source_doi          = "10.11609/jott.4026.11.5.13523-13530",
  role                = "primary",
  quality_flag        = ifelse(single,
    "One observed group; table zeros for absent sectors are not zero-sized social groups",
    paste("Overall summary retained as reported; not reproducible exactly from rounded sector means",
          "and Table1 group counts; do not pool sector rows again")),
  stringsAsFactors = FALSE)

## ---- 4. Write the analysis CSV ----
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- 5. Public TSV: Item encoded from the live __ReadMe.xlsx by Item name ----
## Not registered yet; CSV is built regardless and the TSV waits for a registry row.
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
message(item_name, ": ", nrow(final.dataframe), " reported values; ",
        sum(!single), " overall means and ", sum(single), " single observed group")
