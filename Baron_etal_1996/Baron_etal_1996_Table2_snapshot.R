# Baron_etal_1996_Table2_snapshot.R -- writes ONLY Baron_etal_1996_Table2_snapshot.csv
#
# Baron, Stephan & Frahm (1996), Comparative Neurobiology in Chiroptera. Table 2 ("Linear measures of
# brains in mm", PDF pp. 4-11, printed pp. 266-273), parsed from the PDF text layer. One script per output
# (item taken from its own file name).
#
# Table 2 needed a more general parser than Tables 10/32 because rows are not one-per-line in the text
# layer (many species are crammed onto a single extracted "line"), and because the printed table has TWO
# independent optional fields (BL/HL/HW/HH's leading n, and CCL's own n), either of which can be dashed
# out ("-", "-.--") for a given species.
#
# Pipeline
# 1. Per-page text layer (pdftools::pdf_text, PDF pages 4-6 and 8-11) is cleaned of common OCR digit/letter
#    confusions (l/I -> 1, o/O -> 0 in numeric-only tokens; three specific letters-plus-digits artefacts
#    where an italic "m" was OCR'd as "l11" mid-word).
# 2. Family/subfamily all-caps heading lines and page furniture (page-number headers, "Table 2 <" running
#    heads, the Table 3/4 cross-reference lines, the addendum footnote) are stripped before parsing.
# 3. A single global regex walks the cleaned text as alternating (species name)(numeric run) pairs. Each
#    numeric run is tokenised and typed as INT or FLOAT (FLOAT tokens contain a decimal point; n-columns
#    never do), then assigned by a small state machine in strict column order n1, BL, HL, HW, HH, n2, CCL --
#    each of these 7 slots is independently optional.
# 4. One page in this range (PDF page 7, printed p. 269) has NO extractable text layer at all (a pure
#    scanned image in this otherwise well-OCR'd book): all 39 rows on that page were hand-transcribed
#    directly from the rendered page image and are typed in PAGE269_ROWS below.
# 5. Eight rows (all single-specimen entries, n = 1) had their n1 and/or n2 integer silently dropped by the
#    text extraction (a true invisible extraction failure), caught because a row with a CCL value but no n2
#    is structurally inconsistent with the print convention; each was confirmed against the rendered page
#    images. See CELL_FIXES.
#
# Output: Baron_etal_1996_Table2_snapshot.csv, 303 rows, sharing its first (Eidolon helvum) and last
# (Cheiromeles torquatus) species with Tables 10/32.
#
# R port (2026-11-12) of Baron_etal_1996_Table2_snapshot.py, retired as Baron_etal_1996_Table2_snapshot.py.retired.
# The Python original read per-page text files (page<N>.txt, written by a step that is not in the repo)
# that reproduce the pypdf text layer; poppler's layout text (pdftools) reads the same OCR layer. Verified in
# a temp dir (never in place): the regenerated CSV is byte-identical to the frozen one. One row differs in
# the raw poppler text only by the word gap the frozen copy keeps from the earlier extraction
# ("Miniopterus in flatus", PDF p. 11): NAME_SPACING below restores that printed-text-layer gap so the
# frozen file is reproduced; no value changes. An existing frozen snapshot that differs is never overwritten.

suppressPackageStartupMessages(library(pdftools))

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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # Baron_etal_1996_Table2
PDF <- file.path(HERE, "baron_etal_1996 book Comparative Neurobiology.pdf")
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

LETTER_REPAIRS <- c("bilobatul11" = "bilobatum", "trinitatul11" = "trinitatum", "l11orio" = "morio")

SKIP_NAME_EXACT_PREFIXES <- c("Table", "For proportion", "For average", "Abbreviations", "BL brain", "CCL corpus",
                              "HH hemisphere", "n= number", "See addendum", "see addendum", "pp.")

