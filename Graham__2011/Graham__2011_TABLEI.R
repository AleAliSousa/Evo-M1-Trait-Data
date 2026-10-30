## Graham__2011_TABLEI.R -- frozen snapshot -> analysis CSV + public TSV
##
## Graham, K. L. (2011). Coevolutionary relationship between striatum size and social play
## in nonhuman primates. American Journal of Primatology, 73(4), 314-322. doi:10.1002/ajp.20898
##
## TABLE I (p. 317): 14 primate taxa x {% social play, % nonsocial play, brain size (g),
## body size (g), striatum (mm3), Sources}. The play percentages are means Graham derived
## from the per-row literature listed in the Sources cell (footnote a); brain and body size
## are from Barton [1999] (footnotes b, c) and striatum volume from Stephan et al. [1981]
## (footnote d) -- so every column is republished or compiled, and the item's Data role is
## secondary. The per-row citations are data: they are extracted to
## reference_tables/Graham__2011_TABLEI_references.csv and bind back on sources_printed
## (split on "; ", join on ref_key).
##
## Frozen source: Graham__2011_TABLEI_snapshot.csv, written by Graham__2011_extract_snapshot.R
## from the PDF text layer (no value typed in either script).
##
## A printed en dash in % nonsocial play means the measure was not reported for that taxon
## (Cercocebus albigena, Cercopithecus mitis, Erythrocebus patas) and becomes NA, never 0.
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Graham__2011_TABLEI"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 2. LOAD (frozen snapshot, read positionally as text) -------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, stringsAsFactors = FALSE,
                        colClasses = "character", encoding = "UTF-8", check.names = FALSE)
## printed layout: caption, header, 14 data rows, 6 footnote rows
if (!identical(dim(snap), c(22L, 7L)))
  stop("snapshot shape changed: expected 22 x 7, got ", nrow(snap), " x ", ncol(snap), call. = FALSE)
stopifnot(snap[2, 1] == "Species", snap[2, 7] == "Sources")
dat <- snap[3:16, ]

## 2b. SPECIES (shared resolver; this paper's spoke rows cover the two genus-level labels)
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder), call. = FALSE)
## local = TRUE so the resolver lands in THIS environment: build_dataset_item() runs the
## script with sys.source(envir = new.env(parent = baseenv())), from which globalenv() is
## not on the search path.
source(file.path(base, "_keys", "resolve_species.R"), local = TRUE)

## 3. CLEAN -----------------------------------------------------------
dash <- "\u2013"
num <- function(x) {                       # strip thousands commas; en dash -> NA
  x <- trimws(x)
  out <- suppressWarnings(as.numeric(gsub(",", "", x)))
  out[x %in% c("", dash)] <- NA_real_
  out
}
printed_sp <- trimws(dat[[1]])
res <- resolve_species(printed_sp, source_publication = basename(folder))
if (any(res$unresolved))
  stop("Printed name(s) not resolvable: ", paste(printed_sp[res$unresolved], collapse = "; "),
       " -- add a row to _keys/General/species_key.csv.", call. = FALSE)

src <- trimws(dat[[7]])
keys_of  <- function(s) trimws(strsplit(s, ";", fixed = TRUE)[[1]])
## footnote e = captive study, f = wild study, carried as a superscript on each citation
setting_of <- function(s) {
  k <- keys_of(s)
  e <- any(grepl("e$", k)); w <- any(grepl("f$", k))
  if (e && w) "mixed (captive and wild sources)" else if (e) "captive" else if (w) "wild" else NA_character_
}

final.dataframe <- tibble::tibble(
  species_as_published = printed_sp,
  Species              = res$accepted_name,
  species_basis        = res$species_basis,
  social_play_pct      = num(dat[[2]]),
  nonsocial_play_pct   = num(dat[[3]]),
  brain_mass_g         = num(dat[[4]]),
  brain_mass_mg        = num(dat[[4]]) * 1000,   # project unit for brain weight is mg (HOWTO 6)
  body_mass_g          = num(dat[[5]]),
  striatum_vol_mm3     = num(dat[[6]]),
  sources_printed      = src,
  n_sources_cited      = vapply(src, function(s) length(keys_of(s)), integer(1), USE.NAMES = FALSE),
  study_setting        = vapply(src, setting_of, character(1), USE.NAMES = FALSE),
  data_role            = "secondary",
  source_row           = seq_len(nrow(dat)) + 2L)

stopifnot(nrow(final.dataframe) == 14L,
          sum(is.na(final.dataframe$nonsocial_play_pct)) == 3L,
          !any(is.na(final.dataframe$social_play_pct)),
          !any(is.na(final.dataframe$striatum_vol_mm3)),
          all(final.dataframe$n_sources_cited >= 1L))

## 3b. REFERENCE-TABLE BINDING CHECK -----------------------------------
## Every citation key printed in the Sources column must have exactly one row in the
## item's references table, so the documented join (split on "; ", join on ref_key)
## cannot silently drop a source.
if (file.exists(refs_csv)) {
  refs <- utils::read.csv(refs_csv, stringsAsFactors = FALSE, colClasses = "character",
                          encoding = "UTF-8")
  printed_keys <- unique(unlist(lapply(final.dataframe$sources_printed, keys_of)))
  missing_keys <- setdiff(printed_keys, refs$ref_key)
  if (length(missing_keys))
    stop("Citation key(s) printed in Sources but absent from ", basename(refs_csv), ": ",
         paste(missing_keys, collapse = "; "), call. = FALSE)
  if (anyDuplicated(refs$ref_key))
    stop(basename(refs_csv), " has duplicate ref_key rows", call. = FALSE)
} else warning("references table not found: ", basename(refs_csv))

## 3c. TABLE CHECKS (HOWTO 7a): none -- the table prints no totals, percentages of a
## printed total, or other internal relation that could check itself.

## 4. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, final_csv, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
