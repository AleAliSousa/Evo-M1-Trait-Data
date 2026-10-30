# Hutsler_etal_2005_extract_snapshot.R -----------------------------------------
# R port of Hutsler_etal_2005_extract_snapshot.py (pdfplumber/pypdf -> pdftools).
#
# Verify the local Hutsler PDF and rebuild its exact Table 1 snapshot.
#
# Figure 3 and Figure 6 snapshots are manually reviewed pixel-boundary captures and
# are intentionally not overwritten here. Use --extract-figures-dir to recover the
# embedded figure JPEGs used by those snapshots.
#
# PORT NOTE: the Python script's optional --extract-figures-dir mode (pulling the
# embedded figure JPEGs out of the PDF with pypdf + PIL) is NOT carried over.
# pdftools can rasterise a page but cannot extract an embedded image, and the
# Figure 3 / Figure 6 snapshots are manually reviewed pixel-boundary captures
# that this script never overwrites in either language. Recover the JPEGs with a
# dedicated PDF tool if they are ever needed again.

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
paper_dir <- dirname(.sp)

suppressPackageStartupMessages({ library(pdftools); library(digest) })

PDF_NAME        <- "Hutsler-2005-Comparative analysis of cortical.pdf"
TABLE1_NAME     <- "Hutsler_etal_2005_Table1_snapshot.csv"
EXPECTED_SHA256 <- "93c8718ba14f86e30eef3fabd135c263f86e1de195239f9a1909cb640da8d665"

txt <- "Primate|Human|Homo sapiens|3|Dartmouth Hitchcock Medical Center
Primate|Gorilla|Gorilla gorilla|1|Harvard Univ.
Primate|Chimpanzee|Pan troglodytes|3|Harvard Univ. (1); Yakovlev Collection (2)
Primate|Rhesus Macaque|Macaca mulatta|4|UC Davis (1); Yakovlev Collection (3)
Primate|Squirrel Monkey|Saimiri sciureus|2|Yakovlev Collection
Carnivore|Dog|Canis (lupus) familiaris|3|Harvard Univ.
Carnivore|Ferret|Mustela furo|1|Smith College
Carnivore|Cat|Felis silvestris catus|2|UC Davis (1); Yakovlev Collection (1)
Rodent|Woodchuck|Marmota monax|1|Harvard Univ.
Rodent|Porcupine|Erethizon dorsatum|1|Harvard Univ.
Rodent|Capybara|Hydrochoerus hydrochaeris|3|Yakovlev Collection
Rodent|Rat|Rattus rattus norwegicus|3|Pfizer, Inc.
Rodent|Guinea Pig|Cavia porcellus|2|Harvard Univ. (1); Yakovlev Collection (1)
Rodent|Mouse|Mus musculus|3|Pfizer, Inc."
table1 <- read.delim(text = txt, sep = "|", header = FALSE, quote = "",
                     colClasses = "character", check.names = FALSE,
                     stringsAsFactors = FALSE)
names(table1) <- c("order_printed", "common_name_printed", "scientific_name_printed",
                   "n_specimens", "source_printed")
stopifnot(nrow(table1) == 14L, ncol(table1) == 5L)

## 1. VERIFY THE PDF IS THE EXPECTED FILE ----------------------------
pdf_path <- file.path(paper_dir, PDF_NAME)
checksum <- digest(file = pdf_path, algo = "sha256")
if (!identical(checksum, EXPECTED_SHA256))
  stop(sprintf("Unexpected PDF checksum: %s", checksum), call. = FALSE)

## 2. VERIFY EVERY TRANSCRIBED TOKEN IS ON THE PAGE -------------------
pages <- pdf_text(pdf_path)
if (length(pages) != 11L)
  stop(sprintf("Expected 11 pages, found %d", length(pages)), call. = FALSE)
squish <- function(s) paste(strsplit(trimws(s), "[[:space:]]+")[[1]], collapse = " ")
page3 <- squish(pages[3])
for (i in seq_len(nrow(table1))) {
  for (token in unlist(table1[i, c("common_name_printed", "scientific_name_printed",
                                   "n_specimens", "source_printed")])) {
    if (!grepl(squish(token), page3, fixed = TRUE))
      stop(sprintf("Table 1 token missing from PDF text layer: '%s'", token), call. = FALSE)
  }
}

## 3. WRITE THE SNAPSHOT ---------------------------------------------
## Python's csv.writer defaults are QUOTE_MINIMAL and CRLF line endings; R's
## write.csv quotes every character field, so the rows are assembled by hand.
## On this table only "Pfizer, Inc." needs quoting.
csv_field <- function(x) ifelse(grepl('[,"\r\n]', x), paste0('"', gsub('"', '""', x), '"'), x)
lines <- c(paste(csv_field(names(table1)), collapse = ","),
           apply(table1, 1L, function(r) paste(csv_field(r), collapse = ",")))
target <- file.path(paper_dir, TABLE1_NAME)
con <- file(target, open = "wb")
writeLines(lines, con, sep = "\r\n")
close(con)

message(sprintf("Verified PDF and wrote %s (%d rows; checksum %s)",
                target, nrow(table1), checksum))
