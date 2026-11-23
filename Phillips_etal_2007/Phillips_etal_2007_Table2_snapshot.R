## ============================================================================
## Phillips_etal_2007_Table2_snapshot.R
##
## Snapshot script for Phillips_etal_2007_Table2 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). The source is born-digital, so the snapshot
## is captured programmatically from the frozen PMC full text
## (fulltext.xml, JATS XML of PMC1945086) -- the digital-native
## pattern: no PDF geometry is involved and no value is typed by hand.
##
## Source captured: Table 2 of Phillips, Sherwood & Lilak (2007),
## "Corpus callosum morphology in capuchin monkeys is influenced by
## sex and handedness", PLoS ONE 2(8):e792
## (doi:10.1371/journal.pone.0000792) -- the size-adjusted corpus
## callosum measures (sqrt(area) / cbrt(brain volume)) with age,
## tube-task MHI and dextral group for the same 18 capuchins as
## Table 1. MHI and dextral group are blank in the XML for the 5
## animals that were not in the behavioural sample; the blanks are
## captured as empty cells, as published.
##
## Output: Phillips_etal_2007_Table2_snapshot.csv -- the table exactly
## as published: 18 subject rows in printed order under the printed
## headings. Negative values carry the XML's U+2212 minus and several
## values print without a leading zero (".525"); both forms are kept
## verbatim here and normalised only in the build.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Phillips_etal_2007_Table2_snapshot.R"
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
  stop("Cannot locate ", me, " -- run it with Rscript <path>.")
})
folder <- dirname(script_path)
base   <- sub("_snapshot\\.R$", "", basename(script_path))

xml_path <- file.path(folder, "fulltext.xml")
if (!file.exists(xml_path)) stop("PMC full text not found in ", folder)
doc <- xml2::read_xml(xml_path)
clean <- function(x) trimws(gsub("\\s+", " ", xml2::xml_text(x)))
wraps <- xml2::xml_find_all(doc, "//*[local-name()='table-wrap']")
labs <- vapply(wraps, function(w)
  clean(xml2::xml_find_first(w, "./*[local-name()='label']")), character(1))
tw <- wraps[[which(labs == "Table 2")]]
tbl <- xml2::xml_find_first(tw, "./*[local-name()='table']")
rows <- xml2::xml_find_all(tbl, ".//*[local-name()='tr']")
grid <- do.call(rbind, lapply(rows, function(tr) {
  cells <- xml2::xml_find_all(tr, "./*[local-name()='td' or local-name()='th']")
  vapply(cells, clean, character(1))
}))
hdr <- grid[1, ]
snap <- as.data.frame(grid[-1, , drop = FALSE], stringsAsFactors = FALSE)
names(snap) <- hdr
row.names(snap) <- NULL
stopifnot(identical(hdr, c("Subject", "Sex", "Age", "Overall CC", "Rostrum",
                           "Genu", "Rostral body", "Anterior midbody",
                           "Posterior midbody", "Isthmus", "Splenium", "MHI",
                           "Dextral Group")),
          nrow(snap) == 18L)
expected_subjects <- c("Alou", "Carlos", "DiMaggio", "Miro", "Sabro", "Shiro",
                       "Shoeless", "Sosa", "Vincent", "M21-02", "DC", "Georgia",
                       "Gizmo", "Jake", "LC", "Noel", "M57-04", "M58-04")
if (!identical(snap$Subject, expected_subjects))
  stop("Captured subjects do not match the printed table's rows, in order.")
stopifnot(identical(snap$`Overall CC`[1], "1.86"),
          identical(snap$MHI[5], ""), identical(snap$`Dextral Group`[18], ""))

out_path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(out_path)) {
  old <- utils::read.csv(out_path, check.names = FALSE, colClasses = "character")
  if (!identical(as.matrix(old), as.matrix(snap)))
    stop("Frozen snapshot exists and differs from a fresh capture: ", out_path)
  cat("Snapshot already frozen and identical: ", out_path, "\n", sep = "")
} else {
  utils::write.csv(snap, out_path, row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  cat("Wrote ", out_path, ": ", nrow(snap), " rows (verbatim).\n", sep = "")
}
