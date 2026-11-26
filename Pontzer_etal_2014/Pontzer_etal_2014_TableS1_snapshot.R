# Capture the printed Table S1 from page 7 of the supplied supporting PDF.
# This script writes only the frozen, source-order snapshot. It does not
# normalize labels, convert units, or create analysis/public data.
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(a) != 1L) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a)))
item_name <- sub("_snapshot\\.R$", "", basename(sub("^--file=", "", a)))
pdf <- file.path(folder, "pnas.201316940si.pdf")
if (!file.exists(pdf)) stop("Supporting PDF is missing")
txt <- tempfile(fileext = ".txt")
on.exit(unlink(txt), add = TRUE)
status <- system2("pdftotext", c("-f", "7", "-l", "7", "-layout",
                                  shQuote(pdf), shQuote(txt)))
if (!identical(status, 0L)) stop("pdftotext failed")
lines <- readLines(txt, warn = FALSE, encoding = "UTF-8")
start <- grep("^Table S1\\. Additional information for primate TEE samples", lines)
first <- grep("^M\\. murinus[[:space:]]+Wild", lines)
last <- grep("^G\\. gorilla[[:space:]]+Zoo", lines)
if (length(start) != 1L || length(first) != 1L || length(last) != 1L ||
    !(start < first && first < last)) stop("Table S1 boundaries changed")
body <- lines[first:last]
body <- body[nzchar(trimws(body))]

cols <- c("Species", "Population", "N", "Mean age, y",
          "Body mass Mean, kg", "Body mass SD", "Body mass Range",
          "TEE Mean, kcal/d", "TEE SD", "TEE Range", "Notes")
rows <- list()
for (line in body) {
  fields <- strsplit(trimws(line), "[[:space:]]{2,}", perl = TRUE)[[1]]
  if (length(fields) >= 10L) {
    if (length(fields) == 10L) fields <- c(fields, "")
    if (length(fields) != 11L) stop("Unexpected number of fields: ", line)
    rows[[length(rows) + 1L]] <- fields
  } else {
    if (!length(rows)) stop("Continuation before first row")
    # The PDF wraps long species, population, and note cells. Preserve the
    # printed words while joining a wrapped cell to its row.
    extra <- function(a, b) trimws(substr(line, a, b))
    for (j in c(1L, 2L, 11L)) {
      part <- switch(as.character(j), `1` = extra(1, 20),
                     `2` = extra(21, 36), `11` = extra(127, nchar(line)))
      if (nzchar(part)) rows[[length(rows)]][j] <-
        paste(rows[[length(rows)]][j], part)
    }
  }
}
snapshot <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE,
                          check.names = FALSE)
names(snapshot) <- cols
stopifnot(nrow(snapshot) == 19L,
          identical(snapshot$Species[c(1, 19)], c("M. murinus", "G. gorilla")),
          identical(snapshot$N[17], "195"),
          identical(snapshot$Species[2], "Lepilemur ruficaudatus"),
          identical(snapshot$Population[10], "Research station"))
write.csv(snapshot, file.path(folder, paste0(item_name, "_snapshot.csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat(item_name, ": captured ", nrow(snapshot), " printed rows\n", sep = "")
