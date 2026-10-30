## Bahney_vonBartheld_2018_TABLE3.R -- snapshot -> analysis CSV + public TSV
##
## Bahney, J., & von Bartheld, C. S. (2018). Anatomical Record, 301(4), 697-710.
## doi:10.1002/ar.23728
##
## TABLE 3 (PDF p. 704): glia-neuron ratios (GNRs) for cerebral cortex, cerebellum and
## spinal cord in different vertebrate species -- a literature COMPILATION (secondary) plus
## the paper's own two spinal-cord rows ("This Study"). Per-row sources are in the References
## column; resolve them with reference_tables/Bahney_vonBartheld_2018_TABLE3_references.csv
## (join analysis$references == ref_key). Snapshot built from PDF word coordinates (column
## binning) and verified row-by-row against a 3x page render on 2026-10-28 (AI assistant).
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Bahney_vonBartheld_2018_TABLE3"
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
## Snapshot layout (positional): row 1 = printed header; section rows "Cerebral cortex",
## "Cerebellum", "Spinal Cord" (other cells blank); data rows; last row = table footnote.
## Parentheses = "estimated numerical values or most likely species names (when not disclosed
## in the original publication)" (footnote) -> *_estimated flags; Latin name kept as printed.
stopifnot(ncol(snap) == 5, nrow(snap) == 48)
val <- function(x) {                       # "(0.1)", "86–96", "(90–97)", "∼2.0", "0.29–0.42"
  s <- trimws(x); est <- grepl("^\\(.*\\)$", s); approx <- grepl("^\u223c", s)
  s <- gsub("[()\u223c]", "", s); p <- strsplit(s, "\u2013", fixed = TRUE)
  lo <- vapply(p, function(v) if (length(v)) num(v[1]) else NA_real_, numeric(1))
  hi <- vapply(p, function(v) if (length(v) > 1) num(v[2]) else if (length(v)) num(v[1]) else NA_real_, numeric(1))
  tibble(min = lo, max = hi, mid = ifelse(is.na(lo), NA_real_, (lo + hi) / 2),
         estimated = est & nzchar(s), approximate = approx)
}
own_study <- c("This Study", "This study", "Current study")
section <- NA_character_; recs <- list()
for (i in 2:nrow(snap)) {
  r <- snap[i, ]
  if (all(r[2:5] == "") && r[1] %in% c("Cerebral cortex", "Cerebellum", "Spinal Cord")) { section <- r[[1]]; next }
  if (r[[3]] == "") next                                 # footnote row
  bw <- val(r[[3]]); g <- val(r[[4]])
  latin <- r[[2]]; variant <- if (nzchar(latin)) latin else r[[1]]
  recs[[length(recs) + 1]] <- tibble(
    cns_part = section, common_name = r[[1]],
    species_as_published = na_if(latin, ""), species_variant_matched = variant,
    brain_weight_printed = r[[3]],
    brain_mass_mg_min = bw$min * 1000, brain_mass_mg_max = bw$max * 1000,   # g -> mg (x 1000)
    brain_mass_mg = bw$mid * 1000, brain_mass_estimated = bw$estimated,
    GNR_printed = r[[4]], GNR_min = g$min, GNR_max = g$max, GNR = g$mid, GNR_estimated = g$estimated,
    references = r[[5]],
    data_role = ifelse(r[[5]] %in% own_study, "primary", "secondary"),
    source_row = i)
}
final.dataframe <- bind_rows(recs) %>%
  mutate(Species = harmonise(species_variant_matched), .after = species_as_published)
stopifnot(nrow(final.dataframe) == 43)

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
