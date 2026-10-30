## MacLeod 2000 dissertation -- Appendix I (Hirnforschung records)
## Snapshot -> clean provenance table.
##
## Golden rule: the snapshot is frozen/faithful; ALL cleaning happens here.
##
## Main provenance choices in this version:
##   * Keep the printed taxon/specimen cell as its own field.
##   * Do NOT convert generic "GIBBON" to Hylobates lar.
##   * Preserve multiline IDENT. NUMBER cells, but also parse them into:
##       specimen_name, record_note, primary_identifier, alternate_identifiers.
##   * Treat one biological individual as a specimen identity with potentially
##     multiple identifiers and multiple published taxonomic labels.

options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))

  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }

  ## Fallback for interactive testing if the script was sourced indirectly.
  if (exists("sys.frames")) {
    p <- tryCatch(normalizePath(sys.frames()[[1]]$ofile), error = function(e) NA_character_)
    if (!is.na(p) && nzchar(p)) return(p)
  }

  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})

paper_dir  <- dirname(.sp)
table_name <- tools::file_path_sans_ext(basename(.sp))
setwd(paper_dir)

find_repo_root <- function(start_dir) {
  d <- normalizePath(start_dir)
  while (dirname(d) != d) {
    if (file.exists(file.path(d, "__ReadMe.xlsx"))) return(d)
    d <- dirname(d)
  }
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
}

dataset_root <- find_repo_root(paper_dir)

## ---- snapshot input ---------------------------------------------------------
## Prefer the real snapshot workbook. The CSV fallback is useful when testing from
## a manually exported snapshot or when this script is run outside the full repo.
snapshot_candidates <- unique(c(
  paste0(table_name, "_snapshot.xlsx"),
  paste0(table_name, "_snapshot.csv"),
  "MacLeod__2000_APPENDIXI_snapshot.xlsx",
  "MacLeod__2000_APPENDIXI_snapshot.csv",
  "MacLeod__2000_APPENDIXI.csv"
))

snapshot_file <- snapshot_candidates[file.exists(snapshot_candidates)][1]
if (is.na(snapshot_file)) {
  stop(
    "Could not find a snapshot file. Looked for: ",
    paste(snapshot_candidates, collapse = ", "),
    call. = FALSE
  )
}

read_snapshot <- function(path) {
  ext <- tolower(tools::file_ext(path))

  if (ext %in% c("xlsx", "xls")) {
    if (!requireNamespace("readxl", quietly = TRUE)) {
      stop("Package 'readxl' is required to read the snapshot workbook.", call. = FALSE)
    }
    dat <- readxl::read_excel(
      path,
      sheet = 1,
      skip = 4,
      col_names = TRUE,
      col_types = "text",
      .name_repair = "minimal"
    )
    dat <- as.data.frame(dat, stringsAsFactors = FALSE)
  } else if (ext == "csv") {
    dat <- utils::read.csv(
      path,
      stringsAsFactors = FALSE,
      check.names = FALSE,
      na.strings = c("", "NA")
    )
  } else {
    stop("Unsupported snapshot extension: ", ext, call. = FALSE)
  }

  dat
}

raw <- read_snapshot(snapshot_file)
raw <- raw[!is.na(raw$SPECIMEN) & trimws(raw$SPECIMEN) != "", , drop = FALSE]

## ---- helpers ---------------------------------------------------------------
squish <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  x <- gsub("\r\n|\r", "\n", x)
  x <- gsub("[ \t]+", " ", x)
  x <- gsub(" *\n *", "\n", x)
  trimws(x)
}

split_lines <- function(x) {
  x <- squish(x)
  strsplit(x, "\n", fixed = TRUE)
}

one_line <- function(x, sep = "; ") {
  vapply(split_lines(x), function(z) {
    z <- trimws(z)
    z <- z[nzchar(z)]
    paste(z, collapse = sep)
  }, character(1), USE.NAMES = FALSE)
}

is_na_printed <- function(x) {
  toupper(squish(x)) %in% c("", "NA", "N.A.", "N/A")
}

