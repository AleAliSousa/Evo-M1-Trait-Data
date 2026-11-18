## ============================================================================
## CastilloMorales_etal_2016_Table1.R
##
## Castillo-Morales A, Monzon-Sandoval J, de Sousa AA, Urrutia AO,
## Gutierrez H (2016). Neocortex expansion is linked to size variations in
## gene families with chemotaxis, cell-cell signalling and immune response
## functions in mammals. Open Biology 6: 160132. doi:10.1098/rsob.160132
##
## Item: Table 1 -- phenotypic traits for the 28 mammalian species analysed:
## brain volume (cm3), neocortex volume (cm3), the literature source of the
## volumes (printed as ref. numbers [84]-[99]), the neocortex ratio Nr, the
## encephalization index Ei and maximum lifespan MLSP (years).
##
## Frozen source: CastilloMorales_etal_2016_Table1_snapshot.csv in this
## folder -- Table 1 transcribed exactly as printed (printed headers, row
## order, values and ref. brackets kept), BEFORE any cleaning, following
## _skills/build-dataset-item/references/__HOWTO_make_a_snapshot.md.
## Transcribed by Buddy (AI assistant) on 2026-11-18 from the publisher PDF
## held in this folder (Castillo-Morales-2016-Neocortex_expansion.pdf) and
## verified against it: every row was cross-checked against the values
## extracted from the PDF text layer, and the Ei signs (rendered as a
## leading "2" by the text layer) were read from the printed page -- only
## Homo sapiens has a positive Ei, as the paper's formula requires.
## The publisher PDF is provenance, not the frozen source: this script
## reads ONLY the snapshot.
##
## Data role: SECONDARY compilation. Each species' volumes come from the
## single literature source named in the table's ref. column; those sources
## are itemised in
## reference_tables/CastilloMorales_etal_2016_Table1_references.csv
## (ref_key = the printed bracketed number). Ei derives from the
## 493-species brain/body dataset of Gonzalez-Lagos et al. 2010 (ref. [83]),
## provided by its authors and never deposited; see the
## GonzalezLagos_etal_2010 folder.
##
## Table check (build HOWTO section 7a): the printed Nr is recomputed from
## the printed volumes for all 28 species and left in `table_checks`.
##
## Outputs:
##   CastilloMorales_etal_2016_Table1.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
## (same mechanism as _tools/dataset_builder/load_dataset_builder.R:
##  --file= under Rscript, the innermost source() frame's ofile when the
##  dataset builder sys.source()s this script, rstudioapi interactively)
script_path <- local({
  me   <- "CastilloMorales_etal_2016_Table1.R"   # this file's own name
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

## ---- read the frozen snapshot (as printed; everything character) -----------
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", check.names = FALSE,
                 stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 28L)

num <- function(x) as.numeric(x)

## ---- per-row sources: join the printed ref. keys to the references file ----
refs <- utils::read.csv(file.path(folder, "reference_tables",
                           paste0(item_name, "_references.csv")),
                 stringsAsFactors = FALSE, encoding = "UTF-8")
## the Evo-M1 folder key for each volume source is recorded in the note
refs$folder_key <- sub(".*Evo-M1 folder: ([A-Za-z0-9_]+).*", "\\1", refs$note)
source_key <- refs$folder_key[match(snap[["ref."]], refs$ref_key)]
if (any(is.na(source_key)))
  stop("Unmapped ref. key in snapshot: ",
       paste(snap[["ref."]][is.na(source_key)], collapse = ", "))

## ---- clean (all cleaning happens here, never in the snapshot) --------------
final.dataframe <- data.frame(
  species_sci            = snap[["species name"]],          # as printed
  common_name            = snap[["common name"]],
  Brain_volume_cm3       = num(snap[["brain volume (cm3)"]]),
  Neocortex_volume_cm3   = num(snap[["neocortex volume (cm3)"]]),
  Source_ref_no          = as.integer(gsub("\\[|\\]", "", snap[["ref."]])),
  Source                 = source_key,
  Nr                     = num(snap[["Nr"]]),
  Ei                     = num(snap[["Ei"]]),
  MLSP_years             = num(snap[["MLSP"]]),
  stringsAsFactors = FALSE
)

## ---- table check: printed Nr vs Nr recomputed from the printed volumes -----
## Nr = neocortex / (brain - neocortex), after Dunbar. The printed volumes
## are rounded, so the recomputed Nr has a rounding envelope: for each row
## the envelope runs from (N - uN)/((B + uB) - (N - uN)) to
## (N + uN)/((B - uB) - (N + uN)), where uB/uN are half a unit of the last
## printed decimal of each volume; the check passes when that envelope
## overlaps the printed Nr's own rounding interval (Nr printed to 2 dp).
## Values are never changed to make a check pass.
recomputed <- final.dataframe$Neocortex_volume_cm3 /
  (final.dataframe$Brain_volume_cm3 - final.dataframe$Neocortex_volume_cm3)
half_unit <- function(x) {
  frac <- sub("^[^.]*\\.", "", x)   # digits after the decimal point
  frac[!grepl("\\.", x)] <- ""      # integer values have none
  0.5 * 10^(-nchar(frac))
}
uB <- half_unit(snap[["brain volume (cm3)"]])
uN <- half_unit(snap[["neocortex volume (cm3)"]])
B <- final.dataframe$Brain_volume_cm3; N <- final.dataframe$Neocortex_volume_cm3
env_lo <- (N - uN) / ((B + uB) - (N - uN))
env_hi <- (N + uN) / ((B - uB) - (N + uN))
nr_ok <- env_lo <= final.dataframe$Nr + 0.005 &
         env_hi >= final.dataframe$Nr - 0.005
table_checks <- data.frame(
  check_id   = paste0("Nr_", gsub(" ", "_", final.dataframe$species_sci)),
  basis      = "Table 1: printed Nr vs neocortex/(brain - neocortex) from the printed volumes",
  observed   = recomputed,
  printed    = final.dataframe$Nr,
  difference = recomputed - final.dataframe$Nr,
  tolerance  = (env_hi - env_lo) / 2 + 0.005,
  status     = ifelse(nr_ok, "pass", "mismatch"),
  note       = "Tolerance is the rounding envelope of the printed volumes plus half a unit of Nr's last printed decimal; nothing adjusted.",
  stringsAsFactors = FALSE
)
if (any(table_checks$status != "pass"))
  warning("Nr table check mismatch for: ",
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
