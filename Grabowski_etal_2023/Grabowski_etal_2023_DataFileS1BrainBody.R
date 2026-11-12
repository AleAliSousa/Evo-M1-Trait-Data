## Grabowski_etal_2023_DataFileS1BrainBody.R -- born-digital Dryad workbook sheet -> analysis CSV + public TSV
##
## Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect
##   primate brain-size evolution. Systematic Biology, 72(2), 404-418. https://doi.org/10.1093/sysbio/syac075
##   Data: Dryad https://doi.org/10.5061/dryad.2547d7wpg (registry col C = DOI alt, so Item encoded starts
##   10.5061%2Fdryad.2547d7wpg_).
##
## Item: Data File S1, sheet 'Prmate Brain Body Means ME Data' (sheet name as printed, typo included):
##   "Primate Species Average Endocranial Volume (cc^3) and Body Mass (g), with sample sizes and
##   measurement error" (title row 1).
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched Dryad file
##   Grabowski_SB_Data_File_S1.xlsx is kept under its original name in this folder
##   (sha256 3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08). This script only reads it.
##   This sheet holds no formulas; readxl reads the stored cell values.
##   Layout: row 1 title; row 2 description (A2) + notes on the two error columns (AB2, AC2); row 3 the
##   printed header (29 columns A-AC); rows 4-242 = 239 species rows; no blank or footnote rows.
##
## Observation level: one row = one species as printed (species means of male, female and all
##   individuals; AB/AC = predicted log measurement error of the species means).
## Data role: secondary. ECV and body mass are taken from Isler et al. (2008) and the sources printed in
##   'Source.of.ECV' / 'Source.of.body.mass' (reference_tables/<item>_references.csv); the two
##   measurement-error columns are computed as in Grabowski et al. (2016).
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
item_name <- tools::file_path_sans_ext(basename(.sp))      # Grabowski_etal_2023_DataFileS1BrainBody
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "Grabowski_SB_Data_File_S1.xlsx")
sheet  <- "Prmate Brain Body Means ME Data"

## ---- 1. Read the frozen workbook: every cell as printed (cached values), positional ----
## col_types = "list": numbers stay numbers, text stays text, blank and Excel-error cells are NA.
raw <- suppressMessages(readxl::read_excel(frozen, sheet = sheet, col_names = FALSE, col_types = "list"))
cell_chr <- function(x) vapply(x, function(v) {              # one cell as text (numbers: 15 significant digits)
  if (length(v) == 0L || is.na(v)) return(NA_character_)
  if (is.logical(v)) return(if (v) "TRUE" else "FALSE")
  if (is.numeric(v)) return(format(v, digits = 15, scientific = FALSE, trim = TRUE))
  as.character(v)
}, character(1), USE.NAMES = FALSE)
## Text: U+00A0 -> space, runs of white space -> one space, trimmed; 'n/a' and blanks -> NA. Nothing else changes.
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
int <- function(x, col) {                                    # counts: whole numbers only, else stop
  v <- num(x, col)
  if (any(!is.na(v) & v != round(v))) stop("non-integer count in ", col, call. = FALSE)
  as.integer(v)
}
row_txt <- function(r) txt(lapply(seq_len(ncol(raw)), function(j) raw[[j]][[r]]))

printed_header <- c("Genus_Species", "Isler et al. (2008) Dataset Taxonomy", "10k Trees Species Taxonomy",
                    "Order", "Suborder", "Infraorder", "Parvorder", "Superfamily", "Family", "Subfamily",
                    "Species.group", "Subspecies", "Calculation.of.ECV.species.mean", "Source.of.ECV",
                    "Source.of.body.mass", "ECV.male.mean", "ECV.female.mean", "ECV.species.mean*", "N.male",
                    "N.female", "N.species*", "Body.mass.male.mean", "Body.mass.female.mean",
                    "Body.mass.species.mean*", "N.body.mass.male", "N.body.mass.female", "N.body.mass.species*",
                    "predict.sp.ln_ECV*", "predict.sp.ln_Body.mass*")
if (ncol(raw) < 29L || !identical(row_txt(3)[1:29], printed_header))
  stop("unexpected header in row 3 of '", sheet, "'", call. = FALSE)
if (!startsWith(row_txt(1)[1], "Primate Species Average Endocranial Volume (cc^3) and Body Mass (g)"))
  stop("unexpected title in row 1", call. = FALSE)
