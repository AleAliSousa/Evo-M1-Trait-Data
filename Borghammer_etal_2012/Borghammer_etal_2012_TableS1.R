# Borghammer et al. (2012), Supplementary Table 1. The frozen snapshot is the
# untouched journal-supplied legacy Word file. textutil exposes its four-arm
# table as HTML; this reader parses it without changing the source document.
arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(arg) != 1L) stop("Run this saved file with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", arg)))
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(sub("^--file=", "", arg)))
snapshot <- file.path(folder, paste0(item_name, "_snapshot.doc"))
html <- tempfile(fileext = ".html")
on.exit(unlink(html), add = TRUE)
result <- system2("textutil", c("-convert", "html", "-output", shQuote(html),
                                shQuote(snapshot)), stdout = TRUE, stderr = TRUE)
if (!file.exists(html)) stop("textutil did not convert the frozen Word source: ",
                             paste(result, collapse = " "))
document <- xml2::read_html(html)
tables <- rvest::html_elements(document, "table")
stopifnot(length(tables) >= 1L)
rows <- rvest::html_elements(tables[[1L]], "tr")
cell_text <- function(i) trimws(rvest::html_text2(rvest::html_elements(rows[[i]], "td")))
stopifnot(length(rows) == 12L,
          grepl("Supplementary Table 1", paste(cell_text(1L), collapse = " "), fixed = TRUE),
          identical(cell_text(4L)[c(4L, 5L, 7L, 8L)], c("8", "12", "3", "9")),
          identical(vapply(c(6L, 8L, 10L), function(i) cell_text(i)[2L], ""),
                    c("GM", "WM", "GM/WM")))
arms <- data.frame(center = c("Aarhus", "Aarhus", "Cologne", "Cologne"),
                   group = c("Controls", "PD", "Controls", "PD"),
                   n = c(8L, 12L, 3L, 9L), column = c(4L, 5L, 7L, 8L))
records <- list()
for (i in c(6L, 8L, 10L)) {
  cells <- cell_text(i)
  measure <- cells[2L]
  for (j in seq_len(nrow(arms))) {
    printed <- cells[arms$column[j]]
    match <- regmatches(printed,
                        regexec("^([0-9]+[.][0-9]+)±([0-9]+[.][0-9]+)(\\*{0,2})$",
                                printed, perl = TRUE))[[1L]]
    if (length(match) != 4L) stop("Unparsed supplementary cell: ", printed)
    records[[length(records) + 1L]] <- data.frame(
      species = "Homo sapiens", center = arms$center[j], group = arms$group[j],
      n = arms$n[j], measure_as_published = measure,
      cell_as_printed = printed, mean = as.numeric(match[2L]),
      dispersion = as.numeric(match[3L]), dispersion_type = "not specified in Table S1",
      unit_as_published = if (measure == "GM/WM") "ratio" else "µmol/100g/min",
      significance_mark = if (nzchar(match[4L])) match[4L] else NA_character_,
      stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, records)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 12L,
          sum(!is.na(final.dataframe$significance_mark)) == 4L)
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "")

registry <- as.data.frame(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"))
matches <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(matches) > 1L) stop("Duplicate exact registry item name")
item_encoded <- if (length(matches) == 1L) registry[["Item encoded"]][matches] else NA_character_
if (length(matches) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
    grepl("_$", item_encoded) || grepl("[/\\]", item_encoded)) {
  warning("Public TSV pending exact registry row with a complete Item encoded stem")
} else {
  write.table(final.dataframe,
              file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, qmethod = "double", na = "")
  cat("Public TSV: ", item_encoded, ".tsv\n", sep = "")
}
cat("Analysis rows: ", nrow(final.dataframe), "\n", sep = "")
