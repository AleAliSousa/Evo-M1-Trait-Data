## Powell_etal_2024_SOMTableS2.R -- born-digital journal SOM workbook sheet -> analysis CSV + public TSV
##
## Powell, V. C. R., Barr, W. A., Hammond, A. S., & Wood, B. A. (2024). Behavioral and phylogenetic correlates
##   of limb length proportions in extant apes and monkeys: Implications for interpreting hominin fossils.
##   Journal of Human Evolution, 190, 103494. https://doi.org/10.1016/j.jhevol.2024.103494
##
## Item: SOM Table S2 (journal file 1-s2.0-S0047248424000022-mmc2.xlsx, sheet 'SOM Table S2'): "SOM Table S2.
##   Descriptive Statistics for anthropoid genera in this study." 27 taxon blocks (26 genera and Homo sapiens),
##   each a heading row and four rows (fem, tib, hum, rad) of n, minimum, maximum, range, mean, variance,
##   coefficient of variation, standard error and SD of the unscaled lengths. Methods 2.1: "Descriptive
##   statistics are provided at the genus level in SOM Table S2"; the footnote: "Descriptive statistics for
##   the unscaled measurements of all genera sampled". They are computed from the SOM Table S1 specimens
##   (table checks 4a reproduce every value).
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched journal file
##   1-s2.0-S0047248424000022-mmc2.xlsx (sha256 29cfee08092ac440661962f1dbd7ae19231b063be0b48592d6fc06ca7b9b647f),
##   original name, this folder; only read here. No formulas (values stored to full precision).
##   Layout: row 1 "SOM Table S2"; row 2 the caption; row 3 the header (10 columns A-J; A printed 'Genus');
##   rows 4-138 = 27 blocks x (heading + 4 measurement rows); row 139 abbreviations and footnote (one cell).
##
## Units: lengths in mm (as SOM Table S1); variance mm2; coefficient of variation = SD / mean (a fraction).
## Observation level: one row = one taxon (genus, or Homo sapiens) x one bone; summary statistics over the
##   SOM Table S1 specimens of that taxon.
## Data role: both (statistics pooled over newly collected and published specimens); per row from the pooled
##   SOM Table S1 rows: secondary if all are secondary (GOmD), primary if all primary, else both.
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
item_name <- tools::file_path_sans_ext(basename(.sp))      # Powell_etal_2024_SOMTableS2
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "1-s2.0-S0047248424000022-mmc2.xlsx")
sheet  <- "SOM Table S2"

## ---- 1. Read the frozen workbook: every cell as printed, positional ----
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
num <- function(x, col) vapply(x, function(v) {
  if (length(v) == 0L || is.na(v)) return(NA_real_)
  if (is.numeric(v)) return(as.numeric(v))
  s <- trimws(gsub("\u00a0", " ", as.character(v), fixed = TRUE))
  if (s %in% c("", "n/a")) return(NA_real_)
  r <- suppressWarnings(as.numeric(s))
  if (is.logical(v) || is.na(r)) stop("non-numeric cell in ", col, ": ", s, call. = FALSE)
  r
}, numeric(1), USE.NAMES = FALSE)
read_sheet <- function(s) suppressMessages(readxl::read_excel(frozen, sheet = s, col_names = FALSE, col_types = "list"))
raw <- read_sheet(sheet)
row_txt <- function(r, x = raw) txt(lapply(seq_len(ncol(x)), function(j) x[[j]][[r]]))

printed_header <- c("Genus", "n", "Minimum", "Maximum", "Range", "Mean", "Variance", "Coefficient of variation",
                    "Standard error", "SD")
if (ncol(raw) != 10L || !identical(row_txt(3), printed_header))
  stop("unexpected header in row 3 of '", sheet, "'", call. = FALSE)
if (!identical(row_txt(1)[1], "SOM Table S2") || !identical(row_txt(2)[1], "Descriptive Statistics for anthropoid genera in this study."))
  stop("unexpected title rows 1-2", call. = FALSE)
if (!startsWith(row_txt(139)[1], "Abbreviations: fem = femur;")) stop("unexpected footnote row 139", call. = FALSE)
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
if (nrow(raw) > 139L && !all(blank[140:nrow(raw)])) stop("cells found below the footnote row", call. = FALSE)
## Rows 4-138: a heading row (only column A filled) opens each block; the four rows below it are data.
body    <- (4:138)[!blank[4:138]]
heading <- body[vapply(body, function(r) all(is.na(row_txt(r)[2:10])), logical(1))]
rows    <- setdiff(body, heading)
if (length(heading) != 27L || length(rows) != 108L) stop("expected 27 blocks of 4 rows", call. = FALSE)
label <- vapply(rows, function(r) row_txt(max(heading[heading < r]))[1], character(1))   # the block heading above
P <- function(j) raw[[j]][rows]
measurement <- txt(P(1))
if (!all(measurement == rep(c("fem", "tib", "hum", "rad"), 27L))) stop("blocks are not fem, tib, hum, rad", call. = FALSE)

## ---- 2. Species: the printed block heading kept; accepted name via the General key ----
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", basename(folder), "' in _keys/General/species_key.csv", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
species_as_published <- label                                 # 'Homo sapiens' or a genus ('Aloutta' as printed)
if (!all(tolower(species_as_published) %in% names(lk)))
  stop("Unkeyed printed name: ", paste(unique(species_as_published[!tolower(species_as_published) %in% names(lk)]),
                                      collapse = ", "), call. = FALSE)
Species <- unname(lk[tolower(species_as_published)])
Species[!is.na(Species) & !nzchar(trimws(Species))] <- NA_character_

