## =============================================================================
## Hayssen et al. (1993), Asdell's Patterns of Mammalian Reproduction
## -- species accounts (step 2 of the transcription plan): the tabular data lines
##    of selected families as one-row-per-value tables, each value carrying its
##    own Literature Cited number(s) and a population status.
## =============================================================================
##
## Add a family by extending FAMILIES below; everything else (slice, page range,
## headings) is derived from the PDF text.
##
## Inputs (this folder; frozen, never modified)
##   Hayssen_etal_1993_pdf_slices.csv              slice map with SHA-256 per slice
##   pdf_by_order/..._00_FrontMatter.pdf                   printed pp. 5-6 "Abbreviations"
##   pdf_by_order/..._<NN>_<Order>.pdf                     species accounts of the order
##   reference_tables/..._references.csv                   one row per reference number (step 1)
##   reference_tables/..._cited_numbers_not_in_bibliography.csv
##                                                         numbers the accounts cite that the
##                                                         bibliography never lists (declared)
##   ../_keys/resolve_species.R                            species identity resolver
##
## Outputs (reference_tables/)
##   ..._accounts_<Family>.csv            one row per data line (one value) + family_overview rows
##   ..._accounts_unparsed.csv            lines not attributable to a topic/species (all families)
##   ..._accounts_definitions.csv         house definitions format (incl. method rows)
##   ..._abbreviations.csv                the book's abbreviation list (printed pp. 5-6)
##   and a "Species accounts (step 2)" section appended to the README.
##
## Page layout (verified on the page images; see README "Species accounts")
##   Three columns per data page: species (x ~ 35-180 pt), value (x ~ 190-450),
##   reference numbers (x ~ 455+). Pages are scanned with a slight rotation, so
##   the three columns of ONE printed line can differ by up to 6 pt in the OCR
##   y coordinate (half a line); the parser therefore rebuilds lines per column
##   and aligns the columns with a per-page offset instead of trusting a single
##   y grouping (pdf_text interleaves the columns and misplaces the numbers).
##
## Line grammar (as printed)
##   [species] <value>[; qualifier]* <ref>[, <ref>]*
##   species only on the first line of a species' run (inherited after);
##   TOPIC headings in capitals in the species column; family prose paragraphs
##   between the family heading and the first topic (parenthesised numbers ->
##   topic = family_overview).
## Conventions (evom1-refs-conventions): input problems stop(); every count
## printed; nothing dropped (parse_status = verbatim_only keeps the line).
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

ctype_ok <- any(vapply(c("en_US.UTF-8", "C.UTF-8"), function(l)
  tryCatch({ Sys.setlocale("LC_CTYPE", l); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) },
           error=function(e) FALSE), logical(1)))
if(!ctype_ok) stop("No UTF-8 LC_CTYPE locale available.", call.=FALSE)
for(p in c("readr", "dplyr", "stringr", "tibble", "pdftools", "openssl")) if(!requireNamespace(p, quietly=TRUE)) stop("Install package: ", p, call.=FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr); library(stringr); library(tibble); library(pdftools) })

paper <- "Hayssen_etal_1993"

## ---- families to transcribe ------------------------------------------------------
## Wave 1 (2026-10-22): Suidae, Mustelidae; wave 2 (2026-10-23): remaining Carnivora and all Primates;
## wave 3 (2026-10-24): every family of the book. FAMILIES is now derived from the contents table (all
## `Family` rows in TOC page order), so the vector no longer needs extending by hand.
contents <- read_csv(file.path(folder, paste0(paper, "_contents.csv")), show_col_types = FALSE, col_types = cols(.default = "c"))
## OCR letter errors in the family names of the contents table (2026-10-24: TOC page images of front-matter slice
## pages 5 and 6 rendered and read -- they print Ornithorhynchidae and Octodontidae; the body headings
## 'Order Monotremata, Family Ornithorhynchidae, Genus Ornithorhynchus' and 'Order Rodentia, Family Octodontidae'
## read the same in the text layer)
CONTENTS_OCR_FIX <- tribble(~contents, ~printed,
  "Omithorhynchidae", "Ornithorhynchidae",
  "Qctodontidae", "Octodontidae")
fam_rows <- contents %>% filter(level == "Family") %>% mutate(pp = as.integer(printed_page)) %>% arrange(pp)   # stable: TOC order kept within a page
fam_rows$name <- ifelse(fam_rows$name %in% CONTENTS_OCR_FIX$contents, CONTENTS_OCR_FIX$printed[match(fam_rows$name, CONTENTS_OCR_FIX$contents)], fam_rows$name)
if(anyDuplicated(fam_rows$name)) stop("Duplicate family names in the contents table: ", paste(fam_rows$name[duplicated(fam_rows$name)], collapse = ","), call.=FALSE)
FAMILIES <- fam_rows$name
cat("families in the contents table:", length(FAMILIES), "\n")
## the order of a family = the Order row with the largest printed page <= the family's printed page
## (the contents table's own `order` column interleaves the two TOC columns and labels the Carnivora
## families 'Rodentia'; it is not used -- the body heading 'Order X, Family Y' is asserted below anyway)
ord_rows <- contents %>% filter(level == "Order") %>% mutate(pp = as.integer(printed_page)) %>% arrange(pp)
## the contents table names the last order as the book prints it ('Macroscelidae'); the slice map (and the item names)
## use the current spelling 'Macroscelidea' -- the section name is what the rest of the script keys on
CONTENTS_ORDER_TO_SECTION <- c(Macroscelidae = "Macroscelidea")
ord_rows$name <- ifelse(ord_rows$name %in% names(CONTENTS_ORDER_TO_SECTION), CONTENTS_ORDER_TO_SECTION[ord_rows$name], ord_rows$name)
fam_rows <- fam_rows %>% mutate(pp = as.integer(printed_page), order_from_pages = vapply(pp, function(p) ord_rows$name[max(which(ord_rows$pp <= p))], character(1)))
if(any(fam_rows$order != fam_rows$order_from_pages))
  cat("NOTE contents.csv `order` column disagrees with the TOC page sequence for: ",
      paste(sprintf("%s (column %s, pages -> %s)", fam_rows$name, fam_rows$order, fam_rows$order_from_pages)[fam_rows$order != fam_rows$order_from_pages], collapse = "; "),
      " -- the page-derived order is used and asserted against the body heading\n", sep = "")   ## CONVENTION-OK: declared input defect, checked by the heading assertion in transcribe_family()
FAMILY_SPECS <- tibble(family = FAMILIES) %>% left_join(fam_rows %>% transmute(family = name, order = order_from_pages, toc_printed_page = pp), by = "family")
## Development mode (never for a build): HAYSSEN_DEV="<family|order>[,...]" restricts the run to those families,
## continues past a family that stops (its error is collected and printed at the end) and writes nothing.
DEV <- Sys.getenv("HAYSSEN_DEV")
if(nzchar(DEV)) {
  sel <- str_squish(str_split(DEV, ",")[[1]])
  FAMILY_SPECS <- FAMILY_SPECS %>% filter(family %in% sel | order %in% sel)
  if(!nrow(FAMILY_SPECS)) stop("HAYSSEN_DEV selects no family: ", DEV, call.=FALSE)
  cat("DEV MODE: ", nrow(FAMILY_SPECS), " families (", paste(FAMILY_SPECS$family, collapse = ", "), "); errors collected, nothing written\n", sep = "")
}

## ---- inputs ----------------------------------------------------------------------
slice_map_file <- file.path(folder, paste0(paper, "_pdf_slices.csv"))
pdf_dir <- file.path(folder, "pdf_by_order")
refs_file <- file.path(out_dir, paste0(paper, "_references.csv"))
notin_file <- file.path(out_dir, paste0(paper, "_cited_numbers_not_in_bibliography.csv"))
resolver <- file.path(dirname(folder), "_keys", "resolve_species.R")
for(f in c(slice_map_file, refs_file, notin_file, resolver)) if(!file.exists(f)) stop("Missing input: ", f, call.=FALSE)
slice_map <- read_csv(slice_map_file, show_col_types = FALSE)
refs <- read_csv(refs_file, show_col_types = FALSE, col_types = cols(.default = "c"))
if(anyDuplicated(refs$ref_number)) stop("references.csv ref_number not unique", call.=FALSE)
cat("references table:", nrow(refs), "rows\n")
notin <- read_csv(notin_file, show_col_types = FALSE, col_types = cols(.default = "c"))
DECLARED_ABSENT <- notin$token
## numbers the species accounts cite exactly as the OCR reads them (page images checked) that the bibliography never
## lists and the step-1 coverage check did not record: treated like DECLARED_ABSENT (ref_numbers_resolved FALSE,
## NOT_IN_BIBLIOGRAPHY in ref_first_author_year)
PRINTED_NOT_IN_BIBLIOGRAPHY <- tribble(~section, ~token, ~where,
  "Marsupialia", "8083a",  "Didelphidae prose p. 12, endocrinology list (printed 8083a; the bibliography has 8083 only)",
  "Chiroptera",  "16052a", "Phyllostomidae pp. 123, 132, 133 (printed 16052a; the bibliography ends at 12139)",
  "Chiroptera",  "19785",  "Phyllostomidae pp. 132, 133 (printed 19785; the bibliography ends at 12139)",
  "Rodentia",    "0000",   "Arvicolidae p. 583, Ondatra zibethicus LITTER SIZE '7.1 yg; r5-11; n22 lt' (the book prints 0000)",
  "Artiodactyla", "10564a", "Cervidae prose p. 391, 'flight (Cervus ...)' list (printed 10564a; the bibliography has 10564 only)")
source(resolver)

slice_pdf <- function(section) {
  r <- slice_map[slice_map$section == section, ]
  if(nrow(r) != 1) stop("Slice map must have exactly one row for section ", section, call.=FALSE)
  f <- file.path(pdf_dir, r$file); if(!file.exists(f)) stop("Missing slice: ", f, call.=FALSE)
  sha <- as.character(openssl::sha256(file(f)))
  if(tolower(sha) != tolower(r$sha256)) stop("SHA-256 mismatch for ", basename(f), call.=FALSE)
  cat("slice", basename(f), "SHA-256 verified\n")
  list(file = f, pdf_page_start = as.integer(r$pdf_page_start), n_pages = as.integer(r$n_pages), toc_printed_page = r$toc_printed_page)
}

## ---- helpers: word boxes -> per-column lines ---------------------------------------
words_to_lines <- function(w, ytol = 3) {
  if(nrow(w) == 0) return(tibble(line=character(0), y=numeric(0), x_min=numeric(0), x_max=numeric(0), n_words=integer(0), max_gap=numeric(0)))
  w <- w %>% arrange(y, x)
  grp <- cumsum(c(TRUE, diff(w$y) > ytol))
  w %>% mutate(g = grp) %>% arrange(g, x) %>% group_by(g) %>%
    summarise(line = paste(text, collapse=" "), y = median(y), x_min = min(x), x_max = max(x + width), n_words = n(),
              max_gap = if(n() > 1) max(lead(x) - (x + width), na.rm=TRUE) else 0, .groups="drop") %>% arrange(y) %>% select(-g)
}
## species-column text: a binomial (OCR may split a word -- 'Pan the ra tigris', 'Alouatta pal Hat a' -- or read
## 'rv' as 'n/' and 'i' as '!'; a trailing '?' marks questionable taxonomy, sometimes OCR'd with a space), a genus
## with spp (optionally followed by the book's quoted vernacular: Canis spp "gray jackals"), or two species on
## one line ('Cebus apella, C albifrons', 'Presbytis johnii/P senex', 'Ateles belzebuth/A geoffroyi' OCR'd 'IA')
## wave 3: up to 5 words (an epithet split into four pieces, 'Sciurus carol in en sis'), a '?' after the genus
## ('Sundasciurus? lowii'), a '.' inside a word ('Nycticeiv.s'), a capital I for l inside the genus ('GazeIIa'), and the
## two-species form with 'or' ('Nycteris arge or N major')
species_re <- paste0("^[A-Z][a-zI]+\\??( [A-Za-z!/.]+){1,5} ?\\??$",
                     "|^[A-Z][a-z]+ spp?\\.?( \"[a-z ]+\")?$",
                     "|^[A-Z][a-z]+ [a-z]+(, | ?/ ?|I| or )[A-Z][a-z]*\\.? ?[a-z]+$")
family_heading_re <- "^Order [A-Z][a-z]+, Family [A-Z][a-z]+(, Genus [A-Z][a-z]+)?$"
## OCR letter errors in the family name of a body heading (page image checked; the printed name is the
## one in the contents table and in the running headers of the neighbouring pages)
HEADING_OCR_FIX <- tribble(~section, ~ocr, ~printed,
  "Carnivora", "Proteiidae", "Protelidae")
## 'Order X, Family Y[, Genus Z]' -> the printed family name (OCR variants mapped)
heading_family <- function(text, section) {
  f <- str_match(text, "^Order [A-Z][a-z]+, Family ([A-Z][a-z]+)")[, 2]
  fx <- HEADING_OCR_FIX %>% filter(section == !!section)
  i <- match(f, fx$ocr); ifelse(is.na(i), f, fx$printed[i])
}
topic_re   <- "^[A-Z][A-Z/ ]+['\u2019]?$"   # the book's first table (Tachyglossidae p. 8) carries a footnote mark after HATCHLING MASS, OCR'd as a quote
num_tok_re <- "^\\d{1,5}[a-z]?,?$"
LINE_PITCH <- 11.5   # pt between printed lines
## offset d maximising the number of ya + d that have a yb within tol; ties -> smallest |d|
best_offset <- function(ya, yb, tol = 2.5, grid = seq(-9, 9, by = 0.5)) {
  if(!length(ya) || !length(yb)) return(0)
  sc <- vapply(grid, function(d) sum(vapply(ya, function(v) min(abs(yb - (v + d))) <= tol, logical(1))), integer(1))
  cand <- grid[sc == max(sc)]; cand[which.min(abs(cand))]
}
## order-preserving alignment of two y-sorted line sets (a = values, b = references or species): the columns
## of a page list the same printed lines in the same order, so a value and its reference are matched by
## sequence, not by nearest y. Cost of a pair = |yb - (ya + d)| (allowed up to tolmax); skipping an a-line costs
## ga, skipping a b-line gb. Returns, for each a, the index of its b or NA. Needed because the OCR y offset
## between the columns is not constant down a page (Galagidae p. 185: 0 pt at the top, -5 pt at y 608, +7 pt
## at the foot) and nearest-y matching then pairs a line with its neighbour's reference.
dp_align <- function(ya, yb, d = 0, tolmax = 9, ga = 6, gb = 6) {
  na <- length(ya); nb <- length(yb)
  if(!na) return(integer(0)); if(!nb) return(rep(NA_integer_, na))
  cost <- matrix(Inf, na + 1, nb + 1); cost[1, ] <- gb * (0:nb); cost[, 1] <- ga * (0:na)
  move <- matrix(0L, na + 1, nb + 1)
  for(i in seq_len(na)) for(j in seq_len(nb)) {
    dl <- abs(yb[j] - (ya[i] + d))
    c_m <- if(dl <= tolmax) cost[i, j] + dl else Inf
    c_a <- cost[i, j + 1] + ga; c_b <- cost[i + 1, j] + gb
    k <- which.min(c(c_m, c_a, c_b)); cost[i + 1, j + 1] <- c(c_m, c_a, c_b)[k]; move[i + 1, j + 1] <- k
  }
  idx <- rep(NA_integer_, na); i <- na; j <- nb
  while(i > 0 && j > 0) { k <- move[i + 1, j + 1]; if(k == 1L) { idx[i] <- j; i <- i - 1; j <- j - 1 } else if(k == 2L) i <- i - 1 else j <- j - 1 }
  idx
}
## one page -> classified raw lines + an ordered event stream (topic / data / prose / headings)
parse_page <- function(p, ytol = 3, tol = 4.5, tol2 = 8, first_page = FALSE) {
  p <- p %>% arrange(y, x)
  raw <- words_to_lines(p, ytol)
  ymin <- min(p$y)
  raw$kind <- "tabular"
  raw$kind[raw$y <= ymin + 14] <- "header"
  ## the first page of an order slice has no running header: its top line is the chapter heading. For a monotypic
  ## order that heading is the family heading itself ('Order Scandentia, Family Tupaiidae'; 'Order Pholidota, Family
  ## Manidae, Genus Manis') and must not be taken for a running header
  if(first_page) raw$kind[raw$kind == "header" & str_detect(raw$line, family_heading_re)] <- "family_heading"
  hb <- raw$kind == "header"
  ## monotypic families print the heading with a genus suffix ('Order Carnivora, Family Protelidae, Genus Proteles')
  raw$kind[!hb & str_detect(raw$line, family_heading_re)] <- "family_heading"
  raw$kind[!hb & str_detect(raw$line, "^Order [A-Z][a-z]+$")] <- "order_heading"
  ## left margin = where the species column starts. Normally the left-most body line; on a page without any
  ## species-column text (printed p. 334: Phoca vitulina continues from p. 333) the body minimum is the
  ## value column, so the running header's left edge (same margin) is used instead
  margin_body <- min(raw$x_min[raw$kind != "header"]); margin_hdr <- min(raw$x_min[raw$kind == "header"])
  margin <- if(is.finite(margin_hdr) && margin_body > margin_hdr + 60) margin_hdr else margin_body
  margin_from_header <- margin != margin_body
  ## on a right-hand page the running header is right-aligned and cannot supply the margin; when the body's left-most
  ## text starts beyond x 150 the page has no species-column text at all (Cervidae p. 408: Cervus elaphus continues from
  ## p. 407) and the body minimum is the value column -- the margin is then set a nominal 165 pt to its left
  if(!margin_from_header && margin_body > 150) { margin <- margin_body - 165; margin_from_header <- TRUE }
  ## prose: starts at the margin, spans the page, no wide inter-word gap (data lines have the
  ## species->value or value->reference gap); a short last line of a paragraph follows a prose line
  ## a long species name can fill the species column so that a data line has no wide gap ('Prometheomys
  ## schaposchnikowi 2.7 emb, ps; r1-4; n6 lt 10275', Arvicolidae p. 585); a line that starts with a binomial and ends
  ## with a bare reference-number token is tabular whatever its gaps
  data_shape <- str_detect(raw$line, "^[A-Z][a-z]+ [a-z]+ .*\\s\\d{1,5}[a-z]?$") | (str_detect(raw$line, "^[A-Z][a-z]+ [a-z]+ \\d") & raw$x_max < 450)
  raw$kind[raw$kind == "tabular" & raw$x_min < margin + 40 & raw$max_gap < 25 & (raw$x_max - raw$x_min) > 250 & !data_shape] <- "prose"
  ## a prose line with a wide OCR gap inside the sentence (Echimyidae p. 673) is tabular by the gap rule; when the lines
  ## directly above and below it are prose and it runs to the right margin, it is prose
  if(nrow(raw) > 2) for(i in 2:(nrow(raw) - 1)) if(raw$kind[i] == "tabular" && raw$kind[i-1] == "prose" && raw$kind[i+1] == "prose" && raw$x_max[i] > 540) raw$kind[i] <- "prose"
  ## a family without tabular data prints one centred sentence instead of the topics (Notoryctidae p. 30: 'There are
  ## no tabular data for Notoryctes.'); it is prose, not a value line
  raw$kind[raw$kind == "tabular" & str_detect(raw$line, "^There are no tabular data")] <- "prose"
  ## (a paragraph's short last line follows a prose line at the margin; but a line that ends with a reference-number
  ## token beyond a wide gap is a data line or a topic heading sharing its y with a reference -- 'NEONATAL MASS 12032',
  ## Tapiridae p. 368 -- and stays tabular)
  for(i in seq_len(nrow(raw))[-1]) if(raw$kind[i] == "tabular" && raw$kind[i-1] == "prose" && raw$x_min[i] < margin + 40 &&
                                     !str_detect(raw$line[i], species_re) && !str_detect(raw$line[i], topic_re) &&
                                     !(raw$max_gap[i] >= 25 && str_detect(raw$line[i], "\\s\\d{1,5}[a-z]?,?$"))) raw$kind[i] <- "prose"
  w <- p; grp <- cumsum(c(TRUE, diff(w$y) > ytol)); w$kind <- raw$kind[grp]
  header <- paste(raw$line[raw$kind == "header"], collapse = " ")
  tab <- w %>% filter(kind == "tabular")
  rt <- tab %>% filter(x >= 380, str_detect(text, num_tok_re))
  ref_x <- if(nrow(rt) >= 3) as.numeric(quantile(rt$x, 0.05)) else NA   # 5th pct: the column drifts ~15 pt down a rotated page
  ## values that end in numbers and run close to the reference column ('n595 cycles, 28 f', Cercopithecidae
  ## CYCLE LENGTH pp. 208-210) pull that anchor left; reference numbers are always the last word of their raw
  ## line, so when the anchor from line-final tokens sits clearly to the right, it is used instead
  tabL <- tab %>% group_by(g = cumsum(c(TRUE, diff(y) > ytol))) %>% mutate(is_last = x == max(x)) %>% ungroup()
  rtL <- tabL %>% filter(is_last, x >= 380, str_detect(text, num_tok_re))
  ref_x_final <- if(nrow(rtL) >= 3) as.numeric(quantile(rtL$x, 0.05)) else NA
  ref_x_realigned <- FALSE
  if(!is.na(ref_x) && !is.na(ref_x_final) && ref_x < ref_x_final - 6) { ref_x <- ref_x_final; ref_x_realigned <- TRUE }
  if(is.na(ref_x)) {
    ev <- raw %>% filter(kind %in% c("prose", "family_heading", "order_heading")) %>% transmute(y, type = kind, text = line)
    return(list(raw = raw, ev = ev, header = header, ref_x = NA, val_x = NA, dR = NA, dS = NA, nV = 0L, nR = 0L, nS_text = 0L,
                S_unmatched = tibble(), R_unmatched = tibble(), tab_leftover = tab, margin_from_header = margin_from_header, ref_x_realigned = FALSE, R_cont_suspect = tibble(), n_second = 0L))
  }
  tab$col <- ifelse(tab$x >= ref_x - 4, "R", NA)
  mid <- tab %>% filter(is.na(col), x > margin + 110) %>% arrange(y, x)
  mg <- cumsum(c(TRUE, diff(mid$y) > ytol)); firsts <- tapply(mid$x, mg, min)
  val_x <- as.numeric(quantile(firsts, 0.05))
  tab$col[is.na(tab$col)] <- ifelse(tab$x[is.na(tab$col)] >= val_x - 12, "V", "S")
  V <- words_to_lines(tab %>% filter(col == "V") %>% select(-col), ytol)
  R <- words_to_lines(tab %>% filter(col == "R") %>% select(-col), ytol)
  S <- words_to_lines(tab %>% filter(col == "S") %>% select(-col), ytol)
  ## reference offset anchored on the first value / first reference line of the page (a
  ## reference list never precedes its value line), refined only if implausible
  dR <- R$y[1] - V$y[1]; if(abs(dR) > 9) dR <- best_offset(V$y, R$y)
  ## a species name printed over two lines ('Epomophorus crypturus' / 'or Epomophorus gambianus', Pteropodidae p. 85):
  ## the second line starts with 'or' and carries the value; the two are joined at the second line's y
  if(nrow(S) > 1) for(k in which(str_detect(S$line, "^or [A-Z]"))) if(k > 1 && S$y[k] - S$y[k-1] <= 1.6 * LINE_PITCH && str_detect(S$line[k-1], "^[A-Z][a-z]+ [a-z]+$")) {
    S$line[k] <- paste(S$line[k-1], S$line[k]); S$line[k-1] <- NA_character_ }
  if(nrow(S) && any(is.na(S$line))) S <- S[!is.na(S$line), ]
  S$is_topic <- str_detect(S$line, topic_re)
  dS <- best_offset(S$y[!S$is_topic], V$y)
  V$ref_line <- NA_character_; V$ref_idx <- dp_align(V$y, R$y, dR, tolmax = tol2); R$used <- seq_len(nrow(R)) %in% V$ref_idx
  V$ref_line[!is.na(V$ref_idx)] <- R$line[V$ref_idx[!is.na(V$ref_idx)]]
  ## pairs more than `tol` apart (the greedy nearest-y rule of the first build would have missed them) are counted
  n_second <- sum(abs(R$y[V$ref_idx[!is.na(V$ref_idx)]] - (V$y[!is.na(V$ref_idx)] + dR)) > tol)
  ## a reference line with no value line = continuation of the preceding reference list. The book ends a
  ## wrapped list's first line with a comma; a continuation after a line WITHOUT a trailing comma is more
  ## likely the reference of a value the OCR dropped (a lone '1' is often absent from the text layer) and is
  ## reported as suspect (R_cont_suspect) so it can be checked on the page image and declared
  R_cont_suspect <- list()
  for(k in which(!R$used)) {
    yk <- R$y[k] - dR
    prev <- which(!is.na(V$ref_idx) & V$y < yk)
    if(length(prev)) { j <- max(prev); if(yk - V$y[j] <= 1.6 * LINE_PITCH) {
      if(!str_detect(V$ref_line[j], ",$")) R_cont_suspect[[length(R_cont_suspect)+1]] <- tibble(y = yk, value_line = V$line[j], ref_before = V$ref_line[j], ref_appended = R$line[k])
      V$ref_line[j] <- paste(V$ref_line[j], R$line[k]); R$used[k] <- TRUE } }
  }
  R_cont_suspect <- bind_rows(R_cont_suspect)
  ## a value line with no reference followed closely by one with a reference and no species = a wrapped value
  ## (a value line the book prints WITHOUT a reference -- Cricetidae p. 517 'Akodon longipilis 3.3 g' -- is not joined
  ## to the next line when that line has a species name of its own; it stays a line with no reference)
  V$has_species <- vapply(V$y, function(yv) any(!S$is_topic & abs(S$y + dS - yv) <= tol2), logical(1))
  V$wrapped <- FALSE
  i <- 1
  while(i < nrow(V)) {
    if(is.na(V$ref_idx[i]) && !is.na(V$ref_idx[i+1]) && (V$y[i+1] - V$y[i]) <= 1.6 * LINE_PITCH && !V$has_species[i+1]) {
      V$line[i+1] <- paste(V$line[i], V$line[i+1]); V$wrapped[i+1] <- TRUE; V$y[i+1] <- V$y[i]; V <- V[-i, ]
    } else i <- i + 1
  }
  S$v_idx <- NA_integer_
  ## species lines align to value lines in order too; most value lines have no species line (skipping one is cheap)
  S$v_idx[!S$is_topic] <- dp_align(S$y[!S$is_topic], V$y, dS, tolmax = tol2, ga = 6, gb = 0.5)
  n_second <- n_second + sum(abs(V$y[S$v_idx[!is.na(S$v_idx)]] - (S$y[!is.na(S$v_idx)] + dS)) > tol)
  V$species_line <- NA_character_
  V$species_line[S$v_idx[!is.na(S$v_idx)]] <- S$line[!is.na(S$v_idx)]
  ev <- bind_rows(S %>% filter(is_topic) %>% transmute(y = y + dS, type = "topic", text = line),
                  V %>% transmute(y, type = "data", text = line, species_line, ref_line, wrapped),
                  raw %>% filter(kind %in% c("prose", "family_heading", "order_heading")) %>% transmute(y, type = kind, text = line)) %>% arrange(y)
  list(raw = raw, ev = ev, header = header, ref_x = ref_x, val_x = val_x, dR = dR, dS = dS, nV = nrow(V), nR = nrow(R), nS_text = sum(!S$is_topic),
       S_unmatched = S %>% filter(!is_topic, is.na(v_idx)), R_unmatched = R %>% filter(!used), tab_leftover = tibble(),
       margin_from_header = margin_from_header, ref_x_realigned = ref_x_realigned, R_cont_suspect = R_cont_suspect, n_second = n_second)
}
DECLARED_PAGE_NUMBERS <- tribble(~section, ~slice_page, ~printed_page, ~reason,
  "Carnivora", 49L, 277L, "running header 'Order Carnivora, Family Mustelidae' present but the page number is missing from the OCR text layer; the page image shows 277",
  "Carnivora", 91L, 319L, "running header 'Order Carnivora, Family Odobenidae, Genus Odobenus' present but the page number is missing from the OCR text layer; the page image shows 319",
  "Carnivora", 93L, 321L, "running header 'Order Carnivora, Family Phocidae' present but the page number is missing from the OCR text layer; the page image shows 321",
  "Primates",  54L, 227L, "running header 'Order Primates, Family Pongidae' present but the page number is missing from the OCR text layer; the page image shows 227",
  ## wave 3 (2026-10-24), header strips of the page images read
  "Insectivora",   7L,  59L, "running header 'Order Insectivora, Family Erinaceidae' present, page number missing from the text layer; the page image shows 59",
  "Artiodactyla", 32L, 408L, "running header 'Order Artiodactyla, Family Cervidae' present, page number missing from the text layer; the page image shows 408",
  "Rodentia",     76L, 537L, "running header 'Order Rodentia, Family Cricetidae' present, page number missing from the text layer; the page image shows 537",
  "Rodentia",    187L, 648L, "running header 'Order Rodentia, Family Gliridae' present, page number missing from the text layer; the page image shows 648")
