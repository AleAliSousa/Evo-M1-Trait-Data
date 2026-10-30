## Heffner_Heffner_1992_b_TABLE34.2.R -- snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., & Heffner, H. E. (1992). Evolution of sound localization in
## mammals. In The evolutionary biology of hearing (pp. 691-715). Springer.
## doi:10.1007/978-1-4612-2784-7_43
##
## Table 34.2 (p. 696): 20 species grouped by ability to use the two binaural
## locus cues, with the source study for each species. SECONDARY: every row
## is a categorical result cited from an earlier study (Source column); the
## printed key is kept verbatim and bound to the bibliography through
## reference_tables/Heffner_Heffner_1992_b_TABLE34.2_references.csv
## (join on ref_key = source_as_printed).
##
## Snapshot transcribed by an AI assistant (2026-10-28) from a 250-dpi render
## of PDF p. 6 (the text layer renders the Greek group labels as "~e", "~J",
## "M", "~fi"). Group labels kept exactly as printed, including the
## notational switch in the last group ("Delta t or Delta fi" vs
## "Delta theta / Delta I" above).

## 0. PATHS --------------------------------------------------------
.sp <- local({
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_Heffner_1992_b_TABLE34.2"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## UTF-8 output even under Rscript in a C locale (printed names carry Greek/µ/’)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv, rows with
## source_publication == this folder's name). No mapping is hand-coded here.
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder),
       "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ",
                        paste(bad, collapse = "; "), call. = FALSE)
  out
}

## 2. LOAD -------------------------------------------------------------
snap <- read.csv(snapshot_csv, colClasses = "character", encoding = "UTF-8", check.names = FALSE)
refs <- read.csv(refs_csv, colClasses = "character", encoding = "UTF-8")
stopifnot(identical(names(snap), c("Ability", "Species", "Source")), nrow(snap) == 24L)

## 3. CLEAN: carry the printed group heading down onto its species rows --
grp <- snap$Ability; grp[!nzchar(grp)] <- NA
cur <- NA_character_; g <- character(nrow(snap))
for (i in seq_len(nrow(snap))) { if (!is.na(grp[i])) cur <- grp[i]; g[i] <- cur }
snap$group_as_printed <- g
rows <- snap[nzchar(snap$Species), ]
stopifnot(nrow(rows) == 20L)
## coded cue use, read from the printed heading (no inference beyond it)
## (\u escapes: Delta = \u0394, theta = \u03b8 -- keeps the script locale-independent)
code <- setNames(c("both", "time_cue_reduced_or_absent", "intensity_cue_reduced_or_absent", "neither"),
                 c("Use both \u0394\u03b8 and \u0394I",
                   "Ability to use \u0394\u03b8 reduced or absent",
                   "Ability to use \u0394I reduced or absent",
                   "Unable to use \u0394t or \u0394fi"))
stopifnot(all(rows$group_as_printed %in% names(code)))
## every printed source key must exist in the references table
stopifnot(all(rows$Source %in% refs$ref_key))

final.dataframe <- tibble(
  species_row        = seq_len(nrow(rows)),
  animal_as_printed  = rows$Species,
  species            = resolve(rows$Species),
  binaural_cue_group_as_printed = rows$group_as_printed,
  binaural_cue_use   = unname(code[rows$group_as_printed]),
  uses_time_cue      = unname(c(both = "yes", time_cue_reduced_or_absent = "reduced_or_absent",
                                intensity_cue_reduced_or_absent = "yes", neither = "no")[code[rows$group_as_printed]]),
  uses_intensity_cue = unname(c(both = "yes", time_cue_reduced_or_absent = "yes",
                                intensity_cue_reduced_or_absent = "reduced_or_absent", neither = "no")[code[rows$group_as_printed]]),
  source_as_printed  = rows$Source,
  data_role          = "secondary"
)

## WRITE CSV + PUBLIC TSV ---------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
