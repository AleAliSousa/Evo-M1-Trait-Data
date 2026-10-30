## Bahney_vonBartheld_2018_TABLE2.R -- snapshot -> analysis CSV + public TSV
##
## Bahney, J., & von Bartheld, C. S. (2018). The cellular composition and glia-neuron
## ratio in the spinal cord of a human and a nonhuman primate: Comparison with other
## species and brain regions. Anatomical Record, 301(4), 697-710. doi:10.1002/ar.23728
##
## TABLE 2 (PDF p. 703): cell numbers and ratios in the human spinal cord (cell types
## based on morphology), isotropic fractionator and stereology, n = 3 (Results text).
## Snapshot transcribed from the PDF text layer (glyph-mapped: "6" -> "±") and verified
## cell-by-cell against a 3x page render on 2026-10-28 (AI assistant).
## 0. PATHS --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {                       # source() ("ofile") / sys.source() ("file")
    f <- get0("ofile", envir = fr, inherits = FALSE)
    if (is.null(f)) f <- get0("file", envir = fr, inherits = FALSE)
    if (is.character(f) && length(f) == 1L && grepl("\\.R$", f)) return(normalizePath(f))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Bahney_vonBartheld_2018_TABLE2"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 2. LOAD (frozen snapshot, read positionally as text) -------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", encoding = "UTF-8", check.names = FALSE)

## 2b. SPECIES KEY (collection-scoped: _keys/General; source_publication = folder name)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder), call. = FALSE)
lk <- stats::setNames(key$accepted_name, key$variant_name)
harmonise <- function(x) {
  out <- unname(lk[x]); miss <- !is.na(x) & nzchar(x) & is.na(out)
  if (any(miss)) stop("Printed name(s) missing from species_key: ",
                      paste(unique(x[miss]), collapse = "; "), call. = FALSE)
  out
}
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))

## 3. CLEAN -----------------------------------------------------------
## Snapshot layout (positional): two stacked blocks, each = header row, method row,
## Cervical / Thoracic / Lumbar / Total rows. Col 6 (Endo %) is blank in the IF block,
## col 7 holds nNNR +/- SD (IF) or GNR +/- SD (stereology). Last row = abbreviations footnote.
stopifnot(ncol(snap) == 10, nrow(snap) == 13)
pm <- function(x) {                          # "82.7 ± 18.2", "535.5±98.9", "5.3 ± 0. 85"
  p <- strsplit(gsub("\\s", "", x), "\u00b1", fixed = TRUE)
  t(vapply(p, function(v) c(num(v[1]), if (length(v) > 1) num(v[2]) else NA_real_), numeric(2)))
}
rng <- function(x) {                         # "68–103", "1,400–1,900"
  p <- strsplit(x, "\u2013", fixed = TRUE)
  t(vapply(p, function(v) c(num(v[1]), num(v[2])), numeric(2)))
}
method <- NA_character_; recs <- list()
for (i in seq_len(nrow(snap))) {
  c1 <- snap[i, 1]
  if (c1 %in% c("Isotropic fractionator (IF)", "Stereology")) { method <- c1; next }
  if (!c1 %in% c("Cervical (c)", "Thoracic (th)", "Lumbar (lu)", "Total")) next
  is_if <- method == "Isotropic fractionator (IF)"
  cs <- pm(snap[i, 2]); rr <- rng(snap[i, 3]); ra <- pm(snap[i, 7])
  recs[[length(recs) + 1]] <- tibble(
    method = method, segment = c1,
    cells_million = cs[1], cells_sd_million = cs[2],
    range_min_million = rr[1], range_max_million = rr[2],
    nonneuronal_pct = if (is_if) num(snap[i, 4]) else NA_real_,
    glia_pct        = if (is_if) NA_real_ else num(snap[i, 4]),
    neuron_pct      = num(snap[i, 5]),
    endothelial_pct = if (is_if) NA_real_ else num(snap[i, 6]),
    ratio_type = if (is_if) "nNNR" else "GNR",
    ratio = ra[1], ratio_sd = ra[2],
    segment_comparison = na_if(snap[i, 8], ""), p_value = num(snap[i, 9]),
    significant = na_if(snap[i, 10], ""),
    cell_number_printed = snap[i, 2], ratio_printed = snap[i, 7], source_row = i)
}
final.dataframe <- bind_rows(recs) %>%
  mutate(species_as_published = "Homo sapiens",
         Species = harmonise("Homo sapiens"),
         n_specimens = 3L,
         data_role = "primary",
         .before = 1)
