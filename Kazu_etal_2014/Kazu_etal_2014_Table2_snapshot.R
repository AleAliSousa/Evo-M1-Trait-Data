## Capture only the printed Table 2, including its printed species spellings.
me <- "Kazu_etal_2014_Table2_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(script_path)
base <- sub("_snapshot\\.R$", "", me)
pdf <- file.path(folder, "Kazu-2014-Cellular scaling rules for the brain.pdf")
lines <- strsplit(pdftools::pdf_text(pdf)[[10]], "\n", fixed = TRUE)[[1]]
start <- grep("Table 2 \\| Cortical areas, volumes and folding index", lines)
stopifnot(length(start) == 1L)
header <- trimws(strsplit(trimws(lines[start + 2L]), "\\s{2,}")[[1]])
body <- lines[(start + 4L):(start + 13L)]
records <- lapply(seq(1L, 9L, 2L), function(j) {
  p <- trimws(strsplit(trimws(body[j]), "\\s{2,}")[[1]])
  stopifnot(length(p) == 5L)
  c(paste(p[1], trimws(body[j + 1L])), p[2:5])
})
stopifnot(length(header) == 5L, length(records) == 5L,
          records[[1]][1] == "Sus scrofa domesticus")
foot <- paste(trimws(lines[(start + 15L):(start + 17L)]), collapse = " ")
stopifnot(grepl("one single hemisphere", foot, fixed = TRUE))
snap <- as.data.frame(do.call(rbind, c(records, list(c(foot, rep("", 4L))))),
                      stringsAsFactors = FALSE)
names(snap) <- header
path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(path)) stop("Frozen snapshot exists: ", path)
utils::write.csv(snap, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
