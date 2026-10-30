## Dom_etal_1971_motormapCST.R -- constructed text snapshot -> analysis CSV + public TSV
##
## Dom, R., Martin, G. F., Fisher, B. L., Fisher, A. M., & Harting, J. K. (1971). The motor
## cortex and corticospinal tract of the armadillo (Dasypus novemcinctus). Journal of the
## Neurological Sciences, 14(2), 225-236. doi:10.1016/0022-510X(71)90092-X
##
## No table: the item is the motor map (Fig. 2 + stimulation text) and the corticospinal-tract
## (CST) degeneration results, transcribed sentence-by-sentence into
## Dom_etal_1971_motormapCST_snapshot.csv from 2x page renders of the scanned PDF (the OCR
## text layer is unreliable: e.g. "Woofsey", "t~m"); AI assistant, 2026-10-28.
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Dom_etal_1971_motormapCST"
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
## Constructed snapshot from text/figure legend (no published table): one row per trait
## statement with the printed value, unit, page and the verbatim passage it was read from.
snap <- utils::read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                 colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 42)
rng <- function(v) {                                   # "3–5", "0.25–0.3", ">0.7", "up to 27"
  s <- gsub("^(approximately|around|up to) ", "", v); s <- sub("^>", "", s)
  p <- strsplit(s, "\u2013", fixed = TRUE)
  lo <- vapply(p, function(x) num(x[1]), numeric(1)); hi <- vapply(p, function(x) num(x[length(x)]), numeric(1))
  list(lo = lo, hi = hi)
}
is_num <- nzchar(snap$unit) & snap$unit != "Rexed lamina"
r <- rng(snap$value_printed)
final.dataframe <- tibble(
  species_as_published = "Dasypus novemcinctus",          # title / Introduction (no per-row name)
  Species = harmonise("Dasypus novemcinctus"),
  trait = snap$trait, section = snap$section, page = snap$page,
  value_printed = snap$value_printed, unit_printed = na_if(snap$unit, ""),
  value_min = ifelse(is_num, r$lo, NA_real_), value_max = ifelse(is_num, r$hi, NA_real_),
  qualifier = case_when(grepl("^>", snap$value_printed) ~ "greater than",
                        grepl("^up to", snap$value_printed) ~ "maximum",
                        grepl("^(approximately|around)", snap$value_printed) ~ "approximate",
                        is_num & grepl("\u2013", snap$value_printed) ~ "range",
                        is_num ~ "as printed", TRUE ~ "categorical"),
  value_type = ifelse(is_num, "numeric", "categorical"),
  cited_source = ifelse(grepl("Harting and Martin 1970", snap$value_printed), "Harting and Martin 1970", NA_character_),
  data_role = ifelse(is.na(cited_source), "primary", "secondary"),
  passage = snap[["passage (verbatim, as printed)"]],
  source_row = as.integer(snap$row))
## units: thresholds mA, sizes um, thickness mm, body weight kg -> g (project unit)
kg <- final.dataframe$unit_printed %in% "kg"
final.dataframe$value_min[kg] <- final.dataframe$value_min[kg] * 1000
final.dataframe$value_max[kg] <- final.dataframe$value_max[kg] * 1000
final.dataframe$unit <- ifelse(kg, "g", final.dataframe$unit_printed)
final.dataframe <- relocate(final.dataframe, unit, .after = value_max)

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
write_csv(final.dataframe, final_csv, na = "")                       # readr: always UTF-8
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]

  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
if (exists("table_checks") && any(table_checks$status != "pass"))
  print(as.data.frame(table_checks[table_checks$status != "pass", c("check_id","observed","printed","difference","tolerance","status")]))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
