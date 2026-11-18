## ============================================================================
## Beatty_Laughlin_2006_Table1_snapshot.R
##
## Snapshot script for Beatty_Laughlin_2006_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item scripts,
## one per item). Method 2 of __HOWTO_make_a_snapshot.md: capture the
## publisher's own machine-readable table.
##
## Source captured: Table 1 of the Europe PMC full-text XML of
## Beatty J, Laughlin RE (2006), BMC Neuroscience 7:16
## (doi:10.1186/1471-2202-7-16; PMCID PMC1402304), frozen in this folder as
## fulltext.xml. The XML table is the publisher's digital rendering of the
## printed table; the values were cross-checked against the publisher PDF
## (1471-2202-7-16.pdf, same folder) when the snapshot was made.
##
## Output: Beatty_Laughlin_2006_Table1_snapshot.csv -- the table exactly as
## published (printed column headers, strain order and values, in mm3),
## before any cleaning. The item script Beatty_Laughlin_2006_Table1.R reads
## this file; it never reads the XML.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and the
## freshly captured table differs from it, this script stops instead of
## overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Beatty_Laughlin_2006_Table1_snapshot.R"   # this file's own name
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

## ---- capture Table 1 from the frozen full-text XML --------------------------
doc   <- xml2::read_xml(file.path(folder, "fulltext.xml"))
tw    <- xml2::xml_find_first(doc, "//*[local-name()='table-wrap'][@id='T1']")
if (inherits(tw, "xml_missing")) stop("table-wrap T1 not found in fulltext.xml")
cell_text <- function(node)
  trimws(xml2::xml_text(node))
## (the publisher's JATS marks the header cells up as <td>, not <th>)
header <- vapply(xml2::xml_find_all(
                   tw, ".//*[local-name()='thead']//*[local-name()='tr']/*[local-name()='td' or local-name()='th']"),
                 cell_text, character(1))
body_rows <- xml2::xml_find_all(tw, ".//*[local-name()='tbody']//*[local-name()='tr']")
tab <- do.call(rbind, lapply(body_rows, function(tr)
  vapply(xml2::xml_find_all(tr, "./*[local-name()='td']"), cell_text, character(1))))
stopifnot(ncol(tab) == length(header), nrow(tab) == 36L)
colnames(tab) <- header
snapshot <- as.data.frame(tab, stringsAsFactors = FALSE)

## ---- write the snapshot (refusing to overwrite a differing frozen copy) ----
snapshot_file <- file.path(folder, "Beatty_Laughlin_2006_Table1_snapshot.csv")
if (file.exists(snapshot_file)) {
  existing <- utils::read.csv(snapshot_file, colClasses = "character",
                       check.names = FALSE, stringsAsFactors = FALSE)
  if (!identical(existing, snapshot))
    stop("Frozen snapshot already exists and differs from the captured ",
         "table; refusing to overwrite: ", snapshot_file)
  message("Snapshot already frozen and identical; nothing written.")
} else {
  utils::write.csv(snapshot, snapshot_file, row.names = FALSE, quote = FALSE)
  message("Snapshot written: ", snapshot_file)
}
