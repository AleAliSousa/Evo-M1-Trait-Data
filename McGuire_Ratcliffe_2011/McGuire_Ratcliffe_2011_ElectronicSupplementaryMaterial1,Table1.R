## McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1.R
##   snapshot -> analysis CSV + public TSV
##
## McGuire, L. P., & Ratcliffe, J. M. (2011). Light enough to travel: Migratory bats have
## smaller brains, but not larger hippocampi, than sedentary species. Biology Letters,
## 7(2), 233-236. doi:10.1098/rsbl.2010.0744
##
## Electronic Supplementary Material 1, Table 1 (ESM pp. 1-2): body mass (g) and brain,
## neocortex, hippocampus, medulla oblongata and cerebellum volume (mm3) for 64 bat
## species, each classified Migratory or Sedentary.
##
## DATA ROLE: SECONDARY throughout. The table is a compilation, with two distinct
## provenances that this script keeps apart:
##   * the measurements come from Baron, Stephan & Frahm (1996), stated in the table
##     caption, which also states the conversion the authors applied to the whole brain
##     (brain volume = brain mass / 1.036) -> column measurement_source;
##   * the migratory/sedentary classification comes from the works numbered 1-30 in the
##     ESM's own reference list, printed per row -> column migration_category_ref_keys.
## Both key namespaces resolve in reference_tables/<Item>_references.csv on ref_key;
## split migration_category_ref_keys on "; " before joining.
##
## Snapshot frozen from the PDF text layer by
## <Item>_extract_snapshot.R (no value typed), verified row by row against a page render
## of ESM 1 pp. 1-2 by an AI assistant on 2026-10-31.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  for (fr in rev(sys.frames())) {
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
item_name <- tools::file_path_sans_ext(basename(.sp))
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

## 2. LOAD (frozen snapshot, read as text, column order as printed) -----
snap <- utils::read.csv(snapshot_csv, header = TRUE, stringsAsFactors = FALSE,
                        colClasses = "character", encoding = "UTF-8",
                        check.names = FALSE, na.strings = NULL)
PRINTED <- c("Family", "Species", "Body (g)", "Brain (mm3)", "Neocortex (mm3)",
             "Hippocampus (mm3)", "Medulla Oblongata (mm3)", "Cerebellum (mm3)",
             "Category", "References")
stopifnot(identical(names(snap), PRINTED), nrow(snap) == 66L)

