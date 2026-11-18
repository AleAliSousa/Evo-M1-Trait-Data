## ============================================================================
## Baker_etal_2025_b_SupplementaryData1.R
##
## Baker J, Barton RA, Venditti C (2025). Macroevolutionary brain scaling
## is a microevolutionary metaphenomenon. Nature Communications.
## doi:10.1038/s41467-025-66843-0
## (The "_b" suffix: Baker_etal_2025 without a suffix is the authors'
## Communications Biology paper of the same year, doi:10.1038/s42003-025-08686-5.)
##
## Item: Supplementary Data 1 -- whole-brain mass and body mass for
## 4,679 species across vertebrates, each row naming the literature
## source its values were taken from. The Evo-M1 analysis file keeps the
## 1,684 mammal rows.
##
## Frozen source (digital-native, no snapshot): the untouched
## publisher download, 41467_2025_66843_MOESM3_ESM.xlsx, kept verbatim
## in this folder under its original name. A digital-native file
## needs no snapshot when the registry lists it and the build script
## reads it directly: __ReadMe.xlsx records this filename in the
## item's "Snapshot filename" field. Nothing was re-saved or
## converted. This script reads ONLY that file (sheet "Data S1").
##
## Data role: SECONDARY (compilation). The values are other studies'
## measurements relayed by Baker et al.; the Source column keeps the
## full citation printed for each row. In Evo-M1's brain-mass merge the
## item is classified mass_or_volume_mixed and enters row by row only
## through __metadata/curation/brain_mass_row_basis.csv decisions.
## Brain masses compiled from endocranial volumes were converted by the
## original sources at 1 g = 1 cm3 (see _COMMON_CALCULATIONS.md).
##
## Cleaning done here (and nowhere else): keep the mammal rows
## (class == "mammals") and sort them by species name; rename the
## printed columns to the analysis names (Species -> Species_Baker2025
## as printed, with species_sci the same name with underscores replaced
## by spaces; bd_g -> Body_mass_g; br_g -> Brain_mass_g;
## sub-subclade -> sub_subclade). The two mass columns are rounded to
## 4 decimal places to strip the binary float noise present in the
## publisher file (e.g. a body mass of 58560.0000000006 g); the source file
## itself is unrounded. Non-breaking spaces in the Source citations are
## normalised to plain spaces.
##
## Outputs:
##   Baker_etal_2025_b_SupplementaryData1.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "Baker_etal_2025_b_SupplementaryData1.R"   # this file's own name
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

## ---- read the frozen source file (publisher workbook, sheet "Data S1") -----
snap <- readxl::read_excel(file.path(folder, "41467_2025_66843_MOESM3_ESM.xlsx"),
                           sheet = "Data S1")
stopifnot(nrow(snap) == 4679L)

## ---- clean: mammals only, analysis column names, values unchanged ----------
snap <- snap[snap[["class"]] == "mammals", ]
snap <- snap[order(snap[["Species"]]), ]
## round to 4 decimal places on the exact stored value (sprintf rounds
## the binary value correctly; round() mis-rounds exact halves such as
## the 0.42225 g brain mass of Mops condylurus, which is 0.4223)
round4 <- function(x) {
  out <- as.numeric(sprintf("%.4f", x))
  out[is.na(x)] <- NA_real_
  out
}
## the publisher's float formatting keeps a trailing .0 on whole numbers;
## reproduce it exactly (these two columns are written as text)
fmt_float <- function(x) {
  s <- sprintf("%.15g", x)
  whole <- !is.na(s) & !grepl("[.eE]", s)
  s[whole] <- paste0(s[whole], ".0")
  s[is.na(x)] <- NA_character_
  s
}
final.dataframe <- data.frame(
  species_sci       = gsub("_", " ", snap[["Species"]], fixed = TRUE),
  Species_Baker2025 = snap[["Species"]],
  class             = snap[["class"]],
  subclade          = snap[["subclade"]],
  sub_subclade      = snap[["sub-subclade"]],
  Body_mass_g       = fmt_float(round4(snap[["bd_g"]])),
  Brain_mass_g      = fmt_float(round4(snap[["br_g"]])),
  Source            = gsub("\u00A0", " ", snap[["Source"]], fixed = TRUE),  # non-breaking spaces -> plain spaces
  stringsAsFactors = FALSE
)
stopifnot(nrow(final.dataframe) == 1684L)

## ---- structural checks (the printed table carries no checkable totals) -----
table_checks <- data.frame(
  check_id   = c("one_row_per_species", "masses_complete"),
  basis      = c("species_sci values are unique across the 1,684 mammal rows",
                 "Body_mass_g and Brain_mass_g are present on every row"),
  observed   = c(sum(duplicated(final.dataframe[["species_sci"]])),
                 sum(is.na(final.dataframe[["Body_mass_g"]]) |
                     is.na(final.dataframe[["Brain_mass_g"]]))),
  printed    = 0,
  stringsAsFactors = FALSE
)
table_checks$difference <- table_checks$observed - table_checks$printed
table_checks$tolerance  <- 0
table_checks$status     <- ifelse(table_checks$difference == 0,
                                  "pass", "mismatch")
table_checks$note       <- ""
if (any(table_checks$status != "pass"))
  warning("Structural check mismatch -- values kept as published; ",
          "see the item ReadMe.")
message("Structural checks: ", sum(table_checks$status == "pass"), " of ",
        nrow(table_checks), " pass.")

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
