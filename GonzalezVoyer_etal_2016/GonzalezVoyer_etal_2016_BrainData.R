## ============================================================================
## GonzalezVoyer_etal_2016_BrainData.R
##
## Gonzalez-Voyer A, Gonzalez-Suarez M, Vila C, Revilla E (2016). Larger
## brain size indirectly increases vulnerability to extinction in mammals.
## Evolution 70: 1364-1375. doi:10.1111/evo.12943
## Data package: Dryad doi:10.5061/dryad.m2tj3
##
## Item: the Dryad data file (Brain Data) -- species-level brain mass,
## body mass and life-history / ecology traits for 596 mammal species,
## each row naming the literature sources its values were compiled from
## (the References column keys into the reference list in the package
## README, kept in this folder).
##
## Frozen source (digital-native, no snapshot): the untouched Dryad
## download, Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv (downloaded
## from datadryad.org on 2026-11-18), kept verbatim in this folder
## under its original name. A digital-native file needs no snapshot
## when the registry lists it and the build script reads it directly:
## __ReadMe.xlsx records this filename in the item's "Snapshot
## filename" field. Nothing was re-saved or converted. This script
## reads ONLY that file.
##
## Why this item is in Evo-M1: it is an openly released 596-species
## brain/body compilation. Its authors differ from Gonzalez-Lagos,
## Sol & Reader (2010), and no cell-level lineage to that unavailable
## 493-species database has been verified. The 2010 file itself was
## never deposited in any repository (checked 2026-11-18: no Dryad,
## figshare or DataCite record; the journal page carries no
## supporting-information file); see the GonzálezLagos_etal_2010 folder.
##
## Data role: SECONDARY compilation (values are cross-source means
## compiled from the references named per row).
##
## Cleaning done here (and nowhere else): one column is added --
## species_sci, the printed Species_name with underscores replaced by
## spaces. Every published value is carried over verbatim (the source file
## is read as text and no value is re-typed or rounded).
##
## Outputs:
##   GonzalezVoyer_etal_2016_BrainData.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "GonzalezVoyer_etal_2016_BrainData.R"   # this file's own name
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

## ---- read the frozen source file (verbatim text; no re-typing) ------------
snap <- utils::read.csv(file.path(folder,
                           "Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv"),
                 colClasses = "character", check.names = FALSE,
                 stringsAsFactors = FALSE, encoding = "UTF-8",
                 na.strings = character(0))   # verbatim: nothing is recoded
                                              # (the file codes missing
                                              #  data as the string "NA")
stopifnot(nrow(snap) == 596L)

## ---- clean: add species_sci; every published value carried over verbatim ---
final.dataframe <- data.frame(
  species_sci = gsub("_", " ", snap[["Species_name"]], fixed = TRUE),
  snap,
  stringsAsFactors = FALSE, check.names = FALSE
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
