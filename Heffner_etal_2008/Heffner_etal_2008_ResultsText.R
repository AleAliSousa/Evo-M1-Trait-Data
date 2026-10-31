## Heffner_etal_2008_ResultsText.R -- constructed snapshot -> analysis CSV + public TSV
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2008). Sound localization
## acuity and its relation to vision in large and small fruit-eating bats:
## II. Non-echolocating species, Eidolon helvum and Cynopterus brachyotis.
## Hearing Research, 241, 80-86. doi:10.1016/j.heares.2008.05.001
##
## The values of this item are published only in the Results prose
## (sections 3.1 and 3.2, printed pp. 83-84), not in any table. The frozen
## source is therefore a CONSTRUCTED snapshot, one row per reported value
## with the verbatim sentence and printed page, built by
## Heffner_etal_2008_ResultsText_extract_snapshot.R from the PDF text layer.
## This script reads that frozen file and develops it; it never rebuilds it.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Heffner_etal_2008_ResultsText"
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
library(tidyverse)
library(readxl)

## 2. LOAD THE FROZEN CONSTRUCTED SNAPSHOT ---------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                 colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 11L,
          all(c("row","section","printed_page","pdf_page","species_as_printed",
                "quantity_as_printed","value_printed","units_printed","qualifier",
                "verbatim_sentence") %in% names(snap)))

## 3. SPECIES (collection key is the single source of truth) ---------
key_file <- if (!is.na(base)) file.path(base, "_keys", "General", "species_key.csv") else NA
if (is.na(key_file) || !file.exists(key_file))
  stop("General collection species key not found.", call. = FALSE)
key <- read.csv(key_file, colClasses = "character", check.names = FALSE, encoding = "UTF-8")
key <- key[key$source_publication == "Heffner_etal_2008", , drop = FALSE]
if (nrow(key) == 0L)
  stop("No _keys/General/species_key.csv rows for source_publication == \"Heffner_etal_2008\"; ",
       "key rows are scoped to the paper folder name.", call. = FALSE)
## The prose abbreviates the genus ("E. helvum"); the binomial is printed in
## full in Table 1 and in the title. Expansion is by first letter of genus
## against the key's accepted names -- no name is invented here.
expand <- function(abbrev) {
  vapply(abbrev, function(a) {
    if (a == "") return(NA_character_)
    parts <- str_split(a, " ", n = 2)[[1]]
    hit <- key$accepted_name[str_starts(key$accepted_name, str_sub(parts[1], 1, 1)) &
                             str_ends(key$accepted_name, parts[2])]
    if (length(unique(hit)) != 1L)
      stop("Abbreviated prose name '", a, "' does not resolve to exactly one key entry.", call. = FALSE)
    unique(hit)
  }, character(1), USE.NAMES = FALSE)
}
split_species <- str_split(snap$species_as_printed, "; ")
Species <- vapply(split_species, function(v) paste(expand(v), collapse = "; "), character(1))

## 4. DEVELOP --------------------------------------------------------
## Word-numbers printed in the prose ("the two E. helvum", "retinae of one
## E. helvum") become integers; "n.a." stays missing with the printed token kept.
word_number <- c(one = 1, two = 2, three = 3, four = 4, five = 5,
                 six = 6, seven = 7, eight = 8, nine = 9, ten = 10)
to_number <- function(x) {
  x <- str_squish(x)
  out <- suppressWarnings(as.numeric(x))
  w <- is.na(out) & x %in% names(word_number)
  out[w] <- unname(word_number[x[w]])
  out
}

final.dataframe <- tibble(
  species_as_published = snap$species_as_printed,
  Species              = Species,
  value_row            = as.integer(snap$row),
  results_section      = snap$section,
  quantity             = snap$quantity_as_printed,
  value                = to_number(snap$value_printed),
  value_printed        = snap$value_printed,
  units                = snap$units_printed,
  value_qualifier      = snap$qualifier,
  is_approximate       = snap$qualifier == "approximate" | snap$qualifier == "approximately",
  reported_as_absent   = snap$value_printed == "n.a.",
  source_printed_page  = snap$printed_page,
  source_pdf_page      = as.integer(snap$pdf_page),
  verbatim_sentence    = snap$verbatim_sentence,
  data_role            = "primary",
  source               = "this study"
)
stopifnot(nrow(final.dataframe) == 11L,
          sum(is.na(final.dataframe$value)) == sum(final.dataframe$reported_as_absent))

## 5. CROSS-ITEM CHECK (sec 7a) ---------------------------------------
## The two minimum audible angles are the only values of this item that are
## also printed in Table 1, which is built separately in this folder. They
## must agree exactly: the prose and the table are the same measurement.
t1 <- file.path(folder, "Heffner_etal_2008_Table1.csv")
if (file.exists(t1)) {
  tab <- read.csv(t1, stringsAsFactors = FALSE)
  maa <- final.dataframe %>%
    filter(str_detect(quantity, "minimum audible angle")) %>%
    mutate(table1 = tab$localization_threshold_deg[match(Species, tab$binomial)])
  table_checks <- tibble(
    check_id  = paste0("maa_vs_Table1_", str_replace_all(maa$Species, " ", "_")),
    basis     = "minimum audible angle reported in Results section 3.1 vs the same species' value printed in Table 1",
    observed  = maa$value,
    printed   = maa$table1,
    tolerance = 0,
    note      = "same measurement published twice in the same paper"
  ) %>% mutate(difference = observed - printed,
               status = ifelse(!is.na(difference) & abs(difference) <= tolerance, "pass",
                        ifelse(is.na(difference), "not_evaluable", "mismatch"))) %>%
    select(check_id, basis, observed, printed, difference, tolerance, status, note)
  if (any(table_checks$status == "mismatch"))
    warning("Results-prose MAA disagrees with Table 1; printed values kept as printed.")
  message(sprintf("table_checks: %d pass, %d mismatch, %d not_evaluable",
                  sum(table_checks$status == "pass"), sum(table_checks$status == "mismatch"),
                  sum(table_checks$status == "not_evaluable")))
} else {
  table_checks <- NULL
  warning("Heffner_etal_2008_Table1.csv not found; the MAA cross-check was not run.")
}

## 6. WRITE CSV + PUBLIC TSV ------------------------------------------
## readr writers always emit UTF-8; base write.csv would degrade the printed
## degree signs in verbatim_sentence to "<U+00B0>" under a C locale.
write_csv(final.dataframe, final_csv, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(sprintf("%s: %d rows written", item_name, nrow(final.dataframe)))
