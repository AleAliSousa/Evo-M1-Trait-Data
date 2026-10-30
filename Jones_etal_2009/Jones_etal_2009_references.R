## =============================================================================
## Jones et al. (2009), PanTHERIA 1.0 -- reference list and species x reference
## tables, parsed from the Ecological Archives metadata (metadata.htm)
## =============================================================================
##
## Inputs (all in this folder; frozen, never modified)
##   metadata.htm                     Ecological Archives E090-184 metadata,
##                                    ISO-8859-1 HTML. Section F "Reference list
##                                    for the data set": numbered entries
##                                    "N.&nbsp;...citation...<br />", italics
##                                    (<em>) mark species names, bold (<strong>)
##                                    marks the journal volume.
##   PanTHERIA_1-0_WR05_Aug2008.txt   species-level data, Wilson & Reeder 2005
##   PanTHERIA_1-0_WR93_Aug2008.txt   species-level data, Wilson & Reeder 1993
##                                    Column 36 `References` = semicolon-separated
##                                    reference index numbers PER SPECIES (not per
##                                    variable); -999 = none.
##
## Outputs (reference_tables/)
##   Jones_etal_2009_references.csv                 one row per reference number
##   Jones_etal_2009_references_unparsed.csv        entries whose year/author
##                                                  could not be parsed (kept
##                                                  verbatim, never dropped)
##   Jones_etal_2009_species_references.csv         long: taxonomy x species x
##                                                  ref_number x citation
##   Jones_etal_2009_species_reference_counts.csv   per species: n_refs and
##                                                  n_variables_with_data
##   Jones_etal_2009_species_data_without_references.csv
##                                                  species with any source-
##                                                  variable value but no refs
##   Jones_etal_2009_References_malformed_tokens.csv
##                                                  tokens in the References
##                                                  column that are not a valid
##                                                  reference number (8-digit
##                                                  fused pairs, missing ';')
##
## Conventions (evom1-refs-conventions C2, C5): one row per individual reference
## number; every input problem is a stop(), never a message(); parsed fields
## (first_author, year, title, ...) are heuristic splits of the verbatim
## `citation`, which is the authoritative column.
## =============================================================================

options(scipen = 999, stringsAsFactors = FALSE)
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

for(p in c("readr", "dplyr", "tidyr", "xml2")) if(!requireNamespace(p, quietly=TRUE)) stop("Install package: ", p, call.=FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr) })

meta_file <- file.path(folder, "metadata.htm")
f05 <- file.path(folder, "PanTHERIA_1-0_WR05_Aug2008.txt")
f93 <- file.path(folder, "PanTHERIA_1-0_WR93_Aug2008.txt")
for(f in c(meta_file, f05, f93)) if(!file.exists(f)) stop("Missing input: ", f, call.=FALSE)

