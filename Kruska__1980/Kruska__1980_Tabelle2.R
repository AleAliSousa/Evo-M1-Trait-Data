## ============================================================================
## Kruska__1980_Tabelle2.R
##
## Kruska DCT (1980). Domestikationsbedingte Hirngroessenanderungen bei
## Saeugetieren. Zeitschrift fuer Zoologische Systematik und
## Evolutionsforschung 18: 161-195. doi:10.1111/j.1439-0469.1980.tb00738.x
##
## Item: Tabelle 2 -- per-specimen brain-part volumes (mm3, fresh,
## shrinkage-corrected) for the 7 camelid brains of the serial-section
## study (3 guanacos, 2 alpacas, 2 llamas; specimens G 14, G 10, G 24,
## A 9, A 7, L 6, L 7 as defined in Tabelle 1). The printed table is a
## matrix: structures as rows, specimens as columns.
##
## Frozen source: Kruska__1980_Tabelle2_snapshot.csv in this folder --
## the matrix transcribed exactly as printed (German structure labels,
## specimen column order, space thousands separators and decimal commas
## kept), BEFORE any cleaning. Transcribed by Buddy (AI assistant) on
## 2026-11-18 from the journal scan held in this folder
## (Kruska-1980-Domestikationsbeding.pdf, supplied by Michael Proulx) and
## verified cell by cell against the rendered page images; the full
## extraction of all 14 tables is kept in extracted_tables/ (REPORT.md).
## This script reads ONLY this item's snapshot. Tabelle 2 has its OWN
## snapshot, separate from Tabelle 1's (one snapshot per item).
##
## Specimen -> species: Tabelle 2's snapshot names specimens only, so the
## species of each specimen comes from the item-scoped register
## reference_tables/Kruska__1980_Tabelle2_specimens.csv (the specimen
## register printed in Tabelle 1, reproduced for this item so the item
## is self-contained; build HOWTO section 7b).
##
## Methods that matter: volumes were measured on complete serial
## sections by the planimetric paper-weighing method (Stephan 1960) and
## corrected back to fresh volumes per brain, with fresh volume =
## fresh weight / 1.035 (specific gravity of brain substance; see
## _COMMON_CALCULATIONS.md).
##
## Data role: PRIMARY, per specimen.
##
## Table checks (build HOWTO section 7a), left in `table_checks`:
## neocortex = neocortex grey + white, and pure brain substance =
## telencephalon + diencephalon + mesencephalon + cerebellum + medulla,
## per specimen. Printed parts are integers rounded independently, so
## the tolerance is half a unit per printed value involved; three
## neocortex splits differ by 1 mm3, inside that tolerance.
## Erratum Kruska__1980-E001: Tabelle 2 prints A 7's allocortex as
## 14 386; Tabellen 6 and 11 print 14 368 and Tabelle 3's share confirms
## it -- a misprint, kept as printed here and flagged in the note column.
##
## Outputs:
##   Kruska__1980_Tabelle2.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "Kruska__1980_Tabelle2.R"   # this file's own name
  argv <- commandArgs(trailingOnly = FALSE)
  f    <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f) && basename(f) == me) return(normalizePath(f))
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    of <- tryCatch(fr[[k]]$ofile, error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && basename(of) == me &&
        file.exists(of)) return(normalizePath(of))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me) return(normalizePath(p))
  }
  ## last resort: sys.source() (build_dataset_item) sets no ofile frame --
  ## find this file by name under the working directory (the repo root)
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) == 1L) return(normalizePath(hits))
  stop("Cannot locate this script; run it with Rscript or from RStudio.")
})
folder    <- dirname(script_path)
base      <- sub("\\.R$", "", basename(script_path))
item_name <- base

## ---- repo root (walk up to __ReadMe.xlsx) ----------------------------------
repo_root <- folder
while (!file.exists(file.path(repo_root, "__ReadMe.xlsx")) &&
       dirname(repo_root) != repo_root)
  repo_root <- dirname(repo_root)
if (!file.exists(file.path(repo_root, "__ReadMe.xlsx")))
  stop("__ReadMe.xlsx not found walking up from ", folder)

## ---- Item encoded, looked up by Item name (never by row number) ------------
registry     <- readxl::read_excel(file.path(repo_root, "__ReadMe.xlsx"),
                                   sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name,
                                                 registry[["Item name"]])]
if (is.na(item_encoded)) stop("Item not found in registry: ", item_name)

## ---- species resolution (build HOWTO section 5, Bush pattern) --------------
key <- utils::read.csv(file.path(repo_root, "_keys", "Stephan", "species_key.csv"),
                stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[key$source_publication == "Kruska__1980", ]
lk  <- stats::setNames(key$accepted_name, key$variant_name)
resolve_species <- function(printed) {
  out <- printed
  hit <- printed %in% names(lk)
  out[hit] <- lk[printed[hit]]
  out
}

## ---- read the frozen snapshot (printed matrix; everything text) ------------
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", header = TRUE, check.names = FALSE,
                 stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 13L, ncol(snap) == 8L)
structures <- snap[[1]]
specimens  <- names(snap)[-1]
## printed values: space thousands separators and decimal commas
num <- function(x) as.numeric(gsub(",", ".", gsub(" ", "", x, fixed = TRUE),
                                   fixed = TRUE))
mat <- sapply(snap[-1], num)
rownames(mat) <- structures
col_for <- function(label) mat[label, ]

