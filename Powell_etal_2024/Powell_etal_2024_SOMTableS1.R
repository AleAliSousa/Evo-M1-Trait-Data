## Powell_etal_2024_SOMTableS1.R -- born-digital journal SOM workbook sheet -> analysis CSV + public TSV
##
## Powell, V. C. R., Barr, W. A., Hammond, A. S., & Wood, B. A. (2024). Behavioral and phylogenetic correlates
##   of limb length proportions in extant apes and monkeys: Implications for interpreting hominin fossils.
##   Journal of Human Evolution, 190, 103494. https://doi.org/10.1016/j.jhevol.2024.103494
##
## Item: SOM Table S1 (journal file 1-s2.0-S0047248424000022-mmc2.xlsx, sheet 'SOM Table S1'): "SOM Table S1.
##   Complete anthropoid sample included in the current study." One row per specimen: genus, species,
##   collection, locality, ID, sex, superfamily, the four long-bone maximum lengths (humerus HML, radius RML,
##   femur FML, tibia TML), the Mosimann-adjusted ratios (bone / geometric mean of the four), fore- and hindlimb
##   lengths and the indices IMI, HFI, BRI, CRI (article Table 3).
##
## Frozen source -- DIGITAL-NATIVE, NO DERIVED SNAPSHOT (build HOWTO sec. 0a): the untouched journal file
##   1-s2.0-S0047248424000022-mmc2.xlsx is kept under its original name in this folder
##   (sha256 29cfee08092ac440661962f1dbd7ae19231b063be0b48592d6fc06ca7b9b647f). This script only reads it.
##   The sheet holds no formulas (all values typed/stored). Layout: row 1 title "SOM Table S1 / Complete
##   anthropoid sample included in the current study. A"; row 2 the caption with footnote marker a; row 3 the
##   header (21 columns A-U; 'Localityb' carries footnote b, 'ID ' a trailing space); rows 4-1828 = 1,825
##   specimens; row 1829 abbreviations + footnotes a and b (one cell).
##
## Units: lengths in mm (calipers / osteometric boards; Methods 2.2; not printed in the table). Ratios and
##   indices dimensionless (indices x 100, Table 3).
## Observation level: one row = one specimen (individual).
## Data role: both (abstract: "a mix of newly-collected and published data"). Per row: GOmD = Goldman
##   Osteometric Dataset (Auerbach and Ruff 2004, 2006) -> secondary; MCZ ("Specimens of the Museum of
##   Comparative Zoology, Harvard, and data from Auerbach and Ruff (2004, 2006)", Table 1 footnote f) -> both;
##   all other collections (measured by the authors or provided to them) -> primary.
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
item_name <- tools::file_path_sans_ext(basename(.sp))      # Powell_etal_2024_SOMTableS1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d })
source(file.path(base, "_tools", "dataset_builder", "load_dataset_builder.R"))
frozen <- file.path(folder, "1-s2.0-S0047248424000022-mmc2.xlsx")
sheet  <- "SOM Table S1"