## ---- helpers ---------------------------------------------------------------
## metadata.htm is ISO-8859-1, but it also uses Windows-1252 numeric entities
## (&#150; = en dash) and literal C1 bytes; decode both to real Unicode.
cp1252_fix <- function(x) {
  ## map C1 control code points U+0080..U+009F (as produced from &#128;..&#159;)
  ## to their Windows-1252 glyphs
  for(n in 128:159) {
    ch <- intToUtf8(n)
    if(any(grepl(ch, x, fixed=TRUE))) {
      rep <- iconv(rawToChar(as.raw(n)), from="CP1252", to="UTF-8")
      if(is.na(rep)) rep <- ""
      x <- gsub(ch, rep, x, fixed=TRUE)
    }
  }
  x
}
## named entities: a small fixed table for the common ones, xml2 for the rest
named_entities <- c("&nbsp;"=" ", "&amp;"="&", "&lt;"="<", "&gt;"=">", "&quot;"="\"", "&apos;"="'")
decode_named_entity <- function(e) {
  v <- tryCatch(xml2::xml_text(xml2::read_html(paste0("<p>", e, "</p>"))), error=function(err) NA_character_)
  if(is.na(v) || identical(v, e) || !nzchar(v)) stop("Unhandled HTML named entity: ", e, call.=FALSE)
  v
}
unescape_html <- function(x) {
  ## numeric entities first (decimal and hex)
  x <- vapply(x, function(s) {
    m <- gregexpr("&#(x[0-9A-Fa-f]+|[0-9]+);", s, perl=TRUE)
    ents <- regmatches(s, m)[[1]]
    if(length(ents)) {
      reps <- vapply(ents, function(e) {
        body <- sub("^&#(.*);$", "\\1", e)
        n <- if(grepl("^x", body)) strtoi(sub("^x", "", body), 16L) else as.integer(body)
        intToUtf8(n)
      }, character(1))
      regmatches(s, m) <- list(reps)
    }
    s
  }, character(1), USE.NAMES=FALSE)
  for(e in names(named_entities)) x <- gsub(e, named_entities[[e]], x, fixed=TRUE)
  left <- unique(unlist(regmatches(x, gregexpr("&[A-Za-z]+;", x))))
  for(e in left) x <- gsub(e, decode_named_entity(e), x, fixed=TRUE)
  if(any(grepl("&[A-Za-z#][A-Za-z0-9]*;", x))) stop("Unhandled HTML entity remains after decoding.", call.=FALSE)
  cp1252_fix(x)
}
strip_tags <- function(x) gsub("<[^>]+>", "", x)  # tags carry no text; the source puts its own spaces around <em>/<strong>
squish <- function(x) trimws(gsub("\\s+", " ", gsub("\u00a0", " ", x)))
html_to_text <- function(x) squish(unescape_html(strip_tags(x)))

## ---- read metadata.htm as UTF-8 text ---------------------------------------
raw <- readBin(meta_file, "raw", n=file.info(meta_file)$size)
html <- iconv(rawToChar(raw), from="latin1", to="UTF-8")
if(is.na(html)) stop("metadata.htm could not be decoded from ISO-8859-1.", call.=FALSE)

## ---- locate the reference list ---------------------------------------------
h_start <- regexpr("Reference list for the data set", html, fixed=TRUE)
h_end   <- regexpr("G. History of data set usage", html, fixed=TRUE)
if(h_start < 0 || h_end < 0 || h_end <= h_start)
  stop("Could not locate the 'Reference list for the data set' section in metadata.htm.", call.=FALSE)
seg <- substr(html, h_start, h_end - 1L)
## first entry begins at ">1.&nbsp;" after the heading sentence
e1 <- regexpr(">\\s*1\\.(&nbsp;)+", seg, perl=TRUE)
if(e1 < 0) stop("Could not find reference entry 1 in the reference list.", call.=FALSE)
seg <- substr(seg, e1 + 1L, nchar(seg))

## split on <br />; fragments that do not start with "N.&nbsp;" belong to the
## preceding entry (two entries in the source are broken across a <br />)
pieces <- strsplit(seg, "<br\\s*/?>", perl=TRUE)[[1]]
pieces <- pieces[nzchar(squish(strip_tags(pieces)))]
is_head <- grepl("^\\s*(<[^>]+>\\s*)*[0-9]+\\.(&nbsp;)+", pieces, perl=TRUE)
if(!is_head[1]) stop("Reference list does not start with a numbered entry.", call.=FALSE)
grp <- cumsum(is_head)
entries <- vapply(split(pieces, grp), paste, character(1), collapse=" ")
n_continuation_fragments <- sum(!is_head)

ref_number_chr <- sub("(?s)^\\s*(<[^>]+>\\s*)*([0-9]+)\\.(&nbsp;)+.*$", "\\2", entries, perl=TRUE)
body_html <- sub("^\\s*(<[^>]+>\\s*)*[0-9]+\\.(&nbsp;)+", "", entries, perl=TRUE)
if(any(!grepl("^[0-9]+$", ref_number_chr))) stop("Non-numeric reference number parsed.", call.=FALSE)
ref_number <- as.integer(ref_number_chr)

