## Munger EL, Edler MK, Hopkins WD, Hof PR, Sherwood CC, Raghanti MA (2022).
## Comparative analysis of astrocytes in the prefrontal cortex of primates:
## Insights into the evolution of human brain energetics. J Comp Neurol.
## doi:10.1002/cne.25387. TABLE 4.
##
## "Descriptive statistics for all variables with the mean and standard deviation
##  for each species". Twelve variable rows x four species columns; each cell is
##  printed "mean +/- SD (n)", n = number of individuals analysed (table note).
##
## PDF text layer -> frozen snapshot -> analysis CSV -> public TSV, in one script: an
## extract-then-clean script (build HOWTO sec. 3), with the extraction modelled on
## Jacob_etal_2021/Jacob_etal_2021_extract_snapshot.R. Owner decision, 04 Nov 2026
## (revising the same day's "snapshot not needed"): the conversion to a snapshot lives
## in this script and the snapshot is saved in this folder.
##
## 1. SNAPSHOT. Reads p. 11 of the publisher PDF in this folder (born-digital, with a
##    text layer; pdftools::pdf_text) and writes <script stem>_snapshot.csv BEFORE any
##    cleaning, laid out as printed: the caption row, the header row ("Variable" and
##    the four species as printed), one row per printed variable row in printed order
##    (the label, then the four "mean +/- SD (n)" cells exactly as printed), and the two
##    table-note rows. Everything is read from the text layer - caption, header cells,
##    labels, cells and notes; no table value or label is typed here. Anchors: the
##    caption "TABLE 4 Descriptive statistics", the header cell "Variable" and the table
##    note "Note: The number of individuals".
##    Frozen-file guard: if the snapshot is already here and the new extraction differs
##    from it, the extraction goes to <script stem>_snapshot_NEW.csv and the run stops,
##    so the frozen copy never changes silently. Set keep_frozen_snapshot <- TRUE (below)
##    only to build from a frozen copy that was corrected by hand on purpose (record the
##    correction in the README). With no PDF in the folder, step 1 is skipped and the
##    build runs from the frozen snapshot.
## 2. BUILD. Reads the frozen snapshot (never the PDF) and writes the analysis CSV and
##    the DOI-named public TSV.
##
## Text-layer layout, and what the snapshot does about it. A printed cell that wraps
## onto two lines is still one cell, so the snapshot holds it in one cell:
##  - long labels wrap onto a second line that starts with "(" (for example
##    "(GFAPv, mm3)"); that line is joined to the label above it with one space;
##  - the four GLUT1 vessel-volume cells print "mean +/-" on one line and "SD (n)" on
##    the next, in the same column; the two are joined column by column with one space.
## The superscript in "mm3" / "um3" is plain "3" in the text layer, followed by a stray
## space before ")" ("(Gv, mm3 )"); the space is closed so the label reads as printed.
## The caption's "TABLE 4" is letter-spaced in the text layer ("TA B L E 4"); internal
## runs of spaces in the caption and notes are reduced to one.
##
## Output is long: one row per printed cell (variable x species), in printed order
## (variables top to bottom, species left to right). variable_code is derived from
## the printed label (mu -> u, then every run of other characters -> "_"); it is a
## key for joins and for __merging_supplementary/supplementary_sources.csv, not a
## renaming of the label, which stays in variable_printed.
##
## Units are kept as printed (the table already uses mm3 / um3 / %). The printed unit
## of "GLUT1-ir vessel volume (mm3)" is doubtful - values of 1e8 cannot be mm3 of
## vessel in area 9 - and is NOT converted here; see the definitions file.
##
## Input : the paper's PDF in this folder (the only .pdf here), p. 11
## Output: <script stem>_snapshot.csv  the frozen snapshot (step 1)
##         <script stem>.csv           one row per variable x species (step 2)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
## Species: _keys/Hof/species_key.csv rows for Munger_etal_2022 (never an inline map).

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

