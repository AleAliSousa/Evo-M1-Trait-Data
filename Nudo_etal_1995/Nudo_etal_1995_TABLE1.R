# Nudo et al. 1995 - TABLE 1: body weight, brain weight and neocortical surface area
# for the 24 species / 21 genera in the corticospinal survey.
#
# PRINTED SOURCE -> the frozen copy is Nudo_etal_1995_TABLE1_snapshot.xlsx (sheet "TABLE1"),
# captured by Nudo_etal_1995_extract_snapshot.py from 300-dpi renders of p. 183. This script
# reads ONLY that snapshot.
#
# Output shape: ONE ROW PER SPECIES (24). Printed row order is kept (it is the same order the
# animal rows take in TABLES 2, 4 and 5).
#
# UNITS (sec 6 of __HOWTO_build_a_dataset_file.md). This table is unusual: the journal already
# prints the project units, so both conversions are x1 and are written out explicitly rather
# than silently omitted -
#     body weight   printed "(g)"   -> Body_Mass.g               = printed * 1     (g  -> g)
#     brain weight  printed "(mg)"  -> Brain_Mass.mg             = printed * 1     (mg -> mg)
#     cortical area printed "(mm2)" -> Neocortex_SurfaceArea.mm2 = printed * 1     (area is not
#                                      a volume/mass; mm2 is kept, per the task brief)
# Sanity: rat 268 g / 1,500 mg, least shrew 8 g / 80 mg, rhesus 3,300 g / 53,700 mg - i.e. the
# brain column really is milligrams, not grams.
#
# Source: Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). Variation and evolution of
#   mammalian corticospinal somata with special reference to primates.
#   J Comp Neurol 358(2):181-205. DOI 10.1002/cne.903580203.

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
item_name <- "Nudo_etal_1995_TABLE1"
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
# species_key.csv row scoped to source_publication == "Nudo1995". While those rows are still
# waiting to be merged into _keys/, the identical rows staged in this folder as
# PROPOSED_species_key_rows.csv are used instead, with a warning. Once merged, delete the
# staged file - the resolver then reads the canonical key only and the output is unchanged.
TOKEN <- "Nudo1995"
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
  data.frame(variant_name = character(0), accepted_name = character(0))
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
# Guarded thousands separators (Jacobs_etal_2018_Table3.R pattern, sec 6). Stripping commas is
# the house default, but it is done only when the token is a WELL-FORMED grouped number: the
# first group 1-3 digits and every later group exactly 3 digits. "7,120" parses; a mangled
# "7.120" or "1,4151" would not, and lands in parse_flags with the printed text quoted instead
# of being silently turned into a wrong number.
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
# Positional read (sec 3): row 1 = caption, rows 2-3 = the two header tiers, rows 4+ = data.
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TABLE1", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])
snap <- snap[nzchar(snap$V1) & nzchar(snap$V2), , drop = FALSE]   # drops any footnote row

## 5. BUILD --------------------------------------------------------
out <- NULL
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)
  flags <- character(0)
  body <- num1(r[3]); brain <- num1(r[4]); area <- num1(r[5])
  for (k in 3:5) if (nzchar(r[k]) && is.na(num1(r[k])))
    flags <- c(flags, sprintf("column %d printed '%s' - not parseable as a number", k, r[k]))
  out <- rbind(out, data.frame(
    Common_name_Nudo1995      = r[1],          # printed common name (invariant 3)
    Species_Nudo1995          = r[2],          # printed scientific name, verbatim, incl.
                                               # the printed genus abbreviations
                                               # "E. europaeus" / "M. mulatta"
    species_sci               = resolve(r[2]),
    Body_Mass.g               = body  * 1,     # printed g  -> project g   (x1)
    Brain_Mass.mg             = brain * 1,     # printed mg -> project mg  (x1)
    Neocortex_SurfaceArea.mm2 = area  * 1,     # printed mm2 kept as mm2   (x1)
    parse_flags               = if (length(flags)) paste(flags, collapse = "; ") else NA_character_,
    stringsAsFactors = FALSE))
}
rownames(out) <- NULL                          # printed row order preserved

## 5b. CHECKS ------------------------------------------------------
stopifnot(nrow(out) == 24)
if (any(is.na(out$Body_Mass.g) | is.na(out$Brain_Mass.mg) | is.na(out$Neocortex_SurfaceArea.mm2)))
  warning("TABLE 1: unparsed measure cell(s) - see parse_flags")
unresolved <- out$Species_Nudo1995[out$species_sci == out$Species_Nudo1995 &
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
cat(sprintf("Nudo TABLE 1: %d rows, %d flagged, %d species name(s) not resolved by the key\n",
            nrow(out), sum(!is.na(out$parse_flags)), length(unresolved)))