# Hand-transcribed from the rendered page image (PDF page 7, printed p. 269): the one page in range with no
# extractable text layer at all. Columns: name, n1, BL, HL, HW, HH, n2, CCL (NA = dashed out).
PAGE269_ROWS <- list(
  c("Hipposideros bicolor gentilis", "6", "11.3", "6.4", "7.4", "5.5", NA_character_, NA_character_),
  c("Hipposideros bicolor atrox", "3", "11.5", "6.6", "7.6", "5.7", NA_character_, NA_character_),
  c("Hipposideros caffer", "14", "11.0", "6.8", "8.0", "5.9", "3", "1.52"),
  c("Hipposideros caffer ssp.", "5", "12.3", "7.0", "8.4", "5.9", NA_character_, NA_character_),
  c("Hipposideros c. calcaratus \u00a7)", "7", "14.2", "7.7", "8.6", "6.5", "3", "2.49"),
  c("Hipposideros c. cupidus \u00a7)", "6", "12.8", "7.3", "8.0", "6.2", "3", "2.28"),
  c("Hipposideros cervinus", "17", "11.1", "6.2", "7.1", "5.3", "3", "1.76"),
  c("Hipposideros commersoni", "10", "15.4", "9.9", "11.1", "7.9", "3", "2.17"),
  c("Hipposideros diadema", "21", "17.7", "9.5", "10.9", "7.6", "4", "1.96"),
  c("Hipposideros fulvus", "6", "11.3", "6.5", "7.5", "5.5", "2", "1.50"),
  c("Hipposideros galeritus", "3", "11.9", "6.8", "7.9", "5.8", NA_character_, NA_character_),
  c("Hipposideros halophyllus", "2", "9.8", "5.6", "6.1", "4.5", "2", "1.46"),
  c("Hipposideros lankadiva", "9", "18.2", "9.8", "11.0", "7.5", "3", "2.37"),
  c("Hipposideros larvatus", "20", "14.3", "7.9", "9.0", "6.5", "3", "1.72"),
  c("Hipposideros lekaguli", "10", "16.1", "8.6", "10.1", "7.5", "2", "1.85"),
  c("Hipp. m. maggietaylorae \u00a7)", "1", "16.5", "9.3", "10.0", "7.6", "1", "2.92"),
  c("Hipp. m. erroris \u00a7)", "4", "14.4", "7.8", "8.7", "7.1", "3", "2.48"),
  c("Hipposideros ridleyi", "10", "11.6", "5.9", "7.8", "5.8", "3", "1.33"),
  c("Hipposideros ruber", "1", "10.0", "6.9", "7.9", "5.6", NA_character_, NA_character_),
  c("Hipposideros speoris", "6", "12.5", "7.1", "8.1", "5.8", "2", "1.57"),
  c("Hipposideros turpis", "4", "16.3", "9.0", "9.9", "7.6", "3", "1.93"),
  c("Aselliscus stoliczkanus", "3", "9.1", "5.2", "5.9", "4.7", "3", "1.11"),
  c("Aselliscus tricuspidatus", "10", "9.5", "5.5", "5.9", "4.7", "3", "1.38"),
  c("Triaenops persicus", "10", "10.9", "6.2", "7.0", "5.9", "3", "1.89"),
  c("Noctilio albiventris", "10", "12.7", "8.6", "11.1", "8.4", "3", "2.67"),
  c("Noctilio leporinus", "9", "15.9", "10.8", "13.6", "9.9", "3", "4.28"),
  c("Pteronotus gymnonotus", "6", "11.2", "6.1", "8.4", "7.1", "3", "2.03"),
  c("Pteronotus personatus", "17", "9.6", "5.5", "7.3", "6.2", "3", "1.79"),
  c("Pteronotus parnelli", "15", "13.3", "7.6", "10.4", "8.0", "3", "2.11"),
  c("Mormoops megalophylla", "9", "9.8", "5.2", "8.6", "7.7", "3", "1.34"),
  c("Micronycteris megalotis", "9", "11.1", "6.8", "7.2", "6.7", "3", "2.03"),
  c("Micronycteris minuta", "1", "11.3", "6.7", "7.2", "6.5", "1", "2.00"),
  c("Micronycteris schmidtorum", "10", "11.5", "6.9", "7.6", "7.0", "3", "2.34"),
  c("Micronycteris brachyotis", "1", "12.9", "7.2", "8.3", "7.2", "1", "2.68"),
  c("Macrophyllum macrophyllum", "10", "11.2", "7.1", "7.8", "6.7", "3", "2.54"),
  c("Tonatia bidens", "10", "16.6", "10.1", "10.2", "9.4", "3", "3.70"),
  c("Tonatia schulzi", "1", "13.6", "8.2", "9.2", "8.3", "1", "3.27"),
  c("Tonatia sylvicola", "1", "15.0", "10.2", "10.4", "9.4", "1", "3.52"),
  c("Mimon crenulatum", "2", "12.5", "7.4", "8.1", "6.7", "2", "2.23")
)

