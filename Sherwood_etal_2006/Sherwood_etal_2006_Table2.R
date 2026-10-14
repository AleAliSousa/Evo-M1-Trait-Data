# Table 2 contains original-author derived ratios, not independent primary counts.
# The delivered CSV is a Python preview; this R reader has not been executed.

script_file <- NULL
for (frame in rev(sys.frames())) {
  for (key in c("ofile", "file")) {
    candidate <- frame[[key]]
    if (is.character(candidate) && length(candidate) == 1L &&
        !is.na(candidate) && file.exists(candidate) &&
        identical(basename(candidate), "Sherwood_etal_2006_Table2.R")) {
      script_file <- candidate
      break
    }
  }
  if (!is.null(script_file)) break
}
if (is.null(script_file)) {
  arguments <- commandArgs(trailingOnly = FALSE)
  candidates <- sub("^--file=", "", arguments[grepl("^--file=", arguments)])
  candidates <- candidates[file.exists(candidates) &
    basename(candidates) == "Sherwood_etal_2006_Table2.R"]
  if (length(candidates) == 1L) script_file <- candidates[[1L]]
}
if (is.null(script_file) && interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
  candidate <- rstudioapi::getActiveDocumentContext()$path
  if (nzchar(candidate) && file.exists(candidate) &&
      identical(basename(candidate), "Sherwood_etal_2006_Table2.R")) script_file <- candidate
}
if (is.null(script_file)) stop("Source the saved item reader or run it with Rscript.")
folder <- dirname(normalizePath(script_file, winslash = "/", mustWork = TRUE))
base <- dirname(folder)
item_name <- sub("\\.R$", "", basename(script_file))

frozen <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
  header = FALSE, colClasses = "character", check.names = FALSE,
  na.strings = NULL, strip.white = FALSE, fileEncoding = "UTF-8")
header_row <- which(frozen[[1L]] == "Species")
if (length(header_row) != 1L || ncol(frozen) != 6L) stop("Unexpected frozen table layout.")
area_headers <- as.character(unlist(frozen[header_row, 3:6], use.names = FALSE))
if (!identical(area_headers, c("Area 4", "Area 9L", "Area 32", "Area 44"))) {
  stop("Unexpected printed area headers.")
}
if (!any(frozen[[1L]] == "Data are presented as mean (standard error).")) {
  stop("The frozen uncertainty footnote is missing.")
}
data_rows <- which(seq_len(nrow(frozen)) > header_row & grepl("^[0-9]+$", frozen[[2L]]))
if (length(data_rows) != 3L) stop("Expected the three printed species rows.")

records <- lapply(data_rows, function(i) {
  cells <- as.character(unlist(frozen[i, 3:6], use.names = FALSE))
  pattern <- "^([0-9]+\\.[0-9]+) \\(([0-9]+\\.[0-9]+)\\)$"
  if (!all(grepl(pattern, cells))) stop("Unexpected printed ratio cell.")
  mean_printed <- sub(pattern, "\\1", cells)
  se_printed <- sub(pattern, "\\2", cells)
  # Parse only; dimensionless ratios need no unit conversion or recomputation.
  data.frame(Reference = item_name,
    species_as_published = frozen[[1L]][i], area_as_published = area_headers,
    n_biological = as.integer(frozen[[2L]][i]),
    ratio_cell_as_published = cells, ratio_mean_printed = mean_printed,
    ratio_se_printed = se_printed, ratio_mean = as.numeric(mean_printed),
    ratio_se = as.numeric(se_printed), stringsAsFactors = FALSE,
    check.names = FALSE)
})
final.dataframe <- do.call(rbind, records)
rownames(final.dataframe) <- NULL

context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
  colClasses = "character", check.names = FALSE, na.strings = NULL,
  strip.white = FALSE, fileEncoding = "UTF-8")
join_columns <- c("Reference", "species_as_published", "area_as_published")
make_key <- function(x) do.call(paste, c(x[join_columns], sep = "|"))
context_key <- make_key(context)
data_key <- make_key(final.dataframe)
if (anyDuplicated(context_key) || anyDuplicated(data_key) ||
    !setequal(context_key, data_key)) stop("Context join is not exact one-to-one.")
metadata_columns <- setdiff(names(context), join_columns)
final.dataframe <- cbind(final.dataframe,
  context[match(data_key, context_key), metadata_columns, drop = FALSE])
rownames(final.dataframe) <- NULL
numeric_metadata <- c("section_spacing_um", "sections_per_area_per_cell_type",
  "counting_frame_width_um", "counting_frame_height_um", "disector_height_um",
  "guard_zone_min_um")
for (code in numeric_metadata) {
  if (!all(grepl("^[0-9]+(?:\\.[0-9]+)?$", final.dataframe[[code]], perl = TRUE))) {
    stop(paste("Unexpected numeric method metadata:", code))
  }
  final.dataframe[[code]] <- as.numeric(final.dataframe[[code]])
}
if (nrow(final.dataframe) != 12L || anyNA(final.dataframe)) stop("Incomplete analysis table.")
if (!all(final.dataframe$data_role == "primary")) stop("Unexpected original-source role.")

# Re-read the current registry on each run, never a cached row position.
if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl to read the current registry.")
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
required_headers <- c("Item name", "Item encoded", "Data role (primary/secondary/both)")
if (!all(required_headers %in% names(filecodes))) stop("Current registry headers are missing.")
registry_row <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
if (length(registry_row) != 1L) stop("The exact Item name must occur once in the current registry.")
item_encoded <- as.character(filecodes$`Item encoded`[registry_row])
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$|[/\\\\]", item_encoded)) {
  stop("Invalid current registry Item encoded.")
}
if (!identical(as.character(filecodes$`Data role (primary/secondary/both)`[registry_row]), "primary")) {
  stop("Registry original-source role requires owner review.")
}
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
  row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Preparation is analysis-only by default; a separate owner-controlled R run may opt in.
# This does not lift scientific merge holds or certify a FINISHED build.
if (identical(Sys.getenv("EVOM1_WRITE_PUBLIC_TSV", unset = "FALSE"), "TRUE")) {
  dir.create(file.path(base, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
  utils::write.table(final.dataframe,
    file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
    sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
} else {
  message("Analysis CSV written; public TSV withheld. Scientific merge holds remain.")
}
