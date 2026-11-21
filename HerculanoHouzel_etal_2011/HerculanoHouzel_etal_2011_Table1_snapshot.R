## ============================================================================
## HerculanoHouzel_etal_2011_Table1_snapshot.R
##
## Snapshot script for HerculanoHouzel_etal_2011_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item scripts,
## one per item). Method 2 of __HOWTO_make_a_snapshot.md: capture the
## publisher's own machine-readable table.
##
## Source captured: Table 1 of the PubMed Central full text of
## Herculano-Houzel et al. (2011), Brain Behav Evol 78(4):302-314
## (doi:10.1159/000330825; PMCID PMC3237106), frozen in this folder as
## fulltext.html. The PMC HTML is the publisher's digital rendering of the
## printed table (the Europe PMC fullTextXML endpoint returned a server
## error when this snapshot was made, 2026-11-20); the values were
## cross-checked against the publisher PDF
## (Herculano-Houzel-2011-Updated_neuronal_sca.pdf, same folder), whose
## text layer agrees with the PMC rendering on every checkable cell.
## PMC renders the wide table as two side-by-side HTML tables (species
## 1-5 and 6-11); this script stitches them back together on the printed
## row labels. The second HTML table carries no row-label column.
##
## Output: HerculanoHouzel_etal_2011_Table1_snapshot.csv -- the table
## exactly as published (printed row labels, printed species order
## (vernacular names) and verbatim cell strings, e.g. "23.3 ± 5.9",
## "26.88 ± 3.34 × 106", "ca. 500", "n.a."), before any cleaning. Blank
## separator rows between the printed row groups carry no data and are
## dropped. The item script HerculanoHouzel_etal_2011_Table1.R reads
## this file; it never reads the HTML.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and the
## freshly captured table differs from it, this script stops instead of
## overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "HerculanoHouzel_etal_2011_Table1_snapshot.R"   # this file's own name
  argv <- commandArgs(trailingOnly = FALSE)
  f    <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f) && basename(f) == me) return(normalizePath(f))
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    of <- tryCatch(fr[[k]]$ofile, error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && basename(of) == me &&
        file.exists(of)) return(normalizePath(of))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me) return(normalizePath(p))
  }
  ## last resort: sys.source() (build_dataset_item) sets no ofile frame --
  ## find this file by name under the working directory (the repo root)
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) == 1L) return(normalizePath(hits))
  stop("Cannot locate this script; run it with Rscript or from RStudio.")
})
folder <- dirname(script_path)

if (!requireNamespace("xml2", quietly = TRUE))
  stop("Package 'xml2' required.")

html_file <- file.path(folder, "fulltext.html")
snap_file <- file.path(folder, "HerculanoHouzel_etal_2011_Table1_snapshot.csv")
if (!file.exists(html_file)) stop("Missing frozen source: ", html_file)

## ---- capture Table 1 from the PMC HTML --------------------------------------
doc <- xml2::read_html(html_file)
sec <- xml2::xml_find_first(doc, "//section[@id='T1']")
if (inherits(sec, "xml_missing")) stop("No <section id='T1'> in fulltext.html")
tbls <- xml2::xml_find_all(sec, ".//table")
if (length(tbls) != 2L)
  stop("Expected the 2 side-by-side PMC tables for Table 1, found ", length(tbls))

grab <- function(tbl) {
  rows <- xml2::xml_find_all(tbl, ".//tr")
  lapply(rows, function(r) {
    cells <- xml2::xml_find_all(r, "./th | ./td")
    vapply(cells, function(cl) {
      txt <- xml2::xml_text(cl)
      txt <- gsub("\\s+", " ", txt)
      trimws(txt)
    }, character(1))
  })
}
part1 <- grab(tbls[[1]])   # row label + species 1-5
part2 <- grab(tbls[[2]])   # species 6-11, no row-label column
if (length(part1) != length(part2))
  stop("PMC table halves have different row counts: ",
       length(part1), " vs ", length(part2))

stitched <- vector("list", length(part1))
for (i in seq_along(part1)) {
  r1 <- part1[[i]]; r2 <- part2[[i]]
  stitched[[i]] <- if (length(r1) == 1L && length(r2) == 1L) r1 else c(r1, r2)
}
## drop blank separator rows (no data)
stitched <- stitched[vapply(stitched, function(r) any(nzchar(r)), logical(1))]
if (!all(vapply(stitched, length, integer(1)) == 12L))
  stop("Stitched Table 1 is not 12 columns wide on every row.")
if (length(stitched) != 18L)
  stop("Expected 18 rows (header + Number + 16 measure rows), got ",
       length(stitched))

snap <- as.data.frame(do.call(rbind, stitched), stringsAsFactors = FALSE)
names(snap) <- snap[1, ]
snap <- snap[-1, , drop = FALSE]
row.names(snap) <- NULL
names(snap)[1] <- "Measure"

## ---- write, with the frozen-snapshot guard ----------------------------------
if (file.exists(snap_file)) {
  old <- utils::read.csv(snap_file, check.names = FALSE, colClasses = "character",
                         na.strings = "", encoding = "UTF-8")
  same <- identical(dim(old), dim(snap)) &&
          all(mapply(function(a, b) all(a == b), old, snap))
  if (!isTRUE(same))
    stop("Fresh capture differs from the frozen snapshot at ", snap_file,
         " -- refusing to overwrite. Inspect both before replacing it.")
  message("Snapshot already frozen and identical; nothing written.")
} else {
  utils::write.csv(snap, snap_file, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  message("Snapshot written: ", snap_file, " (", nrow(snap), " rows x ",
          ncol(snap), " cols)")
}
