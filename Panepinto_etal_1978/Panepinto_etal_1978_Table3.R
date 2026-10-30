## Panepinto_etal_1978_Table1.R -- snapshot -> analysis CSV + public TSV
##
## Panepinto, L. M., Phillips, R. W., Wheeler, L. R., & Will, D. H. (1978).
## The Yucatan miniature pig as a laboratory animal. Laboratory Animal
## Science, 28(3), 308-313. PMID: 682579 (no DOI).
##
## Table 3 (printed p. 312): "Neonatal hematology values of 33 Yucatan
## miniature pigs" -- 11 age classes x 7 measures, each "mean +/- SD";
## the four serum-lipid columns are blank (not measured) for the first
## three age classes -- those blank cells are omitted from the long CSV.
## Source PDF is a scan; the snapshot was transcribed from a 300-dpi render
## of the page and every value cross-checked against the OCR text layer.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Panepinto_etal_1978_Table3"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
tsv_dir <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(readxl)

## 2. LOAD (positional: row 1 caption, row 2 title, row 3 headers) ---
snap <- read_excel(paste0(item_name, "_snapshot.xlsx"), sheet = "Table3",
                   col_names = FALSE, col_types = "text")
hdr  <- unname(unlist(snap[3, ]))
dat  <- snap[4:nrow(snap), ]
dat  <- dat[!is.na(dat[[2]]), ]                       # drops the footnote rows
stopifnot(nrow(dat) == 11, ncol(dat) == 8)

## 3. SPECIES (General key, scoped to this paper folder) --------------
publication <- basename(folder)                       # "Panepinto_etal_1978"
key   <- read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                  stringsAsFactors = FALSE, encoding = "UTF-8")
key_p <- key[key$source_publication == publication, ]
if (nrow(key_p) == 0L)
  stop("No species_key.csv rows for source_publication == \"", publication, "\"", call. = FALSE)
species_as_published <- "Yucatan miniature pig"       # table captions / title (single-species paper)
Species <- key_p$accepted_name[match(tolower(species_as_published), tolower(key_p$variant_name))]
if (is.na(Species)) stop("No species_key row for: ", species_as_published, call. = FALSE)

## 4. CLEAN: footnote marks off, "mean +/- SD" split, long format ----
age_printed <- dat[[1]]
age_mark    <- ifelse(grepl("[ab]$", age_printed), sub("^.*([ab])$", "\\1", age_printed), "")
age_clean   <- gsub("\\s|\\(birth\\)", "", sub("[ab]$", "", age_printed))   # "0(birth)" -> "0"
age_min     <- as.numeric(sub("^([0-9]+).*$", "\\1", age_clean))
age_max     <- as.numeric(sub("^.*[^0-9]([0-9]+)$|^([0-9]+)$", "\\1\\2", age_clean))

## printed header -> analysis variable, project unit and conversion factor
vars <- data.frame(
  col      = 2:8,
  variable = c("PlasmaGlucose.mg_dl", "PlasmaProtein.g_dl", "PackedCellVolume.pct",
               "SerumCholesterol.mg_dl", "SerumCholesterolEster.mg_dl",
               "SerumPhospholipids.mg_dl", "SerumTriglycerides.mg_dl"),
  unit_printed = c("mg/dl", "g/dl", "%", "mg/dl", "mg/dl", "mg/dl", "mg/dl"),
  factor   = 1,                         # clinical-chemistry units kept as printed (no project unit)
  stringsAsFactors = FALSE)

final.dataframe <- do.call(rbind, lapply(seq_len(nrow(vars)), function(i) {
  keep <- !is.na(dat[[vars$col[i]]]) & nzchar(trimws(dat[[vars$col[i]]]))   # blank = not measured
  v    <- dat[[vars$col[i]]][keep]
  mark <- ifelse(grepl("[0-9][ab]$", v), sub("^.*([ab])$", "\\1", v), "")
  core <- sub("([0-9])[ab]$", "\\1", v)
  if (!all(grepl("\u00b1", core, fixed = TRUE))) stop("cell without '\u00b1' (mean +/- SD expected)", call. = FALSE)
  m    <- as.numeric(sub("^\\s*([0-9.]+).*$", "\\1", core))          # number before the +/- sign
  s    <- as.numeric(sub("^.*[^0-9.]([0-9.]+)\\s*$", "\\1", core))   # number after the +/- sign
  data.frame(
    Species = Species, species_as_published = species_as_published,
    age_days_as_printed = age_printed[keep], age_min_days = age_min[keep], age_max_days = age_max[keep],
    variable = vars$variable[i], header_as_printed = gsub("\n", " ", hdr[vars$col[i]]),
    value_as_printed = v,
    mean = m * vars$factor[i], sd = s * vars$factor[i],
    unit_printed = vars$unit_printed[i],
    footnote_marks = trimws(paste(ifelse(nzchar(age_mark[keep]), paste0("age:", age_mark[keep]), ""),
                                  ifelse(nzchar(mark), paste0("value:", mark), ""))),
    n_animals = 33L,   # caption "33 Yucatan miniature pigs"; per-age n not printed
    observation_level = "age-class group mean +/- SD (blood sampled alternately from the two halves of the 33-piglet growth group; not a species mean)",
    source_location = "Table 3, printed p. 312",
    data_role = "primary",
    stringsAsFactors = FALSE, check.names = FALSE)
}))
if (anyNA(final.dataframe$mean) || anyNA(final.dataframe$sd))
  stop("Unparsed mean/SD cell in snapshot", call. = FALSE)
stopifnot(nrow(final.dataframe) == 11 * 3 + 8 * 4)   # 3 columns x 11 ages + 4 lipid columns x 8 ages

## 5. WRITE CSV + PUBLIC TSV ------------------------------------------
readr::write_csv(final.dataframe, paste0(item_name, ".csv"), na = "")   # readr always writes UTF-8 (locale-independent)
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded)) {
    ## registry row not pasted yet: derive with the Sheet1 col-I/K formula from this item's registry_row.xlsx
    rr <- read_excel(file.path(folder, paste0(item_name, "_registry_row.xlsx")), sheet = "Registry_row", col_types = "text")
    enc <- function(x) gsub(">", "%3E", gsub("<", "%3C", gsub(":", "%3A", gsub("/", "%2F", x, fixed = TRUE), fixed = TRUE), fixed = TRUE), fixed = TRUE)
    item_encoded <- paste0(enc(rr[[3]][1]), "_", gsub("[ _\u00a0]", "", rr[[4]][1]))
    warning("No registry row for ", item_name, " -- Item encoded derived from registry_row.xlsx: ",
            item_encoded, call. = FALSE)
  }
  if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
    stop("No usable 'Item encoded' for ", item_name, " -- refusing to write NA.tsv.", call. = FALSE)
  readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(item_name, ": ", nrow(final.dataframe), " rows written")
