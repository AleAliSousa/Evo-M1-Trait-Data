## =============================================================================
## Myhrvold et al. (2015), Amniote Life-History Database (Aug 2015 release)
## Item: Amniote_Database_References_Aug_2015.csv -- the per-cell source-tracking
## layer of the database. Same shape and row order as Amniote_Database_Aug_2015.csv;
## each cell holds the citation string(s) behind the value in the matching cell there.
## =============================================================================
##
## Frozen source (byte-identical copy of the Ecological Archives download; never edited):
##   Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv
##     == Data_Files/Amniote_Database_References_Aug_2015.csv, md5 58ce0c047162154dd752cfdd16c1dd26
##
## Output:
##   Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv.csv   long analysis table
##   __Public/comparative-data/<Item encoded>.tsv                  public TSV
##
## The registry "Item name" carries the source file's ".csv" extension, so item_name
## (and the analysis CSV and TSV stem) carry it too -- as for
## Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt. The snapshot and definitions use
## item_stem (item_name without that extension). Every name is derived, none retyped.
##
## Missing-value convention as published: -999 (no reference recorded).
## =============================================================================

options(stringsAsFactors = FALSE, scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); item_name <- sub("\\.R$","",basename(.sp)); setwd(folder)
item_stem <- tools::file_path_sans_ext(item_name)
base <- local({ d<-folder; while(dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d); if(file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })

req <- c("readr","dplyr","tidyr","readxl")
miss <- req[!vapply(req, requireNamespace, logical(1), quietly=TRUE)]
if(length(miss)) stop("Install the required package(s): ", paste(miss, collapse=", "), call.=FALSE)
suppressPackageStartupMessages({ library(readr); library(dplyr); library(tidyr) })

ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "en_US.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if(!ctype_ok) ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "C.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if(!ctype_ok) stop("No UTF-8 LC_CTYPE locale available; citation text would be corrupted on write.", call.=FALSE)

## ---- frozen source ----------------------------------------------------------
snapshot_file <- file.path(folder, paste0(item_stem, "_snapshot.csv"))
if(!file.exists(snapshot_file)) stop("Missing frozen source: ", snapshot_file, call.=FALSE)
x <- read_csv(snapshot_file, col_types = cols(.default = col_character()),
              show_col_types = FALSE, progress = FALSE)
if(nrow(x) != 21322L || ncol(x) != 36L)
  stop("Expected 21322 x 36 in the frozen source, got ", nrow(x), " x ", ncol(x), call.=FALSE)

TAX <- c("class","order","family","genus","species","subspecies","common_name")
if(!identical(names(x)[seq_along(TAX)], TAX))
  stop("Taxonomy columns are not the published first seven.", call.=FALSE)
TRAIT <- setdiff(names(x), TAX)

## ---- alignment with the value table (the join this item exists to serve) -----
## The two files must be row-for-row, taxon-for-taxon aligned for a reference cell to
## name the source of the value cell beside it. Assert it rather than assume it.
value_snapshot <- file.path(folder, "Myhrvold_etal_2015_AmnioteDatabaseAug2015_snapshot.csv")
if(file.exists(value_snapshot)) {
  v <- read_csv(value_snapshot, col_types = cols(.default = col_character()),
                show_col_types = FALSE, progress = FALSE)
  if(!identical(names(v), names(x)))
    stop("Database and References files do not share a column list.", call.=FALSE)
  if(!identical(as.matrix(v[, TAX]), as.matrix(x[, TAX])))
    stop("Database and References files are not row-for-row, taxon-for-taxon aligned.", call.=FALSE)
  aligned <- TRUE
} else {
  stop("Missing ", basename(value_snapshot), "; alignment with the value table cannot be verified.", call.=FALSE)
}

## ---- units, from the paper's own field-information table ---------------------
field_info <- read.csv(file.path(folder, "Supplemental_Materials",
                                  "Supplemental_Table_9_Dataset_Field_Information.csv"),
                        skip = 1, stringsAsFactors = FALSE)
names(field_info) <- c("field_number","field_name","units","taxon_group","description")
field_info <- field_info[nzchar(field_info$field_name), ]
hit <- match(TRAIT, field_info$field_name)
if(anyNA(hit))
  stop("Trait column(s) with no Supplemental Table 9 field: ", paste(TRAIT[is.na(hit)], collapse=", "), call.=FALSE)
unit_map <- setNames(field_info$units[hit], TRAIT)

## ---- long form: one row per species row x trait with a recorded reference ----
final.dataframe <- x %>%
  mutate(row_id = seq_len(n())) %>%
  pivot_longer(all_of(TRAIT), names_to = "trait", values_to = "reference") %>%
  filter(!is.na(reference), reference != "-999", nzchar(trimws(reference))) %>%
  mutate(
    subspecies = ifelse(subspecies == "-999", NA_character_, subspecies),
    common_name = ifelse(common_name == "-999", NA_character_, common_name),
    unit = unname(unit_map[trait]),
    ## the compilers' derivation constructs, kept verbatim in `reference`
    cell_form = case_when(
      grepl("^mean of .* from median of [0-9]+\\(", reference) ~ "mean_of_median_select",
      grepl(" from median of [0-9]+\\(", reference)            ~ "median_select",
      grepl("^mean of ", reference)                            ~ "mean_of_two",
      TRUE                                                      ~ "single"
    ),
    data_role = "secondary",
    source_location = "Amniote_Database_References_Aug_2015.csv (per-cell reference string)"
  ) %>%
  select(row_id, class, order, family, genus, species, subspecies, common_name,
         trait, unit, reference, cell_form, data_role, source_location) %>%
  arrange(class, order, family, genus, species, trait)

if(any(final.dataframe$reference == "-999")) stop("A retained cell still carries the -999 sentinel.", call.=FALSE)
if(!all(final.dataframe$row_id %in% seq_len(21322L))) stop("row_id outside the frozen source row range.", call.=FALSE)

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
message("Wrote: ", file.path(folder, paste0(item_name, ".csv")), " (", nrow(final.dataframe), " rows)")

## ---- public TSV --------------------------------------------------------------
if(!is.na(base)) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  public_dir <- file.path(base, "__Public", "comparative-data")
  if(is.na(item_encoded) || !nzchar(item_encoded)) warning("Registry row pending for ", item_name, "; public TSV skipped.")
  else if(!dir.exists(public_dir)) warning("Public directory unavailable; public TSV skipped.")
  else {
    utils::write.table(final.dataframe, file.path(public_dir, paste0(item_encoded, ".tsv")),
                       sep = "\t", row.names = FALSE, na = "")
    message("Wrote: ", file.path(public_dir, paste0(item_encoded, ".tsv")))
  }
} else warning("Repository root not found; public TSV skipped.")

cat(item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "columns;",
    length(TRAIT), "trait columns; alignment with the value table verified:", aligned, "\n")
print(table(final.dataframe$cell_form))
