## Capture only printed Table 1 from the local publisher PDF.
me <- "Sarko_etal_2009_Table1_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(script_path)
base <- sub("_snapshot\\.R$", "", me)
pdf <- file.path(folder, "Sarko-2009-Cellular scaling rul.pdf")
lines <- strsplit(pdftools::pdf_text(pdf)[[4]], "\n", fixed = TRUE)[[1]]
start <- grep("^Table 1 \\| Comparative cellular composition", lines)
stopifnot(length(start) == 1L)
header <- trimws(strsplit(trimws(lines[start + 2L]), "\\s{2,}")[[1]])
body <- lines[(start + 4L):(start + 9L)]
cells <- lapply(body, function(x) trimws(strsplit(trimws(x), "\\s{2,}")[[1]]))
stopifnot(length(header) == 5L, all(lengths(cells) == 5L),
          cells[[1]][1] == "Smoky shrew", cells[[6]][1] == "Variation")
snap <- as.data.frame(do.call(rbind, cells), stringsAsFactors = FALSE)
names(snap) <- header
path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(path)) stop("Frozen snapshot exists: ", path)
utils::write.csv(snap, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
