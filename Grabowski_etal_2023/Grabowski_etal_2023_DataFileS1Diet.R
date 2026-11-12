## Grabowski_etal_2023_DataFileS1Diet.R -- born-digital Dryad workbook sheet -> analysis CSV + public TSV
##
## Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect
##   primate brain-size evolution. Systematic Biology, 72(2), 404-418. https://doi.org/10.1093/sysbio/syac075
##   Data: Dryad https://doi.org/10.5061/dryad.2547d7wpg (registry col C = DOI alt).
##
## Item: Data File S1, sheet 'Diet Data': percentage of feeding time per food category per species, the
##   four Nunn & van Schaik (2002) categories and the frugivory / folivory classifications (title = note in
##   A1: "Diet Data - species in green have data on % feeding time on each food category; ...").
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched Dryad file
##   Grabowski_SB_Data_File_S1.xlsx (sha256 3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08),
##   original name, this folder; only read here.
##   FORMULAS: 2,751 cells of this sheet are Excel formulas (M on 2 rows, X, Z-AK). readxl returns their
##   CACHED results (the values Excel last saved); every formula cell has a cached value (checked at build:
##   0 missing), 12 are cached as #VALUE! (M80, AA80, AC80, AD80, AG80, AJ80, AK80, M227, AA227, AC227, AD227,
##   AG227: rows where a summed cell holds text) and are read as NA. Optional audit with tidyxl below.
##   Layout: row 1 notes (A1 description; Y1, Z1, AF1, AJ1, AK1, AL1 column notes); row 2 the printed header
##   (38 columns A-AL); rows 3-360 = 358 species rows; no blank or footnote rows.
##
## Observation level: one row = one species as printed (percentages of feeding time from one source, an
##   average of several -- see sheet 'Diet Data - Multiple Sources' -- or a compilation).
## Data role: secondary (compiled from the field studies printed in 'Diet.Reference' / 'Compilation Sources';
##   reference_tables/<item>_references.csv). Columns X-AL are the authors' derived sums and classifications.
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
item_name <- tools::file_path_sans_ext(basename(.sp))      # Grabowski_etal_2023_DataFileS1Diet
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "Grabowski_SB_Data_File_S1.xlsx")
sheet  <- "Diet Data"

## ---- 1. Read the frozen workbook: every cell as printed (cached values), positional ----
## col_types = "list": numbers stay numbers, text stays text, blank and Excel-error cells are NA.
raw <- suppressMessages(readxl::read_excel(frozen, sheet = sheet, col_names = FALSE, col_types = "list"))
if (requireNamespace("tidyxl", quietly = TRUE)) {            # optional: formula cells and their cached values
  fx <- tidyxl::xlsx_cells(frozen, sheets = sheet); fx <- fx[!is.na(fx$formula), ]
  message(sheet, ": ", nrow(fx), " formula cells, ", sum(fx$data_type == "blank"), " without a cached value, ",
          sum(fx$data_type == "error"), " cached as an Excel error (expected 2751, 0, 12)")
}
cell_chr <- function(x) vapply(x, function(v) {              # one cell as text (numbers: 15 significant digits)
  if (length(v) == 0L || is.na(v)) return(NA_character_)
  if (is.logical(v)) return(if (v) "TRUE" else "FALSE")
  if (is.numeric(v)) return(format(v, digits = 15, scientific = FALSE, trim = TRUE))
  as.character(v)
}, character(1), USE.NAMES = FALSE)
## Text: U+00A0 -> space, runs of white space -> one space, trimmed; 'n/a' and blanks -> NA. Nothing else changes
## (the Mac Roman mojibake printed in some cells, e.g. 'Corr\u221a\u2122a', is kept as printed).
txt <- function(x) {
  x <- trimws(gsub("[[:space:]]+", " ", gsub("\u00a0", " ", cell_chr(x), fixed = TRUE)))
  x[!is.na(x) & (x == "" | x == "n/a")] <- NA_character_
  x
}
## Numbers: a number stays as stored; 'n/a' and blanks -> NA; any other text stops the build.
num <- function(x, col) vapply(x, function(v) {
  if (length(v) == 0L || is.na(v)) return(NA_real_)
  if (is.numeric(v)) return(as.numeric(v))
  s <- trimws(gsub("\u00a0", " ", as.character(v), fixed = TRUE))
  if (s %in% c("", "n/a")) return(NA_real_)
  r <- suppressWarnings(as.numeric(s))
  if (is.logical(v) || is.na(r)) stop("non-numeric cell in ", col, ": ", s, call. = FALSE)
  r
}, numeric(1), USE.NAMES = FALSE)
row_txt <- function(r) txt(lapply(seq_len(ncol(raw)), function(j) raw[[j]][[r]]))

