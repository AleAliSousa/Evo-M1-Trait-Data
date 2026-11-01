
## Ziege et al. (2016) Table 1 -- frozen printed grid -> population analysis CSV
##
## Source: Ziege, M., Babitsch, D., Brix, M., et al. (2016). Importance of latrine communication in
##   European rabbits shifts along a rural-to-urban gradient. BMC Ecology 16:29.
##   https://doi.org/10.1186/s12898-016-0083-y
## Frozen source: Ziege_etal_2016_Table1_snapshot.csv = Table 1 exactly as printed (the Coordinates
##   header spanning two columns, the Rural / Suburban / Urban section rows, printed site order and
##   the caption), generated from source/PMC4908761.xml by
##   _checks/social_variables/build_population_censuses.py. This script owns the analysis layer.
##
## PRIMARY at the team level but a re-report: the same group published these censuses in 2015
## (10.1111/jzo.12207), which has not been retrieved; both DOIs travel on every row so the team is
## counted once. Age scope is unspecified in the reprinted table.

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

## ---- read the frozen printed grid ----
grid <- utils::read.csv(file.path(item_dir, paste0(folder, "_Table1_snapshot.csv")), header = FALSE,
                        colClasses = "character", check.names = FALSE, na.strings = character(0),
                        encoding = "UTF-8")
if (ncol(grid) != 7L) stop("expected the 7-column printed grid, got ", ncol(grid), call. = FALSE)
if (trimws(grid[1, 1]) != "Study sites" || trimws(grid[1, 7]) != "Mean social group size")
  stop("unexpected printed header in the snapshot", call. = FALSE)

SETTINGS <- c("Rural", "Suburban", "Urban")    # the printed section rows
rows <- list(); setting <- ""
for (i in 2:nrow(grid)) {
  cells <- trimws(as.character(unlist(grid[i, ])))
  if (all(!nzchar(cells[-1]))) {               # section row, or the trailing caption row
    if (cells[1] %in% SETTINGS) setting <- cells[1]
    next
  }
  if (any(!nzchar(cells))) stop("incomplete data row in the snapshot: row ", i, call. = FALSE)
  if (!nzchar(setting)) stop("data row before any Rural/Suburban/Urban section row", call. = FALSE)
  rows[[length(rows) + 1L]] <- data.frame(
    population               = cells[1],
    coordinates              = paste(cells[2], cells[3], sep = "; "),   # printed as two columns
    site_area_ha             = cells[4],
    urbanity                 = cells[5],       # printed with the minus sign U+2212, kept as printed
    population_density_per_ha = cells[6],
    group_size_mean          = as.numeric(cells[7]),
    setting                  = setting,
    stringsAsFactors = FALSE)
}
tab <- do.call(rbind, rows)
if (nrow(tab) != 15L) stop("expected the 15 study sites, got ", nrow(tab), call. = FALSE)

check_species("Oryctolagus cuniculus")
final.dataframe <- data.frame(
  Species = "Oryctolagus cuniculus", tab[, c("population", "coordinates", "site_area_ha", "urbanity",
                                             "population_density_per_ha", "group_size_mean", "setting")],
  source_location     = "Table 1",
  original_source_doi = "10.1111/jzo.12207",
  reporting_source_doi = "10.1186/s12898-016-0083-y",
  role                = "primary",
  provenance          = "Same originating team re-reporting their field census; not an independent 2016 replicate",
  age_scope           = "Unspecified in reprinted table; do not assume adult-only",
  method              = "Behavioral observations and ferrets driving members from burrows",
  quality_flag        = "Underlying 2015 paper not independently retrieved; population summaries retained as reported",
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
