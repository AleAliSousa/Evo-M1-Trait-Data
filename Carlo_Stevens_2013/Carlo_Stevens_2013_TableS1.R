## Carlo_Stevens_2013_TableS1.R -- snapshot -> analysis CSV + public TSV
##
## Carlo, C. N., & Stevens, C. F. (2013). Structural uniformity of neocortex, revisited.
## PNAS 110(4), 1488-1493. doi:10.1073/pnas.1221398110
##
## Table S1 "Species characteristics" (Supporting Information pnas.201221398si.pdf, p. 1):
## one row per specimen (species, sex, age, cut section thickness, brain regions sampled).
## Snapshot transcribed from the SI text layer and verified against a 2.5x render on
## 2026-10-28 (AI assistant). The 24 non-frontal specimen x region combinations are the 24
## points of Figure 2.
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Carlo_Stevens_2013_TableS1"
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
## Snapshot: row 1 = printed header, 7 specimen rows, last row = abbreviation footnote.
stopifnot(ncol(snap) == 7, nrow(snap) == 9)
d <- snap[2:8, ]
final.dataframe <- tibble(
  species_as_published = d[[1]], Species = harmonise(d[[1]]), common_name = d[[2]],
  specimen_id = d[[3]], sex = d[[4]],
  age_printed = d[[5]], age_years = num(d[[5]]),                 # "Adult"/"Unknown" -> NA (kept in age_printed)
  cut_section_thickness_um = num(d[[6]]),
  brain_regions = d[[7]],                                          # F, M1, P, S1, T (footnote)
  n_regions = lengths(strsplit(d[[7]], ",")),
  in_figure2 = gsub(",? ?F$", "", d[[7]]),                         # Fig. 2 uses M1, S1, P, T only
  data_role = "primary", source_row = 2:8)
stopifnot(nrow(final.dataframe) == 7, sum(lengths(strsplit(final.dataframe$in_figure2, ","))) == 24)

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