## ---- 3. The SOM Table S1 specimens behind each block (for data_role and the checks) ----
## A block pools the S1 rows whose printed Genus (or Genus + Species, for 'Homo sapiens') equals the heading;
## when no printed genus matches ('Aloutta'; 'Piliocolobus', printed 'Procolobus' in S1) the rows whose
## accepted genus equals the heading's accepted genus. Cebus pools C. albifrons and C. apella as printed
## (Table 1 footnote k).
s1 <- read_sheet("SOM Table S1")
s1r <- 4:1828
s1_genus <- txt(s1[[1]][s1r]); s1_sp <- paste(s1_genus, txt(s1[[2]][s1r]))
if (!all(tolower(s1_sp) %in% names(lk))) stop("S1 name missing from the key", call. = FALSE)
s1_acc_genus <- sub(" .*$", "", unname(lk[tolower(s1_sp)]))
s1_coll <- txt(s1[[3]][s1r])
s1_len <- list(fem = num(s1[[8]][s1r], "fem"), tib = num(s1[[9]][s1r], "tib"),
               hum = num(s1[[10]][s1r], "hum"), rad = num(s1[[11]][s1r], "rad"))
members <- lapply(unique(label), function(l) {
  m <- which(s1_genus == l | s1_sp == l)
  if (!length(m)) m <- which(s1_acc_genus == sub(" .*$", "", unname(lk[tolower(l)])))
  m
})
names(members) <- unique(label)
if (any(lengths(members) == 0L)) stop("a block has no S1 specimens", call. = FALSE)
s1_role <- ifelse(s1_coll == "GOmD", "secondary", ifelse(s1_coll == "MCZ", "both", "primary"))
block_role <- vapply(members, function(m) { u <- unique(s1_role[m]); if (length(u) == 1L) u else "both" }, character(1))

## ---- 4. Analysis table: one row per printed data row, printed column order ----
final.dataframe <- data.frame(
  species_as_published     = species_as_published,
  Species                  = Species,
  measurement              = measurement,
  n                        = as.integer(num(P(2), "n")),
  minimum_mm               = num(P(3), "Minimum"),
  maximum_mm               = num(P(4), "Maximum"),
  range_mm                 = num(P(5), "Range"),
  mean_mm                  = num(P(6), "Mean"),
  variance_mm2             = num(P(7), "Variance"),
  coefficient_of_variation = num(P(8), "Coefficient of variation"),
  standard_error_mm        = num(P(9), "Standard error"),
  sd_mm                    = num(P(10), "SD"),
  observation_level        = "taxon (genus, or Homo sapiens) x bone: summary statistics over the SOM Table S1 specimens",
  source_locator           = paste0("SOM Table S2 (1-s2.0-S0047248424000022-mmc2.xlsx), sheet '", sheet, "', row ", rows),
  data_role                = unname(block_role[label]),
  stringsAsFactors = FALSE, check.names = FALSE)

## ---- 5. Table checks (build HOWTO sec. 7a): every statistic recomputed from SOM Table S1 ----
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
## n, minimum, maximum exact; the others relative 1e-9 (S2 stores ~15 significant digits). Variance and SD
## with denominator n - 1; standard error = SD / sqrt(n); coefficient of variation = SD / mean; range = max - min.
for (i in seq_len(nrow(fd))) {
  x <- s1_len[[fd$measurement[i]]][members[[label[i]]]]
  st <- c(n = length(x), minimum_mm = min(x), maximum_mm = max(x), range_mm = max(x) - min(x), mean_mm = mean(x),
          variance_mm2 = stats::var(x), coefficient_of_variation = stats::sd(x) / mean(x),
          standard_error_mm = stats::sd(x) / sqrt(length(x)), sd_mm = stats::sd(x))
  for (v in names(st)) {
    exact <- v %in% c("n", "minimum_mm", "maximum_mm")
    tol <- if (exact) 0 else 1e-9 * abs(fd[[v]][i])
    add_check(sprintf("%s_%s_%s", gsub(" ", "_", label[i]), fd$measurement[i], v),
              paste0(v, " of ", fd$measurement[i], " recomputed from the ", length(x), " SOM Table S1 specimens of ", label[i]),
              unname(st[[v]]), fd[[v]][i], tol, abs(unname(st[[v]]) - fd[[v]][i]) <= tol,
              if (exact) "" else "relative tolerance 1e-9")
  }
}
table_checks <- do.call(rbind, tc)
if (any(table_checks$status == "mismatch"))
  warning(sum(table_checks$status == "mismatch"), " table check(s) did not pass -- values kept as printed; ",
          "see the ReadMe '## Table checks'", call. = FALSE)

## ---- 6. Write the analysis CSV (UTF-8 with BOM, house C6) ----
.csv_txt <- enc2utf8(paste0(paste(utils::capture.output(
  utils::write.csv(final.dataframe, stdout(), row.names = FALSE, na = "")), collapse = "\n"), "\n"))
.con <- file(file.path(folder, paste0(item_name, ".csv")), open = "wb")
writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), .con); writeBin(charToRaw(.csv_txt), .con); close(.con)

## ---- 7. Public TSV: Item encoded looked up by Item name in __ReadMe.xlsx ----
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.1016%2Fj.jhevol.2024.103494_SOMTableS2
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- public TSV NOT written.", call. = FALSE)
} else {
  tsv_path <- file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}

## ---- 8. Validate ----
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
        " accepted taxa; table checks: ", paste(names(table(table_checks$status)), table(table_checks$status),
                                                sep = " = ", collapse = ", "))
