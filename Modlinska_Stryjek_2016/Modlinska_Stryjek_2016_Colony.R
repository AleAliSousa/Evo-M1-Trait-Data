
## Modlinska & Stryjek (2016) wild rat colony estimate -- constructed snapshot -> analysis CSV
##
## Source: Modlinska, K., & Stryjek, R. (2016). Food neophobia in wild rats (Rattus norvegicus)
##   inhabiting a changeable environment - a field study. PLoS ONE 11(5):e0156741.
##   https://doi.org/10.1371/journal.pone.0156741
## Frozen source: Modlinska_Stryjek_2016_Colony_snapshot.csv -- a CONSTRUCTED snapshot, because the
##   value is stated in prose (Materials and Methods, "Animals"), not tabulated: the printed wording
##   ("approx. 50 individuals") with the verbatim sentence and the method sentence beside it,
##   extracted from source/PMC4890768.xml by _checks/social_variables/build_population_censuses.py.
##
## PRIMARY but approximate: a whole-colony population estimate for one free-living farm colony, not
## a head count and not a social-subgroup mean. The colony may hold several social subgroups.

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
folder    <- basename(item_dir)              # species_key source_publication for this paper
item_name <- sub("\\.R$", "", basename(.sp))
csv_path  <- file.path(item_dir, paste0(item_name, ".csv"))
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## ---- species guard: every printed name must resolve through this paper's key rows ----
source(file.path(root, "_keys", "resolve_species.R"))
check_species <- function(printed) {
  key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), stringsAsFactors = FALSE,
                         check.names = FALSE, encoding = "UTF-8")
  if (sum(trimws(key$source_publication) == folder) == 0L)
    stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
  rs <- resolve_species(printed, source_publication = folder)
  if (any(rs$unresolved))
    stop("printed names that do not resolve: ", paste(unique(printed[rs$unresolved]), collapse = ", "), call. = FALSE)
  invisible(rs)
}

snap <- utils::read.csv(file.path(item_dir, paste0(item_name, "_snapshot.csv")), colClasses = "character",
                        check.names = FALSE, na.strings = character(0), encoding = "UTF-8")
if (nrow(snap) != 1L) stop("expected the single reported estimate, got ", nrow(snap), call. = FALSE)
printed <- trimws(snap$colony_size_as_printed)
if (!grepl("^approx\\. [0-9]+ individuals$", printed))
  stop("printed colony size is no longer 'approx. N individuals': ", printed, call. = FALSE)

check_species("Rattus norvegicus")
final.dataframe <- data.frame(
  Species              = "Rattus norvegicus",
  colony_size_estimate = as.numeric(sub("^approx\\. ([0-9]+) individuals$", "\\1", printed)),
  approximate          = TRUE,                 # the printed "approx." is kept as a flag
  population           = "Farm on outskirts of Warsaw, Poland",
  statistic            = "approximate whole-colony population estimate",
  method               = "Six months camera traps plus burrows, paths, droppings and bait consumption; also prior same-team study",
  age_scope            = "not specified",
  source_location      = "Materials and Methods: Animals",
  source_doi           = "10.1371/journal.pone.0156741",
  role                 = "primary",
  quality_flag         = "Population colony may contain multiple social subgroups; not a census-derived social-group mean",
  stringsAsFactors = FALSE)

## ---- write the analysis CSV ----
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- public TSV: Item encoded from the live __ReadMe.xlsx, by Item name ----
## Unregistered items are built anyway: the CSV is written and the TSV waits for a registry row
## (an "NA.tsv" would be worse than none).
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
message(item_name, ": ", nrow(final.dataframe), " rows written to ", basename(csv_path))
