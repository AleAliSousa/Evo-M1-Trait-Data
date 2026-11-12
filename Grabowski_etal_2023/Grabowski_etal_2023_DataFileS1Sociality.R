## Grabowski_etal_2023_DataFileS1Sociality.R -- born-digital Dryad workbook sheet -> analysis CSV + public TSV
##
## Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect
##   primate brain-size evolution. Systematic Biology, 72(2), 404-418. https://doi.org/10.1093/sysbio/syac075
##   Data: Dryad https://doi.org/10.5061/dryad.2547d7wpg (registry col C = DOI alt).
##
## Item: Data File S1, sheet 'Sociality Data': "Social System Data - species in green are from DeCasien et al.
##   (2017), species in light brown are new additions. Columns in green and also denoted with asterisk contain
##   data used in main analysis." (A1). Per species: the social system given by six sources (E-K), the
##   DeCasien et al. (2017) social system (L) and its two recodings (M, O; formulas), the mating system given
##   by five sources (R-V) and the DeCasien-style mating system (W), with notes.
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched Dryad file
##   Grabowski_SB_Data_File_S1.xlsx (sha256 3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08),
##   original name, this folder; only read here.
##   FORMULAS: columns M and O (354 cells) are Excel formulas; readxl returns their CACHED results (checked at
##   build: all 354 have a cached value, none is an error).
##   Layout: row 1 group notes (A1, E1, L1, M1, O1, R1, T1 key "UM: Unimale; MM: Multimale; Mon: Monogamous",
##   W1); row 2 header (27 columns A-AA; three are printed 'Notes'); rows 3-179 = 177 species rows; row 180 the
##   colour legend "Light green matches DeCasien et al. 2017; light brown is additions" (not data).
##
## Observation level: one row = one species as printed (categorical codes per source and as used).
## Data role: secondary (codes compiled from the sources named in the column headers; the reclassifications
##   are the authors' own coding of those data).
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
item_name <- tools::file_path_sans_ext(basename(.sp))      # Grabowski_etal_2023_DataFileS1Sociality
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "Grabowski_SB_Data_File_S1.xlsx")
sheet  <- "Sociality Data"

