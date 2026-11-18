<<<<<<< HEAD
# Beatty_Laughlin_2006_Table1.R
#
# Beatty J, Laughlin RE (2006). Genomic regulation of natural variation in
# cortical and noncortical brain volume. BMC Neuroscience 7: 16.
# doi:10.1186/1471-2202-7-16 (PMID 16503985; PMCID PMC1402304)
#
# Item: Table 1 -- neocortical (cortical) and non-cortical brain volumes
# (mm3) for 34 BXD recombinant inbred mouse strains and the parental
# strains C57BL/6J and DBA/2J (strain means, N = 3-5).
#
# Frozen sources in this folder: the publisher PDF (1471-2202-7-16.pdf),
# the Europe PMC full-text XML (fulltext.xml, the machine-readable copy
# this transcription was taken from), and the publisher's supplementary
# figure files. The article has NO supplementary data files; all data are
# in the main-text tables.
#
# Data role: PRIMARY. The volumes are the authors' own measurements.
# In-vivo values are shrinkage-corrected by the authors; non-cortical
# volume = total - cortical, with total from fresh brain weight at
# specific gravity ~1.00. The "Regressed" columns are size-corrected
# values for QTL mapping (derived) and must not be pooled with volumes.
#
# Outputs:
#   Beatty_Laughlin_2006_Table1.csv               (this folder)
#   ../__Public/comparative-data/10.1186%2F1471-2202-7-16_Table1.tsv (for __Public/comparative-data/)
#
# Registry note: the public TSV name is the expected Item encoded
# (10.1186%2F1471-2202-7-16_Table1). The registry row was added on 2026-11-18; descriptive metadata remain incomplete.
=======
## ============================================================================
## Beatty_Laughlin_2006_Table1.R
##
## Beatty J, Laughlin RE (2006). Genomic regulation of natural variation in
## cortical and noncortical brain volume. BMC Neuroscience 7: 16.
## doi:10.1186/1471-2202-7-16 (PMID 16503985; PMCID PMC1402304)
##
## Item: Table 1 -- neocortical (cortical) and non-cortical brain volumes
## (mm3) for 34 BXD recombinant inbred mouse strains and the parental
## strains C57BL/6J and DBA/2J (strain means, N = 3-5 per strain).
##
## Frozen source: Beatty_Laughlin_2006_Table1_snapshot.csv in this folder,
## captured from the publisher's full-text XML by
## Beatty_Laughlin_2006_Table1_snapshot.R (run that first) and cross-checked
## against the publisher PDF. This script reads ONLY the snapshot.
##
## Data role: PRIMARY. The volumes are the authors' own measurements.
## In-vivo values are shrinkage-corrected by the authors (measured volumes
## multiplied by fresh brain weight / fixed total volume); non-cortical
## volume = total - cortical, with the total from fresh brain weight at
## specific gravity ~1.00. The "Regressed" columns are size-corrected
## values prepared for QTL mapping (derived) and must not be pooled with
## the measured volumes.
##
## The table names no species: every strain is Mus musculus (the paper's
## subject, from the title and Methods), recorded on every row below and in
## the definitions file.
##
## Outputs:
##   Beatty_Laughlin_2006_Table1.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "Beatty_Laughlin_2006_Table1.R"   # this file's own name
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

<<<<<<< HEAD
write.csv(tab, "Beatty_Laughlin_2006_Table1.csv", row.names = FALSE)
write.table(tab, "../__Public/comparative-data/10.1186%2F1471-2202-7-16_Table1.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
=======
## ---- Item encoded, looked up by Item name (never by row number) ------------
registry     <- readxl::read_excel(file.path(repo_root, "__ReadMe.xlsx"),
                                   sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name,
                                                 registry[["Item name"]])]
if (is.na(item_encoded)) stop("Item not found in registry: ", item_name)

## ---- read the frozen snapshot (as printed; everything character) -----------
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", check.names = FALSE,
                 stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 36L)

## ---- clean (all cleaning happens here, never in the snapshot) --------------
final.dataframe <- data.frame(
  species_sci = "Mus musculus",   # the paper's subject; see header note
  Strain      = snap[["Strain"]],
  N           = as.integer(snap[["N"]]),
  Cortical_volume_mm3_in_vivo      = as.numeric(snap[["In Vivo Cortical Volume"]]),
  Noncortical_volume_mm3_in_vivo   = as.numeric(snap[["In Vivo Non-cortical Volume"]]),
  Cortical_volume_mm3_regressed    = as.numeric(snap[["Regressed Cortical Volume"]]),
  Noncortical_volume_mm3_regressed = as.numeric(snap[["Regressed Non-cortical Volume"]]),
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
>>>>>>> 92a9b69404ddaff1cfd1c8f6e9607368c2dbeb5b
