## Krubitzer, Kuenzle & Kaas (1997), JCN 379:399-414 — Results/Discussion text.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript or Source in RStudio.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), stringsAsFactors = FALSE,
                check.names = FALSE, na.strings = c("", "NA"))
needed <- c("Species", "common_name", "structure", "measure", "printed_value", "unit", "value",
            "value_min", "value_max", "comparator", "value_status", "hemisphere_basis",
            "where_in_paper", "source_text")
stopifnot(nrow(raw) == 8L, all(needed %in% names(raw)))
stopifnot(raw$value[raw$structure == "total neocortex"] == 15,
          raw$value[raw$structure == "PV/S2"] == 1.5,
          raw$value_min[raw$structure == "S1" & raw$measure == "rostrocaudal width"] == 1.2,
          raw$value_max[raw$structure == "S1" & raw$measure == "rostrocaudal width"] == 1.4)

clean <- raw[needed]
clean$data_role <- "primary"
clean$source <- item_name
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "NA")

if (!is.na(base)) {
  registry <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  encoded <- registry$`Item encoded`[match(item_name, registry$`Item name`)]
  if (!is.na(encoded) && nzchar(encoded)) {
    write.table(clean, file.path(base, "__Public", "comparative-data", paste0(encoded, ".tsv")),
                sep = "\t", row.names = FALSE, na = "NA")
  } else {
    warning("Registry row pending for ", item_name, "; public TSV skipped.")
  }
}
message(item_name, ": ", nrow(clean), " rows written")
