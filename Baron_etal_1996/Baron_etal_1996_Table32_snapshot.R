# Baron_etal_1996_Table32_snapshot.R -- writes ONLY Baron_etal_1996_Table32_snapshot.csv
#
# Baron, Stephan & Frahm (1996), Comparative Neurobiology in Chiroptera. Table 32 (printed telencephalic-part volumes, mm3: MOB, PAL, STR, SEP, AMY, HIP, SCH, NEO; PDF pp. 138-145).
# One script per output: this copy writes only its own snapshot (item taken from its own file name);
# the shared extractor code is repeated in each Baron_etal_1996_<TableN>_snapshot.R.
#
# The book's PDF text layer has a scrambled reading order and a per-page "staircase" typesetting in which a
# row's values sit one half-line above its species name, so line-based parsing is unreliable. This script
# works from word COORDINATES (pdftools::pdf_data): species names are the non-numeric tokens, data columns
# are recovered by clustering the right edges of the numeric tokens, and each value is attached to a species
# by a per-page vertical offset chosen to make the assignment injective. The book's family / subfamily
# headings (...IDAE / ...INAE) are kept as their own rows (is_header = "TRUE", indented as in print: family
# flush left, subfamily two spaces, species four spaces), so the snapshot reads like the printed page.
#
# R port (2026-11-12) of Baron_etal_1996_Table32_snapshot.py, which is retired as Baron_etal_1996_Table32_snapshot.py.retired. The Python
# script wrote the older header-less layout (species rows only) that no longer matches the frozen
# snapshot; THIS script reproduces the frozen layout (BOM, all fields quoted, CRLF line ends, headings
# interleaved). Verified in a temp dir (never in place); see the README. An existing frozen snapshot that
# differs is never overwritten. Numeric OCR repairs are restricted to the literal TOKEN_REPAIRS below and
# the species-name repairs to NAME_REPAIRS; no biological value is inferred or recomputed.
# Run it with Rscript, or open in RStudio and Source.

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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # Baron_etal_1996_<TableN>
PDF <- file.path(HERE, "baron_etal_1996 book Comparative Neurobiology.pdf")

# ---------------------------------------------------------------- OCR repairs
# Literal token repairs, each checked against the rendered page.  No biological
# value is inferred or recomputed; these restore what is visibly printed.
TOKEN_REPAIRS <- c("~1.4" = "21.4", "/\",2.6" = "72.6", "1O.7" = "10.7",
                   "I" = "1", "l" = "1", "O" = "0")
# Letterform confusions inside otherwise numeric tokens (l/I/i -> 1, O/o/Q/D -> 0,
# J -> 1).  Applied only to tokens that already contain a digit.
NUMLIKE <- "^[0-9lOIiQDoJ][0-9lOIiQDoJ.,]*$"

# Species-name letterform repairs.  The abbreviated taxon wording the book
# prints is deliberately kept; only OCR damage is corrected.
NAME_REPAIRS <- c(
  "Laviafrons" = "Lavia frons", "Nycteris macro tis" = "Nycteris macrotis",
  "CaroWa perspicillata" = "Carollia perspicillata",
  "Sturn ira lilium" = "Sturnira lilium", "Sturn ira ludovici" = "Sturnira ludovici",
  "Sturn ira tUdae" = "Sturnira tildae", "Uroderma bUobatum" = "Uroderma bilobatum",
  "Lionycteris spurreUi" = "Lionycteris spurrelli",
  "Tadarida pUcata pUcata" = "Tadarida plicata plicata",
  "Cyttarops alec to" = "Cyttarops alecto", "Pteropus alec to" = "Pteropus alecto",
  "EctophyUa macconnelli" = "Ectophylla macconnelli",
  "Artibeus cine reus" = "Artibeus cinereus",
  "Artibeus jamaicen;is" = "Artibeus jamaicensis",
  "Miniopterus in flatus" = "Miniopterus inflatus", "fa io" = "Ia io",
  "Tonatia schuld" = "Tonatia schulzi",
  "Cynopterus braehyotis" = "Cynopterus brachyotis",
  "Eonyeteris spelaea" = "Eonycteris spelaea",
  "Hipposideros bieolor" = "Hipposideros bicolor",
  "Noetilio leporinus" = "Noctilio leporinus",
  "Molossus trinitatis (" = "Molossus trinitatis",
  "Penthetor /ucasi (PTN)" = "Penthetor lucasi (PTN)",
  "Penthetor /ucasi" = "Penthetor lucasi",
  "Ametrida centuria" = "Ametrida centurio",
  "Tadarida leu eo stigma" = "Tadarida leucostigma")

HEAD_RE  <- "^(Table|For|Brains|Size|Average|A verage|>|<)"
FAMILY_RE <- "^([A-Z]+ )*[A-Z]+(IDAE|INAE| AE)( \\((cont|cant)\\.\\))?$"
BAD_NAME <- "\\((cont|cant)\\.?\\)|^n$|^[A-Z]{2,4}$|\\bmm\\b|%"

