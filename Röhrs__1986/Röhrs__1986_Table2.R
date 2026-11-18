## ============================================================================
## Röhrs__1986_Table2.R
##
## Röhrs M (1986). Cephalisation, Telencephalisation und
## Neocorticalisation bei Mustelidae. Zeitschrift fuer Zoologische
## Systematik und Evolutionsforschung 24: 157-166.
## doi:10.1111/j.1439-0469.1986.tb00624.x
##
## Item: Table 2 (journal p. 163) -- "Arttypische Volumenwerte (mm3 netto)
## fuer Gesamthirn, Telencephalon, Neocortex, Allocortex + Corpus
## striatum": species-typical net volumes (mm3) of the whole brain (HV),
## telencephalon (TELV), neocortex (NEOCV) and allocortex + corpus
## striatum (ALLO+CSTRV) for 10 mustelid species.
##
## Frozen source: Röhrs__1986_Table2_snapshot.csv in this folder -- the
## table transcribed exactly as printed (printed headers, row order,
## German decimal commas), BEFORE any cleaning. Transcribed by Buddy
## (AI assistant) on 2026-11-18 from the journal scan held in this folder
## (Ro_hrs-1986-Cephalisation__Telen.pdf, supplied by Michael Proulx) and
## verified cell by cell against the rendered page image (journal p. 163).
## This script reads ONLY the snapshot. Table 2 has its OWN snapshot,
## separate from Table 1's (one snapshot per item).
##
## Data role: SECONDARY. The volumes rest on the volume determinations of
## Schumacher (1963) and Thiede (1973), converted by Röhrs to
## species-typical values using Table 1's species means (subadults
## removed); they are not new measurements by Röhrs.
##
## Table check (build HOWTO section 7a): TELV = NEOCV + ALLO+CSTRV is
## recomputed for all 10 species into `table_checks`. The printed
## Conepatus humboldti row does not satisfy it (difference 3.59 mm3) --
## a misprint in one of the row's three values, recorded as erratum
## Röhrs__1986-E001; the values are kept as printed.
##
## Outputs:
##   Röhrs__1986_Table2.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "Röhrs__1986_Table2.R"   # this file's own name
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
## Folder, file names and the registry's Item names all keep the
## author's umlaut (the registry names are derived from the citation);
## the lookup key is stated explicitly here for clarity.
item_name_registry <- "Röhrs__1986_Table2"
registry     <- readxl::read_excel(file.path(repo_root, "__ReadMe.xlsx"),
                                   sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name_registry,
                                                 registry[["Item name"]])]
if (is.na(item_encoded)) stop("Item not found in registry: ", item_name_registry)

## ---- read the frozen snapshot (as printed; positional, everything text) ----
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", header = TRUE,
                 stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 10L, ncol(snap) == 5L)
names(snap) <- c("species_printed", "HV", "TELV", "NEOCV", "ALLO_CSTRV")

## ---- clean (all cleaning happens here, never in the snapshot) --------------
num <- function(x) as.numeric(gsub(",", ".", x, fixed = TRUE))
final.dataframe <- data.frame(
  species_sci = snap$species_printed,   # as printed
  Brain_volume_mm3_net               = num(snap$HV),
  Telencephalon_volume_mm3           = num(snap$TELV),
  Neocortex_volume_mm3               = num(snap$NEOCV),
  Allocortex_plus_striatum_volume_mm3 = num(snap$ALLO_CSTRV),
  stringsAsFactors = FALSE
)

## ---- table check: printed TELV vs NEOCV + ALLO+CSTRV ------------------------
## Tolerance per row: half a unit of the last printed decimal of each of
## the three printed values. Values are never changed to make a check pass.
half_unit <- function(x) {
  frac <- sub("^[^.]*\\.", "", x)
  frac[!grepl("\\.", x)] <- ""
  0.5 * 10^(-nchar(frac))
}
parts_sum <- final.dataframe$Neocortex_volume_mm3 +
             final.dataframe$Allocortex_plus_striatum_volume_mm3
tol <- half_unit(snap$TELV) + half_unit(snap$NEOCV) + half_unit(snap$ALLO_CSTRV)
table_checks <- data.frame(
  check_id   = paste0("TELV_sum_", gsub(" ", "_", final.dataframe$species_sci)),
  basis      = "Table 2: printed TELV vs NEOCV + ALLO+CSTRV from the printed volumes",
  observed   = parts_sum,
  printed    = final.dataframe$Telencephalon_volume_mm3,
  difference = parts_sum - final.dataframe$Telencephalon_volume_mm3,
  tolerance  = tol,
  status     = ifelse(abs(parts_sum - final.dataframe$Telencephalon_volume_mm3) <= tol,
                      "pass", "mismatch"),
  note       = ifelse(final.dataframe$species_sci == "Conepatus humboldti",
                      "Printed row is internally inconsistent; see erratum Röhrs__1986-E001. Kept as printed.",
                      "Volumes as printed in the snapshot; nothing adjusted."),
  stringsAsFactors = FALSE
)
if (any(table_checks$status != "pass"))
  warning("TELV table check mismatch for: ",
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