if (ncol(raw) > 29L && any(!is.na(unlist(lapply(30:ncol(raw), function(j) txt(raw[[j]]))))))
  stop("cells found right of column AC", call. = FALSE)
## Rows: 1 title, 2 description, 3 header are not data; data = every later row that is not fully blank.
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
rows  <- setdiff(which(!blank), 1:3)                         # Excel row numbers (row 1 is never blank)
if (length(rows) != 239L || min(rows) != 4L || max(rows) != 242L) stop("expected data rows 4-242", call. = FALSE)
P <- function(j) raw[[j]][rows]                              # printed column j, data rows only
## 'Subspecies' (column L) is 'n/a' on every row: dropped, never silently.
if (any(!is.na(txt(P(12))))) stop("column L 'Subspecies' is no longer empty", call. = FALSE)

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
## Units (title row 1): ECV in cc (printed "cc^3"), body mass in g. Project unit added beside the printed
## ECV columns: cc x 1000 -> mm3 (house sec. 6). Body mass is already in g.
ecv_m  <- num(P(16), "ECV.male.mean"); ecv_f <- num(P(17), "ECV.female.mean"); ecv_sp <- num(P(18), "ECV.species.mean*")
final.dataframe <- data.frame(
  species_as_published            = species_as_published,
  Species                         = Species,
  isler_2008_dataset_taxonomy     = txt(P(2)),
  species_10k_trees_taxonomy      = txt(P(3)),
  order                           = txt(P(4)),
  suborder                        = txt(P(5)),
  infraorder                      = txt(P(6)),
  parvorder                       = txt(P(7)),
  superfamily                     = txt(P(8)),
  family                          = txt(P(9)),
  subfamily                       = txt(P(10)),
  species_group                   = txt(P(11)),
  calculation_of_ecv_species_mean = txt(P(13)),
  source_of_ecv                   = txt(P(14)),
  source_of_body_mass             = txt(P(15)),
  ecv_male_mean_cc                = ecv_m,
  ecv_male_mean_mm3               = ecv_m * 1000,
  ecv_female_mean_cc              = ecv_f,
  ecv_female_mean_mm3             = ecv_f * 1000,
  ecv_species_mean_cc             = ecv_sp,
  ecv_species_mean_mm3            = ecv_sp * 1000,
  n_male                          = int(P(19), "N.male"),
  n_female                        = int(P(20), "N.female"),
  n_species                       = int(P(21), "N.species*"),
  body_mass_male_mean_g           = num(P(22), "Body.mass.male.mean"),
  body_mass_female_mean_g         = num(P(23), "Body.mass.female.mean"),
  body_mass_species_mean_g        = num(P(24), "Body.mass.species.mean*"),
  n_body_mass_male                = int(P(25), "N.body.mass.male"),
  n_body_mass_female              = int(P(26), "N.body.mass.female"),
  n_body_mass_species             = int(P(27), "N.body.mass.species*"),
  predict_sp_ln_ecv               = num(P(28), "predict.sp.ln_ECV*"),
  predict_sp_ln_body_mass         = num(P(29), "predict.sp.ln_Body.mass*"),
  observation_level               = "species (means of male, female and all individuals as printed)",
  source_locator                  = paste0("Data File S1 (Grabowski_SB_Data_File_S1.xlsx), sheet '", sheet, "', row ", rows),
  data_role                       = "secondary",
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
calc <- fd$calculation_of_ecv_species_mean
nm <- fd$n_male; nf <- fd$n_female; ns <- fd$n_species

## 4a. ECV species mean. 'm/f' = mean of the male and female means; 'ind' = mean of all individuals,
##     which equals the N-weighted mean of the sex means only when every individual is sexed
##     (N.species = N.male + N.female). Means printed to 2 decimals: tolerance 0.01 (half a unit for the
##     sex means carried into the species mean, plus half a unit for the printed species mean).
i <- which(calc == "m/f" & !is.na(fd$ecv_male_mean_cc) & !is.na(fd$ecv_female_mean_cc) & !is.na(fd$ecv_species_mean_cc))
o <- (fd$ecv_male_mean_cc[i] + fd$ecv_female_mean_cc[i]) / 2
add_check(sprintf("ecv_species_mean_mf_row%03d", rows[i]), paste0("ECV.species.mean = (male + female mean) / 2, ", sp[i]),
          round(o, 6), fd$ecv_species_mean_cc[i], 0.01, abs(o - fd$ecv_species_mean_cc[i]) <= 0.01 + 1e-9)
i <- which(calc == "ind" & !is.na(fd$ecv_species_mean_cc) & !is.na(nm) & !is.na(nf) & !is.na(ns))
part <- function(mean, n) ifelse(n > 0, mean * n, 0)
o <- (part(fd$ecv_male_mean_cc[i], nm[i]) + part(fd$ecv_female_mean_cc[i], nf[i])) / (nm[i] + nf[i])
sexed <- ns[i] == nm[i] + nf[i] & (nm[i] + nf[i]) > 0
add_check(sprintf("ecv_species_mean_ind_row%03d", rows[i]),
          paste0("ECV.species.mean = N-weighted mean of the sex means (all individuals sexed), ", sp[i]),
          round(o, 6), fd$ecv_species_mean_cc[i], 0.01,
          ifelse(sexed & !is.na(o), abs(o - fd$ecv_species_mean_cc[i]) <= 0.01 + 1e-9, NA),
          ifelse(sexed, "", "N.species differs from N.male + N.female (unsexed individuals or N mismatch): not evaluable"))

## 4b. N.species vs N.male + N.female: equal for 'm/f'; at least the sum for 'ind' (unsexed individuals).
i <- which(!is.na(nm) & !is.na(nf) & !is.na(ns) & calc %in% c("m/f", "ind"))
add_check(sprintf("n_species_row%03d", rows[i]),
          ifelse(calc[i] == "m/f", paste0("N.species = N.male + N.female ('m/f'), ", sp[i]),
                 paste0("N.species >= N.male + N.female ('ind'), ", sp[i])),
          nm[i] + nf[i], ns[i], 0, ifelse(calc[i] == "m/f", ns[i] == nm[i] + nf[i], ns[i] >= nm[i] + nf[i]))

## 4c. Body mass species mean = (male + female mean) / 2; integers printed: tolerance 0.5 g.
bm <- fd$body_mass_male_mean_g; bf <- fd$body_mass_female_mean_g; bs <- fd$body_mass_species_mean_g
i <- which(!is.na(bm) & !is.na(bf) & !is.na(bs))
add_check(sprintf("body_mass_species_mean_row%03d", rows[i]), paste0("Body.mass.species.mean = (male + female mean) / 2, ", sp[i]),
          (bm[i] + bf[i]) / 2, bs[i], 0.5, abs((bm[i] + bf[i]) / 2 - bs[i]) <= 0.5 + 1e-9)

## 4d. N.body.mass.species = N.body.mass.male + N.body.mass.female.
ym <- fd$n_body_mass_male; yf <- fd$n_body_mass_female; ys <- fd$n_body_mass_species
i <- which(!is.na(ym) & !is.na(yf) & !is.na(ys))
add_check(sprintf("n_body_mass_species_row%03d", rows[i]), paste0("N.body.mass.species = male + female N, ", sp[i]),
          ym[i] + yf[i], ys[i], 0, ys[i] == ym[i] + yf[i])

## 4e. Totals stated in the Methods (article p. 406): "183 primate species based on 3506 individual
##     observations for brain size and 6608 individual observations for body mass ... each species mean
##     was represented by at least one male and one female". The sheet does not flag that main set; the
##     closest reading (>= 1 male and >= 1 female ECV) is reported, not used to change anything.
sel <- which(!is.na(fd$ecv_species_mean_cc) & !is.na(nm) & !is.na(nf) & nm >= 1 & nf >= 1)
add_check("text_total_species", "species with >= 1 male and >= 1 female ECV vs Methods '183 primate species'",
          length(sel), 183, 0, length(sel) == 183, "the 183-species main set is not flagged in the sheet")
add_check("text_total_ecv_observations", "sum of N.species over those species vs Methods '3506 individual observations for brain size'",
          sum(ns[sel], na.rm = TRUE), 3506, 0, sum(ns[sel], na.rm = TRUE) == 3506, "not reproducible from the sheet")
add_check("text_total_body_mass_observations", "sum of N.body.mass.species over those species vs Methods '6608 individual observations for body mass'",
          sum(ys[sel], na.rm = TRUE), 6608, 0, sum(ys[sel], na.rm = TRUE) == 6608, "not reproducible from the sheet")
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
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.5061%2Fdryad.2547d7wpg_DataFileS1BrainBody
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
