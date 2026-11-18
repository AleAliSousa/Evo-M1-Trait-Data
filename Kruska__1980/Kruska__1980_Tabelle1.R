## ============================================================================
## Kruska__1980_Tabelle1.R
##
## Kruska DCT (1980). Domestikationsbedingte Hirngroessenanderungen bei
## Saeugetieren. Zeitschrift fuer Zoologische Systematik und
## Evolutionsforschung 18: 161-195. doi:10.1111/j.1439-0469.1980.tb00738.x
##
## Item: Tabelle 1 -- "Frischhirngewichte in g und prozentuale Abnahme
## durch Formolfixierung und waehrend der histologischen Bearbeitung von
## Tylopoden, Schweinen und Ratten": fresh brain weight (g) and the
## shrinkage (%) through formalin fixation and histological processing
## for 40 specimens (7 camelids, 17 pigs, 16 rats; wild, domestic and
## feral forms), one row per specimen.
##
## Frozen source: Kruska__1980_Tabelle1_snapshot.csv in this folder --
## the table transcribed exactly as printed (two-block layout read in
## printed order, German decimal commas, specimen codes and species
## names as printed), BEFORE any cleaning. Transcribed by Buddy
## (AI assistant) on 2026-11-18 from the journal scan held in this folder
## (Kruska-1980-Domestikationsbeding.pdf, supplied by Michael Proulx) and
## verified cell by cell against the rendered page images; the full
## extraction of all 14 tables is kept in extracted_tables/ (REPORT.md).
## This script reads ONLY the snapshot.
##
## Data role: PRIMARY, per specimen. Tabelle 1 is also the paper's
## specimen register: the codes defined here are the column heads of
## Tabellen 2-14.
##
## Outputs:
##   Kruska__1980_Tabelle1.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "Kruska__1980_Tabelle1.R"   # this file's own name
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
## The printed name is kept verbatim in species_as_printed; the accepted
## name comes from the Stephan collection key (this paper's rows:
## source_publication == "Kruska__1980"). Names the key does not map are
## already accepted and pass through unchanged.
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

## ---- read the frozen snapshot (as printed; positional, everything text) ----
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", header = TRUE,
                 stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 40L, ncol(snap) == 4L)
names(snap) <- c("specimen_code", "species_printed", "weight_g", "shrinkage_pct")

## ---- clean (all cleaning happens here, never in the snapshot) --------------
num <- function(x) as.numeric(gsub(",", ".", x, fixed = TRUE))
final.dataframe <- data.frame(
  specimen_code          = snap$specimen_code,
  species_sci            = resolve_species(snap$species_printed),
  species_as_printed     = snap$species_printed,
  Fresh_brain_weight_g   = num(snap$weight_g),
  Fixation_shrinkage_pct = as.integer(snap$shrinkage_pct),
  stringsAsFactors = FALSE
)

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
