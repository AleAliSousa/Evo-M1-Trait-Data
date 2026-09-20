## Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999).
## A neuronal morphologic type unique to humans and great apes.
## Proc Natl Acad Sci USA 96(9):5268-5273. PMC21853.
##
## Source -> frozen snapshot. Scrapes the open-access PMC HTML (snapshot HOWTO,
## method 2) and writes the two frozen copies BEFORE any cleaning:
##   Nimchinsky_etal_1999_Table1_snapshot.xlsx   (sheet "Table1", bold preserved)
##   Nimchinsky_etal_1999_Table2_snapshot.csv
##
## Table 1 is written as .xlsx because its caption defines a value by typography:
## "Spindle cells ... are observed with certainty only among hominoids, in all
## extant pongid and hominid species (shown in bold)". CSV cannot hold that, so
## per __HOWTO_make_a_snapshot.md ("Choosing the format") Excel is the faithful
## medium here. Table 2 is flat text and stays CSV.
##
## No table values are typed into this script. The only printed literals are the
## two suborder names and the three clade names the caption itself names, used as
## anchors to verify the scrape (the Jacob_etal_2021 pattern).
##
## Refuses to overwrite a differing frozen copy: it writes *_REBUILD.* alongside
## and stops, so the difference can be read before anything is replaced.

library(rvest)
library(xml2)
library(openxlsx)
library(readxl)

options(stringsAsFactors = FALSE)

## The live page (and this script's own literal non-breaking-space character) uses
## non-ASCII whitespace (NBSP, EM SPACE tree indentation, THIN SPACE around "+/-"). Under
## the C locale, gsub()/grepl() on a literal multibyte pattern -- or [[:space:]] trying to
## classify one -- errors or silently fails to match. Try common UTF-8 locale names; a
## failure here is non-fatal (a later gsub will raise a clearer error if it actually matters).
for (loc in c("en_US.UTF-8", "en_GB.UTF-8", "C.UTF-8", "UTF-8")) {
  if (isTRUE(tryCatch(Sys.setlocale("LC_CTYPE", loc), error = function(e) FALSE) == loc)) break
}

## ---- paths: self-contained (Rscript or RStudio) ----
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
folder <- dirname(.sp)
setwd(folder)

src_url   <- "https://pmc.ncbi.nlm.nih.gov/articles/PMC21853/"
local_html<- "Nimchinsky_etal_1999_PMC21853.html"   # optional offline copy of the page
t1_xlsx   <- "Nimchinsky_etal_1999_Table1_snapshot.xlsx"
t2_csv    <- "Nimchinsky_etal_1999_Table2_snapshot.csv"

## ---- 1. get the page (local copy preferred, so the build survives the URL) ----
## Sweep 2026-09-18 failed here with "table not found on the page: section#T1 table" while the
## live page still carried the section (verified the same evening): PMC had answered the
## unattended request with a non-article page (rate-limit / bot interstitial). read_html() on a
## URL swallows the HTTP status, so that page parsed "fine" and only the selector failed. Now:
## fetch with an explicit status check, retry once, and FREEZE the page as `local_html` on the
## first good fetch so every later run is offline and deterministic (snapshot HOWTO method 2).
fetch_html <- function(url, tries = 2L) {
  for (i in seq_len(tries)) {
    r <- tryCatch(curl::curl_fetch_memory(url), error = function(e) NULL)
    if (!is.null(r) && r$status_code == 200L) {
      html <- rawToChar(r$content); Encoding(html) <- "UTF-8"
      if (grepl('id="T1"', html, fixed = TRUE)) return(html)
      message("  fetched page has no Table 1 section (non-article response from PMC)")
    } else message("  HTTP ", if (is.null(r)) "error" else r$status_code, " from PMC")
    if (i < tries) Sys.sleep(5)
  }
  stop("could not fetch the article page from ", url,
       "\n  PMC rate-limits unattended clients. Re-run later, or save the page from a browser as\n  ",
       local_html, " next to this script (the local copy is always preferred).", call. = FALSE)
}
doc <- if (file.exists(local_html)) {
  message("reading local copy: ", local_html)
  read_html(local_html, encoding = "UTF-8")
} else {
  message("fetching: ", src_url)
  html <- fetch_html(src_url)
  writeLines(html, local_html, useBytes = TRUE)
  message("frozen page written: ", local_html)
  read_html(html)
}