stopifnot(nrow(final.dataframe) == 8)

## 3b. TABLE CHECKS (HOWTO 7a) -----------------------------------------
## (i) Cervical + Thoracic + Lumbar = Total for mean cell number (million); tolerance =
##     half a unit of the last printed decimal per summed cell + half a unit of the Total.
## (ii) nN% + Neuron% = 100 (IF) and Glia% + Neuron% + Endo% = 100 (stereology); tolerance =
##     0.05 per printed cell. Mismatches are warned and kept as printed.
dec <- function(s) { s <- sub("\\s*\u00b1.*$", "", gsub(",", "", s)); ifelse(grepl("\\.", s), nchar(sub(".*\\.", "", s)), 0) }
table_checks <- bind_rows(lapply(split(final.dataframe, final.dataframe$method), function(d) {
  seg <- d[d$segment != "Total", ]; tot <- d[d$segment == "Total", ]
  tol <- sum(0.5 * 10^-dec(seg$cell_number_printed)) + 0.5 * 10^-dec(tot$cell_number_printed)
  obs <- sum(seg$cells_million)
  pc <- bind_rows(lapply(seq_len(nrow(d)), function(j) {
    v <- c(d$nonneuronal_pct[j], d$glia_pct[j], d$neuron_pct[j], d$endothelial_pct[j]); v <- v[!is.na(v)]
    tibble(check_id = paste0("pct_sum_", d$method[j], "_", d$segment[j]),
           basis = "percent columns of the row sum to 100", observed = sum(v), printed = 100,
           difference = sum(v) - 100, tolerance = 0.05 * length(v))
  }))
  bind_rows(tibble(check_id = paste0("segment_sum_", d$method[1]),
                   basis = "Cervical + Thoracic + Lumbar vs printed Total (Cell #, million)",
                   observed = obs, printed = tot$cells_million, difference = obs - tot$cells_million,
                   tolerance = tol), pc)
})) %>% mutate(status = ifelse(abs(difference) <= tolerance + 1e-9, "pass", "mismatch"),
               note = "rounding tolerance from printed decimals; values kept as printed")
if (any(table_checks$status == "mismatch"))
  warning("Table check mismatch(es): ", paste(table_checks$check_id[table_checks$status == "mismatch"], collapse = ", "), call. = FALSE)
final.dataframe <- select(final.dataframe, -cell_number_printed)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write_csv(final.dataframe, final_csv, na = "")                       # readr: always UTF-8
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  ## Registry guard (2026-10-28): Sheet1 col A for TABLE 2-4 prints an auto-incremented DOI
  ## (ar.23729 / ar.23730 / ar.23731); the article DOI is 10.1002/ar.23728 (PDF p.697 and the
  ## TABLE 1 row). Until the owner corrects col A, derive the code with the house formula.
  doi_encoded <- "10.1002%2Far.23728"
  if (length(item_encoded) == 1L && !is.na(item_encoded) &&
      !startsWith(item_encoded, paste0(doi_encoded, "_"))) {
    warning("Registry Item encoded '", item_encoded, "' does not carry the article DOI; using ",
            paste0(doi_encoded, "_", sub(".*_", "", item_name)), call. = FALSE)
    item_encoded <- paste0(doi_encoded, "_", sub(".*_", "", item_name))
  }
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
if (exists("table_checks") && any(table_checks$status != "pass"))
  print(as.data.frame(table_checks[table_checks$status != "pass", c("check_id","observed","printed","difference","tolerance","status")]))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