## ---- 1. Read the frozen workbook: every cell as printed (cached values), positional ----
raw <- suppressMessages(readxl::read_excel(frozen, sheet = sheet, col_names = FALSE, col_types = "list"))
if (requireNamespace("tidyxl", quietly = TRUE)) {            # optional: formula cells and their cached values
  fx <- tidyxl::xlsx_cells(frozen, sheets = sheet); fx <- fx[!is.na(fx$formula), ]
  message(sheet, ": ", nrow(fx), " formula cells, ", sum(fx$data_type == "blank"), " without a cached value, ",
          sum(fx$data_type == "error"), " cached as an Excel error (expected 354, 0, 0)")
}
cell_chr <- function(x) vapply(x, function(v) {
  if (length(v) == 0L || is.na(v)) return(NA_character_)
  if (is.logical(v)) return(if (v) "TRUE" else "FALSE")
  if (is.numeric(v)) return(format(v, digits = 15, scientific = FALSE, trim = TRUE))
  as.character(v)
}, character(1), USE.NAMES = FALSE)
## Text: U+00A0 -> space, runs of white space -> one space, trimmed ('  Harem ' -> 'Harem'); 'n/a' -> NA.
txt <- function(x) {
  x <- trimws(gsub("[[:space:]]+", " ", gsub("\u00a0", " ", cell_chr(x), fixed = TRUE)))
  x[!is.na(x) & (x == "" | x == "n/a")] <- NA_character_
  x
}
num <- function(x, col) vapply(x, function(v) {
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
row_txt <- function(r) txt(lapply(seq_len(ncol(raw)), function(j) raw[[j]][[r]]))

printed_header <- c("Genus_Species", "Original Species Name", "Synonyms", "Additions to DeCasien et al. (2017) dataset?",
                    "Shultz and Dunbar 2007-SS", "Sawaguchi et al. 1990-SS", "Shultz et al. 2011-Social solitary",
                    "Ford, 1994-SS", "Maclean et al. 2009 - Lemur Pair/NP", "Mittermeier et al. 2013-SS",
                    "Mittermeier et al. 2013 - Page Number", "Social.System", "Social.System.Drclass*",
                    "Notes on new social system data", "Social.System.DGT*", "Notes-Mittermeier et al. 2013", "Notes",
                    "Schillaci, 2006 - MS - All data from Harvey et al. 1987", "Clutton-Brock and Harvey 1980 - MS",
                    "Thor\u00e9n et al. 2006-MS", "Plavcan 1999-MS", "Mittermeier et al. 2013", "Mating.System*",
                    "Notes on new mating system data", "Notes", "Social.Grouping", "Notes")
if (ncol(raw) < 27L || !identical(row_txt(2)[1:27], printed_header))
  stop("unexpected header in row 2 of '", sheet, "'", call. = FALSE)
if (!startsWith(row_txt(1)[1], "Social System Data - species in green are from DeCasien et al. (2017)"))
  stop("unexpected note in A1", call. = FALSE)
if (ncol(raw) > 27L && any(!is.na(unlist(lapply(28:ncol(raw), function(j) txt(raw[[j]]))))))
  stop("cells found right of column AA", call. = FALSE)
legend <- row_txt(180)
if (!identical(legend[!is.na(legend)], "Light green matches DeCasien et al. 2017; light brown is additions"))
  stop("unexpected legend in row 180", call. = FALSE)
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
if (nrow(raw) > 180L && !all(blank[181:nrow(raw)])) stop("cells found below the legend (row 180)", call. = FALSE)
## Rows: 1 notes, 2 header, 180 legend are not data.
rows <- setdiff(which(!blank), c(1:2, 180:nrow(raw)))
if (length(rows) != 177L || min(rows) != 3L || max(rows) != 179L) stop("expected data rows 3-179", call. = FALSE)
P <- function(j) raw[[j]][rows]
## 'Social.Grouping' (column Z) is 'n/a' on every row: dropped, never silently.
if (any(!is.na(txt(P(26))))) stop("column Z 'Social.Grouping' is no longer empty", call. = FALSE)

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
## ss_* = social system as given by the source in the printed header; ms_* = mating system per source.
## Codes kept as printed (padding spaces trimmed): Harem, Mono, MM, S, Mono/PA, Polygynous, Solitary, Pair, NP,
## MMMF, Mon, PA, ... (key T1: UM = Unimale, MM = Multimale, Mon = Monogamous).
final.dataframe <- data.frame(
  species_as_published         = species_as_published,
  Species                      = Species,
  original_species_name        = txt(P(2)),
  synonyms                     = txt(P(3)),
  addition_to_decasien_2017    = txt(P(4)),
  ss_shultz_dunbar_2007        = txt(P(5)),
  ss_sawaguchi_1990            = txt(P(6)),
  ss_shultz_2011               = txt(P(7)),
  ss_ford_1994                 = txt(P(8)),
  ss_maclean_2009              = txt(P(9)),
  ss_mittermeier_2013          = txt(P(10)),
  mittermeier_2013_page        = int(P(11), "Mittermeier et al. 2013 - Page Number"),
  social_system                = txt(P(12)),
  social_system_drclass        = txt(P(13)),
  notes_new_social_system_data = txt(P(14)),
  social_system_dgt            = txt(P(15)),
  notes_mittermeier_2013       = txt(P(16)),
  notes_social_system          = txt(P(17)),
  ms_schillaci_2006            = txt(P(18)),
  ms_clutton_brock_harvey_1980 = txt(P(19)),
  ms_thoren_2006               = txt(P(20)),
  ms_plavcan_1999              = txt(P(21)),
  ms_mittermeier_2013          = txt(P(22)),
  mating_system                = txt(P(23)),
  notes_new_mating_system_data = txt(P(24)),
  notes_mating_system          = txt(P(25)),
  notes_social_grouping        = txt(P(27)),
  observation_level            = "species (social and mating system codes per source and as used)",
  source_locator               = paste0("Data File S1 (Grabowski_SB_Data_File_S1.xlsx), sheet '", sheet, "', row ", rows),
  data_role                    = "secondary",
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
## 4a. Social.System.Drclass* = recode of Social.System (cached formula: Solitary, Pair, Polygynandry -> MMMF,
##     Polyandry -> UFMM, Polygyny -> UMMF; row 3's copy of the formula has "UM" for Polygyny, unused there).
drclass <- c(Solitary = "Solitary", Pair = "Pair", Polygynandry = "MMMF", Polyandry = "UFMM", Polygyny = "UMMF")
o <- unname(drclass[fd$social_system])
i <- which(!is.na(fd$social_system_drclass))
add_check(sprintf("drclass_row%03d", rows[i]), paste0("Social.System.Drclass* = recode of Social.System, ", sp[i]),
          o[i], fd$social_system_drclass[i], 0, ifelse(is.na(o[i]), NA, o[i] == fd$social_system_drclass[i]))
## 4b. Social.System.DGT* = Solitary / Pair / Group (cached formula; DeCasien & Higham 2019 group types).
o <- ifelse(fd$social_system %in% c("Solitary", "Pair"), fd$social_system, "Group")
o[is.na(fd$social_system)] <- NA
i <- which(!is.na(fd$social_system_dgt))
add_check(sprintf("dgt_row%03d", rows[i]), paste0("Social.System.DGT* = Solitary / Pair / Group from Social.System, ", sp[i]),
          o[i], fd$social_system_dgt[i], 0, ifelse(is.na(o[i]), NA, o[i] == fd$social_system_dgt[i]))
## 4c. Methods (article p. 406): DeCasien et al. (2017) supplemented "with 32 additional species".
k <- sum(fd$addition_to_decasien_2017 %in% "Y")
add_check("text_additions", "rows marked 'Y' in 'Additions to DeCasien et al. (2017) dataset?' vs Methods '32 additional species'",
          k, 32, 0, k == 32, "count of printed 'Y'")
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
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.5061%2Fdryad.2547d7wpg_DataFileS1Sociality
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
