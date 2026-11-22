## Capture only the printed Table 1 from the local publisher PDF.
me <- "HerculanoHouzel_etal_2014_Table1_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_path <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(script_path)
base <- sub("_snapshot\\.R$", "", me)
pdf <- file.path(folder, "Herculano-Houze-2014-The elephant brain in num.pdf")
lines <- strsplit(pdftools::pdf_text(pdf)[[2]], "\n", fixed = TRUE)[[1]]
start <- match("Table 1 | Cellular composition of the African elephant brain.", trimws(lines))
stopifnot(!is.na(start))
header <- trimws(strsplit(trimws(lines[start + 2L]), "\\s{2,}")[[1]])
stopifnot(length(header) == 7L, identical(header[1], "Structure"))
body <- lines[(start + 4L):(start + 17L)]
cells <- lapply(body, function(x) trimws(strsplit(trimws(x), "\\s{2,}")[[1]]))
stopifnot(length(cells) == 14L, all(lengths(cells) == 7L),
          cells[[1]][1] == "Whole brain", cells[[14]][1] == "Olfactory bulb")
foot <- paste(trimws(lines[(start + 19L):(start + 21L)]), collapse = " ")
stopifnot(grepl("All figures refer to 2 times", foot, fixed = TRUE))
snap <- as.data.frame(do.call(rbind, c(cells, list(c(foot, rep("", 6L))))),
                      stringsAsFactors = FALSE)
names(snap) <- header
path <- file.path(folder, paste0(base, "_snapshot.csv"))
if (file.exists(path)) stop("Frozen snapshot exists: ", path)
utils::write.csv(snap, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
