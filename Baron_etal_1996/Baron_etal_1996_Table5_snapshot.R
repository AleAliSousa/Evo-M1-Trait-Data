# Baron_etal_1996_Table5_snapshot.R -- writes ONLY Baron_etal_1996_Table5_snapshot.csv
#
# R port (2026-11-12) of Baron_etal_1996_Table5_snapshot.py, retired as
# Baron_etal_1996_Table5_snapshot.py.retired. The original docstring follows (the Python-specific
# "pageN.txt" input is replaced by the text layer read per page with `pdftotext -raw`, i.e. in the PDF's
# content-stream order, which is the order the line-based parser relies on).
#
# Extract Baron, Stephan & Frahm (1996) Table 5 ("Average body weights (BoW)
# and brain weights (BrW) of 342 species and/or subspecies of bats", PDF pp.
# 22-32, printed pp. 284-294) from the PDF text layer.
#
# Companion to Baron_etal_1996_Table10_snapshot.py / Baron_etal_1996_Table32_snapshot.py (Tables 10/32) and
# Baron_etal_1996_Table2_snapshot.py (Table 2). Unlike Table 2, this table's
# text layer IS one-species-per-line (no crammed multi-species lines), which
# makes line-based parsing straightforward - but each species can have
# between 1 and 4 printed lines:
#
#   1. The species' own first line - the "standard" (bold-faced in print).
#      Per the table's own notes: "If there is more than one line for a
#      species, the first line includes the pairs of body and brain weights
#      used to establish the standards." THIS is the only line built here.
#   2. Optional "males" / "females" / "median inter sexes" sub-lines - sex-
#      differentiated detail already folded into the standard line above.
#   3. Optional bare-numeric continuation lines with no species name at all -
#      literature-comparison values "which more strongly deviate and were
#      therefore not included in the standards" (per the same notes).
#
# Sub-lines and bare-numeric continuations are recognized and skipped: a line
# is only treated as a new species if its first character is an uppercase
# letter (or the section-sign footnote marker); anything starting with a
# digit or with a known continuation keyword (males/female/median/presumed)
# is skipped.
#
# Each species' data run has up to 7 fields, several independently optional:
# BoW, [CV_BoW], BrW, [CV_BrW], [n_BoW, n_BrW | n], Source. CV values (always
# one decimal place, e.g. "9.5") are distinguished from BoW/BrW (which may or
# may not have a decimal point) purely by checking for a decimal point in the
# position where a CV would fall - BrW is never itself printed with a decimal
# point in this table, so this rule is unambiguous. Source is always the
# line's last token and may be a letter code, a bare citation-index digit, or
# a comma-joined list (e.g. "10,12,S"); it never needs disambiguating from n
# because the state machine tracks how many trailing tokens remain (1: Source
# only; 2: shared n + Source; 3: n_BoW, n_BrW, Source).
#
# One species (*Mosia nigrescens*) is printed with a footnote marker but NO
# weight data at all (only a "see addendum" reference) - it is kept as a row
# with blank measurement fields, since it is one of the source's own stated
# 342 species/subspecies and dropping it silently would misrepresent the
# table's total.
#
# The snapshot preserves the source's own printed family/subfamily ALL-CAPS
# section headings (e.g. "PTEROPODIDAE", "PTEROPODINAE (cont.)") as their own
# rows (`is_header=TRUE`, all measurement fields blank), rather than
# discarding them, so the snapshot reads as a faithful visual mirror of the
# printed table's taxonomic groupings - useful for a human skimming the file,
# and trivially filterable (`is_header` blank) for anything that wants
# species rows only. These header rows are NOT carried into the analysis CSV
# (Baron_etal_1996_Table5.R strips them before writing the final output).
#
# A small number of species names have a confirmed, image-verified OCR
# letterform correction applied (documented in NAME_FIXES below) - each was
# cross-checked either directly against a rendered page image, or against the
# same species' independently image-verified spelling in the sibling
# Baron_etal_1996_Table2 build (same source book, same species, already
# verified there against its own page images). Cosmetic spacing/letterform
# artifacts that were NOT independently confirmed are left as printed.
#
# Output: Baron_etal_1996_Table5_snapshot.csv, 342 species rows plus their
# interspersed section-heading rows, matching the table's own stated
# species/subspecies count exactly, from Eidolon helvum through Cheiromeles
# torquatus.
#
# Port notes (verified in a temp dir, never in place: the regenerated CSV is byte-identical to the frozen one)
#  * Page text: pdftotext -raw (poppler-utils) per PDF page 22-32. The earlier Python run used another
#    extractor's text of the same OCR layer; two lines read differently and are handled below:
#    (1) the footnote line "CV =coefficient of variation" (no space after "=") -> the skip pattern
#        '^CV = coefficient' is written '^CV\\s*=\\s*coefficient';
#    (2) the heading printed with a word gap in the earlier text, "MINIOPTERIN AE", reads "MINIOPTERINAE"
#        here; HEADING_SPACING restores the frozen spelling (no value changes).
#  * An existing frozen snapshot that differs is never overwritten.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
HERE <- dirname(.sp)
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # Baron_etal_1996_Table5
PDF <- file.path(HERE, "baron_etal_1996 book Comparative Neurobiology.pdf")
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

