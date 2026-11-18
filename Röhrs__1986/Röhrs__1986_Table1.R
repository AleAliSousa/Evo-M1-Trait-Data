## ============================================================================
## Röhrs__1986_Table1.R
##
## Röhrs M (1986). Cephalisation, Telencephalisation und
## Neocorticalisation bei Mustelidae. Zeitschrift fuer Zoologische
## Systematik und Evolutionsforschung 24: 157-166.
## doi:10.1111/j.1439-0469.1986.tb00624.x
##
## Item: Table 1 (journal p. 161) -- "Bruttokoerpergewichte (BKG),
## Hirngewichte (HG) von 20 Mustelidenarten": gross body weight and brain
## weight (species means, with n) and the Cephalisation index (deviation
## from the Mustela reference line = 100) for 20 mustelid species.
##
## Frozen source: Röhrs__1986_Table1_snapshot.csv in this folder -- the
## table transcribed exactly as printed (printed headers, row order,
## German decimal commas, the footnote mark on the three species whose
## values were determined after Drescher 1977), BEFORE any cleaning.
## Transcribed by Buddy (AI assistant) on 2026-11-18 from the journal scan
## held in this folder (Ro_hrs-1986-Cephalisation__Telen.pdf, supplied by
## Michael Proulx) and verified cell by cell against the rendered page
## image (journal p. 161). This script reads ONLY the snapshot.
##
## Data role: PRIMARY. The values are the Hannover group's own species
## means (196 individuals), except the three footnoted species taken from
## Drescher (1977), which the note column flags.
##
## Outputs:
##   Röhrs__1986_Table1.csv   (this folder)
##   __Public/comparative-data/<Item encoded>.tsv
##     (Item encoded looked up in __ReadMe.xlsx by Item name)
## ============================================================================

## ---- self-locating header: names are derived, never retyped ----------------
script_path <- local({
  me   <- "Röhrs__1986_Table1.R"   # this file's own name
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
item_name_registry <- "Röhrs__1986_Table1"
registry     <- readxl::read_excel(file.path(repo_root, "__ReadMe.xlsx"),
                                   sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name_registry,
                                                 registry[["Item name"]])]
if (is.na(item_encoded)) stop("Item not found in registry: ", item_name_registry)

## ---- read the frozen snapshot (as printed; positional, everything text) ----
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", header = TRUE,
                 stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 20L, ncol(snap) == 5L)
names(snap) <- c("species_printed", "BKG_g", "HG_g", "Cephalisation", "n")

## ---- clean (all cleaning happens here, never in the snapshot) --------------
## German decimal commas become points; the printed footnote mark (a
## superscript 1 on Martes pennanti, Taxidea taxus and Lutra canadensis)
## becomes the note column: those values were determined after
## Drescher (1977), per the table's footnote 1.
num <- function(x) as.numeric(gsub(",", ".", x, fixed = TRUE))
## the printed brain weights carry one or two decimals; a whole-number
## weight is written with its decimal (15.0, not 15), as published
fmt_float <- function(x) {
  s <- sprintf("%.15g", x)
  whole <- !is.na(s) & !grepl("[.eE]", s)
  s[whole] <- paste0(s[whole], ".0")
  s[is.na(x)] <- NA_character_
  s
}
footnoted <- grepl("¹", snap$species_printed, fixed = TRUE)
final.dataframe <- data.frame(
  species_sci    = gsub("¹", "", snap$species_printed, fixed = TRUE),
  Body_mass_g_gross = as.integer(snap$BKG_g),
  Brain_mass_g      = fmt_float(num(snap$HG_g)),
  Cephalisation     = as.integer(snap$Cephalisation),
  n                 = as.integer(snap$n),
  note = ifelse(footnoted,
                "Values determined after Drescher (1977), Table 1 footnote 1",
                NA_character_),   # NA writes as an empty field, not ""
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
