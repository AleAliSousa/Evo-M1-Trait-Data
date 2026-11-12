## Melchionna_etal_2020_SupplementaryAppendix.R -- born-digital journal workbook -> analysis CSV + public TSV
##
## Melchionna, M., Mondanaro, A., Serio, C., Castiglione, S., Di Febbraro, M., Rook, L., Diniz-Filho, J. A. F.,
##   Manzi, G., Profico, A., Sansalone, G., & Raia, P. (2020). Macroevolutionary trends of brain mass in
##   Primates. Biological Journal of the Linnean Society, 129(1), 14-25. https://doi.org/10.1093/biolinnean/blz161
##
## Item: Supporting Information, Appendix S1 (journal file blz161_suppl_supplementary_appendix.xlsx, sheet
##   'Appendix 1'): body mass, endocranial volume (ECV) and EQ of 317 primate species, extant (248) and
##   extinct (69), each with the source of the body mass and of the ECV ("We collected from the literature
##   estimates of primate body mass and endocranial volume (ECV; see Supporting Information, Appendix S1)").
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched journal file
##   blz161_suppl_supplementary_appendix.xlsx is kept under its original name in this folder
##   (sha256 980857464f6b453b0a02c762803012db5973fdea57e30714331e04e0c9491677). This script only reads it.
##   The sheet holds no formulas. Layout: row 1 header (8 columns A-H); rows 2-318 = 317 species rows; no
##   title, blank or footnote rows. The citation cells contain no-break spaces (U+00A0) and line breaks.
##
## Units: not printed. Body mass in g and ECV in cm3 (cc): the printed EQ is reproduced exactly by the paper's
##   eq. 1, EQ = ECV / e^(0.60 ln(BM) - 1.402) (Grabowski et al. 2016), whose coefficients are for g and cc
##   (table check 4a). Project unit added beside ECV: cm3 x 1000 -> mm3.
## Observation level: one row = one species (extant or extinct) as printed.
## Data role: secondary (values from the works printed in 'body mass ref' / 'ECV ref'); three body masses
##   are the authors' own estimates ("ours; calculated from the relationship between mandible size and body
##   size", equation from Raia et al. 2018): those rows are 'both'.
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
item_name <- tools::file_path_sans_ext(basename(.sp))      # Melchionna_etal_2020_SupplementaryAppendix
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "blz161_suppl_supplementary_appendix.xlsx")
sheet  <- "Appendix 1"

## ---- 1. Read the frozen workbook: every cell as printed, positional ----
raw <- suppressMessages(readxl::read_excel(frozen, sheet = sheet, col_names = FALSE, col_types = "list"))
cell_chr <- function(x) vapply(x, function(v) {
  if (length(v) == 0L || is.na(v)) return(NA_character_)
  if (is.logical(v)) return(if (v) "TRUE" else "FALSE")
  if (is.numeric(v)) return(format(v, digits = 15, scientific = FALSE, trim = TRUE))
  as.character(v)
}, character(1), USE.NAMES = FALSE)
## Text: U+00A0 -> space, runs of white space (line breaks included) -> one space, trimmed; 'n/a' -> NA.
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
row_txt <- function(r) txt(lapply(seq_len(ncol(raw)), function(j) raw[[j]][[r]]))

printed_header <- c("body mass ref", "ECV ref", "family", "spec", "state", "body mass", "ECV", "EQ")
if (ncol(raw) != 8L || !identical(row_txt(1), printed_header))
  stop("unexpected header in row 1 of '", sheet, "'", call. = FALSE)
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
rows  <- setdiff(which(!blank), 1L)
if (length(rows) != 317L || min(rows) != 2L || max(rows) != 318L) stop("expected data rows 2-318", call. = FALSE)
P <- function(j) raw[[j]][rows]

## ---- 2. Species: printed name kept; accepted name via the General collection key ----
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", basename(folder), "' in _keys/General/species_key.csv", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
species_as_published <- txt(P(4))
if (!all(tolower(species_as_published) %in% names(lk)))
  stop("Unkeyed printed name: ", paste(unique(species_as_published[!tolower(species_as_published) %in% names(lk)]),
                                      collapse = ", "), call. = FALSE)
Species <- unname(lk[tolower(species_as_published)])
Species[!is.na(Species) & !nzchar(trimws(Species))] <- NA_character_

## ---- 3. Analysis table: one row per printed row, printed column order ----
body_mass_ref <- txt(P(1))
ecv_cm3 <- num(P(7), "ECV")
final.dataframe <- data.frame(
  body_mass_ref        = body_mass_ref,
  ecv_ref              = txt(P(2)),
  family               = txt(P(3)),
  species_as_published = species_as_published,
  Species              = Species,
  state                = txt(P(5)),
  body_mass_g          = num(P(6), "body mass"),
  ecv_cm3              = ecv_cm3,
  ecv_mm3              = ecv_cm3 * 1000,
  eq                   = num(P(8), "EQ"),
  observation_level    = "species (one value per species as printed; extant and extinct)",
  source_locator       = paste0("Appendix S1 (blz161_suppl_supplementary_appendix.xlsx), sheet '", sheet, "', row ", rows),
  data_role            = ifelse(startsWith(body_mass_ref, "ours;"), "both", "secondary"),
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
## 4a. EQ = ECV / e^(0.60 ln(BM) - 1.402) (article eq. 1, Grabowski et al. 2016); stored to full precision:
##     relative tolerance 1e-9.
o <- fd$ecv_cm3 / exp(0.60 * log(fd$body_mass_g) - 1.402)
i <- which(!is.na(fd$eq))
add_check(sprintf("eq_row%03d", rows[i]), paste0("EQ = ECV / exp(0.60 ln(body mass) - 1.402), ", fd$species_as_published[i]),
          o[i], fd$eq[i], 1e-9, ifelse(is.na(o[i]), NA, abs(o[i] - fd$eq[i]) <= 1e-9 * abs(fd$eq[i])), "relative tolerance")
## 4b. Totals in Material and methods (PDF p. 15): "317 species, both extant (248) and extinct (69)".
k <- length(unique(fd$species_as_published))
add_check("text_total_species", "distinct printed species vs Methods '317 species'", k, 317, 0, k == 317)
k <- sum(fd$state %in% "extant")
add_check("text_total_extant", "rows with state 'extant' vs Methods 'extant (248)'", k, 248, 0, k == 248)
k <- sum(fd$state %in% "extinct")
add_check("text_total_extinct", "rows with state 'extinct' vs Methods 'extinct (69)'", k, 69, 0, k == 69)
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
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.1093%2Fbiolinnean%2Fblz161_SupplementaryAppendix
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
