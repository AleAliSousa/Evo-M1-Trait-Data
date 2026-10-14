# Frozen published table -> analysis. Measurement literals live only in data files.
# Default: CSV only. A TSV shelf export requires an explicit owner opt-in.
.script_candidates <- character()
for (.frame in rev(sys.frames())) {
  for (.name in c("ofile", "file")) {
    .candidate <- .frame[[.name]]
    if (is.character(.candidate) && length(.candidate) == 1L && !is.na(.candidate)) {
      .script_candidates <- c(.script_candidates, .candidate)
    }
  }
}
.args <- commandArgs(trailingOnly = FALSE)
.script_candidates <- c(.script_candidates, sub("^--file=", "", .args[grepl("^--file=", .args)]))
if (interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
  .script_candidates <- c(.script_candidates, rstudioapi::getActiveDocumentContext()$path)
}
.script_candidates <- .script_candidates[nzchar(.script_candidates)]
.script_candidates <- .script_candidates[file.exists(.script_candidates)]
.script_candidates <- .script_candidates[grepl("^Stephan_etal_1991_Table(8|10)\\.R$", basename(.script_candidates))]
if (!length(.script_candidates)) stop("Cannot locate this exact saved item reader via source frames or --file.")
.script <- normalizePath(.script_candidates[1L], winslash = "/", mustWork = TRUE)
folder <- dirname(.script)
item_name <- sub("\\.R$", "", basename(.script))
base <- dirname(folder)
while (!file.exists(file.path(base, "__ReadMe.xlsx"))) {
  .parent <- dirname(base)
  if (identical(.parent, base)) stop("A repository with a current __ReadMe.xlsx is required; no encoded stem is guessed.")
  base <- .parent
}
if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl in the local R environment before this exact-item build.")
filecodes <- as.data.frame(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"), stringsAsFactors = FALSE)
if (!all(c("Item name", "Item encoded") %in% names(filecodes))) stop("Registry naming columns are absent.")
.matches <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
if (length(.matches) != 1L) stop("Expected exactly one fresh registry match by exact Item name.")
item_encoded <- as.character(filecodes[["Item encoded"]][.matches])
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded) || grepl("[/\\\\]", item_encoded)) stop("Registry Item encoded is invalid; no fallback filename is constructed.")
.table8 <- endsWith(item_name, "_Table8")
.ncolumns <- if (.table8) 8L else 7L
.snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE, colClasses = "character", na.strings = character(), blank.lines.skip = FALSE, check.names = FALSE, fileEncoding = "UTF-8")
if (ncol(.snapshot) != .ncolumns) stop("Unexpected published-grid width.")
.data_rows <- which(grepl("^[0-9]+(?:\\.[0-9]+)?$", .snapshot[[3L]], perl = TRUE))
if (length(.data_rows) != 50L) stop("Expected 50 printed taxon rows.")
.family <- ""
.families <- character(nrow(.snapshot))
for (.i in seq_len(nrow(.snapshot))) {
  if (.snapshot[[1L]][.i] %in% c("Tenrecidae", "Chrysochloridae", "Solenodontidae", "Erinaceidae", "Talpidae", "Soricidae")) .family <- .snapshot[[1L]][.i]
  .families[.i] <- .family
}
.num <- function(x) {
  .blank <- x == ""
  if (any(!.blank & !grepl("^[0-9]+(?:\\.[0-9]+)?$", x, perl = TRUE))) stop("Unexpected source numeric glyph; do not repair automatically.")
  .out <- as.numeric(x)
  .out[.blank] <- NA_real_
  .out
}
final.dataframe <- data.frame(Source_row = seq_along(.data_rows), Family_as_published = .families[.data_rows], Species_Stephan1991 = .snapshot[[1L]][.data_rows], n_reported = .num(.snapshot[[2L]][.data_rows]), stringsAsFactors = FALSE, check.names = FALSE)
.measure_names <- if (.table8) c("NET_Vol.mm3", "NET_pct.standard_BrV", "VENT_Vol.mm3", "VENT_pct.standard_BrV", "REST_Vol.mm3", "REST_pct.standard_BrV") else c("OBL_Vol.mm3", "MES_Vol.mm3", "CER_Vol.mm3", "DIE_Vol.mm3", "TEL_Vol.mm3")
# Units are already mm3 (Table 8 headers; Table 1 p.396 for Table 10).
# Reported percentages are read, never recomputed, renormalized, or promoted to volumes.
for (.j in seq_along(.measure_names)) final.dataframe[[.measure_names[.j]]] <- .num(.snapshot[[.j + 2L]][.data_rows])
.context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")), colClasses = "character", na.strings = character(), check.names = FALSE, fileEncoding = "UTF-8")
.join_columns <- c("Source_row", "Family_as_published", "Species_Stephan1991")
.key <- function(x) paste(x[["Source_row"]], x[["Family_as_published"]], x[["Species_Stephan1991"]], sep = "\r")
if (!all(.join_columns %in% names(.context)) || anyDuplicated(.key(.context))) stop("Item context keys are absent or duplicated.")
.match <- match(.key(final.dataframe), .key(.context))
if (anyNA(.match) || nrow(.context) != nrow(final.dataframe)) stop("Context is not a complete exact printed-row join.")
for (.column in setdiff(names(.context), .join_columns)) final.dataframe[[.column]] <- .context[[.column]][.match]
if (any(final.dataframe$Reference != item_name) || any(final.dataframe$Primary_ingestion_eligible != "FALSE") || any(final.dataframe$Method_compatible_merge_eligible != "FALSE")) stop("The unresolved provenance/method gates must remain closed.")
.abbreviations <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_abbreviations.csv")), colClasses = "character", na.strings = character(), check.names = FALSE, fileEncoding = "UTF-8")
if (!setequal(.abbreviations$abbreviation, unique(sub("_.*$", "", .measure_names)))) stop("Source abbreviation coverage is incomplete.")
if (.table8) {
  standard_BrV_context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_standard_BrV_context.csv")), colClasses = "character", na.strings = character(), check.names = FALSE, fileEncoding = "UTF-8")
  if (anyDuplicated(.key(standard_BrV_context)) || anyNA(match(.key(final.dataframe), .key(standard_BrV_context))) || nrow(standard_BrV_context) != 50L) stop("Standard BrV context keys do not match the printed Table 8 rows.")
  if (any(standard_BrV_context$independent_observation_eligible != "FALSE")) stop("Standard BrV is dependent support, not another observation.")
  # Keep Table 3 context separate: never insert its values into this analysis or recalculate BrV.
}
.definitions <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_definitions.csv")), colClasses = "character", na.strings = character(), check.names = FALSE, fileEncoding = "UTF-8")
if (!identical(names(.definitions), c("Code", "Definition", "Structure", "Measure", "Stat", "role", "taxon", "Reference", "Note", "Source Note"))) stop("Dictionary must have the exact ten headers.")
if (!all(names(final.dataframe) %in% .definitions$Code)) stop("Dictionary misses analysis columns.")
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (identical(Sys.getenv("EVOM1_WRITE_PUBLIC_TSV"), "YES")) {
  warning("Explicit owner-requested shelf export only: primary-ingestion and method-compatible merge gates remain FALSE.")
  dir.create(file.path(base, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
  utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message("Prepared CSV only; public TSV withheld. R validation and human/source-method review remain required.")
}
