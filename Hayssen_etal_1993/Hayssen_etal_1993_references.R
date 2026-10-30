## =============================================================================
## Hayssen et al. (1993), Asdell's Patterns of Mammalian Reproduction
## -- Literature Cited as a one-row-per-reference-number table, parsed from the
## OCR text layer of the Literature Cited PDF slice with pdftools.
## =============================================================================
##
## Inputs (all in this folder; frozen, never modified)
##   Hayssen_etal_1993_pdf_slices.csv      slice map with SHA-256 per slice
##   pdf_by_order/..._21_LiteratureCited.pdf        286 pages = whole-book PDF 716-1001,
##                                                  printed 705-990; two columns; running
##                                                  header "<printed page>  <first>.-<last>."
##   pdf_by_order/..._22_Appendices_Indexes.pdf     Appendix 1 (Mammalian Species accounts,
##                                                  Literature Cited numbers in parentheses)
##                                                  and Appendix 2 (Core Journals + the
##                                                  abbreviations used in the bibliography)
##   pdf_by_order/..._01 .. _20_<Order>.pdf         species accounts (coverage check only)
##
## Outputs (reference_tables/)
##   Hayssen_etal_1993_references.csv              one row per reference number
##                                                         (letter- and subscript-suffixed
##                                                         inserts are separate rows)
##   Hayssen_etal_1993_references_page_check.csv   one row per Literature Cited page
##   Hayssen_etal_1993_references_unparsed.csv     lines not attributed to an entry,
##                                                         and numeric-start author-like lines
##                                                         folded into the preceding entry
##   Hayssen_etal_1993_references_definitions.csv  house definitions format
##   Hayssen_etal_1993_core_journals.csv           Appendix 2 transcription
##   Hayssen_etal_1993_cited_numbers_not_in_bibliography.csv
##                                                         coverage check: numbers cited in the
##                                                         species accounts / Appendix 1 with no
##                                                         row in the references table
##
## Conventions (evom1-refs-conventions C2, C5): one row per individual reference
## number; every input problem is a stop(), never a message(); parsed fields
## (first_author, year, title, ...) are heuristic splits of the verbatim
## `citation`, which is the authoritative column. Nothing is dropped: an entry
## the grammar cannot split is kept as parse_status = verbatim_only.
##
## Entry grammar (as printed; see README "Reference table" for OCR failure modes)
##   <number><suffix>. <Authors>. <Year>. <Title>. <Journal>. <Volume>:<Pages>.
##   <number><suffix>. <Authors>. <Year>. <Title>. <Book/Publisher ...>.
##   <number>. not used
##   suffix = a-z letter (inserted entries, e.g. 3625a; may be printed BEFORE its
##   base number when alphabetical order requires, e.g. 781a before 781) or a
##   printed SUBSCRIPT digit (5424 followed by 5424_1 and 5424_2 on printed p. 832).
## =============================================================================

options(scipen = 999, stringsAsFactors = FALSE, width = 200)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); setwd(folder)
out_dir <- file.path(folder, "reference_tables")
if(!dir.exists(out_dir)) dir.create(out_dir)

## ---- locale: non-ASCII author names must survive the write -----------------
ctype_ok <- any(vapply(c("en_US.UTF-8", "C.UTF-8"), function(l)
  tryCatch({ Sys.setlocale("LC_CTYPE", l); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) },
           error=function(e) FALSE), logical(1)))
if(!ctype_ok) stop("No UTF-8 LC_CTYPE locale available; citation text would be corrupted on write.", call.=FALSE)

for(p in c("readr", "dplyr", "stringr", "pdftools", "openssl")) if(!requireNamespace(p, quietly=TRUE)) stop("Install package: ", p, call.=FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr); library(stringr); library(pdftools) })

paper <- "Hayssen_etal_1993"
slice_map_file <- file.path(folder, paste0(paper, "_pdf_slices.csv"))
pdf_dir <- file.path(folder, "pdf_by_order")
if(!file.exists(slice_map_file)) stop("Missing input: ", slice_map_file, call.=FALSE)
slice_map <- read_csv(slice_map_file, show_col_types = FALSE)
lit_row <- slice_map[slice_map$section == "LiteratureCited", ]
if(nrow(lit_row) != 1) stop("Slice map must have exactly one LiteratureCited row", call.=FALSE)
lit_pdf <- file.path(pdf_dir, lit_row$file)
app_pdf <- file.path(pdf_dir, slice_map$file[slice_map$section == "Appendices_Indexes"])
for(f in c(lit_pdf, app_pdf)) if(!file.exists(f)) stop("Missing input: ", f, call.=FALSE)

## ---- SHA-256 of the source slice must match the slice map -------------------
sha_lit <- as.character(openssl::sha256(file(lit_pdf)))
if(!isTRUE(tolower(trimws(unname(sha_lit))) == tolower(trimws(lit_row$sha256[[1]])))) stop("SHA-256 mismatch for ", basename(lit_pdf), ": ", sha_lit, " vs slice map ", lit_row$sha256, call.=FALSE)
cat("Literature Cited slice SHA-256 verified:", sha_lit, "\n")

N_PAGES_EXPECTED <- 286L
PRINTED_FIRST    <- 705L     # printed page of slice page 1
PDF_BOOK_FIRST   <- as.integer(lit_row$pdf_page_start)   # whole-book PDF page of slice page 1 (716)
if(lit_row$n_pages != N_PAGES_EXPECTED) stop("Slice map says ", lit_row$n_pages, " pages, expected ", N_PAGES_EXPECTED, call.=FALSE)
if(PDF_BOOK_FIRST != 716L) stop("Slice map pdf_page_start for Literature Cited is ", PDF_BOOK_FIRST, ", expected 716", call.=FALSE)

## ---- helpers: word boxes -> per-column lines --------------------------------
## Each page has a running header on the top text line and two columns of
## entries. The gutter is the longest horizontal run in x = 200..450 not covered
## by any body word box (pages are offset by up to 50 pt, so it is found per page).
## Lines are words within 3 pt of vertical distance, read left-to-right.
words_to_lines <- function(w, ytol = 3) {
  if(nrow(w) == 0) return(data.frame(line = character(0), y = integer(0)))
  w <- w %>% arrange(y, x)
  grp <- cumsum(c(TRUE, diff(w$y) > ytol))
  w %>% mutate(g = grp) %>% arrange(g, x) %>% group_by(g) %>%
    summarise(line = paste(text, collapse = " "), y = min(y), .groups = "drop") %>%
    arrange(y) %>% select(line, y)
}
page_lines <- function(p, ytol = 3, hdr_band = 14) {
  p <- p %>% arrange(y, x)
  ymin <- min(p$y)
  hdr  <- p %>% filter(y <= ymin + hdr_band) %>% arrange(x)
  body <- p %>% filter(y >  ymin + hdr_band)
  if(min(body$y) - max(hdr$y) < 15) stop("Header band touches body text (y gap ", min(body$y) - max(hdr$y), ")", call.=FALSE)
  cov <- rep(FALSE, 700)
  for(i in seq_len(nrow(body))) { a <- max(1, body$x[i]); b <- min(700, body$x[i] + body$width[i]); cov[a:b] <- TRUE }
  idx <- 200:450; unc <- !cov[idx]
  r <- rle(unc); ends <- cumsum(r$lengths); starts <- ends - r$lengths + 1
  k <- which(r$values); if(!length(k)) stop("No column gutter found", call.=FALSE)
  j <- k[which.max(r$lengths[k])]
  if(r$lengths[j] < 20) stop("Column gutter too narrow (", r$lengths[j], " pt)", call.=FALSE)
  gutter <- idx[1] - 1 + (starts[j] + ends[j]) / 2
  list(header = paste(hdr$text, collapse = " "),
       left  = words_to_lines(body %>% filter(x <  gutter), ytol),
       right = words_to_lines(body %>% filter(x >= gutter), ytol),
       gutter = gutter)
}