## ---- guards on numbering (C2) ----------------------------------------------
if(anyDuplicated(ref_number)) stop("Duplicate reference numbers: ",
  paste(unique(ref_number[duplicated(ref_number)]), collapse=", "), call.=FALSE)
if(!identical(sort(ref_number), seq_len(max(ref_number))))
  stop("Reference numbers are not contiguous 1..", max(ref_number), "; missing: ",
       paste(setdiff(seq_len(max(ref_number)), ref_number), collapse=", "), call.=FALSE)

## ---- verbatim citation and italicised species ------------------------------
citation <- html_to_text(body_html)
## drop a trailing "<p></p>" artefact already removed by strip_tags; trim trailing spaces
## Entry 3018 is printed in metadata.htm as just "Wiles, G. 1996." -- an incomplete
## entry in the publication itself. It is declared here so the short-citation
## guard still fails on any OTHER short entry; the row is kept verbatim and also
## listed in the unparsed sidecar. Nothing is invented to complete it.
KNOWN_INCOMPLETE_ENTRIES <- c(`3018` = "Wiles, G. 1996.")
short <- which(nchar(citation) < 20)
undeclared_short <- short[!(as.character(ref_number[short]) %in% names(KNOWN_INCOMPLETE_ENTRIES) &
                            citation[short] == KNOWN_INCOMPLETE_ENTRIES[as.character(ref_number[short])])]
if(length(undeclared_short)) stop("Citation shorter than 20 characters at ref_number(s): ",
  paste(ref_number[undeclared_short], collapse=", "), call.=FALSE)
if(!all(names(KNOWN_INCOMPLETE_ENTRIES) %in% as.character(ref_number[short])))
  stop("A declared incomplete entry is no longer short; update KNOWN_INCOMPLETE_ENTRIES.", call.=FALSE)

species_in_citation <- vapply(body_html, function(s) {
  m <- gregexpr("<em>(.*?)</em>", s, perl=TRUE)
  it <- regmatches(s, m)[[1]]
  if(!length(it)) return("")
  it <- html_to_text(sub("^<em>(.*?)</em>$", "\\1", it, perl=TRUE))
  it <- it[nzchar(it)]
  paste(it, collapse="; ")
}, character(1), USE.NAMES=FALSE)

