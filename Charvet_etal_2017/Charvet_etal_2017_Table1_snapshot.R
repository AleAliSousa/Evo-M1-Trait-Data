## Freeze printed Table 1 from PDF page 3, preserving its row order and units.
me <- "Charvet_etal_2017_Table1_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- sub("_snapshot\\.R$", "", me)
pdf <- file.path(folder, "Charvet-2017-Combining diffusion magnetic reso.pdf")
lines <- strsplit(pdftools::pdf_text(pdf)[3], "\n", fixed = TRUE)[[1]]
start <- grep("^Paca[[:space:]]{2,}Agouti paca", trimws(lines))
end <- grep("^Manatee[[:space:]]{2,}Trichechus manatus", trimws(lines))
stopifnot(length(start) == 1L, length(end) == 1L, end - start == 24L)
cells <- lapply(lines[start:end], function(line)
  strsplit(trimws(line), "[[:space:]]{2,}", perl = TRUE)[[1]])
stopifnot(all(lengths(cells) == 4L))
snapshot <- as.data.frame(do.call(rbind, cells), stringsAsFactors = FALSE)
names(snapshot) <- c("Common name", "Species", "Upper-layer neuron numbers x 10^6",
                     "Lower-layer neuron numbers x 10^6")
out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(out)) {
  old <- utils::read.csv(out, check.names = FALSE, colClasses = "character")
  if (!identical(old, snapshot)) stop("Frozen snapshot differs from PDF extraction")
} else {
  utils::write.csv(snapshot, out, row.names = FALSE, fileEncoding = "UTF-8")
}
cat(item_name, ": ", nrow(snapshot), " source-order rows\n", sep = "")