cat("Extracting word boxes from", basename(lit_pdf), "...\n")
wd <- pdf_data(lit_pdf, font_info = FALSE)
if(length(wd) != N_PAGES_EXPECTED) stop("pdf_data returned ", length(wd), " pages, expected ", N_PAGES_EXPECTED, call.=FALSE)
if(any(vapply(wd, nrow, integer(1)) == 0)) stop("Page(s) with no text layer: ", paste(which(vapply(wd, nrow, integer(1)) == 0), collapse=","), call.=FALSE)
pages <- lapply(wd, page_lines)

lines_df <- bind_rows(lapply(seq_along(pages), function(i) {
  z <- pages[[i]]
  bind_rows(z$left %>% mutate(col = "L"), z$right %>% mutate(col = "R")) %>% mutate(page = i, seq_on_page = row_number())
})) %>% mutate(line_id = row_number(),
               ## U+00AC (NOT SIGN) is the OCR's rendering of the end-of-line hyphen
               line = str_replace_all(str_squish(line), "\u00ac", "-"))
cat("Lines reconstructed:", nrow(lines_df), "on", length(unique(lines_df$page)), "pages\n")
if(length(unique(lines_df$page)) != N_PAGES_EXPECTED) stop("Not every page produced lines", call.=FALSE)

## ---- running headers ---------------------------------------------------------
## "<printed page> <first>.-<last>." (page number left on even, right on odd pages).
## Pages whose header cannot be read are DECLARED here with the reason; nothing
## else is tolerated (guard below).
DECLARED_HEADERS <- tribble(
  ~page, ~hdr_first, ~hdr_last, ~declaration,
  1L,    "1",        NA,        "section title page 'Literature Cited'; no running header; first entry is 1, last taken from the entries found on the page",
  73L,   NA,         NA,        "printed page number 777 OCR'd as 'Ill'; range tokens read normally",
  279L,  NA,         NA,        "header last number OCR'd as '118*1' (unreadable); range first read normally, last taken as the entries found on the page")
hdr_tbl <- tibble(page = seq_along(pages), header = vapply(pages, `[[`, character(1), "header")) %>%
  mutate(printed_page = PRINTED_FIRST + page - 1L, pdf_page_in_book = PDF_BOOK_FIRST + page - 1L)
parse_header <- function(h, printed) {
  toks <- str_extract_all(h, "\\d+[a-z]?")[[1]]
  pg_i <- which(toks == as.character(printed))
  rng  <- if(length(pg_i)) toks[-pg_i[1]] else toks
  list(page_ok = length(pg_i) >= 1, first = if(length(rng) >= 1) rng[1] else NA_character_,
       last = if(length(rng) >= 2) rng[2] else NA_character_, n_tok = length(toks))
}
hp <- Map(parse_header, hdr_tbl$header, hdr_tbl$printed_page)
hdr_tbl$hdr_page_ok <- vapply(hp, `[[`, logical(1), "page_ok")
hdr_tbl$hdr_first   <- vapply(hp, `[[`, character(1), "first")
hdr_tbl$hdr_last    <- vapply(hp, `[[`, character(1), "last")
hdr_tbl$hdr_n_tok   <- vapply(hp, `[[`, integer(1), "n_tok")
hdr_tbl$header_status <- ifelse(hdr_tbl$hdr_page_ok & hdr_tbl$hdr_n_tok == 3 & !is.na(hdr_tbl$hdr_last), "parsed", "declared")
hdr_tbl <- hdr_tbl %>% left_join(DECLARED_HEADERS %>% rename(decl_first = hdr_first, decl_last = hdr_last), by = "page")
bad_hdr <- hdr_tbl %>% filter(header_status == "declared", is.na(declaration))
if(nrow(bad_hdr)) stop("Header not parsable and not declared on slice page(s): ", paste(bad_hdr$page, "'", bad_hdr$header, "'", collapse="; "), call.=FALSE)
over_decl <- hdr_tbl %>% filter(header_status == "parsed", !is.na(declaration))
if(nrow(over_decl)) stop("Declared header pages that actually parse (remove the declaration): ", paste(over_decl$page, collapse=","), call.=FALSE)
## page 73: the range tokens parse although the printed page did not; page 279: first parses
hdr_tbl <- hdr_tbl %>% mutate(
  hdr_first = coalesce(hdr_first, decl_first),
  hdr_first = ifelse(page == 73L, str_extract_all(header[page == 73L], "\\d+[a-z]?")[[1]][1], hdr_first),
  hdr_last  = ifelse(page == 73L, str_extract_all(header[page == 73L], "\\d+[a-z]?")[[1]][2], hdr_last),
  hdr_first = ifelse(page == 279L, str_extract(header, "\\d+[a-z]?(?=\\.-)"), hdr_first),
  hdr_last  = ifelse(page == 279L, NA_character_, hdr_last))
if(any(is.na(hdr_tbl$hdr_first))) stop("Header first number unresolved on page(s): ", paste(which(is.na(hdr_tbl$hdr_first)), collapse=","), call.=FALSE)
cat("Headers parsed:", sum(hdr_tbl$header_status == "parsed"), " declared:", sum(hdr_tbl$header_status == "declared"), "\n")

## ---- entry-start detection: pass 1 (sequence-constrained) --------------------
## A line starts an entry if it begins "<number><suffix>." and the number fits the
## sequence: a bare number must exceed the last bare number by 1..40; a lettered
## insert must sit on the current base (next unseen letter) or open a new base with
## 'a'. Year-like tokens (1700-1992) that start a continuation line ("1974. Title")
## are only accepted when the sequence fits AND the text after the token looks like
## an author ("Surname, I" etc.). Subscript inserts: '5424,.' (subscript 1 read as a
## comma) and '54242.' (subscript digit fused) are accepted on the current base.
auth_re <- "^(?:[A-Z\u2018\u2019'\\(\\[]|not used|d[aeiu]\\s|v[ao]n\\s|de[lr]?\\s|l[ae]\\s|Mc|Mac|O'|St\\s|[0-9]\\S*\\s+[A-Z])"
auth_strict_re <- "^(?:[A-Z\u2018\u2019'][^\\s,]*,\\s|not used|d[aeiu]\\s|v[ao]n\\s|de[lr]?\\s|l[ae]\\s)"
## number token: digits, optional letter suffix, optional subscript-1 artefact (',' or ';'),
## period (may be missing: '11455a Ward' -- then the strict author pattern is required)
m <- str_match(lines_df$line, "^(\\d{1,5})([a-z]?)([,;]?)(\\.?)\\s+(.*)$")
lines_df$t_num  <- suppressWarnings(as.integer(m[,2])); lines_df$t_suf <- m[,3]; lines_df$t_sub1 <- m[,4]; lines_df$t_dot <- m[,5]; lines_df$t_rest <- m[,6]
lines_df$authlike <- !is.na(lines_df$t_rest) & str_detect(lines_df$t_rest, auth_re)
lines_df$auth_strict <- !is.na(lines_df$t_rest) & str_detect(lines_df$t_rest, auth_strict_re)
no_dot <- !is.na(lines_df$t_num) & lines_df$t_dot == "" & !lines_df$auth_strict
lines_df$t_num[no_dot] <- NA_integer_
## OCR-damaged suffixed tokens: digits with junk characters + letter ('115>91a. Yamada')
jm <- str_match(lines_df$line, "^([0-9%>)]*[%>)][0-9%>)]*)([a-z])\\.?\\s+(.*)$")
lines_df$j_tok <- jm[,2]; lines_df$j_suf <- jm[,3]
lines_df$j_auth <- !is.na(jm[,4]) & str_detect(jm[,4], auth_strict_re)
## printed numbering errors: inserted entries whose printed number is out of sequence (kept as printed)
PRINTED_OUT_OF_SEQUENCE <- tribble(
  ~ref_number, ~between, ~declaration,
  "1924a", "1294-1295", "printed '1924a.' between 1294 and 1295 on printed p. 735 (Broadbooks 1952, Cryptotis parva); the species accounts cite it as 1924a; kept as printed")