## ---- heuristic field parse ---------------------------------------------------
## Pattern: "Authors. YEAR[a-z]. Title. Journal <strong>VOL</strong>:PAGES."
## Books/theses/chapters have no <strong> volume; then title = first sentence
## after the year and journal_or_publisher = the remainder.
year_re <- "\\b(1[5-9][0-9]{2}|20[0-9]{2})([a-z]?)\\."
parse_one <- function(ctext, chtml) {
  out <- list(first_author=NA_character_, year=NA_integer_, title=NA_character_,
              journal_or_publisher=NA_character_, volume=NA_character_, pages=NA_character_)
  m <- regexpr(year_re, ctext, perl=TRUE)
  if(m < 0) return(out)
  authors <- squish(substr(ctext, 1, m - 1L))
  out$year <- as.integer(sub(year_re, "\\1", regmatches(ctext, m), perl=TRUE))
  fa <- sub(",.*$", "", authors)
  fa <- sub("\\.$", "", squish(fa))
  out$first_author <- if(nzchar(fa)) fa else NA_character_
  rest <- squish(substr(ctext, m + attr(m, "match.length"), nchar(ctext)))
  ## volume from <strong>
  sm <- regexpr("<strong>(.*?)</strong>", chtml, perl=TRUE)
  if(sm > 0) {
    vol <- html_to_text(sub("^<strong>(.*?)</strong>$", "\\1", regmatches(chtml, sm), perl=TRUE))
    out$volume <- if(nzchar(vol)) vol else NA_character_
    after <- html_to_text(substr(chtml, sm + attr(sm, "match.length"), nchar(chtml)))
    pg <- regmatches(after, regexpr("^:\\s*[^.]+", after, perl=TRUE))
    if(length(pg)) out$pages <- squish(sub("^:\\s*", "", pg))
    ## text between year and the volume
    pre_html <- substr(chtml, 1, sm - 1L)
    pre <- html_to_text(pre_html)
    ym <- regexpr(year_re, pre, perl=TRUE)
    if(ym > 0) pre <- squish(substr(pre, ym + attr(ym, "match.length"), nchar(pre)))
    sp <- gregexpr("\\. ", pre, perl=TRUE)[[1]]
    if(sp[1] > 0) {
      last <- sp[length(sp)]
      out$title <- squish(substr(pre, 1, last))
      out$journal_or_publisher <- squish(substr(pre, last + 2L, nchar(pre)))
    } else {
      out$journal_or_publisher <- pre
    }
  } else {
    sp <- regexpr("\\. ", rest, perl=TRUE)
    if(sp > 0) {
      out$title <- squish(substr(rest, 1, sp))
      out$journal_or_publisher <- squish(substr(rest, sp + 2L, nchar(rest)))
    } else {
      out$title <- rest
    }
    pg <- regmatches(rest, regexpr("\\bPages?\\s+[0-9]+\\s*[-\u2013]\\s*[0-9]+", rest, perl=TRUE))
    if(length(pg)) out$pages <- squish(sub("^Pages?\\s+", "", pg))
  }
  out
}
parsed <- Map(parse_one, citation, body_html)
refs <- tibble(
  ref_number = ref_number,
  citation = citation,
  first_author = vapply(parsed, `[[`, character(1), "first_author"),
  year = vapply(parsed, `[[`, integer(1), "year"),
  title = vapply(parsed, `[[`, character(1), "title"),
  journal_or_publisher = vapply(parsed, `[[`, character(1), "journal_or_publisher"),
  volume = vapply(parsed, `[[`, character(1), "volume"),
  pages = vapply(parsed, `[[`, character(1), "pages"),
  species_in_citation = species_in_citation
) %>% arrange(ref_number)

year_rate <- mean(!is.na(refs$year))
unparsed <- refs %>% filter(is.na(year) | is.na(first_author) | nchar(citation) < 20) %>%
  mutate(reason = case_when(nchar(citation) < 20 ~ "incomplete entry as printed in metadata.htm (author and year only)",
                            is.na(year) ~ "no 4-digit year followed by a period",
                            TRUE ~ "no author text before year")) %>%
  select(ref_number, citation, reason)
if(year_rate < 0.99) stop(sprintf("Year parsed for only %.2f%% of references (< 99%%).", 100*year_rate), call.=FALSE)

## ---- cited numbers in the two data files -------------------------------------
read_pan <- function(f, n_expected) {
  d <- read.delim(f, sep="\t", quote="", check.names=FALSE, stringsAsFactors=FALSE,
                  na.strings=NULL, comment.char="", colClasses="character")
  if(nrow(d) != n_expected || ncol(d) != 55L)
    stop(basename(f), ": expected ", n_expected, " x 55, got ", nrow(d), " x ", ncol(d), call.=FALSE)
  if(!"References" %in% names(d)) stop(basename(f), ": no References column.", call.=FALSE)
  d
}
d05 <- read_pan(f05, 5416L)
d93 <- read_pan(f93, 4629L)
max_ref <- max(refs$ref_number)

