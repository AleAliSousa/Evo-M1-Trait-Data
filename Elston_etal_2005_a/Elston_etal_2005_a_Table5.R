# Prepared source reader; R NOT RUN in this preparation environment.
# Public export is opt-in and remains blocked until both owner identity holds resolve.
.ev_script_paths <- function() {
  found <- character()
  frames <- rev(sys.frames())
  for (frame in frames) {
    for (key in c("ofile", "file")) {
      value <- get0(key, envir = frame, inherits = FALSE)
      if (is.character(value) && length(value) == 1L && !is.na(value)) {
        found <- c(found, value)
      }
    }
  }
  found
}
.ev_select_script <- function(paths) {
  for (path in paths) {
    if (!file.exists(path) || !grepl("\\.R$", path)) next
    path <- normalizePath(path, winslash = "/", mustWork = TRUE)
    stem <- sub("\\.R$", "", basename(path))
    if (startsWith(stem, paste0(basename(dirname(path)), "_")) &&
        file.exists(file.path(dirname(path), paste0(stem, "_snapshot.csv")))) return(path)
  }
  NULL
}
.ev_script <- .ev_select_script(.ev_script_paths())
if (is.null(.ev_script)) {
  .ev_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  .ev_script <- .ev_select_script(sub("^--file=", "", .ev_arg))
}
if (is.null(.ev_script)) stop("Cannot locate this saved item reader; use source() or Rscript on its own .R file.")
folder <- dirname(.ev_script)
item_name <- sub("\\.R$", "", basename(.ev_script))
base <- folder
while (!file.exists(file.path(base, "__ReadMe.xlsx")) && dirname(base) != base) base <- dirname(base)
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
  header = FALSE, colClasses = "character", check.names = FALSE, na.strings = NULL,
  fileEncoding = "UTF-8", stringsAsFactors = FALSE, blank.lines.skip = FALSE)
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
  colClasses = "character", check.names = FALSE, na.strings = NULL,
  fileEncoding = "UTF-8", stringsAsFactors = FALSE)
if (nrow(context) == 0L || !all(context$Reference == item_name)) stop("Context item identity mismatch.")
num <- function(x) {
  value <- suppressWarnings(as.numeric(gsub(",", "", trimws(x), fixed = TRUE)))
  if (anyNA(value)) stop("Unexpected nonnumeric measurement in frozen source.")
  value
}
header <- which(snapshot[[1L]] == "Visual area")
if (length(header) != 1L) stop("Printed Visual area header missing or duplicated.")
rows <- which(seq_len(nrow(snapshot)) > header)
case <- NULL
records <- list()
for (i in rows) {
  label <- snapshot[i, 1L]
  if (grepl("^VM[0-9]+$", label)) {
    case <- label
  } else if (grepl("^[0-9]+(/[0-9]+)?$", label) && nzchar(snapshot[i, 2L])) {
    if (is.null(case)) stop("Area appears before a case group.")
    records[[length(records) + 1L]] <- data.frame(Reference = item_name, Case = case,
      Area_as_published = label, n_cells = num(snapshot[i, 2L]),
      Soma_Area.um2_mean = num(snapshot[i, 3L]), Soma_Area.um2_SD = num(snapshot[i, 4L]),
      Soma_Area.um2_SEM = num(snapshot[i, 5L]), Soma_Area.um2_min = num(snapshot[i, 6L]),
      Soma_Area.um2_max = num(snapshot[i, 7L]), check.names = FALSE, stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, records)
join_key <- function(x) paste(x$Case, x$Area_as_published, sep = "|")
context_columns <- c("species_as_published", "species_title_as_published", "sex", "life_stage", "hemisphere", "layer", "role", "observation_level", "cohort_id", "dependency_note", "area_note", "source_doi", "source_page")

if (anyDuplicated(join_key(final.dataframe)) || anyDuplicated(join_key(context))) stop("Duplicate context/source keys.")
index <- match(join_key(final.dataframe), join_key(context))
if (anyNA(index) || nrow(final.dataframe) != nrow(context)) stop("Incomplete context/source join.")
final.dataframe <- cbind(final.dataframe, context[index, context_columns, drop = FALSE])
if (anyNA(final.dataframe)) stop("Unexpected missing analysis value.")
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
  row.names = FALSE, na = "", fileEncoding = "UTF-8")
source_doi <- unique(context$source_doi)
if (length(source_doi) != 1L || is.na(source_doi) || !nzchar(source_doi)) stop("Source DOI is not unambiguous.")
expected_encoded <- paste0(gsub("/", "%2F", source_doi, fixed = TRUE), "_",
  substring(item_name, nchar(basename(folder)) + 2L))
item_encoded <- NA_character_
export_public <- isTRUE(getOption("evom1.export_public", FALSE))
registry_found <- file.exists(file.path(base, "__ReadMe.xlsx"))
if (registry_found && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  if (!all(c("Item name", "Item encoded") %in% names(filecodes))) stop("Registry identity columns absent.")
  matches <- which(!is.na(filecodes$"Item name") & filecodes$"Item name" == item_name)
  if (length(matches) != 1L) stop("Registry must match this Item name exactly once.")
  item_encoded <- as.character(filecodes$"Item encoded"[matches])
} else if (export_public) {
  stop("Public export refused: current __ReadMe.xlsx and readxl are required.")
} else {
  warning("Analysis CSV only: current registry/readxl unavailable; Item encoded not verified.", call. = FALSE)
}
identity_ok <- length(item_encoded) == 1L && !is.na(item_encoded) &&
  identical(item_encoded, expected_encoded) && !endsWith(item_encoded, "_")
placement_ok <- all(context$source_placement_status == "owner_resolved")
if (export_public) {
  if (!identity_ok) stop("Public export refused: registry Item encoded does not match the DOI printed in the source. Owner must correct Citation A and regenerate identity; no override applied.")
  if (!placement_ok) stop("Public export refused: swapped source location still needs an owner resolution recorded in item context.")
  dir.create(file.path(base, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
  utils::write.table(final.dataframe,
    file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
    sep = "\t", quote = FALSE, row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message("Prepared analysis CSV only; public TSV not written. R execution is not a FINISHED or human-curation certification.")
  if (!identity_ok) warning("Registry/source DOI identity remains unverified or mismatched; no public filename substituted.", call. = FALSE)
  if (!placement_ok) warning("Source filename/location discrepancy remains for owner resolution.", call. = FALSE)
}
