# Haug 1987 - TABLE 2: brain volume (Br-vo, cm3) and register number for the 42 species /
# species groups of the cortex cerebri study.
#
# PRINTED SOURCE -> the frozen copy is Haug__1987_TABLE2_snapshot.xlsx (sheet "TABLE2"), built by
# Haug__1987_extract_snapshot.py from the PDF's OCR text layer (journal p. 128 = PDF p. 3) and
# checked against a render of the page. This script reads ONLY that snapshot.
#
# Output shape: ONE ROW PER PRINTED ROW (42). Printed row order is kept. A row is a species mean
# when the printed common name says "mean" (Value_is_mean); the other rows are single brains
# (n is printed only for 9 species in Haug's Table 3, not here).
#
# UNITS (sec 6 of __HOWTO_build_a_dataset_file.md): brain volume printed in cm3 -> project mm3
#     Brain_Vol.mm3 = printed cm3 * 1000
# Sanity: human 1,300 cm3 -> 1,300,000 mm3; mouse 0.3 cm3 -> 300 mm3; echidna 11.0 cm3.
# Haug prints NO brain mass; a mass would be derived (volume x density) and is not made here.
#
# Source: Haug, H. (1987). Brain sizes, surfaces, and neuronal sizes of the cortex cerebri: a
#   stereological investigation of man and his variability and a comparison with some mammals
#   (primates, whale, marsupials, insectivores, and one elephant). Am J Anat 180(2):126-142.
#   DOI 10.1002/aja.1001800203.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
folder    <- basename(paper_dir)
item_name <- "Haug__1987_TABLE2"
snapshot_xlsx <- file.path(paper_dir, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) -
# No mapping is hand-coded here (sec 5). Every printed name -> accepted name comes from a
# species_key.csv row scoped to source_publication == the paper folder name. While those rows are
# still waiting to be merged into _keys/, the identical rows staged in this folder as
# PROPOSED_species_key_rows.csv are used instead, with a warning. Once merged, delete the staged
# file - the resolver then reads the canonical key only and the output is unchanged.
TOKEN <- folder
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
read_key_rows <- function() {
  out <- list()
  if (!is.na(dataset_root))
    for (kf in list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
                          recursive = TRUE, full.names = TRUE)) {
      k <- read.csv(kf, stringsAsFactors = FALSE)
      if (!all(c("variant_name", "accepted_name", "source_publication") %in% names(k))) next
      k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
      if (nrow(k)) out[[length(out) + 1L]] <- k[, c("variant_name", "accepted_name")]
    }
  if (length(out)) return(do.call(rbind, out))
  staged <- file.path(paper_dir, "PROPOSED_species_key_rows.csv")
  if (file.exists(staged)) {
    warning("No '", TOKEN, "' rows in _keys/*/species_key.csv - falling back to the staged ",
            "PROPOSED_species_key_rows.csv. Merge it into the key, then delete the staged file.")
    k <- read.csv(staged, stringsAsFactors = FALSE)
    return(k[trimws(k$source_publication) == TOKEN, c("variant_name", "accepted_name")])
  }
  stop("No species_key rows for '", TOKEN, "' and no staged PROPOSED_species_key_rows.csv.", call. = FALSE)
}
km <- local({
  k <- read_key_rows(); m <- list()
  for (i in seq_len(nrow(k))) {
    v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && is.null(m[[v]])) m[[v]] <- k$accepted_name[i]
  }
  m
})
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  cx                                     # unresolved: printed name passes through
}

## 3. NUMBER PARSING -----------------------------------------------
# Guarded thousands separators (sec 6): commas are stripped only from a WELL-FORMED grouped number
# ("1,345", "4,148"); a malformed token lands in parse_flags with the printed text quoted.
NA_TOKENS <- c("", "-", "–", "—", "NA", "n.a.", "n/a", "__", "e")
well_formed <- function(tok) {
  tok <- trimws(tok)
  if (!nzchar(tok)) return(FALSE)
  if (!grepl(",", tok, fixed = TRUE)) return(grepl("^[0-9]+(\\.[0-9]+)?$", tok))
  g <- strsplit(tok, ",", fixed = TRUE)[[1]]
  if (!grepl("^[0-9]{1,3}$", g[1])) return(FALSE)
  all(grepl("^[0-9]{3}(\\.[0-9]+)?$", g[-1]))
}
num1 <- function(tok) {
  tok <- trimws(as.character(tok))
  if (tok %in% NA_TOKENS) return(NA_real_)
  if (!well_formed(tok)) return(NA_real_)
  as.numeric(gsub(",", "", tok, fixed = TRUE))
}

## 4. READ SNAPSHOT ------------------------------------------------
# Positional read (sec 3): row 1 = caption, rows 2-3 = the two header tiers, rows 4+ = data,
# last row = the printed footnote (no row number, dropped by the numeric-row filter below).
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TABLE2", col_names = FALSE,
                                 col_types = "text", .name_repair = "minimal"),
                      stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
# NB: only a truly empty cell becomes ""; the literal text "NA" is a PRINTED abbreviation (row 22, Ateles ater)
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x)] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])
snap <- snap[grepl("^[0-9]+$", snap$V1) & nzchar(snap$V3), , drop = FALSE]   # drops the footnote row

## 5. BUILD --------------------------------------------------------
out <- NULL
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)     # no, abbr, latin, common, br-vo, reg
  flags <- character(0)
  brvo <- num1(r[5])
  if (nzchar(r[5]) && is.na(brvo))
    flags <- c(flags, sprintf("Br-vo printed '%s' - not parseable as a number", r[5]))
  out <- rbind(out, data.frame(
    Row_no_Haug1987      = as.integer(r[1]),            # printed row number
    Abbr_Haug1987        = r[2],                        # printed abbreviation (CC is printed twice)
    Common_name_Haug1987 = r[4],                        # printed common name (invariant 3)
    Species_Haug1987     = r[3],                        # printed Latin name, verbatim (incl. misspellings)
    species_sci          = resolve(r[3]),
    Brain_Vol.mm3        = round(brvo * 1000, 6),       # printed cm3 -> project mm3 (x1000)
    Value_is_mean        = grepl(", mean$", r[4]),      # derived: printed common name ends ", mean"
    Reg_no_Haug1987      = r[6],                        # register number kept as text ("000" is printed)
    parse_flags          = if (length(flags)) paste(flags, collapse = "; ") else NA_character_,
    stringsAsFactors = FALSE))
}
rownames(out) <- NULL                                   # printed row order preserved

## 5b. CHECKS ------------------------------------------------------
# The table carries no arithmetic of its own (no sums or percentages), so there is no
# table_checks relation to test (sec 7a). Structural checks only:
stopifnot(nrow(out) == 42, identical(out$Row_no_Haug1987, 1:42))
if (any(is.na(out$Brain_Vol.mm3))) warning("TABLE 2: unparsed Br-vo cell(s) - see parse_flags")
unresolved <- out$Species_Haug1987[out$species_sci == out$Species_Haug1987 &
                                   !(out$species_sci %in% ref)]

## 6. SAVE ---------------------------------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' in __ReadMe.xlsx for Item name: ", item_name)
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  }
}
cat(sprintf("Haug TABLE 2: %d rows, %d flagged, %d species name(s) not resolved by the key: %s\n",
            nrow(out), sum(!is.na(out$parse_flags)), length(unresolved),
            paste(unresolved, collapse = "; ")))