## one printed cell: "mean +/- SD (n)", thousands separated by commas
pm      <- "\u00b1"
cell_rx <- paste0("^([0-9][0-9,]*(?:\\.[0-9]+)?)\\s*", pm, "\\s*([0-9][0-9,]*(?:\\.[0-9]+)?)\\s*\\(([0-9]+)\\)$")

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

  cap_rx <- "T\\s*A\\s*B\\s*L\\s*E\\s*4\\s+Descriptive statistics"
  pg <- grep(cap_rx, pages)
  if (length(pg) != 1L) stop("Table 4 caption not found exactly once in ", pdf_file, call. = FALSE)
  lines <- strsplit(pages[pg], "\n", fixed = TRUE)[[1]]

  cap <- grep(cap_rx, lines)
  hdr <- grep("^\\s*Variable\\s{2,}", lines)
  end <- grep("^\\s*Note: The number of individuals", lines)
  if (length(cap) != 1L || length(hdr) != 1L || length(end) < 1L || cap >= hdr || end[1] <= hdr)
    stop("Table 4 caption, header row or table note not found in order.", call. = FALSE)

  ## caption: the printed line after the letter-spaced "TABLE 4"
  caption <- paste("TABLE 4", gsub("\\s+", " ", trimws(
    sub("^.*?T\\s*A\\s*B\\s*L\\s*E\\s*4\\s+", "", lines[cap], perl = TRUE))))

  ## header: "Variable" + the species as printed
  header_cells <- strsplit(trimws(lines[hdr]), "\\s{2,}")[[1]]
  k <- length(header_cells) - 1L
  stopifnot(header_cells[1] == "Variable", k >= 2L)

  ## table notes: the "Note:" line and the "Abbreviation(s):" line(s) right after it
  notes <- character(0); nx <- end[1]
  while (nx <= length(lines) && grepl("^\\s*(Note|Abbreviations?):", lines[nx])) {
    notes <- c(notes, gsub("\\s+", " ", trimws(lines[nx]))); nx <- nx + 1L
  }

  body <- lines[(hdr + 1L):(end[1] - 1L)]
  body <- body[nzchar(trimws(body))]

  ## split each line into its label part and its value part
  pos      <- regexpr("\\s{2,}[0-9]|^\\s*[0-9]", body)            # where the first value cell starts
  label_pt <- ifelse(pos > 0, substr(body, 1L, pos - 1L), body)
  value_pt <- ifelse(pos > 0, substr(body, pos, nchar(body)), "")
  label_pt <- trimws(label_pt)

  ## a printed row starts with a label that does not begin with "(" (a wrapped label line does)
  starts <- nzchar(label_pt) & !startsWith(label_pt, "(")
  if (!starts[1]) stop("Table 4 body does not start with a variable label.", call. = FALSE)
  rec_id <- cumsum(starts)

  cells_of <- function(v) {                                   # value line -> printed column cells
    v <- trimws(v)
    if (!nzchar(v)) return(character(0))
    strsplit(v, "\\s{2,}")[[1]]
  }
  rows <- lapply(split(seq_along(body), rec_id), function(ix) {
    lab <- gsub("\\s+", " ", paste(label_pt[ix][nzchar(label_pt[ix])], collapse = " "))
    lab <- gsub("\\s+\\)", ")", lab)                           # "(Gv, mm3 )" -> "(Gv, mm3)"
    vl  <- Filter(length, lapply(value_pt[ix], cells_of))
    if (length(vl) == 1L) {
      cl <- vl[[1]]
    } else if (length(vl) == 2L && length(vl[[1]]) == k && length(vl[[2]]) == k &&
               all(endsWith(vl[[1]], pm))) {                     # wrapped "mean +/-" / "SD (n)"
      cl <- paste(vl[[1]], vl[[2]])
    } else stop("Unexpected value layout for Table 4 row: ", lab, call. = FALSE)
    if (length(cl) != k) stop("Table 4 row '", lab, "' has ", length(cl), " cells, not ", k, call. = FALSE)
    bad <- !grepl(cell_rx, cl, perl = TRUE)
    if (any(bad)) stop("Unreadable cell in Table 4 row '", lab, "': ",
                       paste(cl[bad], collapse = " | "), call. = FALSE)
    c(lab, cl)
  })

  blank <- rep("", k)
  write_snapshot(c(csv_row(c(caption, blank)),
                   csv_row(header_cells),
                   vapply(unname(rows), csv_row, character(1)),
                   vapply(notes, function(x) csv_row(c(x, blank)), character(1), USE.NAMES = FALSE)),
                 snapshot_csv)
}

## ==== 2. BUILD: the frozen snapshot -> analysis CSV + public TSV ========================
## positional read: row 1 = caption, row 2 = printed header, then one row per printed
## variable row, then the table-note rows (text in the first cell only)
snap <- read.csv(snapshot_csv, header = FALSE, colClasses = "character",
                 na.strings = character(0), fileEncoding = "UTF-8")
