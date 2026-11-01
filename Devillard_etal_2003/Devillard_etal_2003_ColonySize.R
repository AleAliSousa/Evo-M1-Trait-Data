
## Devillard et al. (2003) feral cat colony size -- constructed snapshot -> analysis CSV
##
## Source: Devillard, S., Say, L., & Pontier, D. (2003). Dispersal pattern of domestic cats
##   (Felis catus) in a promiscuous urban population: do females disperse or die?
##   Journal of Animal Ecology 72:203-211. https://doi.org/10.1046/j.1365-2656.2003.00692.x
## Frozen source: Devillard_etal_2003_ColonySize_snapshot.csv -- a CONSTRUCTED snapshot, because the
##   value is stated in prose (Materials and methods, first paragraph, printed p. 204): the printed
##   wording ("70 feral cats") with the three verbatim passages, each checked against the source PDF
##   by build_colony_size.py.
##
## PRIMARY: one monitored high-density urban colony, explicitly described by the authors as a single
## stable social group. Not a species mean; density varied between years; no age restriction stated.

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
if (nrow(snap) != 1L) stop("expected the single reported value, got ", nrow(snap), call. = FALSE)
printed <- trimws(snap$colony_size_as_printed)
if (!grepl("^[0-9]+ feral cats$", printed))
  stop("printed colony size is no longer 'N feral cats': ", printed, call. = FALSE)
n_cats <- as.numeric(sub("^([0-9]+) feral cats$", "\\1", printed))

check_species("Felis catus")
final.dataframe <- data.frame(
  Species              = "Felis catus",
  colony_size_reported = n_cats,
  statistic            = "reported study-colony population size",
  population           = "Croix-rousse hospital park, Lyon, France",
  setting              = "free-ranging feral domestic cats; provisioned with canteen waste",
  age_scope            = paste0("No age restriction specified for the reported ", n_cats),
  n_social_groups      = 1,                    # the authors describe the colony as one social group
  source_location      = "Materials and methods: monitored population",
  source_doi           = "10.1046/j.1365-2656.2003.00692.x",
  role                 = "primary",
  quality_flag         = paste("One high-density urban colony; not a species mean; population density varied",
                               "by year; paper explicitly describes these cats as one stable social group"),
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