## A token is valid if it is an integer in 1..max_ref. Tokens above max_ref are
## publication defects: two 4-digit numbers fused by a missing ';' (e.g.
## "30483049"). They are never dropped: each is decoded when it splits into
## exactly one pair of in-range numbers, recorded as such, and listed in a
## sidecar; any token that cannot be decoded is fatal.
decode_fused <- function(tok) {
  n <- nchar(tok)
  cands <- list()
  for(k in seq_len(n - 1L)) {
    a <- substr(tok, 1, k); b <- substr(tok, k + 1L, n)
    if(grepl("^0", a) || grepl("^0", b)) next
    ai <- as.integer(a); bi <- as.integer(b)
    if(ai >= 1 && ai <= max_ref && bi >= 1 && bi <= max_ref) cands[[length(cands) + 1L]] <- c(ai, bi)
  }
  cands
}
expand_refs <- function(d, taxonomy) {
  bin_col <- grep("_Binomial$", names(d), value=TRUE)
  ord_col <- grep("_Order$", names(d), value=TRUE)
  fam_col <- grep("_Family$", names(d), value=TRUE)
  rows <- list(); malformed <- list()
  for(i in seq_len(nrow(d))) {
    v <- d$References[i]
    if(v == "-999" || !nzchar(trimws(v))) next
    toks <- trimws(strsplit(v, ";", fixed=TRUE)[[1]])
    toks <- toks[nzchar(toks)]
    bad <- toks[!grepl("^[0-9]+$", toks)]
    if(length(bad)) stop(taxonomy, " ", d[[bin_col]][i], ": non-numeric reference token(s): ",
                         paste(bad, collapse=", "), call.=FALSE)
    for(t in toks) {
      ti <- as.numeric(t)
      if(ti >= 1 && ti <= max_ref) {
        rows[[length(rows) + 1L]] <- data.frame(taxonomy=taxonomy, MSW_Binomial=d[[bin_col]][i],
          MSW_Order=d[[ord_col]][i], MSW_Family=d[[fam_col]][i], ref_token_as_printed=t,
          ref_number=as.integer(ti), token_status="as_printed")
      } else {
        cands <- decode_fused(t)
        if(length(cands) != 1L)
          stop(taxonomy, " ", d[[bin_col]][i], ": reference token '", t, "' is not a valid reference number (1..",
               max_ref, ") and has ", length(cands), " candidate decodings (need exactly 1).", call.=FALSE)
        malformed[[length(malformed) + 1L]] <- data.frame(taxonomy=taxonomy, MSW_Binomial=d[[bin_col]][i],
          token_as_printed=t, decoded_as=paste(cands[[1]], collapse=";"), n_candidate_decodings=length(cands),
          References_as_printed=v)
        for(cn in cands[[1]])
          rows[[length(rows) + 1L]] <- data.frame(taxonomy=taxonomy, MSW_Binomial=d[[bin_col]][i],
            MSW_Order=d[[ord_col]][i], MSW_Family=d[[fam_col]][i], ref_token_as_printed=t,
            ref_number=cn, token_status="decoded_from_fused_token")
      }
    }
  }
  list(long=bind_rows(rows), malformed=bind_rows(malformed))
}
x05 <- expand_refs(d05, "WR05")
x93 <- expand_refs(d93, "WR93")
long <- bind_rows(x05$long, x93$long)
malformed <- bind_rows(x05$malformed, x93$malformed)

cited <- sort(unique(long$ref_number))
missing_rows <- setdiff(cited, refs$ref_number)
if(length(missing_rows)) stop("Cited reference number(s) without a row in the reference list: ",
  paste(missing_rows, collapse=", "), call.=FALSE)

## ---- n species citing each reference ---------------------------------------
cnt <- long %>% distinct(taxonomy, MSW_Binomial, ref_number) %>% count(taxonomy, ref_number) %>%
  tidyr::pivot_wider(names_from=taxonomy, values_from=n, values_fill=0L)
refs <- refs %>% left_join(cnt, by="ref_number") %>%
  mutate(n_species_citing_WR05 = coalesce(WR05, 0L), n_species_citing_WR93 = coalesce(WR93, 0L)) %>%
  select(-WR05, -WR93)

