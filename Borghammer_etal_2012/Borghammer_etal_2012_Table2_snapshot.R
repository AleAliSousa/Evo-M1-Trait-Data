# Extract the printed Table 2 grid from the article PDF text layer. The output
# remains a published-layout snapshot; data cleaning is in Table2.R.
arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(arg) != 1L) stop("Run this saved file with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", arg)))
item_name <- sub("_snapshot[.]R$", "", basename(sub("^--file=", "", arg)))
pdf <- file.path(folder, "Borghammer-2012-Glucose metabolism in small su.pdf")
page <- pdftools::pdf_text(pdf)[[5L]]
lines <- strsplit(page, "\n", fixed = TRUE)[[1L]]
start <- grep("^Table 2 Normalized CMRglc values in subcortical VOIs", lines)
end <- grep("^CMRglc was normalized to white matter", lines)
stopifnot(length(start) == 1L, length(end) == 1L, end > start)

cells <- list(c("Table 2 Normalized CMRglc values in subcortical VOIs", rep("", 6)),
              c("", "WM", "", "Reference cluster", "", "GM", ""),
              c("", "Controls", "PD", "Controls", "PD", "Controls", "PD"))
groups <- c("Putamen", "Caudate", "GPe", "GPi", "VA", "VL", "CM", "STN")
pm <- intToUtf8(6L) # the PDF text layer encodes its printed ± glyph as U+0006
pattern <- paste0("[0-9]+[.][0-9]+[[:space:]]*", pm,
                  "[[:space:]]*[0-9]+[.][0-9]+\\*{0,2}")
data_rows <- 0L
for (line in lines[(start + 1L):(end - 1L)]) {
  label <- trimws(line)
  if (label %in% groups) {
    cells[[length(cells) + 1L]] <- c(label, rep("", 6))
    next
  }
  if (!grepl("^(Right|Left|Pons|Cerebellum)[[:space:]]", label)) next
  hits <- regmatches(line, gregexpr(pattern, line, perl = TRUE))[[1L]]
  if (length(hits) != 6L) stop("Expected six printed values in: ", label)
  hits <- gsub(pm, "±", hits, fixed = TRUE)
  hits <- gsub("[[:space:]]+", " ", hits)
  cells[[length(cells) + 1L]] <- c(sub("[[:space:]].*$", "", label), hits)
  data_rows <- data_rows + 1L
}
stopifnot(data_rows == 18L, length(cells) == 29L)
for (line in lines[end:(end + 3L)])
  cells[[length(cells) + 1L]] <- c(trimws(line), rep("", 6))
snapshot <- as.data.frame(do.call(rbind, cells), stringsAsFactors = FALSE)
names(snapshot) <- paste0("V", seq_len(7L))
target <- file.path(folder, paste0(item_name, "_snapshot.csv"))
temporary <- tempfile(fileext = ".csv")
on.exit(unlink(temporary), add = TRUE)
write.table(snapshot, temporary, sep = ",", row.names = FALSE,
            col.names = FALSE, quote = TRUE, qmethod = "double", fileEncoding = "UTF-8")
if (file.exists(target) && !identical(readBin(target, "raw", file.info(target)$size),
                                      readBin(temporary, "raw", file.info(temporary)$size)))
  stop("Frozen snapshot differs from current source extraction; review before replacing")
if (!file.exists(target)) invisible(file.copy(temporary, target))
cat("Frozen ", data_rows, " printed data rows: ", target, "\n", sep = "")