parse_first_number <- function(x) {
  x <- squish(x)
  out <- rep(NA_real_, length(x))

  for (i in seq_along(x)) {
    m <- regexpr("[-+]?(\\d+(\\.\\d*)?|\\.\\d+)", x[i], perl = TRUE)
    if (!is.na(m) && m[1] > 0) {
      out[i] <- suppressWarnings(as.numeric(regmatches(x[i], m)))
    }
  }

  out
}

parse_brain_weight <- function(x) {
  x <- squish(x)
  out <- rep(NA_real_, length(x))

  for (i in seq_along(x)) {
    if (is_na_printed(x[i])) next
    m <- gregexpr("[-+]?(\\d+(\\.\\d*)?|\\.\\d+)", x[i], perl = TRUE)[[1]]
    if (m[1] < 0) next
    nums <- regmatches(x[i], list(m))[[1]]

    ## If an estimated value is printed after a with-meninges value, use the estimate.
    pick <- if (grepl("EST", x[i], ignore.case = TRUE) && length(nums) > 1) tail(nums, 1) else nums[1]
    out[i] <- suppressWarnings(as.numeric(pick))
  }

  out
}

clean_colnames <- function(x) {
  gsub("[^a-z0-9]+", "", tolower(x))
}

col_pick_clean <- function(dat, wanted) {
  key <- clean_colnames(names(dat))
  wanted_key <- clean_colnames(wanted)
  hit <- which(key == wanted_key)

  if (length(hit) != 1) {
    stop(
      "Expected one matching column for: ", wanted,
      "\nFound: ", length(hit),
      "\nAvailable columns: ", paste(names(dat), collapse = " | "),
      call. = FALSE
    )
  }

  dat[[hit]]
}

## ---- taxon parsing ---------------------------------------------------------
species_from_printed_specimen <- function(x) {
  u <- toupper(squish(x))
  out <- rep(NA_character_, length(u))

  out[grepl("HOMO|H\\. SAPIENS", u)] <- "Homo sapiens"
  out[is.na(out) & grepl("GORILLA", u)] <- "Gorilla gorilla"
  out[is.na(out) & grepl("PAN PANISCUS", u)] <- "Pan paniscus"
  out[is.na(out) & grepl("PAN TROG|PAN T\\.|SCHIMPANSE", u)] <- "Pan troglodytes"
  out[is.na(out) & grepl("PONGO", u)] <- "Pongo pygmaeus"

  ## Important: a generic printed "GIBBON" is NOT enough to assign Hylobates lar.
  out[is.na(out) & grepl("HYLOBATES LAR", u)] <- "Hylobates lar"

  out[is.na(out) & grepl("E\\. PATAS|PATAS", u)] <- "Erythrocebus patas"
  out[is.na(out) & grepl("MACACA MULATTA", u)] <- "Macaca mulatta"
  out[is.na(out) & grepl("CERCOPITHECUS", u)] <- "Cercopithecus sp."
  out[is.na(out) & grepl("C\\. ALBIGENA|CERCOCEBUS", u)] <- "Cercocebus albigena"
  out[is.na(out) & grepl("PAPIO", u)] <- "Papio cynocephalus"
  out[is.na(out) & grepl("ATELES", u)] <- "Ateles paniscus"
  out[is.na(out) & grepl("ALOUATTA SENICUL|ALOUTTA SENICUL", u)] <- "Alouatta seniculus"
  out[is.na(out) & grepl("ALOUATTA|ALOUTTA", u)] <- "Alouatta sp."
  out[is.na(out) & grepl("CEBUS", u)] <- "Cebus sp."
  out[is.na(out) & grepl("SAIMIRI", u)] <- "Saimiri sciureus"
  out[is.na(out) & grepl("AOTUS", u)] <- "Aotus sp."

  out
}

