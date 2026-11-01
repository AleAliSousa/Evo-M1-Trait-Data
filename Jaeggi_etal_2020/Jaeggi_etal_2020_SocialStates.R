
## Jaeggi et al. (2020) species state sets -- population analysis CSV -> species summary CSV
##
## Depends on Jaeggi_etal_2020_Populations.csv (run Jaeggi_etal_2020_Populations.R first).
## The summary is the SET of states reported across that species' populations, unioned and never
## averaged or reduced to a first/modal state; n_population_records counts records, not animals.

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

## ---- read the sibling population table ----
pop <- utils::read.csv(file.path(item_dir, paste0(folder, "_Populations.csv")), stringsAsFactors = FALSE,
                       check.names = FALSE, colClasses = "character", na.strings = character(0),
                       encoding = "UTF-8")
if (nrow(pop) != 245L) stop("expected 245 population records, got ", nrow(pop), call. = FALSE)

usort <- function(x) sort(unique(x), method = "radix")   # byte order, stable across locales
sp <- usort(pop$Species)
final.dataframe <- do.call(rbind, lapply(sp, function(s) {
  r <- pop[pop$Species == s, , drop = FALSE]
  data.frame(Species               = s,
             social_states         = paste(usort(r$social_state), collapse = " | "),
             n_population_records  = nrow(r),
             population_ids        = paste(r$population_id, collapse = "; "),
             supporting_references = paste(usort(r$supporting_references), collapse = "; "),
             role                  = "secondary",
             statistic             = "set of reported population states; not a modal species classification",
             stringsAsFactors = FALSE)
}))
if (nrow(final.dataframe) != 100L) stop("expected 100 species, got ", nrow(final.dataframe), call. = FALSE)

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