printed_page_of <- function(header) { t <- str_extract_all(header, "\\b\\d{1,3}\\b")[[1]]; if(length(t)) as.integer(t[length(t)]) else NA_integer_ }

## ---- abbreviations (front matter, printed pp. 5-6) --------------------------------------------
cat("\n== abbreviations ==\n")
fm <- slice_pdf("FrontMatter")
fm_txt <- pdf_text(fm$file)
ab_pages <- which(str_detect(fm_txt, "^\\s*Abbreviations\\s*\\n") | str_detect(fm_txt, "^\\s*6\\s+Abbreviations"))
if(length(ab_pages) != 2) stop("Expected the two Abbreviations pages in the front matter, found slice pages: ", paste(ab_pages, collapse=","), call.=FALSE)
fm_wd <- pdf_data(fm$file, font_info = FALSE)
## OCR drops or mis-reads the statistical symbols; declared from the page image (printed p. 5)
SYMBOL_ROWS <- tribble(~meaning, ~abbrev,
  "approximately", "~", "less than", "<", "equal to or less than", "\u2264", "greater than", ">", "equal to or greater than", "\u2265", "unknown variance estimate", "\u00b1")
parse_abbrev_page <- function(p, slice_page) {
  p <- p %>% arrange(y, x)
  mid_x <- 300
  out <- list()
  for(side in c("L", "R")) {
    q <- if(side == "L") p %>% filter(x < mid_x) else p %>% filter(x >= mid_x)
    q <- q %>% filter(y > min(p$y) + 14 | slice_page == ab_pages[2])    # drop the page title on p. 5
    q <- q %>% filter(!(str_detect(text, "^\\d$") & y > 800))              # printed page number at the foot
    if(!nrow(q)) next
    x0 <- min(q$x)
    ## abbreviation column = words starting within 60 pt of the column's left edge
    q$part <- ifelse(q$x < x0 + 60, "abbr", "meaning")
    ln <- words_to_lines(q %>% select(-part), 4)
    grp <- cumsum(c(TRUE, diff(q$y) > 4))
    rows <- q %>% mutate(g = grp) %>% group_by(g) %>%
      summarise(abbrev = paste(text[part == "abbr"], collapse = " "), meaning = paste(text[part == "meaning"], collapse = " "), y = min(y), .groups = "drop") %>% arrange(y)
    out[[side]] <- rows %>% mutate(side = side)
  }
  bind_rows(out) %>% mutate(pdf_page = slice_page)
}
ab_raw <- bind_rows(lapply(ab_pages, function(i) parse_abbrev_page(fm_wd[[i]], i)))
## group headings are lines with an abbreviation-column text and no meaning (underlined on the page)
ab_raw <- ab_raw %>% mutate(is_group = meaning == "" & nzchar(abbrev) & !str_detect(abbrev, "^[A-Z]{2,4}$|^[a-z]{1,4}$") | abbrev %in% c("statistics", "seasonality", "months", "location"))
ab_raw <- ab_raw %>% group_by(pdf_page, side) %>% mutate(group = { g <- ifelse(is_group, abbrev, NA_character_); g <- zoo_na_locf <- Reduce(function(a, b) if(is.na(b)) a else b, g, accumulate = TRUE); g }) %>% ungroup()
abbr <- ab_raw %>% filter(!is_group, nzchar(meaning) | nzchar(abbrev)) %>% arrange(pdf_page, side, y)
## symbol rows: the OCR drops '~' entirely and reads the comparison symbols loosely; the abbreviation is
## taken from the declaration (page image) BEFORE wrapped meanings are joined, so 'approximately' is not
## mistaken for a wrapped second line
abbr$ocr_note <- NA_character_
for(k in seq_len(nrow(SYMBOL_ROWS))) {
  i <- which(abbr$meaning == SYMBOL_ROWS$meaning[k])
  if(length(i) != 1) stop("Abbreviations: symbol row '", SYMBOL_ROWS$meaning[k], "' not found exactly once", call.=FALSE)
  abbr$ocr_note[i] <- sprintf("abbreviation symbol read from the page image (OCR gave '%s')", abbr$abbrev[i]); abbr$abbrev[i] <- SYMBOL_ROWS$abbrev[k]
}
## letter confusions in the abbreviation column (page image checked): 'It' is printed 'lt'
OCR_ABBR_FIX <- tribble(~meaning, ~abbrev_ocr, ~abbrev, "litter", "It", "lt")
for(k in seq_len(nrow(OCR_ABBR_FIX))) {
  i <- which(abbr$meaning == OCR_ABBR_FIX$meaning[k] & abbr$abbrev == OCR_ABBR_FIX$abbrev_ocr[k])
  if(length(i) != 1) stop("Abbreviations: OCR-fix row '", OCR_ABBR_FIX$meaning[k], "' not found exactly once", call.=FALSE)
  abbr$ocr_note[i] <- sprintf("abbreviation read from the page image (OCR gave '%s')", abbr$abbrev[i]); abbr$abbrev[i] <- OCR_ABBR_FIX$abbrev[k]
}
## wrapped meanings (the USSR explanation) are lines with a meaning and no abbreviation: join to the previous row
j <- which(abbr$abbrev == "" & nzchar(abbr$meaning))
for(k in rev(j)) { abbr$meaning[k-1] <- paste(abbr$meaning[k-1], abbr$meaning[k]) }
if(length(j)) abbr <- abbr[-j, ]
abbr <- abbr %>% mutate(group = ifelse(is.na(group), "general", group), printed_page = ifelse(pdf_page == ab_pages[1], 5L, 6L)) %>%
  transmute(abbrev, meaning, group, pdf_page, printed_page, ocr_note)
if(any(!nzchar(abbr$abbrev))) stop("Abbreviations rows without an abbreviation: ", paste(abbr$meaning[!nzchar(abbr$abbrev)], collapse = " | "), call.=FALSE)
EXPECTED_ABBR <- c("n", "r", "emb", "yg", "lt", "f", "m", "ea", "d", "wk", "mo", "yr", "max", "min", "preg", "est", "sd", "se", "cl", "ps", "HB", "CR", "TL", "ibi", "lact", "repro", "~", "\u2264", "\u00b1")
miss_ab <- setdiff(EXPECTED_ABBR, abbr$abbrev)
if(length(miss_ab)) stop("Abbreviations missing expected members: ", paste(miss_ab, collapse = ","), call.=FALSE)
cat("abbreviation rows:", nrow(abbr), " groups:", paste(unique(abbr$group), collapse = "; "), "\n")
cat("  ('nl' in the OCR = n1, 'It' = lt, 'rl' = r1 -- handled in the value normalisation; 'mode', 'captive', 'zoo', 'wean' are used in the tables but are not in the printed list)\n")

## ---- value grammar ------------------------------------------------------------------------------
UNITS <- c("g", "kg", "mg", "d", "wk", "mo", "yr", "h", "mm", "cm", "%")
COUNT_WORDS <- c("emb", "yg", "cl", "lt", "ps", "blastocysts", "implantations", "ova", "ea", "wean", "weaned", "live", "alive")
normalise_value <- function(x) {
  x <- str_replace_all(x, "\u00ac", "-")
  x <- str_replace_all(x, "\\bIt\\b", "lt")                       # litter
  x <- str_replace_all(x, "\\bnl\\b", "n1")                        # n1
  x <- str_replace_all(x, "\\brl\\b", "r1")
  x <- str_replace_all(x, "\\b([rn])l(?=[\\d.-])", "\\11")         # rl71-175 -> r171-175
  x <- str_replace_all(x, "\\b(sd|se)l(?=[\\d.])", "\\11")         # sdl.25 -> sd1.25
  x <- str_replace_all(x, "\\bn([0-9IlO]+)\\b", function(m) { d <- str_sub(m, 2); paste0("n", chartr("IlO", "110", d)) })
  x <- str_replace_all(x, "\\b(\\d) (st|nd|rd|th)\\b", "\\1\\2")       # 1 st -> 1st
  x <- str_replace_all(x, "\\u2014", "-")                           # em dash
  x <- str_replace_all(x, "(^|; )\\(?\\u20ac(?=\\d)", "\\1r6")           # 'r600-1000' OCR'd '(\u20ac00-1000' (printed p. 377)
  x <- str_replace_all(x, "(^|; )\\((?=\\d+(\\.\\d+)?-\\d)", "\\1r")     # 'r21.9-25.5' OCR'd '(21.9-25.5'
  x <- str_replace_all(x, "^(f/m|m/f|f|m)[;,] ", "\\1: ")             # 'f; 41.2 g' -> 'f: 41.2 g'
  x <- str_replace_all(x, "(^|: )t: ", "\\1f: ")                     # 'f:' read as 't:' (the book has no label t; 7 lines, wave 2)
  x <- str_replace_all(x, "(^|; )1(\\d+(?:\\.\\d+)?)-(\\d+(?:\\.\\d+)?)(?=;|$)", function(m) {   # 'r270-290' read as '1270-290': the leading 1 is an r when the range is otherwise reversed
    mm <- str_match(m, "^(.*?)1(\\d+(?:\\.\\d+)?)-(\\d+(?:\\.\\d+)?)$"); ok <- !is.na(mm[, 1]) & suppressWarnings(as.numeric(paste0("1", mm[, 3])) > as.numeric(mm[, 4]) & as.numeric(mm[, 3]) <= as.numeric(mm[, 4])); ok[is.na(ok)] <- FALSE
    ifelse(ok, paste0(mm[, 2], "r", mm[, 3], "-", mm[, 4]), m) })
  x <- str_replace_all(x, "(^|; )i(?= [a-z])", "\\11")               # 'i yg' -> '1 yg'
  x <- str_replace_all(x, "\\bni\\b", "n1")                        # 'ni lt' -> 'n1 lt'
  x <- str_replace_all(x, "\\b(r\\d+) (?=[\\d.]\\d*)", "\\1")          # 'r1 33-140' -> 'r133-140'; 'r1 .09-1.70' -> 'r1.09-1.70'
  x <- str_replace_all(x, "\\b(n\\d+) (\\d+)(?= f\\b| lt\\b|$|;)", "\\1\\2")   # 'n1 1 f' -> 'n11 f'
  x <- str_replace_all(x, "(?<=\\d) -(?=\\d)", "-")                 # '1 -3' -> '1-3'
  x <- str_replace_all(x, "\\br([0-9IlO.]+)-([0-9IlO.]+)\\b", function(m) chartr("IlO", "110", m))   # rO-2 -> r0-2
  x <- str_replace_all(x, "(^|:\\s)-(?=\\d)", "\\1~")                  # the OCR renders the book's '~' as '-'
  x <- str_replace_all(x, "(?<=\\d)- (?=\\d)", "-")                # 2- 3 -> 2-3
  x <- str_replace_all(x, "(?<=[rn]\\d{0,4}) -(?=\\d)", "-")       # r1 -4 -> r1-4
  x <- str_replace_all(x, "(?<=\\d)-\\s+(?=\\d)", "-")
  str_squish(x)
}
num_re <- "\\d+(?:\\.\\d+)?"
parse_value <- function(v) {
  ## returns a one-row tibble of parsed fields for the normalised value text v
  out <- tibble(sex = NA_character_, value_label = NA_character_, approx = FALSE, comparator = NA_character_,
                value_type = "text", value_numeric = NA_real_, value_unit = NA_character_, range_low = NA_real_, range_high = NA_real_,
                n = NA_integer_, n_comparator = NA_character_, count_unit = NA_character_, sd = NA_real_, se = NA_real_, pm = NA_real_, mode = NA_character_,
                main_remainder = NA_character_, qualifiers_verbatim = NA_character_)
  segs <- str_squish(str_split(v, ";")[[1]])
  main <- segs[1]; quals <- segs[-1]
  ## prefixes: sex and/or label, in either order ("f: 1st mate: 6-9 mo", "TL: f: 71.9 mm", "HB: 24 cm")
  repeat {
    m <- str_match(main, "^(f/m|m/f|f|m):\\s*(.*)$")
    if(!is.na(m[1]) && is.na(out$sex)) { out$sex <- m[2]; main <- m[3]; next }
    m <- str_match(main, "^([A-Za-z0-9][A-Za-z0-9 /'.-]{0,40}?):\\s*(.*)$")
    if(!is.na(m[1]) && is.na(out$value_label) && !str_detect(m[2], "^(f/m|m/f|f|m)$")) { out$value_label <- str_squish(m[2]); main <- m[3]; next }
    break
  }
  if(str_detect(main, "^(~|-)(?=\\d|\\s?\\d)")) { out$approx <- TRUE; main <- str_squish(str_replace(main, "^(~|-)\\s*", "")) }
  if(str_detect(main, "^est\\b")) { out$approx <- TRUE; main <- str_squish(str_replace(main, "^est\\s*", "")) }
  m <- str_match(main, "^(<=|>=|<|>|\u2264|\u2265)\\s*(.*)$"); if(!is.na(m[1])) { out$comparator <- m[2]; main <- m[3] }
  kind <- "point"
  m <- str_match(main, "^(mode|max|min|median)\\s+(.*)$"); if(!is.na(m[1])) { kind <- m[2]; main <- m[3] }
  if(kind == "median" && str_detect(main, "^(~|est)\\b")) { out$approx <- TRUE; main <- str_squish(str_replace(main, "^(~|est)\\s*", "")) }   # 'median est 144 d', 'median ~1.5 yr' (primates)
  if(str_detect(main, paste0("^r", num_re))) { kind <- "range"; main <- str_replace(main, "^r", "") }
  rng <- str_match(main, paste0("^(", num_re, ")\\s*-\\s*(", num_re, ")\\b\\s*(.*)$"))
  pt  <- str_match(main, paste0("^(", num_re, ")(\\+)?(?![\\d.])\\s*(.*)$"))
  if(!is.na(rng[1])) {
    out$range_low <- as.numeric(rng[2]); out$range_high <- as.numeric(rng[3]); rest <- rng[4]
    out$value_type <- if(kind == "point") "range" else kind
  } else if(!is.na(pt[1])) {
    out$value_numeric <- as.numeric(pt[2]); rest <- pt[4]
    if(!is.na(pt[3])) out$comparator <- "+"
    out$value_type <- kind
  } else { rest <- main; out$value_type <- "text" }
  ## unit / count word directly after the number(s)
  toks <- str_split(str_squish(rest), "\\s+")[[1]]; toks <- toks[nzchar(toks)]
  if(length(toks) && toks[1] %in% UNITS) { out$value_unit <- toks[1]; toks <- toks[-1] }
  else if(length(toks) && str_detect(toks[1], "^[0-9.]+%$")) { out$value_unit <- "%"; }
  if(length(toks) && str_replace(toks[1], ",$", "") %in% COUNT_WORDS) { out$count_unit <- str_replace(toks[1], ",$", ""); toks <- toks[-1] }
  if(out$value_type != "text" && is.na(out$value_unit)) out$value_unit <- "count"
  if(length(toks)) out$main_remainder <- paste(toks, collapse = " ")
  ## qualifier segments
  for(q in quals) {
    m <- str_match(q, paste0("^r(", num_re, ")\\s*-\\s*(", num_re, ")\\b")); if(!is.na(m[1]) && is.na(out$range_low)) { out$range_low <- as.numeric(m[2]); out$range_high <- as.numeric(m[3]); next }
    m <- str_match(q, "^n(>|<|~)?(\\d+)\\b"); if(!is.na(m[1]) && is.na(out$n)) { out$n <- as.integer(m[3]); out$n_comparator <- m[2]; next }
    m <- str_match(q, paste0("^sd\\s?(", num_re, ")")); if(!is.na(m[1]) && is.na(out$sd)) { out$sd <- as.numeric(m[2]); next }
    m <- str_match(q, paste0("^se\\s?(", num_re, ")")); if(!is.na(m[1]) && is.na(out$se)) { out$se <- as.numeric(m[2]); next }
    m <- str_match(q, paste0("^\u00b1\\s?(", num_re, ")")); if(!is.na(m[1]) && is.na(out$pm)) { out$pm <- as.numeric(m[2]); next }
    m <- str_match(q, "^mode\\s+(\\S+)"); if(!is.na(m[1]) && is.na(out$mode)) { out$mode <- m[2]; next }
  }
  if(length(quals)) out$qualifiers_verbatim <- paste(quals, collapse = "; ")
  ## a single number with a dispersion or sample statistic is the book's "mean (numerical average) first" (printed p. 4)
  if(out$value_type == "point" && (!is.na(out$sd) || !is.na(out$se) || !is.na(out$pm) || (!is.na(out$n) && out$n > 1) || !is.na(out$range_low))) out$value_type <- "mean"
  out
}

## ---- population status ------------------------------------------------------------------------------
## (1) the line's own qualifiers; (2) the cited works' title/journal; (3) unspecified
BOOK_TOKENS <- c(captive = "captive_zoo", zoo = "captive_zoo", lab = "domestic_laboratory", domestic = "domestic_laboratory",
                 farm = "domestic_laboratory", `fur farm` = "domestic_laboratory", feral = "feral", wild = "wild")
KW <- list(
  domestic_strong  = c("ferret", "Frettchen", "furo", "UFAW", "Lab Anim", "miniature pig", "domestic", "Hausschwein", "swine"),
  domestic_animal  = c("sows?", "gilts?", "boars?", "pigs?"),
  domestic_journal = c("J Anim Sci", "Anim Prod", "Anim Reprod Sci", "Biol Reprod", "J Reprod Fert", "Theriogenology"),
  feral            = c("feral"),
  wild             = c("wild", "Wildschwein", "Sanglier", "jabal", "Schwarzwild", "Iltis", "polecat", "Mammals of", "J Mamm", "J Wildl Manage", "Mammalia", "Z Saugetierk", "Acta Theriol", "field"))
