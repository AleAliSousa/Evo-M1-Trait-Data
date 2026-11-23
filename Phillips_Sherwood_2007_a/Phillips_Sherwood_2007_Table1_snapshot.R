## ============================================================================
## Phillips_Sherwood_2007_Table1_snapshot.R
##
## Snapshot script for Phillips_Sherwood_2007_Table1 -- writes ONLY the
## snapshot (house rule: snapshot scripts are separate from item
## scripts, one per item). Method 3 of __HOWTO_make_a_snapshot.md:
## extract the table programmatically from the PDF.
##
## Source captured: Table 1 of Phillips & Sherwood (2007), "Cerebral
## petalias and their relationship to handedness in capuchin monkeys
## (Cebus apella)", Neuropsychologia 45(10):2398-2401
## (doi:10.1016/j.neuropsychologia.2007.02.021), from the NIH-PA
## author manuscript PDF frozen in this folder (Phillips-2007-Cerebral
## petalias an.pdf; the table is on PDF page 9). This is the author
## manuscript, not the publisher version; values are captured as in
## the manuscript. (The repo's Phillips_Sherwood_2007_b folder holds a
## second copy of this same manuscript, not another paper.)
##
## Geometry: the table is printed ROTATED 90 degrees on the page.
## In the PDF's word geometry (poppler pdftotext -bbox) the printed
## columns run as horizontal bands of constant yMin (the column
## headings sit at xMin < 120) and the 13 printed rows run as slots
## of constant xMin, 8 pt apart starting at xMin 126. The extraction
## assigns every data word (xMin >= 126) to its band and slot and
## types NO value by hand; the printed row order is asserted on the
## subject names.
##
## Output: Phillips_Sherwood_2007_Table1_snapshot.csv -- the table
## exactly as published: 13 subject rows in printed order under the
## printed headings. Negative values carry the printed U+2212 minus;
## the build script converts them to ASCII for analysis.
##
## Guard (Jacob_etal_2021 pattern): if a snapshot already exists and
## the freshly captured table differs from it, this script stops
## instead of overwriting the frozen copy.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "Phillips_Sherwood_2007_Table1_snapshot.R"
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

pdf_path <- file.path(folder, "Phillips-2007-Cerebral petalias an.pdf")
if (!file.exists(pdf_path))
  stop("Author manuscript PDF not found in ", folder)
if (!nzchar(Sys.which("pdftotext")))
  stop("pdftotext (poppler) not found on PATH -- it provides the word geometry.")

## ---- word geometry of PDF page 9 (the rotated table) --------------------------
bbox <- paste(system2("pdftotext", c("-f", "9", "-l", "9", "-bbox",
                                     shQuote(pdf_path), "-"),
                      stdout = TRUE),
              collapse = "\n")
hits <- regmatches(bbox, gregexpr(
  '<word xMin="[0-9.]+" yMin="[0-9.]+" xMax="[0-9.]+" yMax="[0-9.]+">[^<]*</word>',
  bbox))[[1]]
num <- function(h, attr) as.numeric(sub(paste0('.*', attr, '="([0-9.]+)".*'), "\\1", h))
words <- data.frame(
  x = num(hits, "xMin"), y = num(hits, "yMin"),
  text = sub(".*>([^<]*)</word>", "\\1", hits), stringsAsFactors = FALSE)

## Printed columns as yMin bands; printed rows as xMin slots.
bands <- list(
  "Subject"                       = c(613, 623),
  "Sex"                           = c(573, 583),
  "Age"                           = c(532, 542),
  "MHI"                           = c(486, 496),
  "z-score"                       = c(436, 446),
  "Dextral Group"                 = c(360, 370),
  "Anterior Frontal Petalia AQ"   = c(301, 311),
  "Posterior Frontal Petalia AQ"  = c(241, 251),
  "Parietal Petalia AQ"           = c(150, 160),
  "Occipital Petalia AQ"          = c(55, 65))
dat <- words[words$x >= 126 & words$x < 240, ]
slot <- floor((dat$x - 126) / 8) + 1
stopifnot(all(slot %in% 1:13))

cols <- lapply(names(bands), function(nm) {
  w <- dat[dat$y >= bands[[nm]][1] & dat$y <= bands[[nm]][2], ]
  s <- slot[dat$y >= bands[[nm]][1] & dat$y <= bands[[nm]][2]]
  stopifnot(nrow(w) == 13L, all(sort(s) == seq_len(13L)))
  w$text[order(s)]
})
snap <- as.data.frame(cols, stringsAsFactors = FALSE)
names(snap) <- names(bands)
snap <- snap[, c("Subject", "Sex", "Age", "MHI", "z-score", "Dextral Group",
                 "Anterior Frontal Petalia AQ", "Posterior Frontal Petalia AQ",
                 "Parietal Petalia AQ", "Occipital Petalia AQ")]

expected_subjects <- c("Alou", "Carlos", "DC", "DiMaggio", "Georgia", "Gizmo",
                       "Jake", "LC", "Miro", "Noel", "Shoeless", "Sosa",
                       "Vincent")
if (!identical(snap$Subject, expected_subjects))
  stop("Captured subjects do not match the printed table's rows, in order.")
M <- "−"
stopifnot(identical(snap$Sex, c("M", "M", "F", "M", "F", "F", "F", "F", "M",
                                "F", "M", "M", "M")),
          identical(snap$MHI[1], "0.81"),
          identical(snap$MHI[13], paste0(M, "1.00")),
          identical(snap$`z-score`[13], paste0(M, "14.59")),
          identical(snap$`Dextral Group`,
                    c("R", "L", "R", "R", "L", "R", "R", "R", "R", "L", "A",
                      "L", "L")),
          identical(snap$`Anterior Frontal Petalia AQ`[1], paste0(M, "10.53")),
          identical(snap$`Occipital Petalia AQ`[8], paste0(M, "7.41")))

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