header_row <- unname(unlist(snap[2, ]))
if (header_row[1] != "Variable")
  stop("Row 2 of ", snapshot_csv, " is not the printed Table 4 header.", call. = FALSE)
species_printed_order <- header_row[-1]
k <- length(species_printed_order)
stopifnot(k >= 2L)

body    <- snap[-(1:2), , drop = FALSE]
is_data <- apply(body[, -1, drop = FALSE] != "", 1, all)
is_note <- apply(body[, -1, drop = FALSE] == "", 1, all)
if (!all(is_data | is_note) || any(diff(as.integer(is_note)) < 0))
  stop(snapshot_csv, ": every row after the header must be a full data row, and the note rows ",
       "must come last.", call. = FALSE)
rows <- body[is_data, , drop = FALSE]

num  <- function(x) as.numeric(gsub(",", "", x, fixed = TRUE))
recs <- lapply(seq_len(nrow(rows)), function(i) {
  lab <- rows[i, 1]
  cl  <- unname(unlist(rows[i, -1]))
  mm  <- regmatches(cl, regexec(cell_rx, cl, perl = TRUE))
  if (any(lengths(mm) != 4L)) stop("Unparsed cell in Table 4 row '", lab, "': ",
                                   paste(cl[lengths(mm) != 4L], collapse = " | "), call. = FALSE)
  data.frame(variable_printed     = lab,
             species_as_published = species_printed_order,
             value_printed        = cl,
             mean = num(vapply(mm, `[`, "", 2)),
             sd   = num(vapply(mm, `[`, "", 3)),
             n    = as.integer(vapply(mm, `[`, "", 4)),
             stringsAsFactors = FALSE)
})
tab <- do.call(rbind, recs)
tab$variable_row <- rep(seq_along(recs), each = k)
say("read ", length(recs), " printed variable rows x ", k, " species.")

## ---- label parts derived from the printed label -----------------------------------
paren_of <- function(lbl) { p <- regmatches(lbl, regexpr("\\(([^()]*)\\)$", lbl))
                            if (length(p)) substr(p, 2L, nchar(p) - 1L) else NA_character_ }
inside <- vapply(tab$variable_printed, paren_of, "", USE.NAMES = FALSE)
abbr   <- ifelse(!is.na(inside) & grepl(",", inside, fixed = TRUE), trimws(sub(",.*$", "", inside)), NA_character_)
unit   <- ifelse(is.na(inside), NA_character_, trimws(sub("^.*,", "", inside)))
region <- ifelse(grepl("layer I\\b", tab$variable_printed), "layer I",
          ifelse(grepl("\\bWM\\b", tab$variable_printed), "WM", NA_character_))
code   <- gsub("[\u00b5\u03bc]", "u", tab$variable_printed)
code   <- gsub("^_+|_+$", "", gsub("[^A-Za-z0-9]+", "_", code))
stopifnot(length(unique(code)) == length(recs))           # one code per printed variable row

## ---- species harmonisation via the collection key (never an inline map) --------
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
if (is.na(key_path) || !file.exists(key_path))
  stop("Species key not found. Run this script from inside a clone of the repository, so this ",
       "folder sits under the one holding __ReadMe.xlsx.", call. = FALSE)
key <- read.csv(key_path, stringsAsFactors = FALSE)
key <- key[key$source_publication == source_name, ]
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
species_accepted <- unname(lk[tolower(tab$species_as_published)])
missing <- unique(tab$species_as_published[is.na(species_accepted)])
if (length(missing))
  stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ", paste(missing, collapse = "; "),
       ". Add the rows to the key file, not to this script.", call. = FALSE)

final.dataframe <- data.frame(
  species              = species_accepted,
  species_as_published = tab$species_as_published,
  variable_row         = tab$variable_row,
  variable_printed     = tab$variable_printed,
  variable_code        = code,
  abbreviation_printed = abbr,
  region_printed       = region,
  unit_printed         = unit,
  value_printed        = tab$value_printed,
  mean                 = tab$mean,
  sd                   = tab$sd,
  n                    = tab$n,
  source               = source_name,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(!anyNA(final.dataframe$species), !anyNA(final.dataframe$mean),
          !anyNA(final.dataframe$sd), !anyNA(final.dataframe$n))

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