## stems matched as word prefixes so that inflected German/Spanish forms are caught (Wildlebenden,
## Schwarzwildes, Iltissen, Sangliers, and the OCR 'jabalf' for jabali); everything else whole-word
KW_PREFIX <- c("wild", "Wildschwein", "Sanglier", "jabal", "Schwarzwild", "Iltis", "polecat")
kw_hits <- function(txt, words) { h <- words[vapply(words, function(w) str_detect(txt, regex(paste0("\\b", w, if(w %in% KW_PREFIX) "" else "\\b"), ignore_case = TRUE)), logical(1))]; h }
## one reference -> list(status, keyword)
classify_ref <- function(ref_number) {
  r <- refs[match(ref_number, refs$ref_number), ]
  if(nrow(r) == 0 || is.na(r$ref_number)) return(list(status = NA_character_, kw = NA_character_))
  txt <- paste(coalesce(r$title, ""), coalesce(r$journal_or_publisher, ""), if(is.na(r$title)) coalesce(r$citation, "") else "")
  hf <- kw_hits(txt, KW$feral); hw <- kw_hits(txt, KW$wild)
  hs <- kw_hits(txt, KW$domestic_strong); ha <- kw_hits(txt, KW$domestic_animal); hj <- kw_hits(txt, KW$domestic_journal)
  if(length(hf)) return(list(status = "feral", kw = hf[1]))
  if(length(hw) && !length(hs)) return(list(status = "wild", kw = hw[1]))      # 'wild pig', 'wild boar': the modifier wins over the animal word
  if(length(hw) && length(hs)) return(list(status = "mixed:domestic_laboratory|wild", kw = paste0(hs[1], "+", hw[1])))
  if(length(hs) || length(ha) || length(hj)) return(list(status = "domestic_laboratory", kw = c(hs, ha, hj)[1]))
  list(status = NA_character_, kw = NA_character_)
}
population_status <- function(value_text, ref_numbers) {
  vt <- tolower(value_text)
  toks <- names(BOOK_TOKENS)[vapply(names(BOOK_TOKENS), function(t) str_detect(vt, paste0("\\b", t, "\\b")), logical(1))]
  if("fur farm" %in% toks) toks <- setdiff(toks, "farm")
  if(length(toks)) {
    st <- unique(unname(BOOK_TOKENS[toks]))
    status <- if(length(st) == 1) st else paste0("mixed:", paste(sort(st), collapse = "|"))
    return(list(status = status, basis = paste0("book_qualifier:", paste(toks, collapse = "|"))))
  }
  if(!length(ref_numbers) || all(is.na(ref_numbers))) return(list(status = "unspecified", basis = "none"))
  cl <- lapply(ref_numbers, classify_ref)
  st <- vapply(cl, `[[`, character(1), "status"); kw <- vapply(cl, `[[`, character(1), "kw")
  ok <- !is.na(st)
  if(!any(ok)) return(list(status = "unspecified", basis = "none"))
  u <- unique(unlist(str_split(str_replace(st[ok], "^mixed:", ""), "\\|")))
  status <- if(length(u) == 1) u else paste0("mixed:", paste(sort(u), collapse = "|"))
  list(status = status, basis = paste0("cited_work_title:", paste(unique(paste0(ref_numbers[ok], "=", kw[ok])), collapse = "|")))
}

## ---- species-name canonicalisation within a family ------------------------------------------------
## OCR confusions are glyph-shaped: l/t/i/1/I, rn/ru/m, ri/h, u/v, c/e/o, f/t. Two names are an OCR pair only
## when their keys are within edit distance 2 AND within distance 1 after collapsing confusable glyphs; this
## blocks real species pairs such as Canis rufus / Canis lupus and Panthera uncia / Panthera onca (both at
## distance 2) from being merged
glyph_key <- function(k) { k <- str_replace_all(k, "[uv]", "u"); k <- str_replace_all(k, "[lti1!If]", "l"); k <- str_replace_all(k, "[ceo]", "o"); k <- str_replace_all(k, "rn|ru", "m"); str_replace_all(k, "rl", "h") }
## declared OCR variants that no correctly printed name in the family can absorb (page images checked)
SPECIES_OCR_FIX <- tribble(~section, ~ocr, ~printed,
  "Carnivora", "Tremarctos omatus", "Tremarctos ornatus",
  "Carnivora", "Procyon cancrivoms", "Procyon cancrivorus",
  "Carnivora", "Paradoxums hermaphroditus", "Paradoxurus hermaphroditus",
  "Carnivora", "Paradoxums zeylonensis", "Paradoxurus zeylonensis",
  "Carnivora", "Osbomictis piscivora", "Osbornictis piscivora",
  "Carnivora", "Genetta servelina", "Genetta servalina",
  "Primates",  "Presbytis mbicunda", "Presbytis rubicunda",
  "Primates",  "Nasalis concotor", "Nasalis concolor",
  "Primates",  "Cercopithecus Ihoesti", "Cercopithecus lhoesti",
  "Primates",  "Alouatta pal Hat a", "Alouatta palliata",
  "Primates",  "Ateles belzebuthIA geoffroyi", "Ateles belzebuth/A geoffroyi",
  ## wave 3 (2026-10-24; page images checked)
  "Artiodactyla", "GazeIIa grand", "Gazella granti",            # Bovidae p. 422
  "Chiroptera",   "Nycticeiv.s humeralis", "Nycticeius humeralis",   # Vespertilionidae p. 151
  "Rodentia",     "lomys horsfieldii", "Iomys horsfieldii",      # Sciuridae pp. 469, 489
  "Rodentia",     "Neotoma Stephens'i", "Neotoma stephensi",     # Cricetidae p. 529 (OCR "Stephens'!", the '!' already read as i)
  "Rodentia",     "Oryzomys palustn's", "Oryzomys palustris",    # Cricetidae p. 548
  "Chiroptera",   "Nyctinomops aun'spinosus", "Nyctinomops aurispinosus",   # Molossidae p. 168 ('ri' read as n')
  "Chiroptera",   "Pipistrellus kuhtii", "Pipistrellus kuhlii")           # Vespertilionidae (l read as t on the more frequent lines; p. 147 image reads kuhlii)
SPECIES_OCR_FIX$applied <- 0L
canon_species <- function(names_vec) {
  if(!length(names_vec)) return(setNames(character(0), character(0)))   # a family without data lines (resolve_species() rejects an empty vector)
  tab <- table(names_vec); nm <- names(tab)
  hub_ok <- !resolve_species(nm, source_publication = paper)$unresolved
  ## between two unresolved spellings the canonical one is, in order: the spelling whose genus is shared with another
  ## species of the family (Tylonycteris robustula supports Tylonycteris over the OCR 'Tylonyctehs'), the spelling whose
  ## words are plain letters (no space inside an epithet, 'nanulus' over 'nan ulus'), then the more frequent one
  genus <- str_extract(nm, "^[A-Z][a-z]+"); genus_support <- vapply(seq_along(nm), function(i) sum(genus == genus[i] & str_remove(nm, "^\\S+ ") != str_remove(nm[i], "^\\S+ ")) > 0, logical(1))
  plain <- str_detect(nm, "^[A-Z][a-z]+ [a-z]+$")
  o <- order(-as.integer(hub_ok), -as.integer(genus_support), -as.integer(plain), -as.integer(tab), nm); nm <- nm[o]; freq <- as.integer(tab)[o]; hub_ok <- hub_ok[o]
  key <- tolower(gsub(" ", "", nm))
  canon <- setNames(nm, nm)
  for(i in seq_along(nm)[-1]) {
    dd <- adist(key[i], key[seq_len(i - 1)])[1, ]
    dg <- adist(glyph_key(key[i]), glyph_key(key[seq_len(i - 1)]))[1, ]
    cand <- which(dd <= 2 & dg <= 1)
    if(length(cand) > 1) cand <- cand[which.min(dd[cand])]
    if(length(cand) == 1 && !hub_ok[i]) canon[nm[i]] <- canon[nm[cand]]   # the earlier-ordered spelling is canonical
  }
  canon
}

## ---- declared OCR repairs of reference strings (page images checked) --------------------------------------
## key = section, printed page, species column as OCR'd (inherited), value text as OCR'd, reference string as OCR'd;
## the corrected string replaces ref_raw for tokenising; line_verbatim keeps the OCR text. Each row must apply.
REF_OCR_FIX <- tribble(~section, ~printed_page, ~value_raw, ~ref_raw_ocr, ~ref_raw_printed, ~reading,
  "Carnivora", 242L, "mate: Mar-Apr; captive", "7453, 7.", "7453, 7462, 10086, 10087", "text layer holds only '7453, 7.'; the page prints four numbers",
  "Carnivora", 243L, "birth: Apr-May; Wl", "521\u00b0", "5210", "final 0 read as a degree sign",
  "Carnivora", 246L, "estrus: Jan-May, peak Feb; captive", "831\u00b0", "8310", "final 0 read as a degree sign",
  "Carnivora", 254L, "birth: Jan; n32 It; PA", "205\u2019 206", "205, 206", "comma read as a quotation mark",
  "Carnivora", 256L, "2-4", "1 1 A701 U/ ^ 1", "10721", "number read as scattered junk",
  "Carnivora", 293L, "den emergence: 1 mo", "690/", "5907", "digits mis-read",
  "Carnivora", 303L, "f: 1st estrus: 21.8 mo; sd2.9; r17-28; n9", "11991i", "11991a", "suffix a read as i (the token 11991i in _cited_numbers_not_in_bibliography.csv is this OCR error, not a book gap)",
  "Carnivora", 303L, "f: 1st conceive: 26.3 mo; sd7.9; r13-38; n13", "11991;", "11991a", "suffix a read as ;",
  "Carnivora", 303L, "m: 25.5 mo; sd6.6; r16-38; n16", "11991!", "11991a", "suffix a read as !",
  "Primates",  175L, "59-62 d; n7 It", "115\u00b0. 8443, 8444", "1150, 8443, 8444", "final 0 read as a degree sign",
  "Primates",  177L, "i yg", "8435, 8438, ;", "8435, 8438, 8439", "third number read as ;",
  "Primates",  178L, "estrus: <24 h", "4/22", "4722", "7 read as /",
  ## one confusable digit, both numbers valid (found by the digit-plausibility report + page image)
  "Primates",  175L, "70 d", "6432", "8432", "8 read as 6 (6432 Lidicker 1976 is a house-mouse paper; 8432 Petter-Rousseaux 1964, lemurs)",
  "Primates",  175L, "84-89 d", "6435", "8435", "8 read as 6 (6435 Lidicker 1980, California vole; 8435 Petter et al. 1977, lemurs)",
  "Primates",  175L, "3 mo", "6451", "8451", "8 read as 6 (6451 Lincoln 1971, red deer; 8451 Petter-Rousseaux 1980, prosimians)",
  "Carnivora", 254L, "implant: Nov?; zoo", "2812", "2612", "6 read as 8 (2812 Duplaix 1980, giant river otter; 2612 under Ursus arctos)",
  "Carnivora", 246L, "mate: Dec-Jan; USSR", "486", "466", "6 read as 8 (486 Baevskii, blastocyst cytometry; 466 Avaliani 1965)",
  ## wave 3 (2026-10-24): token guard stops, each read from a 120-220 dpi band of the page image
  "Marsupialia",   31L, "56 d; n6 It, 1 f", "ay4b", "3946", "Peramelidae: number read as letters",
  "Marsupialia",   46L, "birth: yr rd; mainland, Australia", "9909, '", "9909, 9912", "Macropodidae: second number read as a quotation mark",
  "Marsupialia",   47L, "wean: -10 mo", "8700, 8704, 1", "8700, 8704, 8706", "Phascolarctidae: third number truncated to '1' (a valid token -- see the short-token report)",
  "Insectivora",   64L, "2 emb; nl f", "10154 \u2019", "10154", "Soricidae: speck after the number read as a quotation mark",
  "Chiroptera",    97L, "2; rl-2", "\u20197122", "7122", "Emballonuridae: speck before the number read as a quotation mark",
  "Chiroptera",   116L, "1 emb ea; n17 f", "5405c!", "5405d", "Phyllostomidae: suffix d read as c!",
  "Chiroptera",   141L, "1.27 emb; mode 1; rl-2; n15 f", "2197, 5405b.", "2197, 5405b_1", "Vespertilionidae: printed subscript 1 (5405b\u2081) read as a period",
  "Chiroptera",   149L, "2-2.5 mo", "436 A OC", "436", "Vespertilionidae: the page prints 436 alone; 'A OC' is scan noise",
  "Chiroptera",   159L, "preg f: May; n14; SD", "261 a", "261a", "Vespertilionidae: suffix separated by a space",
  "Chiroptera",   161L, "preg f: July; n2; MT", "5424.,", "5424_2", "Vespertilionidae: printed subscript 2 (5424\u2082) read as '.,'",
  "Proboscidea",  361L, "120 kg", "6290, i", "6290, 6292", "Elephantidae: second number read as i",
  "Lagomorpha",   696L, "conceive: Apr-July; Ml", "mi", "1111", "Leporidae: 1111 read as mi",
  "Lagomorpha",   698L, "repro: yr rd", "i 149", "1149", "Leporidae: first digit read as i and split",
  "Lagomorpha",   698L, "preg f: Mar-July; UT", "5254 a", "5254a", "Leporidae: suffix separated by a space",
  "Rodentia",     498L, "16.4 cm", "116/1", "11671", "Geomyidae: digits read as 116/1",
  "Rodentia",     653L, "17-22 d", "1871 a", "1871a", "Zapodidae: suffix separated by a space",
  "Rodentia",     653L, "1", "nyob", "11956", "Zapodidae: number read as letters",
  "Rodentia",     671L, "nurse: 7.7 wk; 95%ci 1.0", "3957, C", "3957, 3960", "Myocastoridae: second number read as C",
  "Rodentia",     653L, "independent: 2-3 mo", "18713", "1871a", "Zapodidae: suffix a read as 3 (18713 is beyond the bibliography)",
  "Marsupialia",   33L, "est 28 d", "1 1U", "7210", "Phalangeridae: number read as '1 1U'",
  "Chiroptera",   108L, "mate: Oct; Selangor, Malaysia", ".7161", "7161", "Rhinolophidae: speck before the number read as a period",
  "Rodentia",     513L, "-90 d", "2uoo", "2088", "Castoridae: digits read as letters",
  "Rodentia",     513L, "1", "1 \u00a3L\\JC-", "1202", "Castoridae LITTERS/YEAR: number read as junk",
  "Artiodactyla", 409L, "birth: peak May-June, some Oct-Nov; Rhum, Inner Hebrides, UK", "1920, 1924, 2151 6460, 6463", "1920, 1924, 2151, 2200, 6460, 6463", "Cervidae: the first line prints '1920, 1924, 2151, 2200,' (2200 lost by the OCR) and wraps to '6460, 6463'",
  "Rodentia",     523L, "5 ps; nl f", "5Q6", "596", "Cricetidae: 9 read as Q",
  "Rodentia",     537L, "3 emb; nl f", "2\u00ae1a", "261a", "Cricetidae (Reithrodontomys montanus): 6 read as a registered sign",
  "Rodentia",     537L, "~4; rl -9", "II 700", "11700", "Cricetidae: 11 read as II and split",
  "Rodentia",     539L, "9.04 emb; \u00b10.31; r3-14; n70 f", "7029, 1563b for range", "7029, 1563b", "Cricetidae (Sigmodon hispidus): NOT an OCR error -- the book prints 'for range' after 1563b in the reference column; the words stay in line_verbatim",
  "Rodentia",     552L, "solid food: 14 d", "8731 '", "8731", "Cricetidae: speck after the number",
  "Rodentia",     591L, "-21 d", "1 A7 A", "1474", "Arvicolidae (Pitymys ochrogaster): 1474 read as '1 A7 A'",
  "Rodentia",     591L, "24 d; mode 24; r24-25; n8", "C 580y QAA", "5809", "Arvicolidae (Pitymys pinetorum): 5809 read as junk",
  "Rodentia",     612L, "6.40; seO.159; mode 6; r3-10; n80 It", "8329, )", "8329, 8331", "Muridae (Apodemus microps): second number read as ')'",
  "Rodentia",     616L, "5-9 yg", "5424.", "5424_1", "Muridae (Micromys minutus): printed subscript 1 (5424\u2081) read as a period",
  "Rodentia",     628L, "f: vag pert: 13.1 wk; sd4.59; r7-23; n30", "5643. 5644", "5643, 5644", "Muridae (Pseudomys novaehollandiae): comma read as a period",
  "Chiroptera",    85L, "21.2 g; rl 9.8-22.3; n3 juveniles", "102ob", "10286", "Pteropodidae (Cynopterus sphinx): 86 read as ob",
  "Chiroptera",   167L, "1", "1 i QQ7 y o/", "1937", "Molossidae (Molossus ater): 1937 read as junk",
  "Artiodactyla", 408L, "mate: mid-end Oct; captive", "44S8", "4488", "Cervidae (Cervus dama): 8 read as S")
REF_OCR_FIX$applied <- 0L
## ---- declared value lines absent from the OCR text layer (page images checked) ------------------------------
## The text layer sometimes lacks a whole short value ('1', 'min 3 yr', 'den emergence: 3-4 wk') while the species
## name and the reference number of that printed line are present. The reference is then left without a value line
## (R_unmatched) or appended to the previous line's list (R_cont_suspect). Each row here is inserted as a data
## line at that position, with value_text read from the page image and the reference it left behind; species is
## NA when the line continues the species above. line_verbatim carries the marker VALUE_FROM_PAGE_IMAGE.
DECLARED_VALUE_LINES <- tribble(~section, ~printed_page, ~species, ~value, ~ref,
  "Carnivora", 240L, NA_character_, "den emergence: 3-4 wk", "747",
  "Carnivora", 314L, "Arctocephalus pusillus", "1", "1605",
  "Primates",  182L, "Lichanotus laniger", "1", "8444",
  "Primates",  182L, NA_character_, "1", "8432",
  "Primates",  182L, "Propithecus verreauxi", "1", "8445",
  "Primates",  224L, "Gorilla gorilla", "1", "9544",
  "Primates",  227L, NA_character_, "min 3 yr", "11176",
  ## wave 3 (2026-10-24; page images checked)
  "Chiroptera",    169L, "Tadarida aegyptiaca", "1", "5547",        # Molossidae LITTERS/YEAR
  "Tubulidentata", 376L, "Orycteropus afer", "1", "11253",          # LITTERS/YEAR
  "Artiodactyla",  388L, "Camelus bactrianus", "2 yr", "8798",      # Camelidae INTERLITTER INTERVAL
  "Chiroptera",     87L, NA_character_, "1", "6845")                # Pteropodidae LITTER SIZE, first line of the page (species inherited from p. 86)
DECLARED_VALUE_LINES$applied <- 0L
## wrapped reference lists whose first line's trailing comma the OCR lost (page images checked)
KNOWN_WRAPS <- tribble(~section, ~printed_page, ~ref_appended,
  "Carnivora", 258L, "7979",            # '1474, 2088, 5146, 6387,' / '7979'
  "Primates",  209L, "5310, 8976, 8977", # '2781, 2782, 2785, 2786,' / '5310, 8976, 8977'
  ## wave 3 (page images checked)
  "Chiroptera",  87L, "3922, 3927, 3931", # Pteropodidae '1 emb ea; n636 f': '3914, 3915, 3916, 3921' / '3922, 3927, 3931' (comma faint on the page)
  "Chiroptera",  89L, "3922",             # Pteropodidae '2': '3914, 3915, 3916, 3921,' / '3922'
  "Artiodactyla", 409L, "6460, 6463")    # Cervidae 'Rhum, Inner Hebrides, UK': '1920, 1924, 2151, 2200,' / '6460, 6463' (see REF_OCR_FIX)
VALUE_FROM_IMAGE_MARKER <- "[VALUE_FROM_PAGE_IMAGE: value absent from the OCR text layer, read from the page image]"
REF_FROM_IMAGE_MARKER <- "[REF_FROM_PAGE_IMAGE: reference number absent from the OCR text layer, read from the page image]"

## ---- transcribe one family --------------------------------------------------------------------------
## the word boxes and page parse of an order slice are shared by all its families (Rodentia: 218 pages, 46 families)
SLICE_CACHE <- new.env()
## the scan repeats the chapter-opening page of three orders (whole-book PDF pp. 16/17, 58/59, 64/65; see the README's
## page-offset note): the second copy is dropped after asserting that its text layer is identical to the first.
## Slice page numbers reported in the tables (pdf_page_in_slice) stay physical, i.e. count the dropped page.
DUPLICATE_SCAN_PAGES <- tribble(~section, ~slice_page,
  "Monotremata", 2L,
  "Edentata",    2L,
  "Insectivora", 2L)
## the order name printed in the body heading when it differs from the slice/contents name
ORDER_HEADING_VARIANT <- tribble(~section, ~printed,
  "Macroscelidea", "Macroscelidae")   # the book prints 'Order Macroscelidae, Family Macroscelididae' (TOC and heading)
## specks and stray marks on the scan that the OCR read as a word in the reference or value column (page images
## checked: nothing is printed there). Each row must match exactly one word box (same text, |y - y_pt| <= 4) on the
## physical slice page; the word is removed before the page is parsed.
NOISE_WORDS <- tribble(~section, ~slice_page, ~text, ~x_pt, ~y_pt, ~reading,
  "Marsupialia", 23L, "_",    462, 705, "p. 33: mark in the reference column level with the CYCLE LENGTH heading (nothing printed; it would be appended to the Wyulda squamicaudata '5097')",
  "Chiroptera",  24L, "noon", 462, 767, "p. 107: smudge in the reference column between 'Rhinolophus landeri ... 255' and 'R. megaphyllus ... 2830'",
  "Cetacea",      2L, "m-",   581, 284, "p. 336: mark at the right margin beside the Delphinidae heading",
  "Cetacea",      7L, "7",    211, 756, "p. 341: speck after 'Globicephala macrorhynchus 3 yr' (its value would otherwise be read as a wrapped '7 3-4 yr')",
  "Rodentia",    52L, "_",    468, 513, "p. 513: mark in the reference column level with the SEASONALITY heading (nothing printed; it would be appended to the Castor GESTATION '8050')",
  "Marsupialia",  4L, "\u2666", 136, 106, "p. 14: speck in the species column beside the Didelphidae '9.0; r8-10; n2 lt 2937' continuation line",
  "Artiodactyla", 65L, "\u2022", 39, 764, "p. 441: speck in the species column beside the Bovidae 'wean: 7 mo 10158' continuation line",
  "Rodentia",   151L, "1",     57,  99, "p. 612: speck (2 x 8 pt box) in the species column beside the Muridae '4; n3 lt 7168' / '5 yg; n1 f 7165' lines",
  "Rodentia",   170L, "\u2022", 185, 457, "p. 631: speck (1 x 7 pt box) between 'Hylomyscus alleni' and '25-33 d'")
NOISE_WORDS$applied <- 0L
## reference numbers printed on the page but absent from the OCR text layer (page images checked): a word box with the
## number is inserted at the reference column before the page is parsed, so the line aligns like any other; the row then
## carries REF_FROM_IMAGE_MARKER in line_verbatim (matched by printed page, value text and number; asserted exactly once)
DECLARED_REF_WORDS <- tribble(~section, ~slice_page, ~printed_page, ~value_raw, ~ref, ~x_pt, ~y_pt,
  "Marsupialia", 19L,  29L, "small juveniles: yr rd, peak May-Aug; TAS, Australia", "4130", 462, 732,   # Thylacinidae SEASONALITY
  "Cetacea",     12L, 346L, "82 kg", "7498c", 480, 418,                                                   # Physeteridae NEONATAL MASS, Kogia breviceps
  "Chiroptera",   2L,  85L, "HB: -70 mm; FA: 32.5 mm", "334", 470, 304)                                  # Pteropodidae NEONATAL SIZE, Epomophorus crypturus or E. gambianus
