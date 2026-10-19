## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (!nzchar(Sys.getenv("EVOM1_TEXT_PUBLIC_EXPORT"))) Sys.setenv(EVOM1_TEXT_PUBLIC_EXPORT = "YES_AFTER_VALIDATION")
## Constructed prose snapshot -> analysis CSV. SECONDARY; excluded from merges.
## PREPARED / R_PENDING: this script has not been executed in R.

.sp <- local({
  ## source()/sys.source() frames precede --file=, which may name a wrapper.
  fr <- sys.frames()
  calls <- sys.calls()
  for (k in rev(seq_along(fr))) {
    p <- tryCatch(get("ofile", envir = fr[[k]], inherits = FALSE), error = function(e) NULL)
    if (is.character(p) && length(p) == 1L && nzchar(p) && file.exists(p))
      return(normalizePath(p))
    fun <- tryCatch(paste(deparse(calls[[k]][[1L]]), collapse = ""), error = function(e) "")
    if (fun %in% c("source", "sys.source", "base::source", "base::sys.source")) {
      p <- tryCatch(get("file", envir = fr[[k]], inherits = FALSE), error = function(e) NULL)
      if (is.character(p) && length(p) == 1L && nzchar(p) && file.exists(p))
        return(normalizePath(p))
    }
  }
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source the saved script.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", check.names = FALSE,
                 stringsAsFactors = FALSE, fileEncoding = "UTF-8", na.strings = NULL)
num <- function(x) {
  y <- suppressWarnings(as.numeric(x))
  if (any(nzchar(x) & is.na(y))) stop("Unparseable numeric snapshot cell.", call. = FALSE)
  y
}
value <- num(snap$`Value as printed`)
value_unit <- snap$`Unit as printed`
## Frequency measures kHz -> Hz; snapshot keeps the printed units and precision.
value[snap$`Unit as printed` == "kHz"] <- value[snap$`Unit as printed` == "kHz"] * 1000
value_unit[value_unit %in% c("kHz", "Hz")] <- "Hz"
## MAA has no printed unit symbol. Degrees are an explicit contextual assignment.
value_unit[snap$`Measurement class` %in% c("measured_spatial_acuity", "receiving_beam_width")] <- "degree"
value_unit[snap$`Measurement class` == "measured_hearing_threshold"] <- "dB SPL re 1 μPa"
frequency_Hz <- num(snap$`Frequency as printed`)
frequency_Hz[snap$`Frequency unit as printed` == "kHz"] <- frequency_Hz[snap$`Frequency unit as printed` == "kHz"] * 1000

final.dataframe <- data.frame(
  record_id = snap$Record,
  species_as_published = snap$`Species as printed`,
  scientific_name_as_published = snap$`Scientific name as printed`,
  measurement = snap$`Measure as described`,
  measurement_class = snap$`Measurement class`,
  plane = snap$Plane,
  value_as_published = snap$`Value as printed`,
  unit_as_published = snap$`Unit as printed`,
  value = value,
  value_unit = value_unit,
  qualifier = snap$`Qualifier as printed`,
  frequency_as_published = snap$`Frequency as printed`,
  frequency_unit_as_published = snap$`Frequency unit as printed`,
  frequency_Hz = frequency_Hz,
  pressure_reference_uPa = ifelse(snap$`Measurement class` == "measured_hearing_threshold", 1, NA_real_),
  pressure_reference_basis = ifelse(snap$`Measurement class` == "measured_hearing_threshold", "Figure 4.2 y-axis, p.204: SPL (dB re:1μPa)", ""),
  reference = snap$`Citation key`,
  printed_page = num(snap$`Printed page`),
  pdf_page = num(snap$`PDF page`),
  section = snap$Section,
  sentence_locator = snap$`Sentence locator`,
  unit_evidence = snap$`Unit evidence`,
  method = snap$`Method context`,
  observation_level = snap$`Observation level`,
  individual_context = snap$`Individual context`,
  sample_size_context = snap$`Sample size context`,
  duration_context = snap$`Duration context`,
  source_criterion = snap$`Source criterion`,
  interpretation_note = snap$`Interpretation note`,
  data_role = "secondary",
  measured_hearing = snap$`Measurement class` %in% c("measured_hearing_limit", "measured_hearing_threshold", "measured_spatial_acuity"),
  merge_eligible = FALSE,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(!anyDuplicated(final.dataframe$record_id), !anyNA(final.dataframe$value))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

item_encoded <- NA_character_
if (!is.na(base)) {
  if (!requireNamespace("readxl", quietly = TRUE)) stop("Install the project dependency readxl before registry validation.", call. = FALSE)
  ## Re-read the mounted registry each run; never use a cached code or row position.
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  hit <- which(filecodes$`Item name` == item_name)
  if (length(hit) != 1L) stop("Item name must have exactly one current registry row.", call. = FALSE)
  item_encoded <- filecodes$`Item encoded`[hit]
  if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("[/\\\\]", item_encoded) || grepl("_$", item_encoded))
    stop("Current Item encoded is missing or unsafe.", call. = FALSE)
  if (tolower(filecodes$`Data role (primary/secondary/both)`[hit]) != "secondary")
    stop("Registry must retain SECONDARY role.", call. = FALSE)
}
## Default is no public write. Owner sets this only after a clean R run and
## current-registry dataset-builder validation have passed (see README).
if (identical(Sys.getenv("EVOM1_TEXT_PUBLIC_EXPORT"), "YES_AFTER_VALIDATION")) {
  if (is.na(base) || is.na(item_encoded)) stop("Fresh mounted registry required for public export.", call. = FALSE)
  if (!dir.exists(file.path(base, "__Public", "comparative-data")))
    stop("Repo-level __Public/comparative-data must already exist.", call. = FALSE)
  utils::write.table(final.dataframe,
              file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("Public TSV withheld: R clean-build and fresh-registry validation remain required.")