taxon_common_from_printed <- function(x) {
  u <- toupper(squish(x))
  out <- rep(NA_character_, length(u))
  out[grepl("\\bGIBBON\\b", u)] <- "gibbon"
  out[grepl("\\bSCHIMPANSE\\b|\\bCHIMP\\b", u)] <- "chimpanzee"
  out[grepl("\\bORANG\\b", u)] <- "orangutan"
  out
}

## ---- identifier parsing ----------------------------------------------------
looks_like_name_line <- function(z) {
  z0 <- trimws(gsub("\\*", "", z))
  z0 <- trimws(gsub("\\([^)]*\\)", "", z0))
  nzchar(z0) && grepl("[A-Za-z]", z0) && !grepl("[0-9]", z0)
}

parse_identifier_field <- function(x) {
  lines <- split_lines(x)

  specimen_name <- vapply(lines, function(z) {
    z <- trimws(gsub("\\*", "", z))
    z <- z[nzchar(z)]
    if (!length(z)) return(NA_character_)

    hit <- z[vapply(z, looks_like_name_line, logical(1))]
    if (!length(hit)) return(NA_character_)

    nm <- trimws(gsub("\\([^)]*\\)", "", hit[1]))
    if (nzchar(nm)) nm else NA_character_
  }, character(1), USE.NAMES = FALSE)

  record_note <- vapply(lines, function(z) {
    z <- trimws(z)
    z <- z[nzchar(z)]
    if (!length(z)) return(NA_character_)

    m <- regmatches(z, gregexpr("\\([^)]*\\)", z, perl = TRUE))
    m <- unlist(m, use.names = FALSE)
    m <- gsub("^\\(|\\)$", "", m)
    m <- m[nzchar(m)]

    if (length(m)) paste(unique(m), collapse = "; ") else NA_character_
  }, character(1), USE.NAMES = FALSE)

  primary_identifier <- vapply(lines, function(z) {
    z <- trimws(gsub("\\*", "", z))
    z <- z[nzchar(z)]
    if (!length(z)) return(NA_character_)

    ## Prefer separate identifier lines containing digits, especially accession-like IDs.
    z_no_paren <- trimws(gsub("\\([^)]*\\)", "", z))
    id_lines <- z_no_paren[grepl("[0-9]", z_no_paren)]

    ## Do not use a name-with-parenthetical-date line as the identifier if a cleaner
    ## second-line accession exists. This is what separates DISCO from GPZ-5542.
    id_lines <- id_lines[!vapply(id_lines, looks_like_name_line, logical(1))]

    if (length(id_lines)) return(tail(id_lines, 1))

    ## If there is no digit-bearing identifier, preserve the last non-name line.
    non_name <- z_no_paren[!vapply(z_no_paren, looks_like_name_line, logical(1))]
    if (length(non_name)) tail(non_name, 1) else NA_character_
  }, character(1), USE.NAMES = FALSE)

  alternate_identifiers <- vapply(lines, function(z) {
    z <- trimws(z)
    z <- z[nzchar(z)]
    if (length(z)) paste(z, collapse = "; ") else NA_character_
  }, character(1), USE.NAMES = FALSE)

  data.frame(
    specimen_name = specimen_name,
    record_note = record_note,
    primary_identifier = primary_identifier,
    alternate_identifiers = alternate_identifiers,
    stringsAsFactors = FALSE
  )
}

normalize_sex <- function(x) {
  u <- toupper(squish(x))
  ifelse(u %in% c("M", "F", "?F"), u, ifelse(is_na_printed(u), NA_character_, squish(x)))
}

normalize_cut <- function(x) {
  u <- toupper(gsub("\n", " ", squish(x)))
  out <- rep(NA_character_, length(u))

  out[grepl("L\\. HEM", u) | (grepl("SAG", u) & grepl("FR|FRONTAL", u))] <- "mixed"
  out[is.na(out) & grepl("SAG", u)] <- "sagittal"
  out[is.na(out) & grepl("HOR|HORIZ", u)] <- "horizontal"
  out[is.na(out) & grepl("FR|FRONTAL", u)] <- "frontal"
  out[is.na(out) & !is_na_printed(u)] <- one_line(x[is.na(out) & !is_na_printed(u)])

  out
}