SKIP_LINE_PATTERNS <- c(
  "^\\d+\\s+Brains of Chiroptera",
  "^>\\s*Table 5",
  "^Table 5\\.",
  "^and/or subspecies",
  "^BoW\\s+CV\\s+BrW",
  "^in g in %",
  "^Notes to Table 5",
  "^If there is more than one line",
  "^pairs of body and brain",
  "^either single values",
  "^females and median",
  "^the preceding lines",
  "^more strongly deviate",
  "^are bold-faced",
  "^\\*\\) Median values",
  "^significant sex differences",
  "^\u00a7\\) See addendum",
  "^The standards are bold",
  "^CV\\s*=\\s*coefficient",
  "^n = number of specimens",
  "^Key to the source",
  "^\\d+: ",
  "^\\*\\*\\) Doubtful determination"
)
CONTINUATION_STARTS <- c("males", "male", "females", "female", "median", "presumed")
HEADING_SPACING <- c("MINIOPTERINAE" = "MINIOPTERIN AE")

# Species-name OCR corrections, each individually confirmed against a rendered page image (either Table 5's
# own page, or -- for species shared with Table 2 -- that item's already image-verified spelling). Applied as
# whole-name literal replacements after the name/data split, so they never touch numeric data.
NAME_FIXES <- c(
  "Pteropus alec to" = "Pteropus alecto",
  "Pteropus maerotis" = "Pteropus macrotis",
  "Pteropus neohibernieus" = "Pteropus neohibernicus",
  "Pteropus polioeephalus *)" = "Pteropus poliocephalus *)",
  "Pteropus seapulatus" = "Pteropus scapulatus",
  "Pteropus temmineki" = "Pteropus temmincki",
  "Mieropteropus pusillus" = "Micropteropus pusillus",
  "Seotonyeteris zenkeri" = "Scotonycteris zenkeri",
  "Casinyeteris argynnis *)" = "Casinycteris argynnis *)",
  "Chi ron ax melanocephalus" = "Chironax melanocephalus",
  "Nycteris macro tis" = "Nycteris macrotis",
  "Megaderma spasm a" = "Megaderma spasma",
  "Sturn ira ludovici" = "Sturnira ludovici",
  "Sturn ira tildae" = "Sturnira tildae",
  "Tadarida leu co stigma" = "Tadarida leucostigma",
  "Ametrida centuria" = "Ametrida centurio",
  "Miniopterus infiatus" = "Miniopterus inflatus",
  "D. moluee. magna \u00a7)" = "D. molucc. magna \u00a7)",
  "D. moluee. anderseni *) \u00a7)" = "D. molucc. anderseni *) \u00a7)"
)
S_FOR_5_PAGE <- 23L   # see the docstring: page-wide OCR confusion of "S" for "5" in the Source column


NUM_RE <- "^-?[0-9]+(\\.[0-9]+)?$"
DEC_RE <- "^-?[0-9]+\\.[0-9]+$"