## ---- 2. read a table element into text + bold flags, nothing else ----
read_tbl <- function(doc, css) {
  tbl <- html_element(doc, css)
  if (inherits(tbl, "xml_missing")) stop("table not found on the page: ", css)
  rows <- html_elements(tbl, "tr")
  out <- lapply(rows, function(r) {
    cells <- html_elements(r, "td, th")
    txt <- vapply(cells, function(c) {
      s <- html_text2(c)
      s <- gsub("\u00a0", " ", s)          # non-breaking space -> space
      trimws(gsub("[[:space:]]+", " ", s))
    }, character(1))
    bold <- vapply(cells, function(c) length(html_elements(c, "b, strong")) > 0, logical(1))
    list(txt = txt, bold = bold)
  })
  ncol <- max(vapply(out, function(x) length(x$txt), integer(1)))
  pad <- function(v, fill) c(v, rep(fill, ncol - length(v)))
  list(
    txt  = do.call(rbind, lapply(out, function(x) pad(x$txt,  ""))),
    bold = do.call(rbind, lapply(out, function(x) pad(x$bold, FALSE)))
  )
}

## ---- 3. Table 1 ----
t1 <- read_tbl(doc, "section#T1 table")
stopifnot(identical(as.character(t1$txt[1, ]), c("Taxonomy", "Spindle cells", "N")))
stopifnot(nrow(t1$txt) == 49L)                       # header + 48 printed rows

body_txt  <- t1$txt[-1, , drop = FALSE]
body_bold <- t1$bold[-1, , drop = FALSE]
# read_tbl() pads short rows (clade/family header rows with only 1 printed cell) with
# "" via pad(), not NA, so nzchar() (FALSE for "") is the right species/non-species test
# here -- confirmed against a fresh run, not assumed.
is_species <- nzchar(body_txt[, 2])
stopifnot(sum(is_species) == 28L)                    # "28 primate species" (Specimens)

## the caption's claim, checked rather than assumed:
##   bold marks exactly the taxa with spindle cells present.
clades_in_bold <- c("Hominoidea", "Pongidae", "Hominidae")   # named in the caption
row_bold <- body_bold[, 1]
stopifnot(all(row_bold[is_species] == (body_txt[is_species, 2] != "None")))
stopifnot(setequal(body_txt[!is_species & row_bold, 1], clades_in_bold))

## write the frozen copy, bold and row order as printed
wb <- createWorkbook()
addWorksheet(wb, "Table1")
writeData(wb, "Table1", as.data.frame(t1$txt[-1, , drop = FALSE]),
          startRow = 2, colNames = FALSE)
writeData(wb, "Table1", as.data.frame(t(t1$txt[1, ])), startRow = 1, colNames = FALSE)
addStyle(wb, "Table1", createStyle(textDecoration = "bold"),
         rows = 1, cols = 1:3, gridExpand = TRUE)
for (i in which(row_bold)) {
  addStyle(wb, "Table1", createStyle(textDecoration = "bold"),
           rows = i + 1L, cols = 1:3, gridExpand = TRUE)
}
setColWidths(wb, "Table1", cols = 1:3, widths = c(30, 18, 8))

if (file.exists(t1_xlsx)) {
  old <- as.matrix(read_excel(t1_xlsx, sheet = "Table1", col_types = "text",
                              col_names = TRUE, .name_repair = "minimal"))
  old[is.na(old)] <- ""
  new <- t1$txt[-1, , drop = FALSE]
  if (!identical(unname(old), unname(new))) {
    saveWorkbook(wb, sub("\\.xlsx$", "_REBUILD.xlsx", t1_xlsx), overwrite = TRUE)
    stop("Frozen Table 1 differs from the page. Wrote *_REBUILD.xlsx; compare before replacing.")
  }
  message("Table 1: frozen copy matches the page.")
} else {
  saveWorkbook(wb, t1_xlsx, overwrite = FALSE)
  message("Table 1: frozen copy written.")
}

## ---- 4. Table 2 ----
t2 <- read_tbl(doc, "section#T2 table")
stopifnot(identical(as.character(t2$txt[1, ]),
                    c("Species", "Pyramidal cells", "Spindle cells", "Fusiform cells")))
stopifnot(nrow(t2$txt) == 6L)                        # header + 5 hominoid species

if (file.exists(t2_csv)) {
  old <- as.matrix(read.csv(t2_csv, header = FALSE, colClasses = "character",
                            check.names = FALSE, encoding = "UTF-8"))
  if (!identical(unname(old), unname(t2$txt))) {
    write.table(t2$txt, sub("\\.csv$", "_REBUILD.csv", t2_csv), sep = ",",
                row.names = FALSE, col.names = FALSE, qmethod = "double",
                fileEncoding = "UTF-8")
    stop("Frozen Table 2 differs from the page. Wrote *_REBUILD.csv; compare before replacing.")
  }
  message("Table 2: frozen copy matches the page.")
} else {
  write.table(t2$txt, t2_csv, sep = ",", row.names = FALSE, col.names = FALSE,
              qmethod = "double", fileEncoding = "UTF-8")
  message("Table 2: frozen copy written.")
}