yearlike <- function(n) !is.na(n) & n >= 1700 & n <= 1992
MAX_JUMP <- 40L
Nl <- nrow(lines_df)
acc_base <- rep(NA_integer_, Nl); acc_suf <- rep(NA_character_, Nl); acc_note <- rep(NA_character_, Nl); acc_oos <- rep(FALSE, Nl)
last_bare <- 0L; cur_base <- 0L; seen <- character(0)
for(i in seq_len(Nl)) {
  n <- lines_df$t_num[i]
  if(is.na(n)) {
    ## damaged suffixed token on the current base, next unseen letter, strict author text
    if(!is.na(lines_df$j_tok[i]) && lines_df$j_auth[i] && adist(gsub("[^0-9]", "", lines_df$j_tok[i]), as.character(cur_base))[1] <= 2 && !(paste0(cur_base, lines_df$j_suf[i]) %in% seen)) {
      acc_base[i] <- cur_base; acc_suf[i] <- lines_df$j_suf[i]
      acc_note[i] <- sprintf("number OCR token '%s%s' read as %d%s (junk characters in the digits; digit-similar to the current base; author text follows)", lines_df$j_tok[i], lines_df$j_suf[i], cur_base, lines_df$j_suf[i])
      seen <- c(seen, paste0(cur_base, lines_df$j_suf[i]))
    }
    next
  }
  s <- lines_df$t_suf[i]; sub1 <- lines_df$t_sub1[i]; al <- lines_df$authlike[i]
  key <- NULL; note <- NA_character_; oos <- FALSE
  if(sub1 == "") {
    if(s == "") {
      if(n > last_bare && n <= last_bare + MAX_JUMP && (!yearlike(n) || al)) key <- c(n, "")
      else if(al && n >= 10L && n %/% 10L == cur_base && !(paste0(cur_base, "_", n %% 10L) %in% seen)) {
        key <- c(cur_base, paste0("_", n %% 10L)); note <- sprintf("subscript insert: OCR token '%d.' read as %d_%d (printed subscript digit fused to the number)", n, cur_base, n %% 10L) }
    } else {
      if(n == cur_base && !(paste0(n, s) %in% seen)) key <- c(n, s)
      else if(n > last_bare && n <= last_bare + MAX_JUMP && s == "a") key <- c(n, s)
      else if(al && paste0(n, s) %in% PRINTED_OUT_OF_SEQUENCE$ref_number && !(paste0(n, s) %in% seen)) {
        key <- c(n, s); oos <- TRUE
        note <- sprintf("printed out of sequence between %d and the next number: %s", cur_base, PRINTED_OUT_OF_SEQUENCE$declaration[PRINTED_OUT_OF_SEQUENCE$ref_number == paste0(n, s)]) }
    }
  } else if(al && (n == cur_base || adist(as.character(n), as.character(cur_base))[1] <= 1) && !(paste0(cur_base, s, "_1") %in% seen)) {
    ## subscript 1 after the base ('5424,.'), after a letter ('5405b,.'), or after an OCR-shifted base ('3990,.' for 3900)
    key <- c(cur_base, paste0(s, "_1"))
    note <- sprintf("subscript insert: OCR token '%d%s%s.' read as %d%s_1 (printed subscript 1 read as '%s'%s)", n, s, sub1, cur_base, s, sub1,
                    if(n != cur_base) sprintf("; digits '%d' digit-similar to the current base %d", n, cur_base) else "")
  }
  if(!is.null(key)) {
    b <- as.integer(key[1]); sf <- key[2]
    acc_base[i] <- b; acc_suf[i] <- sf; acc_note[i] <- note; acc_oos[i] <- oos
    if(!oos) { if(sf == "") last_bare <- b; cur_base <- b }
    seen <- c(seen, paste0(b, sf))
  }
}
cat("Pass 1: entry starts accepted:", sum(!is.na(acc_base)), " (with OCR-number notes:", sum(!is.na(acc_note)), ")\n")

## ---- pass 2: gap fill ---------------------------------------------------------
## For each bare number missing after pass 1, lines between the neighbouring
## accepted entries that start with a digit-containing token and continue with
## author-like text are candidates ('25%.', '587)8.', '115184.', '121 Albignac').
## Assigned only when the count of candidates equals the count of missing numbers
## in that gap, in order. Anything else stays a gap and is reported.
bare_idx <- which(!is.na(acc_base) & acc_suf == "")
bare <- acc_base[bare_idx]
if(any(diff(bare) <= 0)) stop("Bare numbers not strictly increasing after pass 1", call.=FALSE)
gaps <- setdiff(seq_len(max(bare)), bare)
gap_tok_re <- "^(\\S{1,8})\\s+(.*)$"
n_filled <- 0L
if(length(gaps)) {
  gap_groups <- split(gaps, cumsum(c(TRUE, diff(gaps) != 1)))
  for(gg in gap_groups) {
    i_prev <- max(bare_idx[bare < gg[1]]); i_next <- min(bare_idx[bare > gg[length(gg)]])
    cand <- setdiff(seq(i_prev + 1L, i_next - 1L), which(!is.na(acc_base)))
    cand <- cand[str_detect(lines_df$line[cand], gap_tok_re)]
    if(length(cand)) {
      tok  <- str_match(lines_df$line[cand], gap_tok_re)
      ## token = digits plus OCR junk characters only ('25%.', '587)8.', '115>99.', '121'); never a page range like '75-96,'
      keep <- str_detect(tok[,2], "^[0-9%>)]+[.,]{0,2}$") & str_detect(tok[,2], "[0-9]") & str_detect(tok[,3], auth_re)
      cand <- cand[keep]; tok <- tok[keep, , drop = FALSE]
    }
    if(length(cand) == length(gg)) {
      for(k in seq_along(gg)) {
        acc_base[cand[k]] <- gg[k]; acc_suf[cand[k]] <- ""
        acc_note[cand[k]] <- sprintf("number OCR token '%s' read as %d (fills the only gap between %d and %d; author text follows)", tok[k, 2], gg[k], acc_base[i_prev], acc_base[i_next])
        n_filled <- n_filled + 1L
      }
    }
  }
}
cat("Pass 2: gap numbers recovered from OCR-damaged tokens:", n_filled, "\n")
lines_df$acc_base <- acc_base; lines_df$acc_suf <- acc_suf; lines_df$acc_note <- acc_note; lines_df$acc_oos <- acc_oos
lines_df$is_start <- !is.na(acc_base)

## ---- assemble entries -----------------------------------------------------------
lines_df$entry_id <- cumsum(lines_df$is_start)
pre <- lines_df %>% filter(entry_id == 0)            # lines before the first entry (section title)
ent_lines <- lines_df %>% filter(entry_id > 0)
join_lines <- function(x) {
  if(length(x) == 1) return(x)
  out <- x[1]
  for(k in 2:length(x)) out <- if(str_detect(out, "-$")) paste0(out, x[k]) else paste(out, x[k])
  out
}
entries <- ent_lines %>% group_by(entry_id) %>%
  summarise(ref_number_base = first(acc_base), ref_suffix = first(acc_suf), number_note = first(acc_note), out_of_sequence = first(acc_oos),
            citation = str_squish(join_lines(line)),
            pdf_page_in_slice = first(page), column = first(col), n_lines = n(),
            n_pages_spanned = n_distinct(page), .groups = "drop") %>%
  mutate(ref_number = paste0(ref_number_base, ref_suffix),
         printed_page = PRINTED_FIRST + pdf_page_in_slice - 1L,
         pdf_page_in_book = PDF_BOOK_FIRST + pdf_page_in_slice - 1L,
         ## strip the printed number token from the citation text
         citation = str_replace(citation, "^\\S+\\s+", ""))

