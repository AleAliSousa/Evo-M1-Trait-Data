## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"))) Sys.setenv(EVOM1_ALLOW_PUBLIC_TSV = "validated")
## Braitenberg & Schuz (1998), bounded Text item: the printed statements behind the values that
## Zhang & Sejnowski (2000) cite as ref. 30 (book pp. 25/27 and 169). Constructed frozen source -> CSV.
## Reader: Microsoft Copilot AI assistant, 2026-10-22 (America/Los_Angeles); values confirmed on the
## rendered page images, not only the OCR text layer. AI reading, NOT human visual curation.
## R execution and canonical build/validate remain pending; not FINISHED.
options(scipen = 999)
.sp <- local({
  is_me <- function(p) is.character(p) && length(p) == 1L && grepl("_Text\\.R$", p) && file.exists(p)
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    for (name in c("ofile", "file")) {
      p <- tryCatch(get(name, envir = fr[[k]], inherits = FALSE), error = function(e) NULL)
      if (is_me(p)) return(normalizePath(p))
    }
  }
  a <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(a) == 1L && is_me(a)) return(normalizePath(a))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (is_me(p)) return(normalizePath(p))
  }
  stop("Run this file with Rscript, source()/sys.source(), or save and Source in RStudio.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
read_source <- function(path) utils::read.csv(path, colClasses = "character",
  stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = "UTF-8", na.strings = "")
snap <- read_source(file.path(folder, paste0(item_name, "_snapshot.csv")))
context <- read_source(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")))
stopifnot(nrow(snap) == 5L, !anyDuplicated(snap$record_id), !anyDuplicated(context$record_id),
          setequal(snap$record_id, context$record_id))
context <- context[match(snap$record_id, context$record_id), , drop = FALSE]

## Parse printed notation only: a single number, "between A and B" (kept as a range, no midpoint),
## or the order of magnitude 10^5 printed with a superscript. No biological value is typed in here.
parse_value <- function(x) {
  x <- trimws(x)
  if (grepl("^between [0-9.]+ and [0-9.]+$", x)) {
    p <- as.numeric(regmatches(x, gregexpr("[0-9.]+", x))[[1]])
    stopifnot(length(p) == 2L, !anyNA(p), p[1] < p[2])
    return(c(value = NA_real_, lower = p[1], upper = p[2]))
  }
  if (x %in% c("10\u2075", "10^5")) return(c(value = 1e5, lower = NA_real_, upper = NA_real_))
  v <- as.numeric(x)
  stopifnot(!is.na(v))
  c(value = v, lower = NA_real_, upper = NA_real_)
}
parsed <- do.call(rbind, lapply(snap$printed_value, parse_value))
unit_map <- c("mm\u00b3" = "mm\u00b3", "mm" = "mm", "per square millimetre" = "neurons/mm\u00b2")
units <- unname(unit_map[snap$printed_unit])
stopifnot(!anyNA(units))

final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  record_id = snap$record_id,
  species_as_published = snap$species_term,
  measure_code = snap$measure_code,
  value = parsed[, "value"], value_lower = parsed[, "lower"], value_upper = parsed[, "upper"],
  unit = units,
  printed_value = snap$printed_value, printed_unit = snap$printed_unit,
  qualifier_as_printed = snap$qualifier_as_printed,
  structure_scope = context$structure_scope, hemisphere_scope = context$hemisphere_scope,
  stat = context$stat, approximate = context$approximate == "TRUE",
  data_role = context$data_role, provenance_status = context$provenance_status,
  merge_gate = context$merge_gate,
  source_ref_key = snap$reference_keys_printed,
  source_locus = snap$source_locus,
  source_pdf_page = as.integer(snap$source_pdf_page),
  source_printed_page = as.integer(snap$source_printed_page),
  source_year = 1998L,
  stringsAsFactors = FALSE, check.names = FALSE
)
v <- stats::setNames(final.dataframe$value, final.dataframe$record_id)
lo <- stats::setNames(final.dataframe$value_lower, final.dataframe$record_id)
stopifnot(v[["neocortex_volume_one_hemisphere"]] < v[["cortex_incl_hippocampus_volume_one_hemisphere"]],
          v[["cortex_thickness_mean_paraffin"]] < lo[["cortex_thickness_mean_unfixed_estimate"]],
          all(final.dataframe$data_role %in% c("primary", "secondary")))
## Cross-publication note only (not stored as data): Zhang & Sejnowski (2000) give G = 112 mm3,
## which is 2 x the neocortex volume printed for ONE hemisphere. W = 13 mm3 is not printed in this book.
message(sprintf("Neocortex, both hemispheres = 2 x %g = %g mm3 (Zhang & Sejnowski 2000 G = 112 mm3).",
                v[["neocortex_volume_one_hemisphere"]], 2 * v[["neocortex_volume_one_hemisphere"]]))

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

## Fresh registry authority is resolved only by Item name; no cached row fallback.
item_encoded <- NA_character_
if (!is.na(base) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  matches <- which(nfc(filecodes$`Item name`) == nfc(item_name))
  if (length(matches) == 1L) item_encoded <- filecodes$`Item encoded`[matches]
}
authority <- length(item_encoded) == 1L && !is.na(item_encoded) &&
             nzchar(item_encoded) && !grepl("_$|[/\\\\]", item_encoded)
if (authority && identical(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"), "validated")) {
  if (!dir.exists(file.path(base, "__Public", "comparative-data"))) {
    warning("Public destination unavailable; TSV withheld.")
  } else {
    utils::write.table(final.dataframe,
                       file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                       sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  }
} else warning("Public TSV withheld: fresh authority and explicit post-validation publication gate required.")
