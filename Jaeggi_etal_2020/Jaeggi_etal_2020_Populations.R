
## Jaeggi et al. (2020) population records -- frozen author workbook -> population analysis CSV
##
## Source: Jaeggi, A. V., Miles, M. I., Festa-Bianchet, M., et al. (2020). Variable social
##   organization is ubiquitous in Artiodactyla and probably evolved from pair-living ancestors.
##   Proc R Soc B 287:20200035. https://doi.org/10.1098/rspb.2020.0035
## Frozen source: Jaeggi_etal_2020_Populations_snapshot.xlsx = the author's
##   Artiodactyla_Dataset_corrected_11Mar.xlsx, byte-identical to the copy inside
##   source/author_workbook_original.zip (frozen by _checks/social_variables/build_population_censuses.py,
##   which keeps the snapshot and the readable sheet twin; this script owns the analysis layer).
##
## SECONDARY: 245 population classifications compiled from primary field studies, not new
## observations. The sex-composition codes are categories, not group counts; references are kept
## per row and primary-paper verification is still pending.

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

## ---- read the frozen workbook sheet (headers on row 7, records from row 8, first 30 columns) ----
snap <- as.data.frame(readxl::read_excel(file.path(item_dir, paste0(folder, "_Populations_snapshot.xlsx")),
                                         sheet = "Population data for analysis", col_names = FALSE,
                                         .name_repair = "minimal"), stringsAsFactors = FALSE)
hdr  <- as.character(unlist(snap[7, 1:30]))
body <- snap[8:nrow(snap), 1:30, drop = FALSE]
names(body) <- hdr
source_row <- 8:nrow(snap)                      # the workbook's own row numbers
keep <- !is.na(body[[1]]) & nzchar(trimws(as.character(body[[1]])))
body <- body[keep, , drop = FALSE]; source_row <- source_row[keep]
if (nrow(body) != 245L) stop("expected 245 population records, got ", nrow(body), call. = FALSE)

chr <- function(x) { x <- as.character(x); x[is.na(x)] <- ""; trimws(x) }
printed_species <- gsub("_", " ", chr(body$Genus_species))
check_species(printed_species)                   # identity guard; the printed name is kept below

## ---- population rows (printed names kept; no phylogenetic proxy substitutions) ----
final.dataframe <- data.frame(
  Species               = printed_species,
  population_id         = paste0("Jaeggi2020_row", source_row),
  population            = chr(body$Population),
  subspecies_printed    = chr(body$Subspecies),
  social_state          = chr(body$`Social state - for R`),
  detailed_state        = chr(body$`VASO - for R`),
  supporting_references = chr(body$References),
  role                  = "secondary",
  primary_paper_verified = FALSE,
  age_scope             = "adult male-female social organization",
  quality_flag          = "Compiler classification from cited field papers; not a numerical group count",
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
