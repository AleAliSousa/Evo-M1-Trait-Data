# Frozen printed table -> analysis CSV. TSV export remains explicitly gated.
self <- local({
  own_basename <- "Bjugn__1993_TABLEV.R"
  candidates <- character()
  frames <- sys.frames()
  for (frame in rev(frames)) {
    for (field in c("ofile", "file", "filename")) {
      candidate <- frame[[field]]
      if (is.character(candidate)) candidates <- c(candidates, candidate)
    }
    src <- frame[["srcfile"]]
    if (is.environment(src) || is.list(src)) {
      candidate <- src[["filename"]]
      if (is.character(candidate)) candidates <- c(candidates, candidate)
    }
  }
  # A source()/sys.source() frame must precede a wrapper's --file argument.
  args <- commandArgs(trailingOnly = FALSE)
  candidates <- c(candidates, sub("^--file=", "", args[grepl("^--file=", args)]))
  candidates <- candidates[!is.na(candidates) & nzchar(candidates)]
  candidates <- candidates[basename(candidates) == own_basename & file.exists(candidates)]
  if (!length(candidates)) stop("Cannot locate this script by its own basename.")
  normalizePath(candidates[[1L]], winslash = "/", mustWork = TRUE)
})
folder <- dirname(self)
base <- normalizePath(file.path(folder, ".."), winslash = "/", mustWork = TRUE)
item_name <- tools::file_path_sans_ext(basename(self))
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
                           colClasses = "character", check.names = FALSE, na.strings = NULL,
                           fileEncoding = "UTF-8")
if (anyDuplicated(context$key) || any(context$Reference != item_name)) stop("Invalid item context.")
ctx <- function(key) {
  index <- match(key, context$key)
  if (is.na(index)) stop(paste("Missing context key:", key))
  context$value[[index]]
}
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                            header = FALSE, colClasses = "character", check.names = FALSE,
                            fill = TRUE, blank.lines.skip = FALSE, na.strings = NULL,
                            fileEncoding = "UTF-8")
number <- function(x) {
  out <- suppressWarnings(as.numeric(x))
  if (any(is.na(out))) stop("Unparseable published numeric cell.")
  out
}

if (snapshot[1L, 1L] != "TABLE V") stop("Wrong printed table.")
labels <- trimws(snapshot[[1L]])
header <- which(labels == "")
if (length(header) != 1L) stop("Expected one published portion-header row.")
final.dataframe <- data.frame(AnatomicalPortionAsPublished = unlist(snapshot[header, -1L], use.names = FALSE),
                             stringsAsFactors = FALSE, check.names = FALSE)
printed_codes <- c("Volume", "Number of glia", "Number of endothelia", "Number of unidentified",
                   "Number of neurons", "Category 1 ᵃ", "Category 2 ᵇ", "Category 3 ᶜ")
measure_codes <- c("GrayMatterVolume_mm3", "GlialCount_cells", "EndothelialCount_cells",
                   "UnidentifiedCount_cells", "NeuronCount_cells", "NeuronCategory1_pct",
                   "NeuronCategory2_pct", "NeuronCategory3_pct")
for (index in seq_along(measure_codes)) {
  row <- which(labels == printed_codes[[index]])
  if (length(row) != 1L) stop("Missing or duplicated printed measure row.")
  value <- number(sub("%$", "", unlist(snapshot[row, -1L], use.names = FALSE)))
  # Convert only million-cell counts. Percentages stay on the printed 0–100 scale.
  if (index > 1L && index < 6L) value <- value * 10^6
  final.dataframe[[measure_codes[[index]]]] <- value
}

common <- c("species_as_published", "Strain", "Sex", "AgeStage", "Tissue", "ObservationLevel",
            "Statistic", "EstimateType", "ContributingAnimalsN", "ContributingAnimalsStatus",
            "StudyEnrolledN", "StudyAnimalIDs", "CohortDependency")
tail <- c("SourceCountUnit", "SourceVolumeUnit", "ConfidenceNote", "SourceDiscrepancyNote",
          "Reference", "SourceReader", "SourceReadDate", "HumanVisualCuration", "PublicationGate")
for (code in c(common, tail)) final.dataframe[[code]] <- ctx(code)
for (code in c("AnimalID", "AnatomicalScope")) final.dataframe[[code]] <- ctx(code)
final.dataframe$CoverageAsAuthorPrinted_pct <- number(ctx("CoverageAsAuthorPrinted_pct"))
for (code in c("ContributingAnimalsN", "StudyEnrolledN")) {
  value <- ctx(code)
  final.dataframe[[code]] <- if (nzchar(value)) number(value) else NA_real_
}

final.dataframe <- final.dataframe[, c(common, "AnimalID", "AnatomicalPortionAsPublished", "AnatomicalScope", "CoverageAsAuthorPrinted_pct", measure_codes, tail), drop = FALSE]
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

if (identical(Sys.getenv("EVOM1_PUBLISH_PUBLIC_TSV"), "true")) {
  if (!identical(Sys.getenv("EVOM1_R_QA_CONFIRMED"), "true"))
    stop("Canonical R audit/dry-run/build/validation must be confirmed before public export.")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  index <- which(filecodes[["Item name"]] == item_name)
  if (length(index) != 1L) stop("Registry must contain exactly one row matched by Item name.")
  citation <- as.character(filecodes[["Citation (APA 7th-Annotated)"]][[index]])
  override <- as.character(filecodes[["DOI if different from article or doi Alt "]][[index]])
  resolved <- as.character(filecodes[["DOI (or Alt)"]][[index]])
  if (is.na(citation) || !endsWith(trimws(citation), paste0("https://doi.org/", ctx("SourceDOI"))))
    stop("Owner must correct the article citation DOI before trusting code authority.")
  if (!is.na(override) && nzchar(trimws(override)) && utils::URLdecode(trimws(override)) != ctx("SourceDOI"))
    stop("Owner must clear or correct Column C's DOI override.")
  if (is.na(resolved) || utils::URLdecode(resolved) != ctx("SourceDOI"))
    stop("Registry DOI formulas/cached results require owner recalculation.")
  item_encoded <- as.character(filecodes[["Item encoded"]][[index]])
  locus <- sub(paste0("^", basename(folder), "_"), "", item_name)
  if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded) ||
      !identical(utils::URLdecode(item_encoded), paste0(ctx("SourceDOI"), "_", locus)))
    stop("Registry Item encoded does not match the corrected article DOI and exact item suffix.")
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!dir.exists(tsv_dir)) stop("Canonical public folder must already exist; no folder creation here.")
  utils::write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                     sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message(ctx("PublicationGate"), "; analysis CSV only; no registry code authority read.")
}