DECLARED_REF_WORDS$applied <- 0L
## species names printed on the page but absent from the OCR text layer (page image checked; Cervidae p. 408 prints
## 'Cervus duvauceli' and 'Cervus elaphus' in the species column and the text layer has no species-column word at all,
## so every line of the page would have been inherited by Cervus dama from p. 407): the words are inserted at the
## species column before the page is parsed; the row then carries SPECIES_FROM_IMAGE_MARKER (asserted exactly once)
DECLARED_SPECIES_WORDS <- tribble(~section, ~slice_page, ~printed_page, ~text, ~value_raw, ~x_pt, ~y_pt,
  "Artiodactyla", 32L, 408L, "Cervus duvauceli", "mate: peak Sept; Assam, India", 57, 188,
  "Artiodactyla", 32L, 408L, "Cervus elaphus",   "sperm: Sept-Mar; captive",      57, 329)
DECLARED_SPECIES_WORDS$applied <- 0L
SPECIES_FROM_IMAGE_MARKER <- "[SPECIES_FROM_PAGE_IMAGE: species name absent from the OCR text layer, read from the page image]"
## pages with >= 5 value lines and NO species-column text at all: either the species continues from the previous page
## (declared here after the page image was read) or the OCR dropped the names (Cervidae p. 408 -> DECLARED_SPECIES_WORDS);
## an undeclared such page stops the run
NO_SPECIES_TEXT_PAGES <- tribble(~section, ~slice_page, ~printed_page, ~reading,
  "Carnivora",     32L, 260L, "Procyonidae tail (Procyon lotor continues) above the Mustelidae heading; wave-2 page image check",
  "Carnivora",    106L, 334L, "Phoca vitulina continues from p. 333; wave-2 page image check",
  "Artiodactyla",  33L, 409L, "Cervus elaphus continues from p. 408 (SEASONALITY); page image read 2026-10-24",
  "Rodentia",      73L, 534L, "Cricetidae LITTER SIZE continuation (Peromyscus spp.); page image read 2026-10-24",
  "Rodentia",     143L, 604L, "Arvicolidae SEASONALITY continuation (Microtus pennsylvanicus); page image read 2026-10-24")
## a reference number the BOOK prints inside the value column (Phalangeridae p. 33: 'Trichosurus arnhemensis 1 10081',
## the reference column empty on that line; page image checked): the word box is moved to the reference column so the
## line parses as value '1', reference 10081. Each row must match exactly one word box.
DECLARED_WORD_MOVES <- tribble(~section, ~slice_page, ~text, ~x_pt, ~y_pt, ~new_x, ~reading,
  "Marsupialia", 23L, "10081", 208, 399, 461, "p. 33: the book sets the reference number beside the value '1' instead of in the reference column")
DECLARED_WORD_MOVES$applied <- 0L
## pages whose OCR text layer is unusable (a faint scan read as random glyphs; page image legible to the eye): the page's
## lines are kept verbatim in the unparsed table (kind page_ocr_unusable) and no row is built from it; the species in force
## is reset so that nothing is inherited across the gap (the following page is asserted to start with a printed species
## or a topic). topic_on_page is what the page image shows, asserted equal to the topic in force when the page is entered.
OCR_UNUSABLE_PAGES <- tribble(~section, ~slice_page, ~printed_page, ~family, ~topic_on_page,
  "Rodentia", 173L, 634L, "Muridae", "LACTATION")   # Micromys minutus .. Rattus norvegicus LACTATION lines; to be transcribed by hand from the page image
## running headers too damaged for the edit-distance match (page image checked)
DECLARED_HEADERS <- tribble(~section, ~slice_page, ~family, ~ocr,
  "Rodentia", 173L, "Muridae", "634 Oroer Rcvkaas. Familv Monoae")   # faint scan of printed p. 634 'Order Rodentia, Family Muridae'
load_slice <- function(ord) {
  if(!exists(ord, envir = SLICE_CACHE, inherits = FALSE)) {
    sl <- slice_pdf(ord)
    wd <- pdf_data(sl$file, font_info = FALSE)
    if(length(wd) != sl$n_pages) stop("pdf_data page count differs from the slice map for ", basename(sl$file), call.=FALSE)
    nw <- NOISE_WORDS %>% filter(section == ord)
    for(k in seq_len(nrow(nw))) {
      w <- wd[[nw$slice_page[k]]]; hit <- which(w$text == nw$text[k] & abs(w$y - nw$y_pt[k]) <= 4 & abs(w$x - nw$x_pt[k]) <= 10)
      if(length(hit) != 1) stop("Declared noise word '", nw$text[k], "' on ", ord, " slice page ", nw$slice_page[k], " matched ", length(hit), " word boxes (expected 1)", call.=FALSE)
      wd[[nw$slice_page[k]]] <- w[-hit, ]; NOISE_WORDS$applied[NOISE_WORDS$section == ord & NOISE_WORDS$slice_page == nw$slice_page[k] & NOISE_WORDS$text == nw$text[k]] <<- 1L
      cat(sprintf("noise word removed: %s slice page %d '%s' (%s)\n", ord, nw$slice_page[k], nw$text[k], nw$reading[k]))   ## CONVENTION-OK: declared, page image checked
    }
    mv <- DECLARED_WORD_MOVES %>% filter(section == ord)
    for(k in seq_len(nrow(mv))) {
      w <- wd[[mv$slice_page[k]]]; hit <- which(w$text == mv$text[k] & abs(w$y - mv$y_pt[k]) <= 4 & abs(w$x - mv$x_pt[k]) <= 10)
      if(length(hit) != 1) stop("Declared word move '", mv$text[k], "' on ", ord, " slice page ", mv$slice_page[k], " matched ", length(hit), " word boxes (expected 1)", call.=FALSE)
      w$x[hit] <- as.integer(mv$new_x[k]); wd[[mv$slice_page[k]]] <- w; DECLARED_WORD_MOVES$applied[DECLARED_WORD_MOVES$section == ord & DECLARED_WORD_MOVES$slice_page == mv$slice_page[k] & DECLARED_WORD_MOVES$text == mv$text[k]] <<- 1L
      cat(sprintf("word moved to the reference column: %s slice page %d '%s' (%s)\n", ord, mv$slice_page[k], mv$text[k], mv$reading[k]))   ## CONVENTION-OK: declared, page image checked
    }
    sw <- DECLARED_SPECIES_WORDS %>% filter(section == ord)
    for(k in seq_len(nrow(sw))) {
      w <- wd[[sw$slice_page[k]]]
      if(any(abs(w$y - sw$y_pt[k]) <= 4 & w$x < sw$x_pt[k] + 120)) stop("Declared species word '", sw$text[k], "' on ", ord, " slice page ", sw$slice_page[k], ": the text layer already has species-column text there", call.=FALSE)
      parts <- str_split(sw$text[k], " ")[[1]]; xs <- as.integer(sw$x_pt[k] + cumsum(c(0, 5.5 * nchar(parts[-length(parts)]) + 4)))
      wd[[sw$slice_page[k]]] <- bind_rows(w, tibble(width = as.integer(5 * nchar(parts)), height = 8L, x = xs, y = as.integer(sw$y_pt[k]), space = c(rep(TRUE, length(parts) - 1), FALSE), text = parts))
      cat(sprintf("species words inserted from the page image: %s slice page %d '%s' at y %d\n", ord, sw$slice_page[k], sw$text[k], as.integer(sw$y_pt[k])))   ## CONVENTION-OK: declared, page image checked
    }
    dw <- DECLARED_REF_WORDS %>% filter(section == ord)
    for(k in seq_len(nrow(dw))) {
      w <- wd[[dw$slice_page[k]]]
      if(any(abs(w$y - dw$y_pt[k]) <= 4 & w$x >= dw$x_pt[k] - 10)) stop("Declared reference word '", dw$ref[k], "' on ", ord, " slice page ", dw$slice_page[k], ": the text layer already has a word there", call.=FALSE)
      wd[[dw$slice_page[k]]] <- bind_rows(w, tibble(width = as.integer(5 * nchar(dw$ref[k])), height = 8L, x = as.integer(dw$x_pt[k]), y = as.integer(dw$y_pt[k]), space = FALSE, text = dw$ref[k]))
      cat(sprintf("reference word inserted from the page image: %s slice page %d '%s' at y %d\n", ord, dw$slice_page[k], dw$ref[k], as.integer(dw$y_pt[k])))   ## CONVENTION-OK: declared, page image checked
    }
    pages <- lapply(seq_along(wd), function(i) parse_page(wd[[i]], first_page = (i == 1L)))
    phys <- seq_along(pages)
    dup <- DUPLICATE_SCAN_PAGES$slice_page[DUPLICATE_SCAN_PAGES$section == ord]
    for(k in dup) {
      if(!identical(pages[[k]]$raw$line, pages[[k - 1]]$raw$line)) stop("Declared duplicate scan page ", k, " of ", ord, " is not identical to page ", k - 1, call.=FALSE)
      cat(sprintf("duplicate scan page dropped: %s slice page %d (text layer identical to page %d)\n", ord, k, k - 1))   ## CONVENTION-OK: declared, asserted identical
    }
    keep <- !(phys %in% dup); pages <- pages[keep]; phys <- phys[keep]
    assign(ord, list(sl = sl, pages = pages, phys = phys), envir = SLICE_CACHE)
  }
  get(ord, envir = SLICE_CACHE, inherits = FALSE)
}
transcribe_family <- function(spec) {
  fam <- spec$family; ord <- spec$order
  slc <- load_slice(ord); sl <- slc$sl; pages <- slc$pages; phys <- slc$phys
  ord_printed <- if(ord %in% ORDER_HEADING_VARIANT$section) ORDER_HEADING_VARIANT$printed[match(ord, ORDER_HEADING_VARIANT$section)] else ord
  cat(sprintf("\n== %s (%s) == slice %s\n", fam, ord, basename(sl$file)))
  ## family range from the body headings
  head_tbl <- bind_rows(lapply(seq_along(pages), function(i) { e <- pages[[i]]$ev; if(is.null(e) || !nrow(e)) return(NULL); e %>% filter(type == "family_heading") %>% mutate(page = i) }))
  if(nrow(head_tbl)) head_tbl <- head_tbl %>% mutate(family = heading_family(text, ord))
  if(nrow(head_tbl) && any(!str_detect(head_tbl$text, paste0("^Order ", ord_printed, ", ")))) stop("Family heading naming another order in slice ", ord, ": ", paste(head_tbl$text[!str_detect(head_tbl$text, paste0("^Order ", ord_printed, ", "))], collapse = " | "), call.=FALSE)
  this_h <- head_tbl %>% filter(family == fam)
  if(nrow(this_h) != 1) stop("Family heading 'Order ", ord, ", Family ", fam, "' found ", nrow(this_h), " times in the slice (expected once)", call.=FALSE)
  if(this_h$text != sprintf("Order %s, Family %s", ord_printed, fam)) cat(sprintf("family heading printed as '%s' (genus suffix and/or declared OCR variant)\n", this_h$text))   ## CONVENTION-OK: monotypic-family heading form / declared OCR fix
  start_page <- this_h$page; start_y <- this_h$y
  next_h <- head_tbl %>% filter(page > start_page | (page == start_page & y > start_y)) %>% arrange(page, y) %>% slice(1)
  if(nrow(next_h)) { end_page <- next_h$page; end_y <- next_h$y } else { end_page <- length(pages); end_y <- Inf }
  ## when the next family's heading is the first body line of its page, that page holds nothing of this family
  if(nrow(next_h) && !any(pages[[end_page]]$ev$y < end_y & pages[[end_page]]$ev$type != "family_heading")) { end_page <- end_page - 1L; end_y <- Inf }
  cat(sprintf("family heading on slice page %d (y %.0f); next family heading '%s' on slice page %d (y %.0f)\n", start_page, start_y, if(nrow(next_h)) next_h$text else "<none>", end_page, end_y))
  ## running headers: 'Order X, Family Y <page>'; OCR letter errors in Y ('Cercopitliecidae', 'Omithorhynchidae') are
  ## accepted within edit distance 2 and printed
  header_names <- function(h, name) { w <- str_match(h, "Family ([A-Za-z]+)")[, 2]; !is.na(w) && (w == name || adist(w, name)[1, 1] <= 2) }
  ## the last page carries the family in its running header, or the next family heading sits on it
  last_hdr <- pages[[end_page]]$header
  ## (a family that starts and ends on one page -- Hominidae on printed p. 228, the slice's last page -- is
  ## located by its own heading, asserted above; its running header names the preceding family)
  if(!(header_names(last_hdr, fam) || nrow(next_h) || end_page == start_page)) stop("Last page of ", fam, " carries neither the family in its running header nor the next family heading", call.=FALSE)
  dh <- DECLARED_HEADERS %>% filter(section == ord)
  if(end_page > start_page) for(i in (start_page + 1):end_page) {
    h <- pages[[i]]$header
    if(phys[i] %in% dh$slice_page) { j <- match(phys[i], dh$slice_page)
      if(h != dh$ocr[j]) stop("Declared running header for ", ord, " slice page ", phys[i], " reads '", h, "', not the declared OCR text", call.=FALSE)
      cat(sprintf("declared running header: %s slice page %d '%s' = Family %s (page image)\n", ord, phys[i], h, dh$family[j]))   ## CONVENTION-OK: declared
      h <- sprintf("Order %s, Family %s", ord, dh$family[j]) }
    if(!header_names(h, fam) && !(i == end_page && nrow(next_h) && header_names(h, next_h$family)))
      stop("Running header on slice page ", i, " does not name ", fam, ": '", h, "'", call.=FALSE)
    if(!str_detect(h, fam) && header_names(h, fam)) cat(sprintf("running header OCR variant accepted on slice page %d: '%s'\n", i, h))   ## CONVENTION-OK: edit-distance match printed for audit
  }
  ## printed pages: running header (last 1-3 digit token); the first slice page has none -> contents table
  printed <- vapply(seq_along(pages), function(i) printed_page_of(pages[[i]]$header), integer(1))
  if(is.na(printed[1])) printed[1] <- as.integer(sl$toc_printed_page)
  rng <- start_page:end_page
  ## pages whose number is absent from the OCR text layer are declared (page image checked)
  dp <- DECLARED_PAGE_NUMBERS %>% filter(section == ord) %>% mutate(slice_page = match(slice_page, phys))   # physical -> index
  for(k in seq_len(nrow(dp))) {
    if(!is.na(printed[dp$slice_page[k]])) stop("Declared page number for ", ord, " slice page ", phys[dp$slice_page[k]], " but the header reads ", printed[dp$slice_page[k]], " (remove the declaration)", call.=FALSE)
    printed[dp$slice_page[k]] <- dp$printed_page[k]
    cat(sprintf("declared printed page: %s slice page %d -> %d (%s)\n", ord, phys[dp$slice_page[k]], dp$printed_page[k], dp$reason[k]))
  }
  if(any(is.na(printed[rng]))) stop("Printed page not readable on slice page(s): ", paste(phys[rng[is.na(printed[rng])]], collapse=","), call.=FALSE)
  if(any(diff(printed[rng]) != 1)) stop("Printed pages not consecutive over the ", fam, " range: ", paste(printed[rng], collapse=","), call.=FALSE)

  ## declared value lines (see DECLARED_VALUE_LINES): locate the orphaned reference, insert the data event
  for(k in which(DECLARED_VALUE_LINES$section == ord & DECLARED_VALUE_LINES$printed_page %in% printed[rng])) {
    dv <- DECLARED_VALUE_LINES[k, ]; i <- rng[which(printed[rng] == dv$printed_page)]; pg <- pages[[i]]
    if(!"declared" %in% names(pg$ev)) pg$ev$declared <- FALSE
    ru <- which(pg$R_unmatched$line == dv$ref)
    if(length(ru) == 1) { y_ev <- pg$R_unmatched$y[ru] - pg$dR; pg$R_unmatched <- pg$R_unmatched[-ru, ]; how <- "orphaned reference line" }
    else {
      j <- which(pg$ev$type == "data" & str_detect(coalesce(pg$ev$ref_line, ""), paste0("[^,]\\s", dv$ref, "$")))   # appended without a comma = continuation, not a printed list
      if(length(j) != 1) stop("Declared value line (", ord, " p. ", dv$printed_page, ", ref ", dv$ref, ") not locatable: ", length(ru), " orphaned, ", length(j), " appended", call.=FALSE)
      pg$ev$ref_line[j] <- str_remove(pg$ev$ref_line[j], paste0("\\s", dv$ref, "$")); y_ev <- pg$ev$y[j] + LINE_PITCH; how <- "reference appended to the previous line"
      pg$R_cont_suspect <- pg$R_cont_suspect %>% filter(ref_appended != dv$ref)
    }
    if(!is.na(dv$species)) { su <- which(pg$S_unmatched$line == dv$species); if(length(su) != 1) stop("Declared value line species '", dv$species, "' not an unmatched species line on ", ord, " p. ", dv$printed_page, call.=FALSE); pg$S_unmatched <- pg$S_unmatched[-su, ] }
    pg$ev <- bind_rows(pg$ev, tibble(y = y_ev, type = "data", text = dv$value, species_line = dv$species, ref_line = dv$ref, wrapped = FALSE, declared = TRUE)) %>% arrange(y)
    pages[[i]] <- pg; DECLARED_VALUE_LINES$applied[k] <<- DECLARED_VALUE_LINES$applied[k] + 1L
    cat(sprintf("declared value line inserted on printed p. %d: '%s' | '%s' | %s (%s)\n", dv$printed_page, coalesce(dv$species, "<inherited>"), dv$value, dv$ref, how))   ## CONVENTION-OK: declared, page image checked
  }
  rows <- list(); unp <- list(); prose_lines <- list(); page_counts <- list(); suspects <- list()
  topic <- NA_character_; species <- NA_character_; topics_seen <- character(0)
  up <- OCR_UNUSABLE_PAGES %>% filter(section == ord)
  for(i in rng) {
    pg <- pages[[i]]
    e <- pg$ev
    if(phys[i] %in% up$slice_page) { u <- up[match(phys[i], up$slice_page), ]
      if(u$family != fam) stop("OCR-unusable page ", phys[i], " declared for ", u$family, " lies in the ", fam, " range", call.=FALSE)
      if(is.na(topic) || topic != u$topic_on_page) stop("OCR-unusable page ", phys[i], ": topic in force is '", topic, "', the page image shows ", u$topic_on_page, call.=FALSE)
      unp[[length(unp)+1]] <- pg$raw %>% filter(kind != "header") %>% transmute(family = fam, kind = "page_ocr_unusable", pdf_page_in_slice = phys[i], printed_page = printed[i], text = line)
      page_counts[[length(page_counts)+1]] <- tibble(pdf_page_in_slice = phys[i], printed_page = printed[i], n_data_rows = 0L, n_prose = 0L, nV = pg$nV, nR = pg$nR, dR = pg$dR, dS = pg$dS, ref_x = round(pg$ref_x), margin_hdr = pg$margin_from_header, ref_realigned = pg$ref_x_realigned, n_2nd_pass = pg$n_second)
      species <- NA_character_
      cat(sprintf("OCR-UNUSABLE PAGE skipped: printed p. %d (%d text-layer lines kept verbatim in the unparsed table; species reset)\n", printed[i], nrow(pg$raw) - sum(pg$raw$kind == "header")))   ## CONVENTION-OK: declared gap, reported
      next }
    if(pg$nV >= 5 && pg$nS_text == 0 && !(phys[i] %in% NO_SPECIES_TEXT_PAGES$slice_page[NO_SPECIES_TEXT_PAGES$section == ord]))
      stop("Printed p. ", printed[i], " (", fam, ") has value lines but no species-column text: check the page image -- declare it in NO_SPECIES_TEXT_PAGES (species continues) or add the dropped names to DECLARED_SPECIES_WORDS", call.=FALSE)
    if(pg$nV >= 5 && pg$nS_text == 0) cat(sprintf("declared no-species-text page: printed p. %d (%s)\n", printed[i], NO_SPECIES_TEXT_PAGES$reading[NO_SPECIES_TEXT_PAGES$section == ord & NO_SPECIES_TEXT_PAGES$slice_page == phys[i]]))   ## CONVENTION-OK: declared
    in_range <- rep(TRUE, nrow(e))
    if(i == start_page) in_range <- in_range & e$y > start_y
    if(i == end_page)   in_range <- in_range & e$y < end_y
    e_out <- e[!in_range & !(e$type == "family_heading" & e$y == start_y & i == start_page), ]
    if(nrow(e_out)) unp[[length(unp)+1]] <- e_out %>% transmute(family = fam, kind = paste0("outside_family_range:", ifelse(type == "family_heading", "heading", type)),
                                                              pdf_page_in_slice = phys[i], printed_page = printed[i], text = ifelse(type == "data", paste(coalesce(species_line, ""), text, coalesce(ref_line, "")), text))
    e <- e[in_range, ]
    ## column alignment leftovers inside the range
    if(nrow(pg$S_unmatched)) unp[[length(unp)+1]] <- pg$S_unmatched %>% filter(if(i == start_page) y > start_y else TRUE, if(i == end_page) y < end_y else TRUE) %>%
      transmute(family = fam, kind = "species_column_line_without_value_line", pdf_page_in_slice = phys[i], printed_page = printed[i], text = line)
    if(nrow(pg$R_unmatched)) unp[[length(unp)+1]] <- pg$R_unmatched %>% filter(if(i == start_page) y > start_y else TRUE, if(i == end_page) y < end_y else TRUE) %>%
      transmute(family = fam, kind = "reference_column_line_without_value_line", pdf_page_in_slice = phys[i], printed_page = printed[i], text = line)
    if(nrow(pg$R_cont_suspect)) { sus <- pg$R_cont_suspect %>% filter(if(i == start_page) y > start_y else TRUE, if(i == end_page) y < end_y else TRUE)
      if(nrow(sus)) suspects[[length(suspects)+1]] <- sus %>% transmute(family = fam, printed_page = printed[i], value_line, ref_before, ref_appended) }
    n_rows_page <- 0L
    for(k in seq_len(nrow(e))) {
      ty <- e$type[k]
      if(ty == "prose") { prose_lines[[length(prose_lines)+1]] <- tibble(page = i, printed = printed[i], y = e$y[k], text = e$text[k]); next }
      if(ty == "topic") { topic <- str_squish(str_remove(e$text[k], "['\u2019]$")); topics_seen <- union(topics_seen, topic); species <- NA_character_; next }
      if(ty %in% c("family_heading", "order_heading")) next
      ## a 'data' line met before the family's first topic that carries prose punctuation is a prose line the column
      ## split broke up (an OCR gap inside the sentence: Dasyuridae p. 19 '... 11912), 60-74 d (Dasycercus 3305,';
      ## Echimyidae p. 673 'Ovulation in Proechimys is induced (6650) and ...')
      if(is.na(topic)) { full <- str_squish(paste(coalesce(e$species_line[k], ""), e$text[k], coalesce(e$ref_line[k], "")))
        if(str_detect(full, "[()]|\\.$") || str_count(full, ";") >= 2 && is.na(e$species_line[k]) && str_detect(full, "^[A-Z][a-z]+ \\d")) { prose_lines[[length(prose_lines)+1]] <- tibble(page = i, printed = printed[i], y = e$y[k], text = full)
          cat(sprintf("prose-shaped line before the first topic read as prose (p. %d): %s\n", printed[i], substr(full, 1, 80))); next } }   ## CONVENTION-OK: printed for audit
      ## data line
      if(!is.na(e$species_line[k])) species <- str_squish(e$species_line[k])
      if(is.na(topic) || is.na(species)) {
        unp[[length(unp)+1]] <- tibble(family = fam, kind = ifelse(is.na(topic), "data_line_before_first_topic", "data_line_before_first_species_of_topic"),
                                       pdf_page_in_slice = phys[i], printed_page = printed[i], text = paste(coalesce(e$species_line[k], ""), e$text[k], coalesce(e$ref_line[k], "")))
        next
      }
      sw_hit <- which(DECLARED_SPECIES_WORDS$section == ord & DECLARED_SPECIES_WORDS$printed_page == printed[i] & DECLARED_SPECIES_WORDS$text == coalesce(e$species_line[k], "") & DECLARED_SPECIES_WORDS$value_raw == e$text[k])
      if(length(sw_hit)) DECLARED_SPECIES_WORDS$applied[sw_hit] <<- DECLARED_SPECIES_WORDS$applied[sw_hit] + 1L
      rows[[length(rows)+1]] <- tibble(family = fam, topic = topic, species_binomial_printed = species, value_raw = e$text[k], ref_raw = e$ref_line[k], declared_species = length(sw_hit) > 0,
                                       wrapped = e$wrapped[k], pdf_page_in_slice = phys[i], printed_page = printed[i], declared = if("declared" %in% names(e)) coalesce(e$declared[k], FALSE) else FALSE)
      n_rows_page <- n_rows_page + 1L
    }
    page_counts[[length(page_counts)+1]] <- tibble(pdf_page_in_slice = phys[i], printed_page = printed[i], n_data_rows = n_rows_page, n_prose = sum(e$type == "prose"),
                                                   nV = pg$nV, nR = pg$nR, dR = pg$dR, dS = pg$dS, ref_x = round(pg$ref_x), margin_hdr = pg$margin_from_header, ref_realigned = pg$ref_x_realigned, n_2nd_pass = pg$n_second)
  }
  rows <- bind_rows(rows); unp <- bind_rows(unp); prose <- bind_rows(prose_lines); page_counts <- bind_rows(page_counts)
  if(nrow(rows)) { rows$declared_ref <- FALSE
    for(k in which(DECLARED_REF_WORDS$section == ord & DECLARED_REF_WORDS$printed_page %in% printed[rng])) { dr <- DECLARED_REF_WORDS[k, ]
      hit <- which(rows$printed_page == dr$printed_page & rows$value_raw == dr$value_raw & !is.na(rows$ref_raw) & rows$ref_raw == dr$ref)
      if(length(hit) == 1) { rows$declared_ref[hit] <- TRUE; DECLARED_REF_WORDS$applied[k] <<- DECLARED_REF_WORDS$applied[k] + 1L } }
  }
  ## a family whose account has no tabular data (Notoryctidae p. 30, Myzopodidae p. 137) yields family_overview rows only
  if(!nrow(rows)) { cat("no data lines in ", fam, " (family_overview rows only)\n", sep = "")
    rows <- tibble(family = character(0), topic = character(0), species_binomial_printed = character(0), value_raw = character(0), ref_raw = character(0),
                   wrapped = logical(0), pdf_page_in_slice = integer(0), printed_page = integer(0), declared = logical(0), declared_ref = logical(0), declared_species = logical(0)) }
  cat("pages in range:", length(rng), " printed", printed[start_page], "-", printed[end_page], "\n")
  print(as.data.frame(page_counts), row.names = FALSE)
  if(any(page_counts$n_data_rows + page_counts$n_prose == 0 & !(page_counts$pdf_page_in_slice %in% up$slice_page))) stop("Page(s) in the ", fam, " range yielded no rows: ", paste(page_counts$pdf_page_in_slice[page_counts$n_data_rows + page_counts$n_prose == 0], collapse=","), call.=FALSE)
  cat("topics seen (in order):", paste(topics_seen, collapse = " | "), "\n")
  suspects <- bind_rows(suspects)
  if(nrow(suspects)) suspects <- suspects %>% left_join(KNOWN_WRAPS %>% filter(section == ord) %>% transmute(printed_page, ref_appended, known_wrap = TRUE), by = c("printed_page", "ref_appended")) %>% mutate(known_wrap = coalesce(known_wrap, FALSE))
  cat("reference continuations after a line without a trailing comma (suspect dropped value):", nrow(suspects), "; declared genuine wraps:", if(nrow(suspects)) sum(suspects$known_wrap) else 0L, "\n")
  if(nrow(suspects)) print(as.data.frame(suspects %>% select(-family)), row.names = FALSE)
  if(nrow(suspects) && any(!suspects$known_wrap)) stop("Unexplained reference continuation(s) in ", fam, " -- check the page image: a dropped value line (declare in DECLARED_VALUE_LINES) or a wrapped list whose comma the OCR lost (declare in KNOWN_WRAPS)", call.=FALSE)

  ## ---- family overview: parenthesised reference groups in the prose -----------------------------
  prose_txt <- prose %>% arrange(page, y) %>% pull(text) %>% str_replace_all("\u00ac", "-") %>% paste(collapse = " ") %>% str_squish()
  groups <- str_match_all(prose_txt, "\\(([^()]*\\d[^()]*)\\)")[[1]]
  pos <- str_locate_all(prose_txt, "\\(([^()]*\\d[^()]*)\\)")[[1]]
  ov <- list()
  prev_end <- 1
  for(g in seq_len(nrow(groups))) {
    inner <- groups[g, 2]
    clause <- str_squish(str_sub(prose_txt, prev_end, pos[g, 1] - 1)); prev_end <- pos[g, 2] + 1
    clause <- str_replace(clause, "^[,.;]\\s*", "")
    segs <- str_squish(str_split(inner, ";")[[1]])
    for(s in segs) {
      cf <- str_detect(s, "^cf\\b"); s2 <- str_replace(s, "^cf\\s*", "")
      gen <- str_match(s2, "^([A-Z][a-z]+)\\s+(.*)$")
      genus_g <- NA_character_; nums_txt <- s2
      if(!is.na(gen[1]) && str_detect(gen[3], "^\\d")) { genus_g <- gen[2]; nums_txt <- gen[3] }
      toks <- str_squish(str_split(nums_txt, ",")[[1]]); toks <- toks[nzchar(toks)]
      if(!length(toks) || !all(str_detect(toks, "^\\d{1,5}[a-z]?$"))) next     # a mass range such as 'Sus 3-350 kg', not a reference list
      ov[[length(ov)+1]] <- tibble(family = fam, topic = "family_overview", species_binomial_printed = NA_character_, genus_overview = genus_g,
                                   value_raw = paste0(if(nchar(clause) > 160) paste0("...", str_sub(clause, -157)) else clause, if(cf) " [cf]" else ""),
                                   ref_raw = paste(toks, collapse = ", "), wrapped = FALSE,
                                   pdf_page_in_slice = phys[prose$page[1]], printed_page = prose$printed[1], line_verbatim_override = paste0(clause, " (", inner, ")"))
    }
  }
  ov <- bind_rows(ov)
  cat("family prose lines:", nrow(prose), " parenthesised reference groups:", nrow(groups), " overview rows (genus segments):", nrow(ov), "\n")
  list(rows = rows, overview = ov, unparsed = unp, page_counts = page_counts, topics = topics_seen, slice = sl, start_page = start_page, end_page = end_page, phys = phys, printed = printed, order = ord)
}

