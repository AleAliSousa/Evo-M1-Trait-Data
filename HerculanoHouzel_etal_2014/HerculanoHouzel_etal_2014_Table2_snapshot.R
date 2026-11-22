## Capture only printed Table 2 from the right column of the local PDF page.
me <- "HerculanoHouzel_etal_2014_Table2_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(script_path)
base <- sub("_snapshot\\.R$", "", me)
pdf <- file.path(folder, "Herculano-Houze-2014-The elephant brain in num.pdf")
lines <- strsplit(pdftools::pdf_text(pdf)[[2]], "\n", fixed = TRUE)[[1]]
start <- grep("Table 2 \\| Cortical areas and volumes in the African elephant", lines)
stopifnot(length(start) == 1L)
section <- trimws(substr(lines[(start + 1L):(start + 7L)], 84L, 200L))
cells <- lapply(section, function(x) trimws(strsplit(x, "\\s{2,}")[[1]]))
stopifnot(length(cells) == 7L, all(lengths(cells) == 2L),
          cells[[1]][1] == "Total cortical surface area, pial",
          cells[[7]][1] == "Cortical volume, white matter")
foot <- trimws(substr(lines[start + 9L], 84L, 200L))
stopifnot(foot == "Values for one hemisphere only.")
snap <- as.data.frame(do.call(rbind, c(cells, list(c(foot, "")))),
                      stringsAsFactors = FALSE)
names(snap) <- c("Measure", "Value")
path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(path)) stop("Frozen snapshot exists: ", path)
utils::write.csv(snap, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
