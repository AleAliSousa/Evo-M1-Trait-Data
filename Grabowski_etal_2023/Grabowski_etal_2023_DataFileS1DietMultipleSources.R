## Grabowski_etal_2023_DataFileS1DietMultipleSources.R -- born-digital Dryad workbook sheet -> analysis CSV + public TSV
##
## Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect
##   primate brain-size evolution. Systematic Biology, 72(2), 404-418. https://doi.org/10.1093/sysbio/syac075
##   Data: Dryad https://doi.org/10.5061/dryad.2547d7wpg (registry col C = DOI alt).
##
## Item: Data File S1, sheet 'Diet Data - Multiple Sources': "Percentage Average Diet Data when Multiple
##   Sources with Sample Sizes (individuals per study group) are Available. Spaces in rows separate species
##   groups." (title, A1). 13 species blocks: one row per source (study group, population, season or month)
##   followed by the block's average row.
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched Dryad file
##   Grabowski_SB_Data_File_S1.xlsx (sha256 3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08),
##   original name, this folder; only read here.
##   FORMULAS: 143 cells (the average rows) are Excel formulas; readxl returns their CACHED results. Every
##   formula cell has a cached value (checked at build: 0 missing); 3 are cached as #VALUE! (F39, E57, F57:
##   a source printed 'n/a') and are read as NA.
##   Layout: row 1 title; row 2 header (19 named columns A-S; column T has no header and holds 'n/a' on every
##   data row); rows 3-63 data with 13 blank separator rows (6, 10, 15, 20, 26, 30, 35, 40, 45, 49, 53, 58,
##   59); row 64 footnote '* Max sizes when variation is reported' (for 'N*', printed in D64).
##
## Observation level: one row = one source x species (source rows) or the species average of its block
##   (average rows); `block` and `row_role` (derived) say which.
## Data role: secondary (values from the studies printed in 'Reference'; reference_tables/<item>_references.csv).
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
item_name <- tools::file_path_sans_ext(basename(.sp))      # Grabowski_etal_2023_DataFileS1DietMultipleSources
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "Grabowski_SB_Data_File_S1.xlsx")
sheet  <- "Diet Data - Multiple Sources"