## ---- species x reference long table ----------------------------------------
long <- long %>% left_join(refs %>% select(ref_number, citation), by="ref_number") %>%
  arrange(taxonomy, MSW_Order, MSW_Family, MSW_Binomial, ref_number)
if(any(is.na(long$citation))) stop("Unresolved citation in long table.", call.=FALSE)

per_sp <- long %>% group_by(taxonomy, MSW_Binomial) %>%
  summarise(n_tokens_as_printed = n_distinct(ref_token_as_printed),
            n_fused_tokens = n_distinct(ref_token_as_printed[token_status == "decoded_from_fused_token"]),
            n_reference_numbers = n(),
            n_citations_resolved = sum(!is.na(citation) & nzchar(citation)), .groups="drop")
if(!all(per_sp$n_reference_numbers == per_sp$n_citations_resolved))
  stop("n_reference_numbers != n_citations_resolved for ",
       sum(per_sp$n_reference_numbers != per_sp$n_citations_resolved), " species.", call.=FALSE)
if(!all(per_sp$n_tokens_as_printed + per_sp$n_fused_tokens == per_sp$n_reference_numbers))
  stop("Token accounting failed: n_tokens_as_printed + n_fused_tokens != n_reference_numbers.", call.=FALSE)
## no species may cite the same number twice in its printed list
dup_in_species <- long %>% count(taxonomy, MSW_Binomial, ref_number) %>% filter(n > 1)
if(nrow(dup_in_species)) stop("Reference number repeated within a species list: ", nrow(dup_in_species), " cases.", call.=FALSE)
long <- long %>% left_join(per_sp, by=c("taxonomy", "MSW_Binomial")) %>%
  select(taxonomy, MSW_Binomial, MSW_Order, MSW_Family, ref_number, citation,
         ref_token_as_printed, token_status, n_reference_numbers, n_citations_resolved)

## ---- per-species counts: refs vs variables with data ------------------------
is_missing <- function(m) { r <- grepl("^-999(\\.0+)?$", m); dim(r) <- dim(m); r }
src_cols <- 6:35   # the 30 extracted source variables; References is column 36
species_counts <- function(d, taxonomy, per_sp) {
  bin_col <- grep("_Binomial$", names(d), value=TRUE)
  src <- as.matrix(d[, src_cols])
  all_other <- as.matrix(d[, setdiff(6:55, 36)])
  tibble(taxonomy = taxonomy, MSW_Binomial = d[[bin_col]],
         MSW_Order = d[[grep("_Order$", names(d), value=TRUE)]],
         MSW_Family = d[[grep("_Family$", names(d), value=TRUE)]],
         n_variables_with_data = rowSums(!is_missing(src)),
         n_variables_with_data_incl_derived = rowSums(!is_missing(all_other)),
         References_is_999 = d$References == "-999") %>%
    left_join(per_sp %>% filter(taxonomy == !!taxonomy) %>% select(MSW_Binomial, n_refs = n_reference_numbers),
              by="MSW_Binomial") %>%
    mutate(n_refs = coalesce(n_refs, 0L)) %>%
    select(taxonomy, MSW_Binomial, MSW_Order, MSW_Family, n_refs, n_variables_with_data,
           n_variables_with_data_incl_derived)
}
sc <- bind_rows(species_counts(d05, "WR05", per_sp), species_counts(d93, "WR93", per_sp))
if(nrow(sc) != 5416L + 4629L) stop("species_reference_counts must have 5416 + 4629 rows.", call.=FALSE)
no_refs_with_data <- sc %>% filter(n_refs == 0 & n_variables_with_data > 0)
refs_no_data <- sc %>% filter(n_refs > 0 & n_variables_with_data == 0)

