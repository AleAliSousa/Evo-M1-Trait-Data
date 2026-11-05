## Munger EL, Edler MK, Hopkins WD, Hof PR, Sherwood CC, Raghanti MA (2022).
## Comparative analysis of astrocytes in the prefrontal cortex of primates:
## Insights into the evolution of human brain energetics. J Comp Neurol.
## doi:10.1002/cne.25387. TABLE 1.
##
## "Individuals included in the present study with age (years), sex, and brain
##  weight (grams) listed." One printed row per individual, four species.
##
## PDF text layer -> frozen snapshot -> analysis CSV -> public TSV, in one script: an
## extract-then-clean script (build HOWTO sec. 3), with the extraction modelled on
## Jacob_etal_2021/Jacob_etal_2021_extract_snapshot.R. Owner decision, 04 Nov 2026
## (revising the same day's "snapshot not needed"): the conversion to a snapshot lives
## in this script and the snapshot is saved in this folder.
##
## 1. SNAPSHOT. Reads p. 3 of the publisher PDF in this folder (born-digital, with a
##    text layer; pdftools::pdf_text) and writes <script stem>_snapshot.csv BEFORE any
##    cleaning: the caption row, the printed header row, then one row per printed row
##    in printed order - the species name only where it is printed (top of its block,
##    blank below it), age, sex, and the brain weight with its footnote mark exactly as
##    printed (124.2*, 384**, 118.0). No table value is typed here; every row is read
##    from the text layer. The caption and the four header cells are printed literals,
##    each checked against the page before anything is written: the caption shares its
##    lines with the page's second text column, so it cannot be cut out cleanly.
##    Frozen-file guard: if the snapshot is already here and the new extraction differs
##    from it, the extraction goes to <script stem>_snapshot_NEW.csv and the run stops,
##    so the frozen copy never changes silently. Set keep_frozen_snapshot <- TRUE (below)
##    only to build from a frozen copy that was corrected by hand on purpose (record the
##    correction in the README). With no PDF in the folder, step 1 is skipped and the
##    build runs from the frozen snapshot.
## 2. BUILD. Reads the frozen snapshot (never the PDF) and writes the analysis CSV and
##    the DOI-named public TSV.
##
## Text-layer layout. Table 1 fills the left column of p. 3. On several lines text from
## the right-hand column follows after a wide gap, so each line is read only for its
## four leading cells - [Genus species]  age  sex  brain weight[*|**] - and only when
## the age cell starts under the printed "Age (years)" header. The text layer puts an
## empty line between the 41-year and 43-year chimpanzees (paragraph spacing in the
## right-hand column); it is not a printed row and is not in the snapshot. The caption's
## "TABLE 1" is letter-spaced in the text layer ("TA B L E 1").
##
## Footnote marks (caption): "*" = brain weight extrapolated from one hemisphere;
## "**" = the average brain weight for the species (Robson & Wood, 2008), i.e. not
## a measurement of this individual. Kept as brain_weight_marker and spelled out
## in brain_weight_basis; the value itself is never changed.
##
## Units: the table prints grams; the analysis CSV carries project units,
## brain_weight_mg = printed grams x 1000 (build HOWTO sec. 6). The printed gram
## string stays in brain_weight_printed.
##
## Input : the paper's PDF in this folder (the only .pdf here), p. 3
## Output: <script stem>_snapshot.csv  the frozen snapshot (step 1)
##         <script stem>.csv           one row per individual (step 2)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
## Species: _keys/Hof/species_key.csv rows for Munger_etal_2022 (never an inline map).
## Specimens: no accession or house name is printed; specimen_row is the printed
## row order, a local locator only. Cross-paper identity evidence (Bauernfeind
## 2013, Stimpson 2015, Hrvoj-Mihic 2026) is kept in
## _keys/specimen_crosswalk/Munger2022_specimen_note.md, not in this table.

options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder       <- dirname(.sp)
item_name    <- tools::file_path_sans_ext(basename(.sp))
source_name  <- sub("_TABLE[^_]*$", "", item_name)
output_csv   <- paste0(item_name, ".csv")
snapshot_csv <- paste0(item_name, "_snapshot.csv")
keep_frozen_snapshot <- FALSE    # TRUE only for a deliberately hand-corrected snapshot (see header)
base         <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

say <- function(...) message("[", item_name, "] ", ...)

## the printed header cells (structure, not data): written in step 1, checked again in step 2
header_cells <- c("Genus, species", "Age (years)", "Sex", "Brain weight (g)")

## CSV writing for the snapshot: a field is quoted only when it holds a comma or a quote
csv_field <- function(x) ifelse(grepl('[",]', x), paste0('"', gsub('"', '""', x, fixed = TRUE), '"'), x)
csv_row   <- function(x) paste(csv_field(x), collapse = ",")