## ---- guards on the number sequence ----------------------------------------------
if(any(duplicated(entries$ref_number))) stop("Duplicate ref_number: ", paste(entries$ref_number[duplicated(entries$ref_number)], collapse=","), call.=FALSE)
bare_seq <- entries$ref_number_base[entries$ref_suffix == ""]
if(any(diff(bare_seq) <= 0)) stop("Bare reference numbers are not strictly increasing", call.=FALSE)
## every suffixed insert sits on the preceding or the following bare number
oos_found <- entries$ref_number[entries$out_of_sequence]
if(!setequal(oos_found, PRINTED_OUT_OF_SEQUENCE$ref_number)) stop("Out-of-sequence printed numbers found (", paste(oos_found, collapse=","), ") differ from the declared set (", paste(PRINTED_OUT_OF_SEQUENCE$ref_number, collapse=","), ")", call.=FALSE)
suf_rows <- which(entries$ref_suffix != "" & !entries$out_of_sequence)
bad_suf <- vapply(suf_rows, function(r) {
  prev_b <- suppressWarnings(max(entries$ref_number_base[seq_len(r - 1)][entries$ref_suffix[seq_len(r - 1)] == ""], -Inf))
  nxt    <- entries$ref_number_base[seq(r + 1, nrow(entries))][entries$ref_suffix[seq(r + 1, nrow(entries))] == ""]
  next_b <- if(length(nxt)) nxt[1] else Inf
  !(entries$ref_number_base[r] %in% c(prev_b, next_b))
}, logical(1))
if(any(bad_suf)) stop("Suffixed entries not adjacent to their base number: ", paste(entries$ref_number[suf_rows[bad_suf]], collapse=","), call.=FALSE)

## ---- citation grammar -------------------------------------------------------------
## Authors. YEAR. Title. Journal. VOL:PAGES.   (journal article)
## Authors. YEAR. Title. <rest>.               (book / chapter / report -> partial)
## Year token: 4 digits optionally followed by a letter or a range ("1972-74").
## the period before/after the year may be a comma or missing in the OCR ("Tullner, WW, 1967." / "et al 1988.")
year_re <- "^(.*?)[.,]?\\s+((?:1[6-9]|20)\\d{2}[a-z]?(?:[-/]\\d{2,4})?)[.,]\\s*(.*)$"
ym <- str_match(entries$citation, year_re)
entries$authors_block <- ym[,2]; entries$year <- ym[,3]; after <- ym[,4]
## trailing "Journal. VOL:PAGES." with an optional issue "(3)" and page letters
## the journal may start with an OCR period ('.1 Mamm' for 'J Mamm')
jr <- str_match(after, "^(.*?)\\.\\s+(\\.?[^.]*?[A-Za-z][^.]*?)\\.?\\s+(\\d+[A-Za-z]?(?:\\s*\\([^)]*\\))?(?:\\s*Suppl\\.?\\s*\\d*)?)\\s*:\\s*([0-9A-Za-z][0-9A-Za-z, -]*)\\.?$")
entries$title <- jr[,2]; entries$journal_or_publisher <- jr[,3]; entries$volume <- jr[,4]; entries$pages <- jr[,5]
no_vol <- !is.na(after) & is.na(entries$title)
## title and journal not separable (period lost) but VOL:PAGES present: keep the block as title,
## take volume and pages, journal NA (-> partial)
vm <- str_match(after[no_vol], "^(.*?[A-Za-z].*?)\\.?\\s+(\\d+[A-Za-z]?(?:\\s*\\([^)]*\\))?)\\s*:\\s*([0-9A-Za-z][0-9A-Za-z, -]*)\\.?$")
has_vp <- !is.na(vm[,1])
idx_vp <- which(no_vol)[has_vp]
entries$title[idx_vp] <- vm[has_vp, 2]; entries$volume[idx_vp] <- vm[has_vp, 3]; entries$pages[idx_vp] <- vm[has_vp, 4]
entries$title_journal_unseparated <- FALSE; entries$title_journal_unseparated[idx_vp] <- TRUE
## book form: first sentence is the title, remainder is publisher/book
no_vol2 <- no_vol & is.na(entries$title)
bm <- str_match(after[no_vol2], "^(.*?)\\.\\s+(.*)$")
entries$title[no_vol2] <- bm[,2]; entries$journal_or_publisher[no_vol2] <- bm[,3]
entries$first_author <- str_squish(str_replace(entries$authors_block, "^([^,]+),.*$", "\\1"))
entries$first_author[!is.na(entries$authors_block) & !str_detect(entries$authors_block, ",")] <- str_squish(entries$authors_block[!is.na(entries$authors_block) & !str_detect(entries$authors_block, ",")])
entries$parse_status <- case_when(
  is.na(entries$year) ~ "verbatim_only",
  !is.na(entries$volume) & !is.na(entries$pages) & !is.na(entries$title) & nzchar(entries$title) & !entries$title_journal_unseparated ~ "parsed",
  TRUE ~ "partial")
not_used <- str_detect(entries$citation, "^not used\\.?$")
entries$number_note[not_used] <- ifelse(is.na(entries$number_note[not_used]), "printed 'not used'", paste(entries$number_note[not_used], "; printed 'not used'"))
## sanity: a parsed year must not be absurd and the first author must be short
if(any(nchar(entries$first_author[!is.na(entries$first_author)]) > 60)) {
  long_fa <- entries %>% filter(!is.na(first_author), nchar(first_author) > 60)
  entries$parse_status[entries$ref_number %in% long_fa$ref_number] <- "partial"
}

refs <- entries %>% transmute(ref_number, ref_number_base, ref_suffix, citation, first_author, year, title,
                              journal_or_publisher, volume, pages, printed_page, pdf_page_in_slice, pdf_page_in_book,
                              parse_status, number_note, n_lines, column)
cat("\n== references table ==\n")
cat("rows (reference numbers):", nrow(refs), "\n")
cat("bare numbers:", sum(refs$ref_suffix == ""), " letter-suffixed:", sum(str_detect(refs$ref_suffix, "^[a-z]$")), " subscript-suffixed:", sum(str_detect(refs$ref_suffix, "_")), " printed out of sequence (kept as printed):", sum(refs$ref_number %in% PRINTED_OUT_OF_SEQUENCE$ref_number), "\n")
cat("max base number:", max(refs$ref_number_base), "\n")
print(table(refs$parse_status))
cat("'not used' placeholders:", sum(not_used), "\n")
cat("entries with an OCR-number note:", sum(!is.na(refs$number_note) & !not_used), "\n")
cat("entries spanning a page break:", sum(entries$n_pages_spanned > 1), "\n")
cat("partial with title/journal unseparated but volume:pages taken:", sum(entries$title_journal_unseparated), "\n")