## ---- run all families ----------------------------------------------------------------------------------
## in DEV mode a family that stops is recorded (DEV_ERRORS) and the run continues with the next one
DEV_ERRORS <- list()
dev_try <- function(fam, expr) {
  if(!nzchar(DEV)) return(expr)
  tryCatch(expr, error = function(e) { DEV_ERRORS[[fam]] <<- conditionMessage(e); cat("DEV ERROR in ", fam, ": ", conditionMessage(e), "\n", sep = ""); NULL })
}
res <- lapply(seq_len(nrow(FAMILY_SPECS)), function(k) dev_try(FAMILY_SPECS$family[k], transcribe_family(FAMILY_SPECS[k, ])))
names(res) <- FAMILY_SPECS$family
res <- res[!vapply(res, is.null, logical(1))]

## ---- assemble, parse values, references, species, status --------------------------------------------------
build_table <- function(r) {
  fam <- r$rows$family[1]
  d <- bind_rows(r$rows %>% mutate(genus_overview = NA_character_, line_verbatim_override = NA_character_), r$overview %>% mutate(declared = FALSE, declared_ref = FALSE, declared_species = FALSE)) %>%
    mutate(order = r$order,
           slice_file = basename(r$slice$file),
           pdf_page_in_book = r$slice$pdf_page_start + pdf_page_in_slice - 1L,
           line_verbatim = coalesce(line_verbatim_override, str_squish(paste(coalesce(species_binomial_printed, ""), value_raw, coalesce(ref_raw, ""), ifelse(declared, VALUE_FROM_IMAGE_MARKER, ""), ifelse(declared_ref, REF_FROM_IMAGE_MARKER, ""), ifelse(declared_species, SPECIES_FROM_IMAGE_MARKER, "")))),
           value_text = str_squish(str_replace_all(value_raw, "\u00ac", "-")),
           value_normalised = normalise_value(value_raw))
  ## species
  ## OCR variants of a species name ('Sus scrota', 'Maries americana', 'Metes metes', 'Mu stela ...') are mapped to
  ## the canonical spelling within the family: names within edit distance 2 (spaces and case ignored) of a
  ## name that resolves in the species key or is printed more often; the as-printed text stays in
  ## species_binomial_printed and the mapping is printed for audit
  raw_sp <- ifelse(d$topic == "family_overview", NA_character_, str_squish(str_remove_all(d$species_binomial_printed, "\\?")))   # '?' after the name or after the genus
  ## a genus split by an OCR space ('Mu stela nigripes'): three words with a short first word -> join the first two
  raw_sp <- vapply(raw_sp, function(m) { if(is.na(m)) return(NA_character_); w <- str_split(m, " ")[[1]]; if(length(w) == 3 && nchar(w[1]) <= 3) paste0(w[1], w[2], " ", w[3]) else m }, character(1), USE.NAMES = FALSE)
  ## systematic OCR confusions inside epithets: 'rv' read as 'n/' (sen/al, lan/ata, pan/ula, sen/elina), 'i' as '!'
  ## (sen!cuius); the key is then within edit distance 2 of the correctly printed name
  raw_sp <- str_replace_all(raw_sp, "n/", "rv"); raw_sp <- str_replace_all(raw_sp, "!", "i")
  for(k in which(SPECIES_OCR_FIX$section == d$order[1])) { hit <- which(raw_sp == SPECIES_OCR_FIX$ocr[k]); if(length(hit)) { raw_sp[hit] <- SPECIES_OCR_FIX$printed[k]; SPECIES_OCR_FIX$applied[k] <<- SPECIES_OCR_FIX$applied[k] + length(hit) } }
  ## the species guard runs on the name after the systematic and declared OCR repairs (a declared variant such as
  ## 'lomys horsfieldii' = Iomys is not a binomial before its repair)
  sp_ok <- !is.na(raw_sp)
  if(any(sp_ok & !str_detect(raw_sp, species_re))) {
    bad <- unique(d$species_binomial_printed[sp_ok & !str_detect(raw_sp, species_re)])
    stop("Species-column text that is not a binomial in ", fam, ": ", paste(bad, collapse = " | "), call.=FALSE)
  }
  canon <- canon_species(raw_sp[!is.na(raw_sp)])
  d$species_printed <- ifelse(is.na(raw_sp), NA_character_, unname(canon[raw_sp]))
  d$species_ocr_corrected <- !is.na(raw_sp) & d$species_printed != raw_sp
  mp <- unique(tibble(printed = raw_sp, canonical = d$species_printed)[d$species_ocr_corrected, ])
  cat(sprintf("%s: species OCR variants mapped: %d (%s)\n", fam, nrow(mp), paste(sprintf("%s -> %s", mp$printed, mp$canonical), collapse = "; ")))
  d$genus <- ifelse(d$topic == "family_overview", d$genus_overview, str_extract(d$species_printed, "^[A-Z][a-z]+"))
  rs <- resolve_species(ifelse(is.na(d$species_printed), "", d$species_printed), source_publication = paper)
  d$species_msw05 <- ifelse(rs$unresolved | is.na(d$species_printed), NA_character_, rs$accepted_name)
  d$species_basis <- ifelse(is.na(d$species_printed), NA_character_, ifelse(rs$unresolved, "unresolved", paste0(rs$match_level, ":", rs$species_basis)))
  ## values
  pv <- bind_rows(lapply(seq_len(nrow(d)), function(i) if(d$topic[i] == "family_overview") parse_value("")[0, ] %>% add_row() else parse_value(d$value_normalised[i])))
  d <- bind_cols(d, pv)
  d$value_type[d$topic == "family_overview"] <- "text"
  d$qualifiers_verbatim[d$topic == "family_overview"] <- NA_character_
  ## references (declared OCR repairs first)
  for(k in which(REF_OCR_FIX$section == d$order[1])) {
    hit <- which(d$printed_page == REF_OCR_FIX$printed_page[k] & d$value_raw == REF_OCR_FIX$value_raw[k] & !is.na(d$ref_raw) & d$ref_raw == REF_OCR_FIX$ref_raw_ocr[k])
    if(length(hit)) { d$ref_raw[hit] <- REF_OCR_FIX$ref_raw_printed[k]; REF_OCR_FIX$applied[k] <<- REF_OCR_FIX$applied[k] + length(hit)
      cat(sprintf("%s: reference string repaired on printed p. %d: '%s' -> '%s' (%s)\n", fam, REF_OCR_FIX$printed_page[k], REF_OCR_FIX$ref_raw_ocr[k], REF_OCR_FIX$ref_raw_printed[k], REF_OCR_FIX$reading[k])) }   ## CONVENTION-OK: declared, page image checked
  }
  ref_tok <- lapply(d$ref_raw, function(x) { if(is.na(x)) return(character(0)); t <- str_squish(str_split(x, "[,\\s]+")[[1]]); t[nzchar(t)] })
  ## a token is <number><letter?> or a subscript insert written <number><letter?>_<digit> (5424_2, 5405b_1 in _references.csv)
  bad_tok <- unique(unlist(lapply(ref_tok, function(t) t[!str_detect(t, "^\\d{1,5}[a-z]?(_\\d)?$")])))
  if(length(bad_tok)) stop("Reference tokens that are not <number><letter?> in ", fam, ": ", paste(bad_tok, collapse = " | "), call.=FALSE)
  ## a printed subscript insert (5424\u2082) fused by the OCR into a 5-digit number beyond the bibliography (54242): mapped to
  ## the _references.csv form (5424_2) when that row exists; counted and printed
  fuse <- function(t) { f <- !(t %in% refs$ref_number) & str_detect(t, "^\\d{5}$") & paste0(substr(t, 1, 4), "_", substr(t, 5, 5)) %in% refs$ref_number; t[f] <- paste0(substr(t[f], 1, 4), "_", substr(t[f], 5, 5)); attr(t, "n") <- sum(f); t }
  n_fused <- 0L; ref_tok <- lapply(ref_tok, function(t) { t2 <- fuse(t); n_fused <<- n_fused + attr(t2, "n"); as.character(t2) })
  if(n_fused) cat(sprintf("%s: fused subscript tokens mapped to _references.csv form: %d\n", fam, n_fused))   ## CONVENTION-OK: printed for audit
  all_tok <- unique(unlist(ref_tok))
  unknown <- all_tok[!(all_tok %in% refs$ref_number) & !(all_tok %in% DECLARED_ABSENT) & !(all_tok %in% PRINTED_NOT_IN_BIBLIOGRAPHY$token[PRINTED_NOT_IN_BIBLIOGRAPHY$section == d$order[1]])]
  if(length(unknown)) stop("Reference numbers in ", fam, " with no row in references.csv and not declared absent: ", paste(unknown, collapse = ","), call.=FALSE)
  d$ref_numbers <- vapply(ref_tok, function(t) paste(t, collapse = ";"), character(1))
  d$n_ref_numbers <- lengths(ref_tok)
  d$ref_numbers_resolved <- vapply(ref_tok, function(t) length(t) > 0 && all(t %in% refs$ref_number), logical(1))
  d$ref_first_author_year <- vapply(ref_tok, function(t) { i <- match(t, refs$ref_number); paste(ifelse(is.na(i), "NOT_IN_BIBLIOGRAPHY", paste(refs$first_author[i], refs$year[i])), collapse = "; ") }, character(1))
  d$n_citations_resolved <- vapply(ref_tok, function(t) sum(t %in% refs$ref_number), integer(1))
  if(any(d$ref_numbers_resolved & d$n_citations_resolved != d$n_ref_numbers)) stop("Citation list shorter than the reference-number list", call.=FALSE)
  ## population status
  ps <- Map(function(v, t) population_status(v, t), d$value_normalised, ref_tok)
  d$population_status <- vapply(ps, `[[`, character(1), "status")
  d$population_status_basis <- vapply(ps, `[[`, character(1), "basis")
  d$population_status[d$topic == "family_overview"] <- "unspecified"
  d$population_status_basis[d$topic == "family_overview"] <- "none"
  ## parse status
  d$parse_status <- case_when(
    d$topic == "family_overview" ~ "parsed",
    d$n_ref_numbers == 0 ~ "verbatim_only",
    d$value_type != "text" & is.na(d$main_remainder) ~ "parsed",
    d$value_type != "text" ~ "partial",
    d$topic == "SEASONALITY" & !is.na(d$value_label) ~ "parsed",
    !is.na(d$value_label) ~ "partial",
    TRUE ~ "verbatim_only")
  d %>% transmute(order, family, genus, species_printed, species_binomial_printed, species_ocr_corrected, species_msw05, species_basis, topic, line_verbatim, value_text, value_normalised,
                  sex, value_label, approx, comparator, value_type, value_numeric, value_unit, count_unit, range_low, range_high, n, n_comparator, sd, se, pm, mode,
                  main_remainder, qualifiers_verbatim, population_status, population_status_basis, ref_numbers, n_ref_numbers, ref_numbers_resolved, n_citations_resolved,
                  ref_first_author_year, wrapped_value_line = wrapped, printed_page, pdf_page_in_slice, pdf_page_in_book, slice_file, parse_status)
}
tables <- lapply(names(res), function(fam) dev_try(fam, build_table(res[[fam]]))); names(tables) <- names(res)
tables <- tables[!vapply(tables, is.null, logical(1))]; res <- res[names(tables)]
if(!nzchar(DEV)) if(any(REF_OCR_FIX$applied != 1L)) stop("Declared reference repairs not applied exactly once: ", paste(sprintf("%s p.%d '%s' x%d", REF_OCR_FIX$section, REF_OCR_FIX$printed_page, REF_OCR_FIX$ref_raw_ocr, REF_OCR_FIX$applied)[REF_OCR_FIX$applied != 1L], collapse = "; "), call.=FALSE)
cat("declared reference repairs applied:", sum(REF_OCR_FIX$applied), "of", nrow(REF_OCR_FIX), "\n")
if(!nzchar(DEV)) if(any(DECLARED_VALUE_LINES$applied != 1L)) stop("Declared value lines not applied exactly once: ", paste(sprintf("%s p.%d ref %s x%d", DECLARED_VALUE_LINES$section, DECLARED_VALUE_LINES$printed_page, DECLARED_VALUE_LINES$ref, DECLARED_VALUE_LINES$applied)[DECLARED_VALUE_LINES$applied != 1L], collapse = "; "), call.=FALSE)
cat("declared value lines inserted:", sum(DECLARED_VALUE_LINES$applied), "of", nrow(DECLARED_VALUE_LINES), "\n")
if(!nzchar(DEV)) if(any(DECLARED_REF_WORDS$applied != 1L)) stop("Declared reference words not found on exactly one row: ", paste(DECLARED_REF_WORDS$ref[DECLARED_REF_WORDS$applied != 1L], collapse = "; "), call.=FALSE)
cat("declared reference words (absent from the text layer) placed:", sum(DECLARED_REF_WORDS$applied), "of", nrow(DECLARED_REF_WORDS), "\n")
if(!nzchar(DEV)) if(any(DECLARED_SPECIES_WORDS$applied != 1L)) stop("Declared species words not found on exactly one row: ", paste(DECLARED_SPECIES_WORDS$text[DECLARED_SPECIES_WORDS$applied != 1L], collapse = "; "), call.=FALSE)
if(!nzchar(DEV)) if(any(DECLARED_WORD_MOVES$applied != 1L)) stop("Declared word moves not applied: ", paste(DECLARED_WORD_MOVES$text[DECLARED_WORD_MOVES$applied != 1L], collapse = "; "), call.=FALSE)
if(!nzchar(DEV)) if(any(NOISE_WORDS$applied != 1L)) stop("Declared noise words not applied: ", paste(NOISE_WORDS$text[NOISE_WORDS$applied != 1L], collapse = "; "), call.=FALSE)
if(!nzchar(DEV)) if(any(SPECIES_OCR_FIX$applied == 0L)) stop("Declared species OCR fixes never applied: ", paste(SPECIES_OCR_FIX$ocr[SPECIES_OCR_FIX$applied == 0L], collapse = "; "), call.=FALSE)
cat("declared species OCR fixes applied (rows):", paste(sprintf("%s->%s x%d", SPECIES_OCR_FIX$ocr, SPECIES_OCR_FIX$printed, SPECIES_OCR_FIX$applied), collapse = "; "), "\n")

## ---- reference-number digit plausibility (report) -----------------------------------------------------------------------------
## A reference number mis-read by one confusable digit (8/6, 8/3, 8/0, 6/0, 6/5, 1/7, 9/0, 3/5, 1/4) can still be a valid
## number (Cheirogaleidae p. 175: 8435 Petter et al. 1977 read as 6435 Lidicker 1980 on the California vole) and passes
## every guard. Heuristic: a number cited once in a family whose one-digit variant is cited >= 2 times in the same
## family is suspect. Written to _accounts_ref_suspects.csv for page-image checking; confirmed errors go to REF_OCR_FIX.
DIGIT_CONFUSIONS <- list(c("8","6"), c("8","3"), c("8","0"), c("6","0"), c("6","5"), c("1","7"), c("9","0"), c("3","5"), c("1","4"))
digit_variants <- function(tok) { base <- str_extract(tok, "^\\d+"); suf <- str_remove(tok, "^\\d+"); ch <- str_split(base, "")[[1]]; out <- character(0)
  for(i in seq_along(ch)) for(pr in DIGIT_CONFUSIONS) { if(ch[i] == pr[1]) { v <- ch; v[i] <- pr[2]; out <- c(out, paste0(paste(v, collapse = ""), suf)) }; if(ch[i] == pr[2]) { v <- ch; v[i] <- pr[1]; out <- c(out, paste0(paste(v, collapse = ""), suf)) } }
  unique(out) }