parse_age_years <- function(x) {
  u <- toupper(squish(x))
  ifelse(grepl("YR", u), parse_first_number(u), NA_real_)
}

age_class <- function(x) {
  u <- toupper(squish(x))
  out <- rep(NA_character_, length(u))

  out[grepl("JUV", u)] <- "juvenile"
  out[grepl("INF", u)] <- "infant"
  out[is.na(out) & u %in% c("A", "ADULT")] <- "adult"
  out[is.na(out) & grepl("YR", u)] <- "adult_or_age_given"
  out[is.na(out) & !is_na_printed(u)] <- one_line(x[is.na(out) & !is_na_printed(u)])

  out
}

make_specimen_label <- function(species, taxon_common_printed, specimen_name, primary_identifier, identification_number, specimen_printed) {
  taxon_for_label <- ifelse(!is.na(species) & nzchar(species), species, taxon_common_printed)
  taxon_for_label <- ifelse(is.na(taxon_for_label) | !nzchar(taxon_for_label), one_line(specimen_printed), taxon_for_label)

  id_for_label <- ifelse(!is.na(specimen_name) & nzchar(specimen_name), specimen_name, primary_identifier)
  id_for_label <- ifelse(is.na(id_for_label) | !nzchar(id_for_label), identification_number, id_for_label)

  ifelse(
    !is.na(id_for_label) & nzchar(id_for_label),
    paste0(taxon_for_label, " (", id_for_label, ")"),
    taxon_for_label
  )
}

## ---- clean -----------------------------------------------------------------
specimen_printed_raw <- col_pick_clean(raw, "SPECIMEN")
identifier_raw       <- col_pick_clean(raw, "IDENT. NUMBER")
brain_weight_raw     <- col_pick_clean(raw, "BRAIN WT. GRAMS")
fixed_volume_raw     <- col_pick_clean(raw, "FIXED VOL. CC'S")
body_weight_raw      <- col_pick_clean(raw, "WEIGHT")
cause_of_death_raw   <- col_pick_clean(raw, "CAUSE OF DEATH")
stains_raw           <- col_pick_clean(raw, "STAINS MEASURED")

identifier_parsed <- parse_identifier_field(identifier_raw)
identification_number <- one_line(identifier_raw)
species <- species_from_printed_specimen(specimen_printed_raw)
taxon_common_printed <- taxon_common_from_printed(specimen_printed_raw)

specimen <- make_specimen_label(
  species = species,
  taxon_common_printed = taxon_common_printed,
  specimen_name = identifier_parsed$specimen_name,
  primary_identifier = identifier_parsed$primary_identifier,
  identification_number = identification_number,
  specimen_printed = specimen_printed_raw
)

is_disco <- grepl("\\bDISCO\\b", identifier_raw, ignore.case = TRUE) |
  grepl("\\bGPZ-?5542\\b", identifier_raw, ignore.case = TRUE)

ambiguous_generic_gibbon <- is.na(species) & taxon_common_printed == "gibbon"

taxonomic_note <- rep(NA_character_, nrow(raw))
taxonomic_note[ambiguous_generic_gibbon] <- "MacLeod prints only generic 'GIBBON'; do not infer Hylobates lar from this row alone."
taxonomic_note[is_disco] <- paste(
  "MacLeod links the named specimen DISCO to GPZ-5542 in the identifier field;",
  "published species labels for this specimen should be resolved from accession/studbook records rather than generic 'GIBBON'."
)