## ---- page check -----------------------------------------------------------------------
base_set <- refs$ref_number_base[refs$ref_suffix == ""]
page_check <- lapply(seq_len(N_PAGES_EXPECTED), function(i) {
  h <- hdr_tbl[i, ]
  on_page <- refs %>% filter(pdf_page_in_slice == i)
  bare_on <- on_page$ref_number_base[on_page$ref_suffix == ""]
  first_b <- as.integer(str_extract(h$hdr_first, "^\\d+"))
  last_b  <- if(!is.na(h$hdr_last)) as.integer(str_extract(h$hdr_last, "^\\d+")) else NA_integer_
  last_eff <- if(is.na(last_b)) suppressWarnings(max(bare_on)) else last_b
  rng <- seq(first_b, last_eff)
  ## a header starting with a suffixed insert (217a.-260.) continues the previous page's base
  ## number; that base is counted on the page where it starts
  first_has_suffix <- str_detect(h$hdr_first, "[a-z]$")
  if(first_has_suffix && !(first_b %in% bare_on)) rng <- rng[-1]
  missing_global <- rng[!(rng %in% base_set)]
  on_other <- rng[!(rng %in% bare_on) & (rng %in% base_set)]
  extra <- bare_on[!(bare_on %in% rng)]
  tibble(pdf_page_in_slice = i, pdf_page_in_book = h$pdf_page_in_book, printed_page = h$printed_page,
         header_as_read = h$header, header_status = h$header_status, header_declaration = h$declaration,
         hdr_first = h$hdr_first, hdr_last = ifelse(is.na(h$hdr_last), NA_character_, h$hdr_last),
         hdr_last_used = as.character(last_eff),
         n_entries_found = nrow(on_page), n_bare_found = length(bare_on), n_suffixed_found = nrow(on_page) - length(bare_on),
         n_expected_base = length(rng),
         missing_numbers = paste(missing_global, collapse = ";"), n_missing = length(missing_global),
         base_on_adjacent_page = paste(on_other, collapse = ";"),
         extra_numbers = paste(extra, collapse = ";"), n_extra = length(extra))
}) %>% bind_rows()

## GUARDS
if(any(page_check$n_entries_found == 0)) stop("Page(s) with no entries: ", paste(which(page_check$n_entries_found == 0), collapse=","), call.=FALSE)
if(any(page_check$n_extra > 0)) stop("Entries outside the header range on page(s): ", paste(page_check$pdf_page_in_slice[page_check$n_extra > 0], collapse=","), call.=FALSE)
## header continuity: next page's first base follows this page's last (allowing a printed skip of one number)
fb <- as.integer(str_extract(page_check$hdr_first, "^\\d+")); lb <- as.integer(page_check$hdr_last_used)
step <- fb[-1] - lb[-length(lb)]
first_suffixed <- str_detect(page_check$hdr_first[-1], "[a-z]$")
step_ok <- (step %in% 1:2) | (step == 0 & first_suffixed)
if(!all(step_ok)) stop("Header ranges not continuous between slice pages: ", paste(which(!step_ok), collapse=","), call.=FALSE)
cat("page-break steps of 2 (a number skipped across a page break):", sum(step == 2), "; pages opening with a suffixed insert of the previous page's last number:", sum(step == 0), "\n")
## cross-page bases: a base number listed under another page's header must start on an adjacent page
adj_ok <- vapply(seq_len(nrow(page_check)), function(i) {
  nums <- as.integer(str_split(page_check$base_on_adjacent_page[i], ";")[[1]]); nums <- nums[!is.na(nums)]
  if(!length(nums)) return(TRUE)
  all(abs(refs$pdf_page_in_slice[match(nums, ifelse(refs$ref_suffix == "", refs$ref_number_base, NA))] - i) == 1)
}, logical(1))
if(!all(adj_ok)) stop("Base numbers found far from their header page: ", paste(which(!adj_ok), collapse=","), call.=FALSE)

residual <- sort(unique(as.integer(unlist(str_split(page_check$missing_numbers[page_check$n_missing > 0], ";")))))
cat("Residual missing base numbers after gap fill:", length(residual), " ->", paste(residual, collapse=", "), "\n")
## CONVENTION-OK: the residual is written to the page-check file and printed above; the
## three numbers 1744, 5418 and 11166 are absent from the printed book itself (verified on
## the page images of printed pp. 746, 832 and 966: 1743 -> 1745, 5417 -> 5419, 11165 ->
## 11167, each with no entry between). Any other residual is an OCR/parse failure and stops.
RESIDUAL_BOOK_GAPS <- c(1744L, 5418L, 11166L)
if(!setequal(residual, RESIDUAL_BOOK_GAPS)) stop("Residual missing numbers differ from the declared printed gaps (", paste(RESIDUAL_BOOK_GAPS, collapse=","), "): ", paste(residual, collapse=","), call.=FALSE)
if(sum(page_check$n_expected_base) - length(residual) != length(base_set)) stop("Header totals do not reconcile with bare numbers found", call.=FALSE)
cat("Header-expected base numbers (sum over pages):", sum(page_check$n_expected_base), "; bare numbers found:", length(base_set), "; residual:", length(residual), "\n")

## ---- unparsed ------------------------------------------------------------------------
folded <- lines_df %>% filter(!is_start, (!is.na(t_num) & auth_strict) | (!is.na(j_tok) & j_auth)) %>%
  mutate(kind = "numeric-start author-like line folded into preceding entry (not accepted by the sequence rule)")
pre_u <- pre %>% mutate(kind = "line before the first entry (section title)")
unparsed <- bind_rows(pre_u, folded) %>%
  transmute(kind, pdf_page_in_slice = page, printed_page = PRINTED_FIRST + page - 1L, column = col, line,
            folded_into_ref_number = ifelse(entry_id > 0, entries$ref_number[match(entry_id, entries$entry_id)], NA_character_))
cat("unparsed rows:", nrow(unparsed), " (pre-first-entry:", nrow(pre_u), ", folded numeric-start author-like:", nrow(folded), ")\n")
if(nrow(folded)) print(as.data.frame(folded %>% select(page, line)), right = FALSE)

## ---- Appendix 2: core journals (printed pp. 995-998, three columns) -----------------------
cat("\n== Appendix 2 core journals ==\n")
ap_txt <- pdf_text(app_pdf)
ap_core_pages <- which(str_detect(ap_txt, "Core Journals"))
if(!length(ap_core_pages)) stop("Appendix 2 'Core Journals' not found", call.=FALSE)
ap_wd <- pdf_data(app_pdf, font_info = FALSE)
core <- bind_rows(lapply(ap_core_pages, function(i) {
  p <- ap_wd[[i]] %>% arrange(y, x)
  ymin <- min(p$y)
  body <- p %>% filter(y > ymin + 14)
  ## drop prose lines spanning the page (the introductory paragraph on the first page)
  ## (a prose row spans the page with no wide inter-word gap; column rows have gaps > 30 pt)
  body <- body %>% arrange(y, x) %>% mutate(g = cumsum(c(TRUE, diff(y) > 3))) %>% arrange(g, x) %>% group_by(g) %>%
    mutate(span = max(x + width) - min(x), maxgap = if(n() > 1) max(lead(x) - (x + width), na.rm = TRUE) else 0) %>% ungroup() %>%
    filter(!(span > 300 & maxgap < 30)) %>% select(-g, -span, -maxgap)
  ## up to three columns: split on uncovered x-runs (>= 8 pt) between the text extents
  cov <- rep(FALSE, 700)
  for(k in seq_len(nrow(body))) { a <- max(1, body$x[k]); b <- min(700, body$x[k] + body$width[k]); cov[a:b] <- TRUE }
  lo <- min(body$x) + 30; hi <- max(body$x + body$width) - 30
  r <- rle(!cov[lo:hi]); ends <- cumsum(r$lengths) + lo - 1; starts <- ends - r$lengths + 1
  runs <- tibble(start = starts, end = ends, len = r$lengths, uncovered = r$values) %>% filter(uncovered, len >= 8) %>% arrange(desc(len)) %>% slice(1:2) %>% arrange(start)
  cuts <- (runs$start + runs$end) / 2
  body$colno <- 1L
  for(cc in cuts) body$colno <- body$colno + as.integer(body$x >= cc)
  bind_rows(lapply(1:3, function(cn) words_to_lines(body %>% filter(colno == cn)) %>% mutate(colno = cn))) %>%
    mutate(ap_page = i, printed_page = 991L + i - 1L)
})) %>% mutate(line = str_squish(line)) %>% filter(nzchar(line)) %>%
  ## the last (short) line of the introductory paragraph on printed p. 995 is not a journal
  filter(line != "BioSciences Information Service.")