## a number truncated by the OCR to 1-2 digits ('8700, 8704, 1' for 8706, Phascolarctidae p. 47) is still a valid
## token (references 1-99 exist); such tokens on lines whose other tokens have >= 4 digits are listed as short_token
short_tok <- bind_rows(lapply(names(tables), function(fam) { d <- tables[[fam]] %>% filter(n_ref_numbers > 1)
  i <- which(vapply(str_split(d$ref_numbers, ";"), function(t) any(nchar(str_extract(t, "^\\d+")) <= 2) && any(nchar(str_extract(t, "^\\d+")) >= 4), logical(1)))
  if(!length(i)) return(NULL)
  tibble(family = fam, printed_page = d$printed_page[i], topic = d$topic[i], species_printed = d$species_printed[i], value_text = d$value_text[i], ref_cited_once = d$ref_numbers[i],
         cited_once_work = d$ref_first_author_year[i], variant_cited_often = "short_token", variant_n = NA_character_, variant_work = NA_character_, checked = NA_character_) }))
cat("short reference tokens beside long ones (possible truncations):", nrow(short_tok), "\n")
ref_suspects <- bind_rows(lapply(names(tables), function(fam) {
  d <- tables[[fam]]; toks <- unlist(str_split(d$ref_numbers[nzchar(d$ref_numbers)], ";")); tc <- table(toks)
  single <- names(tc)[tc == 1]
  bind_rows(lapply(single, function(t) { v <- digit_variants(t); v <- v[v %in% names(tc) & tc[v] >= 2]; if(!length(v)) return(NULL)
    i <- which(str_detect(paste0(";", d$ref_numbers, ";"), fixed(paste0(";", t, ";"))))
    tibble(family = fam, printed_page = d$printed_page[i], topic = d$topic[i], species_printed = d$species_printed[i], value_text = d$value_text[i], ref_cited_once = t,
           cited_once_work = d$ref_first_author_year[i], variant_cited_often = paste(v, collapse = "|"), variant_n = paste(as.integer(tc[v]), collapse = "|"),
           variant_work = paste(refs$first_author[match(v, refs$ref_number)], refs$year[match(v, refs$ref_number)], collapse = "|"), checked = NA_character_) }))
}))
## rows inspected on the page image during the 2026-10-23 session (the five errors are repaired in REF_OCR_FIX and
## therefore no longer appear as singletons; the sixth is printed as cited)
SUSPECTS_CHECKED <- tribble(~family, ~printed_page, ~ref_cited_once, ~checked,
  "Cebidae", 198L, "10809", "page image 2026-10-23: printed 10809 as cited (Thornback & Jenkins, IUCN Red Data Book) -- correct")
ref_suspects <- bind_rows(ref_suspects, short_tok) %>% select(-checked) %>% left_join(SUSPECTS_CHECKED %>% mutate(printed_page = as.integer(printed_page)), by = c("family", "printed_page", "ref_cited_once"))
cat("\nreference-number digit suspects (cited once; one-digit variant cited >= 2x in the family):", nrow(ref_suspects), "; data-line suspects:", sum(ref_suspects$topic != "family_overview"), "; checked on page image:", sum(!is.na(ref_suspects$checked)), "\n")
if(nrow(ref_suspects)) print(table(ref_suspects$family))

## ---- guards and counts ------------------------------------------------------------------------------------------------
cat("\n== counts ==\n")
for(fam in names(tables)) {
  d <- tables[[fam]]
  if(any(is.na(d$topic))) stop("Rows without topic in ", fam, call.=FALSE)
  if(any(is.na(d$species_binomial_printed) & d$topic != "family_overview")) stop("Rows without species in ", fam, call.=FALSE)
  cat(sprintf("%s: %d rows (%d data lines, %d family_overview); topics: %s\n", fam, nrow(d), sum(d$topic != "family_overview"), sum(d$topic == "family_overview"), paste(res[[fam]]$topics, collapse = " | ")))
  print(table(d$parse_status[d$topic != "family_overview"]))
  vfrac <- if(any(d$topic != "family_overview")) mean(d$parse_status[d$topic != "family_overview"] == "verbatim_only") else 0
  cat(sprintf("  verbatim_only fraction of data lines: %.1f%%\n", 100 * vfrac))
  ## the 10% guard is meaningful for a family with >= 30 data lines; below that a single prose-like line (Thylacinidae:
  ## 3 lines) exceeds it, so small families are reported instead
  n_dl <- sum(d$topic != "family_overview")
  ## families whose verbatim_only lines were read on the page image and are the book's own prose-like values
  VERBATIM_ACCEPTED <- c(Phascolarctidae = "4 of 32 lines: 'f: end 2 yr' x2, 'every other yr', 'birth; Jan-Mar; VIC, Australia' (printed with a semicolon)")
  if(fam %in% names(VERBATIM_ACCEPTED)) { cat("  verbatim_only lines accepted (declared): ", VERBATIM_ACCEPTED[[fam]], "\n", sep = ""); vfrac <- 0 }   ## CONVENTION-OK: declared, lines kept
  if(vfrac > 0.10 && n_dl >= 30) { if(nzchar(DEV)) DEV_ERRORS[[fam]] <- sprintf("verbatim_only fraction %.1f%% above 10%%", 100 * vfrac) else stop("verbatim_only fraction above 10% in ", fam, call.=FALSE) }
  if(vfrac > 0.10 && n_dl < 30) cat(sprintf("  NOTE small family (%d data lines): verbatim_only %.1f%% -- lines kept, not a stop\n", n_dl, 100 * vfrac))   ## CONVENTION-OK: reported
  cat(sprintf("  wrapped value lines joined: %d; rows with >1 reference: %d; reference numbers not in bibliography (declared): %s\n",
              sum(d$wrapped_value_line), sum(d$n_ref_numbers > 1), paste(unique(unlist(str_split(d$ref_numbers[!d$ref_numbers_resolved & d$topic != "family_overview"], ";"))), collapse = ",")))
  cat(sprintf("  species printed: %d distinct; resolved to a key name: %d; unresolved: %s\n", n_distinct(d$species_printed, na.rm = TRUE),
              n_distinct(d$species_msw05, na.rm = TRUE), paste(unique(d$species_printed[!is.na(d$species_printed) & is.na(d$species_msw05)]), collapse = "; ")))
  print(table(d$population_status[d$topic != "family_overview"]))
}
unparsed <- bind_rows(lapply(res, `[[`, "unparsed"))
cat("unparsed rows (all families):", nrow(unparsed), "\n"); if(nrow(unparsed)) print(table(unparsed$family, unparsed$kind))
in_range_unp <- if(nrow(unparsed)) unparsed %>% filter(!str_detect(kind, "^outside_family_range"), kind != "page_ocr_unusable") else unparsed
if(nrow(in_range_unp)) { cat("  in-range unparsed lines:\n"); print(as.data.frame(in_range_unp), row.names = FALSE)
  if(nzchar(DEV)) for(f in unique(in_range_unp$family)) DEV_ERRORS[[f]] <- paste(c(DEV_ERRORS[[f]], "in-range unparsed lines (see table above)"), collapse = " | ") else stop("In-range unparsed lines: species or reference lines without a value line, or data lines without topic/species -- check the page images and declare", call.=FALSE) }
if(nzchar(DEV)) {
  cat("\n== DEV MODE summary ==\n")
  cat("families run:", nrow(FAMILY_SPECS), "; built:", length(tables), "; stopped:", length(DEV_ERRORS), "\n")
  for(f in names(DEV_ERRORS)) cat(sprintf("  %-18s %s\n", f, DEV_ERRORS[[f]]))
  cat("DEV MODE: nothing written\n"); quit(save = "no", status = if(length(DEV_ERRORS)) 2L else 0L)
}

## ---- positive controls (read from the page images) -------------------------------------------------------------------
cat("\n== positive controls ==\n")
has_line <- function(d, species, topic, value_regex, ref) {
  x <- d %>% filter(species_printed == species, topic == !!topic, str_detect(value_normalised, value_regex), str_detect(paste0(";", ref_numbers, ";"), paste0(";", ref, ";")))
  nrow(x) >= 1
}
CONTROL_LINES <- tribble(~family, ~species, ~topic, ~value_regex, ~ref,
  "Mustelidae", "Mustela putorius", "NEONATAL MASS", "^7 g$", "4643",
  "Mustelidae", "Mustela putorius", "NEONATAL MASS", "^9-10 g$", "3571",
  "Mustelidae", "Mustela putorius", "NEONATAL MASS", "^~10 g$", "9344",
  "Mustelidae", "Mustela putorius", "NEONATAL MASS", "^10 g ea; n2$", "4689",
  "Mustelidae", "Mustela putorius", "SEXUAL MATURITY", "^f: vulvar edema: 30-50 wk$", "9394",
  "Mustelidae", "Mustela putorius", "SEXUAL MATURITY", "^f: 1st mate: 6-9 mo$", "9344",
  "Mustelidae", "Mustela putorius", "SEXUAL MATURITY", "^m: spermatogenesis: 8 mo$", "5167",
  "Mustelidae", "Mustela putorius", "SEXUAL MATURITY", "^f/m: 1 yr$", "7979",
  "Mustelidae", "Mustela putorius", "INTERLITTER INTERVAL", "^20 wk$", "9344",
  "Mustelidae", "Mustela putorius", "LITTERS/YEAR", "^1$", "7979",
  "Mustelidae", "Mustela putorius", "LITTERS/YEAR", "^1$", "10499",
  "Mustelidae", "Mustela putorius", "LITTERS/YEAR", "^1; 2 if 1st lt removed$", "6156",
  "Mustelidae", "Mustela putorius", "LITTERS/YEAR", "^2; r0-2$", "4299",
  ## wave 2 (read from the page images rendered during the 2026-10-23 session)
  "Canidae", "Canis lupus", "SEASONALITY", "^birth: Apr-May; Wl$", "5210",
  "Canidae", "Alopex lagopus", "SEASONALITY", "^mate: Mar-Apr; captive$", "7462",
  "Canidae", "Canis latrans", "LACTATION", "^den emergence: 3-4 wk$", "747",
  "Procyonidae", "Bassariscus astutus", "LITTER SIZE", "^2-4$", "10721",
  "Protelidae", "Proteles cristatus", "LACTATION", "^den emergence: 1 mo$", "5907",
  "Felidae", "Neofelis nebulosa", "SEXUAL MATURITY", "^f: 1st conceive: 26.3 mo; sd7.9; r13-38; n13$", "11991a",
  "Felidae", "Panthera tigris", "SEASONALITY", "^birth: peak May-June; n1239; zoo$", "9706",
  "Otariidae", "Arctocephalus pusillus", "LITTER SIZE", "^1$", "1605",
  "Phocidae", "Phoca vitulina", "SEASONALITY", "^mate: Aug; zoo$", "5470",
  "Phocidae", "Phoca vitulina", "SEASONALITY", "^implant: mid Nov; se Vancouver I, BC, Canada$", "928",
  "Phocidae", "Lobodon carcinophagus", "NEONATAL MASS", "^22 kg$", "854",
  "Cheirogaleidae", "Microcebus murinus", "GESTATION", "^59-62 d; n7 lt$", "1150",
  "Lemuridae", "Lemur catta", "CYCLE LENGTH", "^estrus: <24 h$", "4722",
  "Lemuridae", "Hapalemur griseus", "LITTER SIZE", "^1 yg$", "8439",
  "Indriidae", "Lichanotus laniger", "LITTERS/YEAR", "^1$", "8444",
  "Galagidae", "Galago demidovii", "NEONATAL SIZE", "^75 mm$", "5758",
  "Galagidae", "Galago inustus", "LITTER SIZE", "^1 emb; n1 f$", "5758",
  "Galagidae", "Galago senegalensis", "LITTER SIZE", "^1-2$", "9507",
  "Galagidae", "Galago elegantulus", "LITTER SIZE", "^1 emb ea; n9 f$", "1742",
  "Cebidae", "Ateles belzebuth/A geoffroyi", "SEASONALITY", "^birth: yr rd; n15; zoo$", "5862",
  "Cercopithecidae", "Macaca fuscata", "CYCLE LENGTH", "^follicular phase: 12.2 d; \u00b11.4; r10-15; n21 cycles, 20 f$", "7918",
  "Cercopithecidae", "Macaca fascicularis", "CYCLE LENGTH", "^30.9 d; sd4.8; median 33; mode 28; r19-43; n595 cycles, 28 f$", "8977",
  "Cercopithecidae", "Macaca mulatta", "CYCLE LENGTH", "^follicular phase: 10.6 d; \u00b11.4$", "1131",
  "Pongidae", "Gorilla gorilla", "LITTER SIZE", "^1$", "9544",
  "Pongidae", "Gorilla gorilla", "LITTER SIZE", "^1 yg$", "6583",
  "Pongidae", "Pan troglodytes", "GESTATION", "^180 d; r167-193; n31; last menses to birth$", "4385",
  ## wave 3 (read from 120-220 dpi bands of the page images rendered during the 2026-10-24 session)
  "Thylacinidae", "Thylacinus cynocephalus", "SEASONALITY", "^small juveniles: yr rd, peak May-Aug; TAS, Australia$", "4130",
  "Phascolarctidae", "Phascolarctos cinereus", "LACTATION", "^wean: ~10 mo$", "8706",
  "Peramelidae", "Isoodon macrourus", "INTERLITTER INTERVAL", "^56 d; n6 lt, 1 f$", "3946",
  "Pteropodidae", "Cynopterus sphinx", "WEANING MASS", "^21.2 g; r19.8-22.3; n3 juveniles$", "10286",
  "Molossidae", "Tadarida aegyptiaca", "LITTERS/YEAR", "^1$", "5547",
  "Molossidae", "Molossus ater", "LITTER SIZE", "^1$", "1937",
  "Vespertilionidae", "Myotis lucifugus", "SEASONALITY", "^preg f: May; n14; SD$", "261a",
  "Physeteridae", "Kogia breviceps", "NEONATAL MASS", "^82 kg$", "7498c",
  "Physeteridae", "Physeter macrocephalus", "NEONATAL MASS", "^774 kg$", "10158",
  "Elephantidae", "Loxodonta africana", "NEONATAL MASS", "^120 kg$", "6292",
  "Orycteropodidae", "Orycteropus afer", "LITTERS/YEAR", "^1$", "11253",
  "Camelidae", "Camelus bactrianus", "INTERLITTER INTERVAL", "^2 yr$", "8798",
  "Cervidae", "Cervus elaphus", "SEASONALITY", "^birth: peak May-June, some Oct-Nov; Rhum, Inner Hebrides, UK$", "2200",
  "Leporidae", "Lepus townsendii", "SEASONALITY", "^preg f: Mar-July; UT$", "5254a",
  "Geomyidae", "Thomomys bulbivorus", "WEANING SIZE", "^16.4 cm$", "11671",
  "Castoridae", "Castor canadensis", "GESTATION", "^~90 d$", "2088",
  "Castoridae", "Castor canadensis", "LITTERS/YEAR", "^1$", "1202",
  "Arvicolidae", "Prometheomys schaposchnikowi", "LITTER SIZE", "^2.7 emb, ps; r1-4; n6 lt$", "10275",
  "Cricetidae", "Akodon molinae", "NEONATAL MASS", "^m: 3 g; from graph$", "7213")
CONTROL_LINES$found <- vapply(seq_len(nrow(CONTROL_LINES)), function(i) with(CONTROL_LINES[i, ], has_line(tables[[family]], species, topic, value_regex, ref)), logical(1))
print(as.data.frame(CONTROL_LINES %>% select(species, topic, value_regex, ref, found)), row.names = FALSE)
if(!all(CONTROL_LINES$found)) stop("Positive-control line(s) not found", call.=FALSE)
CONTROL_REFSETS <- list(
  list(family = "Suidae", species = "Sus scrofa", topic = "GESTATION", refs = c("9175","2588","8220","4795","2098","1474","2040","2973","4639","6885","5146","8498","8501","8223","2936","4645","8466","4181","3571","4643")),
  list(family = "Suidae", species = "Sus scrofa", topic = "LITTER SIZE", refs = c("2588","1230","11254","5349","11255","10079","5136","9428","458","6979","1931","4152","35","473","1287","10519","8466","2973")))
for(cs in CONTROL_REFSETS) {
  d <- tables[[cs$family]] %>% filter(species_printed == cs$species, topic == cs$topic)
  cited <- unique(unlist(str_split(d$ref_numbers, ";")))
  miss <- setdiff(cs$refs, cited)
  cat(sprintf("%s %s: %d rows, %d distinct refs; control refs missing: %s\n", cs$species, cs$topic, nrow(d), length(cited), if(length(miss)) paste(miss, collapse=",") else "none"))
  if(length(miss)) stop("Positive-control reference set incomplete for ", cs$species, " ", cs$topic, call.=FALSE)
}
ss <- tables$Suidae %>% filter(species_printed == "Sus scrofa")
need_status <- list(domestic_laboratory = c("8220", "2973"), feral = c("473", "10600"), wild = c("2588", "6979"))
for(st in names(need_status)) for(rf in need_status[[st]]) {
  hit <- ss %>% filter(str_detect(paste0(";", ref_numbers, ";"), paste0(";", rf, ";")))
  if(!nrow(hit)) stop("Sus scrofa control reference ", rf, " not cited on any line", call.=FALSE)
  ok <- any(str_detect(hit$population_status, st))
  cat(sprintf("Sus scrofa ref %s -> expected %s: %s (statuses found: %s)\n", rf, st, if(ok) "OK" else "FAIL", paste(unique(hit$population_status), collapse = "|")))
  if(!ok) stop("Sus scrofa population status control failed for ", rf, call.=FALSE)
}

## ---- the question: domestic/laboratory vs wild for Sus scrofa and Mustela putorius ------------------------------------------------
cat("\n== status tables ==\n")
status_table <- function(d, species) {
  x <- d %>% filter(species_printed == species) %>% mutate(status_class = case_when(
    str_detect(population_status, "^mixed") ~ "mixed", TRUE ~ population_status))
  cat(sprintf("\n%s: %d data lines\n", species, nrow(x)))
  print(table(x$topic, x$status_class))
  print(table(x$status_class))
  invisible(x)
}
sus_tab <- status_table(tables$Suidae, "Sus scrofa")
put_tab <- status_table(tables$Mustelidae, "Mustela putorius")
## wave 2: the species the domestic/laboratory-vs-wild question is asked about. The book lists no domestic
## species as such (printed p. 1): Felis catus and Canis familiaris have no account; printed p. 229 says
## dingos, wolves and domestic dogs are all considered Canis lupus; Felis bieti has no account either.
SPECIES_OF_INTEREST <- tribble(~family, ~species,
  "Felidae", "Felis silvestris", "Felidae", "Felis catus", "Canidae", "Canis lupus", "Canidae", "Canis familiaris", "Canidae", "Vulpes vulpes",
  "Cercopithecidae", "Macaca mulatta", "Cercopithecidae", "Papio hamadryas", "Cercopithecidae", "Papio leucophaeus", "Cercopithecidae", "Papio sphinx", "Cercopithecidae", "Papio spp",
  "Pongidae", "Pan troglodytes", "Hominidae", "Homo sapiens", "Felidae", "Felis marmorata", "Felidae", "Felis bieti")
soi_tabs <- lapply(seq_len(nrow(SPECIES_OF_INTEREST)), function(k) status_table(tables[[SPECIES_OF_INTEREST$family[k]]], SPECIES_OF_INTEREST$species[k]))
names(soi_tabs) <- SPECIES_OF_INTEREST$species
absent_soi <- SPECIES_OF_INTEREST$species[vapply(soi_tabs, nrow, integer(1)) == 0]
cat("\nspecies of interest with no account in the book:", paste(absent_soi, collapse = ", "), "\n")
if(!setequal(absent_soi, c("Felis catus", "Canis familiaris", "Felis bieti"))) stop("Unexpected set of absent species of interest: ", paste(absent_soi, collapse = ", "), call.=FALSE)
cat("\nFelis marmorata (Pardofelis marmorata), every line:\n")
print(as.data.frame(tables$Felidae %>% filter(species_printed == "Felis marmorata") %>% select(topic, value_text, ref_numbers, ref_first_author_year, population_status, printed_page)), row.names = FALSE)

## ---- write -------------------------------------------------------------------------------------------------------------
write_bom_csv <- function(x, path) {
  write_excel_csv(x, path, na = "")
  b <- readBin(path, "raw", 3); if(!identical(b, as.raw(c(0xef, 0xbb, 0xbf)))) stop("BOM missing on ", path, call.=FALSE)
  rb <- read_csv(path, show_col_types = FALSE, col_types = cols(.default = "c")); if(nrow(rb) != nrow(x)) stop("Row count changed on write: ", path, call.=FALSE)
}
written <- character(0)
for(fam in names(tables)) { f <- file.path(out_dir, sprintf("%s_accounts_%s.csv", paper, fam)); write_bom_csv(tables[[fam]], f); written <- c(written, f) }
f_unp <- file.path(out_dir, paste0(paper, "_accounts_unparsed.csv")); write_bom_csv(unparsed, f_unp); written <- c(written, f_unp)
f_abbr <- file.path(out_dir, paste0(paper, "_abbreviations.csv")); write_bom_csv(abbr, f_abbr); written <- c(written, f_abbr)
f_sus <- file.path(out_dir, paste0(paper, "_accounts_ref_suspects.csv")); write_bom_csv(ref_suspects, f_sus); written <- c(written, f_sus)

