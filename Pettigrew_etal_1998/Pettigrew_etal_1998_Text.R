## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"))) Sys.setenv(EVOM1_ALLOW_PUBLIC_TSV = "validated")
## Pettigrew et al. (1998), bounded Text item: constructed frozen source -> CSV.
## Reader: Microsoft Copilot AI assistant, 2026-10-10 (America/Los_Angeles).
## R execution and canonical build/validate remain pending; not FINISHED.
.sp <- local({
  me <- "Pettigrew_etal_1998_Text.R"
  ## Innermost source()/sys.source() frame precedes a wrapper's --file=.
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    for (name in c("ofile", "file")) {
      p <- tryCatch(get(name, envir = fr[[k]], inherits = FALSE),
                    error = function(e) NULL)
      if (is.character(p) && length(p) == 1L && basename(p) == me && file.exists(p))
        return(normalizePath(p))
    }
  }
  a <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(a) == 1L && basename(a) == me && file.exists(a)) return(normalizePath(a))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me && file.exists(p)) return(normalizePath(p))
  }
  stop("Run this file with Rscript, source()/sys.source(), or save and Source in RStudio.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
read_source <- function(path) utils::read.csv(path, colClasses = "character",
  stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = "UTF-8", na.strings = "")
snap <- read_source(file.path(folder, paste0(item_name, "_snapshot.csv")))
context <- read_source(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")))
species <- read_source(file.path(folder, "reference_tables", paste0(item_name, "_species_context.csv")))
stopifnot(nrow(species) == 1L, species$item_name == item_name,
          !anyDuplicated(snap$record_id), !anyDuplicated(context$record_id),
          setequal(snap$record_id, context$record_id))
context <- context[match(snap$record_id, context$record_id), , drop = FALSE]

## Remove printed thousands spaces, split printed range bounds, and divide ratio
## numerator by denominator; no biological values are defined in this script.
parsed <- lapply(snap$printed_value, function(x) {
  x <- gsub("[[:space:]]", "", x)
  if (grepl(":", x, fixed = TRUE)) {
    parts <- as.numeric(strsplit(x, ":", fixed = TRUE)[[1]])
    stopifnot(length(parts) == 2L, !anyNA(parts), parts[2] != 0)
    return(c(value = parts[1] / parts[2], lower = NA_real_, upper = NA_real_))
  }
  if (grepl("–", x, fixed = TRUE)) {
    parts <- as.numeric(strsplit(x, "–", fixed = TRUE)[[1]])
    stopifnot(length(parts) == 2L, !anyNA(parts), parts[1] <= parts[2])
    return(c(value = NA_real_, lower = parts[1], upper = parts[2]))
  }
  value <- as.numeric(x)
  stopifnot(!is.na(value))
  c(value = value, lower = NA_real_, upper = NA_real_)
})
parsed <- do.call(rbind, parsed)
unit_map <- c("ganglion cells per square millimetre" = "cells/mm²",
              "ratio" = "dimensionless", "ganglion cells" = "cells",
              "cycles deg⁻¹" = "cycles/deg", "kHz" = "kHz",
              "electroreceptors" = "receptors", "mV cm⁻¹" = "mV/cm",
              "µV cm⁻¹" = "µV/cm")
units <- unname(unit_map[snap$printed_unit])
stopifnot(!anyNA(units))
## Threshold normalization only: 1 mV/cm = 1000 µV/cm. Keep original units/data.
electric <- units %in% c("mV/cm", "µV/cm")
multiplier <- ifelse(units == "mV/cm", 1000, 1)
normal <- parsed * multiplier
normal[!electric, ] <- NA_real_
final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  record_id = snap$record_id,
  species_as_published = snap$species_term,
  measure_code = snap$measure_code,
  value = parsed[, "value"], value_lower = parsed[, "lower"], value_upper = parsed[, "upper"],
  unit = units,
  printed_value = snap$printed_value, printed_unit = snap$printed_unit,
  qualifier_as_printed = snap$qualifier_as_printed,
  approximate = context$approximate == "TRUE", stat = context$stat,
  threshold_value_uV_per_cm = normal[, "value"],
  threshold_lower_uV_per_cm = normal[, "lower"], threshold_upper_uV_per_cm = normal[, "upper"],
  data_role = context$data_role,
  source_ref_key = snap$reference_keys_printed,
  provenance_status = context$provenance_status, merge_gate = context$merge_gate,
  source_uncertainty = context$source_uncertainty,
  source_locus = snap$source_locus,
  source_pdf_page = as.integer(snap$source_pdf_page),
  source_printed_page = as.integer(snap$source_printed_page),
  source_year = as.integer(species$source_year),
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(nrow(final.dataframe) == 9L,
          all(final.dataframe$species_as_published == species$species_as_published),
          all(final.dataframe$data_role %in% c("primary", "secondary")))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

## Fresh registry authority is resolved only by Item name; no cached row fallback.
item_encoded <- NA_character_
if (!is.na(base) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  matches <- which(filecodes$`Item name` == item_name)
  if (length(matches) == 1L) item_encoded <- filecodes$`Item encoded`[matches]
}
authority <- length(item_encoded) == 1L && !is.na(item_encoded) &&
             nzchar(item_encoded) && !grepl("_$|[/\\\\]", item_encoded)
## Opt-in only after fresh registry authority AND canonical R validation.
if (authority && identical(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"), "validated")) {
  if (!dir.exists(file.path(base, "__Public", "comparative-data"))) {
    warning("Public destination unavailable; TSV withheld.")
  } else {
    utils::write.table(final.dataframe,
                file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  }
} else warning("Public TSV withheld: fresh authority and explicit post-validation publication gate required.")