## a journal record = name lines followed by an "(abbreviation)" that may wrap onto a
## further line until its parentheses balance ("(Ann Mus R Afr Cent Ser" / "Quarto Zool)")
core <- core %>% arrange(ap_page, colno, y)
is_abbr <- logical(nrow(core)); rec <- integer(nrow(core)); open_par <- 0L; r <- 0L
for(i in seq_len(nrow(core))) {
  ln <- core$line[i]
  if(open_par > 0) { is_abbr[i] <- TRUE }
  else if(str_detect(ln, "^\\(")) { is_abbr[i] <- TRUE }
  else { if(i == 1 || is_abbr[i - 1]) r <- r + 1L }
  rec[i] <- r
  open_par <- open_par + str_count(ln, "\\(") - str_count(ln, "\\)")
  if(open_par < 0) open_par <- 0L
}
core$is_abbr <- is_abbr; core$rec <- rec
## every record must have exactly one abbreviation block
if(any(core$rec == 0)) stop("Appendix 2: abbreviation line before any journal name", call.=FALSE)
core_tbl <- core %>% group_by(ap_page, printed_page, colno, rec) %>%
  summarise(journal_name = str_squish(paste(line[!is_abbr], collapse = " ")),
            abbreviation = str_squish(str_replace_all(paste(line[is_abbr], collapse = " "), "^\\(|\\)$", "")), .groups = "drop") %>%
  arrange(ap_page, colno, rec) %>% select(journal_name, abbreviation, printed_page)
core_tbl <- core_tbl %>% filter(!(journal_name %in% c("Core Journals", "Appendix 2")), nzchar(abbreviation) | nzchar(journal_name))
cat("core journal records:", nrow(core_tbl), " with abbreviation:", sum(nzchar(core_tbl$abbreviation)), " without:", sum(!nzchar(core_tbl$abbreviation)), "\n")
norm_j <- function(x) str_squish(str_to_lower(str_replace_all(x, "[^A-Za-z ]", " ")))
refs_j <- norm_j(refs$journal_or_publisher)
core_j <- norm_j(core_tbl$abbreviation)
cat("references whose parsed journal matches a core-journal abbreviation:", sum(refs_j %in% core_j[nzchar(core_j)], na.rm = TRUE), "of", sum(refs$parse_status == "parsed"), "parsed\n")

## ---- Appendix 1: Literature Cited numbers in parentheses ----------------------------------------
ap1_pages <- seq_len(ap_core_pages[1] - 1L)
ap1_nums <- unlist(str_extract_all(ap_txt[ap1_pages], "\\((\\d{1,5}[a-z]?)\\)"))
ap1_nums <- unique(str_replace_all(ap1_nums, "[()]", ""))
ap1_in <- ap1_nums %in% refs$ref_number
cat("Appendix 1 distinct numbers in parentheses:", length(ap1_nums), " in references table:", sum(ap1_in), " not:", sum(!ap1_in), "\n")

## ---- coverage check: numbers cited in the species accounts (20 order slices) -----------------
## Species-account pages are single-column; the reference numbers are right-aligned
## (x >= 420 pt in 635-pt pages) at the end of a data line or on a line of their own.
## We take the trailing comma-separated run of tokens <int 1-13000><letter?> on every
## line whose last word starts at x >= 420 pt, plus every parenthesised number list in the
## familial prose. This is a plausibility check, not the transcription.
cat("\n== coverage check over the order slices ==\n")
order_rows <- slice_map %>% filter(!(section %in% c("FrontMatter", "LiteratureCited", "Appendices_Indexes")))
if(nrow(order_rows) != 20) stop("Expected 20 order slices, found ", nrow(order_rows), call.=FALSE)
tok_re <- "^\\d{1,5}[a-z]?$"
cited <- bind_rows(lapply(seq_len(nrow(order_rows)), function(k) {
  fk <- file.path(pdf_dir, order_rows$file[k]); if(!file.exists(fk)) stop("Missing slice: ", fk, call.=FALSE)
  w <- pdf_data(fk, font_info = FALSE)
  bind_rows(lapply(seq_along(w), function(i) {
    p <- w[[i]]; if(nrow(p) == 0) return(NULL)
    p <- p %>% arrange(y, x) %>% mutate(g = cumsum(c(TRUE, diff(y) > 3))) %>% arrange(g, x)
    ln <- p %>% group_by(g) %>% summarise(words = list(text), x_last = last(x), .groups = "drop")
    out <- list()
    for(r in seq_len(nrow(ln))) {
      ws <- ln$words[[r]]
      ## trailing run of number tokens (commas allowed between them)
      if(ln$x_last[r] >= 420) {
        j <- length(ws); run <- character(0)
        while(j >= 1) {
          t <- str_replace(ws[j], ",$", "")
          if(str_detect(t, tok_re)) { run <- c(t, run); j <- j - 1 } else break
        }
        if(length(run)) out[[length(out) + 1]] <- tibble(token = run, kind = "trailing", page = i)
      }
      ## parenthesised lists in prose
      s <- paste(ws, collapse = " ")
      par <- str_extract_all(s, "\\(([^()]*)\\)")[[1]]
      for(pp in par) {
        inner <- str_split(str_replace_all(pp, "[()]", ""), "[,;]\\s*")[[1]] %>% str_squish()
        inner <- inner[str_detect(inner, tok_re)]
        if(length(inner)) out[[length(out) + 1]] <- tibble(token = inner, kind = "parenthesised", page = i)
      }
    }
    if(length(out)) bind_rows(out) %>% mutate(order_slice = order_rows$section[k], pdf_page_in_slice = page) %>% select(-page) else NULL
  }))
}))
cited <- cited %>% mutate(base = as.integer(str_extract(token, "^\\d+"))) %>% filter(base >= 1, base <= 13000)
cited_distinct <- cited %>% group_by(token) %>% summarise(n_occurrences = n(), kinds = paste(sort(unique(kind)), collapse = "+"),
                                                            orders = paste(sort(unique(order_slice)), collapse = ";"), .groups = "drop")
cited_distinct$in_references <- cited_distinct$token %in% refs$ref_number
cat("number tokens collected:", nrow(cited), " (trailing:", sum(cited$kind == "trailing"), ", parenthesised:", sum(cited$kind == "parenthesised"), ")\n")
cat("distinct numbers cited in the species accounts:", nrow(cited_distinct), "\n")
cat("  with a row in the references table:", sum(cited_distinct$in_references), "\n")
cat("  without:", sum(!cited_distinct$in_references), "\n")
cat("references table rows cited at least once by this check:", sum(refs$ref_number %in% cited_distinct$token), "of", nrow(refs), "\n")
not_in <- cited_distinct %>% filter(!in_references) %>% arrange(desc(n_occurrences))
cat("  cited >= 3 times but absent:", sum(not_in$n_occurrences >= 3), "\n")
ap1_tbl <- tibble(token = ap1_nums[!ap1_in], n_occurrences = NA_integer_, kinds = "appendix1_parenthesised", orders = "Appendix 1", in_references = FALSE)
not_in_out <- bind_rows(not_in, ap1_tbl)

