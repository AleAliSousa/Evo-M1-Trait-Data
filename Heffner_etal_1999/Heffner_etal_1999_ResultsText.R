## Heffner_etal_1999_ResultsText.R -- constructed text snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (1999). Sound localization in an
## Old-World fruit bat (Rousettus aegyptiacus): Acuity, use of binaural cues,
## and relationship to vision. J Comp Psychol 113(3):297-306.
## doi:10.1037/0735-7036.113.3.297
##
## No table: the values are printed in running text and legends.
## Heffner_etal_1999_ResultsText_snapshot.csv is a CONSTRUCTED snapshot (one row
## per printed quantitative statement: section, journal page, subject, quantity,
## value and unit exactly as printed, in-text citation, verbatim phrase),
## built by an AI assistant on 2026-10-28 from the PDF text layer and checked
## against 140-150 dpi page renders of pp. 298-306 (the text layer drops en
## dashes and misreads "bats" / "Heffner"). This reader never rewrites it.
##
## data_role: primary = this study's own Rousettus measurements; secondary =
## values the paper cites from other studies (printed citation kept, joined to
## reference_tables/Heffner_etal_1999_ResultsText_references.csv on ref_key
## after splitting citation_as_printed on "; ").

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_1999_ResultsText"
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
stopifnot(nrow(snap) == 29L, !anyDuplicated(snap$statement_id))

## 3. PARSE printed values -> numeric (min/max for ranges) ---------------
## dash = en dash (\u2013) as printed; "approximately" kept as a qualifier.
v <- gsub(",", "", snap$value_as_printed)                     # 9,704 -> 9704
v <- gsub("\u00b1", "", v)                                     # "± 1"  -> " 1"
qual <- ifelse(grepl("or less", v), "upper_bound",
        ifelse(grepl("approximately", v), "approximately", ""))
v <- trimws(gsub("approximately|or less", "", v))
rng <- regmatches(v, regexec("^(?:between )?([0-9.]+)\\s*(?:\u2013|-|to|and)\\s*([0-9.]+)$", v, perl = TRUE))
vmin <- vmax <- val <- rep(NA_real_, length(v))
for (i in seq_along(v)) {
  if (length(rng[[i]]) == 3L) { vmin[i] <- as.numeric(rng[[i]][2]); vmax[i] <- as.numeric(rng[[i]][3]) }
  else { val[i] <- as.numeric(v[i]); if (qual[i] == "upper_bound") { vmax[i] <- val[i]; val[i] <- NA } }
}
stopifnot(all(!is.na(val) | !is.na(vmax)))
## project units: frequencies in kHz (S28 is printed as 500 Hz -> 0.5 kHz)
unit <- snap$unit_as_printed
hz <- unit == "Hz"
val[hz] <- val[hz] / 1000; vmin[hz] <- vmin[hz] / 1000; vmax[hz] <- vmax[hz] / 1000
unit[hz] <- "kHz"
unit[unit == "\u00b0"] <- "deg"

## 4. SPECIES (group statements carry no single species) ----------------
group_subjects <- c("all surface-dwelling mammals (excluding aquatic and subterranean species)",
                    "other megachiropteran bats")
is_group <- snap$subject_as_printed %in% group_subjects
species <- rep(NA_character_, nrow(snap))
species[!is_group] <- resolve(snap$subject_as_printed[!is_group])

## 5. ROLE + CITATIONS --------------------------------------------------
cites <- strsplit(snap$citation_as_printed, "; ", fixed = TRUE)
own_method_cite <- "Kuhn, 1977"                # formula source for S06, not a data source
role <- ifelse(!nzchar(snap$citation_as_printed) | snap$citation_as_printed == own_method_cite,
               "primary", "secondary")
role[snap$statement_id %in% c("S18", "S28")] <- "secondary"   # compiled from Fig. 5 / Fig. 7 sources
all_keys <- setdiff(unique(unlist(cites)), "")
miss <- setdiff(all_keys, refs$ref_key)
if (length(miss)) stop("Citations not in references table: ", paste(miss, collapse = "; "), call. = FALSE)

final.dataframe <- tibble(
  statement_id       = snap$statement_id,
  section            = snap$section,
  journal_page       = as.integer(snap$journal_page),
  subject_as_printed = snap$subject_as_printed,
  species            = species,
  observation_level  = ifelse(is_group, "group_of_species",
                        ifelse(grepl("^Bat [ABC]$", snap$subject_as_printed), "individual",
                        ifelse(snap$statement_id %in% c("S10","S11","S12","S13","S14"), "individual (one retina)", "species"))),
  quantity           = snap$quantity_as_printed,
  value              = val,
  value_min          = vmin,
  value_max          = vmax,
  value_qualifier    = qual,
  unit               = unit,
  value_as_printed   = snap$value_as_printed,
  unit_as_printed    = snap$unit_as_printed,
  condition          = snap$condition_as_printed,
  citation_as_printed = snap$citation_as_printed,
  data_role          = role,
  exclude_flag       = ifelse(snap$statement_id == "S23",
                        "landing error of flying bats, not a minimum audible angle -- do not pool with MAA", "")
)
stopifnot(sum(final.dataframe$data_role == "primary") == 15L)

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