## 2b. SPECIES KEY (collection-scoped: _keys/Stephan; source_publication = folder name)
key <- utils::read.csv(file.path(base, "_keys", "Stephan", "species_key.csv"),
                       stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
if (nrow(key) == 0L)
  stop("species_key filter returned zero rows for source_publication = ", basename(folder),
       call. = FALSE)
lk <- stats::setNames(key$accepted_name, key$variant_name)
harmonise <- function(x) {
  out <- unname(lk[x]); miss <- !is.na(x) & nzchar(x) & is.na(out)
  if (any(miss)) stop("Printed name(s) missing from species_key: ",
                      paste(unique(x[miss]), collapse = "; "), call. = FALSE)
  out
}
num <- function(x) suppressWarnings(as.numeric(trimws(x)))

## 3. CLEAN -----------------------------------------------------------
## The last two printed rows are the group mean +/- se summaries; they are kept in the
## snapshot (they are how a reader checks the table) and used for the table check in
## section 4, but they are not species records and do not enter the analysis CSV.
is_species <- snap$Category %in% c("Migratory", "Sedentary")
stopifnot(sum(is_species) == 64L, identical(which(!is_species), c(65L, 66L)))
x   <- snap[is_species, ]
sm  <- snap[!is_species, ]

## Family is printed once per block, on the first species of the family; carry it down.
fam <- x$Family
for (i in seq_along(fam)) if (!nzchar(fam[i])) fam[i] <- fam[i - 1L]
stopifnot(all(nzchar(fam)))

final.dataframe <- tibble(
  species_printed  = x$Species,
  accepted_name    = harmonise(x$Species),
  family_printed   = fam,
  body_mass_g                   = num(x[["Body (g)"]]),
  brain_volume_mm3              = num(x[["Brain (mm3)"]]),
  neocortex_volume_mm3          = num(x[["Neocortex (mm3)"]]),
  hippocampus_volume_mm3        = num(x[["Hippocampus (mm3)"]]),
  medulla_oblongata_volume_mm3  = num(x[["Medulla Oblongata (mm3)"]]),
  cerebellum_volume_mm3         = num(x[["Cerebellum (mm3)"]]),
  migration_category            = x$Category,
  ## printed keys kept verbatim, one cell, "; " separated -> join to <Item>_references.csv
  migration_category_ref_keys   = gsub(",\\s*", "; ", trimws(x$References)),
  measurement_source            = "Baron_etal_1996",
  data_role                     = "secondary",
  source                        = basename(folder))

## Every printed cell that held a number became one, and every printed blank stayed blank.
printed_num <- as.matrix(x[, 3:8]); got <- as.matrix(final.dataframe[, 4:9])
stopifnot(identical(dim(printed_num), dim(got)),
          all(nzchar(printed_num) == !is.na(got)),
          nrow(final.dataframe) == 64L,
          !anyDuplicated(final.dataframe$species_printed),
          !anyDuplicated(final.dataframe$accepted_name),
          all(nzchar(final.dataframe$migration_category_ref_keys)),
          sum(final.dataframe$migration_category == "Migratory") == 31L,
          sum(final.dataframe$migration_category == "Sedentary") == 33L)

## Every printed key resolves in the item's references table (both key namespaces).
refs <- utils::read.csv(refs_csv, stringsAsFactors = FALSE, colClasses = "character",
                        encoding = "UTF-8")
cited <- unique(c(unlist(strsplit(final.dataframe$migration_category_ref_keys, "; ")),
                  final.dataframe$measurement_source))
unresolved <- setdiff(cited, refs$ref_key)
if (length(unresolved))
  stop("reference key(s) with no row in ", basename(refs_csv), ": ",
       paste(unresolved, collapse = ", "), call. = FALSE)

## 4. TABLE CHECK (printed summary rows; build HOWTO section 7a) ---------
## ESM 1 Table 1 prints a Migratory and a Sedentary mean +/- se under each measurement
## column. Recompute them from the species rows and compare at the printed precision.
## Values are kept as printed either way; a mismatch is warned, never corrected.
pm <- function(s) num(sub("\\s*\u00b1.*$", "", s))
se <- function(v) stats::sd(v) / sqrt(length(v))
dec <- function(s) { s <- sub("\\s*\u00b1.*$", "", s)
                     ifelse(grepl("\\.", s), nchar(sub(".*\\.", "", s)), 0) }
MEAS <- names(final.dataframe)[4:9]
table_checks <- bind_rows(lapply(seq_len(nrow(sm)), function(i) {
  grp <- sub(" .*$", "", sm$Family[i])
  d   <- final.dataframe[final.dataframe$migration_category == grp, ]
  bind_rows(lapply(seq_along(MEAS), function(k) {
    v <- d[[MEAS[k]]]; v <- v[!is.na(v)]
    cell <- sm[[PRINTED[k + 2L]]][i]; p <- dec(cell)
    tibble(check_id = paste0(tolower(grp), "_", MEAS[k]),
           basis    = "printed group mean +/- se recomputed from the species rows",
           n_used   = length(v),
           observed = round(mean(v), p), printed = pm(cell),
           observed_se = round(se(v), dec(sub("^.*\u00b1\\s*", "", cell))),
           printed_se  = num(sub("^.*\u00b1\\s*", "", cell)),
           tolerance   = 10^-p)
  }))
})) %>% mutate(difference = observed - printed,
               status = ifelse(abs(difference) <= tolerance + 1e-9, "pass", "mismatch"),
               note   = "values kept as printed; tolerance = one unit of the printed decimal")
if (any(table_checks$status == "mismatch"))
  warning("Table check mismatch(es): ",
          paste(table_checks$check_id[table_checks$status == "mismatch"], collapse = ", "),
          call. = FALSE)

## 5. WRITE CSV + PUBLIC TSV -------------------------------------------
readr::write_csv(final.dataframe, final_csv, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  ## The live registry is the naming authority, looked up by Item name (never by row).
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  readr::write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
print(as.data.frame(table_checks[, c("check_id", "n_used", "observed", "printed",
                                     "observed_se", "printed_se", "status")]))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