## ---- specimen register (item-scoped; species as printed in Tabelle 1) ------
register <- utils::read.csv(file.path(folder, "reference_tables",
                               "Kruska__1980_Tabelle2_specimens.csv"),
                     stringsAsFactors = FALSE, encoding = "UTF-8")
printed_species <- register$species_as_printed[
  match(specimens, register$specimen_code)]
if (any(is.na(printed_species))) stop("Specimen missing from the register")

## ---- clean: transpose the printed matrix to one row per specimen -----------
final.dataframe <- data.frame(
  specimen_code            = specimens,
  species_sci              = resolve_species(printed_species),
  species_as_printed       = printed_species,
  Brain_mass_g_fresh       = col_for("Hirngewicht [g]"),
  Brain_volume_mm3_fresh   = col_for("Hirnvolumen [mm3]"),
  Pure_brain_substance_mm3 = col_for("Reine Hirnsubstanz [mm3]"),
  Telencephalon_mm3        = col_for("Telencephalon [mm3]"),
  Diencephalon_mm3         = col_for("Diencephalon [mm3]"),
  Mesencephalon_mm3        = col_for("Mesencephalon [mm3]"),
  Cerebellum_mm3           = col_for("Cerebellum [mm3]"),
  Medulla_oblongata_mm3    = col_for("Medulla oblongata [mm3]"),
  Neocortex_mm3            = col_for("Neocortex [mm3]"),
  Neocortex_grey_mm3       = col_for("Neocortex grau [mm3]"),
  Neocortex_white_mm3      = col_for("Neocortex weiss [mm3]"),
  Corpus_striatum_mm3      = col_for("Corpus striatum [mm3]"),
  Allocortex_mm3           = col_for("Allocortex [mm3]"),
  note = ifelse(specimens == "A 7",
                paste0("Allocortex as printed in Tabelle 2; Tabellen 6 and ",
                       "11 print 14368 and Tabelle 3's share (8.22%) confirms ",
                       "14368 -- misprint in Tabelle 2"),
                NA_character_),   # NA writes as an empty field, not ""
  stringsAsFactors = FALSE, row.names = NULL
)

## ---- table checks (section 7a) ----------------------------------------------
code_id <- gsub(" ", "_", final.dataframe$specimen_code)
neo_sum <- final.dataframe$Neocortex_grey_mm3 + final.dataframe$Neocortex_white_mm3
parts_sum <- final.dataframe$Telencephalon_mm3 + final.dataframe$Diencephalon_mm3 +
             final.dataframe$Mesencephalon_mm3 + final.dataframe$Cerebellum_mm3 +
             final.dataframe$Medulla_oblongata_mm3
table_checks <- rbind(
  data.frame(
    check_id   = paste0("Neocortex_split_", code_id),
    basis      = "Tabelle 2: printed Neocortex vs Neocortex grau + Neocortex weiss",
    observed   = neo_sum,
    printed    = final.dataframe$Neocortex_mm3,
    difference = neo_sum - final.dataframe$Neocortex_mm3,
    tolerance  = 1.5,   # half a unit for each of the three printed integers
    status     = ifelse(abs(neo_sum - final.dataframe$Neocortex_mm3) <= 1.5,
                        "pass", "mismatch"),
    note       = "Printed parts are independently rounded integers; differences of 1 mm3 are rounding.",
    stringsAsFactors = FALSE),
  data.frame(
    check_id   = paste0("Parts_sum_", code_id),
    basis      = "Tabelle 2: printed Reine Hirnsubstanz vs Telencephalon + Diencephalon + Mesencephalon + Cerebellum + Medulla oblongata",
    observed   = parts_sum,
    printed    = final.dataframe$Pure_brain_substance_mm3,
    difference = parts_sum - final.dataframe$Pure_brain_substance_mm3,
    tolerance  = 3,     # half a unit for each of the six printed integers
    status     = ifelse(abs(parts_sum - final.dataframe$Pure_brain_substance_mm3) <= 3,
                        "pass", "mismatch"),
    note       = "Printed parts are independently rounded integers; differences of 1 mm3 are rounding.",
    stringsAsFactors = FALSE)
)
if (any(table_checks$status != "pass"))
  warning("Tabelle 2 table check mismatch for: ",
          paste(table_checks$check_id[table_checks$status != "pass"],
                collapse = ", "))

## ---- write the analysis CSV and the public TSV ------------------------------
## House file format: CRLF line endings, minimal quoting -- the format
## of the committed Evo-M1 CSV/TSV files.
write_house <- function(df, path, sep) {
  ## minimal quoting, decided per field (a field is quoted only when it
  ## contains the separator, a double quote or a newline; embedded
  ## quotes are doubled) -- the format of the committed Evo-M1 files
  fmt <- function(v) {
    v <- as.character(v)
    v[is.na(v)] <- ""
    needs <- grepl(sep, v, fixed = TRUE) | grepl('"', v, fixed = TRUE) |
             grepl("[\r\n]", v)
    v[needs] <- paste0('"', gsub('"', '""', v[needs], fixed = TRUE), '"')
    v
  }
  lines <- do.call(paste, c(lapply(df, fmt), sep = sep))
  con <- file(path, open = "wb")
  writeLines(c(paste(names(df), collapse = sep), lines), con, sep = "\r\n")
  close(con)
}
write_house(final.dataframe, file.path(folder, paste0(item_name, ".csv")), ",")
tsv_dir <- file.path(repo_root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write_house(final.dataframe,
              file.path(tsv_dir, paste0(item_encoded, ".tsv")), "\t")
} else {
  warning("__Public/comparative-data not found under the repo root; ",
          "public TSV not written.")
}
