# Frozen Table 2 -> analysis CSV. Publication is disabled by default.
expected.basename <- "Raghanti_etal_2008_a_Table2.R"
locate.self <- function() {
  # source() uses ofile; sys.source() uses file. Inspect these before --file,
  # which may name a sweep wrapper rather than this saved item script.
  for (frame in rev(sys.frames())) {
    for (key in c("ofile", "file")) {
      if (exists(key, envir = frame, inherits = FALSE)) {
        candidate <- get(key, envir = frame, inherits = FALSE)
        if (is.character(candidate) && length(candidate) == 1L &&
            !is.na(candidate) && basename(candidate) == expected.basename &&
            file.exists(candidate)) return(normalizePath(candidate, mustWork = TRUE))
      }
    }
  }
  arguments <- commandArgs(trailingOnly = FALSE)
  candidates <- sub("^--file=", "", arguments[grepl("^--file=", arguments)])
  candidates <- c(candidates, file.path(getwd(), expected.basename))
  for (candidate in candidates) {
    if (basename(candidate) == expected.basename && file.exists(candidate))
      return(normalizePath(candidate, mustWork = TRUE))
  }
  stop("Cannot locate the exact saved item script: ", expected.basename)
}
base <- locate.self()
stopifnot(identical(basename(base), expected.basename))
folder <- dirname(base)
item_name <- sub("\\.R$", "", basename(base))
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                            header = FALSE, colClasses = "character", na.strings = NULL,
                            check.names = FALSE, fileEncoding = "UTF-8")
header <- which(snapshot[[1L]] == "Species")
stopifnot(length(header) == 1L,
          identical(as.character(unlist(snapshot[header, 3:6], use.names = FALSE)),
                    c("Area 9", "Area 32", "Area 4", "N")))
source.rows <- snapshot[snapshot[[2L]] %in% c("I", "II", "III", "V/VI"), , drop = FALSE]
stopifnot(nrow(source.rows) == 12L,
          identical(source.rows[[2L]], rep(c("I", "II", "III", "V/VI"), 3L)))
carry.forward <- function(x) {
  for (i in seq_along(x)) {
    if (!nzchar(x[i])) {
      if (i == 1L) stop("Leading blank in a printed group column")
      x[i] <- x[i - 1L]
    }
  }
  x
}
source.rows[[1L]] <- carry.forward(source.rows[[1L]])
source.rows[[6L]] <- carry.forward(source.rows[[6L]])
context <- utils::read.csv(file.path(folder, "reference_tables",
                          paste0(item_name, "_context_snapshot.csv")),
                          colClasses = "character", na.strings = NULL,
                          check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(nrow(context) == 3L, !anyDuplicated(context$species_as_published),
          all(context$Reference == item_name),
          setequal(context$species_as_published, source.rows[[1L]]),
          all(context$comparative_use == "HOLD_CROSS_SPECIES_UNCORRECTED_TISSUE_SHRINKAGE"),
          all(context$observation_level == "species_cohort_area_layer_summary"))
metadata.columns <- c("marker_as_published", "hemisphere", "ALv_unit", "observation_level",
                      "data_role", "measure_class", "comparative_use", "source_table",
                      "source_pdf_page", "source_publication_year", "SourceReader",
                      "SourceReadDate", "SourceVisualCheck")
parts <- list()
for (i in seq_len(nrow(source.rows))) {
  context.row <- context[match(source.rows[i, 1L], context$species_as_published), , drop = FALSE]
  for (j in 3:5) {
    cell <- source.rows[i, j]
    if (!grepl("^[0-9]+[.][0-9]+ +± +[0-9]+[.][0-9]+$", cell))
      stop("Invalid printed mean/SD cell: ", cell)
    values <- as.numeric(trimws(strsplit(cell, "±", fixed = TRUE)[[1L]]))
    stopifnot(length(values) == 2L, all(is.finite(values)), all(values >= 0))
    row <- data.frame(species_as_published = source.rows[i, 1L],
                      area_as_published = snapshot[header, j],
                      layer_as_published = source.rows[i, 2L],
                      Structure = context.row$Structure,
                      ALv_mean = values[1L], ALv_SD = values[2L],
                      N = as.integer(source.rows[i, 6L]), stringsAsFactors = FALSE)
    for (column in metadata.columns) row[[column]] <- context.row[[column]]
    row$Reference <- item_name
    parts[[length(parts) + 1L]] <- row
  }
}
final.dataframe <- do.call(rbind, parts)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 36L, all(final.dataframe$N == 6L),
          !anyDuplicated(final.dataframe[c("species_as_published", "area_as_published", "layer_as_published")]))
# Keep µm/µm³: this is length per volume (dimension L^-2), not cell density
# or tissue volume. No unit conversion or neuron-count normalization is made.
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Fresh registry authority + owner source-limit review are prerequisites.
# Cached item codes are documentary only and never drive this writer.
if (identical(getOption("evom1.publish", FALSE), TRUE)) {
  if (!identical(getOption("evom1.owner_review", FALSE), TRUE) ||
      !identical(getOption("evom1.source_limits_review", FALSE), TRUE))
    stop("Public TSV withheld: owner and source-limit reviews are required")
  root <- folder
  while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root)
    root <- dirname(root)
  if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Current registry is not mounted")
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Package readxl is required for registry lookup")
  filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  matches <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
  if (length(matches) != 1L) stop("Registry must match the exact Item name once")
  item_encoded <- as.character(filecodes[["Item encoded"]][matches])
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$|[/\\\\]", item_encoded)) stop("Invalid current Item encoded")
  if (!identical(as.character(filecodes[["year"]][matches]),
                 unique(final.dataframe$source_publication_year)))
    stop("Registry year differs from frozen source context; review instead of overriding")
  public <- file.path(root, "__Public", "comparative-data")
  if (!dir.exists(public)) stop("Canonical public directory is not mounted")
  utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")),
                     sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message("Analysis CSV only; public TSV WITHHELD. Cross-species HOLD remains in every row.")
}