## ---- write -------------------------------------------------------------------------------------
write_bom_csv <- function(x, path) {
  write_excel_csv(x, path, na = "")
  b <- readBin(path, "raw", 3); if(!identical(b, as.raw(c(0xef, 0xbb, 0xbf)))) stop("BOM missing on ", path, call.=FALSE)
  rb <- read_csv(path, show_col_types = FALSE, col_types = cols(.default = "c")); if(nrow(rb) != nrow(x)) stop("Row count changed on write: ", path, call.=FALSE)
}
f_refs  <- file.path(out_dir, paste0(paper, "_references.csv"))
f_pc    <- file.path(out_dir, paste0(paper, "_references_page_check.csv"))
f_unp   <- file.path(out_dir, paste0(paper, "_references_unparsed.csv"))
f_def   <- file.path(out_dir, paste0(paper, "_references_definitions.csv"))
f_core  <- file.path(out_dir, paste0(paper, "_core_journals.csv"))
f_cov   <- file.path(out_dir, paste0(paper, "_cited_numbers_not_in_bibliography.csv"))
write_bom_csv(refs, f_refs); write_bom_csv(page_check, f_pc); write_bom_csv(unparsed, f_unp)
write_bom_csv(core_tbl, f_core); write_bom_csv(not_in_out, f_cov)

## read-back: a non-ASCII author survives the round trip
rb <- read_csv(f_refs, show_col_types = FALSE, col_types = cols(.default = "c"))
if(nrow(rb) != nrow(refs) || !identical(rb$ref_number, refs$ref_number)) stop("references.csv read-back mismatch", call.=FALSE)
if(!any(str_detect(rb$citation, "[^\\x01-\\x7f]"))) stop("No non-ASCII character survived in citation text", call.=FALSE)

## ---- definitions -----------------------------------------------------------------------------------
src_note <- "pdf_by_order/Hayssen_etal_1993_21_LiteratureCited.pdf (printed pp. 705-990, OCR text layer)"
defs <- tribble(
  ~Code, ~Definition, ~Structure, ~Measure, ~Stat, ~role, ~taxon, ~Reference, ~Note, ~`Source Note`,
  "ref_number", "Reference number as printed in the Literature Cited: integer, or integer plus an inserted-entry suffix (letter a-z as printed, e.g. 3625a; printed subscript digit written as _1, _2, e.g. 5424_1); the key cited at the end of every data line in the species accounts", NA, "key", NA, "info", "mammals", paste0(paper, "_references"), "one row per individual number including suffixed inserts; unique, asserted; inserts may be printed before their base number (781a before 781); 1924a is printed out of sequence (between 1294 and 1295) and kept as printed", src_note,
  "ref_number_base", "Integer part of ref_number", NA, "integer", NA, "info", "mammals", paste0(paper, "_references"), "bare numbers strictly increasing 1..12139, asserted; 1744, 5418, 11166 are absent from the printed book (verified on page images)", src_note,
  "ref_suffix", "Insert suffix: '' for a bare number, 'a'-'z' as printed, '_<digit>' for a printed subscript digit, letter+'_1' for a subscript after a letter (5405b_1)", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), "subscript tokens were OCR'd as ',' or as a fused trailing digit and are recovered on the current base (see number_note)", src_note,
  "citation", "Full bibliographic entry verbatim from the OCR text layer: the number token removed, line wraps joined (a line ending in a hyphen is joined without a space), whitespace collapsed; OCR errors retained (e.g. '.1 Mamm' for 'J Mamm', 'Omithorhynchus')", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), "authoritative column; 'not used' marks a number the book reserved without an entry", src_note,
  "first_author", "Surname block of the first author: text before the first comma of the author block; heuristic split of the verbatim citation", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), "author block = text before the first ' YYYY. ' token", src_note,
  "year", "Publication year token: four digits with optional letter or range (1972-74, 1968/69), the first such token followed by '.' or ',' after the author block; heuristic", NA, "year", NA, "info", "mammals", paste0(paper, "_references"), NA, src_note,
  "title", "Title: text between the year and the journal/book block; heuristic (for journal articles the block before 'Journal. VOL:PAGES'; for books the first sentence after the year; when the period between title and journal is lost the whole block is kept here, volume/pages taken and journal left NA -> partial)", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), NA, src_note,
  "journal_or_publisher", "Journal abbreviation as printed (BioSciences Information Service style, see _core_journals.csv) for journal articles; for books/chapters/reports the remainder after the title (book title, pages, editors, publisher, place)", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), "no normalisation applied", src_note,
  "volume", "Volume token before the colon, including issue in parentheses or supplement if printed", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), "NA for books", src_note,
  "pages", "Page range after the colon, as printed", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), "NA for books", src_note,
  "printed_page", "Printed page of the book on which the entry starts (705-990)", NA, "integer", NA, "info", "mammals", paste0(paper, "_references"), "running header checked against slice position", src_note,
  "pdf_page_in_slice", "Page within pdf_by_order/..._21_LiteratureCited.pdf (1-286)", NA, "integer", NA, "info", "mammals", paste0(paper, "_references"), NA, src_note,
  "pdf_page_in_book", "Page within the whole-book PDF (716-1001 = slice page + 715)", NA, "integer", NA, "info", "mammals", paste0(paper, "_references"), NA, src_note,
  "parse_status", "parsed = authors, year, title, journal, volume and pages all split; partial = year found but not the full journal pattern (books, chapters, reports, OCR-damaged journal lines); verbatim_only = no year token found (includes 'not used' placeholders)", NA, "category", NA, "info", "mammals", paste0(paper, "_references"), NA, src_note,
  "number_note", "How an OCR-damaged number token was resolved to ref_number (gap fill, digit-similar suffix, subscript insert), or 'printed not used'; NA when the token was read cleanly", NA, NA, NA, "info", "mammals", paste0(paper, "_references"), "every corrected token is quoted verbatim", src_note,
  "n_lines", "Number of OCR text lines joined into the citation", NA, "integer", NA, "info", "mammals", paste0(paper, "_references"), NA, src_note,
  "column", "Column of the printed page in which the entry starts (L/R)", NA, "category", NA, "info", "mammals", paste0(paper, "_references"), NA, src_note,
  "journal_name", "Core journal full name as printed in Appendix 2 (printed pp. 995-998)", NA, NA, NA, "info", "mammals", paste0(paper, "_core_journals"), "journals reviewed volume by volume 1964-1988 or vol. 1-1991", "pdf_by_order/Hayssen_etal_1993_22_Appendices_Indexes.pdf Appendix 2",
  "abbreviation", "Abbreviation used in the bibliography, as printed in parentheses under the journal name", NA, NA, NA, "info", "mammals", paste0(paper, "_core_journals"), "other abbreviations follow the BioSciences Information Service (book statement)", "pdf_by_order/Hayssen_etal_1993_22_Appendices_Indexes.pdf Appendix 2",
  "token", "Reference-number token found at the end of a species-account data line or in a parenthesised list, with no row in the references table", NA, NA, NA, "info", "mammals", paste0(paper, "_cited_numbers_not_in_bibliography"), "plausibility check of the bibliography parse; tokens may be OCR noise or values misread as numbers", "pdf_by_order order slices 01-20, Appendix 1",
  "missing_numbers", "Base numbers in the page's header range with no row anywhere in the references table", NA, NA, NA, "info", "mammals", paste0(paper, "_references_page_check"), "residual = 1744;5418;11166, printed gaps in the book", src_note,
  "extra_numbers", "Bare numbers found on the page but outside its header range (asserted empty)", NA, NA, NA, "info", "mammals", paste0(paper, "_references_page_check"), NA, src_note
)
write_bom_csv(defs, f_def)