is_skip_line <- function(line) {
  s <- trimws(line)
  if (!nzchar(s)) return(TRUE)
  any(vapply(SKIP_LINE_PATTERNS, function(p) grepl(p, s, perl = TRUE), TRUE))
}
is_all_caps_header <- function(line) {
  letters_only <- gsub("[^A-Za-z]", "", trimws(line))
  nchar(letters_only) >= 3 && letters_only == toupper(letters_only)
}
clean_ocr <- function(text) {
  text <- gsub("(?<![A-Za-z])I(?![A-Za-z.])", "1", text, perl = TRUE)   # standalone 'I' -> '1'
  gsub("1O,S", "10,S", text, fixed = TRUE)
}
fix_source_s_for_5 <- function(source, page_num) {
  if (is.na(source) || page_num != S_FOR_5_PAGE) return(source)
  if (source == "5") return("S")
  if (endsWith(source, ",5")) return(paste0(substr(source, 1, nchar(source) - 1L), "S"))
  source
}
empty_row <- function(name, page_num)
  list(species_printed = name, source_pdf_page = page_num, BoW_g = NA_character_, CV_BoW_pct = NA_character_,
       BrW_mg = NA_character_, CV_BrW_pct = NA_character_, n_BoW = NA_character_, n_BrW = NA_character_,
       Source = NA_character_)

parse_species_line <- function(line, page_num) {
  line <- clean_ocr(trimws(line))
  tokens <- strsplit(line, "\\s+")[[1]]
  i <- 1L; name_tokens <- character(0)
  while (i <= length(tokens) && !grepl(NUM_RE, tokens[i])) { name_tokens <- c(name_tokens, tokens[i]); i <- i + 1L }
  name <- trimws(paste(name_tokens, collapse = " "))
  if (name %in% names(NAME_FIXES)) name <- NAME_FIXES[[name]]
  data <- if (i <= length(tokens)) tokens[i:length(tokens)] else character(0)
  if (!length(data)) return(c(empty_row(name, page_num), list(no_data = TRUE)))
  pos <- 1L
  BoW <- data[pos]; pos <- pos + 1L
  CV_BoW <- NA_character_
  if (pos <= length(data) && grepl(DEC_RE, data[pos])) { CV_BoW <- data[pos]; pos <- pos + 1L }
  BrW <- NA_character_
  if (pos <= length(data) && grepl(NUM_RE, data[pos])) { BrW <- data[pos]; pos <- pos + 1L }
  CV_BrW <- NA_character_
  if (pos <= length(data) && grepl(DEC_RE, data[pos])) { CV_BrW <- data[pos]; pos <- pos + 1L }
  tail <- if (pos <= length(data)) data[pos:length(data)] else character(0)
  n_BoW <- n_BrW <- Source <- NA_character_
  if (length(tail) == 3L) { n_BoW <- tail[1]; n_BrW <- tail[2]; Source <- tail[3]
  } else if (length(tail) == 2L) { n_BoW <- n_BrW <- tail[1]; Source <- tail[2]
  } else if (length(tail) == 1L) { Source <- tail[1]
  } else if (length(tail) > 3L) {
    return(c(list(species_printed = name, source_pdf_page = page_num, BoW_g = BoW, CV_BoW_pct = CV_BoW, BrW_mg = BrW,
                  CV_BrW_pct = CV_BrW, n_BoW = NA_character_, n_BrW = NA_character_, Source = NA_character_),
             list(issue = paste("unexpected tail", paste(tail, collapse = " ")))))
  }
  Source <- fix_source_s_for_5(Source, page_num)
  list(species_printed = name, source_pdf_page = page_num, BoW_g = BoW, CV_BoW_pct = CV_BoW, BrW_mg = BrW,
       CV_BrW_pct = CV_BrW, n_BoW = n_BoW, n_BrW = n_BrW, Source = Source)
}

parse_page <- function(text, page_num) {
  rows <- list(); no_data <- character(0); issues <- character(0); in_key_section <- FALSE
  for (raw_line in strsplit(text, "\r\n|[\n\r\v\f\u0085\u2028\u2029]")[[1]]) {
    s <- trimws(raw_line)
    if (!nzchar(s)) next
    if (grepl("^Key to the source", s)) { in_key_section <- TRUE; next }
    if (in_key_section) next
    if (is_skip_line(s)) next
    s <- sub("\\s+['\"]+$", "", s)   # trailing stray punctuation-only tokens (OCR artefacts)
    if (s %in% names(HEADING_SPACING)) s <- HEADING_SPACING[[s]]
    # family/subfamily headings (e.g. "PTEROPODIDAE (cont.)") become their own header rows, indented as in print
    stripped_of_cont <- sub("\\s*\\((cont|cant)\\.\\)\\s*$", "", s)
    if (is_all_caps_header(stripped_of_cont)) {
      clean_heading <- trimws(gsub("\\s+", " ", s))
      indent <- if (endsWith(trimws(stripped_of_cont, "right"), "INAE")) "  " else ""
      rows[[length(rows) + 1L]] <- c(empty_row(paste0(indent, clean_heading), page_num), list(is_header = TRUE))
      next
    }
    first_word <- tolower(strsplit(s, "\\s+")[[1]][1])
    if (first_word %in% CONTINUATION_STARTS) next
    if (grepl("^-?[0-9]", s)) next                        # bare-numeric continuation lines
    if (!grepl("^[A-Z\u00a7]", s)) next                  # a species line starts with an uppercase letter
    row <- parse_species_line(s, page_num)
    if (isTRUE(row$no_data)) { no_data <- c(no_data, row$species_printed); next }
    if (!is.null(row$issue)) { issues <- c(issues, paste(row$species_printed, row$issue, page_num)); next }
    row$is_header <- FALSE
    row$species_printed <- paste0("    ", row$species_printed)
    rows[[length(rows) + 1L]] <- row
  }
  list(rows = rows, no_data = no_data, issues = issues)
}