clean <- data.frame(
  species                    = species,
  taxon_common_printed       = taxon_common_printed,
  specimen                   = specimen,
  specimen_name              = identifier_parsed$specimen_name,
  record_note                = identifier_parsed$record_note,
  primary_identifier         = identifier_parsed$primary_identifier,
  alternate_identifiers      = identifier_parsed$alternate_identifiers,
  identification_number      = identification_number,
  identifier_raw             = squish(identifier_raw),
  specimen_printed           = one_line(specimen_printed_raw),
  specimen_printed_raw       = squish(specimen_printed_raw),
  sex                        = normalize_sex(col_pick_clean(raw, "SEX")),
  sample                     = "Hirnforschung",
  body_weight_kg             = parse_first_number(body_weight_raw),
  body_weight_raw            = one_line(body_weight_raw),
  brain_weight_g             = parse_brain_weight(brain_weight_raw),
  brain_weight_raw           = one_line(brain_weight_raw),
  fixed_volume_cm3           = parse_first_number(fixed_volume_raw),
  fixed_volume_raw           = one_line(fixed_volume_raw),
  age                        = one_line(col_pick_clean(raw, "AGE")),
  age_years                  = parse_age_years(col_pick_clean(raw, "AGE")),
  age_class                  = age_class(col_pick_clean(raw, "AGE")),
  collection_source          = one_line(col_pick_clean(raw, "SOURCE")),
  cause_of_death             = one_line(cause_of_death_raw),
  section_plane              = normalize_cut(col_pick_clean(raw, "CUT")),
  section_plane_raw          = one_line(col_pick_clean(raw, "CUT")),
  stains_measured            = one_line(stains_raw),
  stephan_database_specimen  = grepl("*", specimen_printed_raw, fixed = TRUE) |
                                grepl("*", identifier_raw, fixed = TRUE),
  stephan_related_note       = grepl("STEPHAN|FROM ST", specimen_printed_raw, ignore.case = TRUE),
  semendeferi_record         = grepl("SEMEND", specimen_printed_raw, ignore.case = TRUE),
  brainweight_known          = !is_na_printed(brain_weight_raw),
  taxonomic_issue            = ambiguous_generic_gibbon | is_disco,
  taxonomic_note             = taxonomic_note,
  source                     = "MacLeod__2000",
  stringsAsFactors = FALSE
)

## ---- checks ----------------------------------------------------------------
stopifnot(nrow(clean) == nrow(raw))
stopifnot(length(unique(names(clean))) == ncol(clean))

## This should be readable for the problematic specimen:
if (any(is_disco)) {
  disco <- clean[is_disco, c(
    "species", "taxon_common_printed", "specimen", "specimen_name",
    "record_note", "primary_identifier", "alternate_identifiers", "taxonomic_note"
  ), drop = FALSE]
  print(disco)
}

## ---- save ------------------------------------------------------------------
final.dataframe <- clean
final_csv <- file.path(paper_dir, paste0(table_name, ".csv"))

utils::write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
message("Wrote local CSV: ", final_csv)

## Public TSV, if this script is being run inside the full Evo-M1-Trait-Data repo.
if (!is.na(dataset_root)) {
  readme_xlsx <- file.path(dataset_root, "__ReadMe.xlsx")
  public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

  item_encoded <- NA_character_
  if (file.exists(readme_xlsx) && requireNamespace("readxl", quietly = TRUE)) {
    filecodes <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")

    ## Try exact match first; then tolerate single-vs-double underscore differences.
    item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
    if (is.na(item_encoded) || !nzchar(item_encoded)) {
      table_name_alt <- gsub("__+", "_", table_name)
      readme_names_alt <- gsub("__+", "_", filecodes$`Item name`)
      item_encoded <- filecodes$`Item encoded`[match(table_name_alt, readme_names_alt)]
    }
  }

  if (!is.na(item_encoded) && nzchar(item_encoded)) {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    public_tsv <- file.path(public_tsv_dir, paste0(item_encoded, ".tsv"))
    utils::write.table(
      final.dataframe,
      file = public_tsv,
      sep = "\t",
      row.names = FALSE,
      quote = FALSE,
      na = ""
    )
    message("Wrote public TSV: ", public_tsv)
  } else {
    warning(
      "No matching 'Item encoded' entry found in __ReadMe.xlsx for Item name '",
      table_name,
      "'. Wrote local CSV only.",
      call. = FALSE
    )
  }
} else {
  message("No __ReadMe.xlsx found above this folder; wrote local CSV only.")
}
