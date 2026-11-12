## Grabowski_etal_2023_DataFileS1GroupSizeActivity.R -- born-digital Dryad workbook sheet -> analysis CSV + public TSV
##
## Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect
##   primate brain-size evolution. Systematic Biology, 72(2), 404-418. https://doi.org/10.1093/sysbio/syac075
##   Data: Dryad https://doi.org/10.5061/dryad.2547d7wpg (registry col C = DOI alt).
##
## Item: Data File S1, sheet 'Group Size and Activity Data': "Group Size and Activity Period Data. Columns in
##   green and also denoted with asterisk contain data used in main analysis." (A1). Per species: the combined
##   average group size used in the analysis (B), the DeCasien et al. (2017) group-size columns (C-F), the
##   Powell et al. (2017) group-size columns (G-J) and the activity period (K-M).
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched Dryad file
##   Grabowski_SB_Data_File_S1.xlsx (sha256 3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08),
##   original name, this folder; only read here.
##   FORMULAS: 356 cells of column L are Excel formulas IF(K=1,"Diurnal",IF(K=0,"Nocturnal")); readxl returns
##   their CACHED results (checked at build: all cached, none an error). L305 caches the logical FALSE (its
##   K305 is 'n/a', the formula has no else branch): kept as printed, "FALSE".
##   Layout: row 1 notes (A1; B1, C1, H1, K1, L1 name the sources of the column groups); row 2 header
##   (13 columns A-M); rows 3-365 = 363 species rows; no blank or footnote rows.
##
## Observation level: one row = one species as printed (average group sizes and activity period).
## Data role: secondary (Powell et al. 2017 and DeCasien et al. 2017 compilations, sources in
##   'Source.group.size' / 'Activity Period Sources'; reference_tables/<item>_references.csv).
##
## Outputs of 2026-11-10 were written by a Python mirror of this script: R NOT RUN (Python mirror).

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))      # Grabowski_etal_2023_DataFileS1GroupSizeActivity
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "Grabowski_SB_Data_File_S1.xlsx")
sheet  <- "Group Size and Activity Data"

## ---- 1. Read the frozen workbook: every cell as printed (cached values), positional ----
raw <- suppressMessages(readxl::read_excel(frozen, sheet = sheet, col_names = FALSE, col_types = "list"))
if (requireNamespace("tidyxl", quietly = TRUE)) {            # optional: formula cells and their cached values
  fx <- tidyxl::xlsx_cells(frozen, sheets = sheet); fx <- fx[!is.na(fx$formula), ]
  message(sheet, ": ", nrow(fx), " formula cells, ", sum(fx$data_type == "blank"), " without a cached value, ",
          sum(fx$data_type == "error"), " cached as an Excel error (expected 356, 0, 0)")
}
cell_chr <- function(x) vapply(x, function(v) {
  if (length(v) == 0L || is.na(v)) return(NA_character_)
  if (is.logical(v)) return(if (v) "TRUE" else "FALSE")
  if (is.numeric(v)) return(format(v, digits = 15, scientific = FALSE, trim = TRUE))
  as.character(v)
}, character(1), USE.NAMES = FALSE)
txt <- function(x) {                                          # U+00A0 -> space, white space collapsed, 'n/a' -> NA
  x <- trimws(gsub("[[:space:]]+", " ", gsub("\u00a0", " ", cell_chr(x), fixed = TRUE)))
  x[!is.na(x) & (x == "" | x == "n/a")] <- NA_character_
  x
}
num <- function(x, col) vapply(x, function(v) {               # number as stored; 'n/a'/blank -> NA; other text stops
  if (length(v) == 0L || is.na(v)) return(NA_real_)
  if (is.numeric(v)) return(as.numeric(v))
  s <- trimws(gsub("\u00a0", " ", as.character(v), fixed = TRUE))
  if (s %in% c("", "n/a")) return(NA_real_)
  r <- suppressWarnings(as.numeric(s))
  if (is.logical(v) || is.na(r)) stop("non-numeric cell in ", col, ": ", s, call. = FALSE)
  r
}, numeric(1), USE.NAMES = FALSE)
int <- function(x, col) {
  v <- num(x, col)
  if (any(!is.na(v) & v != round(v))) stop("non-integer value in ", col, call. = FALSE)
  as.integer(v)
}
## A numeric column that also prints words ('single study', '30+', 'two studies'): the number goes to the
## value column, the printed text to a *_note column; nothing is parsed out of the text.
num_part  <- function(x) vapply(x, function(v) if (length(v) && !is.na(v) && is.numeric(v)) as.numeric(v) else NA_real_,
                                numeric(1), USE.NAMES = FALSE)