pdftotext <- Sys.which("pdftotext")
if (!nzchar(pdftotext)) stop("pdftotext (poppler-utils) is needed: the text layer is read in content-stream order (-raw)", call. = FALSE)
page_raw_text <- function(p) paste(system2(pdftotext, c("-raw", "-f", p, "-l", p, shQuote(PDF), "-"), stdout = TRUE), collapse = "\n")

all_rows <- list()
for (pidx in 21:31) {
  r <- parse_page(page_raw_text(pidx + 1L), pidx + 1L)
  if (length(r$issues)) stop("Unresolved issues on page ", pidx + 1L, ": ", paste(r$issues, collapse = "; "), call. = FALSE)
  all_rows <- c(all_rows, r$rows)
  for (nm in r$no_data)   # species printed with a footnote marker but no weight data: kept as a blank row
    all_rows[[length(all_rows) + 1L]] <- c(empty_row(paste0("    ", nm), pidx + 1L), list(is_header = FALSE))
}
is_hd <- vapply(all_rows, function(r) isTRUE(r$is_header), TRUE)
species_rows <- all_rows[!is_hd]
if (length(species_rows) != 342L) stop("Expected 342 species rows, got ", length(species_rows), call. = FALSE)
if (trimws(species_rows[[1]]$species_printed) != "Eidolon helvum") stop("Unexpected first species", call. = FALSE)
if (trimws(species_rows[[342]]$species_printed) != "Cheiromeles torquatus") stop("Unexpected final species", call. = FALSE)

# species_printed (with its printed-hierarchy indentation) leads the file; species_row is kept for reference
fieldnames <- c("species_printed", "is_header", "source_pdf_page", "BoW_g", "CV_BoW_pct", "BrW_mg", "CV_BrW_pct",
                "n_BoW", "n_BrW", "Source", "species_row")
df <- do.call(rbind, lapply(seq_along(all_rows), function(i) {
  r <- all_rows[[i]]
  vapply(fieldnames, function(f) {
    if (f == "species_row") return(as.character(i))
    if (f == "is_header") return(if (isTRUE(r$is_header)) "TRUE" else "")
    v <- r[[f]]; if (is.null(v) || is.na(v)) "" else as.character(v)
  }, "")
}))
colnames(df) <- fieldnames

# csv.DictWriter(QUOTE_ALL) style: BOM, every field quoted, CRLF line ends
q <- function(x) paste0("\"", gsub("\"", "\"\"", as.character(x)), "\"")
out <- paste0("\ufeff", paste(c(paste(q(fieldnames), collapse = ","),
                                 apply(df, 1, function(rw) paste(q(rw), collapse = ","))), collapse = "\r\n"), "\r\n")
path <- file.path(HERE, paste0(item_name, "_snapshot.csv"))
message("TOTAL ROWS: ", nrow(df), " (", length(species_rows), " species + ", sum(is_hd), " section headers)")
if (file.exists(path)) {
  old <- readChar(path, file.info(path)$size, useBytes = TRUE); Encoding(old) <- "UTF-8"
  if (!identical(old, out)) stop("REFUSING to overwrite differing frozen snapshot ", path, call. = FALSE)
  message("  unchanged ", basename(path), " (byte-identical)")
} else {
  con <- file(path, "wb"); writeBin(charToRaw(enc2utf8(out)), con); close(con)
  message("  wrote ", basename(path))
}