printed_header <- c("Genus_Species", "To.Use", "Percent Feeding Data", "Species.name.adjusted.to.10kTrees",
                    "Synonyms", "Family", "Diet.Reference", "Compilation Sources", "Leaves", "Flowers", "Fruit",
                    "Seeds", "Fruit+Seeds", "Invertebrates", "Vertebrates", "Total.Animal", "Gum", "Roots",
                    "Other.Plant.Matter", "Fungus", "Nectar", "Buds", "Other", "Sum", "Vs.100", "Total.Leaves",
                    "Total.Fruit", "Animal", "High.Cal.Non.Animal", "Reproductive", "Structural", "Fauna",
                    "Reproductive.Parts", "Vegetative.Parts", "Exudates", "Frug.Non.Frug.Per*", "Fol.Non.Fol.Per*",
                    "Fol.Non.Fol.Strict*")
if (ncol(raw) < 38L || !identical(row_txt(2)[1:38], printed_header))
  stop("unexpected header in row 2 of '", sheet, "'", call. = FALSE)
if (!startsWith(row_txt(1)[1], "Diet Data - species in green have data on % feeding time"))
  stop("unexpected note in A1", call. = FALSE)
if (ncol(raw) > 38L && any(!is.na(unlist(lapply(39:ncol(raw), function(j) txt(raw[[j]]))))))
  stop("cells found right of column AL", call. = FALSE)
## Rows: 1 notes, 2 header are not data; data = every later row that is not fully blank.
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
rows  <- setdiff(which(!blank), 1:2)
if (length(rows) != 358L || min(rows) != 3L || max(rows) != 360L) stop("expected data rows 3-360", call. = FALSE)
P <- function(j) raw[[j]][rows]

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
Species[!is.na(Species) & !nzchar(trimws(Species))] <- NA_character_   # basis 'unresolved' -> NA

## ---- 3. Analysis table: one row per printed row, printed column order ----
## Units: percentage of feeding time (0-100); Sum and Vs.100 in percentage points. Codes as printed:
## To.Use / Percent Feeding Data Yes/No; Frug/Non.Frug; Fol/Non.Fol.
pct_cols <- c(leaves_pct = 9, flowers_pct = 10, fruit_pct = 11, seeds_pct = 12, fruit_seeds_pct = 13,
              invertebrates_pct = 14, vertebrates_pct = 15, total_animal_pct = 16, gum_pct = 17, roots_pct = 18,
              other_plant_matter_pct = 19, fungus_pct = 20, nectar_pct = 21, buds_pct = 22, other_pct = 23,
              sum_pct = 24, vs_100_pct = 25, total_leaves_pct = 26, total_fruit_pct = 27, animal_pct = 28,
              high_cal_non_animal_pct = 29, reproductive_pct = 30, structural_pct = 31, fauna_pct = 32,
              reproductive_parts_pct = 33, vegetative_parts_pct = 34, exudates_pct = 35)
final.dataframe <- data.frame(
  species_as_published              = species_as_published,
  Species                           = Species,
  to_use                            = txt(P(2)),
  percent_feeding_data              = txt(P(3)),
  species_name_adjusted_to_10ktrees = txt(P(4)),
  synonyms                          = txt(P(5)),
  family                            = txt(P(6)),
  diet_reference                    = txt(P(7)),
  compilation_sources               = txt(P(8)),
  stringsAsFactors = FALSE, check.names = FALSE)
for (nm_ in names(pct_cols)) final.dataframe[[nm_]] <- num(P(pct_cols[[nm_]]), printed_header[pct_cols[[nm_]]])
final.dataframe$frug_non_frug_per  <- txt(P(36))
final.dataframe$fol_non_fol_per    <- txt(P(37))
final.dataframe$fol_non_fol_strict <- txt(P(38))
final.dataframe$observation_level  <- "species (percentage of feeding time as printed: one source, an average of sources, or a compilation)"
final.dataframe$source_locator     <- paste0("Data File S1 (Grabowski_SB_Data_File_S1.xlsx), sheet '", sheet, "', row ", rows)
final.dataframe$data_role          <- "secondary"

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
V  <- function(...) as.matrix(fd[, c(...), drop = FALSE])
xl_sum <- function(...) rowSums(V(...), na.rm = TRUE)               # Excel SUM: text ('n/a') ignored, 0 if none
num_check <- function(prefix, basis, obs, prn, tol, note = "") {    # one check per printed number
  i <- which(!is.na(prn))
  add_check(sprintf("%s_row%03d", prefix, rows[i]), paste0(basis, ", ", sp[i]), obs[i], prn[i], tol,
            ifelse(is.na(obs[i]), NA, abs(obs[i] - prn[i]) <= tol + 1e-9), if (length(note) > 1L) note[i] else note)
}

