## =============================================================================
## Myhrvold et al. (2015), Amniote Life-History Database (Aug 2015 release)
## Item: Amniote_Range_Count_Aug_2015.csv -- for every species row and trait, the
## minimum, maximum and number of underlying literature records behind the single
## value published in Amniote_Database_Aug_2015.csv.
## =============================================================================
##
## Frozen source (byte-identical copy of the Ecological Archives download; never edited):
##   Myhrvold_etal_2015_AmnioteRangeCountAug2015_snapshot.csv
##     == Data_Files/Amniote_Range_Count_Aug_2015.csv, md5 8095602c7d10befc52feaf22db8e6c76
##
## Output:
##   Myhrvold_etal_2015_AmnioteRangeCountAug2015.csv.csv     long analysis table
##   __Public/comparative-data/<Item encoded>.tsv            public TSV
##
## The registry "Item name" for this item carries the source file's ".csv" extension,
## so item_name (and therefore the analysis CSV and the TSV stem) carry it too -- the
## same situation as Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt. The snapshot and the
## definitions file use item_stem (item_name with that extension dropped), matching the
## sibling Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015_snapshot.csv already in
## this folder. Every name is derived, none retyped.
##
## Missing-value convention as published: -999. A trait with count 0 has no underlying
## records and prints min = max = -999; those cells are dropped from the long table.
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

## ---- frozen source ----------------------------------------------------------
snapshot_file <- file.path(folder, paste0(item_stem, "_snapshot.csv"))
if(!file.exists(snapshot_file)) stop("Missing frozen source: ", snapshot_file, call.=FALSE)
x <- read_csv(snapshot_file, col_types = cols(.default = col_character()),
              show_col_types = FALSE, progress = FALSE)
if(nrow(x) != 21322L || ncol(x) != 91L)
  stop("Expected 21322 x 91 in the frozen source, got ", nrow(x), " x ", ncol(x), call.=FALSE)

TAX <- c("classx","orderx","familyx","genus","species","subspecies","common_name")
if(!identical(names(x)[seq_along(TAX)], TAX))
  stop("Taxonomy columns are not the published first seven.", call.=FALSE)
VAL <- setdiff(names(x), TAX)
if(!all(grepl("^(min|max|count)_", VAL)))
  stop("Unexpected non-min/max/count column: ",
       paste(VAL[!grepl("^(min|max|count)_", VAL)], collapse=", "), call.=FALSE)

## ---- units, from the paper's own field-information table ---------------------
## Supplemental Table 9 names the traits as they appear in Amniote_Database_Aug_2015.csv
## (with a unit suffix); this file names them without one. Normalise the database names
## and require an exact 1:1 hit for every trait here.
field_info <- read.csv(file.path(folder, "Supplemental_Materials",
                                  "Supplemental_Table_9_Dataset_Field_Information.csv"),
                        skip = 1, stringsAsFactors = FALSE)
names(field_info) <- c("field_number","field_name","units","taxon_group","description")
field_info <- field_info[nzchar(field_info$field_name), ]
norm_field <- function(s) {
  s <- sub("_n_or_y$", "", s)
  s <- sub("_per_y$",  "", s)
  s <- sub("_(d|n|y|g|mm|cm)$", "", s)
  gsub("_or_", "_", s)
}
## One genuine inconsistency in the publication's own naming: the range/count file calls
## the hatching snout-vent length "hatching_svl" while the database calls it
## "birth_or_hatching_svl_cm" (its weight counterpart IS "birth_hatching_weight" in both).
TRAIT_ALIAS <- c(hatching_svl = "birth_hatching_svl")
field_key <- norm_field(field_info$field_name)

traits <- unique(sub("^(min|max|count)_", "", VAL))
lookup <- ifelse(traits %in% names(TRAIT_ALIAS), TRAIT_ALIAS[traits], traits)
hit <- match(lookup, field_key)
if(anyNA(hit))
  stop("Trait(s) with no Supplemental Table 9 field: ", paste(traits[is.na(hit)], collapse=", "), call.=FALSE)
if(anyDuplicated(hit))
  stop("Trait(s) matching the same Supplemental Table 9 field.", call.=FALSE)
unit_map <- setNames(field_info$units[hit], traits)
database_field <- setNames(field_info$field_name[hit], traits)

## ---- long form: one row per species row x trait ------------------------------
long <- x %>%
  pivot_longer(all_of(VAL), names_to = c(".value", "trait"),
               names_pattern = "^(min|max|count)_(.*)$") %>%
  mutate(across(c(min, max, count), ~ suppressWarnings(as.numeric(.x))))
if(anyNA(long$count)) stop("Non-numeric count value in the frozen source.", call.=FALSE)
if(nrow(long) != 21322L * length(traits))
  stop("Pivot lost rows: expected ", 21322L * length(traits), ", got ", nrow(long), call.=FALSE)

## count 0 == no underlying records; min/max print -999 for those cells. Guard that
## reading rather than assume it, then drop them.
chk <- long %>% filter(count == 0) %>% filter(min != -999 | max != -999)
if(nrow(chk)) stop(nrow(chk), " cells have count 0 but a min/max other than -999.", call.=FALSE)

## 21 cells (all female_svl) print count > 0 and a real max but min = -999; the
## publication computed min() and count() over the record pool with the -999 sentinel
## included as an observation. Recorded as Myhrvold_etal_2015-E003..E023
## (issue_type publication_error): the printed value stands, so the sentinel is carried
## as missing here and the printed count is left unchanged. Guard the known shape.
SENTINEL_MIN_CELLS <- 21L
odd <- long %>% filter(count > 0, min == -999 | max == -999)
if(nrow(odd) != SENTINEL_MIN_CELLS || !all(odd$trait == "female_svl") || any(odd$max == -999))
  stop("The count>0 / -999 anomaly no longer matches the ", SENTINEL_MIN_CELLS,
       " female_svl cells recorded in the errata file; re-check before building.", call.=FALSE)

final.dataframe <- long %>%
  filter(count > 0) %>%
  mutate(
    min = ifelse(min == -999, NA_real_, min),
    max = ifelse(max == -999, NA_real_, max),
    subspecies = ifelse(subspecies == "-999", NA_character_, subspecies),
    common_name = ifelse(common_name == "-999", NA_character_, common_name),
    unit = unname(unit_map[trait]),
    database_field = unname(database_field[trait]),
    data_role = "secondary",
    source_location = "Amniote_Range_Count_Aug_2015.csv"
  ) %>%
  rename(class = classx, order = orderx, family = familyx) %>%
  select(class, order, family, genus, species, subspecies, common_name,
         trait, database_field, unit, min, max, count, data_role, source_location) %>%
  arrange(class, order, family, genus, species, trait)

if(any(final.dataframe$min %in% -999 | final.dataframe$max %in% -999))
  stop("A retained cell still carries the -999 sentinel.", call.=FALSE)
if(anyNA(final.dataframe$max))
  stop("A retained cell has a missing max.", call.=FALSE)
if(sum(is.na(final.dataframe$min)) != SENTINEL_MIN_CELLS)
  stop("Expected exactly ", SENTINEL_MIN_CELLS, " retained cells with a missing min, got ",
       sum(is.na(final.dataframe$min)), ".", call.=FALSE)
if(any(final.dataframe$min > final.dataframe$max, na.rm = TRUE))
  stop("min > max in ", sum(final.dataframe$min > final.dataframe$max, na.rm = TRUE), " retained cells.", call.=FALSE)

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
    length(traits), "traits;", length(unique(paste(final.dataframe$genus, final.dataframe$species))), "binomials\n")
