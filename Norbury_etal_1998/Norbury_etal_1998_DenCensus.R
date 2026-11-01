
## Norbury et al. (1998) ferret den occupancy -- constructed snapshot -> count-frequency CSV
##
## Source: Norbury, G. L., Norbury, D. C., & Heyward, R. P. (1998). Space use and denning behaviour
##   of wild ferrets (Mustela furo) and cats (Felis catus). New Zealand Journal of Ecology 22(2):149-159.
## Frozen source: Norbury_etal_1998_DenCensus_snapshot.csv -- a CONSTRUCTED snapshot holding only
##   PRINTED quantities (41 excavated dens, "Two" shared, "adult males", "May and August") plus the
##   two verbatim p. 154 sentences, checked against source/Norbury_etal_1998.pdf by
##   _checks/social_variables/build_population_censuses.py.
##
## The 39 single-occupant dens are NOT printed in the paper; they are derived here, by subtraction,
## where the derivation is visible per row. No identifiers are invented for individual dens.

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
if (nrow(snap) != 1L) stop("expected one printed passage row, got ", nrow(snap), call. = FALSE)
WORDS <- c(one = 1, two = 2)                   # the paper prints the shared-den count as a word
excavated <- as.numeric(trimws(snap$excavated_dens_as_printed))
shared    <- unname(WORDS[tolower(trimws(snap$shared_dens_as_printed))])
if (is.na(excavated) || is.na(shared)) stop("printed den counts could not be read from the snapshot", call. = FALSE)

check_species("Mustela furo")                  # printed name kept; the key maps it to the project anchor
final.dataframe <- data.frame(
  Species                 = "Mustela furo",
  occupants_per_den       = c(1, 2),
  number_of_excavated_dens = c(excavated - shared, shared),
  derivation              = c(paste0("derived: ", excavated, " excavated dens minus the two printed as shared"),
                              "printed: two dens each contained a collared ferret and another adult male"),
  source_location         = "p.154 Den sharing by ferrets",
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