text_part <- function(x) { t <- txt(x); t[!is.na(num_part(x))] <- NA_character_; t }
row_txt <- function(r) txt(lapply(seq_len(ncol(raw)), function(j) raw[[j]][[r]]))

printed_header <- c("Genus_Species", "Combo Average Group Size*", "Average.Group Size", "Min.of.Group.Size",
                    "Max.of.Group.Size", "Count.of.First.or.Duplicate.Entry.", "Foraging.Group.Size.Mean",
                    "Group.Size.Range", "Group.size.combined", "Source.group.size", "Diurnality",
                    "Activity.Period.DN*", "Activity Period Sources")
if (ncol(raw) < 13L || !identical(row_txt(2)[1:13], printed_header))
  stop("unexpected header in row 2 of '", sheet, "'", call. = FALSE)
if (!startsWith(row_txt(1)[1], "Group Size and Activity Period Data."))
  stop("unexpected note in A1", call. = FALSE)
if (ncol(raw) > 13L && any(!is.na(unlist(lapply(14:ncol(raw), function(j) txt(raw[[j]]))))))
  stop("cells found right of column M", call. = FALSE)
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
rows  <- setdiff(which(!blank), 1:2)
if (length(rows) != 363L || min(rows) != 3L || max(rows) != 365L) stop("expected data rows 3-365", call. = FALSE)
P <- function(j) raw[[j]][rows]
## The text cells of the numeric columns G and I must be the known ones (anything new stops the build).
if (!all(text_part(P(7)) %in% c(NA, "single study", "30+")) || !all(text_part(P(9)) %in% c(NA, "two studies")))
  stop("new text in Foraging.Group.Size.Mean or Group.size.combined", call. = FALSE)

## ---- 2. Species: printed name kept; accepted name via the General collection key ----
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", basename(folder), "' in _keys/General/species_key.csv", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
species_as_published <- txt(P(1))
if (!all(tolower(species_as_published) %in% names(lk)))
  stop("Unkeyed printed name: ", paste(unique(species_as_published[!tolower(species_as_published) %in% names(lk)]),
                                      collapse = ", "), call. = FALSE)
Species <- unname(lk[tolower(species_as_published)])
Species[!is.na(Species) & !nzchar(trimws(Species))] <- NA_character_

## ---- 3. Analysis table: one row per printed row, printed column order ----
## Units: individuals per group (averages, minima, maxima). Diurnality 1 = diurnal, 0 = nocturnal;
## Activity.Period.DN* Diurnal / Nocturnal (and one cached FALSE, row 305). Group.Size.Range and
## Source.group.size are text as printed (numbers in them are written as printed: 100, 13.9).
final.dataframe <- data.frame(
  species_as_published              = species_as_published,
  Species                           = Species,
  combo_average_group_size          = num(P(2), "Combo Average Group Size*"),
  average_group_size                = num(P(3), "Average.Group Size"),
  min_group_size                    = num(P(4), "Min.of.Group.Size"),
  max_group_size                    = num(P(5), "Max.of.Group.Size"),
  count_of_first_or_duplicate_entry = int(P(6), "Count.of.First.or.Duplicate.Entry."),
  foraging_group_size_mean          = num_part(P(7)),
  foraging_group_size_mean_note     = text_part(P(7)),
  group_size_range                  = txt(P(8)),
  group_size_combined               = num_part(P(9)),
  group_size_combined_note          = text_part(P(9)),
  source_group_size                 = txt(P(10)),
  diurnality                        = int(P(11), "Diurnality"),
  activity_period_dn                = txt(P(12)),
  activity_period_sources           = txt(P(13)),
  observation_level                 = "species (average group size and activity period as printed)",
  source_locator                    = paste0("Data File S1 (Grabowski_SB_Data_File_S1.xlsx), sheet '", sheet, "', row ", rows),
  data_role                         = "secondary",
  stringsAsFactors = FALSE, check.names = FALSE)

