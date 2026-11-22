## Capture the full two-page printed Table 2, preserving section and column order.
me <- "Sarko_etal_2009_Table2_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(script_path)
base <- sub("_snapshot\\.R$", "", me)
pdf <- file.path(folder, "Sarko-2009-Cellular scaling rul.pdf")
pages <- pdftools::pdf_text(pdf)
lines <- unlist(strsplit(pages[6:7], "\n", fixed = TRUE), use.names = FALSE)
groups <- c("TOTAL CORTEX", "TOTAL HIPPOCAMPUS", "TOTAL OLFACTORY BULBS",
            "CEREBELLUM", "REMAINING AREAS")
first <- c("Smoky", "Short-tailed", "Hairy-tailed", "Star-nosed", "Eastern")
last <- c("shrew", "shrew", "mole", "mole", "mole")
records <- list()
group <- 0L
for (i in seq_along(lines)) {
  line <- trimws(lines[i])
  if (line %in% groups) {
    group <- match(line, groups)
    records[[length(records) + 1L]] <- c(line, rep("", 13L))
  } else if (group > 0L && any(startsWith(line, first))) {
    parts <- trimws(strsplit(line, "\\s{2,}")[[1]])
    tail <- trimws(strsplit(trimws(lines[i + 1L]), "\\s{2,}")[[1]])
    who <- match(parts[1], first)
    stopifnot(length(parts) == 14L, length(tail) == 13L,
              tail[1] == last[who], all(grepl(" ±$", parts[3:14])))
    records[[length(records) + 1L]] <- c(paste(parts[1], tail[1]), parts[2],
      paste(parts[3:14], tail[2:13]))
  }
}
stopifnot(length(records) == 30L, all(lengths(records) == 14L))
snap <- as.data.frame(do.call(rbind, records), stringsAsFactors = FALSE)
names(snap) <- c("Species", "n", "Brain structure mass (M, g)",
 "Percentage of total brain mass contained in structure (%MBR, %)",
 "Total number of cells (Nc, ×106)", "Number of cells per milligram of tissue in structure (Dc, ×103)",
 "Percentage of total brain cells contained in structure (%NcBR, %)",
 "Percentage of total cells in structure that are neurons (%Nn, %)",
 "Number of neurons in structure (Nn, ×106)",
 "Number of neurons per milligram of tissue in structure (Dn, ×103)",
 "Percentage of total brain neurons contained in structure (%NnBR, %)",
 "Number of non-neurons in structure (Nnn, ×106)",
 "Number of non-neurons per milligram of tissue in structure (Dnn, ×103)",
 "Percentage of total brain non-neurons located within structure (%NnnBR, %)")
path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(path)) stop("Frozen snapshot exists: ", path)
utils::write.csv(snap, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