## 4a. Sum = SUM(I, J, K, L, P, Q:W) (cached formula; Fruit+Seeds and the two animal parts are not summed).
num_check("sum", "Sum = SUM(Leaves, Flowers, Fruit, Seeds, Total.Animal, Gum ... Other)",
          xl_sum("leaves_pct", "flowers_pct", "fruit_pct", "seeds_pct", "total_animal_pct", "gum_pct", "roots_pct",
                 "other_plant_matter_pct", "fungus_pct", "nectar_pct", "buds_pct", "other_pct"), fd$sum_pct, 1e-6)
## 4b. The categories of one source should sum to ~100% of feeding time: |Sum - 100| <= 1 point.
num_check("sum_vs_100", "Sum within 1 percentage point of 100", rep(100, nrow(fd)), fd$sum_pct, 1,
          ifelse(abs(fd$sum_pct - 100) > 1 + 1e-9, "categories as printed do not add up to 100", ""))
## 4c. Vs.100 = 100 - Sum (typed values, one printed decimal: tolerance 0.05).
num_check("vs_100", "Vs.100 = 100 - Sum", 100 - fd$sum_pct, fd$vs_100_pct, 0.05,
          ifelse(!is.na(fd$sum_pct) & abs(100 - fd$sum_pct - fd$vs_100_pct) > 0.05 + 1e-9,
                 "typed value differs from 100 - Sum (not updated after the categories changed?)", ""))
## 4d. Fruit+Seeds = Fruit + Seeds and Total.Animal = Invertebrates + Vertebrates ('n/a' left out). When
##     both parts are 'n/a' the printed total is the source's own combined value: not evaluable.
##     Three printed one-decimal values: tolerance 0.1.
part_sum <- function(a, b) ifelse(is.na(a) & is.na(b), NA, rowSums(cbind(a, b), na.rm = TRUE))
num_check("fruit_seeds", "Fruit+Seeds = Fruit + Seeds", part_sum(fd$fruit_pct, fd$seeds_pct), fd$fruit_seeds_pct, 0.1,
          ifelse(is.na(fd$fruit_pct) & is.na(fd$seeds_pct), "Fruit and Seeds are n/a: combined value from the source", ""))
num_check("total_animal", "Total.Animal = Invertebrates + Vertebrates", part_sum(fd$invertebrates_pct, fd$vertebrates_pct),
          fd$total_animal_pct, 0.1,
          ifelse(is.na(fd$invertebrates_pct) & is.na(fd$vertebrates_pct), "Invertebrates and Vertebrates are n/a: total from the source", ""))
## 4e. Derived columns (cached formulas, row 1 notes: categories following Nunn and van Schaik 2002).
num_check("total_leaves", "Total.Leaves = Leaves", fd$leaves_pct, fd$total_leaves_pct, 1e-6)
num_check("total_fruit", "Total.Fruit = Fruit+Seeds", fd$fruit_seeds_pct, fd$total_fruit_pct, 1e-6)
num_check("animal", "Animal = Total.Animal", fd$total_animal_pct, fd$animal_pct, 1e-6)
num_check("high_cal_non_animal", "High.Cal.Non.Animal = SUM(Flowers, Fruit+Seeds, Gum, Nectar, Buds)",
          xl_sum("flowers_pct", "fruit_seeds_pct", "gum_pct", "nectar_pct", "buds_pct"), fd$high_cal_non_animal_pct, 1e-6)
num_check("reproductive", "Reproductive = SUM(Flowers, Fruit+Seeds, Nectar, Buds)",
          xl_sum("flowers_pct", "fruit_seeds_pct", "nectar_pct", "buds_pct"), fd$reproductive_pct, 1e-6)
num_check("structural", "Structural = SUM(Leaves, Gum, Roots, Other.Plant.Matter, Fungus)",
          xl_sum("leaves_pct", "gum_pct", "roots_pct", "other_plant_matter_pct", "fungus_pct"), fd$structural_pct, 1e-6)
num_check("fauna", "Fauna = Total.Animal", fd$total_animal_pct, fd$fauna_pct, 1e-6)
num_check("reproductive_parts", "Reproductive.Parts = SUM(Flowers, Fruit+Seeds, Nectar, Buds)",
          xl_sum("flowers_pct", "fruit_seeds_pct", "nectar_pct", "buds_pct"), fd$reproductive_parts_pct, 1e-6)
num_check("vegetative_parts", "Vegetative.Parts = SUM(Leaves, Roots, Other.Plant.Matter)",
          xl_sum("leaves_pct", "roots_pct", "other_plant_matter_pct"), fd$vegetative_parts_pct, 1e-6)
num_check("exudates", "Exudates = Gum", fd$gum_pct, fd$exudates_pct, 1e-6)