## ---- definitions ---------------------------------------------------------------------------------------------------------
ALL_TOPICS <- unique(unlist(lapply(res, `[[`, "topics")))
NEW_TOPICS <- setdiff(ALL_TOPICS, c("NEONATAL MASS", "NEONATAL SIZE", "WEANING MASS", "WEANING SIZE", "LITTER SIZE", "SEXUAL MATURITY", "CYCLE LENGTH", "GESTATION", "LACTATION", "INTERLITTER INTERVAL", "LITTERS/YEAR", "SEASONALITY"))
cat("topic headings over all families:", length(ALL_TOPICS), "; new since the Suidae/Mustelidae build:", paste(NEW_TOPICS, collapse = ", "), "\n")
tbl_ref <- paste0(paper, "_accounts_<Family>")
src_note <- "pdf_by_order/<order slice>.pdf species-account pages of the family (OCR text layer, word boxes)"
D <- function(Code, Definition, Measure = NA, role = "info", Reference = tbl_ref, Note = NA, Source = src_note) tibble(Code = Code, Definition = Definition, Structure = NA, Measure = Measure, Stat = NA, role = role, taxon = "mammals", Reference = Reference, Note = Note, `Source Note` = Source)
defs <- bind_rows(
  D("order", "Order as printed in the family heading 'Order X, Family Y'"),
  D("family", "Family as printed in the family heading; one output table per family"),
  D("genus", "First word of the printed species name; for family_overview rows the genus named before the number list inside the parentheses (NA when the list applies to the whole family)"),
  D("species_printed", "Genus + epithet as printed, question mark removed (the book marks questionable taxonomy with '?' after the name, printed p. 1), OCR letter errors mapped to the family's canonical spelling (species_ocr_corrected); NA for family_overview rows"),
  D("species_binomial_printed", "Species-column text exactly as OCR'd, including a trailing '?' or 'spp' and OCR letter errors ('Sus scrota')"),
  D("species_ocr_corrected", "TRUE when species_printed differs from the OCR text: (a) systematic glyph confusions undone ('n/' -> 'rv', '!' -> 'i', an OCR space inside a genus removed); (b) the name is within edit distance 2 (spaces/case ignored) AND within 1 edit after collapsing confusable glyphs (l/t/i/1/I/f, rn/ru/m, ri/h, u/v, c/e/o) of a name that resolves in the species key or is printed more often in the family -- the glyph condition keeps real pairs such as Canis rufus / Canis lupus and Panthera uncia / Panthera onca apart; (c) a declared variant (SPECIES_OCR_FIX in the script, page image checked: Tremarctos omatus -> ornatus, Paradoxums -> Paradoxurus, Alouatta pal Hat a -> palliata, ...). Every mapping is printed by the script", "logical"),
  D("species_msw05", "Identity anchor returned by _keys/resolve_species.R (accepted_name) for species_printed with source_publication = Hayssen_etal_1993; blank when unresolved", Note = "the book's taxonomy follows Honacki et al. (Mammal Species of the World, 1st ed.), printed p. 1; no Hayssen spoke exists yet, so matches are variant/hub level"),
  D("species_basis", "match_level:species_basis from resolve_species (paper | variant | hub) or 'unresolved'"),
  D("topic", paste0("Topic heading in capitals under which the line is printed, as the book prints it. Headings met so far: ", paste(ALL_TOPICS, collapse = ", "), " (INTERBIRTH INTERVAL is the primate families' heading for what the carnivore and artiodactyl families head INTERLITTER INTERVAL); or 'family_overview' for a parenthesised reference list in the family's introductory prose"), "category"),
  D("line_verbatim", "The printed line rebuilt from the OCR word boxes: species (if printed on that line) + value text + reference numbers; for family_overview rows the clause preceding the parentheses plus the parenthesised list. OCR errors retained ('nl' for n1, 'It' for lt, 'rl' for r1, '-' for '~'), including damaged reference tokens that ref_numbers repairs (method:declared_repairs). Lines whose value the OCR text layer lacked entirely carry the marker [VALUE_FROM_PAGE_IMAGE: ...] after the reference (method:declared_repairs)"),
  D("value_text", "The value column as OCR'd (line minus species and reference tokens), whitespace collapsed; wrapped second lines joined"),
  D("value_normalised", "value_text after OCR normalisation used for parsing: It->lt, nl->n1, rl->r1, l->1 after r/n/sd/se, I/O->1/0 inside n-tokens, '2- 3'->'2-3'"),
  D("sex", "Sex prefix as printed: f, m, f/m, m/f", "category"),
  D("value_label", "Measure label printed before a colon (1st mate, 1st birth, wean, solid food, birth, mate, estrus, HB, CR, TL, testes, ...)", "category"),
  D("approx", "TRUE when the value is printed with '~' (OCR'd as a leading '-') or 'est'", "logical"),
  D("comparator", "<, >, <=, >= (or the printed symbols) or '+' ('2+ yr') preceding the value", "category"),
  D("value_type", "point = a single number without dispersion/sample statistics; mean = a single number accompanied by sd, se, +/-, r or n>1 (the book prints the mean first, printed p. 4); range = 'a-b' or 'ra-b' as the main value; mode/max/min/median = so labelled (median added in wave 2: 'median 35 d', 'median 14-16 d' in the primate cycle data); text = no leading number (seasonality lines, 'half grown', ...)", "category"),
  D("value_numeric", "The leading number of the main value (before the first ';') for point/mean/mode/max/min", "numeric"),
  D("value_unit", "Unit token printed directly after the number: g, kg, mg, d, wk, mo, yr, h, mm, cm, %; 'count' when a bare number (litter size, litters per year); NA for text", "category"),
  D("count_unit", "What was counted when printed after the number: emb, yg, cl, lt, ps, blastocysts, implantations, ova, ea", "category"),
  D("range_low", "Lower bound of the main range or of the 'r' qualifier (first r-segment)", "numeric"),
  D("range_high", "Upper bound of the main range or of the 'r' qualifier", "numeric"),
  D("n", "Sample size from the first 'n<digits>' qualifier ('nl' OCR = n1); what was counted (lt, f, samples) stays in qualifiers_verbatim", "integer"),
  D("n_comparator", "'>' or '<' when printed before the sample size (n>5000)", "category"),
  D("sd", "Standard deviation qualifier 'sd<number>'", "numeric"),
  D("se", "Standard error qualifier 'se<number>'", "numeric"),
  D("pm", "Unknown variance estimate '+/-<number>' (book symbol +/-)", "numeric"),
  D("mode", "Mode qualifier 'mode <x>' when printed after the main value", "category"),
  D("main_remainder", "Tokens of the main segment after the number, unit and count word that the grammar did not classify (e.g. 'morphs, 1st lt', 'from graph'); non-NA -> parse_status partial"),
  D("qualifiers_verbatim", "All '; '-separated segments after the main value, verbatim (normalised OCR)"),
  D("population_status", "wild | feral | domestic_laboratory | captive_zoo | unspecified | mixed:<a>|<b> (sorted, '|'-joined) -- see method rows", "category"),
  D("population_status_basis", "book_qualifier:<token(s)> | cited_work_title:<ref>=<keyword>[|...] | none"),
  D("ref_numbers", "Literature Cited numbers printed at the end of the line, as printed (letter suffix kept), ';'-joined", "key"),
  D("n_ref_numbers", "Number of reference tokens on the line", "integer"),
  D("ref_numbers_resolved", "TRUE iff every token has a row in _references.csv; FALSE tokens are in _cited_numbers_not_in_bibliography.csv (asserted)", "logical"),
  D("n_citations_resolved", "Number of tokens with a row in _references.csv (asserted equal to n_ref_numbers when resolved)", "integer"),
  D("ref_first_author_year", "'; '-joined first_author + year from _references.csv in token order; NOT_IN_BIBLIOGRAPHY for a declared-absent token"),
  D("wrapped_value_line", "TRUE when the value text was printed over two lines (the reference number on the second) and joined", "logical"),
  D("printed_page", "Printed page from the running header (contents table for the first page of an order slice)", "integer"),
  D("pdf_page_in_slice", "Page within the order slice PDF", "integer"),
  D("pdf_page_in_book", "Page within the whole-book PDF (slice pdf_page_start + page - 1)", "integer"),
  D("slice_file", "Order slice file name"),
  D("parse_status", "parsed = numeric value (or a labelled SEASONALITY text) with every main-segment token classified and >=1 reference; partial = numeric value with unclassified main-segment tokens, or a labelled text value; verbatim_only = no numeric value and no label, or no reference token -- the line is kept in line_verbatim", "category"),
  D("method:line_grammar", "Data line = [species] <value>[; qualifier]* <ref>[, <ref>]*. Pages are rebuilt from pdf_data word boxes: raw y-groups (3 pt) classify running header, prose (starts at the margin, spans > 250 pt, no inter-word gap >= 25 pt), 'Order X, Family Y' headings; remaining words are split into species / value / reference columns at per-page x anchors (5th percentile of reference-token x minus 4; 5th percentile of value-line first-word x minus 12), lines rebuilt per column, and the columns aligned with a per-page y offset (reference column anchored on the first value/reference pair; species column by the offset maximising matches) because the scan rotation shifts the columns by up to 6 pt. A reference line without a value line continues the previous reference list; a value line without a reference followed within 1.6 lines by one with a reference is a wrapped value. Species names are inherited down a topic; the topic resets the species. Lines before the family heading or after the next family's heading go to _accounts_unparsed.csv (outside_family_range).", role = "method", Reference = paste0(paper, "_accounts")),
  D("method:family_overview", "Parenthesised groups containing a reference number in the family prose (between the family heading and the first topic) become one row per ';'-segment: genus = leading italic genus if any, 'cf' kept as '[cf]', value_text = the clause preceding the parentheses. Groups that are size ranges ('Sus 3-350 kg') are skipped.", role = "method", Reference = paste0(paper, "_accounts")),
  D("method:population_status", "(1) If the line's own text contains a book token -- captive, zoo (-> captive_zoo); lab, domestic, farm, fur farm (-> domestic_laboratory); feral; wild -- use it, basis book_qualifier:<token>; two tokens of different classes -> mixed. (2) Else classify each cited work from title + journal in _references.csv (citation when no title parsed): feral keyword 'feral' -> feral; wild keywords (wild, Wildschwein, Sanglier, jabali, Schwarzwild, Iltis, polecat, 'Mammals of', J Mamm, J Wildl Manage, Mammalia, Z Saugetierk, Acta Theriol, field) -> wild unless a strong domestic keyword also fires (then mixed); domestic keywords (ferret, Frettchen, furo, UFAW, Lab Anim, miniature pig, domestic, Hausschwein, swine; animal words sow(s)/gilt(s)/boar(s)/pig(s); journals J Anim Sci, Anim Prod, Anim Reprod Sci, Biol Reprod, J Reprod Fert, Theriogenology) -> domestic_laboratory. A wild modifier wins over an animal word ('wild boar', 'feral pigs'). Several cited works disagreeing -> mixed:<a>|<b>; basis cited_work_title:<ref>=<keyword>. (3) Else unspecified, basis none. Matching is case-insensitive and whole-word, except that the stems wild, Wildschwein, Sanglier, jabal, Schwarzwild, Iltis, polecat are matched as word prefixes (Wildlebenden, Schwarzwildes, Iltissen, OCR 'jabalf').", role = "method", Reference = paste0(paper, "_accounts")),
  D("method:book_statements_on_domestic_species", "Printed p. 1: data for domesticated species (pig Sus scrofa, dog, cat, horse, cow, sheep, goat) and common laboratory animals are 'generally not listed'; 'data from their wild counterparts are included'; medical-journal 'ferret' studies are assigned to Mustela putorius. Printed p. 377 (Suidae prose): 'The reproductive biology of domestic pigs is reviewed in supplements 33 and 40 of the Journal of Reproduction and Fertility'. Printed p. 229 (Canidae prose): the reproductive biology of domestic dogs is summarized in supplement 39 of J Reprod Fert (1989); 'Note that dingos, wolves, and domestic dogs are all considered Canis lupus'. Printed p. 296 (Felidae prose): the reproductive biology of domestic cats is reviewed in the same supplement 39. Accordingly Canis familiaris and Felis catus have no species account (0 lines each; asserted by the script), and domestic-dog data, where cited, sit under Canis lupus. These statements are why population_status is derived per value.", role = "method", Reference = paste0(paper, "_accounts")),
  D("method:family_headings_and_page_range", "A family's range runs from its body heading 'Order X, Family Y' (monotypic families print 'Order X, Family Y, Genus Z': Protelidae, Odobenidae, Daubentoniidae, Tarsiidae, Callimiconidae, Hylobatidae, Hominidae) to the next family heading; a page shared by two families (printed pp. 183, 188, 189, 195, 196, 221, 228, 247, 255, 260, 293, 312, 318) is split at the heading's y position, never duplicated. A heading's family name may be OCR-damaged (declared: 'Proteiidae' = Protelidae); running headers are matched within edit distance 2 ('Cercopitliecidae') and printed when not exact. A single-page family at the end of a slice (Hominidae, printed p. 228) is located by its own heading. Printed page numbers absent from the text layer are declared from the page image (Carnivora pp. 277, 319, 321; Primates p. 227).", role = "method", Reference = paste0(paper, "_accounts")),
  D("method:column_alignment_wave2", "Additions to the line grammar for the Carnivora/Primates families (all guarded so that the Suidae and Mustelidae tables are byte-identical to the 2026-10-22 build): (1) the left margin is taken from the running header when a page has no species-column text at all (printed p. 334: Phoca vitulina continues from p. 333) -- otherwise the value column would have been read as the species column; (2) the reference-column anchor is recomputed from line-final numeric tokens when values end in numbers that run close to that column ('n595 cycles, 28 f', Cercopithecidae pp. 208-210, 212, 216); (3) a second matching pass pairs leftover value and reference (and species) lines up to 8 pt apart when they are mutually nearest, because the OCR y offset between the columns varies down a page (Galagidae p. 185: 0, -5, +7 pt); (4) a reference line appended as a 'continuation' after a reference line WITHOUT a trailing comma is reported as suspect and the run stops unless it is a declared genuine wrap (KNOWN_WRAPS: comma lost by the OCR) -- this is the signature of a value line the OCR dropped (see method:declared_repairs); (5) in-range species/reference lines without a value line stop the run.", role = "method", Reference = paste0(paper, "_accounts")),
  D("method:declared_repairs", paste0("Two declared tables in the script, each row checked on the rendered page image and asserted to apply exactly once. REF_OCR_FIX (", nrow(REF_OCR_FIX), " rows): a reference string damaged in the OCR text layer (e.g. '521\u00b0' = 5210, '690/' = 5907, '11991;' = 11991a, '1 1 A701 U/ ^ 1' = 10721, '7453, 7.' = '7453, 7462, 10086, 10087') is replaced for ref_numbers; line_verbatim keeps the OCR text. DECLARED_VALUE_LINES (", nrow(DECLARED_VALUE_LINES), " rows): the text layer lacked the whole value of a printed line (a lone '1' on Otariidae p. 314, Indriidae p. 182 x3, Pongidae p. 224; 'den emergence: 3-4 wk' Canidae p. 240; 'min 3 yr' Pongidae p. 227) while its species and reference were present; the line is inserted with the value read from the page image, line_verbatim carries [VALUE_FROM_PAGE_IMAGE: ...]. Without the insertion the orphaned reference would have been appended to the previous line's reference list, mis-attributing a citation."), role = "method", Reference = paste0(paper, "_accounts")),
  D("abbrev", "Abbreviation as printed on pp. 5-6 (symbols read from the page image where the OCR lost them)", Reference = paste0(paper, "_abbreviations"), Source = "pdf_by_order/Hayssen_etal_1993_00_FrontMatter.pdf printed pp. 5-6"),
  D("meaning", "Expansion as printed", Reference = paste0(paper, "_abbreviations"), Source = "pdf_by_order/Hayssen_etal_1993_00_FrontMatter.pdf printed pp. 5-6"),
  D("group", "Section heading of the list (general, seasonality, months, location, statistics, Canadian Provinces/Territories, Australian States/Territories, Countries, US States)", "category", Reference = paste0(paper, "_abbreviations"), Source = "pdf_by_order/Hayssen_etal_1993_00_FrontMatter.pdf printed pp. 5-6"),
  D("ref_cited_once", "Reference number cited exactly once in the family whose one-confusable-digit variant (8/6, 8/3, 8/0, 6/0, 6/5, 1/7, 9/0, 3/5, 1/4) is cited >= 2 times in the same family: a candidate OCR digit error that passes the reference guard because both numbers exist (Cheirogaleidae p. 175: 8435 read as 6435). Report only; confirmed errors are repaired in REF_OCR_FIX and leave this file. Rows with variant_cited_often = short_token are a second kind of candidate (wave 3): the line's full ref_numbers string, in which a 1-2 digit token stands beside >= 4-digit ones -- the signature of a number truncated by the OCR ('8700, 8704, 1' for 8706, Phascolarctidae p. 47)", "key", Reference = paste0(paper, "_accounts_ref_suspects")),
  D("cited_once_work", "first_author year of ref_cited_once (and of the other references on the same line)", Reference = paste0(paper, "_accounts_ref_suspects")),
  D("variant_cited_often", "The one-digit variant(s) cited >= 2 times in the family, '|'-joined; variant_n their counts; variant_work their first_author year", Reference = paste0(paper, "_accounts_ref_suspects")),
  D("checked", "Outcome of a page-image check when one was made (SUSPECTS_CHECKED in the script); blank = not yet checked. Triage before rendering: compare cited_once_work's title with the species -- most singletons are genuine (same author, different year; a paper on the right taxon)", Reference = paste0(paper, "_accounts_ref_suspects")),
  D("kind", "Why the line is in the unparsed table: outside_family_range:<type> (previous/next family or order prose on a shared page), species_column_line_without_value_line, reference_column_line_without_value_line, data_line_before_first_topic, data_line_before_first_species_of_topic, page_ocr_unusable (every text-layer line of a declared OCR-unusable page, kept verbatim; see method:wave3_declared_tables)", "category", Reference = paste0(paper, "_accounts_unparsed")),
  D("method:wave3_declared_tables", paste0("Wave 3 (2026-10-24, all remaining orders) added declared tables, each row read from a rendered band of the page image and asserted to apply exactly once: NOISE_WORDS (", nrow(NOISE_WORDS), " specks/marks the OCR read as a word, removed before parsing); DECLARED_REF_WORDS (", nrow(DECLARED_REF_WORDS), " reference numbers printed but absent from the text layer, inserted as word boxes; line_verbatim carries [REF_FROM_PAGE_IMAGE: ...]); DECLARED_SPECIES_WORDS (", nrow(DECLARED_SPECIES_WORDS), " species names absent from the text layer -- Cervidae p. 408 -- inserted; [SPECIES_FROM_PAGE_IMAGE: ...]); DECLARED_WORD_MOVES (", nrow(DECLARED_WORD_MOVES), ": a reference number the book sets in the value column); NO_SPECIES_TEXT_PAGES (", nrow(NO_SPECIES_TEXT_PAGES), " pages with value lines but no species text, each checked: the species continues from the previous page); OCR_UNUSABLE_PAGES (", nrow(OCR_UNUSABLE_PAGES), ": printed p. 634, Muridae LACTATION, text layer unreadable -- NOT transcribed, lines kept verbatim in _accounts_unparsed.csv, species reset after the gap); PRINTED_NOT_IN_BIBLIOGRAPHY (", nrow(PRINTED_NOT_IN_BIBLIOGRAPHY), " numbers the book prints that its bibliography lacks: 8083a, 16052a, 19785, 0000, 10564a -> ref_numbers_resolved FALSE); DUPLICATE_SCAN_PAGES (", nrow(DUPLICATE_SCAN_PAGES), " repeated chapter-opening scan pages dropped after asserting identical text); DECLARED_HEADERS (", nrow(DECLARED_HEADERS), " running header too damaged to match); CONTENTS_OCR_FIX (2 family names in the contents table); ORDER_HEADING_VARIANT (the book prints 'Order Macroscelidae'). Parser rules added: the first page of a monotypic order carries the family heading as its top line; a binomial-led line that does not reach the reference column, or that ends with a reference token, is tabular whatever its gaps; a line between two prose lines running to the right margin is prose; a 'data' line before the family's first topic with prose punctuation is prose; a value line without a reference is not joined to the next line when that line has its own species name (the book prints values without a citation: Cricetidae p. 517 'Akodon longipilis 3.3 g'); a page whose body text starts beyond x 150 has no species column; a 5-digit token beyond the bibliography whose <4 digits>_<digit> form exists is a fused printed subscript (5424\u2082 -> 5424_2); the 10% verbatim_only guard applies to families with >= 30 data lines (smaller ones are reported; Phascolarctidae's 4 lines declared). Reference tokens of the form <number><letter?>_<digit> are the bibliography's subscript inserts."), role = "method", Reference = paste0(paper, "_accounts"))
)
f_def <- file.path(out_dir, paste0(paper, "_accounts_definitions.csv")); write_bom_csv(defs, f_def); written <- c(written, f_def)

## ---- README section ---------------------------------------------------------------------------------------------------------
readme <- file.path(folder, paste0(paper, ".README.md"))
if(!file.exists(readme)) stop("README missing", call.=FALSE)
rl <- readLines(readme, encoding = "UTF-8")
marker <- "## Species accounts (step 2)"
if(any(rl == marker)) { k <- which(rl == marker)[1]; nxt <- which(str_detect(rl, "^## ") & seq_along(rl) > k); rl <- if(length(nxt)) c(rl[1:(k-1)], rl[nxt[1]:length(rl)]) else rl[1:(k-1)] }
fam_lines <- unlist(lapply(names(tables), function(fam) {
  d <- tables[[fam]]; r <- res[[fam]]; ps <- table(factor(d$parse_status[d$topic != "family_overview"], levels = c("parsed", "partial", "verbatim_only")))
  st <- table(d$population_status[d$topic != "family_overview"])
  sprintf("- **%s** (%s; `%s`, slice pages %d–%d, printed pp. %d–%d): `reference_tables/%s_accounts_%s.csv` **%d rows** = %d data lines + %d family_overview rows; parse_status parsed %d / partial %d / verbatim_only %d (%.1f%%); %d distinct printed species, %d resolved through `_keys/resolve_species.R`%s; population_status: %s. Topics: %s.",
          fam, r$order, basename(r$slice$file), r$phys[r$start_page], r$phys[r$end_page], r$printed[r$start_page], r$printed[r$end_page], paper, fam, nrow(d), sum(d$topic != "family_overview"), sum(d$topic == "family_overview"),
          ps[["parsed"]], ps[["partial"]], ps[["verbatim_only"]], 100 * ps[["verbatim_only"]] / sum(ps), n_distinct(d$species_printed, na.rm = TRUE), n_distinct(d$species_msw05, na.rm = TRUE),
          { u <- unique(d$species_printed[!is.na(d$species_printed) & is.na(d$species_msw05)]); if(length(u)) paste0(" (unresolved: ", paste(u, collapse = ", "), ")") else "" },
          paste(sprintf("%s %d", names(st), as.integer(st)), collapse = ", "), paste(r$topics, collapse = ", "))
}))
## per-family counts table (markdown)
fam_table <- c("| family | order | printed pp. | rows | data lines | overview rows | parsed | partial | verbatim_only | % verbatim | species | resolved | n topics | refs resolved | refs declared absent |",
               "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|",
  vapply(names(tables), function(fam) { d <- tables[[fam]]; r <- res[[fam]]; dl <- d %>% filter(topic != "family_overview"); ps <- table(factor(dl$parse_status, levels = c("parsed", "partial", "verbatim_only")))
    toks <- unlist(str_split(d$ref_numbers[nzchar(d$ref_numbers)], ";"))
    sprintf("| %s | %s | %d–%d | %d | %d | %d | %d | %d | %d | %.1f | %d | %d | %d | %d | %d |", fam, r$order, r$printed[r$start_page], r$printed[r$end_page], nrow(d), nrow(dl), nrow(d) - nrow(dl), ps[["parsed"]], ps[["partial"]], ps[["verbatim_only"]], 100 * ps[["verbatim_only"]] / max(1, sum(ps)),
            n_distinct(dl$species_printed), n_distinct(dl$species_msw05, na.rm = TRUE), length(r$topics), sum(toks %in% refs$ref_number), sum(!(toks %in% refs$ref_number))) }, character(1)))