fix_tok <- function(x) {
  x <- ifelse(x %in% names(TOKEN_REPAIRS), TOKEN_REPAIRS[x], x)
  i <- grepl(NUMLIKE, x) & grepl("[lOIiQDoJ]", x) & grepl("[0-9]", x)
  x[i] <- chartr("lOIiQDoJ", "10110001", x[i])
  x
}
is_heading <- function(s) {
  L <- gsub("[^A-Za-z]", "", s)
  nchar(L) < 3 || identical(L, toupper(L)) || grepl(BAD_NAME, s) || grepl(HEAD_RE, s)
}
# A value printed as "71. 4" reaches the text layer as two adjacent tokens.
merge_split_numbers <- function(pg) {
  pg <- pg[order(pg$y, pg$x), ]
  isn <- grepl("^[0-9][0-9.,]*$", pg$text); drop <- rep(FALSE, nrow(pg)); i <- 1L
  while (i < nrow(pg)) {
    if (isn[i] && isn[i + 1L] && abs(pg$y[i + 1L] - pg$y[i]) <= 2 &&
        (pg$x[i + 1L] - (pg$x[i] + pg$width[i])) < 3 &&
        (grepl("\\.$", pg$text[i]) || grepl("^[.,]", pg$text[i + 1L]))) {
      pg$text[i] <- paste0(pg$text[i], pg$text[i + 1L])
      pg$width[i] <- pg$x[i + 1L] + pg$width[i + 1L] - pg$x[i]
      drop[i + 1L] <- TRUE; isn[i + 1L] <- FALSE; i <- i + 2L
    } else i <- i + 1L
  }
  pg[!drop, ]
}
# Single-linkage clustering of numeric right edges into `ncol` data columns.
# Small clusters (marginal notes outside the table block) are discarded.
split_cols <- function(v, ncol) {
  cl <- function(thr) { o <- order(v); s <- v[o]; lab <- integer(length(v))
                        lab[o] <- cumsum(c(TRUE, diff(s) > thr)); lab }
  for (thr in c(8, 6, 10, 5, 12, 4, 14, 16, 3, 18, 20, 24)) {
    lab <- cl(thr); tb <- table(lab)
    keep <- as.integer(names(tb)[tb >= max(3, 0.25 * median(tb))])
    if (length(keep) == ncol) {
      out <- rep(NA_integer_, length(v))
      for (j in seq_along(keep)) out[lab == keep[j]] <- j
      return(out)
    }
  }
  o <- order(v); s <- v[o]; g <- diff(s)
  cut <- sort(order(g, decreasing = TRUE)[seq_len(ncol - 1L)])
  lab <- integer(length(v)); lab[o] <- rep(seq_len(ncol), times = diff(c(0, cut, length(s)))); lab
}

extract_page <- function(pg, ncol, y_min, y_max = Inf) {
  Encoding(pg$text) <- "UTF-8"
  a <- pg$y[grepl("^Abbreviations", pg$text)]
  ymax <- min(c(if (length(a)) min(a) - 2 else Inf, y_max))
  pg <- pg[pg$y >= y_min & pg$y <= ymax, ]
  pg <- pg[order(pg$y, pg$x), ]
  pg$text <- fix_tok(pg$text); pg <- pg[nzchar(pg$text), ]
  pg <- merge_split_numbers(pg)
  # The column header "n  mm3  %  mm3  %  mm3  %" is repeated at the top of every
  # page of Table 8, and the superscript 3 of each "mm3" reaches the text layer as
  # its own numeric token "3". Left in, those three tokens are clustered into the
  # mm3 columns and attached to the first species row of the page (2026-10-31:
  # seven species carried NET = VENT = REST = 3 mm3 -- Baron_etal_1996-E001..E007).
  # A numeral is a header token when a "mm" token sits on the same line.
  mm_y <- pg$y[pg$text == "mm"]
  if (length(mm_y)) {
    hdr_num <- grepl("^[0-9]$", pg$text) &
      vapply(pg$y, function(y) any(abs(y - mm_y) <= 6), logical(1))
    pg <- pg[!hdr_num, ]
  }
  isnum <- grepl("^[0-9][0-9.,]*$", pg$text)
  nm <- pg[!isnum, ]; recs <- character(0); recy <- numeric(0); heads <- character(0); heady <- numeric(0)
  if (nrow(nm)) {
    g <- cumsum(c(TRUE, diff(nm$y) > 3))
    for (k in unique(g)) {
      L <- nm[g == k, ]; L <- L[order(L$x), ]
      s <- gsub("\\s+", " ", trimws(paste(L$text, collapse = " ")))
      if (is_heading(s)) {
        # the book's family / subfamily headings (...IDAE / ...INAE, optionally "(cont.)") are kept as rows
        # (stray punctuation-only OCR tokens on the heading line are ignored)
        hs <- gsub("\\s+", " ", trimws(paste(L$text[grepl("[A-Za-z0-9]", L$text)], collapse = " ")))
        if (grepl(FAMILY_RE, hs)) { heads <- c(heads, hs); heady <- c(heady, max(L$y)) }
        next
      }
      recs <- c(recs, s); recy <- c(recy, max(L$y))
    }
  }
  num <- pg[isnum, ]
  if (!length(recs) || !nrow(num)) return(NULL)
  lab <- split_cols(num$x + num$width, ncol)
  num <- num[!is.na(lab), ]; lab <- lab[!is.na(lab)]
  list(names = recs, y = recy, heads = heads, heady = heady,
       cols = lapply(seq_len(ncol), function(j) { t <- num[lab == j, ]; t[order(t$y, t$x), ] }))
}

