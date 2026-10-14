## Frozen publication snapshot -> analysis CSV -> registry-authoritative public TSV.
options(scipen = 999)
.sp <- local({
  for (fr in rev(sys.frames())) {
    p <- fr$ofile; if (is.null(p)) p <- fr$file
    if (is.character(p) && length(p) == 1L && grepl("\\.R$", p) && file.exists(p)) return(normalizePath(p))
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1L])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run the saved item script with Rscript, source(), or RStudio Source.")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- folder
while (dirname(base) != base && !file.exists(file.path(base, "__ReadMe.xlsx"))) base <- dirname(base)
num <- function(x) as.numeric(gsub(",", "", x, fixed = TRUE))
raw <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), skip = 3L, check.names = FALSE, colClasses = "character", na.strings = "", stringsAsFactors = FALSE)
raw <- raw[!is.na(raw[[1L]]) & !is.na(raw[[2L]]) & grepl("^[0-9]", raw[[2L]]), , drop = FALSE]
final.dataframe <- data.frame(species_as_published = "Trichechus manatus latirostris", neuron_type_as_published = raw[[1L]], CL2_traced_neurons.n = num(raw[[2L]]), DL1_traced_neurons.n = num(raw[[3L]]), DL4_traced_neurons.n = num(raw[[4L]]), total_traced_neurons.n = num(raw[[5L]]), biological_specimens.n = 1L, data_role = "primary", source = item_name, stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(nrow(final.dataframe) == 10L, all(final.dataframe$total_traced_neurons.n == rowSums(final.dataframe[, 3:5])), sum(final.dataframe$total_traced_neurons.n) == 55L)

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "NA")
item_encoded <- NA_character_
if (requireNamespace("readxl", quietly = TRUE) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  i <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
  if (length(i) == 1L) item_encoded <- filecodes[["Item encoded"]][i]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) && !grepl("_$", item_encoded)) {
  out <- file.path(base, "__Public", "comparative-data")
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  utils::write.table(final.dataframe, file.path(out, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE, quote = TRUE, na = "NA")
} else warning("Analysis CSV built; public TSV withheld until owner registration and Item encoded recalculation. No proposed identifier is treated as registry authority.")
message(item_name, ": ", nrow(final.dataframe), " analysis rows")
