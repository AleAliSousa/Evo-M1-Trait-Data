
## Mangold-Wirz (1966) Table I -- checked transcription -> analysis CSV -> public TSV
##
## Source: Mangold-Wirz, K. (1966). Cerebralisation und Ontogenesemodus bei Eutherien.
##   Acta Anatomica 63:449-508. https://doi.org/10.1159/000142809
## Frozen source: MangoldWirz__1966_TableI_source.tsv -- the checked transcription of the printed
##   table (page, group, printed species, printed body and brain masses, printed TI, source flag).
## Replaces the Table I half of build_tables.py, which wrote this CSV and its TSV from Python.
##
## DATA ROLE: the table is a COMPILATION. Only the three rows flagged author_own are primary; every
## other row restates Stephan's or another author's measurement, so data_role = secondary and no row
## is merge_eligible -- the values are a roadmap back to the originating sources, not new data.
## Species names are kept exactly as printed: this paper has no curated species_key rows yet, so no
## harmonisation is attempted here (a later key pass can add them).
## printed mass -> grams. Only a SCALAR printed mass becomes a mergeable number: anything with a
## range, a "to", or parentheses stays source text and yields an empty cell (the printed string is
## preserved in the *_as_printed column beside it). "kg" is converted; a bare number is grams.
mass_g <- function(raw) {
  raw <- trimws(as.character(raw)); raw[is.na(raw)] <- ""
  out <- rep("", length(raw))
  ok  <- nzchar(raw) & !grepl("[-\u2013\u2014()]|\\bto\\b", raw)
  m   <- regmatches(raw, regexec("^([0-9]+(?:\\.[0-9]+)?)\\s*(kg|g)?$", raw))
  for (i in which(ok)) {
    if (length(m[[i]]) != 3L) next
    v <- as.numeric(m[[i]][2]) * if (identical(m[[i]][3], "kg")) 1000 else 1
    out[i] <- sprintf("%.12g", v)
  }
  out
}

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

src <- utils::read.delim(file.path(item_dir, paste0(item_name, "_source.tsv")), quote = "",
                         colClasses = "character", check.names = FALSE, na.strings = character(0),
                         encoding = "UTF-8")
if (nrow(src) != 212L) stop("expected 212 printed rows, got ", nrow(src), call. = FALSE)

own <- src$source_flag == "author_own"
final.dataframe <- data.frame(
  source_row = seq_len(nrow(src)), src,
  species        = src$species_as_printed,
  body_weight_g  = mass_g(src$body_as_printed),
  brain_weight_g = mass_g(src$brain_as_printed),
  TI             = src$TI_as_printed,
  merge_eligible = "FALSE",
  data_role      = ifelse(own, "primary", "secondary"),
  stringsAsFactors = FALSE, check.names = FALSE)
if (sum(own) != 3L) stop("expected 3 author_own rows, got ", sum(own), call. = FALSE)

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