## frozen-file guard + writer (UTF-8, LF line ends; model: Jacob_etal_2021_extract_snapshot.R)
write_snapshot <- function(lines, path) {
  txt   <- enc2utf8(paste0(paste(lines, collapse = "\n"), "\n"))
  bytes <- charToRaw(txt)
  put   <- function(p) { con <- file(p, open = "wb"); on.exit(close(con)); writeBin(bytes, con) }
  if (!file.exists(path)) { put(path); say("snapshot written: ", path); return(invisible(TRUE)) }
  if (identical(readBin(path, "raw", file.info(path)$size), bytes)) {
    say("snapshot unchanged (frozen): ", path); return(invisible(TRUE))
  }
  alt <- sub("\\.csv$", "_NEW.csv", path)
  put(alt)
  if (!keep_frozen_snapshot)
    stop(path, " differs from this extraction of the PDF, which was written to ", alt, ". ",
         "Compare both with the printed table: delete the frozen copy to accept the new ",
         "extraction, or set keep_frozen_snapshot <- TRUE to build from the frozen copy.",
         call. = FALSE)
  warning(path, " differs from the PDF extraction (see ", alt, "); building from the frozen ",
          "copy because keep_frozen_snapshot is TRUE.", call. = FALSE)
  invisible(FALSE)
}

## ==== 1. SNAPSHOT: the PDF's text layer -> <item>_snapshot.csv (before any cleaning) ====
pdf_file <- list.files(folder, pattern = "\\.pdf$", ignore.case = TRUE)
if (length(pdf_file) > 1L)
  stop("Expected one PDF of the paper in ", folder, "; found ", length(pdf_file), ".", call. = FALSE)
if (length(pdf_file) == 0L) {
  if (!file.exists(snapshot_csv))
    stop("Neither the paper's PDF nor ", snapshot_csv, " is in ", folder, ".", call. = FALSE)
  say("no PDF in this folder: step 1 skipped, building from the frozen ", snapshot_csv)
} else {
  if (!requireNamespace("pdftools", quietly = TRUE))
    stop("Package 'pdftools' is needed: install.packages('pdftools')", call. = FALSE)
  pages <- pdftools::pdf_text(pdf_file)

  pg <- grep("T\\s*A\\s*B\\s*L\\s*E\\s*1\\s+Individuals included", pages)
  if (length(pg) != 1L) stop("Table 1 caption not found exactly once in ", pdf_file, call. = FALSE)
  lines     <- strsplit(pages[pg], "\n", fixed = TRUE)[[1]]
  page_flat <- gsub("\\s+", " ", pages[pg])

  ## the caption, one printed line per element; each is checked on the page
  caption_lines <- c(
    "Individuals included in the present study with age",
    "(years), sex, and brain weight (grams) listed. When the exact brain",
    "weight for a specimen was unknown, it was extrapolated from one",
    "hemisphere (*) or the average brain weight for the species was used",
    "(**, Robson & Wood, 2008)")
  for (x in caption_lines)
    if (!grepl(x, page_flat, fixed = TRUE))
      stop("Table 1 caption text not found on p. ", pg, ": ", x, call. = FALSE)
  caption <- paste("TABLE 1", paste(caption_lines, collapse = " "))

  hdr <- grep("Genus, species", lines, fixed = TRUE)
  if (length(hdr) != 1L) stop("Table 1 header row not found exactly once.", call. = FALSE)
  for (x in header_cells)
    if (!grepl(x, lines[hdr], fixed = TRUE)) stop("Table 1 header cell not found: ", x, call. = FALSE)
  age_col <- regexpr("Age (years)", lines[hdr], fixed = TRUE)[1]
  sex_col <- regexpr("Sex", lines[hdr], fixed = TRUE)[1]
  stopifnot(age_col > 0, sex_col > age_col)

  ## printed rows: [species cell] age sex weight marker, then (optionally) right-column text
  row_rx <- "^([^0-9]*?)\\s+([0-9]+)\\s+([MF])\\s+([0-9]+(?:\\.[0-9]+)?)(\\**)(?:\\s{2,}.*)?$"
  body   <- lines[(hdr + 1L):length(lines)]
  m      <- regexec(row_rx, body, perl = TRUE)
  first_digit <- regexpr("[0-9]", body)
  keep   <- vapply(m, function(x) x[1] != -1L, logical(1)) &
            first_digit >= age_col - 3L & first_digit < sex_col
  if (!any(keep)) stop("No Table 1 rows recognised under the header.", call. = FALSE)
  cells <- regmatches(body[keep], m[keep])
  rows  <- lapply(cells, function(x) c(trimws(x[2]), x[3], x[4], paste0(x[5], x[6])))

  write_snapshot(c(csv_row(c(caption, rep("", length(header_cells) - 1L))),
                   csv_row(header_cells),
                   vapply(rows, csv_row, character(1))),
                 snapshot_csv)
}

