# Borghammer et al. (2012), Table 2: one row per printed structure/side,
# normalization reference, and clinical group. The six cells on each printed
# row are parsed from the separately frozen published-layout snapshot.
arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(arg) != 1L) stop("Run this saved file with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", arg)))
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(sub("^--file=", "", arg)))
snapshot <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                     header = FALSE, colClasses = "character", na.strings = character(0),
                     check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(ncol(snapshot) == 7L, nrow(snapshot) == 33L,
          snapshot[1L, 1L] == "Table 2 Normalized CMRglc values in subcortical VOIs")

normalizations <- c("WM", "WM", "Reference cluster", "Reference cluster", "GM", "GM")
groups <- c("Controls", "PD", "Controls", "PD", "Controls", "PD")
structure_headings <- c("Putamen", "Caudate", "GPe", "GPi", "VA", "VL", "CM", "STN")
current_structure <- NA_character_
records <- list()
for (i in 4:29) {
  label <- snapshot[i, 1L]
  if (label %in% structure_headings) {
    current_structure <- label
    next
  }
  if (!label %in% c("Right", "Left", "Pons", "Cerebellum")) next
  structure <- if (label %in% c("Pons", "Cerebellum")) label else current_structure
  side <- if (label %in% c("Right", "Left")) label else NA_character_
  if (is.na(structure)) stop("Unassigned printed structure at row ", i)
  for (j in seq_len(6L)) {
    cell <- snapshot[i, j + 1L]
    match <- regmatches(cell, regexec("^([0-9]+[.][0-9]+) ± ([0-9]+[.][0-9]+)(\\*{0,2})$",
                                      cell, perl = TRUE))[[1L]]
    if (length(match) != 4L) stop("Unparsed printed cell at row ", i, ", column ", j)
    records[[length(records) + 1L]] <- data.frame(
      species = "Homo sapiens", structure_as_published = structure,
      side_as_published = side, normalization_as_published = normalizations[j],
      group_as_published = groups[j], cell_as_printed = cell,
      normalized_CMRglc_mean = as.numeric(match[2L]),
      normalized_CMRglc_dispersion = as.numeric(match[3L]),
      dispersion_type = "not specified in Table 2",
      significance_mark = if (nzchar(match[4L])) match[4L] else NA_character_,
      stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, records)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 108L,
          sum(!is.na(final.dataframe$significance_mark)) == 18L)
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