## ---- README section (replaces an existing 'Reference table' section) -----------------------------------
readme <- file.path(folder, paste0(paper, ".README.md"))
if(!file.exists(readme)) stop("README missing: ", readme, call.=FALSE)
rl <- readLines(readme, encoding = "UTF-8")
marker <- "## Reference table"
if(any(rl == marker)) { k <- which(rl == marker)[1]; nxt <- which(str_detect(rl, "^## ") & seq_along(rl) > k); rl <- if(length(nxt)) c(rl[1:(k-1)], rl[nxt[1]:length(rl)]) else rl[1:(k-1)] }
ps <- table(refs$parse_status)
sec <- c(marker, "",
  sprintf("Built by `%s_references.R` (Rscript, pdftools word boxes -> per-column lines -> sequence-constrained entry grammar) from `pdf_by_order/%s` (SHA-256 verified against the slice map; all %d slice pages processed). Run date %s.", paper, basename(lit_pdf), N_PAGES_EXPECTED, format(Sys.Date())),
  "",
  "### Counts (printed by the script)", "",
  sprintf("- `reference_tables/%s_references.csv`: **%d rows** = one per reference number; %d bare numbers (1..%d), %d letter-suffixed inserts (e.g. 3625a), %d subscript-suffixed inserts (printed 5424₁/5424₂/5405b₁, written `5424_1`/`5424_2`/`5405b_1`), %d insert printed out of sequence and kept as printed (`1924a` between 1294 and 1295, printed p. 735; cited as 1924a in Insectivora).", paper, nrow(refs), sum(refs$ref_suffix == ""), max(refs$ref_number_base), sum(str_detect(refs$ref_suffix, "^[a-z]$")), sum(str_detect(refs$ref_suffix, "_")), sum(refs$ref_number %in% PRINTED_OUT_OF_SEQUENCE$ref_number)),
  sprintf("- parse_status: parsed %d, partial %d, verbatim_only %d (of which %d are the book's own `not used` placeholders).", ps[["parsed"]], ps[["partial"]], ps[["verbatim_only"]], sum(not_used)),
  sprintf("- Page check: headers parsed on %d pages, declared on %d (slice p. 1 title page; p. 73 printed page `777` OCR'd `Ill`; p. 279 header last `118*1` unreadable). Header-expected base numbers %d; found %d; **residual missing %d: %s** — all three are absent from the printed book (page images of printed pp. 746, 832, 966 checked: 1743→1745, 5417→5419, 11165→11167). Zero entries outside their page's header range (asserted).", sum(hdr_tbl$header_status == "parsed"), sum(hdr_tbl$header_status == "declared"), sum(page_check$n_expected_base), length(base_set), length(residual), paste(residual, collapse = ", ")),
  sprintf("- OCR-damaged number tokens resolved: %d (quoted verbatim in `number_note`): %d by gap fill (e.g. `25%%.`→2596, `115184.`→11984, `121 Albignac`→122), %d subscript inserts, %d damaged suffixed token(s) (`115>91a.`→11991a).", sum(!is.na(refs$number_note) & !not_used & !refs$ref_number %in% PRINTED_OUT_OF_SEQUENCE$ref_number), n_filled, sum(str_detect(refs$ref_suffix, "_")), sum(str_detect(coalesce(refs$number_note, ""), "junk characters"))),
  sprintf("- `%s_references_unparsed.csv`: %d rows (%d lines before the first entry; %d numeric-start author-like lines folded into the preceding entry).", paper, nrow(unparsed), nrow(pre_u), nrow(folded)),
  sprintf("- `%s_core_journals.csv`: %d Appendix 2 records (%d with an abbreviation); %d of %d parsed journal strings match a core abbreviation exactly.", paper, nrow(core_tbl), sum(nzchar(core_tbl$abbreviation)), sum(refs_j %in% core_j[nzchar(core_j)], na.rm = TRUE), sum(refs$parse_status == "parsed")),
  sprintf("- Coverage check (order slices 01–20, trailing right-aligned number runs + parenthesised lists in the familial prose): %d tokens, **%d distinct numbers cited; %d have a row, %d do not** (`%s_cited_numbers_not_in_bibliography.csv`; %d of them cited ≥ 3 times). %d of %d reference rows are hit at least once. Appendix 1: %d distinct numbers, %d in the table, %d not.", nrow(cited), nrow(cited_distinct), sum(cited_distinct$in_references), sum(!cited_distinct$in_references), paper, sum(not_in$n_occurrences >= 3), sum(refs$ref_number %in% cited_distinct$token), nrow(refs), length(ap1_nums), sum(ap1_in), sum(!ap1_in)),
  "",
  "### Grammar", "",
  "`<number><suffix>. <Authors>. <Year>. <Title>. <Journal>. <Volume>:<Pages>.` for articles; `<number>. <Authors>. <Year>. <Title>. <book, pages, editors, publisher, place>.` for books/chapters (→ `partial`); `<number>. not used` for reserved numbers (→ `verbatim_only`). Suffix = letter (inserted entry; can be printed before its base when alphabetical order requires: 781a precedes 781) or a printed subscript digit. Entry starts are accepted only when the number fits the sequence (bare: last bare + 1..40; letter: on the current base or opening a new base with `a`), so continuation lines beginning with a year (`1974. Observations …`) or a volume (`178.`) are never mistaken for entries; year-like tokens additionally need author-like text after them. A second pass fills single-number gaps with the one author-like line whose number token was OCR-damaged.",
  "",
  "### OCR failure modes and handling", "",
  "- Two-column pages: `pdf_text` interleaves the columns; the script uses `pdf_data` word boxes, finds the gutter per page (widest uncovered x-run in 200–450 pt) and reads each column separately.",
  "- Running header: `<printed page> <first>.-<last>.`; dash dropped (`1236. 1276.`) or fused (`1598.1639b.`) handled by token extraction; three pages declared (see counts).",
  "- Number tokens: digit→symbol (`25%.`, `50%.`), inserted characters (`587)8.`, `115184.`, `115>99.`), dropped period (`121 Albignac`), junk characters inside a suffixed number (`115>91a.`), a missing period (`11455a Ward`), subscript digits read as `,` or fused (`5424,.`, `54242.`, `5405b,.`, `3990,.` for 3900₁) — all resolved by sequence position and recorded in `number_note`. `1924a.` on printed p. 735 is NOT an OCR error: the book prints that number between 1294 and 1295 and cites it as 1924a; it is kept as printed and declared (`PRINTED_OUT_OF_SEQUENCE`).",
  "- End-of-line hyphen rendered as `¬` (U+00AC): replaced by `-` and the next line joined without a space.",
  "- Letter confusions inside citations (`.1 Mamm`, `Omithorhynchus`, `Fluszpferde`, `liber` for `über`, `Hire` for `Ihre`) are left verbatim in `citation`; `journal_or_publisher` is therefore as-OCR'd and the core-journal match rate above is a lower bound.",
  "- Three printed gaps (1744, 5418, 11166) are the book's own; they are listed in the page-check file, not silenced.",
  "",
  "### Coverage-check caveats", "",
  sprintf("The %d cited-but-absent tokens are of two kinds: (i) value tokens the trailing-number rule cannot distinguish from reference numbers (`10g`, `13d`, `5f` — a unit letter after a small number); (ii) suffixed numbers the species accounts cite but the bibliography never lists (%s). Kind (ii) is a finding about the book; it will be re-examined when the species accounts are transcribed. Columns beyond the specified set: `number_note`, `n_lines`, `column` (provenance of the number resolution and of the OCR block).", nrow(not_in), paste(head(not_in$token[not_in$n_occurrences >= 2 & nchar(not_in$token) >= 4], 8), collapse = ", ")),
  "")
writeLines(c(rl, if(length(rl) && nzchar(rl[length(rl)])) "" else NULL, sec), readme, useBytes = FALSE)
cat("\nWritten:\n"); for(f in c(f_refs, f_pc, f_unp, f_def, f_core, f_cov, readme)) cat(" ", f, "\n")
cat("DONE\n")
