# Herberstein et al. (2022), AnimalTraits. Reads only this item's frozen workbook.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- if (length(args) == 1L) sub("^--file=", "", args) else sys.frame(1)$ofile
folder <- dirname(normalizePath(script, mustWork = TRUE))
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(script))
final.dataframe <- as.data.frame(readxl::read_excel(
  file.path(folder, paste0(item_name, "_snapshot.xlsx")), sheet = "Column descriptions"))
stopifnot(nrow(final.dataframe) == 43L)

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "")
registry <- as.data.frame(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"))
i <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
stopifnot(length(i) == 1L)
item_encoded <- registry[["Item encoded"]][i]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", quote = TRUE, qmethod = "double", row.names = FALSE, na = "")
cat(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns\n", sep = "")