## ==== 2. BUILD: the frozen snapshot -> analysis CSV + public TSV ========================
## positional read: row 1 = caption, row 2 = printed header, then one row per individual
snap <- read.csv(snapshot_csv, header = FALSE, colClasses = "character",
                 na.strings = character(0), fileEncoding = "UTF-8")
if (ncol(snap) != length(header_cells) ||
    !identical(unname(unlist(snap[2, ])), header_cells))
  stop("Row 2 of ", snapshot_csv, " is not the printed Table 1 header.", call. = FALSE)
body <- snap[-(1:2), , drop = FALSE]
names(body) <- c("species_cell", "age", "sex", "weight_cell")

## the printed brain-weight cell = grams + footnote mark ("", "*" or "**")
wm <- regmatches(body$weight_cell,
                 regexec("^([0-9]+(?:\\.[0-9]+)?)(\\**)$", body$weight_cell, perl = TRUE))
if (any(lengths(wm) != 3L))
  stop("Unreadable brain-weight cell in ", snapshot_csv, ": ",
       paste(body$weight_cell[lengths(wm) != 3L], collapse = " | "), call. = FALSE)
tab <- data.frame(species_cell = body$species_cell, age = body$age, sex = body$sex,
                  weight = vapply(wm, `[`, "", 2), marker = vapply(wm, `[`, "", 3),
                  stringsAsFactors = FALSE)

## the species is printed once at the top of its block; carry it down the block
species_printed <- trimws(tab$species_cell)
species_printed[!nzchar(species_printed)] <- NA_character_
if (is.na(species_printed[1])) stop("First Table 1 row has no species name.", call. = FALSE)
for (i in seq_along(species_printed)[-1])
  if (is.na(species_printed[i])) species_printed[i] <- species_printed[i - 1L]

## structural checks only (no expected values are typed here)
stopifnot(all(tab$sex %in% c("M", "F")),
          all(tab$marker %in% c("", "*", "**")),
          !anyNA(suppressWarnings(as.integer(tab$age))),
          !anyNA(suppressWarnings(as.numeric(tab$weight))),
          !anyDuplicated(rle(species_printed)$values))   # each species is one contiguous block
say("read ", nrow(tab), " printed rows in ", length(unique(species_printed)), " species blocks.")

## ---- species harmonisation via the collection key (never an inline map) --------
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
if (is.na(key_path) || !file.exists(key_path))
  stop("Species key not found. Run this script from inside a clone of the repository, so this ",
       "folder sits under the one holding __ReadMe.xlsx.", call. = FALSE)
key <- read.csv(key_path, stringsAsFactors = FALSE)
key <- key[key$source_publication == source_name, ]
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
species_accepted <- unname(lk[tolower(species_printed)])
missing <- unique(species_printed[is.na(species_accepted)])
if (length(missing))
  stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ", paste(missing, collapse = "; "),
       ". Add the rows to the key file, not to this script.", call. = FALSE)

## ---- analysis table ----------------------------------------------------------------
basis <- ifelse(tab$marker == "", "measured",
         ifelse(tab$marker == "*", "extrapolated from one hemisphere",
                                   "species average (Robson & Wood, 2008)"))
final.dataframe <- data.frame(
  specimen_row         = seq_len(nrow(tab)),          # printed row order; not an accession
  species              = species_accepted,
  species_as_published = species_printed,
  age_years            = as.integer(tab$age),
  sex                  = tab$sex,
  brain_weight_printed = paste0(tab$weight, tab$marker),   # grams, exactly as printed
  brain_weight_mg      = as.numeric(tab$weight) * 1000,    # g x 1000 = mg (project unit)
  brain_weight_marker  = ifelse(nzchar(tab$marker), tab$marker, NA_character_),
  brain_weight_basis   = basis,
  source               = source_name,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(!anyNA(final.dataframe$species))   # never write a file with an empty species column

write.csv(final.dataframe, output_csv, row.names = FALSE)
say("built: ", output_csv, " - ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns.")

## ---- public TSV: the DOI code comes from __ReadMe.xlsx (never typed here) ----------
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (grepl("\\s", item_encoded)) {
  stop("'Item encoded' for ", item_name, " contains a space: '", item_encoded, "'. The citation ",
       "in column A of __ReadMe.xlsx ends with a space after the DOI; delete it so the TSV is ",
       "named by the DOI alone, then re-run.", call. = FALSE)
} else if (!dir.exists(tsv_dir)) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  say("built: ", item_encoded, ".tsv in __Public/comparative-data/")
}