## ---- 4. Table checks (build HOWTO sec. 7a): relations the sheet defines; values are never changed ----
tc <- list()
add_check <- function(check_id, basis, observed, printed, tolerance, ok, note = "") {
  if (!length(check_id)) return(invisible(NULL))
  difference <- if (is.numeric(observed) && is.numeric(printed)) observed - printed else NA_real_
  tc[[length(tc) + 1L]] <<- data.frame(check_id = check_id, basis = basis,
    observed = as.character(observed), printed = as.character(printed), difference = difference,
    tolerance = tolerance, status = ifelse(is.na(ok), "not_evaluable", ifelse(ok, "pass", "mismatch")),
    note = note, stringsAsFactors = FALSE)
}
fd <- final.dataframe
sp <- fd$species_as_published
## 4a. Activity.Period.DN* = IF(Diurnality = 1, "Diurnal", IF(Diurnality = 0, "Nocturnal")) (cached formula).
o <- ifelse(fd$diurnality == 1L, "Diurnal", ifelse(fd$diurnality == 0L, "Nocturnal", "FALSE"))
i <- which(!is.na(fd$activity_period_dn))
add_check(sprintf("activity_row%03d", rows[i]), paste0("Activity.Period.DN* = Diurnal/Nocturnal from Diurnality 1/0, ", sp[i]),
          o[i], fd$activity_period_dn[i], 0, ifelse(is.na(o[i]), NA, o[i] == fd$activity_period_dn[i]),
          ifelse(is.na(o[i]), "Diurnality is 'n/a': the formula has no else branch and returns FALSE", ""))
## 4b. Combo Average Group Size* = Group.size.combined (Powell et al. 2017) when it is a number, else
##     Average.Group Size (DeCasien et al. 2017) -- note B1.
o <- ifelse(!is.na(fd$group_size_combined), fd$group_size_combined, fd$average_group_size)
i <- which(!is.na(fd$combo_average_group_size))
add_check(sprintf("combo_row%03d", rows[i]), paste0("Combo = Group.size.combined, else Average.Group Size, ", sp[i]),
          o[i], fd$combo_average_group_size[i], 1e-9,
          ifelse(is.na(o[i]), NA, abs(o[i] - fd$combo_average_group_size[i]) <= 1e-9))
## 4c. Min.of.Group.Size <= Average.Group Size <= Max.of.Group.Size (DeCasien et al. 2017 columns).
i <- which(!is.na(fd$min_group_size) & !is.na(fd$average_group_size) & !is.na(fd$max_group_size))
add_check(sprintf("min_avg_max_row%03d", rows[i]), paste0("Min <= Average <= Max group size, ", sp[i]),
          fd$average_group_size[i], paste0(cell_chr(as.list(fd$min_group_size[i])), " to ", cell_chr(as.list(fd$max_group_size[i]))),
          0, fd$min_group_size[i] <= fd$average_group_size[i] & fd$average_group_size[i] <= fd$max_group_size[i])
table_checks <- do.call(rbind, tc)
if (any(table_checks$status == "mismatch"))
  warning(sum(table_checks$status == "mismatch"), " table check(s) did not pass -- values kept as printed; ",
          "see the ReadMe '## Table checks'", call. = FALSE)

## ---- 5. Write the analysis CSV (UTF-8 with BOM, house C6) ----
.csv_txt <- enc2utf8(paste0(paste(utils::capture.output(
  utils::write.csv(final.dataframe, stdout(), row.names = FALSE, na = "")), collapse = "\n"), "\n"))
.con <- file(file.path(folder, paste0(item_name, ".csv")), open = "wb")
writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), .con); writeBin(charToRaw(.csv_txt), .con); close(.con)

## ---- 6. Public TSV: Item encoded looked up by Item name in __ReadMe.xlsx ----
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.5061%2Fdryad.2547d7wpg_DataFileS1GroupSizeActivity
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- public TSV NOT written.", call. = FALSE)
} else {
  tsv_path <- file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}

## ---- 7. Validate ----
checks <- validate_dataset_item(
  csv_file           = file.path(folder, paste0(item_name, ".csv")),
  tsv_file           = tsv_path,
  readme_file        = file.path(folder, paste0(item_name, ".README.md")),
  definitions_file   = file.path(folder, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = if (is.na(tsv_path)) NULL else item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " rows; ", length(unique(stats::na.omit(final.dataframe$Species))),
        " accepted species; table checks: ", paste(names(table(table_checks$status)), table(table_checks$status),
                                                   sep = " = ", collapse = ", "))