## ---- write (UTF-8) and verify by reading back --------------------------------
write_utf8 <- function(x, name) {
  f <- file.path(out_dir, name)
  write_csv(x, f, na = "")
  back <- read_csv(f, show_col_types=FALSE, na=character(), progress=FALSE,
                   locale=locale(encoding="UTF-8"), col_types = cols(.default = col_character()))
  if(nrow(problems(back))) stop("Read-back of ", name, " reported parsing problems.", call.=FALSE)
  if(nrow(back) != nrow(x) || ncol(back) != ncol(x)) stop("Read-back dimension mismatch for ", name, call.=FALSE)
  if(!identical(names(back), names(x))) stop("Read-back header mismatch for ", name, call.=FALSE)
  if(!validUTF8(paste(readLines(f, encoding="UTF-8", warn=FALSE), collapse=""))) stop(name, " is not valid UTF-8.", call.=FALSE)
  if(nrow(x) && "citation" %in% names(x) && !identical(as.character(back$citation), as.character(x$citation)))
    stop("citation column changed on read-back for ", name, call.=FALSE)
  invisible(f)
}
write_utf8(refs, "Jones_etal_2009_references.csv")
write_utf8(unparsed, "Jones_etal_2009_references_unparsed.csv")
write_utf8(long, "Jones_etal_2009_species_references.csv")
write_utf8(sc, "Jones_etal_2009_species_reference_counts.csv")
write_utf8(no_refs_with_data, "Jones_etal_2009_species_data_without_references.csv")
write_utf8(malformed, "Jones_etal_2009_References_malformed_tokens.csv")

## ---- summary -------------------------------------------------------------------
cat("== Jones_etal_2009_references ==\n")
cat("n references (rows):", nrow(refs), "\n")
cat("max ref_number:", max_ref, "\n")
cat("continuation fragments joined (<br /> inside an entry):", n_continuation_fragments, "\n")
cat("year parsed:", sum(!is.na(refs$year)), sprintf("(%.2f%%)", 100*year_rate), "; unparsed sidecar rows:", nrow(unparsed), "\n")
cat("references with italicised species:", sum(nzchar(refs$species_in_citation)), "\n")
cat("n cited numbers (distinct, both files, after decoding fused tokens):", length(cited), "\n")
cat("n cited numbers without a row (must be 0):", length(missing_rows), "\n")
cat("n distinct reference numbers never cited by either file:", sum(refs$n_species_citing_WR05 == 0 & refs$n_species_citing_WR93 == 0), "\n")
cat("malformed (fused) reference tokens: ", nrow(malformed), " (WR05 ", sum(malformed$taxonomy=="WR05"),
    ", WR93 ", sum(malformed$taxonomy=="WR93"), "), distinct tokens ", length(unique(malformed$token_as_printed)), "\n", sep="")
cat("\n== species x reference long table ==\n")
cat("rows:", nrow(long), " (WR05 ", sum(long$taxonomy=="WR05"), ", WR93 ", sum(long$taxonomy=="WR93"), ")\n", sep="")
for(tx in c("WR05", "WR93")) {
  s <- sc %>% filter(taxonomy == tx)
  cat(tx, ": species rows ", nrow(s),
      "; species with refs ", sum(s$n_refs > 0),
      "; species with any source-variable (cols 6-35) data ", sum(s$n_variables_with_data > 0),
      "; species with any data incl. derived cols 37-55 ", sum(s$n_variables_with_data_incl_derived > 0),
      "; species with source data but no refs ", sum(s$n_refs == 0 & s$n_variables_with_data > 0),
      "; species with refs but no source data ", sum(s$n_refs > 0 & s$n_variables_with_data == 0),
      "; mean refs per species with refs ", round(mean(s$n_refs[s$n_refs > 0]), 2), "\n", sep="")
}
if(nrow(refs_no_data)) cat("species with refs but no source data:", paste(refs_no_data$taxonomy, refs_no_data$MSW_Binomial, collapse="; "), "\n")
cat("Wrote 6 files to", out_dir, "\n")