status_lines <- function(x, species) {
  if(nrow(x) == 0) return(c(sprintf("- *%s*: **0 data lines** — the book has no account for this species%s.", species, if(species %in% c("Felis catus", "Canis familiaris")) " (domestic; see method:book_statements_on_domestic_species — domestic-dog data sit under Canis lupus)" else ""), ""))
  tt <- table(x$status_class)
  c(sprintf("- *%s*: %d data lines — %s.", species, nrow(x), paste(sprintf("%s %d", names(tt), as.integer(tt)), collapse = ", ")),
    "", paste0("  | topic | ", paste(colnames(table(x$topic, x$status_class)), collapse = " | "), " |"),
    paste0("  |---|", paste(rep("---", ncol(table(x$topic, x$status_class))), collapse = "|"), "|"),
    { m <- table(x$topic, x$status_class); vapply(rownames(m), function(rn) paste0("  | ", rn, " | ", paste(m[rn, ], collapse = " | "), " |"), character(1)) }, "")
}
sec <- c(marker, "",
  sprintf("Built by `%s_accounts.R` (Rscript; `FAMILIES <- c(%s)`), run date %s. One row per printed data line (one value), each with its own Literature Cited number(s) joined to `reference_tables/%s_references.csv`, plus `family_overview` rows for the parenthesised reference lists in the family prose. Column definitions and the method rows (line grammar, family_overview, population_status rule, the book's own statements on domestic species) are in `reference_tables/%s_accounts_definitions.csv`; the book's abbreviation list (printed pp. 5–6) is `reference_tables/%s_abbreviations.csv` (%d rows).", paper, paste0('"', names(tables), '"', collapse = ", "), format(Sys.Date()), paper, paper, paper, nrow(abbr)),
  "", "### Families done", "", fam_lines, "", sprintf("Per-family counts (%d families, %d rows, %d data lines):", length(tables), sum(vapply(tables, nrow, integer(1))), sum(vapply(tables, function(d) sum(d$topic != "family_overview"), integer(1)))), "", fam_table, "",
  sprintf("Topic headings over all families (%d): %s. New since the Suidae/Mustelidae build: %s.", length(ALL_TOPICS), paste(ALL_TOPICS, collapse = ", "), if(length(NEW_TOPICS)) paste(NEW_TOPICS, collapse = ", ") else "none"), "",
  sprintf("`reference_tables/%s_accounts_unparsed.csv`: %d rows — %s.", paper, nrow(unparsed), paste(sprintf("%s %d", names(table(unparsed$kind)), as.integer(table(unparsed$kind))), collapse = ", ")),
  "", "### Grammar and page handling", "",
  "Data line: `[species] <value>[; qualifier]* <ref>[, <ref>]*`; the species name is printed only on the first line of its run and inherited; a TOPIC heading in capitals resets the species. Pages are three columns (species / value / reference numbers) and the scan is slightly rotated, so one printed line's three columns differ by up to 6 pt (half a line) in the OCR y coordinate and `pdf_text` misplaces the numbers; the script rebuilds lines per column from `pdf_data` word boxes and aligns the columns with a per-page offset (reference column anchored on the first value/reference pair of the page; species column by the offset that maximises matches). Reference lists that wrap (`3571, 4643, 4645, 7979,` / `10499`) and values that wrap are joined. The family range is taken from the body headings `Order X, Family Y` (first page asserted to carry the family heading, every further page asserted to name the family in its running header); lines on shared pages that belong to the neighbouring family or to the order introduction are kept in the unparsed table as `outside_family_range`.",
  "", "Value grammar: optional sex (`f:`, `m:`, `f/m:`) and measure label (`1st mate:`, `wean:`, `birth:`, `HB:`, ...), optional `~`/`est`/comparator, then `mode|max|min`, a number or range, a unit (g, kg, mg, d, wk, mo, yr, h, mm, cm, %) or count word (emb, yg, cl, lt, ps, ...); `;`-separated qualifiers parsed for `rA-B`, `n<k>`, `sd`, `se`, `±`, `mode`. OCR normalisation before parsing: `It`→`lt`, `nl`→`n1`, `rl`→`r1`, `l`→`1` after r/n/sd/se, `I`/`O`→`1`/`0` inside n-tokens; the verbatim OCR text is kept in `line_verbatim`/`value_text`.",
  "", "### Population status rule", "",
  "(1) Book qualifier on the line (`captive`/`zoo` → captive_zoo; `lab`/`domestic`/`farm`/`fur farm` → domestic_laboratory; `feral`; `wild`), basis `book_qualifier:<token>`. (2) Else the cited works' title/journal: `feral` → feral; wild keywords (wild, Wildschwein, Sanglier, jabalí, Schwarzwild, Iltis, polecat, Mammals of, J Mamm, J Wildl Manage, Mammalia, Z Saugetierk, Acta Theriol, field) → wild; domestic keywords (ferret, Frettchen, furo, UFAW, Lab Anim, miniature pig, domestic, Hausschwein, swine, sow/gilt/boar/pig, and the production journals J Anim Sci, Anim Prod, Anim Reprod Sci, Biol Reprod, J Reprod Fert, Theriogenology) → domestic_laboratory; a wild/feral modifier wins over an animal word (`wild boar`, `feral pigs`); several works disagreeing → `mixed:<a>|<b>`, basis `cited_work_title:<ref>=<keyword>`. Keyword matching is whole-word and case-insensitive, except that the stems wild, Wildschwein, Sanglier, jabal, Schwarzwild, Iltis, polecat are matched as word prefixes (Wildlebenden, Schwarzwildes, Iltissen, OCR `jabalf`). (3) Else `unspecified`. The book itself states (printed p. 1) that data for domesticated species such as the pig are generally not listed while their wild counterparts are, and that medical-journal ferret studies are assigned to *Mustela putorius*.",
  "", "### Sus scrofa and Mustela putorius by population status", "",
  status_lines(sus_tab, "Sus scrofa"), status_lines(put_tab, "Mustela putorius"),
  "### Species of interest by population status (wave 2: domestic/laboratory vs wild)", "",
  "The population_status rule is the one above (book qualifier on the line, else keywords in the cited work's title/journal, else unspecified); for primates the production-journal cue (J Reprod Fert, Biol Reprod, Lab Anim) is what marks laboratory-colony studies domestic_laboratory, and `captive`/`zoo` on the line marks captive_zoo. Counts are data lines (family_overview rows excluded).", "",
  unlist(lapply(seq_len(nrow(SPECIES_OF_INTEREST)), function(k) status_lines(soi_tabs[[k]], SPECIES_OF_INTEREST$species[k]))),
  sprintf("*Papio*: the book prints Papio hamadryas, Papio leucophaeus, Papio sphinx and 'Papio spp' — %d data lines in all (%s).", sum(vapply(c("Papio hamadryas", "Papio leucophaeus", "Papio sphinx", "Papio spp"), function(sp) nrow(soi_tabs[[sp]]), integer(1))), paste(sprintf("%s %d", c("Papio hamadryas", "Papio leucophaeus", "Papio sphinx", "Papio spp"), vapply(c("Papio hamadryas", "Papio leucophaeus", "Papio sphinx", "Papio spp"), function(sp) nrow(soi_tabs[[sp]]), integer(1))), collapse = ", ")),
  "", sprintf("*Felis marmorata* (Pardofelis marmorata) — every line (%d; the book has no longevity topic):", nrow(soi_tabs[["Felis marmorata"]])), "",
  "  | topic | value | refs | cited work | population_status | printed p. |", "  |---|---|---|---|---|---|",
  { m <- tables$Felidae %>% filter(species_printed == "Felis marmorata"); sprintf("  | %s | `%s` | %s | %s | %s | %d |", m$topic, m$value_text, m$ref_numbers, m$ref_first_author_year, m$population_status, m$printed_page) },
  "", "*Felis bieti*: no account in the book (0 lines; the Felidae species list has no bieti, and the slice text contains no 'bieti').", "",
  "### Verification", "",
  sprintf("Positive controls asserted by the script: %d *Mustela putorius* lines (NEONATAL MASS `7 g 4643`, `9-10 g 3571`, `~10 g 9344`, `10 g ea; n2 4689`; SEXUAL MATURITY `f: vulvar edema: 30-50 wk 9394`, `f: 1st mate: 6-9 mo 9344`, `m: spermatogenesis: 8 mo 5167`, `f/m: 1 yr 7979`; INTERLITTER INTERVAL `20 wk 9344`; LITTERS/YEAR `1 7979, 10499`, `1; 2 if 1st lt removed 6156`, `2; r0-2 4299`); the *Sus scrofa* GESTATION (20) and LITTER SIZE (18) reference sets; and the *Sus scrofa* status mix (8220, 2973 domestic_laboratory; 473, 10600 feral; 2588, 6979 wild). Page images of every Suidae page and of Mustelidae printed pp. 260–267, 276–277, 285 were rendered and compared with the parsed rows by eye (see the session report for the lines checked).", nrow(CONTROL_LINES)),
  "", "### Wave 2 (2026-10-23): remaining Carnivora and all Primates", "",
  "Grammar changes, each guarded so that the Suidae and Mustelidae tables stay byte-identical to the 2026-10-22 build (SHA-256 asserted in the session report): monotypic-family headings (`Order X, Family Y, Genus Z`) and an OCR-damaged heading name (`Proteiidae`) accepted; running headers matched within edit distance 2 (`Cercopitliecidae`); a single-page last family (Hominidae, p. 228) located by its own heading; three more printed page numbers declared from the page image (Carnivora pp. 319, 321; Primates p. 227); the page margin taken from the running header when a page has no species-column text (Phocidae p. 334); the reference-column anchor recomputed from line-final tokens when values end in numbers (Cercopithecidae pp. 208–210, 212, 216); a mutually-nearest second matching pass up to 8 pt for leftover lines (Primates pp. 177, 185); species-name OCR tolerance (`n/`→`rv`, `!`→`i`, split words, two-species lines, quoted vernacular) with a glyph-aware canonicalisation that keeps Canis rufus / Canis lupus and Panthera uncia / Panthera onca apart. See the method rows `method:family_headings_and_page_range`, `method:column_alignment_wave2`, `method:declared_repairs` in the definitions file.", "",
  sprintf("Declared repairs (page images checked, each asserted to apply exactly once): %d damaged reference strings (REF_OCR_FIX), %d value lines absent from the OCR text layer (DECLARED_VALUE_LINES), %d genuine wrapped reference lists whose comma the OCR lost (KNOWN_WRAPS), %d species-name variants (SPECIES_OCR_FIX), 1 heading variant.", nrow(REF_OCR_FIX), nrow(DECLARED_VALUE_LINES), nrow(KNOWN_WRAPS), nrow(SPECIES_OCR_FIX)), "",
  "  | section | printed p. | OCR reference string | printed | reading |", "  |---|---|---|---|---|",
  sprintf("  | %s | %d | `%s` | `%s` | %s |", REF_OCR_FIX$section, REF_OCR_FIX$printed_page, REF_OCR_FIX$ref_raw_ocr, REF_OCR_FIX$ref_raw_printed, REF_OCR_FIX$reading), "",
  "  | section | printed p. | species | value (from page image) | ref |", "  |---|---|---|---|---|",
  sprintf("  | %s | %d | %s | `%s` | %s |", DECLARED_VALUE_LINES$section, DECLARED_VALUE_LINES$printed_page, coalesce(DECLARED_VALUE_LINES$species, "(inherited)"), DECLARED_VALUE_LINES$value, DECLARED_VALUE_LINES$ref), "",
  sprintf("Reference-number digit plausibility (`reference_tables/%s_accounts_ref_suspects.csv`): %d numbers cited once in a family whose one-confusable-digit variant is cited >= 2 times in the same family (%d on data lines, %d in family_overview prose lists). The 60 data-line suspects whose cited-once work has a different first author from the variant were triaged by title against the species on the line; 6 were rendered: 5 were OCR digit errors (both numbers valid in the bibliography: 6432/6435/6451 for 8432/8435/8451 on Cheirogaleidae p. 175 — a house-mouse, a California-vole and a red-deer paper standing in for the lemur monographs; 2812 for 2612 on Ursidae p. 254; 486 for 466 on Canidae p. 246) and are repaired in REF_OCR_FIX; 1 (Cebidae p. 198, 10809) is printed as cited. The remaining rows are a review list, not findings.", paper, nrow(ref_suspects), sum(ref_suspects$topic != "family_overview"), sum(ref_suspects$topic == "family_overview")), "",
  sprintf("Positive controls for the wave-2 families: %d lines in `CONTROL_LINES` (read from the page images), all asserted. Page images rendered and compared line by line with the parsed rows during the session (every data line of the page unless stated): Felidae pp. 296 (38 lines) and 303 (63; found 11991i = 11991a); Cercopithecidae pp. 209 (57) and 210 (64); Phocidae pp. 321 (64) and 334 (first 28 of 59); Cheirogaleidae p. 175 (58; found the 6432/6435/6451 digit errors). Species, value text and every reference number agreed on all other lines. Also rendered: the repair sites (Canidae pp. 240, 242, 243, 246; Ursidae p. 254; Procyonidae pp. 256, 258; Protelidae p. 293; Otariidae p. 314; Odobenidae p. 319; Lemuridae pp. 177, 178; Indriidae p. 182; Galagidae p. 185; Cebidae p. 201; Pongidae pp. 224, 227).", sum(CONTROL_LINES$family != "Mustelidae")), "",
  "### Wave 3 (2026-10-24): all remaining orders", "",
  sprintf("All %d families of the book are now transcribed (FAMILIES is derived from the contents table). The parser rules and declared tables added for this wave are listed in the definitions row `method:wave3_declared_tables`; every declared row was read from a 120-220 dpi band of the rendered page image during the session. One page is NOT transcribed: printed p. 634 (Muridae, LACTATION, Micromys minutus .. Rattus norvegicus, about 60 lines) -- its text layer is unreadable; the lines are kept verbatim in `_accounts_unparsed.csv` (kind `page_ocr_unusable`) and the page awaits hand transcription from the image.", length(tables)), "",
  sprintf("Declared repairs over the whole book (each asserted to apply exactly once): %d damaged reference strings (REF_OCR_FIX), %d value lines absent from the text layer (DECLARED_VALUE_LINES), %d reference numbers absent from the text layer (DECLARED_REF_WORDS), %d species names absent from the text layer (DECLARED_SPECIES_WORDS), %d genuine wrapped reference lists (KNOWN_WRAPS), %d species-name variants (SPECIES_OCR_FIX), %d noise words (NOISE_WORDS), %d word moved (DECLARED_WORD_MOVES), %d printed page numbers (DECLARED_PAGE_NUMBERS), %d running header (DECLARED_HEADERS), %d duplicate scan pages dropped, %d pages without species text accepted (NO_SPECIES_TEXT_PAGES), %d numbers printed but absent from the bibliography (PRINTED_NOT_IN_BIBLIOGRAPHY).", nrow(REF_OCR_FIX), nrow(DECLARED_VALUE_LINES), nrow(DECLARED_REF_WORDS), nrow(DECLARED_SPECIES_WORDS), nrow(KNOWN_WRAPS), nrow(SPECIES_OCR_FIX), nrow(NOISE_WORDS), nrow(DECLARED_WORD_MOVES), nrow(DECLARED_PAGE_NUMBERS), nrow(DECLARED_HEADERS), nrow(DUPLICATE_SCAN_PAGES), nrow(NO_SPECIES_TEXT_PAGES), nrow(PRINTED_NOT_IN_BIBLIOGRAPHY)), "",
  "  | section | slice page | word removed | reading |", "  |---|---|---|---|",
  sprintf("  | %s | %d | `%s` | %s |", NOISE_WORDS$section, NOISE_WORDS$slice_page, NOISE_WORDS$text, NOISE_WORDS$reading), "",
  "  | section | printed p. | value | reference inserted from the page image |", "  |---|---|---|---|",
  sprintf("  | %s | %d | `%s` | %s |", DECLARED_REF_WORDS$section, DECLARED_REF_WORDS$printed_page, DECLARED_REF_WORDS$value_raw, DECLARED_REF_WORDS$ref), "",
  "  | section | printed p. | species inserted from the page image | on the line |", "  |---|---|---|---|",
  sprintf("  | %s | %d | %s | `%s` |", DECLARED_SPECIES_WORDS$section, DECLARED_SPECIES_WORDS$printed_page, DECLARED_SPECIES_WORDS$text, DECLARED_SPECIES_WORDS$value_raw), "",
  "  | section | printed p. | page without species text: reading |", "  |---|---|---|",
  sprintf("  | %s | %d | %s |", NO_SPECIES_TEXT_PAGES$section, NO_SPECIES_TEXT_PAGES$printed_page, NO_SPECIES_TEXT_PAGES$reading), "",
  "  | section | token printed but not in the bibliography | where |", "  |---|---|---|",
  sprintf("  | %s | %s | %s |", PRINTED_NOT_IN_BIBLIOGRAPHY$section, PRINTED_NOT_IN_BIBLIOGRAPHY$token, PRINTED_NOT_IN_BIBLIOGRAPHY$where), "",
  sprintf("Positive controls for the wave-3 families: %d lines in `CONTROL_LINES` (read from the page-image bands), all asserted. Depth of the visual check for this wave: the bands around every declared repair site, the header strips of the pages whose number the text layer lacks, the TOC pages for the two contents-table name fixes, and whole-page renders of printed pp. 408, 409, 534, 604 (species-column check) and 634 (unusable page). Pages were NOT compared line by line beyond these sites; the structural guards (every page yields rows, running headers name the family, reference tokens resolve, species text is a binomial, values without a reference are reported) are what stands behind the other pages.", sum(CONTROL_LINES$family %in% c("Thylacinidae", "Phascolarctidae", "Peramelidae", "Pteropodidae", "Molossidae", "Vespertilionidae", "Physeteridae", "Elephantidae", "Orycteropodidae", "Camelidae", "Cervidae", "Leporidae", "Geomyidae", "Castoridae", "Arvicolidae", "Cricetidae"))), "",
  "### Known failure modes", "",
  "- Rotated pages: the reference column drifts ~15 pt in x down the page and sits up to 6 pt above/below its value line; handled by the per-column rebuild (a plain y grouping would pair a reference with the neighbouring line).",
  "- OCR letter/digit confusions in qualifiers (`nl`, `It`, `rl`, `sdl.25`, `nIO`): normalised for parsing only.",
  "- `~` is OCR'd as `-` (`-10 g`): read as approximately (`approx = TRUE`).",
  "- A value whose text runs close to the reference column (`... nw Assam, India 8095`) is still split correctly because the split is by x anchor, not by gap.",
  "- Lines whose value is prose-like (`half grown`, `solid food: grass almost at once`) parse as text (`partial`/`verbatim_only`) and are kept.",
  "- Whole short value lines missing from the OCR text layer (a lone `1`, `min 3 yr`, `den emergence: 3-4 wk`) while species and reference survive: the orphaned reference is otherwise appended to the previous line's list. Detected by the suspect-continuation check (previous reference line without a trailing comma) and by in-range leftover lines; both now stop the run until declared. A dropped value whose reference follows a genuinely wrapped list cannot be detected this way.",
  "- A reference number mis-read by one confusable digit into another valid number (8435 -> 6435) passes the reference guard silently; the digit-plausibility report lists candidates, and the step-1 note that 11991i is 'cited but not listed' turned out to be this kind of OCR error (11991a).",
  "- Reference numbers damaged in the text layer (`°` for a final 0, `/` for 7, `;`/`!` for a suffix letter, a list truncated to `7453, 7.`): caught by the token guard and declared from the page image.",
  "- A page whose only species name continues from the previous page has no species-column text; the margin then comes from the running header.",
  "- Values that end in numbers close to the reference column (`n595 cycles, 28 f`) pull the reference anchor left unless it is taken from line-final tokens.",
  "- Species names: `rv` read as `n/`, `i` as `!`, `rn` as `m`, `ri` as `h`, `l` as `t`/`i`, words split by spaces; and the inverse risk — two real species within two edits (Canis rufus/lupus, Panthera uncia/onca) must not be merged, hence the glyph-aware rule.",
  "- The OCR drops whole species names set in light italics (Cervidae p. 408: both names of the page): every line then inherits the previous species silently. Guarded since wave 3: a page with value lines and no species-column text stops the run until the page image is read and the page declared (species continues) or the names inserted.",
  "- A faint scan page (Muridae p. 634) yields a text layer of random glyphs that passes no guard individually; the running-header check caught it ('Oroer Rcvkaas. Familv Monoae'). Declared unusable; transcription from the image pending.",
  "- Specks and stray marks become one-character 'words' in a column (`_`, `•`, `♦`, `'`, `7`) and attach to the neighbouring line as a species, value or reference token; the token and binomial guards catch most, a digit speck (`7`) only shows as a wrong wrapped value.",
  "- The book itself prints things the grammar does not expect: a reference number in the value column (Phalangeridae p. 33), 'for range' after a number in the reference column (Cricetidae p. 539), numbers its bibliography lacks (8083a, 16052a, 19785, 0000, 10564a), values without any citation (Cricetidae p. 517). These are declared, not repaired.",
  "- Two OCR spellings of one unresolved species are canonicalised by genus support, plain letters, then frequency; when both are plain and share the genus the more frequent spelling wins even if it is the damaged one ('Pipistrellus kuhtii' outnumbered 'kuhlii' -- declared in SPECIES_OCR_FIX after the page image). species_binomial_printed keeps each line's own OCR text, so such cases can be re-mapped once Hayssen variant rows enter the species key.",
  "- The keyword rule for population status is a heuristic over titles and journals: Henry 1968 'European wild hogs' (J Wildl Manage) classifies as wild although those are introduced populations; the production-journal cue (J Reprod Fert, Biol Reprod) fires on physiological studies of wild-caught mustelids (stoat, badger, spotted skunk) and marks them domestic_laboratory; the animal word `pig` fires on 'Common bush-pig' (5771, *Potamochoerus*) and on 'Pigs' (9607a, *Babyrousa*). The basis column names the reference and keyword for every classification so these can be audited or re-weighted.",
  "", "### How to re-run, and how a stop is handled", "",
  "`Rscript Hayssen_etal_1993_accounts.R` rebuilds every family (FAMILIES is the contents table; about 5 min). A stop names the family and the guard (page without rows, running header not naming the family, reference token not <number><letter?>, species text not a binomial, unexplained reference continuation, in-range line without a value, page with value lines and no species text, verbatim_only above 10%): render the page (`pdftools::pdf_convert`), read the printed line, and add one row to the matching declared table (REF_OCR_FIX, DECLARED_VALUE_LINES, DECLARED_REF_WORDS, DECLARED_SPECIES_WORDS, NOISE_WORDS, DECLARED_WORD_MOVES, KNOWN_WRAPS, SPECIES_OCR_FIX, DECLARED_PAGE_NUMBERS, DECLARED_HEADERS, NO_SPECIES_TEXT_PAGES, PRINTED_NOT_IN_BIBLIOGRAPHY, OCR_UNUSABLE_PAGES) with the reading; never silence a guard. `HAYSSEN_DEV=\"<family|order>,...\"` runs a subset, collects every stop instead of halting and writes nothing. The 27 wave-1/2 tables are asserted byte-identical across the wave-3 changes (SHA-256 compared in the 2026-10-24 session).",
  "", "### Open items", "",
  "- Printed p. 634 (Muridae, LACTATION, ~60 lines) is not transcribed (OCR unusable); transcribe by hand from the page image into a declared constructed snapshot and bind it.",
  sprintf("- `reference_tables/%s_accounts_ref_suspects.csv` lists %d digit-plausibility candidates and %d short-token candidates over the whole book; only the wave-2 triage (Carnivora, Primates) has been done.", paper, sum(ref_suspects$variant_cited_often != "short_token"), sum(ref_suspects$variant_cited_often == "short_token")),
  "- Species resolution: most non-primate, non-carnivore names are unresolved in `_keys` (no Hayssen spoke yet); species_binomial_printed keeps the OCR text so variant rows can be added later.",
  "")
plan_k <- which(str_detect(rl, "^## Transcription plan"))
if(length(plan_k) != 1) stop("README: the '## Transcription plan' heading was not found exactly once", call.=FALSE)
rl[plan_k] <- sprintf("## Transcription plan (step 1 done — see \"Reference table\"; step 2 done — all %d families of the book, see \"Species accounts (step 2)\"; step 3 — per-order items built by `%s_orders.R`, registry rows in `%s_registry_rows.xlsx`, see \"Registry\")", length(tables), paper, paper)
writeLines(c(rl, if(length(rl) && nzchar(rl[length(rl)])) "" else NULL, sec), readme, useBytes = FALSE)
written <- c(written, readme)
cat("\nWritten:\n"); for(f in written) cat(" ", f, "\n")
cat("DONE\n")