## ---- 1. Read the frozen workbook: every cell as printed (cached values), positional ----
raw <- suppressMessages(readxl::read_excel(frozen, sheet = sheet, col_names = FALSE, col_types = "list"))
if (requireNamespace("tidyxl", quietly = TRUE)) {            # optional: formula cells and their cached values
  fx <- tidyxl::xlsx_cells(frozen, sheets = sheet); fx <- fx[!is.na(fx$formula), ]
  message(sheet, ": ", nrow(fx), " formula cells, ", sum(fx$data_type == "blank"), " without a cached value, ",
          sum(fx$data_type == "error"), " cached as an Excel error (expected 143, 0, 3)")
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
row_txt <- function(r) txt(lapply(seq_len(ncol(raw)), function(j) raw[[j]][[r]]))

printed_header <- c("Species", "Reference", "Notes", "N*", "Leaves", "Flowers", "Fruit", "Seeds", "Fruit+Seeds",
                    "Invertebrates", "Vertebrates", "Total Animal", "Gum", "Roots", "Other Plant Matter", "Fungus",
                    "Nectar", "Buds", "Other")
if (ncol(raw) < 20L || !identical(row_txt(2)[1:19], printed_header) || !is.na(row_txt(2)[20]))
  stop("unexpected header in row 2 of '", sheet, "'", call. = FALSE)
if (!startsWith(row_txt(1)[1], "Percentage Average Diet Data when Multiple Sources"))
  stop("unexpected title in A1", call. = FALSE)
foot <- row_txt(64)
if (!identical(foot[!is.na(foot)], "* Max sizes when variation is reported"))
  stop("unexpected footnote in row 64", call. = FALSE)
if (ncol(raw) > 20L && any(!is.na(unlist(lapply(21:ncol(raw), function(j) txt(raw[[j]]))))))
  stop("cells found right of column T", call. = FALSE)
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
if (nrow(raw) > 64L && !all(blank[65:nrow(raw)])) stop("cells found below the footnote (row 64)", call. = FALSE)
## Rows: 1 title, 2 header, 64 footnote are not data; the 13 blank rows between 3 and 63 separate the blocks.
rows  <- (3:63)[!blank[3:63]]
if (length(rows) != 48L) stop("expected 48 data rows", call. = FALSE)
block <- cumsum(c(TRUE, diff(rows) > 1L))                     # a gap in the row numbers = a blank separator row
P <- function(j) raw[[j]][rows]
## Dropped printed columns: 'n/a' on every data row (Roots N, Fungus P, Nectar Q, Buds R; unnamed T).
for (j in c(14L, 16L, 17L, 18L, 20L))
  if (any(!is.na(txt(P(j))))) stop("printed column ", j, " is no longer empty", call. = FALSE)

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
## The last row of each block is its average (Reference says "Average ..."); stop if the layout changed.
reference <- txt(P(2))
row_role  <- ifelse(!duplicated(block, fromLast = TRUE), "average", "source")
if (!identical(grepl("Average", reference), row_role == "average"))
  stop("block layout changed: the average rows are not the last row of each block", call. = FALSE)
if (any(tapply(species_as_published, block, function(z) length(unique(z))) != 1L))
  stop("a block holds more than one species", call. = FALSE)
## Units: percentage of feeding time (0-100); N* = individuals per study group (max when variation reported).
pct_cols <- c(leaves_pct = 5, flowers_pct = 6, fruit_pct = 7, seeds_pct = 8, fruit_seeds_pct = 9,
              invertebrates_pct = 10, vertebrates_pct = 11, total_animal_pct = 12, gum_pct = 13,
              other_plant_matter_pct = 15, other_pct = 19)
final.dataframe <- data.frame(
  species_as_published = species_as_published,
  Species              = Species,
  block                = as.integer(block),
  row_role             = row_role,
  reference            = reference,
  notes                = txt(P(3)),
  n                    = num(P(4), "N*"),
  stringsAsFactors = FALSE, check.names = FALSE)
for (nm_ in names(pct_cols)) final.dataframe[[nm_]] <- num(P(pct_cols[[nm_]]), printed_header[pct_cols[[nm_]]])
final.dataframe$observation_level <- ifelse(row_role == "average", "species (average row of the block, as printed)",
                                            "source x species (one study group, population, season or month)")
final.dataframe$source_locator    <- paste0("Data File S1 (Grabowski_SB_Data_File_S1.xlsx), sheet '", sheet, "', row ", rows)
final.dataframe$data_role         <- "secondary"

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
## Diet Data rows of the same species (sheet 'Diet Data', same printed Genus_Species), for 4d.
dd <- suppressMessages(readxl::read_excel(frozen, sheet = "Diet Data", col_names = FALSE, col_types = "list"))
dd_species <- txt(dd[[1]])
dd_col <- c(leaves_pct = 9, flowers_pct = 10, fruit_pct = 11, seeds_pct = 12, fruit_seeds_pct = 13,
            invertebrates_pct = 14, vertebrates_pct = 15, total_animal_pct = 16, gum_pct = 17,
            other_plant_matter_pct = 19, other_pct = 23)
for (b in unique(block)) {
  s <- which(block == b & row_role == "source"); a <- which(block == b & row_role == "average")
  spb <- fd$species_as_published[a]
  ## 4a. Average N* = sum of the source N* (cached formula SUM).
  add_check(sprintf("n_sum_block%02d", b), paste0("average N* = sum of source N*, ", spb),
            sum(fd$n[s]), fd$n[a], 1e-9, abs(sum(fd$n[s]) - fd$n[a]) <= 1e-9)
  dr <- match(spb, dd_species)
  for (v in names(pct_cols)) {
    src <- fd[[v]][s]; avg <- fd[[v]][a]
    ## 4b. Average = N-weighted mean of the sources, sum(x_i/100 * N_i) / N_avg * 100 (cached formula; the
    ##     Propithecus verreauxi block uses AVERAGE, its three N are equal). A source 'n/a' -> not evaluable.
    if (!is.na(avg)) {
      o <- if (anyNA(src)) NA_real_ else sum(src / 100 * fd$n[s]) / fd$n[a] * 100
      add_check(sprintf("weighted_%s_block%02d", v, b), paste0("average ", v, " = N-weighted mean of the sources, ", spb),
                o, avg, 1e-6, if (is.na(o)) NA else abs(o - avg) <= 1e-6, if (is.na(o)) "a source is printed 'n/a'" else "")
    }
    ## 4d. Sheet 'Diet Data' ("Average of ... - see Multiple Sources Sheet") vs this block: against the
    ##     N-weighted average row, and against the unweighted mean of the sources. Tolerance 0.05 (one decimal).
    ddv <- if (is.na(dr)) NA_real_ else num(list(dd[[dd_col[[v]]]][[dr]]), "Diet Data")
    if (!is.na(ddv) || !is.na(avg))
      add_check(sprintf("diet_data_weighted_%s_block%02d", v, b),
                paste0("Diet Data ", v, " = this sheet's average row, ", spb), avg, ddv, 0.05,
                if (is.na(avg) || is.na(ddv)) NA else abs(avg - ddv) <= 0.05 + 1e-9,
                if (is.na(dr)) "species not in Diet Data" else "")
    if (!is.na(ddv)) {
      u <- if (anyNA(src)) NA_real_ else mean(src)
      add_check(sprintf("diet_data_unweighted_%s_block%02d", v, b),
                paste0("Diet Data ", v, " = unweighted mean of the sources, ", spb), u, ddv, 0.05,
                if (is.na(u)) NA else abs(u - ddv) <= 0.05 + 1e-9, if (is.na(u)) "a source is printed 'n/a'" else "")
    }
  }
}
## 4c. Source rows: Fruit+Seeds = Fruit + Seeds, Total Animal = Invertebrates + Vertebrates ('n/a' left out;
##     not evaluable when both parts are 'n/a'). Tolerance 0.1 (three one-decimal values).
part_sum <- function(a, b) ifelse(is.na(a) & is.na(b), NA, rowSums(cbind(a, b), na.rm = TRUE))
for (p in list(c("fruit_seeds_pct", "fruit_pct", "seeds_pct", "Fruit+Seeds = Fruit + Seeds"),
               c("total_animal_pct", "invertebrates_pct", "vertebrates_pct", "Total Animal = Invertebrates + Vertebrates"))) {
  o <- part_sum(fd[[p[2]]], fd[[p[3]]])
  i <- which(row_role == "source" & !is.na(fd[[p[1]]]))
  add_check(sprintf("src_%s_row%03d", sub("_pct$", "", p[1]), rows[i]), paste0(p[4], ", ", fd$species_as_published[i]),
            o[i], fd[[p[1]]][i], 0.1, ifelse(is.na(o[i]), NA, abs(o[i] - fd[[p[1]]][i]) <= 0.1 + 1e-9),
            ifelse(is.na(o[i]), "both parts 'n/a': combined value from the source", ""))
}
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
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.5061%2Fdryad.2547d7wpg_DataFileS1DietMultipleSources
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
