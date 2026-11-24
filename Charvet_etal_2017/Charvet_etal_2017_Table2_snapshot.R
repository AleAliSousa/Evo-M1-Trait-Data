## Freeze printed Table 2 from PDF page 4, with three verified text-layer corrections.
me <- "Charvet_etal_2017_Table2_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- sub("_snapshot\\.R$", "", me)
pdf <- file.path(folder, "Charvet-2017-Combining diffusion magnetic reso.pdf")
lines <- strsplit(pdftools::pdf_text(pdf)[4], "\n", fixed = TRUE)[[1]]
start <- grep("^Red panda[[:space:]]{2,}Ailurus fulgens", trimws(lines))
end <- grep("^Rat[[:space:]]{2,}Rattus norvegicus", trimws(lines))
stopifnot(length(start) == 1L, length(end) == 1L)
cells <- lapply(lines[start:end], function(line)
  strsplit(trimws(line), "[[:space:]]{2,}", perl = TRUE)[[1]])
cells <- cells[lengths(cells) == 9L]
stopifnot(length(cells) == 23L)
snapshot <- as.data.frame(do.call(rbind, cells), stringsAsFactors = FALSE)
names(snapshot) <- c("Common name", "Species", "Upper-layer/lower-layer neurons counted",
  "Brain weight (g)", "Age", "Sex", "Sections sampled",
  "Section thickness (µm)", "Optical disector (µm)")
## The selectable PDF text has 'Callithirx', a control character for the
## hippo's approximate age, and 'mm' for the micrometre headers. The rendered
## table (PDF p. 4) shows the forms frozen here; no measurement is changed.
snapshot$Species[snapshot$`Common name` == "Pygmy marmoset"] <- "Callithrix pygmaea"
snapshot$Age[snapshot$`Common name` == "River hippopotamus"] <- "~60 y"
out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(out)) {
  old <- utils::read.csv(out, check.names = FALSE, colClasses = "character")
  if (!identical(old, snapshot)) stop("Frozen snapshot differs from PDF extraction")
} else {
  utils::write.csv(snapshot, out, row.names = FALSE, fileEncoding = "UTF-8")
}
cat(item_name, ": ", nrow(snapshot), " source-order specimen rows\n", sep = "")