## ---- 1. Read the frozen workbook: every cell as printed, positional ----
raw <- suppressMessages(readxl::read_excel(frozen, sheet = sheet, col_names = FALSE, col_types = "list"))
cell_chr <- function(x) vapply(x, function(v) {              # one cell as text (numbers: 15 significant digits)
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

printed_header <- c("Genus", "Species", "Collection", "Localityb", "ID", "Sex", "Superfamily", "fem", "tib", "hum",
                    "rad", "gFEM", "gTIB", "gHUM", "gRAD", "fl", "hl", "IMI", "HFI", "BRI", "CRI")
if (ncol(raw) != 21L || !identical(row_txt(3), printed_header))       # txt() trims the printed 'ID '
  stop("unexpected header in row 3 of '", sheet, "'", call. = FALSE)
if (!startsWith(row_txt(1)[1], "SOM Table S1 Complete anthropoid sample included in the current study."))
  stop("unexpected title in row 1", call. = FALSE)
footer <- row_txt(1829)
if (!startsWith(footer[1], "Abbreviations: fem = femur;") || any(!is.na(footer[-1])))
  stop("unexpected footnote row 1829", call. = FALSE)
blank <- vapply(seq_len(nrow(raw)), function(r) all(is.na(row_txt(r))), logical(1))
if (nrow(raw) > 1829L && !all(blank[1830:nrow(raw)])) stop("cells found below the footnote row", call. = FALSE)
## Rows: 1 title, 2 caption, 3 header and 1829 footnotes are not data.
rows <- setdiff(which(!blank), c(1:3, 1829:nrow(raw)))
if (length(rows) != 1825L || min(rows) != 4L || max(rows) != 1828L) stop("expected data rows 4-1828", call. = FALSE)
P <- function(j) raw[[j]][rows]

## ---- 2. Species: printed genus + species (joined by a space) kept; accepted name via the General key ----
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", basename(folder), "' in _keys/General/species_key.csv", call. = FALSE)
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
genus <- txt(P(1)); species_epithet <- txt(P(2))
species_as_published <- paste(genus, species_epithet)        # e.g. "Gorilla g.gorilla", "Papio hamadrays"
if (!all(tolower(species_as_published) %in% names(lk)))
  stop("Unkeyed printed name: ", paste(unique(species_as_published[!tolower(species_as_published) %in% names(lk)]),
                                      collapse = ", "), call. = FALSE)
Species <- unname(lk[tolower(species_as_published)])
Species[!is.na(Species) & !nzchar(trimws(Species))] <- NA_character_

## ---- 3. Analysis table: one row per printed row, printed column order ----
## Codes as printed: Sex m / f / uk (unknown) and u (7 rows; not in the abbreviation list); Collection AMNH,
## CMNH, GOmD, MCZ, NMK, NMNH, PCM, RMAC, ZZ (abbreviations in row 1829). ID as printed (numbers written with
## up to 15 significant digits; IDs that Excel stored as numbers have lost any trailing zero).
collection <- txt(P(3))
final.dataframe <- data.frame(
  species_as_published = species_as_published,
  Species              = Species,
  genus                = genus,
  species_epithet      = species_epithet,
  collection           = collection,
  locality             = txt(P(4)),
  id                   = txt(P(5)),
  sex                  = txt(P(6)),
  superfamily          = txt(P(7)),
  fem_mm               = num(P(8), "fem"),
  tib_mm               = num(P(9), "tib"),
  hum_mm               = num(P(10), "hum"),
  rad_mm               = num(P(11), "rad"),
  g_fem                = num(P(12), "gFEM"),
  g_tib                = num(P(13), "gTIB"),
  g_hum                = num(P(14), "gHUM"),
  g_rad                = num(P(15), "gRAD"),
  fl_mm                = num(P(16), "fl"),
  hl_mm                = num(P(17), "hl"),
  imi                  = num(P(18), "IMI"),
  hfi                  = num(P(19), "HFI"),
  bri                  = num(P(20), "BRI"),
  cri                  = num(P(21), "CRI"),
  observation_level    = "individual specimen",
  source_locator       = paste0("SOM Table S1 (1-s2.0-S0047248424000022-mmc2.xlsx), sheet '", sheet, "', row ", rows),
  data_role            = ifelse(collection == "GOmD", "secondary", ifelse(collection == "MCZ", "both", "primary")),
  stringsAsFactors = FALSE, check.names = FALSE)

## ---- 4. Table checks (build HOWTO sec. 7a): relations the table defines; values are never changed ----
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
## 4a. Derived columns from the four lengths (article Table 3): fl = hum + rad, hl = fem + tib (two printed
##     decimals: tolerance 0.005); IMI = 100 (hum + rad) / (fem + tib), HFI = 100 hum / fem, BRI = 100 rad / hum,
##     CRI = 100 tib / fem (printed to 10 significant digits: half a unit of the 10th digit); gX = X / GM with
##     GM = (fem tib hum rad)^(1/4) (Mosimann; printed to 9 decimals: 0.5e-9). 1e-12 added for float noise.
gm <- (fd$fem_mm * fd$tib_mm * fd$hum_mm * fd$rad_mm)^(1 / 4)
sig10 <- function(p) 0.5 * 10^(floor(log10(abs(p))) - 9)
rel <- list(
  fl_mm = list(fd$hum_mm + fd$rad_mm, "fl = hum + rad", function(p) 0.005),
  hl_mm = list(fd$fem_mm + fd$tib_mm, "hl = fem + tib", function(p) 0.005),
  imi   = list(100 * (fd$hum_mm + fd$rad_mm) / (fd$fem_mm + fd$tib_mm), "IMI = 100 (hum + rad) / (fem + tib)", sig10),
  hfi   = list(100 * fd$hum_mm / fd$fem_mm, "HFI = 100 hum / fem", sig10),
  bri   = list(100 * fd$rad_mm / fd$hum_mm, "BRI = 100 rad / hum", sig10),
  cri   = list(100 * fd$tib_mm / fd$fem_mm, "CRI = 100 tib / fem", sig10),
  g_fem = list(fd$fem_mm / gm, "gFEM = fem / GM", function(p) 0.5e-9),
  g_tib = list(fd$tib_mm / gm, "gTIB = tib / GM", function(p) 0.5e-9),
  g_hum = list(fd$hum_mm / gm, "gHUM = hum / GM", function(p) 0.5e-9),
  g_rad = list(fd$rad_mm / gm, "gRAD = rad / GM", function(p) 0.5e-9))
for (v in names(rel)) {
  o <- rel[[v]][[1]]; p <- fd[[v]]; tol <- rep_len(rel[[v]][[3]](p), length(p))     # one tolerance per row
  i <- which(!is.na(p))
  add_check(sprintf("%s_row%04d", v, rows[i]), paste0(rel[[v]][[2]], ", ", sp[i]), o[i], p[i], tol[i],
            ifelse(is.na(o[i]), NA, abs(o[i] - p[i]) <= tol[i] + 1e-12))
}
## 4b. Footnote a (row 1829): "n = 1825 ... Homo sapiens (n = 1270); non-Homo Hominoidea (n = 312);
##     Cercopithecoidea (n = 153); Ceboidea (n = 90)" (column Superfamily; 'Homo' kept apart).
for (s in list(c("all", "1825"), c("Homo", "1270"), c("Hominoidea", "312"), c("Cercopithecoidea", "153"), c("Ceboidea", "90"))) {
  k <- if (s[1] == "all") nrow(fd) else sum(fd$superfamily == s[1])
  add_check(paste0("footnote_n_", tolower(s[1])), paste0("specimens with Superfamily '", s[1], "' vs footnote a n = ", s[2]),
            k, as.numeric(s[2]), 0, k == as.numeric(s[2]))
}
## 4c. Article Table 1 (PDF p. 3): males, females, unknown and n per species (blank = 0), matched on the
##     accepted name (Table 1 prints e.g. 'abelli', 'lagotricha', 'fuscicolis'). S1 sex 'uk' and 'u' count
##     as unknown.
table1 <- data.frame(
  Species = c("Homo sapiens", "Pan troglodytes", "Pan paniscus", "Gorilla gorilla", "Gorilla beringei",
              "Pongo pygmaeus", "Pongo abelii", "Hylobates lar", "Symphalangus syndactylus",
              "Cercopithecus albogularis", "Cercopithecus mitis", "Colobus guereza", "Macaca fascicularis",
              "Macaca nemestrina", "Nasalis larvatus", "Papio cynocephalus", "Papio hamadryas", "Presbytis rubicunda",
              "Piliocolobus badius", "Theropithecus gelada", "Trachypithecus cristatus", "Alouatta caraya",
              "Alouatta palliata", "Aotus trivirgatus", "Ateles fusciceps", "Ateles geoffroyi", "Callicebus moloch",
              "Callimico goeldii", "Callithrix jacchus", "Cebuella pygmaea", "Cebus albifrons", "Cebus apella",
              "Lagothrix lagothricha", "Leontopithecus chrysomelas", "Leontopithecus rosalia", "Saguinus fuscicollis",
              "Saguinus labiatus", "Saguinus oedipus", "Saimiri sciureus"),
  males   = c(789, 53, 9, 37, 3, 14, 3, 39, 3, 5, 0, 8, 10, 2, 3, 19, 0, 5, 2, 0, 5, 2, 3, 3, 3, 1, 3, 2, 2, 4, 3, 2, 1, 3, 2, 2, 3, 1, 3),
  females = c(481, 28, 9, 27, 4, 15, 2, 34, 3, 4, 1, 9, 10, 6, 5, 18, 2, 5, 11, 13, 5, 3, 2, 3, 3, 1, 2, 3, 2, 1, 3, 3, 1, 2, 2, 1, 3, 3, 3),
  unknown = c(0, 14, 0, 0, 2, 5, 0, 7, 1, 0, 0, 3, 0, 0, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0),
  n       = c(1270, 95, 18, 66, 7, 34, 5, 80, 7, 9, 1, 20, 20, 8, 10, 37, 2, 10, 13, 13, 10, 6, 5, 6, 6, 4, 5, 5, 4, 5, 6, 5, 4, 5, 5, 3, 6, 4, 6),
  stringsAsFactors = FALSE)
if (!setequal(table1$Species, unique(fd$Species))) stop("Table 1 species and S1 accepted species differ", call. = FALSE)
for (t in seq_len(nrow(table1))) {
  r <- fd$Species == table1$Species[t]
  obs <- c(males = sum(fd$sex[r] == "m"), females = sum(fd$sex[r] == "f"),
           unknown = sum(fd$sex[r] %in% c("uk", "u")), n = sum(r))
  for (cc in names(obs))
    add_check(sprintf("table1_%s_%s", cc, gsub(" ", "_", table1$Species[t])),
              paste0("S1 ", cc, " vs article Table 1, ", table1$Species[t]), obs[[cc]], table1[[cc]][t], 0,
              obs[[cc]] == table1[[cc]][t],
              if (cc == "n" && table1$n[t] != table1$males[t] + table1$females[t] + table1$unknown[t])
                "Table 1 n is not the sum of its own sex columns" else "")
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
  ## CONVENTION-OK: no TSV under a guessed name. Expected: 10.1016%2Fj.jhevol.2024.103494_SOMTableS1
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