## 4f. Frug.Non.Frug.Per* / Fol.Non.Fol.Per* (used in the main analysis). Cached formula:
##     IF(AND(AG > AF, AG > AH, AG > AI), "Frug", "Non.Frug") on Fauna (AF), Reproductive.Parts (AG),
##     Vegetative.Parts (AH), Exudates (AI); AK the same with AH. In Excel any text ('n/a') compares greater
##     than any number, so a category printed 'n/a' makes the comparison FALSE. Two readings are checked:
##     (i) the Excel rule on the row's own cells; (ii) the Methods rule (largest of the four categories,
##     'n/a' = no data, left out).
xl_gt <- function(a, b) mapply(function(x, y) {
  if (length(x) == 0L || length(y) == 0L || is.na(x) || is.na(y)) return(NA)
  if (is.character(x) && is.character(y)) return(tolower(x) > tolower(y))
  if (is.character(x)) return(TRUE)
  if (is.character(y)) return(FALSE)
  x > y
}, a, b, USE.NAMES = FALSE)
xl_and <- function(...) { m <- cbind(...); ifelse(rowSums(is.na(m)) > 0, NA, rowSums(m) == ncol(m)) }
AF <- P(32); AG <- P(33); AH <- P(34); AI <- P(35)
xl_frug <- ifelse(xl_and(xl_gt(AG, AF), xl_gt(AG, AH), xl_gt(AG, AI)), "Frug", "Non.Frug")
xl_fol  <- ifelse(xl_and(xl_gt(AH, AF), xl_gt(AH, AG), xl_gt(AH, AI)), "Fol", "Non.Fol")
cls_check <- function(prefix, basis, obs, prn, note = "") {
  i <- which(!is.na(prn))
  add_check(sprintf("%s_row%03d", prefix, rows[i]), paste0(basis, ", ", sp[i]), obs[i], prn[i], 0,
            ifelse(is.na(obs[i]), NA, obs[i] == prn[i]), if (length(note) > 1L) note[i] else note)
}
prev <- function(x) c(NA, x[-length(x)])                             # the value computed for the row above
cls_check("frug_excel", "Frug.Non.Frug.Per* = Excel rule on this row's Fauna/Reproductive/Vegetative/Exudates",
          xl_frug, fd$frug_non_frug_per,
          ifelse(!is.na(xl_frug) & !is.na(prev(xl_frug)) & xl_frug != fd$frug_non_frug_per & prev(xl_frug) == fd$frug_non_frug_per,
                 "printed value is the rule applied to the row above (formula references row r-1)", ""))
cls_check("fol_excel", "Fol.Non.Fol.Per* = Excel rule on this row's Fauna/Reproductive/Vegetative/Exudates",
          xl_fol, fd$fol_non_fol_per,
          ifelse(!is.na(xl_fol) & !is.na(prev(xl_fol)) & xl_fol != fd$fol_non_fol_per & prev(xl_fol) == fd$fol_non_fol_per,
                 "printed value is the rule applied to the row above (formula references row r-1)", ""))
f4 <- V("fauna_pct", "reproductive_parts_pct", "vegetative_parts_pct", "exudates_pct")
largest <- function(k) {                                             # Methods rule, 'n/a' left out
  others <- f4[, -k, drop = FALSE]
  mx <- suppressWarnings(apply(others, 1, function(z) if (all(is.na(z))) -Inf else max(z, na.rm = TRUE)))
  ifelse(is.na(f4[, k]), NA, f4[, k] > mx)
}
rule_frug <- ifelse(largest(2), "Frug", "Non.Frug"); rule_fol <- ifelse(largest(3), "Fol", "Non.Fol")
cls_check("frug_rule", "Frug.Non.Frug.Per* = Methods rule (reproductive parts the largest of the 4 categories, n/a left out)",
          rule_frug, fd$frug_non_frug_per,
          ifelse(!is.na(rule_frug) & rule_frug != fd$frug_non_frug_per,
                 "differs from the Methods rule: an 'n/a' category (text) makes Excel's comparison FALSE, or the formula references the row above", ""))
cls_check("fol_rule", "Fol.Non.Fol.Per* = Methods rule (vegetative parts the largest of the 4 categories, n/a left out)",
          rule_fol, fd$fol_non_fol_per,
          ifelse(!is.na(rule_fol) & rule_fol != fd$fol_non_fol_per,
                 "differs from the Methods rule: an 'n/a' category (text) makes Excel's comparison FALSE", ""))
## 4g. 'To.Use' and 'Percent Feeding Data' (A1: both mark the species with % feeding data) agree.
i <- which(!is.na(fd$to_use) | !is.na(fd$percent_feeding_data))
add_check(sprintf("to_use_row%03d", rows[i]), paste0("To.Use = Percent Feeding Data, ", sp[i]),
          fd$to_use[i], fd$percent_feeding_data[i], 0, fd$to_use[i] == fd$percent_feeding_data[i])
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
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.5061%2Fdryad.2547d7wpg_DataFileS1Diet
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
