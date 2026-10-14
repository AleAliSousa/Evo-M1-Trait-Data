## Frozen publication snapshot -> analysis CSV. PREPARED / R_PENDING.
## No R execution or dataset-builder certification has occurred.
.sp <- local({
  own_name <- "Semendeferi_etal_1998_TABLE5.R"
  accept <- function(p) is.character(p) && length(p) == 1L && !is.na(p) &&
    nzchar(p) && identical(basename(p), own_name) && file.exists(p)
  fr <- sys.frames()
  calls <- sys.calls()
  for (k in rev(seq_along(fr))) {
    p <- tryCatch(get("ofile", envir = fr[[k]], inherits = FALSE), error = function(e) NULL)
    if (accept(p)) return(normalizePath(p, mustWork = TRUE))
    fun <- tryCatch(paste(deparse(calls[[k]][[1L]]), collapse = ""), error = function(e) "")
    if (fun %in% c("source", "sys.source", "base::source", "base::sys.source")) {
      p <- tryCatch(get("file", envir = fr[[k]], inherits = FALSE), error = function(e) NULL)
      if (accept(p)) return(normalizePath(p, mustWork = TRUE))
    }
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) {
    p <- sub("^--file=", "", a[1L])
    if (accept(p)) return(normalizePath(p, mustWork = TRUE))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (accept(p)) return(normalizePath(p, mustWork = TRUE))
    p <- rstudioapi::getActiveDocumentContext()$path
    if (accept(p)) return(normalizePath(p, mustWork = TRUE))
  }
  stop("Cannot identify this saved item script; source the item itself or use Rscript item.R.", call. = FALSE)
})
stopifnot(identical(basename(.sp), "Semendeferi_etal_1998_TABLE5.R"))
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
  header = FALSE, colClasses = "character", check.names = FALSE,
  stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = NULL,
  blank.lines.skip = FALSE)
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
  colClasses = "character", check.names = FALSE, stringsAsFactors = FALSE,
  fileEncoding = "UTF-8", na.strings = NULL)
stopifnot(!anyDuplicated(context$species_as_published), all(context$source_ref == item_name))
num <- function(x) {
  y <- suppressWarnings(as.numeric(gsub(",", "", x, fixed = TRUE)))
  if (any(!nzchar(x) | is.na(y) | !is.finite(y))) stop("Invalid numeric source cell.", call. = FALSE)
  y
}
keep <- nzchar(snap[[2L]]) & grepl("^[0-9,]+$", snap[[2L]])
d <- snap[keep, , drop = FALSE]
stopifnot(identical(d[[1L]], context$species_as_published))
z <- context[match(d[[1L]], context$species_as_published), , drop = FALSE]
## Published counts and neurons/mm³ are already in project units. No x2 laterality conversion.
final.dataframe <- data.frame(record_id = paste0(item_name, "_", seq_len(nrow(d))),
  species_as_published = d[[1L]], total_neurons_R = num(d[[2L]]),
  neuronal_density_R_per_mm3 = num(d[[3L]]), SE_as_published = num(d[[4L]]),
  SE_target_context = z$statistic_context, stringsAsFactors = FALSE, check.names = FALSE)
final.dataframe$n_biological_specimens <- num(z$n_biological_specimens)
final.dataframe$n_hemispheres <- num(z$n_hemispheres)
final.dataframe$hemisphere <- z$hemisphere
final.dataframe$observation_level <- z$observation_level
final.dataframe$source_ref <- z$source_ref
final.dataframe$source_table <- z$source_table
final.dataframe$printed_page <- num(z$printed_page)
final.dataframe$pdf_page <- num(z$pdf_page)
final.dataframe$method_context <- z$method_context
final.dataframe$measurement_locations_context <- z$measurement_locations_context
final.dataframe$anatomical_context <- z$anatomical_context
final.dataframe$provenance_flag <- z$provenance_flag
final.dataframe$species_pooling_gate <- z$species_pooling_gate
final.dataframe$data_role <- z$data_role
final.dataframe$merge_eligible <- z$merge_eligible == "TRUE"
final.dataframe$SourceReader <- z$SourceReader
final.dataframe$SourceReadDate <- z$SourceReadDate

stopifnot(nrow(final.dataframe) > 0L, !anyDuplicated(final.dataframe$record_id))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
  row.names = FALSE, na = "", fileEncoding = "UTF-8")
item_encoded <- NA_character_
## Public export is opt-in and must resolve the current registry, never the cached DOI.
if (identical(Sys.getenv("EVOM1_SEMENDEFERI_PUBLIC_EXPORT"), "YES_AFTER_VALIDATION")) {
  if (is.na(base)) stop("Fresh mounted __ReadMe.xlsx is required.", call. = FALSE)
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Install project dependency readxl.", call. = FALSE)
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  hit <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
  if (length(hit) != 1L) stop("Exactly one current Item name row required.", call. = FALSE)
  item_encoded <- as.character(filecodes$`Item encoded`[hit])
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("[/\\\\]", item_encoded) || grepl("_$", item_encoded))
    stop("Current Item encoded is missing or unsafe.", call. = FALSE)
  role <- as.character(filecodes$`Data role (primary/secondary/both)`[hit])
  if (is.na(role) || tolower(trimws(role)) != "primary") stop("Current primary role required.", call. = FALSE)
  if (!dir.exists(file.path(base, "__Public", "comparative-data")))
    stop("Repo-level __Public/comparative-data must already exist.", call. = FALSE)
  utils::write.table(final.dataframe,
    file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
    sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("Public TSV withheld; clean R execution and fresh-registry validation remain required.")
