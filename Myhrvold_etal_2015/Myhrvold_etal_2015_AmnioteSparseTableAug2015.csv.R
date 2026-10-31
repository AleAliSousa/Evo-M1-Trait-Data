## =============================================================================
## Myhrvold et al. (2015), Amniote Life-History Database (Aug 2015 release)
## Item: Amniote_Sparse_Table_Aug_2015.csv -- the underlying literature RECORDS.
## One published row per record: a species, one (occasionally more) trait value, and
## the `dataset` column naming the study the record was taken from. This is the most
## direct trait-value -> primary-study link the database publishes; the single values
## in Amniote_Database_Aug_2015.csv are selected or averaged from these records.
## =============================================================================
##
## Frozen source (byte-identical copy of the Ecological Archives download; never edited):
##   Myhrvold_etal_2015_AmnioteSparseTableAug2015_snapshot.csv
##     == Data_Files/Amniote_Sparse_Table_Aug_2015.csv, md5 03253b795e400f629b823e730cd7f75a
##
## Output:
##   Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv.csv   long analysis table
##   __Public/comparative-data/<Item encoded>.tsv           public TSV
##
## The registry "Item name" carries the source file's ".csv" extension, so item_name
## (and the analysis CSV and TSV stem) carry it too -- as for
## Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt. The snapshot and definitions use
## item_stem (item_name without that extension). Every name is derived, none retyped.
##
## Missing-value convention as published: -999.
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
if(nrow(x) != 139827L || ncol(x) != 36L)
  stop("Expected 139827 x 36 in the frozen source, got ", nrow(x), " x ", ncol(x), call.=FALSE)

TAX <- c("class","order","family","genus","species","subspecies","common_name")
if(!identical(names(x)[seq_along(TAX)], TAX))
  stop("Taxonomy columns are not the published first seven.", call.=FALSE)
if(!identical(names(x)[ncol(x)], "dataset"))
  stop("Last column is not the published `dataset` (source) column.", call.=FALSE)
TRAIT <- setdiff(names(x), c(TAX, "dataset"))

## ---- units, from the paper's own field-information table ---------------------
## Supplemental Table 9 names the traits as they appear in Amniote_Database_Aug_2015.csv.
## This file matches those names except for one: the sparse table writes
## `litters_or_clutches_n_or_y` where the database writes `litters_or_clutches_per_y`.
field_info <- read.csv(file.path(folder, "Supplemental_Materials",
                                  "Supplemental_Table_9_Dataset_Field_Information.csv"),
                        skip = 1, stringsAsFactors = FALSE)
names(field_info) <- c("field_number","field_name","units","taxon_group","description")
field_info <- field_info[nzchar(field_info$field_name), ]
TRAIT_ALIAS <- c(litters_or_clutches_n_or_y = "litters_or_clutches_per_y")
lookup <- ifelse(TRAIT %in% names(TRAIT_ALIAS), TRAIT_ALIAS[TRAIT], TRAIT)
hit <- match(lookup, field_info$field_name)
if(anyNA(hit))
  stop("Trait column(s) with no Supplemental Table 9 field: ", paste(TRAIT[is.na(hit)], collapse=", "), call.=FALSE)
unit_map <- setNames(field_info$units[hit], TRAIT)
database_field <- setNames(field_info$field_name[hit], TRAIT)

## ---- long form: one row per published record x trait carrying a value --------
final.dataframe <- x %>%
  mutate(row_id = seq_len(n())) %>%
  pivot_longer(all_of(TRAIT), names_to = "trait", values_to = "value") %>%
  filter(!is.na(value), value != "-999", nzchar(trimws(value))) %>%
  mutate(value_num = suppressWarnings(as.numeric(value)))
if(anyNA(final.dataframe$value_num))
  stop(sum(is.na(final.dataframe$value_num)), " non-numeric trait value(s) in the frozen source.", call.=FALSE)

final.dataframe <- final.dataframe %>%
  mutate(
    value = value_num,
    subspecies = ifelse(subspecies == "-999", NA_character_, subspecies),
    common_name = ifelse(common_name == "-999", NA_character_, common_name),
    reference = ifelse(dataset == "-999" | !nzchar(trimws(dataset)), NA_character_, dataset),
    unit = unname(unit_map[trait]),
    database_field = unname(database_field[trait]),
    data_role = "secondary",
    source_location = "Amniote_Sparse_Table_Aug_2015.csv (one row per literature record; `dataset` = source)"
  ) %>%
  select(row_id, class, order, family, genus, species, subspecies, common_name,
         trait, database_field, unit, value, reference, data_role, source_location) %>%
  arrange(class, order, family, genus, species, trait, row_id)

if(any(final.dataframe$value %in% -999)) stop("A retained record still carries the -999 sentinel.", call.=FALSE)
if(!all(final.dataframe$row_id %in% seq_len(139827L))) stop("row_id outside the frozen source row range.", call.=FALSE)

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
    length(TRAIT), "trait columns;",
    length(unique(paste(final.dataframe$genus, final.dataframe$species))), "binomials;",
    length(unique(na.omit(final.dataframe$reference))), "distinct source strings;",
    sum(is.na(final.dataframe$reference)), "records with no source string\n")
