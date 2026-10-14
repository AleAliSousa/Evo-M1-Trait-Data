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
raw <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), skip = 1L, check.names = FALSE, colClasses = "character", na.strings = "", stringsAsFactors = FALSE)
raw <- raw[!is.na(raw[[1L]]) & grepl("^(Soma area|TDL|MSL|DSC|DSN|DSD)", raw[[1L]]), , drop = FALSE]
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_sample_context.csv")), check.names = FALSE, stringsAsFactors = FALSE, na.strings = "")
stopifnot(nrow(raw) == 6L, nrow(context) == 3L, identical(names(raw)[2:4], context$table_column_as_published))
final.dataframe <- context
names(final.dataframe)[names(final.dataframe) == "traced_neurons_n"] <- "traced_neurons.n"
names(final.dataframe)[names(final.dataframe) == "biological_specimens_n"] <- "biological_specimens.n"
codes <- c("Soma_Area.um2","Total_dendritic_Length.um","Mean_segment_Length.um","Dendritic_segments.n","Dendritic_spines.n","Dendritic_spine_Density.n_per_um")
for (j in seq_len(nrow(raw))) {
  parts <- strsplit(as.character(unlist(raw[j, 2:4], use.names = FALSE)), " ± ", fixed = TRUE)
  stopifnot(all(lengths(parts) == 2L))
  final.dataframe[[paste0(codes[j], "_mean")]] <- vapply(parts, function(x) num(x[1L]), numeric(1), USE.NAMES = FALSE)
  final.dataframe[[paste0(codes[j], "_SD")]] <- vapply(parts, function(x) num(x[2L]), numeric(1), USE.NAMES = FALSE)
}
final.dataframe$source <- item_name

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