# (species_row, field) -> corrected value. All eight are single-specimen (n = 1) rows where the text layer
# silently dropped an n1 and/or n2 token (no garbled remnant to repair programmatically). Each was
# individually confirmed against the rendered page image before being applied here.
CELL_FIXES <- list(
  list(row = 9L, field = "n2", value = "1"),
  list(row = 74L, field = "n", value = "1"),
  list(row = 74L, field = "n2", value = "1"),
  list(row = 171L, field = "n", value = "1"),
  list(row = 171L, field = "n2", value = "1"),
  list(row = 201L, field = "n", value = "1"),
  list(row = 201L, field = "n2", value = "1"),
  list(row = 280L, field = "n", value = "1"),
  list(row = 280L, field = "n2", value = "1"),
  list(row = 281L, field = "n", value = "1"),
  list(row = 281L, field = "n2", value = "1"),
  list(row = 282L, field = "n", value = "1"),
  list(row = 282L, field = "n2", value = "1"),
  list(row = 283L, field = "n", value = "1"),
  list(row = 283L, field = "n2", value = "1")
)
NAME_FIXES <- list(   # name itself was truncated to "a" by the same digit-adjacent parsing issue
  list(row = 282L, value = "Kerivoula phalaena")
)
# text-layer word gap kept in the frozen snapshot (see header)
NAME_SPACING <- c("Miniopterus inflatus" = "Miniopterus in flatus")

clean_ocr_numbers <- function(text) {
  for (bad in names(LETTER_REPAIRS)) text <- gsub(bad, LETTER_REPAIRS[[bad]], text, fixed = TRUE)
  m <- gregexpr("\\S+", text)
  toks <- regmatches(text, m)[[1]]
  fix <- function(tok) {
    if (tok %in% c("I", "l")) return("1")
    if (nchar(tok) < 2) return(tok)
    if (grepl("^[0-9lIoO]*\\.?[0-9lIoO]*$", tok) && !(tok %in% c("", "."))) {
      cand <- chartr("lIoO", "1100", tok)
      if (grepl("^([0-9]+(\\.[0-9]+)?|\\.[0-9]+)$", cand)) return(cand)
    }
    tok
  }
  regmatches(text, m) <- list(vapply(toks, fix, "", USE.NAMES = FALSE))
  text
}
is_all_caps_header <- function(line) {
  letters_only <- gsub("[^A-Za-z]", "", trimws(line))
  nchar(letters_only) >= 3 && letters_only == toupper(letters_only)
}
is_skip_name <- function(name) {
  n <- trimws(name)
  if (!nzchar(n)) return(TRUE)
  if (any(startsWith(n, SKIP_NAME_EXACT_PREFIXES))) return(TRUE)
  grepl("[[:alpha:]]", n) && n == toupper(n)
}

WORD <- "[A-Za-z\\x{00a7}+][A-Za-z.+\\x{00a7}/'%()?-]*"
NAME_RE <- paste0(WORD, "(?:\\s+", WORD, ")*")
BLOCK_RE <- paste0("(*UCP)(", NAME_RE, ")\\s+((?:\\d+\\.\\d+|\\d+)(?:\\s+(?:\\d+\\.\\d+|\\d+))*)")