assemble <- function(dat, pages, ncol, colnames_, y_min_first, y_max = Inf) {
  out <- NULL; hd <- NULL
  for (i in seq_along(pages)) {
    r <- extract_page(dat[[pages[i]]], ncol, if (i == 1L) y_min_first else 80, y_max)
    if (is.null(r)) next
    ns <- length(r$names); ny <- r$y
    score <- vapply(0:14, function(dl) sum(vapply(r$cols, function(t) {
      if (!nrow(t)) return(0L)
      idx <- vapply(t$y + dl, function(yy) which.min(abs(ny - yy)), 1L)
      length(unique(idx)) - 2L * sum(duplicated(idx))
    }, 1L)), 1L)
    dl <- (0:14)[which.max(score)]
    m <- as.data.frame(matrix(NA_character_, ns, ncol), stringsAsFactors = FALSE)
    names(m) <- colnames_
    for (j in seq_len(ncol)) {
      t <- r$cols[[j]]; if (!nrow(t)) next
      idx <- vapply(t$y + dl, function(yy) which.min(abs(ny - yy)), 1L)
      keep <- !duplicated(idx); m[idx[keep], j] <- t$text[keep]
    }
    nmv <- r$names
    nmv <- ifelse(nmv %in% names(NAME_REPAIRS), NAME_REPAIRS[nmv], nmv)
    out <- rbind(out, cbind(source_pdf_page = pages[i], species_printed = nmv, m, ypos = ny,
                            stringsAsFactors = FALSE))
    if (length(r$heads))
      hd <- rbind(hd, data.frame(source_pdf_page = pages[i], species_printed = r$heads, ypos = r$heady,
                                 stringsAsFactors = FALSE))
  }
  out <- out[rowSums(!is.na(out[, colnames_, drop = FALSE])) > 0, ]
  list(species = out, heads = hd)
}

# ------------------------------------------------------- table specification
cols  <- c("MOB","PAL","STR","SEP","AMY","HIP","SCH","NEO")
pages <- 138:145
y1    <- 125
N     <- 272L   # species rows (the book's Table 1 key)

message("Reading word coordinates from the PDF ...")
dat <- pdf_data(PDF, font_info = FALSE)
stopifnot(length(dat) == 170L)

r <- assemble(dat, pages, length(cols), cols, y1)
sp <- r$species; hd <- r$heads
if (nrow(sp) != N) stop(item_name, ": ", nrow(sp), " species rows extracted, expected ", N, call. = FALSE)
sp$is_header <- ""; sp$species_printed <- paste0("    ", sp$species_printed)
hd$is_header <- "TRUE"
hd$species_printed <- paste0(ifelse(grepl("INAE( \\((cont|cant)\\.\\))?$", hd$species_printed), "  ", ""), hd$species_printed)
for (v in cols) hd[[v]] <- ""
sp[is.na(sp)] <- ""
all <- rbind(sp[, c("species_printed", "is_header", "source_pdf_page", cols, "ypos")],
             hd[, c("species_printed", "is_header", "source_pdf_page", cols, "ypos")])
all <- all[order(all$source_pdf_page, all$ypos), ]
all$ypos <- NULL
all$species_row <- as.character(seq_len(nrow(all)))
all[] <- lapply(all, as.character)

# Frozen layout: BOM, every field quoted, CRLF line ends.
q <- function(x) paste0("\"", gsub("\"", "\"\"", as.character(x)), "\"")
lines <- c(paste(q(names(all)), collapse = ","),
           apply(as.matrix(all), 1, function(rw) paste(q(rw), collapse = ",")))
out <- paste0("\ufeff", paste(lines, collapse = "\r\n"), "\r\n")

path <- file.path(HERE, paste0(item_name, "_snapshot.csv"))
if (file.exists(path)) {
  old <- readChar(path, file.info(path)$size, useBytes = TRUE); Encoding(old) <- "UTF-8"
  if (!identical(old, out)) stop("REFUSING to overwrite differing frozen snapshot ", path, call. = FALSE)
  message("  unchanged ", basename(path), ": ", nrow(sp), " species rows + ", nrow(hd), " heading rows (byte-identical)")
} else {
  con <- file(path, "wb"); writeBin(charToRaw(enc2utf8(out)), con); close(con)
  message("  wrote ", basename(path), ": ", nrow(sp), " species rows + ", nrow(hd), " heading rows")
}