parse_page <- function(text, page_num) {
  text <- clean_ocr_numbers(text)
  keep <- character(0)
  for (ln in strsplit(text, "\n", fixed = TRUE)[[1]]) {
    s <- trimws(ln)
    if (!nzchar(s)) next
    if (grepl("^\\d+\\s+Brains of Chiroptera", s)) next
    if (grepl("^>\\s*Table", s)) next
    if (startsWith(s, "Table 2.")) next
    if (startsWith(s, "For proportion") || startsWith(s, "For average")) next
    if (grepl("^n\\s+BL\\s+HL", s)) next
    if (grepl("addendum", tolower(s), fixed = TRUE) || grepl("Voume", s, fixed = TRUE)) next
    if (is_all_caps_header(s)) next
    keep <- c(keep, ln)
  }
  text2 <- paste(keep, collapse = "\n")
  m <- gregexpr(BLOCK_RE, text2, perl = TRUE)[[1]]
  rows <- list()
  if (m[1] == -1L) return(rows)
  st <- attr(m, "capture.start"); ln <- attr(m, "capture.length")
  for (k in seq_along(m)) {
    name_raw <- substr(text2, st[k, 1], st[k, 1] + ln[k, 1] - 1L)
    nums_raw <- substr(text2, st[k, 2], st[k, 2] + ln[k, 2] - 1L)
    if (is_skip_name(name_raw)) next
    name <- trimws(gsub("\\s+", " ", name_raw))
    for (junk in c("cont.) ", "cant.) ")) if (startsWith(name, junk)) name <- substring(name, nchar(junk) + 1L)
    toks <- strsplit(nums_raw, "\\s+")[[1]]
    isf <- grepl(".", toks, fixed = TRUE)
    i <- 1L; n1 <- NA_character_
    if (i <= length(toks) && !isf[i]) { n1 <- toks[i]; i <- i + 1L }
    measures <- rep(NA_character_, 4); mi <- 1L
    while (i <= length(toks) && isf[i] && mi <= 4L) { measures[mi] <- toks[i]; mi <- mi + 1L; i <- i + 1L }
    n2 <- NA_character_
    if (i <= length(toks) && !isf[i]) { n2 <- toks[i]; i <- i + 1L }
    ccl <- NA_character_
    if (i <= length(toks) && isf[i]) { ccl <- toks[i]; i <- i + 1L }
    if (i <= length(toks) || is.na(measures[1]))
      stop("Unresolved parse issue on page ", page_num, ": ", name, " | ", nums_raw, call. = FALSE)
    rows[[length(rows) + 1L]] <- list(source_pdf_page = page_num, species_printed = name, n = n1,
      BL = measures[1], HL = measures[2], HW = measures[3], HH = measures[4], n2 = n2, CCL = ccl)
  }
  rows
}

txt <- pdf_text(PDF)
all_rows <- list()
for (pg in 4:6) all_rows <- c(all_rows, parse_page(txt[pg], pg))
for (r in PAGE269_ROWS)
  all_rows[[length(all_rows) + 1L]] <- list(source_pdf_page = 7, species_printed = r[1], n = r[2],
    BL = r[3], HL = r[4], HW = r[5], HH = r[6], n2 = r[7], CCL = r[8])
for (pg in 8:11) all_rows <- c(all_rows, parse_page(txt[pg], pg))
if (length(all_rows) != 303L) stop("Expected 303 rows, got ", length(all_rows), call. = FALSE)

for (idx in seq_along(all_rows)) {
  for (cf in CELL_FIXES) if (cf$row == idx) all_rows[[idx]][[cf$field]] <- cf$value
  for (nf in NAME_FIXES) if (nf$row == idx) all_rows[[idx]]$species_printed <- nf$value
  sp <- all_rows[[idx]]$species_printed
  if (sp %in% names(NAME_SPACING)) all_rows[[idx]]$species_printed <- NAME_SPACING[[sp]]
}
if (all_rows[[1]]$species_printed != "Eidolon helvum") stop("Unexpected first species", call. = FALSE)
if (all_rows[[303]]$species_printed != "Cheiromeles torquatus") stop("Unexpected final species", call. = FALSE)

fieldnames <- c("species_row", "source_pdf_page", "species_printed", "n", "BL", "HL", "HW", "HH", "n2", "CCL")
df <- do.call(rbind, lapply(seq_along(all_rows), function(i)
  vapply(fieldnames, function(f) if (f == "species_row") as.character(i) else {
    v <- all_rows[[i]][[f]]; if (is.null(v) || is.na(v)) "" else as.character(v) }, "")))
colnames(df) <- fieldnames

# csv.DictWriter style: minimal quoting, CRLF line ends, UTF-8 without BOM
csv_cell <- function(x) ifelse(grepl("[\",\r\n]", x), paste0("\"", gsub("\"", "\"\"", x), "\""), x)
out <- paste0(paste(c(paste(csv_cell(fieldnames), collapse = ","),
                      apply(df, 1, function(r) paste(csv_cell(r), collapse = ","))), collapse = "\r\n"), "\r\n")
path <- file.path(HERE, paste0(item_name, "_snapshot.csv"))
if (file.exists(path)) {
  old <- readChar(path, file.info(path)$size, useBytes = TRUE); Encoding(old) <- "UTF-8"
  if (!identical(old, out)) stop("REFUSING to overwrite differing frozen snapshot ", path, call. = FALSE)
  message("  unchanged ", basename(path), ": ", nrow(df), " rows (byte-identical)")
} else {
  con <- file(path, "wb"); writeBin(charToRaw(enc2utf8(out)), con); close(con)
  message("  wrote ", basename(path), ": ", nrow(df), " rows")
}
